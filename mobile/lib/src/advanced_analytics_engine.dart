import 'dart:convert';
import 'dart:math' as math;

import 'models/fitness_models.dart';

class WeeklyMuscleHistory {
  const WeeklyMuscleHistory({
    required this.weekStart,
    required this.setsByMuscle,
  });

  final DateTime weekStart;
  final Map<String, int> setsByMuscle;
}

class PerformancePoint {
  const PerformancePoint({
    required this.date,
    required this.estimatedOneRepMax,
    required this.bestWeight,
    required this.bestReps,
    required this.bestHoldSeconds,
  });

  final DateTime date;
  final double estimatedOneRepMax;
  final double bestWeight;
  final int bestReps;
  final int bestHoldSeconds;
}

class StrengthStandard {
  const StrengthStandard({
    required this.exercise,
    required this.ratio,
    required this.level,
    required this.nextLevel,
    required this.nextTargetKilograms,
  });

  final String exercise;
  final double ratio;
  final String level;
  final String nextLevel;
  final double nextTargetKilograms;
}

class PersonalRecordEvent {
  const PersonalRecordEvent({
    required this.date,
    required this.exercise,
    required this.value,
    required this.kind,
  });

  final DateTime date;
  final String exercise;
  final String value;
  final String kind;
}

class ConsistencyStreaks {
  const ConsistencyStreaks({
    required this.currentDaily,
    required this.bestDaily,
    required this.currentWeekly,
    required this.bestWeekly,
  });

  final int currentDaily;
  final int bestDaily;
  final int currentWeekly;
  final int bestWeekly;
}

class WorkloadRatio {
  const WorkloadRatio({
    required this.acute,
    required this.chronicWeeklyAverage,
    required this.ratio,
    required this.label,
  });

  final double acute;
  final double chronicWeeklyAverage;
  final double ratio;
  final String label;
}

class AdvancedAnalyticsEngine {
  const AdvancedAnalyticsEngine._();

  static const muscles = [
    'Στήθος',
    'Πλάτη',
    'Ώμοι',
    'Πόδια',
    'Οπίσθια αλυσίδα',
    'Κορμός',
  ];

  static List<WeeklyMuscleHistory> muscleVolumeHistory({
    required List<WorkoutLog> logs,
    required DateTime now,
    int weeks = 8,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final currentWeek = today.subtract(Duration(days: today.weekday - 1));
    return [
      for (var offset = weeks - 1; offset >= 0; offset--)
        _muscleWeek(currentWeek.subtract(Duration(days: offset * 7)), logs),
    ];
  }

  static List<PerformancePoint> performanceTimeline(
    String exercise,
    List<WorkoutLog> logs,
  ) {
    final grouped = <DateTime, List<ExerciseSetLog>>{};
    for (final log in logs) {
      final date = DateTime(
        log.completedAt.year,
        log.completedAt.month,
        log.completedAt.day,
      );
      final sets = log.sets.where((set) => set.exerciseName == exercise);
      if (sets.isNotEmpty) grouped.putIfAbsent(date, () => []).addAll(sets);
    }
    final points = [
      for (final entry in grouped.entries)
        _performancePoint(entry.key, entry.value),
    ]..sort((left, right) => left.date.compareTo(right.date));
    return points;
  }

  static StrengthStandard strengthStandard({
    required String exercise,
    required List<WorkoutLog> logs,
    required double bodyweightKilograms,
  }) {
    final points = performanceTimeline(exercise, logs);
    final best = points.fold<double>(
      0,
      (value, point) => math.max(value, point.estimatedOneRepMax),
    );
    final ratio = bodyweightKilograms <= 0 ? 0.0 : best / bodyweightKilograms;
    final thresholds = _strengthThresholds(exercise);
    var level = 'Starter';
    var nextLevel = 'Novice';
    var nextRatio = thresholds[0];
    const labels = ['Novice', 'Intermediate', 'Advanced', 'Elite'];
    for (var index = 0; index < thresholds.length; index++) {
      if (ratio >= thresholds[index]) {
        level = labels[index];
        if (index == thresholds.length - 1) {
          nextLevel = 'Elite+';
          nextRatio = thresholds.last * 1.1;
        } else {
          nextLevel = labels[index + 1];
          nextRatio = thresholds[index + 1];
        }
      }
    }
    return StrengthStandard(
      exercise: exercise,
      ratio: ratio,
      level: level,
      nextLevel: nextLevel,
      nextTargetKilograms: nextRatio * bodyweightKilograms,
    );
  }

  static List<PersonalRecordEvent> personalRecordTimeline(
    List<WorkoutLog> logs,
  ) {
    final sorted = [...logs]
      ..sort((left, right) => left.completedAt.compareTo(right.completedAt));
    final bestE1rm = <String, double>{};
    final bestHold = <String, int>{};
    final events = <PersonalRecordEvent>[];
    for (final log in sorted) {
      for (final set in log.sets) {
        if (set.weightKilograms > 0 && set.reps > 0) {
          final estimate = set.weightKilograms * (1 + set.reps / 30);
          if (estimate > (bestE1rm[set.exerciseName] ?? 0) + .25) {
            bestE1rm[set.exerciseName] = estimate;
            events.add(
              PersonalRecordEvent(
                date: log.completedAt,
                exercise: set.exerciseName,
                value: '${estimate.toStringAsFixed(1)} kg e1RM',
                kind: 'STRENGTH PR',
              ),
            );
          }
        }
        if (set.holdSeconds > (bestHold[set.exerciseName] ?? 0)) {
          bestHold[set.exerciseName] = set.holdSeconds;
          events.add(
            PersonalRecordEvent(
              date: log.completedAt,
              exercise: set.exerciseName,
              value: '${set.holdSeconds}″ hold',
              kind: 'HOLD PR',
            ),
          );
        }
      }
    }
    return events.reversed.take(30).toList();
  }

  static Set<DateTime> consistencyCalendar(List<WorkoutLog> logs) => {
    for (final log in logs)
      DateTime(
        log.completedAt.year,
        log.completedAt.month,
        log.completedAt.day,
      ),
  };

  static ConsistencyStreaks streaks({
    required List<WorkoutLog> logs,
    required DateTime now,
  }) {
    final dates = consistencyCalendar(logs).toList()..sort();
    var bestDaily = 0;
    var runningDaily = 0;
    DateTime? previous;
    for (final date in dates) {
      runningDaily = previous != null && date.difference(previous).inDays == 1
          ? runningDaily + 1
          : 1;
      bestDaily = math.max(bestDaily, runningDaily);
      previous = date;
    }
    var cursor = DateTime(now.year, now.month, now.day);
    if (!dates.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var currentDaily = 0;
    while (dates.contains(cursor)) {
      currentDaily++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    final weekKeys = <int>{for (final date in dates) _weekKey(date)};
    final sortedWeeks = weekKeys.toList()..sort();
    var bestWeekly = 0;
    var runningWeekly = 0;
    int? priorWeek;
    for (final week in sortedWeeks) {
      runningWeekly = priorWeek != null && week - priorWeek == 7
          ? runningWeekly + 1
          : 1;
      bestWeekly = math.max(bestWeekly, runningWeekly);
      priorWeek = week;
    }
    var weekCursor = _weekStart(DateTime(now.year, now.month, now.day));
    if (!weekKeys.contains(_weekKey(weekCursor))) {
      weekCursor = weekCursor.subtract(const Duration(days: 7));
    }
    var currentWeekly = 0;
    while (weekKeys.contains(_weekKey(weekCursor))) {
      currentWeekly++;
      weekCursor = weekCursor.subtract(const Duration(days: 7));
    }
    return ConsistencyStreaks(
      currentDaily: currentDaily,
      bestDaily: bestDaily,
      currentWeekly: currentWeekly,
      bestWeekly: bestWeekly,
    );
  }

  static List<int> sessionDurationTrend(
    List<WorkoutLog> logs, {
    int limit = 12,
  }) {
    final sorted = [...logs]
      ..sort((left, right) => right.completedAt.compareTo(left.completedAt));
    return sorted
        .take(limit)
        .map((log) => log.minutes)
        .toList()
        .reversed
        .toList();
  }

  static WorkloadRatio workloadRatio({
    required List<WorkoutLog> logs,
    required DateTime now,
  }) {
    double loadBetween(DateTime start, DateTime end) => logs
        .where(
          (log) =>
              !log.completedAt.isBefore(start) && log.completedAt.isBefore(end),
        )
        .fold<double>(0, (sum, log) => sum + _sessionLoad(log));
    final acuteStart = now.subtract(const Duration(days: 7));
    final chronicStart = now.subtract(const Duration(days: 28));
    final acute = loadBetween(acuteStart, now.add(const Duration(seconds: 1)));
    final chronic = loadBetween(
      chronicStart,
      now.add(const Duration(seconds: 1)),
    );
    final weeklyAverage = chronic / 4;
    final ratio = weeklyAverage <= 0 ? 0.0 : acute / weeklyAverage;
    final label = ratio == 0
        ? 'Χρειάζονται περισσότερες προπονήσεις'
        : ratio < .8
        ? 'Χαμηλότερο από το συνηθισμένο φορτίο'
        : ratio <= 1.3
        ? 'Ισορροπημένη ζώνη φορτίου'
        : 'Απότομη αύξηση — σκέψου recovery ή deload';
    return WorkloadRatio(
      acute: acute,
      chronicWeeklyAverage: weeklyAverage,
      ratio: ratio,
      label: label,
    );
  }

  static String exportCsv({
    required List<WorkoutLog> logs,
    required List<WeightEntry> weights,
  }) {
    final rows = <String>[
      'type,date,name,minutes,sets,session_rpe,pain_severity,value',
      for (final log in logs)
        [
          'workout',
          log.completedAt.toIso8601String(),
          _csv(log.templateName),
          '${log.minutes}',
          '${log.sets.length}',
          '${log.sessionRpe}',
          '${log.painSeverity}',
          _sessionLoad(log).toStringAsFixed(1),
        ].join(','),
      for (final weight in weights)
        [
          'bodyweight',
          weight.recordedAt.toIso8601String(),
          'Body weight',
          '',
          '',
          '',
          '',
          weight.kilograms.toStringAsFixed(1),
        ].join(','),
    ];
    return rows.join('\n');
  }

  static String exportJson({
    required List<WorkoutLog> logs,
    required List<WeightEntry> weights,
    required DateTime generatedAt,
  }) => const JsonEncoder.withIndent('  ').convert({
    'report': 'Phoenix Advanced Analytics',
    'generatedAt': generatedAt.toIso8601String(),
    'workouts': logs.map((log) => log.toJson()).toList(),
    'weights': weights.map((weight) => weight.toJson()).toList(),
    'prTimeline': personalRecordTimeline(logs)
        .map(
          (event) => {
            'date': event.date.toIso8601String(),
            'exercise': event.exercise,
            'value': event.value,
            'kind': event.kind,
          },
        )
        .toList(),
  });

  static WeeklyMuscleHistory _muscleWeek(
    DateTime start,
    List<WorkoutLog> logs,
  ) {
    final end = start.add(const Duration(days: 7));
    final totals = {for (final muscle in muscles) muscle: 0};
    for (final log in logs.where(
      (log) =>
          !log.completedAt.isBefore(start) && log.completedAt.isBefore(end),
    )) {
      for (final set in log.sets) {
        for (final muscle in _musclesFor(set.exerciseName)) {
          totals[muscle] = (totals[muscle] ?? 0) + 1;
        }
      }
    }
    return WeeklyMuscleHistory(weekStart: start, setsByMuscle: totals);
  }

  static PerformancePoint _performancePoint(
    DateTime date,
    List<ExerciseSetLog> sets,
  ) => PerformancePoint(
    date: date,
    estimatedOneRepMax: sets.fold<double>(
      0,
      (best, set) => math.max(
        best,
        set.weightKilograms > 0 && set.reps > 0
            ? set.weightKilograms * (1 + set.reps / 30)
            : 0,
      ),
    ),
    bestWeight: sets.fold<double>(
      0,
      (best, set) => math.max(best, set.weightKilograms),
    ),
    bestReps: sets.fold<int>(0, (best, set) => math.max(best, set.reps)),
    bestHoldSeconds: sets.fold<int>(
      0,
      (best, set) => math.max(best, set.holdSeconds),
    ),
  );

  static List<double> _strengthThresholds(String exercise) {
    final name = exercise.toLowerCase();
    if (name.contains('squat') || name.contains('άρσ')) {
      return const [.6, 1.0, 1.5, 2.0];
    }
    if (name.contains('πιέσ') || name.contains('press')) {
      return const [.4, .7, 1.0, 1.35];
    }
    return const [.3, .55, .85, 1.15];
  }

  static Iterable<String> _musclesFor(String exercise) {
    final name = exercise.toLowerCase();
    final result = <String>{};
    if (name.contains('πιέσ') ||
        name.contains('push-up') ||
        name.contains('κάμψ')) {
      result.addAll(['Στήθος', 'Ώμοι']);
    }
    if (name.contains('κωπη') ||
        name.contains('έλξ') ||
        name.contains('pull')) {
      result.add('Πλάτη');
    }
    if (name.contains('squat') ||
        name.contains('step') ||
        name.contains('split') ||
        name.contains('sled')) {
      result.add('Πόδια');
    }
    if (name.contains('ρουμαν') ||
        name.contains('hinge') ||
        name.contains('deadlift')) {
      result.add('Οπίσθια αλυσίδα');
    }
    if (name.contains('hold') ||
        name.contains('plank') ||
        name.contains('carry')) {
      result.add('Κορμός');
    }
    return result.isEmpty ? const ['Κορμός'] : result;
  }

  static double _sessionLoad(WorkoutLog log) {
    final setLoad = log.sets.fold<double>(
      0,
      (sum, set) =>
          sum +
          (set.volume > 0 ? set.volume : (set.reps + set.holdSeconds / 5) * 5),
    );
    return setLoad * (log.sessionRpe > 0 ? log.sessionRpe / 7 : 1);
  }

  static DateTime _weekStart(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  static int _weekKey(DateTime date) =>
      _weekStart(date).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

  static String _csv(String value) => '"${value.replaceAll('"', '""')}"';
}
