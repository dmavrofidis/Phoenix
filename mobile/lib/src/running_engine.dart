import 'models/fitness_models.dart';

class RunningPace {
  const RunningPace({
    required this.distanceKilometers,
    required this.durationSeconds,
    required this.secondsPerKilometer,
    required this.kilometersPerHour,
  });

  final double distanceKilometers;
  final int durationSeconds;
  final double secondsPerKilometer;
  final double kilometersPerHour;

  String get formattedPace {
    final total = secondsPerKilometer.round();
    final minutes = total ~/ 60;
    final seconds = total % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')} /km';
  }
}

class RunWalkWeek {
  const RunWalkWeek({
    required this.week,
    required this.sessions,
    required this.runSeconds,
    required this.walkSeconds,
    required this.rounds,
    required this.totalMinutes,
    required this.deload,
  });

  final int week;
  final int sessions;
  final int runSeconds;
  final int walkSeconds;
  final int rounds;
  final int totalMinutes;
  final bool deload;
}

class FiveKPlanWeek {
  const FiveKPlanWeek({
    required this.week,
    required this.easyKilometers,
    required this.qualitySession,
    required this.longRunKilometers,
    required this.weeklyKilometers,
    required this.recoveryFocus,
  });

  final int week;
  final double easyKilometers;
  final String qualitySession;
  final double longRunKilometers;
  final double weeklyKilometers;
  final bool recoveryFocus;
}

class LongRunGuard {
  const LongRunGuard({
    required this.allowedKilometers,
    required this.requestedKilometers,
    required this.status,
    required this.reason,
  });

  final double allowedKilometers;
  final double requestedKilometers;
  final String status;
  final String reason;
}

class WeeklyMileageSummary {
  const WeeklyMileageSummary({
    required this.kilometers,
    required this.durationMinutes,
    required this.sessions,
    required this.longestRunKilometers,
    required this.elevationMeters,
    required this.averageCadence,
    required this.hardSessions,
  });

  final double kilometers;
  final int durationMinutes;
  final int sessions;
  final double longestRunKilometers;
  final int elevationMeters;
  final double averageCadence;
  final int hardSessions;
}

class RunningInjuryRisk {
  const RunningInjuryRisk({
    required this.level,
    required this.score,
    required this.mileageChangePercentage,
    required this.actions,
  });

  final String level;
  final int score;
  final double mileageChangePercentage;
  final List<String> actions;
}

class RacePrediction {
  const RacePrediction({
    required this.targetDistanceKilometers,
    required this.predictedSeconds,
    required this.pace,
    required this.confidence,
  });

  final double targetDistanceKilometers;
  final int predictedSeconds;
  final RunningPace pace;
  final String confidence;

  String get formattedTime {
    final hours = predictedSeconds ~/ 3600;
    final minutes = (predictedSeconds % 3600) ~/ 60;
    final seconds = predictedSeconds % 60;
    return hours > 0
        ? '$hours:${minutes.toString().padLeft(2, '0')}:'
              '${seconds.toString().padLeft(2, '0')}'
        : '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class RunningEngine {
  const RunningEngine._();

  static const surfaces = <String>[
    'Road',
    'Track',
    'Trail',
    'Treadmill',
    'Mixed',
  ];

  static RunningPace pace({
    required double distanceKilometers,
    required int durationSeconds,
  }) {
    if (distanceKilometers <= 0 || durationSeconds <= 0) {
      return const RunningPace(
        distanceKilometers: 0,
        durationSeconds: 0,
        secondsPerKilometer: 0,
        kilometersPerHour: 0,
      );
    }
    final secondsPerKm = durationSeconds / distanceKilometers;
    return RunningPace(
      distanceKilometers: distanceKilometers,
      durationSeconds: durationSeconds,
      secondsPerKilometer: secondsPerKm,
      kilometersPerHour: 3600 / secondsPerKm,
    );
  }

  static List<RunWalkWeek> runWalkProgression({
    String experienceLevel = 'Beginner',
  }) {
    final returning =
        _normalize(experienceLevel).contains('return') ||
        _normalize(experienceLevel).contains('επιστροφ');
    final startRun = returning ? 60 : 30;
    const ratios = <(int, int, int)>[
      (1, 2, 10),
      (1, 1, 12),
      (2, 1, 10),
      (3, 1, 8),
      (5, 1, 6),
      (8, 1, 4),
      (12, 1, 3),
      (20, 1, 1),
    ];
    return [
      for (var index = 0; index < ratios.length; index++)
        RunWalkWeek(
          week: index + 1,
          sessions: index == 3 || index == 7 ? 2 : 3,
          runSeconds: ratios[index].$1 * startRun,
          walkSeconds: ratios[index].$2 * 60,
          rounds: ratios[index].$3,
          totalMinutes:
              ((ratios[index].$1 * startRun + ratios[index].$2 * 60) *
                      ratios[index].$3 /
                      60)
                  .round(),
          deload: index == 3 || index == 7,
        ),
    ];
  }

  static List<FiveKPlanWeek> fiveKPlan({
    required double currentWeeklyKilometers,
    int daysPerWeek = 3,
  }) {
    final baseline = currentWeeklyKilometers.clamp(6, 35);
    final days = daysPerWeek.clamp(2, 5);
    final weeks = <FiveKPlanWeek>[];
    for (var week = 1; week <= 8; week++) {
      final recovery = week == 4 || week == 8;
      final multiplier = recovery
          ? (week == 8 ? .65 : .8)
          : 1 + (week - 1 - (week > 4 ? 1 : 0)) * .055;
      final total = _roundTenth(baseline * multiplier);
      final longRun = _roundTenth(total * (days <= 3 ? .38 : .32));
      weeks.add(
        FiveKPlanWeek(
          week: week,
          easyKilometers: _roundTenth(
            (total - longRun) / (days - 1).clamp(1, 4),
          ),
          qualitySession: recovery
              ? 'EASY STRIDES ONLY'
              : week <= 2
              ? '6 × 30s relaxed strides'
              : week <= 5
              ? '5 × 3 min at controlled 5K effort'
              : '3 × 1 km at target 5K pace',
          longRunKilometers: longRun,
          weeklyKilometers: total,
          recoveryFocus: recovery,
        ),
      );
    }
    return weeks;
  }

  static LongRunGuard longRunGuard({
    required double previousLongestKilometers,
    required double requestedKilometers,
    required double plannedWeeklyKilometers,
    int recentPainSeverity = 0,
  }) {
    final growthCap =
        (previousLongestKilometers <= 0
                ? requestedKilometers.clamp(2, 6)
                : previousLongestKilometers * 1.1)
            .toDouble();
    final weeklyCap = plannedWeeklyKilometers * .4;
    var allowed = [
      growthCap,
      weeklyCap,
    ].reduce((left, right) => left < right ? left : right);
    if (recentPainSeverity >= 2) allowed *= .75;
    allowed = _roundTenth(allowed.clamp(1, 50));
    final safe = requestedKilometers <= allowed + .01;
    return LongRunGuard(
      allowedKilometers: allowed,
      requestedKilometers: requestedKilometers,
      status: safe ? 'ALLOWED' : 'CAPPED',
      reason: safe
          ? 'The long run stays within progression and weekly-share guards.'
          : 'Cap the run at $allowed km; build consistency before distance.',
    );
  }

  static WeeklyMileageSummary weeklyMileage(
    List<RunningSessionLog> sessions, {
    DateTime? now,
    int weeksAgo = 0,
  }) {
    final anchor = now ?? DateTime.now();
    final thisMonday = DateTime(
      anchor.year,
      anchor.month,
      anchor.day,
    ).subtract(Duration(days: anchor.weekday - 1));
    final start = thisMonday.subtract(Duration(days: weeksAgo * 7));
    final end = start.add(const Duration(days: 7));
    final selected = sessions
        .where(
          (item) =>
              !item.recordedAt.isBefore(start) && item.recordedAt.isBefore(end),
        )
        .toList();
    final distance = selected.fold<double>(
      0,
      (sum, item) => sum + item.distanceKilometers,
    );
    final cadenceSamples = selected
        .where((item) => item.cadenceStepsPerMinute > 0)
        .toList();
    return WeeklyMileageSummary(
      kilometers: _roundTenth(distance),
      durationMinutes: selected.fold<int>(
        0,
        (sum, item) => sum + item.durationSeconds ~/ 60,
      ),
      sessions: selected.length,
      longestRunKilometers: selected.isEmpty
          ? 0
          : selected
                .map((item) => item.distanceKilometers)
                .reduce((left, right) => left > right ? left : right),
      elevationMeters: selected.fold<int>(
        0,
        (sum, item) => sum + item.elevationGainMeters,
      ),
      averageCadence: cadenceSamples.isEmpty
          ? 0
          : cadenceSamples.fold<int>(
                  0,
                  (sum, item) => sum + item.cadenceStepsPerMinute,
                ) /
                cadenceSamples.length,
      hardSessions: selected.where((item) => item.rpe >= 8).length,
    );
  }

  static double shoeMileage(
    RunningShoe shoe,
    List<RunningSessionLog> sessions,
  ) {
    return _roundTenth(
      sessions
          .where((item) => item.shoeId == shoe.id)
          .fold<double>(
            shoe.startingKilometers,
            (sum, item) => sum + item.distanceKilometers,
          ),
    );
  }

  static RunningInjuryRisk injuryRisk({
    required WeeklyMileageSummary currentWeek,
    required WeeklyMileageSummary previousWeek,
    int painSeverity = 0,
    int consecutiveRunDays = 0,
  }) {
    final change = previousWeek.kilometers <= 0
        ? (currentWeek.kilometers > 0 ? 100.0 : 0.0)
        : (currentWeek.kilometers - previousWeek.kilometers) /
              previousWeek.kilometers *
              100;
    var score = 0;
    if (change > 15) score += 30;
    if (change > 30) score += 20;
    if (currentWeek.hardSessions >= 2) score += 20;
    if (consecutiveRunDays >= 4) score += 15;
    if (painSeverity >= 2) score += 45;
    if (currentWeek.longestRunKilometers > currentWeek.kilometers * .45) {
      score += 15;
    }
    final level = score >= 60
        ? 'HIGH'
        : score >= 30
        ? 'MODERATE'
        : 'LOW';
    return RunningInjuryRisk(
      level: level,
      score: score.clamp(0, 100),
      mileageChangePercentage: change,
      actions: [
        if (change > 15)
          'Hold or reduce mileage until the weekly jump settles.',
        if (currentWeek.hardSessions >= 2)
          'Replace one hard run with conversational easy running.',
        if (consecutiveRunDays >= 4) 'Insert a non-running recovery day.',
        if (painSeverity >= 2)
          'Stop progression and use a pain-free alternative; seek qualified care if symptoms persist.',
        if (score < 30)
          'Current running load is stable; progress only one variable next week.',
      ],
    );
  }

  static RacePrediction predictRace({
    required double sourceDistanceKilometers,
    required int sourceSeconds,
    required double targetDistanceKilometers,
  }) {
    if (sourceDistanceKilometers <= 0 ||
        sourceSeconds <= 0 ||
        targetDistanceKilometers <= 0) {
      return const RacePrediction(
        targetDistanceKilometers: 0,
        predictedSeconds: 0,
        pace: RunningPace(
          distanceKilometers: 0,
          durationSeconds: 0,
          secondsPerKilometer: 0,
          kilometersPerHour: 0,
        ),
        confidence: 'NO DATA',
      );
    }
    final ratio = targetDistanceKilometers / sourceDistanceKilometers;
    final predicted = (sourceSeconds * _pow106(ratio)).round();
    return RacePrediction(
      targetDistanceKilometers: targetDistanceKilometers,
      predictedSeconds: predicted,
      pace: pace(
        distanceKilometers: targetDistanceKilometers,
        durationSeconds: predicted,
      ),
      confidence: ratio >= .5 && ratio <= 2 ? 'HIGHER' : 'ESTIMATE',
    );
  }

  static double _pow106(double value) {
    if (value <= 0) return 0;
    // Stable approximation for Riegel's exponent without adding dependencies.
    final sixthRootAdjustment = 1 + .06 * _naturalLogApprox(value);
    return value * sixthRootAdjustment.clamp(.75, 1.35);
  }

  static double _naturalLogApprox(double value) {
    var scaled = value;
    var shifts = 0;
    while (scaled > 1.5) {
      scaled /= 2;
      shifts++;
    }
    while (scaled < .75) {
      scaled *= 2;
      shifts--;
    }
    final x = (scaled - 1) / (scaled + 1);
    final x2 = x * x;
    final local = 2 * (x + x * x2 / 3 + x * x2 * x2 / 5);
    return local + shifts * .69314718056;
  }

  static double _roundTenth(num value) => (value.toDouble() * 10).round() / 10;

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[άα]'), 'α')
      .replaceAll(RegExp('[έε]'), 'ε')
      .replaceAll(RegExp('[ήη]'), 'η')
      .replaceAll(RegExp('[ίϊΐι]'), 'ι')
      .replaceAll(RegExp('[όο]'), 'ο')
      .replaceAll(RegExp('[ύϋΰυ]'), 'υ')
      .replaceAll(RegExp('[ώω]'), 'ω');
}
