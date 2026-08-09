import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'models/fitness_models.dart';

class CollaborationPackage {
  const CollaborationPackage({
    required this.kind,
    required this.createdAt,
    required this.expiresAt,
    required this.readOnly,
    required this.redacted,
    required this.payload,
    required this.checksum,
  });

  final String kind;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool readOnly;
  final bool redacted;
  final Map<String, Object?> payload;
  final String checksum;

  bool isExpired(DateTime now) => !expiresAt.isAfter(now);

  Map<String, Object?> toJson({bool includeChecksum = true}) => {
    'version': 1,
    'kind': kind,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'expiresAt': expiresAt.toUtc().toIso8601String(),
    'readOnly': readOnly,
    'redacted': redacted,
    'payload': payload,
    if (includeChecksum) 'checksum': checksum,
  };
}

class CollaborationPreview {
  const CollaborationPreview({
    required this.package,
    required this.conflicts,
    required this.safeToApprove,
  });

  final CollaborationPackage package;
  final List<String> conflicts;
  final bool safeToApprove;
}

class LocalCollaborationEngine {
  const LocalCollaborationEngine._();

  static CollaborationPackage coachView({
    required FitnessData data,
    required DateTime now,
    int expiresInDays = 7,
    bool redacted = true,
  }) {
    final payload = <String, Object?>{
      'profile': data.profile?.toJson(),
      'templates': data.templates.map((item) => item.toJson()).toList(),
      'recentLogs': data.logs.take(30).map((item) => item.toJson()).toList(),
      'recentRecovery': data.recoveryChecks
          .take(14)
          .map((item) => item.toJson())
          .toList(),
      'trainingMaxes': data.strengthTrainingMaxes,
      if (!redacted)
        'nutrition': data.meals.take(30).map((item) => item.toJson()).toList(),
    };
    return _signed(
      kind: 'coach-view',
      now: now,
      expiresInDays: expiresInDays,
      redacted: redacted,
      payload: payload,
    );
  }

  static CollaborationPackage sessionPlan({
    required WorkoutTemplate template,
    required DateTime now,
    int expiresInDays = 14,
  }) => _signed(
    kind: 'session-plan',
    now: now,
    expiresInDays: expiresInDays,
    redacted: true,
    payload: {'template': template.toJson()},
  );

  static CollaborationPackage challenge({
    required String title,
    required String metric,
    required double target,
    required DateTime now,
    int expiresInDays = 30,
  }) {
    if (title.trim().length < 3 || target <= 0 || target > 1000000) {
      throw const FormatException('Challenge title or target is not safe.');
    }
    return _signed(
      kind: 'challenge',
      now: now,
      expiresInDays: expiresInDays,
      redacted: true,
      payload: {'title': title.trim(), 'metric': metric, 'target': target},
    );
  }

  static CollaborationPackage _signed({
    required String kind,
    required DateTime now,
    required int expiresInDays,
    required bool redacted,
    required Map<String, Object?> payload,
  }) {
    final boundedDays = expiresInDays.clamp(1, 90);
    final unsigned = <String, Object?>{
      'version': 1,
      'kind': kind,
      'createdAt': now.toUtc().toIso8601String(),
      'expiresAt': now
          .toUtc()
          .add(Duration(days: boundedDays))
          .toIso8601String(),
      'readOnly': true,
      'redacted': redacted,
      'payload': payload,
    };
    final checksum = sha256
        .convert(utf8.encode(jsonEncode(unsigned)))
        .toString();
    return CollaborationPackage(
      kind: kind,
      createdAt: now,
      expiresAt: now.add(Duration(days: boundedDays)),
      readOnly: true,
      redacted: redacted,
      payload: payload,
      checksum: checksum,
    );
  }

  static String encode(CollaborationPackage package) {
    final encoded = base64Url
        .encode(utf8.encode(jsonEncode(package.toJson())))
        .replaceAll('=', '');
    return 'PHXC1:$encoded';
  }

  static CollaborationPackage decode(String code, {required DateTime now}) {
    final trimmed = code.trim();
    if (!trimmed.startsWith('PHXC1:')) {
      throw const FormatException('Unknown Phoenix collaboration code.');
    }
    try {
      final value = trimmed.substring(6);
      final normalized = value.padRight(
        value.length + ((4 - value.length % 4) % 4),
        '=',
      );
      final json =
          jsonDecode(utf8.decode(base64Url.decode(normalized)))
              as Map<String, dynamic>;
      final checksum = json.remove('checksum') as String;
      final actual = sha256.convert(utf8.encode(jsonEncode(json))).toString();
      if (checksum != actual) {
        throw const FormatException('Collaboration checksum failed.');
      }
      final package = CollaborationPackage(
        kind: json['kind'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        expiresAt: DateTime.parse(json['expiresAt'] as String).toLocal(),
        readOnly: json['readOnly'] as bool? ?? true,
        redacted: json['redacted'] as bool? ?? true,
        payload: Map<String, Object?>.from(json['payload'] as Map),
        checksum: checksum,
      );
      if (package.isExpired(now)) {
        throw const FormatException('This collaboration code has expired.');
      }
      return package;
    } on FormatException {
      rethrow;
    } on Object {
      throw const FormatException('Collaboration code is malformed.');
    }
  }

  static CollaborationPreview previewImport({
    required String code,
    required FitnessData current,
    required DateTime now,
  }) {
    final package = decode(code, now: now);
    final conflicts = <String>[];
    if (package.kind == 'session-plan') {
      final template = WorkoutTemplate.fromJson(
        Map<String, dynamic>.from(package.payload['template'] as Map),
      );
      if (current.templates.any((item) => item.id == template.id)) {
        conflicts.add('Template ID ${template.id} already exists.');
      }
      if (template.exercises.isEmpty) {
        conflicts.add('The imported plan has no exercises.');
      }
    }
    return CollaborationPreview(
      package: package,
      conflicts: conflicts,
      safeToApprove: package.readOnly && conflicts.isEmpty,
    );
  }
}
