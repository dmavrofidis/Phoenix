import 'exercise_intelligence_engine.dart';
import 'models/fitness_models.dart';

class MuscleVolumeLandmark {
  const MuscleVolumeLandmark({
    required this.muscle,
    required this.minimumEffective,
    required this.maximumAdaptive,
    required this.maximumRecoverable,
    required this.currentWeeklySets,
  });

  final String muscle;
  final int minimumEffective;
  final int maximumAdaptive;
  final int maximumRecoverable;
  final int currentWeeklySets;

  String get zone {
    if (currentWeeklySets < minimumEffective) return 'BELOW MEV';
    if (currentWeeklySets <= maximumAdaptive) return 'ADAPTIVE';
    if (currentWeeklySets <= maximumRecoverable) return 'HIGH';
    return 'ABOVE MRV';
  }
}

class StimulusFatigueScore {
  const StimulusFatigueScore({
    required this.exercise,
    required this.muscle,
    required this.stimulus,
    required this.fatigue,
    required this.ratio,
    required this.lengthenedBias,
    required this.cue,
  });

  final String exercise;
  final String muscle;
  final int stimulus;
  final int fatigue;
  final double ratio;
  final bool lengthenedBias;
  final String cue;
}

class HypertrophyAdjustment {
  const HypertrophyAdjustment({
    required this.action,
    required this.setChange,
    required this.reason,
  });

  final String action;
  final int setChange;
  final String reason;
}

class HypertrophyTechniquePrescription {
  const HypertrophyTechniquePrescription({
    required this.technique,
    required this.activationReps,
    required this.miniSetReps,
    required this.rounds,
    required this.loadDropPercentage,
    required this.restSeconds,
    required this.stopRule,
  });

  final String technique;
  final int activationReps;
  final int miniSetReps;
  final int rounds;
  final double loadDropPercentage;
  final int restSeconds;
  final String stopRule;
}

class SpecializationWeek {
  const SpecializationWeek({
    required this.week,
    required this.targetSets,
    required this.frequency,
    required this.intensityTechnique,
    required this.note,
  });

  final int week;
  final int targetSets;
  final int frequency;
  final String intensityTechnique;
  final String note;
}

class HypertrophyEngine {
  const HypertrophyEngine._();

  static const muscles = <String>[
    'chest',
    'lats',
    'upper back',
    'shoulders',
    'biceps',
    'triceps',
    'quadriceps',
    'hamstrings',
    'glutes',
    'calves',
    'abs',
  ];

  static List<MuscleVolumeLandmark> volumeLandmarks(FitnessData data) {
    final actual = weeklyPrimarySets(data);
    final experience = _normalize(data.profile?.experienceLevel ?? 'beginner');
    final shift =
        experience.contains('advanced') || experience.contains('προχωρη')
        ? 4
        : experience.contains('intermediate') || experience.contains('μετρι')
        ? 2
        : 0;
    return [
      for (final muscle in muscles)
        MuscleVolumeLandmark(
          muscle: muscle,
          minimumEffective: _baseMev(muscle) + shift ~/ 2,
          maximumAdaptive: _baseMav(muscle) + shift,
          maximumRecoverable: _baseMrv(muscle) + shift,
          currentWeeklySets: actual[muscle] ?? 0,
        ),
    ];
  }

  static Map<String, int> weeklyPrimarySets(FitnessData data, {DateTime? now}) {
    final anchor = now ?? DateTime.now();
    final start = DateTime(
      anchor.year,
      anchor.month,
      anchor.day,
    ).subtract(Duration(days: anchor.weekday - 1));
    final custom = {
      for (final item in data.customExercises) _normalize(item.name): item,
    };
    final result = <String, int>{};
    for (final log in data.logs.where(
      (item) => !item.completedAt.isBefore(start),
    )) {
      for (final set in log.sets) {
        final profile = ExerciseIntelligenceEngine.profileFor(
          set.exerciseName,
          custom: custom[_normalize(set.exerciseName)],
        );
        for (final muscle in profile.primaryMuscles) {
          result.update(muscle, (value) => value + 1, ifAbsent: () => 1);
        }
      }
    }
    return result;
  }

  static List<StimulusFatigueScore> stimulusFatigue(
    FitnessData data, {
    String muscle = '',
  }) {
    final profiles = ExerciseIntelligenceEngine.allProfiles(data);
    final selected = profiles.where(
      (item) => muscle.isEmpty || item.primaryMuscles.contains(muscle),
    );
    final scores = <StimulusFatigueScore>[];
    for (final profile in selected) {
      final lengthened = hasLengthenedBias(profile);
      var stimulus = 48;
      stimulus += lengthened ? 20 : 0;
      stimulus += profile.primaryMuscles.length == 1 ? 10 : 5;
      stimulus += profile.difficulty.clamp(1, 5) * 3;
      var fatigue = 24 + profile.skillDemand * 6;
      if (const {
        'squat',
        'hinge',
        'loaded carry',
      }.contains(profile.movementPattern)) {
        fatigue += 15;
      }
      if (profile.equipment.contains('machine') ||
          profile.equipment.contains('cable')) {
        fatigue -= 8;
      }
      fatigue = fatigue.clamp(10, 95);
      stimulus = stimulus.clamp(20, 100);
      scores.add(
        StimulusFatigueScore(
          exercise: profile.name,
          muscle: profile.primaryMuscles.firstOrNull ?? 'general',
          stimulus: stimulus,
          fatigue: fatigue,
          ratio: stimulus / fatigue,
          lengthenedBias: lengthened,
          cue: lengthened
              ? 'Control the loaded stretch; never force range through pain.'
              : 'Use stable technique and progress reps before load.',
        ),
      );
    }
    scores.sort((left, right) => right.ratio.compareTo(left.ratio));
    return scores;
  }

  static bool hasLengthenedBias(ExerciseIntelligenceProfile profile) {
    final name = _normalize(profile.name);
    return name.contains('romanian') ||
        name.contains('ρουμαν') ||
        name.contains('split squat') ||
        name.contains('fly') ||
        name.contains('curl') ||
        name.contains('pullover') ||
        name.contains('overhead extension') ||
        name.contains('calf raise') ||
        name.contains('leg curl') ||
        const {
          'hinge',
          'single-leg squat',
          'shoulder horizontal adduction',
        }.contains(profile.movementPattern);
  }

  static HypertrophyAdjustment checkInAdjustment({
    required int pump,
    required int disruption,
    required int soreness,
    required int currentWeeklySets,
    required MuscleVolumeLandmark landmark,
  }) {
    if (soreness >= 4 ||
        disruption >= 5 ||
        currentWeeklySets > landmark.maximumRecoverable) {
      return const HypertrophyAdjustment(
        action: 'REDUCE VOLUME',
        setChange: -2,
        reason:
            'Recovery cost is too high. Remove two sets and keep repetitions shy of failure.',
      );
    }
    if (pump <= 2 &&
        disruption <= 2 &&
        currentWeeklySets < landmark.maximumAdaptive) {
      return const HypertrophyAdjustment(
        action: 'ADD ONE SET',
        setChange: 1,
        reason: 'Stimulus markers are low while disruption remains controlled.',
      );
    }
    if (pump >= 3 && soreness <= 3) {
      return const HypertrophyAdjustment(
        action: 'HOLD VOLUME',
        setChange: 0,
        reason:
            'Stimulus and recovery are balanced. Progress reps or execution.',
      );
    }
    return const HypertrophyAdjustment(
      action: 'HOLD AND REVIEW',
      setChange: 0,
      reason:
          'Keep volume stable and repeat the check-in after the next exposure.',
    );
  }

  static int recommendedFrequency({
    required int weeklySets,
    required String muscle,
    int maxSetsPerSession = 6,
  }) {
    if (weeklySets <= 0) return 2;
    final minimum = (weeklySets / maxSetsPerSession.clamp(3, 10)).ceil();
    final highFrequencyMuscle = const {
      'calves',
      'abs',
      'biceps',
      'triceps',
      'shoulders',
    }.contains(muscle);
    return minimum.clamp(2, highFrequencyMuscle ? 4 : 3);
  }

  static HypertrophyTechniquePrescription technique(String name) {
    switch (_normalize(name)) {
      case 'myo-reps':
      case 'myoreps':
        return const HypertrophyTechniquePrescription(
          technique: 'MYO-REPS',
          activationReps: 15,
          miniSetReps: 4,
          rounds: 4,
          loadDropPercentage: 0,
          restSeconds: 20,
          stopRule: 'Stop when a mini-set loses one rep or technique changes.',
        );
      case 'drop set':
      case 'drop-set':
        return const HypertrophyTechniquePrescription(
          technique: 'DROP SET',
          activationReps: 10,
          miniSetReps: 8,
          rounds: 2,
          loadDropPercentage: 20,
          restSeconds: 10,
          stopRule: 'Two drops maximum; stop before uncontrolled repetitions.',
        );
      default:
        return const HypertrophyTechniquePrescription(
          technique: 'REST-PAUSE',
          activationReps: 10,
          miniSetReps: 3,
          rounds: 3,
          loadDropPercentage: 0,
          restSeconds: 20,
          stopRule:
              'Stop after three clusters or the first technical breakdown.',
        );
    }
  }

  static List<SpecializationWeek> specializationBlock({
    required MuscleVolumeLandmark landmark,
    required int baselineSets,
  }) {
    final start = baselineSets.clamp(
      landmark.minimumEffective,
      landmark.maximumAdaptive,
    );
    final week2 = (start + 1).clamp(start, landmark.maximumAdaptive);
    final week3 = (week2 + 1).clamp(week2, landmark.maximumRecoverable);
    final deload = (landmark.minimumEffective * .65).round().clamp(2, start);
    return [
      SpecializationWeek(
        week: 1,
        targetSets: start,
        frequency: recommendedFrequency(
          weeklySets: start,
          muscle: landmark.muscle,
        ),
        intensityTechnique: 'STRAIGHT SETS',
        note: 'Establish repeatable technique and 2–3 RIR.',
      ),
      SpecializationWeek(
        week: 2,
        targetSets: week2,
        frequency: recommendedFrequency(
          weeklySets: week2,
          muscle: landmark.muscle,
        ),
        intensityTechnique: 'LENGTHENED BIAS',
        note: 'Add volume only if soreness has returned to baseline.',
      ),
      SpecializationWeek(
        week: 3,
        targetSets: week3,
        frequency: recommendedFrequency(
          weeklySets: week3,
          muscle: landmark.muscle,
        ),
        intensityTechnique: 'ONE INTENSIFIER',
        note: 'Use one myo-rep, drop or rest-pause set in the final exercise.',
      ),
      SpecializationWeek(
        week: 4,
        targetSets: deload,
        frequency: 2,
        intensityTechnique: 'DELOAD',
        note: 'Remove intensifiers and stay at least 3 RIR.',
      ),
    ];
  }

  static HypertrophyAdjustment volumeProgression({
    required MuscleVolumeLandmark landmark,
    HypertrophyCheckIn? latestCheckIn,
  }) {
    if (landmark.currentWeeklySets > landmark.maximumRecoverable) {
      return const HypertrophyAdjustment(
        action: 'DELOAD NOW',
        setChange: -3,
        reason: 'Weekly volume exceeded the maximum recoverable landmark.',
      );
    }
    if (latestCheckIn != null) {
      return checkInAdjustment(
        pump: latestCheckIn.pump,
        disruption: latestCheckIn.disruption,
        soreness: latestCheckIn.soreness,
        currentWeeklySets: landmark.currentWeeklySets,
        landmark: landmark,
      );
    }
    if (landmark.currentWeeklySets < landmark.minimumEffective) {
      return const HypertrophyAdjustment(
        action: 'BUILD TO MEV',
        setChange: 1,
        reason: 'Add one weekly set, then hold for at least one exposure.',
      );
    }
    return const HypertrophyAdjustment(
      action: 'HOLD BASELINE',
      setChange: 0,
      reason: 'Add a pump/disruption check-in before changing weekly volume.',
    );
  }

  static int _baseMev(String muscle) =>
      const {
        'chest': 6,
        'lats': 6,
        'upper back': 6,
        'shoulders': 6,
        'biceps': 4,
        'triceps': 4,
        'quadriceps': 6,
        'hamstrings': 4,
        'glutes': 4,
        'calves': 6,
        'abs': 4,
      }[muscle] ??
      4;

  static int _baseMav(String muscle) =>
      const {
        'chest': 14,
        'lats': 14,
        'upper back': 16,
        'shoulders': 14,
        'biceps': 12,
        'triceps': 12,
        'quadriceps': 14,
        'hamstrings': 12,
        'glutes': 14,
        'calves': 14,
        'abs': 12,
      }[muscle] ??
      12;

  static int _baseMrv(String muscle) =>
      const {
        'chest': 20,
        'lats': 22,
        'upper back': 24,
        'shoulders': 20,
        'biceps': 18,
        'triceps': 18,
        'quadriceps': 20,
        'hamstrings': 18,
        'glutes': 20,
        'calves': 20,
        'abs': 18,
      }[muscle] ??
      18;

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
