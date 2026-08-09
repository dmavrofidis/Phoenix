import 'dart:math' as math;

import 'models/fitness_models.dart';

enum TrainingDecision { proceed, modify, recoveryOnly, stopAndSeekCare }

class SymptomAssessment {
  const SymptomAssessment({
    required this.decision,
    required this.loadMultiplier,
    required this.rangeMultiplier,
    required this.allowedPatterns,
    required this.blockedPatterns,
    required this.fallbacks,
    required this.returnStage,
    required this.flags,
    required this.careReminder,
  });

  final TrainingDecision decision;
  final double loadMultiplier;
  final double rangeMultiplier;
  final List<String> allowedPatterns;
  final List<String> blockedPatterns;
  final List<String> fallbacks;
  final int returnStage;
  final List<String> flags;
  final String careReminder;

  String exportNote({required String area, required int severity}) => [
    'Phoenix symptom handoff (user-entered, not a diagnosis)',
    'Area: $area · severity: $severity/10',
    'Decision: ${decision.name}',
    'Load: ${(loadMultiplier * 100).round()}% · range: ${(rangeMultiplier * 100).round()}%',
    if (blockedPatterns.isNotEmpty)
      'Avoided patterns: ${blockedPatterns.join(', ')}',
    if (fallbacks.isNotEmpty) 'Fallbacks: ${fallbacks.join(', ')}',
    careReminder,
  ].join('\n');
}

class PainTrend {
  const PainTrend({
    required this.values,
    required this.direction,
    required this.recurrenceRisk,
  });

  final List<int> values;
  final String direction;
  final bool recurrenceRisk;
}

class TrainingPhase {
  const TrainingPhase({
    required this.name,
    required this.weeks,
    required this.volumeMultiplier,
    required this.intensityMultiplier,
    required this.focus,
  });

  final String name;
  final int weeks;
  final double volumeMultiplier;
  final double intensityMultiplier;
  final String focus;
}

class AdaptivePeriodizationPlan {
  const AdaptivePeriodizationPlan({
    required this.style,
    required this.phases,
    required this.deloadCriteria,
    required this.summary,
  });

  final String style;
  final List<TrainingPhase> phases;
  final List<String> deloadCriteria;
  final String summary;
}

class TestResult {
  const TestResult({
    required this.id,
    required this.name,
    required this.value,
    required this.unit,
    required this.score,
    required this.category,
    required this.stopRule,
  });

  final String id;
  final String name;
  final double value;
  final String unit;
  final int score;
  final String category;
  final String stopRule;
}

class PerformanceBattery {
  const PerformanceBattery({
    required this.results,
    required this.radar,
    required this.nextTestDate,
    required this.lowestCategory,
  });

  final List<TestResult> results;
  final Map<String, int> radar;
  final DateTime nextTestDate;
  final String lowestCategory;
}

class SportDemandProfile {
  const SportDemandProfile({
    required this.sport,
    required this.demands,
    required this.sessions,
    required this.sprintExposureLimit,
    required this.inSeasonVolumeMultiplier,
    required this.competitionWeek,
  });

  final String sport;
  final Map<String, int> demands;
  final List<String> sessions;
  final int sprintExposureLimit;
  final double inSeasonVolumeMultiplier;
  final List<String> competitionWeek;
}

class AdaptivePlan {
  const AdaptivePlan({
    required this.name,
    required this.minutes,
    required this.exercises,
    required this.tags,
    required this.safetyChecklist,
    required this.streakProtected,
    required this.returnRampDays,
  });

  final String name;
  final int minutes;
  final List<String> exercises;
  final List<String> tags;
  final List<String> safetyChecklist;
  final bool streakProtected;
  final int returnRampDays;
}

class SafetyAdaptationEngine {
  const SafetyAdaptationEngine._();

  static SymptomAssessment assessSymptom({
    required String area,
    required int severity,
    required bool sudden,
    required bool swelling,
    required bool numbness,
    required bool worsening,
    required bool toleratesIsometric,
    required int painFreeDays,
  }) {
    if (area.trim().isEmpty ||
        severity < 0 ||
        severity > 10 ||
        painFreeDays < 0 ||
        painFreeDays > 365) {
      throw const FormatException('Symptom values are outside safe limits.');
    }
    final redFlag = numbness || (sudden && swelling) || severity >= 8;
    final stop = redFlag;
    final recoveryOnly = !stop && (severity >= 6 || worsening);
    final modify = !stop && !recoveryOnly && severity >= 3;
    final decision = stop
        ? TrainingDecision.stopAndSeekCare
        : recoveryOnly
        ? TrainingDecision.recoveryOnly
        : modify
        ? TrainingDecision.modify
        : TrainingDecision.proceed;
    final normalizedArea = area.trim().toLowerCase();
    final blocked = <String>[
      if (normalizedArea.contains('knee') || normalizedArea.contains('ankle'))
        'impact and deep knee-dominant work',
      if (normalizedArea.contains('shoulder') ||
          normalizedArea.contains('elbow'))
        'loaded overhead and painful pressing',
      if (normalizedArea.contains('back')) 'loaded spinal flexion and rotation',
      if (severity >= 6) 'all symptom-provoking patterns',
    ];
    final allowed = <String>[
      'pain-free breathing and easy mobility',
      if (severity < 6) 'unaffected movement patterns',
      if (severity <= 2) 'normal technique at controlled effort',
    ];
    final fallbacks = <String>[
      if (toleratesIsometric) 'short pain-free isometric at low effort',
      'reduce external load and stop before symptoms rise',
      'replace range with a comfortable partial range',
    ];
    final returnStage = stop
        ? 0
        : painFreeDays >= 14
        ? 4
        : painFreeDays >= 7
        ? 3
        : painFreeDays >= 3
        ? 2
        : severity <= 2
        ? 1
        : 0;
    return SymptomAssessment(
      decision: decision,
      loadMultiplier: stop
          ? 0
          : recoveryOnly
          ? .25
          : modify
          ? .6
          : 1,
      rangeMultiplier: stop
          ? 0
          : severity >= 6
          ? .4
          : severity >= 3
          ? .7
          : 1,
      allowedPatterns: allowed,
      blockedPatterns: blocked.toSet().toList(),
      fallbacks: fallbacks,
      returnStage: returnStage,
      flags: [
        if (sudden) 'sudden onset',
        if (swelling) 'swelling',
        if (numbness) 'numbness or altered sensation',
        if (worsening) 'worsening trend',
      ],
      careReminder: stop
          ? 'Stop training and seek qualified medical care promptly. Emergency symptoms require emergency services.'
          : worsening || severity >= 5
          ? 'Consider assessment by a qualified healthcare professional before progressing.'
          : 'Monitor the response. Phoenix does not diagnose or replace professional care.',
    );
  }

  static PainTrend painTrend(FitnessData data, {String area = ''}) {
    final logs =
        data.logs
            .where(
              (item) =>
                  item.painSeverity > 0 &&
                  (area.trim().isEmpty ||
                      item.painArea.toLowerCase().contains(area.toLowerCase())),
            )
            .toList()
          ..sort((a, b) => a.completedAt.compareTo(b.completedAt));
    final values = logs.map((item) => item.painSeverity).toList();
    final direction = values.length < 2
        ? 'insufficient data'
        : values.last > values.first
        ? 'worsening'
        : values.last < values.first
        ? 'improving'
        : 'stable';
    final recent = values.length > 5
        ? values.sublist(values.length - 5)
        : values;
    return PainTrend(
      values: values,
      direction: direction,
      recurrenceRisk:
          recent.where((value) => value >= 4).length >= 3 ||
          direction == 'worsening',
    );
  }

  static AdaptivePeriodizationPlan periodization({
    required String style,
    required int weeks,
    double volumeRamp = .08,
    double intensityRamp = .04,
  }) {
    if (!const {'linear', 'undulating', 'block'}.contains(style) ||
        weeks < 4 ||
        weeks > 24 ||
        volumeRamp < 0 ||
        volumeRamp > .15 ||
        intensityRamp < 0 ||
        intensityRamp > .1) {
      throw const FormatException('Periodization inputs exceed safe bounds.');
    }
    final workWeeks = math.max(3, weeks - 1);
    final phases = switch (style) {
      'linear' => <TrainingPhase>[
        TrainingPhase(
          name: 'Progressive loading',
          weeks: workWeeks,
          volumeMultiplier: 1 + volumeRamp,
          intensityMultiplier: 1 + intensityRamp,
          focus: 'Small repeatable increases',
        ),
        const TrainingPhase(
          name: 'Deload',
          weeks: 1,
          volumeMultiplier: .55,
          intensityMultiplier: .85,
          focus: 'Fatigue reduction',
        ),
      ],
      'undulating' => <TrainingPhase>[
        TrainingPhase(
          name: 'Volume emphasis',
          weeks: workWeeks ~/ 2,
          volumeMultiplier: 1 + volumeRamp,
          intensityMultiplier: .93,
          focus: 'Higher repetitions',
        ),
        TrainingPhase(
          name: 'Intensity emphasis',
          weeks: workWeeks - workWeeks ~/ 2,
          volumeMultiplier: .86,
          intensityMultiplier: 1 + intensityRamp,
          focus: 'Heavier technical work',
        ),
        const TrainingPhase(
          name: 'Pivot week',
          weeks: 1,
          volumeMultiplier: .6,
          intensityMultiplier: .8,
          focus: 'Variation and recovery',
        ),
      ],
      _ => <TrainingPhase>[
        TrainingPhase(
          name: 'Accumulation',
          weeks: math.max(1, weeks ~/ 2),
          volumeMultiplier: 1 + volumeRamp,
          intensityMultiplier: .9,
          focus: 'Work capacity',
        ),
        TrainingPhase(
          name: 'Intensification',
          weeks: math.max(1, weeks ~/ 3),
          volumeMultiplier: .82,
          intensityMultiplier: 1 + intensityRamp,
          focus: 'Specific strength',
        ),
        TrainingPhase(
          name: 'Realization / taper',
          weeks: math.max(1, weeks - weeks ~/ 2 - weeks ~/ 3),
          volumeMultiplier: .5,
          intensityMultiplier: .95,
          focus: 'Express performance without fatigue',
        ),
      ],
    };
    return AdaptivePeriodizationPlan(
      style: style,
      phases: phases,
      deloadCriteria: const [
        'Two consecutive high-fatigue check-ins',
        'Performance falls while effort rises',
        'Pain severity reaches 4/10 or more',
        'User explicitly requests recovery',
      ],
      summary:
          '${style.toUpperCase()} · $weeks weeks · volume ramp ${(volumeRamp * 100).round()}% · intensity ramp ${(intensityRamp * 100).round()}%.',
    );
  }

  static PerformanceBattery performanceBattery({
    required Map<String, double> values,
    required DateTime testedAt,
  }) {
    const definitions = <String, (String, String, double, String)>{
      'push-up': ('Push-up capacity', 'reps', 40, 'strength endurance'),
      'pull-up': ('Pull-up capacity', 'reps', 12, 'strength'),
      'squat': ('Squat endurance', 'reps', 60, 'strength endurance'),
      'plank': ('Plank endurance', 'seconds', 180, 'trunk endurance'),
      'broad-jump': ('Broad jump', 'centimeters', 240, 'power'),
      'vertical-jump': ('Vertical jump', 'centimeters', 60, 'power'),
      'cooper': ('Cooper test', 'meters', 2800, 'aerobic'),
      'step-recovery': ('Step-test recovery', 'bpm drop', 45, 'aerobic'),
    };
    final results = <TestResult>[];
    for (final entry in definitions.entries) {
      final value = values[entry.key];
      if (value == null || value < 0 || !value.isFinite) continue;
      final definition = entry.value;
      results.add(
        TestResult(
          id: entry.key,
          name: definition.$1,
          value: value,
          unit: definition.$2,
          score: ((value / definition.$3) * 100).round().clamp(0, 100),
          category: definition.$4,
          stopRule: entry.key.contains('jump')
              ? 'Stop for pain, unstable landing or loss of balance.'
              : 'Stop for pain, dizziness, chest symptoms or technique breakdown.',
        ),
      );
    }
    final grouped = <String, List<int>>{};
    for (final result in results) {
      grouped.putIfAbsent(result.category, () => []).add(result.score);
    }
    final radar = {
      for (final entry in grouped.entries)
        entry.key: entry.value.reduce((a, b) => a + b) ~/ entry.value.length,
    };
    final lowest = radar.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return PerformanceBattery(
      results: results,
      radar: radar,
      nextTestDate: testedAt.add(const Duration(days: 42)),
      lowestCategory: lowest.isEmpty ? 'unmeasured' : lowest.first.key,
    );
  }

  static SportDemandProfile sportProfile(
    String sport, {
    bool inSeason = false,
    int daysToCompetition = 30,
  }) {
    final normalized = sport.trim().toLowerCase();
    final demands = switch (normalized) {
      'football' || 'soccer' => const {
        'acceleration': 90,
        'agility': 90,
        'power': 75,
        'aerobic': 80,
      },
      'basketball' => const {
        'acceleration': 85,
        'agility': 90,
        'power': 90,
        'aerobic': 65,
      },
      'tennis' => const {
        'acceleration': 75,
        'agility': 90,
        'power': 65,
        'aerobic': 70,
      },
      _ => const {
        'acceleration': 60,
        'agility': 60,
        'power': 60,
        'aerobic': 60,
      },
    };
    return SportDemandProfile(
      sport: normalized.isEmpty ? 'general field sport' : normalized,
      demands: demands,
      sessions: const [
        'Acceleration: 6 × 10 m with full recovery',
        'Agility: 4 controlled change-of-direction reps each side',
        'Landing: 3 × 4 stick-and-hold landings',
        'Power endurance: 4 short rounds, stop before speed loss',
      ],
      sprintExposureLimit: inSeason ? 8 : 12,
      inSeasonVolumeMultiplier: inSeason ? .65 : 1,
      competitionWeek: daysToCompetition <= 7
          ? const [
              'Reduce volume 40–60%.',
              'Keep brief high-quality speed exposure.',
              'No novel drills or exhaustive conditioning.',
            ]
          : const [
              'Normal preparation; reassess seven days before competition.',
            ],
    );
  }

  static AdaptivePlan adaptivePlan({
    required String context,
    int availableMinutes = 30,
    bool seatedOnly = false,
    bool lowImpact = false,
    bool balanceSupport = false,
    bool limitedRange = false,
    bool sensoryFriendly = false,
    bool fatigueLimited = false,
    String lifeStage = 'adult',
  }) {
    if (availableMinutes < 5 || availableMinutes > 90) {
      throw const FormatException('Available time must be 5–90 minutes.');
    }
    final normalized = context.trim().toLowerCase();
    final travel = {
      'hotel',
      'travel',
      'no-equipment',
      'band',
    }.contains(normalized);
    final exercises = <String>[
      if (seatedOnly) ...[
        'Seated march',
        'Seated band row',
        'Seated press-out',
      ] else ...[
        if (!lowImpact) 'Controlled squat to reach',
        if (lowImpact) 'Sit-to-stand',
        'Incline push-up',
        if (normalized == 'band')
          'Resistance-band row'
        else
          'Towel row isometric',
        if (!balanceSupport) 'Split-stance hinge' else 'Supported hip hinge',
      ],
      'Easy breathing cooldown',
    ];
    final tags = <String>[
      if (travel) 'travel',
      if (availableMinutes <= 15) '15-minute',
      if (seatedOnly) 'seated',
      if (lowImpact) 'low-impact',
      if (balanceSupport) 'support-required',
      if (limitedRange) 'range-limited',
      if (sensoryFriendly) 'sensory-friendly',
      if (fatigueLimited) 'fatigue-limited',
      lifeStage,
    ];
    final safety = <String>[
      'Clear the floor and verify stable support.',
      if (travel) 'Check unfamiliar furniture before using it for support.',
      if (normalized == 'outdoor') ...[
        'Check daylight, route, weather and emergency contact plan.',
        'Log distance and elevation only from verified data.',
      ],
      if (sensoryFriendly) 'Keep cues predictable, quiet and optional.',
      if (fatigueLimited)
        'Use the minimum-day version and stop before form loss.',
      if (lifeStage == 'teen')
        'No maximal loading; qualified adult supervision is recommended.',
      if (lifeStage == 'older-adult')
        'Prioritize stable strength, balance support and gradual loading.',
      if (lifeStage == 'pregnancy' || lifeStage == 'postpartum')
        'Use only after individualized clearance from a qualified healthcare professional.',
      'Stop for pain, dizziness, chest symptoms, bleeding or unusual shortness of breath.',
    ];
    return AdaptivePlan(
      name: travel ? 'Travel continuity plan' : 'Adaptive functional plan',
      minutes: fatigueLimited
          ? math.min(15, availableMinutes)
          : availableMinutes,
      exercises: exercises,
      tags: tags,
      safetyChecklist: safety,
      streakProtected: travel || fatigueLimited,
      returnRampDays: travel ? 7 : 3,
    );
  }
}
