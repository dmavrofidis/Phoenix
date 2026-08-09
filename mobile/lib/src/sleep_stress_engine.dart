import 'models/fitness_models.dart';

class SleepScheduleSummary {
  const SleepScheduleSummary({
    required this.bedtimeMinutes,
    required this.wakeMinutes,
    required this.durationMinutes,
    required this.sampleDays,
    required this.label,
  });

  final int bedtimeMinutes;
  final int wakeMinutes;
  final int durationMinutes;
  final int sampleDays;
  final String label;
}

class SleepConsistencyScore {
  const SleepConsistencyScore({
    required this.score,
    required this.averageDeviationMinutes,
    required this.label,
  });

  final int score;
  final int averageDeviationMinutes;
  final String label;
}

class CaffeineCutoffPlan {
  const CaffeineCutoffPlan({
    required this.cutoffMinutes,
    required this.bufferHours,
    required this.status,
    required this.reason,
  });

  final int cutoffMinutes;
  final int bufferHours;
  final String status;
  final String reason;
}

class WindDownStep {
  const WindDownStep({
    required this.minutesBeforeBed,
    required this.title,
    required this.detail,
  });

  final int minutesBeforeBed;
  final String title;
  final String detail;
}

class ScreenFreePlan {
  const ScreenFreePlan({
    required this.startMinutes,
    required this.targetMinutes,
    required this.status,
    required this.cue,
  });

  final int startMinutes;
  final int targetMinutes;
  final String status;
  final String cue;
}

class StressTimelineSummary {
  const StressTimelineSummary({
    required this.average,
    required this.peak,
    required this.direction,
    required this.sampleSize,
  });

  final double average;
  final int peak;
  final String direction;
  final int sampleSize;
}

class RelaxationProtocol {
  const RelaxationProtocol({
    required this.id,
    required this.title,
    required this.minutes,
    required this.steps,
    required this.stopRule,
  });

  final String id;
  final String title;
  final int minutes;
  final List<String> steps;
  final String stopRule;
}

class SleepTrainingCorrelation {
  const SleepTrainingCorrelation({
    required this.sampleNights,
    required this.wellRestedWorkoutRate,
    required this.shortSleepWorkoutRate,
    required this.label,
    required this.caution,
  });

  final int sampleNights;
  final double wellRestedWorkoutRate;
  final double shortSleepWorkoutRate;
  final String label;
  final String caution;
}

class FatigueRiskBrief {
  const FatigueRiskBrief({
    required this.score,
    required this.status,
    required this.drivers,
    required this.action,
  });

  final int score;
  final String status;
  final List<String> drivers;
  final String action;
}

class SleepStressEngine {
  const SleepStressEngine._();

  static DateTime _day(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static SleepScheduleSummary schedule(List<SleepRoutineLog> logs) {
    if (logs.isEmpty) {
      return const SleepScheduleSummary(
        bedtimeMinutes: 1380,
        wakeMinutes: 420,
        durationMinutes: 480,
        sampleDays: 0,
        label: 'SET A BASELINE',
      );
    }
    final bedtimes = logs
        .map(
          (item) => item.bedtimeMinutes < 720
              ? item.bedtimeMinutes + 1440
              : item.bedtimeMinutes,
        )
        .toList();
    final bedtime = (_average(bedtimes) % 1440).round();
    final wake = _average(logs.map((item) => item.wakeMinutes)).round();
    final durations = logs.map(
      (item) => item.wakeMinutes >= item.bedtimeMinutes
          ? item.wakeMinutes - item.bedtimeMinutes
          : (1440 - item.bedtimeMinutes) + item.wakeMinutes,
    );
    final duration = _average(durations).round();
    return SleepScheduleSummary(
      bedtimeMinutes: bedtime,
      wakeMinutes: wake,
      durationMinutes: duration,
      sampleDays: logs.length,
      label: duration >= 420 && duration <= 540
          ? 'RECOVERY WINDOW'
          : duration < 420
          ? 'SHORT WINDOW'
          : 'LONG WINDOW',
    );
  }

  static SleepConsistencyScore bedtimeConsistency(List<SleepRoutineLog> logs) =>
      _consistency(
        logs
            .map(
              (item) => item.bedtimeMinutes < 720
                  ? item.bedtimeMinutes + 1440
                  : item.bedtimeMinutes,
            )
            .toList(),
      );

  static SleepConsistencyScore wakeConsistency(List<SleepRoutineLog> logs) =>
      _consistency(logs.map((item) => item.wakeMinutes).toList());

  static SleepConsistencyScore _consistency(List<int> values) {
    if (values.length < 2) {
      return const SleepConsistencyScore(
        score: 0,
        averageDeviationMinutes: 0,
        label: 'NEED 2+ NIGHTS',
      );
    }
    final center = _average(values);
    final deviation = _average(
      values.map((value) => (value - center).abs()),
    ).round();
    final score = (100 - (deviation * 1.5)).round().clamp(0, 100);
    return SleepConsistencyScore(
      score: score,
      averageDeviationMinutes: deviation,
      label: score >= 85
          ? 'CONSISTENT'
          : score >= 65
          ? 'IMPROVING'
          : 'IRREGULAR',
    );
  }

  static CaffeineCutoffPlan caffeineCutoff({
    required int bedtimeMinutes,
    required int lastCaffeineMinutes,
    bool caffeineSensitive = false,
  }) {
    final bufferHours = caffeineSensitive ? 10 : 8;
    final cutoff = (bedtimeMinutes - (bufferHours * 60)) % 1440;
    final caffeine = lastCaffeineMinutes;
    final afterCutoff =
        _forwardDistance(cutoff, caffeine) <
        _forwardDistance(cutoff, bedtimeMinutes);
    return CaffeineCutoffPlan(
      cutoffMinutes: cutoff,
      bufferHours: bufferHours,
      status: afterCutoff ? 'LATE CAFFEINE' : 'ON TARGET',
      reason: afterCutoff
          ? 'Last caffeine entered the $bufferHours-hour pre-bed buffer.'
          : 'Last caffeine stays outside the planned pre-bed buffer.',
    );
  }

  static List<WindDownStep> windDownRoutine({
    required int bedtimeMinutes,
    required int stressLevel,
  }) => [
    const WindDownStep(
      minutesBeforeBed: 90,
      title: 'CLOSE THE DAY',
      detail: 'Finish demanding work and write tomorrow’s first task.',
    ),
    const WindDownStep(
      minutesBeforeBed: 60,
      title: 'LOWER STIMULATION',
      detail: 'Dim lights and move the phone away from the bed.',
    ),
    WindDownStep(
      minutesBeforeBed: 30,
      title: stressLevel >= 4 ? 'DOWNSHIFT' : 'QUIET ROUTINE',
      detail: stressLevel >= 4
          ? 'Use five minutes of slow breathing or a body scan.'
          : 'Read, stretch gently or prepare the sleep environment.',
    ),
    const WindDownStep(
      minutesBeforeBed: 0,
      title: 'LIGHTS OUT',
      detail: 'Keep the room cool, dark and quiet.',
    ),
  ];

  static ScreenFreePlan screenFree({
    required int bedtimeMinutes,
    required int actualMinutes,
  }) {
    const target = 45;
    return ScreenFreePlan(
      startMinutes: (bedtimeMinutes - target) % 1440,
      targetMinutes: target,
      status: actualMinutes >= target ? 'TARGET MET' : 'BUILD THE BUFFER',
      cue: actualMinutes >= target
          ? 'Protect the current phone-away routine.'
          : 'Charge the phone outside reach and start with 15 minutes.',
    );
  }

  static StressTimelineSummary stressTimeline(
    List<StressCheckInLog> logs, {
    DateTime? now,
  }) {
    final anchor = now ?? DateTime.now();
    final recent =
        logs
            .where(
              (item) => item.recordedAt.isAfter(
                anchor.subtract(const Duration(days: 14)),
              ),
            )
            .toList()
          ..sort((left, right) => left.recordedAt.compareTo(right.recordedAt));
    if (recent.isEmpty) {
      return const StressTimelineSummary(
        average: 0,
        peak: 0,
        direction: 'NO DATA',
        sampleSize: 0,
      );
    }
    final average = _average(recent.map((item) => item.level));
    final midpoint = recent.length ~/ 2;
    final first = recent.take(midpoint == 0 ? 1 : midpoint);
    final second = recent.skip(midpoint == 0 ? 1 : midpoint);
    final direction = second.isEmpty
        ? 'BASELINE'
        : _average(second.map((item) => item.level)) >
              _average(first.map((item) => item.level)) + .3
        ? 'RISING'
        : _average(second.map((item) => item.level)) <
              _average(first.map((item) => item.level)) - .3
        ? 'EASING'
        : 'STABLE';
    return StressTimelineSummary(
      average: average,
      peak: recent.map((item) => item.level).reduce((a, b) => a > b ? a : b),
      direction: direction,
      sampleSize: recent.length,
    );
  }

  static List<RelaxationProtocol> relaxationLibrary() => const [
    RelaxationProtocol(
      id: 'physiological-sigh',
      title: 'PHYSIOLOGICAL SIGH',
      minutes: 2,
      steps: [
        'Inhale gently through the nose.',
        'Add a small second inhale.',
        'Exhale slowly and fully.',
      ],
      stopRule: 'Stop if light-headed; return to normal breathing.',
    ),
    RelaxationProtocol(
      id: 'extended-exhale',
      title: 'EXTENDED EXHALE',
      minutes: 5,
      steps: ['Inhale for 4 seconds.', 'Exhale softly for 6 seconds.'],
      stopRule: 'No breath holds or forceful breaths.',
    ),
    RelaxationProtocol(
      id: 'body-scan',
      title: 'BODY SCAN',
      minutes: 8,
      steps: [
        'Notice contact with the surface.',
        'Scan from feet to face without fixing anything.',
        'Relax the jaw and shoulders.',
      ],
      stopRule: 'Pause if the exercise increases distress.',
    ),
  ];

  static SleepTrainingCorrelation trainingCorrelation({
    required List<RecoveryCheckIn> recoveryChecks,
    required List<WorkoutLog> workouts,
  }) {
    final workoutDays = workouts.map((item) => _day(item.completedAt)).toSet();
    final nights = <DateTime, double>{};
    for (final check in recoveryChecks) {
      nights[_day(check.recordedAt)] = check.sleepHours;
    }
    if (nights.length < 4) {
      return SleepTrainingCorrelation(
        sampleNights: nights.length,
        wellRestedWorkoutRate: 0,
        shortSleepWorkoutRate: 0,
        label: 'EARLY DATA',
        caution: 'Log at least four matched mornings before comparing.',
      );
    }
    final well = nights.entries.where((item) => item.value >= 7).toList();
    final short = nights.entries.where((item) => item.value < 7).toList();
    final wellRate = _entryRate(well, workoutDays);
    final shortRate = _entryRate(short, workoutDays);
    return SleepTrainingCorrelation(
      sampleNights: nights.length,
      wellRestedWorkoutRate: wellRate,
      shortSleepWorkoutRate: shortRate,
      label: wellRate > shortRate + .15
          ? 'BETTER AFTER 7H+'
          : shortRate > wellRate + .15
          ? 'SCHEDULE EFFECT'
          : 'NO CLEAR DIFFERENCE',
      caution:
          'This is an association, not causation; planned rest days can reverse the pattern.',
    );
  }

  static FatigueRiskBrief morningBrief({
    RecoveryCheckIn? recovery,
    required StressTimelineSummary stress,
    required int hardWorkoutsLast72Hours,
  }) {
    var score = 0;
    final drivers = <String>[];
    if (recovery == null) {
      score += 20;
      drivers.add('No morning recovery check-in');
    } else {
      if (recovery.sleepHours < 6) {
        score += 35;
        drivers.add('Sleep below six hours');
      } else if (recovery.sleepHours < 7) {
        score += 20;
        drivers.add('Sleep below seven hours');
      }
      if (recovery.energy <= 2) {
        score += 20;
        drivers.add('Low energy');
      }
      if (recovery.soreness >= 4) {
        score += 15;
        drivers.add('High soreness');
      }
    }
    if (stress.average >= 4 || stress.direction == 'RISING') {
      score += 15;
      drivers.add('Elevated stress trend');
    }
    if (hardWorkoutsLast72Hours >= 2) {
      score += 15;
      drivers.add('Dense hard training');
    }
    score = score.clamp(0, 100);
    return FatigueRiskBrief(
      score: score,
      status: score >= 70
          ? 'HIGH FATIGUE RISK'
          : score >= 40
          ? 'MODERATE FATIGUE RISK'
          : 'LOW FATIGUE RISK',
      drivers: drivers.isEmpty ? const ['No major risk flags'] : drivers,
      action: score >= 70
          ? 'Use recovery work or rest; avoid maximal or failure training.'
          : score >= 40
          ? 'Keep two to three reps in reserve and reduce optional volume.'
          : 'Train as planned while keeping technique and normal stop rules.',
    );
  }

  static int _forwardDistance(int start, int end) => (end - start) % 1440;

  static double _entryRate(
    List<MapEntry<DateTime, double>> entries,
    Set<DateTime> workouts,
  ) {
    if (entries.isEmpty) return 0;
    return entries.where((item) => workouts.contains(item.key)).length /
        entries.length;
  }

  static double _average(Iterable<num> values) {
    final list = values.toList();
    if (list.isEmpty) return 0;
    return list.fold<double>(0, (sum, value) => sum + value) / list.length;
  }
}
