import 'models/fitness_models.dart';

class HeartRateZone {
  const HeartRateZone({
    required this.zone,
    required this.label,
    required this.minimumBpm,
    required this.maximumBpm,
    required this.purpose,
  });

  final int zone;
  final String label;
  final int minimumBpm;
  final int maximumBpm;
  final String purpose;
}

class ConditioningSessionPlan {
  const ConditioningSessionPlan({
    required this.name,
    required this.modality,
    required this.totalMinutes,
    required this.warmupMinutes,
    required this.cooldownMinutes,
    required this.rounds,
    required this.workSeconds,
    required this.restSeconds,
    required this.targetZone,
    required this.targetRpe,
    required this.stopRule,
  });

  final String name;
  final String modality;
  final int totalMinutes;
  final int warmupMinutes;
  final int cooldownMinutes;
  final int rounds;
  final int workSeconds;
  final int restSeconds;
  final int targetZone;
  final int targetRpe;
  final String stopRule;
}

class WorkRestPreset {
  const WorkRestPreset({
    required this.id,
    required this.label,
    required this.workSeconds,
    required this.restSeconds,
    required this.rounds,
    required this.purpose,
  });

  final String id;
  final String label;
  final int workSeconds;
  final int restSeconds;
  final int rounds;
  final String purpose;

  String get ratio => '$workSeconds:$restSeconds';
}

class ConditioningLoadSummary {
  const ConditioningLoadSummary({
    required this.totalMinutes,
    required this.totalLoad,
    required this.sessions,
    required this.highIntensitySessions,
    required this.monotony,
  });

  final int totalMinutes;
  final int totalLoad;
  final int sessions;
  final int highIntensitySessions;
  final double monotony;
}

class InterferenceAdvice {
  const InterferenceAdvice({
    required this.level,
    required this.score,
    required this.title,
    required this.actions,
  });

  final String level;
  final int score;
  final String title;
  final List<String> actions;
}

class AerobicProgressionWeek {
  const AerobicProgressionWeek({
    required this.week,
    required this.sessions,
    required this.minutesPerSession,
    required this.deload,
  });

  final int week;
  final int sessions;
  final int minutesPerSession;
  final bool deload;
}

class BenchmarkAssessment {
  const BenchmarkAssessment({
    required this.test,
    required this.score,
    required this.label,
    required this.estimatedVo2Max,
    required this.cue,
  });

  final String test;
  final double score;
  final String label;
  final double estimatedVo2Max;
  final String cue;
}

class ConditioningEngine {
  const ConditioningEngine._();

  static List<HeartRateZone> heartRateZones({
    required int age,
    int restingHeartRate = 60,
    int? measuredMaximumHeartRate,
  }) {
    final maxHr = measuredMaximumHeartRate ?? (208 - .7 * age).round();
    final resting = restingHeartRate.clamp(35, maxHr - 30);
    final reserve = maxHr - resting;
    const ranges = <(double, double, String, String)>[
      (.50, .60, 'RECOVERY', 'Easy recovery and warm-up'),
      (.60, .70, 'AEROBIC BASE', 'Sustainable Zone 2 development'),
      (.70, .80, 'TEMPO', 'Steady aerobic power'),
      (.80, .90, 'THRESHOLD', 'Controlled hard intervals'),
      (.90, 1.00, 'VO2 / PEAK', 'Short high-intensity work'),
    ];
    return [
      for (var index = 0; index < ranges.length; index++)
        HeartRateZone(
          zone: index + 1,
          label: ranges[index].$3,
          minimumBpm: (resting + reserve * ranges[index].$1).round(),
          maximumBpm: (resting + reserve * ranges[index].$2).round(),
          purpose: ranges[index].$4,
        ),
    ];
  }

  static ConditioningSessionPlan zone2Session({
    required String modality,
    int minutes = 30,
    String experienceLevel = 'Beginner',
  }) {
    final total = minutes.clamp(20, 90);
    final warmup = total >= 40 ? 8 : 5;
    final cooldown = total >= 40 ? 7 : 5;
    return ConditioningSessionPlan(
      name: 'ZONE 2 BASE',
      modality: modality,
      totalMinutes: total,
      warmupMinutes: warmup,
      cooldownMinutes: cooldown,
      rounds: 1,
      workSeconds: (total - warmup - cooldown) * 60,
      restSeconds: 0,
      targetZone: 2,
      targetRpe: 4,
      stopRule:
          'Keep the talk test: full sentences remain possible. Reduce pace before adding time.',
    );
  }

  static ConditioningSessionPlan intervalSession({
    required String modality,
    String goal = 'vo2',
    String experienceLevel = 'Beginner',
  }) {
    final advanced =
        _normalize(experienceLevel).contains('advanced') ||
        _normalize(experienceLevel).contains('προχωρη');
    final preset = workRestPresets().firstWhere(
      (item) => item.id == goal,
      orElse: () => workRestPresets().first,
    );
    final rounds = advanced ? preset.rounds + 2 : preset.rounds;
    final workMinutes =
        ((preset.workSeconds + preset.restSeconds) * rounds / 60).ceil();
    return ConditioningSessionPlan(
      name: '${preset.label} INTERVALS',
      modality: modality,
      totalMinutes: workMinutes + 12,
      warmupMinutes: 8,
      cooldownMinutes: 4,
      rounds: rounds,
      workSeconds: preset.workSeconds,
      restSeconds: preset.restSeconds,
      targetZone: goal == 'threshold' ? 4 : 5,
      targetRpe: goal == 'sprint' ? 9 : 8,
      stopRule:
          'Stop when output drops twice, technique changes or symptoms appear.',
    );
  }

  static List<WorkRestPreset> workRestPresets() => const [
    WorkRestPreset(
      id: 'vo2',
      label: 'VO2',
      workSeconds: 120,
      restSeconds: 120,
      rounds: 5,
      purpose: 'Repeatable high aerobic power',
    ),
    WorkRestPreset(
      id: 'threshold',
      label: 'THRESHOLD',
      workSeconds: 240,
      restSeconds: 120,
      rounds: 4,
      purpose: 'Sustainable hard aerobic work',
    ),
    WorkRestPreset(
      id: 'sprint',
      label: 'SPRINT',
      workSeconds: 15,
      restSeconds: 75,
      rounds: 6,
      purpose: 'Full-quality power with complete recovery',
    ),
    WorkRestPreset(
      id: 'tempo',
      label: 'TEMPO',
      workSeconds: 60,
      restSeconds: 30,
      rounds: 10,
      purpose: 'Moderate repeatable conditioning',
    ),
  ];

  static List<String> modalitySelector({
    required UserProfile? profile,
    String goal = 'aerobic',
  }) {
    final equipment = _normalize(profile?.equipment ?? '');
    final limitations = _normalize(profile?.limitations ?? '');
    final options = <String>[];
    if (!limitations.contains('knee') && !limitations.contains('γονατ')) {
      options.add('Brisk walk');
      if (equipment.contains('treadmill') ||
          equipment.contains('διαδρομ') ||
          equipment.contains('full gym') ||
          equipment.contains('πληρες γυμναστηριο')) {
        options.add('Incline treadmill');
      }
    }
    if (equipment.contains('bike') ||
        equipment.contains('ποδηλα') ||
        equipment.isEmpty) {
      options.add('Stationary bike');
    }
    if (equipment.contains('row') ||
        equipment.contains('κωπηλα') ||
        equipment.isEmpty) {
      options.add('Row ergometer');
    }
    if (equipment.contains('sled')) options.add('Sled push');
    options.add('Low-impact circuit');
    if (goal == 'sprint') {
      options.removeWhere(
        (item) => const {'Brisk walk', 'Low-impact circuit'}.contains(item),
      );
    }
    return options.toSet().toList();
  }

  static ConditioningLoadSummary weeklyLoad(
    List<CardioSessionLog> logs, {
    DateTime? now,
  }) {
    final anchor = now ?? DateTime.now();
    final start = DateTime(
      anchor.year,
      anchor.month,
      anchor.day,
    ).subtract(Duration(days: anchor.weekday - 1));
    final selected = logs
        .where((item) => !item.recordedAt.isBefore(start))
        .toList();
    final loads = selected
        .map((item) => item.durationMinutes * item.rpe)
        .toList();
    final totalLoad = loads.fold<int>(0, (sum, item) => sum + item);
    final mean = loads.isEmpty ? 0.0 : totalLoad / loads.length;
    final variance = loads.length < 2
        ? 0.0
        : loads
                  .map((item) => (item - mean) * (item - mean))
                  .reduce((left, right) => left + right) /
              loads.length;
    final deviation = variance <= 0 ? 0.0 : _sqrt(variance);
    return ConditioningLoadSummary(
      totalMinutes: selected.fold<int>(
        0,
        (sum, item) => sum + item.durationMinutes,
      ),
      totalLoad: totalLoad,
      sessions: selected.length,
      highIntensitySessions: selected.where((item) => item.rpe >= 8).length,
      monotony: deviation == 0 ? (loads.isEmpty ? 0 : 3) : mean / deviation,
    );
  }

  static InterferenceAdvice interferenceRisk({
    required int strengthDays,
    required ConditioningLoadSummary cardio,
    int hoursBetweenHardCardioAndLegs = 24,
  }) {
    var score = 0;
    if (strengthDays >= 4) score += 20;
    if (cardio.totalMinutes > 180) score += 25;
    if (cardio.highIntensitySessions >= 2) score += 30;
    if (hoursBetweenHardCardioAndLegs < 24) score += 30;
    if (cardio.monotony > 2) score += 15;
    final level = score >= 60
        ? 'HIGH'
        : score >= 30
        ? 'MODERATE'
        : 'LOW';
    return InterferenceAdvice(
      level: level,
      score: score.clamp(0, 100),
      title: '$level INTERFERENCE RISK',
      actions: [
        if (cardio.highIntensitySessions >= 2)
          'Keep no more than one hard conditioning session near heavy lower-body work.',
        if (hoursBetweenHardCardioAndLegs < 24)
          'Separate hard cardio and leg strength by at least 24 hours.',
        if (cardio.totalMinutes > 180)
          'Move additional conditioning volume to easy Zone 2.',
        if (score < 30)
          'Current conditioning load is compatible with the strength schedule.',
      ],
    );
  }

  static List<AerobicProgressionWeek> aerobicBaseProgression({
    int baselineMinutes = 30,
    int sessions = 2,
  }) {
    final base = baselineMinutes.clamp(20, 75);
    final frequency = sessions.clamp(2, 4);
    return [
      AerobicProgressionWeek(
        week: 1,
        sessions: frequency,
        minutesPerSession: base,
        deload: false,
      ),
      AerobicProgressionWeek(
        week: 2,
        sessions: frequency,
        minutesPerSession: (base * 1.08).round(),
        deload: false,
      ),
      AerobicProgressionWeek(
        week: 3,
        sessions: frequency,
        minutesPerSession: (base * 1.15).round(),
        deload: false,
      ),
      AerobicProgressionWeek(
        week: 4,
        sessions: frequency,
        minutesPerSession: (base * .75).round(),
        deload: true,
      ),
    ];
  }

  static BenchmarkAssessment benchmark({
    required String test,
    required double value,
    int age = 30,
  }) {
    switch (test) {
      case 'cooper-12':
        final vo2 = ((value - 504.9) / 44.73).clamp(5, 90).toDouble();
        return BenchmarkAssessment(
          test: '12-MINUTE COOPER',
          score: value,
          label: _vo2Label(vo2),
          estimatedVo2Max: vo2,
          cue:
              'Repeat on the same surface and similar conditions in 6–8 weeks.',
        );
      case 'row-2000':
        final score = (1200 - value).clamp(0, 900).toDouble();
        return BenchmarkAssessment(
          test: '2K ROW',
          score: score,
          label: value <= 480 ? 'DEVELOPED' : 'BUILDING',
          estimatedVo2Max: 0,
          cue: 'Use an even first 1500 m and a controlled final push.',
        );
      case 'bike-20':
        final wattsPerKg = value.clamp(.5, 7).toDouble();
        return BenchmarkAssessment(
          test: '20-MINUTE BIKE',
          score: wattsPerKg,
          label: wattsPerKg >= 3 ? 'DEVELOPED' : 'BUILDING',
          estimatedVo2Max: 0,
          cue: 'Record average power, cadence and RPE under repeatable setup.',
        );
      default:
        final recovery = value.clamp(0, 80).toDouble();
        return BenchmarkAssessment(
          test: '3-MINUTE STEP RECOVERY',
          score: recovery,
          label: recovery >= 30 ? 'DEVELOPED' : 'BUILDING',
          estimatedVo2Max: 0,
          cue:
              'Use the same step height and measure one-minute heart-rate drop.',
        );
    }
  }

  static String _vo2Label(double value) {
    if (value >= 50) return 'DEVELOPED';
    if (value >= 40) return 'SOLID';
    return 'BUILDING';
  }

  static double _sqrt(double value) {
    if (value <= 0) return 0;
    var estimate = value;
    for (var index = 0; index < 12; index++) {
      estimate = (estimate + value / estimate) / 2;
    }
    return estimate;
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
