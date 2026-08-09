import 'dart:convert';

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
    await _database
        .into(_database.profileStates)
        .insertOnConflictUpdate(
          ProfileStatesCompanion.insert(
            profileId: id,
            displayName: name.trim(),
            payload: jsonEncode(data.toJson()),
            storageVersion: const Value(StorageMigrationEngine.currentVersion),
            updatedAt: DateTime.now(),
          ),
        );
  }

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
    await _database
        .into(_database.appMeta)
        .insertOnConflictUpdate(
          AppMetaCompanion.insert(key: 'activeProfileId', value: id),
        );
    _activeProfileId = id;
    await recordDiagnostic(
      category: 'profiles',
      message: 'Switched active local profile.',
    );
    final migration = StorageMigrationEngine.migrate(
      jsonDecode(state.payload) as Map<String, dynamic>,
      fromVersion: state.storageVersion,
    );
    return FitnessData.fromJson(migration.json);
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
