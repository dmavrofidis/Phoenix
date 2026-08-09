import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'models/fitness_models.dart';
import 'secure_backup_engine.dart';

enum SyncResolution { keepLocal, mergeSafely, useIncoming }

class EncryptedSyncPackage {
  const EncryptedSyncPackage({
    required this.deviceId,
    required this.revision,
    required this.baseChecksum,
    required this.contentChecksum,
    required this.createdAt,
    required this.data,
  });

  final String deviceId;
  final int revision;
  final String baseChecksum;
  final String contentChecksum;
  final DateTime createdAt;
  final FitnessData data;
}

class SyncConflictPreview {
  const SyncConflictPreview({
    required this.changedSections,
    required this.conflicts,
    required this.localChecksum,
    required this.incomingChecksum,
    required this.baseMatchesLocal,
  });

  final List<String> changedSections;
  final List<String> conflicts;
  final String localChecksum;
  final String incomingChecksum;
  final bool baseMatchesLocal;

  bool get alreadyInSync => localChecksum == incomingChecksum;
  bool get hasConflicts => conflicts.isNotEmpty;
}

/// A provider-neutral, manual sync protocol. Phoenix only reads or writes the
/// file chosen by the athlete; cloud-folder providers can transport the opaque
/// encrypted package without receiving Phoenix credentials or clear data.
class EncryptedSyncEngine {
  const EncryptedSyncEngine._();

  static const format = 'PHX-ENCRYPTED-SYNC';
  static const version = 1;
  static const maximumEnvelopeBytes = 25 * 1024 * 1024;

  static Future<String> create({
    required FitnessData data,
    required String password,
    required String deviceId,
    required int revision,
    String? baseChecksum,
    DateTime? createdAt,
  }) async {
    final normalizedDeviceId = deviceId.trim();
    if (normalizedDeviceId.length < 3 || normalizedDeviceId.length > 80) {
      throw const FormatException(
        'Sync device ID must contain 3–80 characters.',
      );
    }
    if (revision < 1) {
      throw const FormatException('Sync revision must be positive.');
    }
    final encodedData = jsonEncode(data.toJson());
    final contentChecksum = _checksum(encodedData);
    final normalizedBase = baseChecksum ?? contentChecksum;
    if (!_isChecksum(normalizedBase)) {
      throw const FormatException('Sync base checksum is invalid.');
    }
    final timestamp = (createdAt ?? DateTime.now()).toUtc();
    final secureEnvelope = await SecureBackupEngine.encrypt(
      clearText: jsonEncode({
        'format': format,
        'version': version,
        'deviceId': normalizedDeviceId,
        'revision': revision,
        'baseChecksum': normalizedBase,
        'contentChecksum': contentChecksum,
        'createdAt': timestamp.toIso8601String(),
        'data': data.toJson(),
      }),
      password: password,
    );
    return jsonEncode({
      'format': format,
      'version': version,
      'deviceId': normalizedDeviceId,
      'revision': revision,
      'createdAt': timestamp.toIso8601String(),
      'secureEnvelope': secureEnvelope,
    });
  }

  static Future<EncryptedSyncPackage> open({
    required String envelope,
    required String password,
  }) async {
    if (utf8.encode(envelope).length > maximumEnvelopeBytes) {
      throw const FormatException('Encrypted sync package is too large.');
    }
    try {
      final outer = jsonDecode(envelope) as Map<String, dynamic>;
      if (outer['format'] != format || outer['version'] != version) {
        throw const FormatException('Unsupported encrypted sync package.');
      }
      final clearText = await SecureBackupEngine.decrypt(
        envelope: outer['secureEnvelope'] as String,
        password: password,
      );
      final clear = jsonDecode(clearText) as Map<String, dynamic>;
      if (clear['format'] != format || clear['version'] != version) {
        throw const FormatException('Invalid encrypted sync payload.');
      }
      final deviceId = clear['deviceId'] as String;
      final revision = clear['revision'] as int;
      final createdAt = DateTime.parse(clear['createdAt'] as String).toUtc();
      final baseChecksum = clear['baseChecksum'] as String;
      final contentChecksum = clear['contentChecksum'] as String;
      if (deviceId != outer['deviceId'] ||
          revision != outer['revision'] ||
          createdAt.toIso8601String() != outer['createdAt'] ||
          !_isChecksum(baseChecksum) ||
          !_isChecksum(contentChecksum)) {
        throw const FormatException('Encrypted sync metadata was altered.');
      }
      final dataJson = clear['data'] as Map<String, dynamic>;
      if (_checksum(jsonEncode(dataJson)) != contentChecksum) {
        throw const FormatException('Encrypted sync checksum mismatch.');
      }
      return EncryptedSyncPackage(
        deviceId: deviceId,
        revision: revision,
        baseChecksum: baseChecksum,
        contentChecksum: contentChecksum,
        createdAt: createdAt,
        data: FitnessData.fromJson(dataJson),
      );
    } on FormatException {
      rethrow;
    } on Object {
      throw const FormatException('Encrypted sync package is damaged.');
    }
  }

  static SyncConflictPreview preview({
    required FitnessData local,
    required EncryptedSyncPackage incoming,
  }) {
    final localJson = local.toJson();
    final incomingJson = incoming.data.toJson();
    final changed =
        incomingJson.keys
            .where(
              (key) =>
                  jsonEncode(localJson[key]) != jsonEncode(incomingJson[key]),
            )
            .toList()
          ..sort();
    final conflicts = <String>[];
    if (changed.contains('profile') &&
        local.profile != null &&
        incoming.data.profile != null) {
      conflicts.add(
        'Athlete profile differs; safe merge keeps the local profile.',
      );
    }
    if (changed.contains('preferences')) {
      conflicts.add(
        'Experience and vault settings differ; safe merge keeps local settings.',
      );
    }
    if (changed.contains('templates') && local.templates.isNotEmpty) {
      conflicts.add(
        'Workout templates differ; matching local records win during safe merge.',
      );
    }
    final localChecksum = checksum(local);
    return SyncConflictPreview(
      changedSections: List.unmodifiable(changed),
      conflicts: List.unmodifiable(conflicts),
      localChecksum: localChecksum,
      incomingChecksum: incoming.contentChecksum,
      baseMatchesLocal: incoming.baseChecksum == localChecksum,
    );
  }

  static FitnessData resolve({
    required FitnessData local,
    required EncryptedSyncPackage incoming,
    required SyncResolution resolution,
  }) => switch (resolution) {
    SyncResolution.keepLocal => _copy(local),
    SyncResolution.useIncoming => _copy(incoming.data),
    SyncResolution.mergeSafely => _merge(local, incoming.data),
  };

  static FitnessData _merge(FitnessData local, FitnessData incoming) {
    final localJson = Map<String, dynamic>.from(local.toJson());
    final incomingJson = incoming.toJson();
    for (final entry in incomingJson.entries) {
      final current = localJson[entry.key];
      final remote = entry.value;
      if (current is List && remote is List) {
        localJson[entry.key] = _mergeLists(current, remote);
      } else if (current is Map && remote is Map) {
        localJson[entry.key] = Map<String, dynamic>.from({
          ...remote,
          ...current,
        });
      }
      // Scalar, profile and preferences values deliberately remain local.
    }
    return FitnessData.fromJson(localJson);
  }

  static List<dynamic> _mergeLists(List<dynamic> local, List<dynamic> remote) {
    final result = <dynamic>[];
    final seen = <String>{};
    for (final value in [...local, ...remote]) {
      final key = _stableKey(value);
      if (seen.add(key)) result.add(value);
    }
    return result;
  }

  static String _stableKey(dynamic value) {
    if (value is Map) {
      for (final key in const [
        'id',
        'completedAt',
        'loggedAt',
        'recordedAt',
        'date',
        'day',
      ]) {
        final identity = value[key];
        if (identity != null) return '$key:$identity';
      }
    }
    return jsonEncode(value);
  }

  static FitnessData _copy(FitnessData data) => FitnessData.fromJson(
    jsonDecode(jsonEncode(data.toJson())) as Map<String, dynamic>,
  );

  static String checksum(FitnessData data) =>
      _checksum(jsonEncode(data.toJson()));

  static String _checksum(String value) =>
      sha256.convert(utf8.encode(value)).toString();

  static bool _isChecksum(String value) =>
      RegExp(r'^[a-f0-9]{64}$').hasMatch(value);
}
