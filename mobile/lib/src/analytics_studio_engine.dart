import 'dart:math' as math;

import 'models/fitness_models.dart';

class StudioMetric {
  const StudioMetric({
    required this.id,
    required this.label,
    required this.value,
    required this.unit,
    required this.detail,
  });

  final String id;
  final String label;
  final double value;
  final String unit;
  final String detail;
}

class DateRangeComparison {
  const DateRangeComparison({
    required this.metric,
    required this.current,
    required this.previous,
    required this.changePercent,
    required this.label,
  });

  final String metric;
  final double current;
  final double previous;
  final double changePercent;
  final String label;
}

class TrainingLoadDistribution {
  const TrainingLoadDistribution({
    required this.low,
    required this.moderate,
    required this.high,
    required this.totalSets,
  });

  final int low;
  final int moderate;
  final int high;
  final int totalSets;
}

class TrainingMonotony {
  const TrainingMonotony({
    required this.weeklyLoad,
    required this.monotony,
    required this.strain,
    required this.label,
  });

  final double weeklyLoad;
  final double monotony;
  final double strain;
  final String label;
}

class SetRepHeatCell {
  const SetRepHeatCell({
    required this.repBand,
    required this.loadBand,
    required this.count,
  });

  final String repBand;
  final String loadBand;
  final int count;
}

class AdherenceFunnel {
  const AdherenceFunnel({
    required this.planned,
    required this.completed,
    required this.loggedSets,
    required this.qualityReviewed,
  });

  final int planned;
  final int completed;
  final int loggedSets;
  final int qualityReviewed;

  double get completionRate => planned == 0 ? 0 : completed / planned;
}

class GoalForecast {
  const GoalForecast({
    required this.exercise,
    required this.current,
    required this.target,
    required this.weeklyChange,
    required this.estimatedWeeks,
    required this.status,
    required this.assumption,
  });

  final String exercise;
  final double current;
  final double target;
  final double weeklyChange;
  final int estimatedWeeks;
  final String status;
  final String assumption;
}

class AnalyticsStudioEngine {
  const AnalyticsStudioEngine._();

  static const supportedMetrics = {
    'sessions',
    'volume',
    'readiness',
    'bodyweight',
    'duration',
    'set-count',
  };

  static List<StudioMetric> customDashboard({
    required FitnessData data,
    required List<String> selectedMetrics,
    required DateTime now,
  }) {
    final cutoff = now.subtract(const Duration(days: 7));
    final logs = data.logs.where((item) => item.completedAt.isAfter(cutoff));
    final logList = logs.toList();
    final recovery = data.recoveryChecks
        .where((item) => item.recordedAt.isAfter(cutoff))
        .toList();
    final latestWeight = data.weights.isEmpty
        ? data.profile?.weightKilograms ?? 0
        : ([...data.weights]..sort(
                (left, right) => right.recordedAt.compareTo(left.recordedAt),
              ))
              .first
              .kilograms;
    final metrics = <String, StudioMetric>{
      'sessions': StudioMetric(
        id: 'sessions',
        label: 'SESSIONS',
        value: logList.length.toDouble(),
        unit: '',
        detail: 'LAST 7 DAYS',
      ),
      'volume': StudioMetric(
        id: 'volume',
        label: 'VOLUME',
        value: logList.fold<double>(
          0,
          (sum, item) => sum + _sessionVolume(item),
        ),
        unit: 'kg',
        detail: 'TONNAGE',
      ),
      'readiness': StudioMetric(
        id: 'readiness',
        label: 'READINESS',
        value: _average(recovery.map(_readiness)),
        unit: '/100',
        detail: '${recovery.length} CHECK-IN(S)',
      ),
      'bodyweight': StudioMetric(
        id: 'bodyweight',
        label: 'BODYWEIGHT',
        value: latestWeight,
        unit: 'kg',
        detail: 'LATEST',
      ),
      'duration': StudioMetric(
        id: 'duration',
        label: 'DURATION',
        value: _average(logList.map((item) => item.minutes)),
        unit: 'min',
        detail: 'SESSION AVG',
      ),
      'set-count': StudioMetric(
        id: 'set-count',
        label: 'SETS',
        value: logList
            .fold<int>(0, (sum, item) => sum + item.sets.length)
            .toDouble(),
        unit: '',
        detail: 'LOGGED',
      ),
    };
    return selectedMetrics
        .where(supportedMetrics.contains)
        .map((id) => metrics[id]!)
        .toList();
  }

  static DateRangeComparison compareRanges({
    required List<WorkoutLog> logs,
    required DateTime currentStart,
    required DateTime currentEnd,
    required int previousDays,
    String metric = 'load',
  }) {
    final previousStart = currentStart.subtract(Duration(days: previousDays));
    double value(DateTime start, DateTime end) {
      final selected = logs.where(
        (item) =>
            !item.completedAt.isBefore(start) && item.completedAt.isBefore(end),
      );
      return switch (metric) {
        'sessions' => selected.length.toDouble(),
        'sets' =>
          selected
              .fold<int>(0, (sum, item) => sum + item.sets.length)
              .toDouble(),
        'volume' => selected.fold<double>(
          0,
          (sum, item) => sum + _sessionVolume(item),
        ),
        _ => selected.fold<double>(0, (sum, item) => sum + _sessionLoad(item)),
      };
    }

    final current = value(currentStart, currentEnd);
    final previous = value(previousStart, currentStart);
    final change =
        (previous == 0
                ? (current == 0 ? 0 : 100)
                : (current - previous) / previous * 100)
            .toDouble();
    return DateRangeComparison(
      metric: metric,
      current: current,
      previous: previous,
      changePercent: change,
      label: change > 5
          ? 'RISING'
          : change < -5
          ? 'FALLING'
          : 'STABLE',
    );
  }

  static List<double> movingAverage(List<double> values, int window) {
    if (window < 1 || window > 30) {
      throw const FormatException('Moving-average window must be 1–30.');
    }
    return [
      for (var index = 0; index < values.length; index++)
        _average(values.sublist(math.max(0, index - window + 1), index + 1)),
    ];
  }

  static TrainingMonotony monotony({
    required List<WorkoutLog> logs,
    required DateTime now,
  }) {
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 6));
    final daily = List<double>.filled(7, 0);
    for (final log in logs) {
      final index = DateTime(
        log.completedAt.year,
        log.completedAt.month,
        log.completedAt.day,
      ).difference(start).inDays;
      if (index >= 0 && index < 7) daily[index] += _sessionLoad(log);
    }
    final weekly = daily.reduce((left, right) => left + right);
    final mean = weekly / 7;
    final variance =
        daily
            .map((value) => math.pow(value - mean, 2).toDouble())
            .reduce((left, right) => left + right) /
        7;
    final deviation = math.sqrt(variance);
    final monotony =
        (deviation == 0 ? (weekly == 0 ? 0 : 10) : mean / deviation).toDouble();
    final strain = weekly * monotony;
    return TrainingMonotony(
      weeklyLoad: weekly,
      monotony: monotony,
      strain: strain,
      label: monotony > 2
          ? 'HIGH MONOTONY'
          : monotony >= 1.3
          ? 'MODERATE MONOTONY'
          : weekly == 0
          ? 'NO LOAD'
          : 'VARIED LOAD',
    );
  }

  static TrainingLoadDistribution volumeIntensityDistribution(
    List<WorkoutLog> logs,
  ) {
    final bestByExercise = <String, double>{};
    for (final log in logs) {
      for (final set in log.sets) {
        if (set.weightKilograms <= 0) continue;
        bestByExercise[set.exerciseName] = math.max(
          bestByExercise[set.exerciseName] ?? 0,
          set.weightKilograms,
        );
      }
    }
    var low = 0;
    var moderate = 0;
    var high = 0;
    for (final log in logs) {
      for (final set in log.sets) {
        final best = bestByExercise[set.exerciseName] ?? 0;
        if (best == 0 || set.weightKilograms == 0) continue;
        final ratio = set.weightKilograms / best;
        if (ratio < .65) {
          low++;
        } else if (ratio < .85) {
          moderate++;
        } else {
          high++;
        }
      }
    }
    return TrainingLoadDistribution(
      low: low,
      moderate: moderate,
      high: high,
      totalSets: low + moderate + high,
    );
  }

  static List<SetRepHeatCell> setRepHeatmap(List<WorkoutLog> logs) {
    const repBands = ['1–5', '6–10', '11–15', '16+'];
    const loadBands = ['BODYWEIGHT', 'LIGHT', 'MODERATE', 'HEAVY'];
    final counts = <String, int>{};
    for (final log in logs) {
      for (final set in log.sets) {
        final rep = set.reps <= 5
            ? '1–5'
            : set.reps <= 10
            ? '6–10'
            : set.reps <= 15
            ? '11–15'
            : '16+';
        final load = set.weightKilograms == 0
            ? 'BODYWEIGHT'
            : set.weightKilograms < 30
            ? 'LIGHT'
            : set.weightKilograms < 80
            ? 'MODERATE'
            : 'HEAVY';
        final key = '$rep:$load';
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }
    return [
      for (final rep in repBands)
        for (final load in loadBands)
          SetRepHeatCell(
            repBand: rep,
            loadBand: load,
            count: counts['$rep:$load'] ?? 0,
          ),
    ];
  }

  static AdherenceFunnel adherenceFunnel({
    required int plannedSessions,
    required List<WorkoutLog> logs,
    required DateTime start,
    required DateTime end,
  }) {
    final selected = logs
        .where(
          (item) =>
              !item.completedAt.isBefore(start) &&
              item.completedAt.isBefore(end),
        )
        .toList();
    return AdherenceFunnel(
      planned: math.max(plannedSessions, selected.length),
      completed: selected.length,
      loggedSets: selected.where((item) => item.sets.isNotEmpty).length,
      qualityReviewed: selected
          .where((item) => item.sessionRpe > 0 || item.notes.isNotEmpty)
          .length,
    );
  }

  static GoalForecast forecast({
    required String exercise,
    required List<WorkoutLog> logs,
    required double target,
  }) {
    final points = <_ForecastPoint>[];
    final ordered = [...logs]
      ..sort((left, right) => left.completedAt.compareTo(right.completedAt));
    for (final log in ordered) {
      final values = log.sets
          .where(
            (set) =>
                set.exerciseName == exercise &&
                set.weightKilograms > 0 &&
                set.reps > 0,
          )
          .map((set) => set.weightKilograms * (1 + set.reps / 30))
          .toList();
      if (values.isNotEmpty) {
        points.add(_ForecastPoint(log.completedAt, values.reduce(math.max)));
      }
    }
    if (points.isEmpty) {
      return GoalForecast(
        exercise: exercise,
        current: 0,
        target: target,
        weeklyChange: 0,
        estimatedWeeks: 0,
        status: 'NO DATA',
        assumption: 'Log at least two measurable sessions.',
      );
    }
    final current = points.last.value;
    final first = points.first;
    final weeks = math.max(
      1.0,
      points.last.date.difference(first.date).inDays / 7,
    );
    final weeklyChange = (current - first.value) / weeks;
    final remaining = target - current;
    final eta = remaining <= 0
        ? 0
        : weeklyChange <= 0
        ? 0
        : (remaining / weeklyChange).ceil().clamp(1, 104);
    return GoalForecast(
      exercise: exercise,
      current: current,
      target: target,
      weeklyChange: weeklyChange,
      estimatedWeeks: eta,
      status: remaining <= 0
          ? 'TARGET REACHED'
          : weeklyChange > 0
          ? 'ON TRAJECTORY'
          : 'NO POSITIVE TREND',
      assumption:
          'Linear estimate from logged e1RM only; plateaus and deloads will change the timeline.',
    );
  }

  static List<AnalyticsAnnotation> annotationsForRange({
    required List<AnalyticsAnnotation> annotations,
    required DateTime start,
    required DateTime end,
  }) =>
      annotations
          .where(
            (item) => !item.date.isBefore(start) && item.date.isBefore(end),
          )
          .toList()
        ..sort((left, right) => left.date.compareTo(right.date));

  static double _sessionVolume(WorkoutLog log) => log.sets.fold<double>(
    0,
    (sum, set) => sum + set.weightKilograms * set.reps,
  );

  static double _sessionLoad(WorkoutLog log) {
    final base = _sessionVolume(log) > 0
        ? _sessionVolume(log) / 100
        : log.minutes.toDouble();
    return base * (log.sessionRpe > 0 ? log.sessionRpe : 5);
  }

  static double _readiness(RecoveryCheckIn item) =>
      ((item.sleepHours / 8 * 100).clamp(0, 100) * .35) +
      (item.energy / 5 * 100 * .25) +
      ((6 - item.soreness) / 5 * 100 * .2) +
      ((6 - item.stress) / 5 * 100 * .2);

  static double _average(Iterable<num> values) {
    final list = values.toList();
    if (list.isEmpty) return 0;
    return list.fold<double>(0, (sum, item) => sum + item) / list.length;
  }
}

class _ForecastPoint {
  const _ForecastPoint(this.date, this.value);

  final DateTime date;
  final double value;
}
