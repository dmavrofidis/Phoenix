import 'dart:convert';
import 'dart:math' as math;

import 'models/fitness_models.dart';

class RouteImportSummary {
  const RouteImportSummary({
    required this.points,
    required this.distanceKilometers,
    required this.elevationGainMeters,
  });

  final int points;
  final double distanceKilometers;
  final double elevationGainMeters;
}

class IncrementalBackup {
  const IncrementalBackup({
    required this.baseFingerprint,
    required this.changedKeys,
    required this.payload,
  });

  final String baseFingerprint;
  final List<String> changedKeys;
  final Map<String, Object?> payload;

  String encode() => jsonEncode({
    'format': 'PHX-INCREMENTAL',
    'version': 1,
    'baseFingerprint': baseFingerprint,
    'changedKeys': changedKeys,
    'payload': payload,
  });
}

class SelectiveRestorePreview {
  const SelectiveRestorePreview({
    required this.availableSections,
    required this.conflicts,
    required this.valid,
  });

  final List<String> availableSections;
  final List<String> conflicts;
  final bool valid;
}

class StructuredImportExportEngine {
  const StructuredImportExportEngine._();

  static List<WorkoutLog> parseWorkoutCsv(
    String source, {
    String mapping = 'generic',
  }) {
    final rows = _csv(source);
    if (rows.length < 2) {
      throw const FormatException('Workout CSV has no data rows.');
    }
    final aliases = switch (mapping) {
      'strong' => const {
        'date': ['date'],
        'workout': ['workout name', 'workout'],
        'exercise': ['exercise name', 'exercise'],
        'reps': ['reps'],
        'weight': ['weight', 'weight (kg)'],
        'rir': ['rir'],
      },
      'hevy' => const {
        'date': ['start_time', 'date'],
        'workout': ['title', 'workout_title'],
        'exercise': ['exercise_title', 'exercise'],
        'reps': ['reps'],
        'weight': ['weight_kg', 'weight'],
        'rir': ['rpe', 'rir'],
      },
      _ => const {
        'date': ['date', 'completedat'],
        'workout': ['workout', 'template'],
        'exercise': ['exercise'],
        'reps': ['reps'],
        'weight': ['weight', 'kg'],
        'rir': ['rir'],
      },
    };
    final headers = rows.first.map(_header).toList();
    int column(String key, {bool required = true}) {
      final accepted = aliases[key]!.map(_header).toSet();
      final index = headers.indexWhere(accepted.contains);
      if (index < 0 && required) {
        throw FormatException('Workout CSV is missing $key.');
      }
      return index;
    }

    final dateColumn = column('date');
    final workoutColumn = column('workout');
    final exerciseColumn = column('exercise');
    final repsColumn = column('reps');
    final weightColumn = column('weight');
    final rirColumn = column('rir', required: false);
    final groups = <String, List<ExerciseSetLog>>{};
    final dates = <String, DateTime>{};
    final names = <String, String>{};
    for (final row in rows.skip(1)) {
      if (row.every((item) => item.trim().isEmpty)) continue;
      try {
        final date = DateTime.parse(row[dateColumn]).toLocal();
        final workout = row[workoutColumn].trim();
        final exercise = row[exerciseColumn].trim();
        final reps = int.parse(row[repsColumn].trim());
        final weight = double.parse(
          row[weightColumn].trim().replaceAll(',', '.'),
        );
        final rawEffort = rirColumn < 0 || rirColumn >= row.length
            ? 2
            : int.tryParse(row[rirColumn].trim()) ?? 2;
        final rir = mapping == 'hevy'
            ? (10 - rawEffort).clamp(0, 5)
            : rawEffort.clamp(0, 5);
        if (workout.isEmpty ||
            exercise.isEmpty ||
            reps < 0 ||
            reps > 1000 ||
            weight < 0 ||
            weight > 2000) {
          throw const FormatException();
        }
        final key = '${date.toIso8601String()}|$workout';
        groups
            .putIfAbsent(key, () => [])
            .add(
              ExerciseSetLog(
                exerciseName: exercise,
                reps: reps,
                weightKilograms: weight,
                rir: rir,
                holdSeconds: 0,
                loggedAt: date,
              ),
            );
        dates[key] = date;
        names[key] = workout;
      } on Object {
        throw const FormatException('Workout CSV contains an invalid row.');
      }
    }
    if (groups.isEmpty) {
      throw const FormatException('Workout CSV has no valid sets.');
    }
    return [
      for (final entry in groups.entries)
        WorkoutLog(
          templateName: names[entry.key]!,
          completedAt: dates[entry.key]!,
          minutes: 0,
          sets: entry.value,
        ),
    ]..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  static List<MealEntry> parseNutritionCsv(String source) {
    final rows = _csv(source);
    if (rows.length < 2) {
      throw const FormatException('Nutrition CSV has no data.');
    }
    final headers = rows.first.map(_header).toList();
    int requiredColumn(List<String> names) {
      final index = headers.indexWhere(names.map(_header).toSet().contains);
      if (index < 0) {
        throw FormatException('Nutrition CSV is missing ${names.first}.');
      }
      return index;
    }

    final date = requiredColumn(const ['date', 'loggedAt']);
    final name = requiredColumn(const ['name', 'meal']);
    final calories = requiredColumn(const ['calories', 'kcal']);
    final protein = requiredColumn(const ['protein', 'proteinGrams']);
    final carbs = requiredColumn(const ['carbs', 'carbohydrateGrams']);
    final fat = requiredColumn(const ['fat', 'fatGrams']);
    final results = <MealEntry>[];
    for (final row in rows.skip(1)) {
      if (row.every((item) => item.trim().isEmpty)) continue;
      try {
        final item = MealEntry(
          name: row[name].trim(),
          calories: int.parse(row[calories]),
          proteinGrams: double.parse(row[protein].replaceAll(',', '.')),
          carbohydrateGrams: double.parse(row[carbs].replaceAll(',', '.')),
          fatGrams: double.parse(row[fat].replaceAll(',', '.')),
          loggedAt: DateTime.parse(row[date]).toLocal(),
        );
        if (item.name.isEmpty || item.calories < 0 || item.calories > 10000) {
          throw const FormatException();
        }
        results.add(item);
      } on Object {
        throw const FormatException('Nutrition CSV contains an invalid row.');
      }
    }
    return results;
  }

  static RouteImportSummary parseGpx(String source) {
    final pattern = RegExp(
      r'<trkpt[^>]*lat="([+-]?[0-9.]+)"[^>]*lon="([+-]?[0-9.]+)"[^>]*>([\s\S]*?)<\/trkpt>',
      caseSensitive: false,
    );
    final elevation = RegExp(
      r'<ele>([+-]?[0-9.]+)<\/ele>',
      caseSensitive: false,
    );
    final points = <(double, double, double?)>[];
    for (final match in pattern.allMatches(source)) {
      final latitude = double.parse(match.group(1)!);
      final longitude = double.parse(match.group(2)!);
      final elevationMatch = elevation.firstMatch(match.group(3)!);
      final meters = elevationMatch == null
          ? null
          : double.tryParse(elevationMatch.group(1)!);
      if (latitude.abs() > 90 || longitude.abs() > 180) {
        throw const FormatException('GPX contains invalid coordinates.');
      }
      points.add((latitude, longitude, meters));
    }
    if (points.length < 2 || points.length > 200000) {
      throw const FormatException('GPX needs 2–200000 track points.');
    }
    var distance = 0.0;
    var gain = 0.0;
    for (var index = 1; index < points.length; index++) {
      distance += _haversine(points[index - 1], points[index]);
      final previous = points[index - 1].$3;
      final current = points[index].$3;
      if (previous != null && current != null && current > previous) {
        gain += current - previous;
      }
    }
    return RouteImportSummary(
      points: points.length,
      distanceKilometers: distance,
      elevationGainMeters: gain,
    );
  }

  static String calendarIcs({
    required List<WorkoutReminder> reminders,
    required DateTime from,
    int weeks = 4,
  }) {
    final lines = <String>[
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//Phoenix//Local Training//EN',
    ];
    for (final reminder in reminders.where((item) => item.enabled)) {
      for (var week = 0; week < weeks.clamp(1, 12); week++) {
        final delta = (reminder.weekday - from.weekday + 7) % 7 + week * 7;
        final day = DateTime(
          from.year,
          from.month,
          from.day + delta,
          reminder.minutesSinceMidnight ~/ 60,
          reminder.minutesSinceMidnight % 60,
        );
        final stamp = _icsDate(day);
        lines.addAll([
          'BEGIN:VEVENT',
          'UID:phoenix-${reminder.id}-$week@local',
          'DTSTART:$stamp',
          'DTEND:${_icsDate(day.add(const Duration(hours: 1)))}',
          'SUMMARY:Phoenix workout',
          'DESCRIPTION:Generated locally. Review the plan before training.',
          'END:VEVENT',
        ]);
      }
    }
    lines.add('END:VCALENDAR');
    return lines.join('\r\n');
  }

  static Map<String, String> jsonSchemaDocumentation(FitnessData data) => {
    for (final entry in data.toJson().entries)
      entry.key: switch (entry.value) {
        List<Object?> _ => 'array',
        Map<Object?, Object?> _ => 'object',
        String _ => 'string',
        num _ => 'number',
        bool _ => 'boolean',
        null => 'nullable',
        _ => 'unknown',
      },
  };

  static IncrementalBackup incremental({
    required FitnessData baseline,
    required FitnessData current,
  }) {
    final base = baseline.toJson();
    final now = current.toJson();
    final changed =
        now.keys
            .where((key) => jsonEncode(now[key]) != jsonEncode(base[key]))
            .toList()
          ..sort();
    final fingerprint = base64Url
        .encode(utf8.encode(jsonEncode(base)))
        .substring(0, 16);
    return IncrementalBackup(
      baseFingerprint: fingerprint,
      changedKeys: changed,
      payload: {for (final key in changed) key: now[key]},
    );
  }

  static SelectiveRestorePreview previewSelectiveRestore({
    required String backup,
    required FitnessData current,
  }) {
    try {
      final envelope = jsonDecode(backup) as Map<String, dynamic>;
      final incoming = envelope['data'] is Map
          ? Map<String, dynamic>.from(envelope['data'] as Map)
          : envelope;
      final sections =
          incoming.keys.where(current.toJson().containsKey).toList()..sort();
      final conflicts = <String>[];
      if (incoming['profile'] != null && current.profile != null) {
        conflicts.add('Profile data already exists and would be replaced.');
      }
      if (incoming['templates'] is List && current.templates.isNotEmpty) {
        conflicts.add('Workout templates require explicit merge approval.');
      }
      return SelectiveRestorePreview(
        availableSections: sections,
        conflicts: conflicts,
        valid: sections.isNotEmpty,
      );
    } on Object {
      return const SelectiveRestorePreview(
        availableSections: [],
        conflicts: ['Backup is not valid JSON.'],
        valid: false,
      );
    }
  }

  static FitnessData applySelectiveRestore({
    required String backup,
    required FitnessData current,
    required Set<String> sections,
  }) {
    final envelope = jsonDecode(backup) as Map<String, dynamic>;
    final incoming = envelope['data'] is Map
        ? Map<String, dynamic>.from(envelope['data'] as Map)
        : envelope;
    final merged = Map<String, Object?>.from(current.toJson());
    for (final section in sections) {
      if (incoming.containsKey(section) && merged.containsKey(section)) {
        merged[section] = incoming[section];
      }
    }
    return FitnessData.fromJson(Map<String, dynamic>.from(merged));
  }

  static List<List<String>> _csv(String source) {
    final rows = const LineSplitter().convert(source.trim());
    return rows.map(_csvRow).toList();
  }

  static List<String> _csvRow(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var quoted = false;
    for (var index = 0; index < line.length; index++) {
      final char = line[index];
      if (char == '"') {
        if (quoted && index + 1 < line.length && line[index + 1] == '"') {
          buffer.write('"');
          index++;
        } else {
          quoted = !quoted;
        }
      } else if (char == ',' && !quoted) {
        values.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    if (quoted) throw const FormatException('CSV contains an unclosed quote.');
    values.add(buffer.toString());
    return values;
  }

  static String _header(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_()]'), '');

  static double _haversine(
    (double, double, double?) a,
    (double, double, double?) b,
  ) {
    const earth = 6371.0;
    final lat1 = a.$1 * math.pi / 180;
    final lat2 = b.$1 * math.pi / 180;
    final dLat = lat2 - lat1;
    final dLon = (b.$2 - a.$2) * math.pi / 180;
    final value =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return earth * 2 * math.atan2(math.sqrt(value), math.sqrt(1 - value));
  }

  static String _icsDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}${value.month.toString().padLeft(2, '0')}${value.day.toString().padLeft(2, '0')}T${value.hour.toString().padLeft(2, '0')}${value.minute.toString().padLeft(2, '0')}00';
}
