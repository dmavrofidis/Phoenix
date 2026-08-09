import 'models/fitness_models.dart';

class StrengthLiftMetric {
  const StrengthLiftMetric({
    required this.lift,
    required this.estimatedOneRepMax,
    required this.trainingMax,
    required this.bestWeight,
    required this.bestReps,
    required this.recordedAt,
    required this.source,
  });

  final String lift;
  final double estimatedOneRepMax;
  final double trainingMax;
  final double bestWeight;
  final int bestReps;
  final DateTime? recordedAt;
  final String source;

  bool get hasData => estimatedOneRepMax > 0;
}

class RepMaxRow {
  const RepMaxRow({
    required this.reps,
    required this.weight,
    required this.percentage,
  });

  final int reps;
  final double weight;
  final double percentage;
}

class PlateLoadResult {
  const PlateLoadResult({
    required this.targetWeight,
    required this.loadedWeight,
    required this.barWeight,
    required this.platesPerSide,
  });

  final double targetWeight;
  final double loadedWeight;
  final double barWeight;
  final List<double> platesPerSide;

  double get difference => loadedWeight - targetWeight;
  bool get exact => difference.abs() < .01;
}

class StrengthWarmupSet {
  const StrengthWarmupSet({
    required this.label,
    required this.weight,
    required this.reps,
    required this.plateLoad,
  });

  final String label;
  final double weight;
  final int reps;
  final PlateLoadResult plateLoad;
}

class TopBackoffProtocol {
  const TopBackoffProtocol({
    required this.topWeight,
    required this.topReps,
    required this.topRpe,
    required this.backoffWeight,
    required this.backoffSets,
    required this.backoffReps,
    required this.restSeconds,
  });

  final double topWeight;
  final int topReps;
  final double topRpe;
  final double backoffWeight;
  final int backoffSets;
  final int backoffReps;
  final int restSeconds;
}

enum HeavySingleStatus { allowed, controlled, blocked }

class HeavySingleDecision {
  const HeavySingleDecision({
    required this.status,
    required this.loadCapPercentage,
    required this.title,
    required this.reason,
  });

  final HeavySingleStatus status;
  final double loadCapPercentage;
  final String title;
  final String reason;
}

class VelocityStopDecision {
  const VelocityStopDecision({
    required this.lossPercentage,
    required this.thresholdPercentage,
    required this.stopSet,
    required this.cue,
  });

  final double lossPercentage;
  final double thresholdPercentage;
  final bool stopSet;
  final String cue;
}

class StrengthBlockWeek {
  const StrengthBlockWeek({
    required this.week,
    required this.phase,
    required this.intensityPercentage,
    required this.sets,
    required this.reps,
    required this.targetRpe,
  });

  final int week;
  final String phase;
  final double intensityPercentage;
  final int sets;
  final int reps;
  final double targetRpe;
}

class MeetAttemptPlan {
  const MeetAttemptPlan({
    required this.opener,
    required this.second,
    required this.third,
    required this.readinessAdjustment,
    required this.notes,
  });

  final double opener;
  final double second;
  final double third;
  final double readinessAdjustment;
  final List<String> notes;
}

class StrengthLabEngine {
  const StrengthLabEngine._();

  static const bigLifts = <String>[
    'Back squat',
    'Bench press',
    'Deadlift',
    'Overhead press',
  ];

  static List<StrengthLiftMetric> dashboard(FitnessData data) {
    final candidates = <String, List<_LiftCandidate>>{
      for (final lift in bigLifts) lift: <_LiftCandidate>[],
    };
    for (final test in data.strengthTests) {
      final lift = canonicalLift(test.exerciseName);
      if (lift == null) continue;
      candidates[lift]!.add(
        _LiftCandidate(
          estimatedOneRepMax: test.estimatedOneRepMax,
          weight: test.weightKilograms,
          reps: test.reps,
          recordedAt: test.recordedAt,
          source: 'STRENGTH TEST',
        ),
      );
    }
    for (final log in data.logs) {
      for (final set in log.sets) {
        final lift = canonicalLift(set.exerciseName);
        if (lift == null || set.weightKilograms <= 0 || set.reps <= 0) {
          continue;
        }
        candidates[lift]!.add(
          _LiftCandidate(
            estimatedOneRepMax: estimateOneRepMax(
              set.weightKilograms,
              set.reps,
            ),
            weight: set.weightKilograms,
            reps: set.reps,
            recordedAt: set.loggedAt,
            source: 'WORKOUT LOG',
          ),
        );
      }
    }
    return [
      for (final lift in bigLifts)
        _metricFor(lift, candidates[lift]!, data.strengthTrainingMaxes[lift]),
    ];
  }

  static StrengthLiftMetric _metricFor(
    String lift,
    List<_LiftCandidate> candidates,
    double? savedTrainingMax,
  ) {
    candidates.sort(
      (left, right) =>
          right.estimatedOneRepMax.compareTo(left.estimatedOneRepMax),
    );
    final best = candidates.firstOrNull;
    final estimated = best?.estimatedOneRepMax ?? 0;
    return StrengthLiftMetric(
      lift: lift,
      estimatedOneRepMax: estimated,
      trainingMax: savedTrainingMax ?? roundToPlate(estimated * .9),
      bestWeight: best?.weight ?? 0,
      bestReps: best?.reps ?? 0,
      recordedAt: best?.recordedAt,
      source: best?.source ?? 'NO DATA',
    );
  }

  static String? canonicalLift(String value) {
    final normalized = _normalize(value);
    if (normalized.contains('squat') &&
        !normalized.contains('split') &&
        !normalized.contains('goblet') &&
        !normalized.contains('single')) {
      return 'Back squat';
    }
    if (normalized.contains('bench') ||
        normalized.contains('πιεσεισ παγκου') ||
        normalized.contains('πιεσεις παγκου')) {
      return 'Bench press';
    }
    if (normalized.contains('deadlift') ||
        normalized.contains('αρση θανατου') ||
        normalized.contains('αρσεις θανατου')) {
      return 'Deadlift';
    }
    if (normalized.contains('overhead press') ||
        normalized.contains('military press') ||
        normalized.contains('πιεσεισ ωμων') ||
        normalized.contains('πιεσεις ωμων')) {
      return 'Overhead press';
    }
    return null;
  }

  static double estimateOneRepMax(double weight, int reps) {
    if (weight <= 0 || reps < 1) return 0;
    final safeReps = reps.clamp(1, 20);
    final epley = weight * (1 + safeReps / 30);
    final brzycki = weight * 36 / (37 - safeReps);
    return (epley + brzycki) / 2;
  }

  static List<RepMaxRow> repMaxTable(double oneRepMax, {int maxReps = 12}) {
    if (oneRepMax <= 0) return const [];
    return [
      for (var reps = 1; reps <= maxReps.clamp(1, 20); reps++)
        RepMaxRow(
          reps: reps,
          weight: roundToPlate(oneRepMax / (1 + reps / 30)),
          percentage: 100 / (1 + reps / 30),
        ),
    ];
  }

  static PlateLoadResult loadBar({
    required double targetWeight,
    double barWeight = 20,
    List<double> availablePlates = const [25, 20, 15, 10, 5, 2.5, 1.25],
  }) {
    if (targetWeight < barWeight || barWeight <= 0) {
      return PlateLoadResult(
        targetWeight: targetWeight,
        loadedWeight: barWeight,
        barWeight: barWeight,
        platesPerSide: const [],
      );
    }
    var perSide = (targetWeight - barWeight) / 2;
    final selected = <double>[];
    final plates = availablePlates.where((item) => item > 0).toList()
      ..sort((left, right) => right.compareTo(left));
    for (final plate in plates) {
      while (perSide + .001 >= plate) {
        selected.add(plate);
        perSide -= plate;
      }
    }
    final loaded =
        barWeight + selected.fold<double>(0, (sum, item) => sum + item) * 2;
    return PlateLoadResult(
      targetWeight: targetWeight,
      loadedWeight: loaded,
      barWeight: barWeight,
      platesPerSide: selected,
    );
  }

  static List<StrengthWarmupSet> warmupPlan({
    required double workWeight,
    double barWeight = 20,
  }) {
    if (workWeight <= 0) return const [];
    const stages = <(String, double, int)>[
      ('EMPTY BAR', 0, 10),
      ('RAMP 1', .4, 6),
      ('RAMP 2', .55, 5),
      ('RAMP 3', .7, 3),
      ('PRIMER', .82, 2),
      ('FINAL WARM-UP', .9, 1),
    ];
    final result = <StrengthWarmupSet>[];
    var previous = -1.0;
    for (final stage in stages) {
      final target = stage.$2 == 0
          ? barWeight
          : roundToPlate((workWeight * stage.$2).clamp(barWeight, workWeight));
      final load = loadBar(targetWeight: target, barWeight: barWeight);
      if ((load.loadedWeight - previous).abs() < .01) continue;
      result.add(
        StrengthWarmupSet(
          label: stage.$1,
          weight: load.loadedWeight,
          reps: stage.$3,
          plateLoad: load,
        ),
      );
      previous = load.loadedWeight;
    }
    return result;
  }

  static TopBackoffProtocol topSetPlusBackoff({
    required double trainingMax,
    int topReps = 3,
    double topRpe = 8,
    int backoffSets = 3,
  }) {
    if (trainingMax <= 0) {
      return const TopBackoffProtocol(
        topWeight: 0,
        topReps: 3,
        topRpe: 8,
        backoffWeight: 0,
        backoffSets: 3,
        backoffReps: 5,
        restSeconds: 180,
      );
    }
    final repAdjustment = (topReps.clamp(1, 8) - 1) * .025;
    final rpeAdjustment = (8 - topRpe.clamp(6, 9.5)) * .02;
    final topPercentage = (.94 - repAdjustment - rpeAdjustment).clamp(.68, .95);
    final topWeight = roundToPlate(trainingMax * topPercentage);
    return TopBackoffProtocol(
      topWeight: topWeight,
      topReps: topReps,
      topRpe: topRpe,
      backoffWeight: roundToPlate(topWeight * .9),
      backoffSets: backoffSets.clamp(1, 6),
      backoffReps: (topReps + 2).clamp(2, 10),
      restSeconds: topReps <= 3 ? 240 : 180,
    );
  }

  static HeavySingleDecision heavySingleGate({
    required int readinessScore,
    int painSeverity = 0,
    int heavyExposuresLastSevenDays = 0,
  }) {
    if (painSeverity >= 2) {
      return const HeavySingleDecision(
        status: HeavySingleStatus.blocked,
        loadCapPercentage: 0,
        title: 'HEAVY SINGLE BLOCKED',
        reason:
            'Pain takes priority. Use a pain-free variation or recovery day.',
      );
    }
    if (readinessScore < 60 || heavyExposuresLastSevenDays >= 2) {
      return const HeavySingleDecision(
        status: HeavySingleStatus.blocked,
        loadCapPercentage: .8,
        title: 'HEAVY SINGLE BLOCKED',
        reason:
            'Readiness or recent heavy exposure is outside the safe gate. Cap technique work at 80%.',
      );
    }
    if (readinessScore < 76) {
      return const HeavySingleDecision(
        status: HeavySingleStatus.controlled,
        loadCapPercentage: .88,
        title: 'CONTROLLED SINGLE ONLY',
        reason: 'Use one crisp single, no grind, with an 88% training-max cap.',
      );
    }
    return const HeavySingleDecision(
      status: HeavySingleStatus.allowed,
      loadCapPercentage: .93,
      title: 'HEAVY SINGLE ALLOWED',
      reason: 'Readiness supports one technical single. Stop before a grind.',
    );
  }

  static VelocityStopDecision velocityLoss({
    required double fastestVelocity,
    required double currentVelocity,
    double thresholdPercentage = 20,
  }) {
    final safeFastest = fastestVelocity <= 0 ? .01 : fastestVelocity;
    final loss = ((safeFastest - currentVelocity) / safeFastest * 100)
        .clamp(0, 100)
        .toDouble();
    final stop = loss >= thresholdPercentage;
    return VelocityStopDecision(
      lossPercentage: loss,
      thresholdPercentage: thresholdPercentage,
      stopSet: stop,
      cue: stop
          ? 'STOP THE SET — velocity loss reached the quality limit.'
          : 'CONTINUE — rep speed remains inside the quality limit.',
    );
  }

  static List<StrengthBlockWeek> strengthBlock({String block = 'base'}) {
    final normalized = block.toLowerCase();
    if (normalized == 'peak') {
      return const [
        StrengthBlockWeek(
          week: 1,
          phase: 'PEAK',
          intensityPercentage: 85,
          sets: 4,
          reps: 3,
          targetRpe: 7.5,
        ),
        StrengthBlockWeek(
          week: 2,
          phase: 'PEAK',
          intensityPercentage: 88,
          sets: 4,
          reps: 2,
          targetRpe: 8,
        ),
        StrengthBlockWeek(
          week: 3,
          phase: 'REALIZATION',
          intensityPercentage: 92,
          sets: 3,
          reps: 1,
          targetRpe: 8,
        ),
        StrengthBlockWeek(
          week: 4,
          phase: 'TAPER',
          intensityPercentage: 70,
          sets: 2,
          reps: 2,
          targetRpe: 6,
        ),
      ];
    }
    if (normalized == 'intensification') {
      return const [
        StrengthBlockWeek(
          week: 1,
          phase: 'INTENSIFY',
          intensityPercentage: 77.5,
          sets: 5,
          reps: 4,
          targetRpe: 7,
        ),
        StrengthBlockWeek(
          week: 2,
          phase: 'INTENSIFY',
          intensityPercentage: 80,
          sets: 5,
          reps: 3,
          targetRpe: 7.5,
        ),
        StrengthBlockWeek(
          week: 3,
          phase: 'INTENSIFY',
          intensityPercentage: 82.5,
          sets: 4,
          reps: 3,
          targetRpe: 8,
        ),
        StrengthBlockWeek(
          week: 4,
          phase: 'DELOAD',
          intensityPercentage: 65,
          sets: 3,
          reps: 3,
          targetRpe: 6,
        ),
      ];
    }
    return const [
      StrengthBlockWeek(
        week: 1,
        phase: 'BASE',
        intensityPercentage: 67.5,
        sets: 4,
        reps: 6,
        targetRpe: 6.5,
      ),
      StrengthBlockWeek(
        week: 2,
        phase: 'BASE',
        intensityPercentage: 70,
        sets: 5,
        reps: 5,
        targetRpe: 7,
      ),
      StrengthBlockWeek(
        week: 3,
        phase: 'BASE',
        intensityPercentage: 72.5,
        sets: 5,
        reps: 5,
        targetRpe: 7.5,
      ),
      StrengthBlockWeek(
        week: 4,
        phase: 'DELOAD',
        intensityPercentage: 60,
        sets: 3,
        reps: 5,
        targetRpe: 6,
      ),
    ];
  }

  static MeetAttemptPlan meetDayAttempts({
    required double estimatedOneRepMax,
    required int readinessScore,
    String experienceLevel = 'Intermediate',
  }) {
    if (estimatedOneRepMax <= 0) {
      return const MeetAttemptPlan(
        opener: 0,
        second: 0,
        third: 0,
        readinessAdjustment: 0,
        notes: ['Add a submax strength test before planning attempts.'],
      );
    }
    final readinessAdjustment = readinessScore >= 80
        ? .01
        : readinessScore < 65
        ? -.035
        : 0.0;
    final advanced =
        _normalize(experienceLevel).contains('advanced') ||
        _normalize(experienceLevel).contains('προχωρη');
    final opener = roundToPlate(
      estimatedOneRepMax * (.88 + readinessAdjustment / 2),
    );
    final second = roundToPlate(
      estimatedOneRepMax * (.95 + readinessAdjustment),
    );
    final thirdCap = advanced ? 1.015 : 1.005;
    final third = roundToPlate(
      estimatedOneRepMax * (thirdCap + readinessAdjustment),
    );
    return MeetAttemptPlan(
      opener: opener,
      second: second.clamp(opener + 2.5, estimatedOneRepMax * 1.01),
      third: third.clamp(second + 2.5, estimatedOneRepMax * 1.03),
      readinessAdjustment: readinessAdjustment,
      notes: [
        'Opener: a weight you can complete even on an average day.',
        'Second: secure the result before chasing a PR.',
        readinessScore < 65
            ? 'Low readiness: the third attempt is deliberately conservative.'
            : 'Third: adjust down if the second attempt slows or technique shifts.',
      ],
    );
  }

  static double roundToPlate(double value, {double increment = 2.5}) {
    if (value <= 0 || increment <= 0) return 0;
    return (value / increment).round() * increment;
  }

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

class _LiftCandidate {
  const _LiftCandidate({
    required this.estimatedOneRepMax,
    required this.weight,
    required this.reps,
    required this.recordedAt,
    required this.source,
  });

  final double estimatedOneRepMax;
  final double weight;
  final int reps;
  final DateTime recordedAt;
  final String source;
}
