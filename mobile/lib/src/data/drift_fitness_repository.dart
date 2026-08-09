import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../models/fitness_models.dart';
import '../storage_migration_engine.dart';
import 'drift_connection.dart';
import 'local_fitness_repository.dart';
import 'phoenix_database.dart';

class LocalProfileInfo {
  const LocalProfileInfo({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.isActive,
  });

  final String id;
  final String name;
  final DateTime updatedAt;
  final bool isActive;
}

class DiagnosticEntry {
  const DiagnosticEntry({
    required this.level,
    required this.category,
    required this.message,
    required this.createdAt,
  });

  final String level;
  final String category;
  final String message;
  final DateTime createdAt;
}

abstract interface class ReliabilityRepository {
  Future<List<LocalProfileInfo>> listProfiles();
  Future<String> createProfile(String name, FitnessData data);
  Future<FitnessData> switchProfile(String id);
  Future<void> deleteProfile(String id);
  Future<void> recordDiagnostic({
    required String category,
    required String message,
    String level = 'info',
  });
  Future<List<DiagnosticEntry>> recentDiagnostics({int limit = 100});
  String get activeProfileId;
}

class DriftFitnessRepository
    implements FitnessRepository, ReliabilityRepository {
  DriftFitnessRepository({PhoenixDatabase? database, this.legacyRepository})
    : _database = database ?? PhoenixDatabase(openPhoenixConnection());

  final PhoenixDatabase _database;
  final LocalFitnessRepository? legacyRepository;
  String _activeProfileId = 'default';

  @override
  String get activeProfileId => _activeProfileId;

  @override
  Future<FitnessData> load() async {
    final active = await (_database.select(
      _database.appMeta,
    )..where((row) => row.key.equals('activeProfileId'))).getSingleOrNull();
    _activeProfileId = active?.value ?? 'default';
    var state =
        await (_database.select(_database.profileStates)
              ..where((row) => row.profileId.equals(_activeProfileId)))
            .getSingleOrNull();
    if (state == null) {
      final legacy = legacyRepository == null
          ? FitnessData.initial()
          : await legacyRepository!.load();
      await _writeProfile(
        id: _activeProfileId,
        name: legacy.profile == null ? 'Main Athlete' : 'Main Athlete',
        data: legacy,
      );
      state = await (_database.select(
        _database.profileStates,
      )..where((row) => row.profileId.equals(_activeProfileId))).getSingle();
      await recordDiagnostic(
        category: 'migration',
        message: 'Initialized Drift/SQLite profile from legacy local storage.',
      );
    }
    final expectedChecksum = state.checksum;
    final actualChecksum = _checksum(state.payload);
    if (expectedChecksum.isNotEmpty && expectedChecksum != actualChecksum) {
      await _database
          .into(_database.profileSnapshots)
          .insert(
            ProfileSnapshotsCompanion.insert(
              profileId: state.profileId,
              payload: state.payload,
              checksum: expectedChecksum,
              storageVersion: state.storageVersion,
              reason: 'checksum-mismatch',
              quarantined: const Value(true),
              createdAt: DateTime.now(),
            ),
          );
      final snapshots =
          await (_database.select(_database.profileSnapshots)
                ..where(
                  (row) =>
                      row.profileId.equals(state!.profileId) &
                      row.quarantined.equals(false),
                )
                ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
              .get();
      final valid = snapshots
          .where((item) => _checksum(item.payload) == item.checksum)
          .firstOrNull;
      if (valid == null) {
        await recordDiagnostic(
          category: 'integrity',
          level: 'error',
          message:
              'Quarantined a profile with invalid checksum; no verified snapshot was available.',
        );
        throw const FormatException(
          'Profile checksum mismatch. The payload was quarantined without being overwritten.',
        );
      }
      await _database
          .into(_database.profileStates)
          .insertOnConflictUpdate(
            ProfileStatesCompanion.insert(
              profileId: state.profileId,
              displayName: state.displayName,
              payload: valid.payload,
              storageVersion: Value(valid.storageVersion),
              checksum: Value(valid.checksum),
              updatedAt: DateTime.now(),
            ),
          );
      await recordDiagnostic(
        category: 'integrity',
        level: 'warning',
        message: 'Recovered active profile from the newest verified snapshot.',
      );
      state = await (_database.select(
        _database.profileStates,
      )..where((row) => row.profileId.equals(_activeProfileId))).getSingle();
    }
    if (state.checksum.isEmpty) {
      await _database
          .into(_database.profileStates)
          .insertOnConflictUpdate(
            ProfileStatesCompanion.insert(
              profileId: state.profileId,
              displayName: state.displayName,
              payload: state.payload,
              storageVersion: Value(state.storageVersion),
              checksum: Value(actualChecksum),
              updatedAt: state.updatedAt,
            ),
          );
    }
    final migration = StorageMigrationEngine.migrate(
      jsonDecode(state.payload) as Map<String, dynamic>,
      fromVersion: state.storageVersion,
    );
    final data = FitnessData.fromJson(migration.json);
    if (migration.appliedSteps.isNotEmpty) {
      await _writeProfile(
        id: state.profileId,
        name: state.displayName,
        data: data,
      );
      await recordDiagnostic(
        category: 'migration',
        message: migration.appliedSteps.join(' • '),
      );
    }
    return data;
  }

  @override
  Future<void> save(FitnessData data) async {
    final existing =
        await (_database.select(_database.profileStates)
              ..where((row) => row.profileId.equals(_activeProfileId)))
            .getSingleOrNull();
    await _writeProfile(
      id: _activeProfileId,
      name: existing?.displayName ?? 'Main Athlete',
      data: data,
    );
  }

  Future<void> _writeProfile({
    required String id,
    required String name,
    required FitnessData data,
  }) async {
    final payload = jsonEncode(data.toJson());
    final checksum = _checksum(payload);
    await _database.transaction(() async {
      final existing = await (_database.select(
        _database.profileStates,
      )..where((row) => row.profileId.equals(id))).getSingleOrNull();
      if (existing != null && existing.payload != payload) {
        await _database
            .into(_database.profileSnapshots)
            .insert(
              ProfileSnapshotsCompanion.insert(
                profileId: id,
                payload: existing.payload,
                checksum: existing.checksum.isEmpty
                    ? _checksum(existing.payload)
                    : existing.checksum,
                storageVersion: existing.storageVersion,
                reason: 'before-write',
                createdAt: DateTime.now(),
              ),
            );
      }
      await _database
          .into(_database.profileStates)
          .insertOnConflictUpdate(
            ProfileStatesCompanion.insert(
              profileId: id,
              displayName: name.trim(),
              payload: payload,
              storageVersion: const Value(
                StorageMigrationEngine.currentVersion,
              ),
              checksum: Value(checksum),
              updatedAt: DateTime.now(),
            ),
          );
      final snapshots =
          await (_database.select(_database.profileSnapshots)
                ..where(
                  (row) =>
                      row.profileId.equals(id) & row.quarantined.equals(false),
                )
                ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
              .get();
      if (snapshots.length > 5) {
        await (_database.delete(_database.profileSnapshots)..where(
              (row) => row.id.isIn(snapshots.skip(5).map((item) => item.id)),
            ))
            .go();
      }
    });
  }

  String _checksum(String payload) =>
      sha256.convert(utf8.encode(payload)).toString();

  @override
  Future<List<LocalProfileInfo>> listProfiles() async {
    final rows = await (_database.select(
      _database.profileStates,
    )..orderBy([(row) => OrderingTerm.desc(row.updatedAt)])).get();
    return [
      for (final row in rows)
        LocalProfileInfo(
          id: row.profileId,
          name: row.displayName,
          updatedAt: row.updatedAt,
          isActive: row.profileId == _activeProfileId,
        ),
    ];
  }

  @override
  Future<String> createProfile(String name, FitnessData data) async {
    final trimmed = name.trim();
    if (trimmed.length < 2 || trimmed.length > 60) {
      throw const FormatException(
        'Το όνομα προφίλ πρέπει να έχει 2–60 χαρακτήρες.',
      );
    }
    final id = 'profile-${DateTime.now().microsecondsSinceEpoch}';
    await _writeProfile(id: id, name: trimmed, data: data);
    await recordDiagnostic(
      category: 'profiles',
      message: 'Created local profile $trimmed.',
    );
    return id;
  }

  @override
  Future<FitnessData> switchProfile(String id) async {
    final state = await (_database.select(
      _database.profileStates,
    )..where((row) => row.profileId.equals(id))).getSingleOrNull();
    if (state == null) {
      throw const FormatException('Το local προφίλ δεν υπάρχει.');
    }
    if (state.checksum.isNotEmpty &&
        _checksum(state.payload) != state.checksum) {
      throw const FormatException(
        'Cannot switch to a profile that fails checksum verification.',
      );
    }
    final migration = StorageMigrationEngine.migrate(
      jsonDecode(state.payload) as Map<String, dynamic>,
      fromVersion: state.storageVersion,
    );
    final data = FitnessData.fromJson(migration.json);
    await _database.transaction(() async {
      await _database
          .into(_database.appMeta)
          .insertOnConflictUpdate(
            AppMetaCompanion.insert(key: 'activeProfileId', value: id),
          );
      _activeProfileId = id;
    });
    await recordDiagnostic(
      category: 'profiles',
      message: 'Switched active local profile transactionally.',
    );
    return data;
  }

  @override
  Future<void> deleteProfile(String id) async {
    if (id == _activeProfileId) {
      throw const FormatException(
        'Δεν μπορείς να διαγράψεις το ενεργό προφίλ.',
      );
    }
    final count = await _database.profileStates.count().getSingle();
    if (count <= 1) {
      throw const FormatException(
        'Πρέπει να παραμείνει τουλάχιστον ένα προφίλ.',
      );
    }
    await (_database.delete(
      _database.profileStates,
    )..where((row) => row.profileId.equals(id))).go();
    await recordDiagnostic(
      category: 'profiles',
      message: 'Deleted inactive local profile.',
      level: 'warning',
    );
  }

  @override
  Future<void> recordDiagnostic({
    required String category,
    required String message,
    String level = 'info',
  }) async {
    await _database
        .into(_database.diagnosticRows)
        .insert(
          DiagnosticRowsCompanion.insert(
            level: Value(level),
            category: category,
            message: message,
            createdAt: DateTime.now(),
          ),
        );
    final oldRows =
        await (_database.select(_database.diagnosticRows)
              ..orderBy([(row) => OrderingTerm.desc(row.id)])
              ..limit(500, offset: 500))
            .get();
    if (oldRows.isNotEmpty) {
      await (_database.delete(
        _database.diagnosticRows,
      )..where((row) => row.id.isIn(oldRows.map((item) => item.id)))).go();
    }
  }

  @override
  Future<List<DiagnosticEntry>> recentDiagnostics({int limit = 100}) async {
    final rows =
        await (_database.select(_database.diagnosticRows)
              ..orderBy([
                (row) => OrderingTerm.desc(row.createdAt),
                (row) => OrderingTerm.desc(row.id),
              ])
              ..limit(limit.clamp(1, 500)))
            .get();
    return [
      for (final row in rows)
        DiagnosticEntry(
          level: row.level,
          category: row.category,
          message: row.message,
          createdAt: row.createdAt,
        ),
    ];
  }
}
