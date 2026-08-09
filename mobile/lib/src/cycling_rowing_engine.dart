import 'models/fitness_models.dart';

class CyclingPowerZone {
  const CyclingPowerZone({
    required this.number,
    required this.name,
    required this.minimumWatts,
    required this.maximumWatts,
    required this.purpose,
  });

  final int number;
  final String name;
  final int minimumWatts;
  final int? maximumWatts;
  final String purpose;

  String get rangeLabel => maximumWatts == null
      ? '$minimumWatts+ W'
      : '$minimumWatts–$maximumWatts W';
}

class FtpEstimate {
  const FtpEstimate({
    required this.protocol,
    required this.testPowerWatts,
    required this.estimatedFtpWatts,
    required this.multiplier,
    required this.guidance,
  });

  final String protocol;
  final double testPowerWatts;
  final int estimatedFtpWatts;
  final double multiplier;
  final String guidance;
}

class CadenceAssessment {
  const CadenceAssessment({
    required this.rpm,
    required this.targetMinimum,
    required this.targetMaximum,
    required this.status,
    required this.cue,
  });

  final int rpm;
  final int targetMinimum;
  final int targetMaximum;
  final String status;
  final String cue;
}

class CyclingWorkoutSegment {
  const CyclingWorkoutSegment({
    required this.label,
    required this.minutes,
    required this.ftpPercentage,
    required this.cadenceMinimum,
    required this.cadenceMaximum,
    this.repeats = 1,
  });

  final String label;
  final int minutes;
  final int ftpPercentage;
  final int cadenceMinimum;
  final int cadenceMaximum;
  final int repeats;

  int get totalMinutes => minutes * repeats;
}

class IndoorCyclingWorkout {
  const IndoorCyclingWorkout({
    required this.id,
    required this.name,
    required this.focus,
    required this.segments,
    required this.safetyNote,
  });

  final String id;
  final String name;
  final String focus;
  final List<CyclingWorkoutSegment> segments;
  final String safetyNote;

  int get totalMinutes =>
      segments.fold(0, (sum, segment) => sum + segment.totalMinutes);
}

class RowingSplit {
  const RowingSplit({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.secondsPer500Meters,
    required this.watts,
    required this.metersPerSecond,
  });

  final int distanceMeters;
  final int durationSeconds;
  final double secondsPer500Meters;
  final double watts;
  final double metersPerSecond;

  String get formattedSplit {
    final minutes = secondsPer500Meters ~/ 60;
    final seconds = (secondsPer500Meters % 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')} /500m';
  }
}

class RowingStrokeAssessment {
  const RowingStrokeAssessment({
    required this.strokesPerMinute,
    required this.targetMinimum,
    required this.targetMaximum,
    required this.efficiencyWattsPerStroke,
    required this.status,
    required this.cue,
  });

  final int strokesPerMinute;
  final int targetMinimum;
  final int targetMaximum;
  final double efficiencyWattsPerStroke;
  final String status;
  final String cue;
}

class ErgBenchmark {
  const ErgBenchmark({
    required this.id,
    required this.name,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.targetStrokeRate,
    required this.protocol,
  });

  final String id;
  final String name;
  final int distanceMeters;
  final int durationSeconds;
  final String targetStrokeRate;
  final String protocol;
}

class EnduranceConversion {
  const EnduranceConversion({
    required this.modality,
    required this.distance,
    required this.durationSeconds,
    required this.speed,
    required this.paceLabel,
  });

  final String modality;
  final double distance;
  final int durationSeconds;
  final double speed;
  final String paceLabel;
}

class EnduranceModalityProfile {
  const EnduranceModalityProfile({
    required this.modality,
    required this.impact,
    required this.primaryMuscles,
    required this.skillDemand,
    required this.strengthInterference,
    required this.bestFor,
  });

  final String modality;
  final String impact;
  final String primaryMuscles;
  final String skillDemand;
  final String strengthInterference;
  final String bestFor;
}

class MultiSportWeeklyLoad {
  const MultiSportWeeklyLoad({
    required this.totalLoad,
    required this.durationMinutes,
    required this.sessions,
    required this.hardSessions,
    required this.byModality,
    required this.status,
    required this.guidance,
  });

  final int totalLoad;
  final int durationMinutes;
  final int sessions;
  final int hardSessions;
  final Map<String, int> byModality;
  final String status;
  final String guidance;
}

class CyclingRowingEngine {
  const CyclingRowingEngine._();

  static List<CyclingPowerZone> powerZones(double ftpWatts) {
    final ftp = ftpWatts.clamp(1, 1000).toDouble();
    int at(double percentage) => (ftp * percentage).round();
    return [
      CyclingPowerZone(
        number: 1,
        name: 'ACTIVE RECOVERY',
        minimumWatts: 0,
        maximumWatts: at(.55),
        purpose: 'Easy circulation, warm-up and recovery.',
      ),
      CyclingPowerZone(
        number: 2,
        name: 'ENDURANCE',
        minimumWatts: at(.56),
        maximumWatts: at(.75),
        purpose: 'Aerobic base and sustainable volume.',
      ),
      CyclingPowerZone(
        number: 3,
        name: 'TEMPO',
        minimumWatts: at(.76),
        maximumWatts: at(.90),
        purpose: 'Durable sub-threshold work.',
      ),
      CyclingPowerZone(
        number: 4,
        name: 'THRESHOLD',
        minimumWatts: at(.91),
        maximumWatts: at(1.05),
        purpose: 'FTP development in controlled blocks.',
      ),
      CyclingPowerZone(
        number: 5,
        name: 'VO2 MAX',
        minimumWatts: at(1.06),
        maximumWatts: at(1.20),
        purpose: 'Short aerobic-power intervals.',
      ),
      CyclingPowerZone(
        number: 6,
        name: 'ANAEROBIC',
        minimumWatts: at(1.21),
        maximumWatts: at(1.50),
        purpose: 'Brief high-power efforts with full recovery.',
      ),
      CyclingPowerZone(
        number: 7,
        name: 'NEUROMUSCULAR',
        minimumWatts: at(1.51),
        maximumWatts: null,
        purpose: 'Very short, technically clean sprints.',
      ),
    ];
  }

  static FtpEstimate estimateFtp({
    required String protocol,
    required double testPowerWatts,
  }) {
    final normalized = protocol.trim().toLowerCase();
    final multiplier = normalized.contains('ramp')
        ? .75
        : normalized.contains('8')
        ? .90
        : .95;
    final name = normalized.contains('ramp')
        ? 'RAMP TEST'
        : normalized.contains('8')
        ? '8-MINUTE TEST'
        : '20-MINUTE TEST';
    return FtpEstimate(
      protocol: name,
      testPowerWatts: testPowerWatts,
      estimatedFtpWatts: (testPowerWatts.clamp(1, 1500) * multiplier).round(),
      multiplier: multiplier,
      guidance: name == 'RAMP TEST'
          ? 'Use the best completed one-minute power after a progressive ramp.'
          : 'Test after a full warm-up; pace evenly and stop for chest pain, dizziness or unusual symptoms.',
    );
  }

  static CadenceAssessment cyclingCadence({
    required int rpm,
    String goal = 'Endurance',
  }) {
    final normalized = goal.toLowerCase();
    final target = normalized.contains('climb')
        ? (70, 85)
        : normalized.contains('speed')
        ? (95, 110)
        : normalized.contains('recovery')
        ? (80, 95)
        : (85, 100);
    final status = rpm < target.$1
        ? 'LOW'
        : rpm > target.$2
        ? 'HIGH'
        : 'ON TARGET';
    return CadenceAssessment(
      rpm: rpm,
      targetMinimum: target.$1,
      targetMaximum: target.$2,
      status: status,
      cue: status == 'LOW'
          ? 'Shift easier and raise cadence gradually without bouncing.'
          : status == 'HIGH'
          ? 'Add light resistance and keep the pedal stroke controlled.'
          : 'Cadence matches the session goal; keep the hips stable.',
    );
  }

  static const indoorWorkouts = <IndoorCyclingWorkout>[
    IndoorCyclingWorkout(
      id: 'aerobic-base',
      name: 'AEROBIC BASE 45',
      focus: 'Endurance',
      segments: [
        CyclingWorkoutSegment(
          label: 'Warm-up',
          minutes: 8,
          ftpPercentage: 55,
          cadenceMinimum: 80,
          cadenceMaximum: 90,
        ),
        CyclingWorkoutSegment(
          label: 'Steady endurance',
          minutes: 30,
          ftpPercentage: 70,
          cadenceMinimum: 85,
          cadenceMaximum: 95,
        ),
        CyclingWorkoutSegment(
          label: 'Cool-down',
          minutes: 7,
          ftpPercentage: 50,
          cadenceMinimum: 75,
          cadenceMaximum: 90,
        ),
      ],
      safetyNote: 'Conversational effort; reduce resistance if form degrades.',
    ),
    IndoorCyclingWorkout(
      id: 'sweet-spot',
      name: 'SWEET SPOT 3×8',
      focus: 'Durability',
      segments: [
        CyclingWorkoutSegment(
          label: 'Warm-up',
          minutes: 10,
          ftpPercentage: 60,
          cadenceMinimum: 80,
          cadenceMaximum: 95,
        ),
        CyclingWorkoutSegment(
          label: 'Sweet spot',
          minutes: 8,
          ftpPercentage: 90,
          cadenceMinimum: 85,
          cadenceMaximum: 95,
          repeats: 3,
        ),
        CyclingWorkoutSegment(
          label: 'Easy recovery',
          minutes: 4,
          ftpPercentage: 50,
          cadenceMinimum: 80,
          cadenceMaximum: 95,
          repeats: 2,
        ),
        CyclingWorkoutSegment(
          label: 'Cool-down',
          minutes: 6,
          ftpPercentage: 45,
          cadenceMinimum: 75,
          cadenceMaximum: 90,
        ),
      ],
      safetyNote:
          'Keep every interval controlled; do not turn it into a maximal test.',
    ),
    IndoorCyclingWorkout(
      id: 'threshold',
      name: 'THRESHOLD 4×6',
      focus: 'FTP',
      segments: [
        CyclingWorkoutSegment(
          label: 'Warm-up',
          minutes: 12,
          ftpPercentage: 60,
          cadenceMinimum: 80,
          cadenceMaximum: 95,
        ),
        CyclingWorkoutSegment(
          label: 'Threshold',
          minutes: 6,
          ftpPercentage: 100,
          cadenceMinimum: 85,
          cadenceMaximum: 100,
          repeats: 4,
        ),
        CyclingWorkoutSegment(
          label: 'Easy recovery',
          minutes: 3,
          ftpPercentage: 50,
          cadenceMinimum: 80,
          cadenceMaximum: 95,
          repeats: 3,
        ),
        CyclingWorkoutSegment(
          label: 'Cool-down',
          minutes: 7,
          ftpPercentage: 45,
          cadenceMinimum: 75,
          cadenceMaximum: 90,
        ),
      ],
      safetyNote:
          'End the set if power drops sharply while effort keeps rising.',
    ),
    IndoorCyclingWorkout(
      id: 'vo2',
      name: 'VO2 5×3',
      focus: 'Aerobic power',
      segments: [
        CyclingWorkoutSegment(
          label: 'Warm-up',
          minutes: 12,
          ftpPercentage: 60,
          cadenceMinimum: 85,
          cadenceMaximum: 95,
        ),
        CyclingWorkoutSegment(
          label: 'VO2 interval',
          minutes: 3,
          ftpPercentage: 115,
          cadenceMinimum: 95,
          cadenceMaximum: 105,
          repeats: 5,
        ),
        CyclingWorkoutSegment(
          label: 'Easy recovery',
          minutes: 3,
          ftpPercentage: 45,
          cadenceMinimum: 80,
          cadenceMaximum: 95,
          repeats: 4,
        ),
        CyclingWorkoutSegment(
          label: 'Cool-down',
          minutes: 8,
          ftpPercentage: 45,
          cadenceMinimum: 75,
          cadenceMaximum: 90,
        ),
      ],
      safetyNote:
          'Use only when recovered and keep at least 48 hours before another hard endurance day.',
    ),
  ];

  static RowingSplit rowingSplit({
    required int distanceMeters,
    required int durationSeconds,
  }) {
    if (distanceMeters <= 0 || durationSeconds <= 0) {
      return const RowingSplit(
        distanceMeters: 0,
        durationSeconds: 0,
        secondsPer500Meters: 0,
        watts: 0,
        metersPerSecond: 0,
      );
    }
    final split = durationSeconds / distanceMeters * 500;
    final watts = 2.8 / ((split / 500) * (split / 500) * (split / 500));
    return RowingSplit(
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      secondsPer500Meters: split,
      watts: _roundTenth(watts),
      metersPerSecond: distanceMeters / durationSeconds,
    );
  }

  static RowingStrokeAssessment rowingStrokeRate({
    required int strokesPerMinute,
    required double watts,
    String goal = 'Steady',
  }) {
    final normalized = goal.toLowerCase();
    final target = normalized.contains('race')
        ? (28, 36)
        : normalized.contains('power')
        ? (24, 30)
        : (18, 24);
    final status = strokesPerMinute < target.$1
        ? 'LOW'
        : strokesPerMinute > target.$2
        ? 'HIGH'
        : 'ON TARGET';
    return RowingStrokeAssessment(
      strokesPerMinute: strokesPerMinute,
      targetMinimum: target.$1,
      targetMaximum: target.$2,
      efficiencyWattsPerStroke: strokesPerMinute <= 0
          ? 0
          : _roundTenth(watts / strokesPerMinute),
      status: status,
      cue: status == 'LOW'
          ? 'Keep the drive powerful and raise the rate gradually.'
          : status == 'HIGH'
          ? 'Lengthen the recovery and avoid rushing the slide.'
          : 'Rate matches the goal: legs first, then body, then arms.',
    );
  }

  static const ergBenchmarks = <ErgBenchmark>[
    ErgBenchmark(
      id: '500m',
      name: '500 M SPRINT',
      distanceMeters: 500,
      durationSeconds: 0,
      targetStrokeRate: '30–38 spm',
      protocol:
          'Full warm-up, one controlled maximal effort, complete recovery.',
    ),
    ErgBenchmark(
      id: '2k',
      name: '2 KM STANDARD',
      distanceMeters: 2000,
      durationSeconds: 0,
      targetStrokeRate: '28–34 spm',
      protocol:
          'Even first half, controlled build, finish only if technique holds.',
    ),
    ErgBenchmark(
      id: '5k',
      name: '5 KM AEROBIC',
      distanceMeters: 5000,
      durationSeconds: 0,
      targetStrokeRate: '24–28 spm',
      protocol: 'Sustainable hard pace; avoid an aggressive first kilometer.',
    ),
    ErgBenchmark(
      id: '30min',
      name: '30-MINUTE DISTANCE',
      distanceMeters: 0,
      durationSeconds: 1800,
      targetStrokeRate: '20–26 spm',
      protocol: 'Record total meters while preserving a repeatable stroke.',
    ),
  ];

  static EnduranceConversion convertDistanceTime({
    required String modality,
    required double distance,
    required int durationSeconds,
  }) {
    if (distance <= 0 || durationSeconds <= 0) {
      return EnduranceConversion(
        modality: modality,
        distance: 0,
        durationSeconds: 0,
        speed: 0,
        paceLabel: 'NO DATA',
      );
    }
    final rowing = modality.toLowerCase().contains('row');
    final distanceKilometers = rowing ? distance / 1000 : distance;
    final speed = distanceKilometers / durationSeconds * 3600;
    final paceSeconds = rowing
        ? durationSeconds / distance * 500
        : durationSeconds / distance;
    final minutes = paceSeconds ~/ 60;
    final seconds = (paceSeconds % 60).round();
    return EnduranceConversion(
      modality: modality,
      distance: distance,
      durationSeconds: durationSeconds,
      speed: _roundTenth(speed),
      paceLabel:
          '$minutes:${seconds.toString().padLeft(2, '0')} ${rowing ? '/500m' : '/km'}',
    );
  }

  static const modalityProfiles = <EnduranceModalityProfile>[
    EnduranceModalityProfile(
      modality: 'CYCLING',
      impact: 'Very low',
      primaryMuscles: 'Quads, glutes, calves',
      skillDemand: 'Low–moderate',
      strengthInterference: 'Moderate for lower-body volume',
      bestFor: 'High aerobic volume with low impact',
    ),
    EnduranceModalityProfile(
      modality: 'ROWING',
      impact: 'Low',
      primaryMuscles: 'Legs, trunk, lats, arms',
      skillDemand: 'Moderate–high',
      strengthInterference: 'Moderate whole-body fatigue',
      bestFor: 'Whole-body conditioning and power endurance',
    ),
    EnduranceModalityProfile(
      modality: 'RUNNING',
      impact: 'Moderate–high',
      primaryMuscles: 'Calves, quads, hamstrings, glutes',
      skillDemand: 'Moderate',
      strengthInterference: 'Higher eccentric lower-body cost',
      bestFor: 'Running economy, bone loading and simple access',
    ),
  ];

  static MultiSportWeeklyLoad weeklyLoad({
    required List<CardioSessionLog> cardio,
    required List<RunningSessionLog> running,
    required List<CyclingSessionLog> cycling,
    required List<RowingSessionLog> rowing,
    DateTime? now,
    int weeksAgo = 0,
  }) {
    final anchor = now ?? DateTime.now();
    final monday = DateTime(
      anchor.year,
      anchor.month,
      anchor.day,
    ).subtract(Duration(days: anchor.weekday - 1 + weeksAgo * 7));
    final end = monday.add(const Duration(days: 7));
    bool inWeek(DateTime value) =>
        !value.isBefore(monday) && value.isBefore(end);

    final cardioWeek = cardio.where((item) => inWeek(item.recordedAt)).toList();
    final runningWeek = running
        .where((item) => inWeek(item.recordedAt))
        .toList();
    final cyclingWeek = cycling
        .where((item) => inWeek(item.recordedAt))
        .toList();
    final rowingWeek = rowing.where((item) => inWeek(item.recordedAt)).toList();

    final byModality = <String, int>{
      'CARDIO': cardioWeek.fold(
        0,
        (sum, item) => sum + item.durationMinutes * item.rpe,
      ),
      'RUNNING': runningWeek.fold(
        0,
        (sum, item) => sum + (item.durationSeconds / 60 * item.rpe).round(),
      ),
      'CYCLING': cyclingWeek.fold(
        0,
        (sum, item) => sum + item.durationMinutes * item.rpe,
      ),
      'ROWING': rowingWeek.fold(
        0,
        (sum, item) => sum + (item.durationSeconds / 60 * item.rpe).round(),
      ),
    };
    final total = byModality.values.fold(0, (sum, value) => sum + value);
    final duration =
        cardioWeek.fold<int>(0, (sum, item) => sum + item.durationMinutes) +
        runningWeek.fold<int>(
          0,
          (sum, item) => sum + (item.durationSeconds / 60).round(),
        ) +
        cyclingWeek.fold<int>(0, (sum, item) => sum + item.durationMinutes) +
        rowingWeek.fold<int>(
          0,
          (sum, item) => sum + (item.durationSeconds / 60).round(),
        );
    final hard =
        cardioWeek.where((item) => item.rpe >= 8).length +
        runningWeek.where((item) => item.rpe >= 8).length +
        cyclingWeek.where((item) => item.rpe >= 8).length +
        rowingWeek.where((item) => item.rpe >= 8).length;
    final sessions =
        cardioWeek.length +
        runningWeek.length +
        cyclingWeek.length +
        rowingWeek.length;
    final status = hard >= 4 || total >= 2400
        ? 'HIGH'
        : hard >= 2 || total >= 1200
        ? 'BUILDING'
        : 'BALANCED';
    return MultiSportWeeklyLoad(
      totalLoad: total,
      durationMinutes: duration,
      sessions: sessions,
      hardSessions: hard,
      byModality: byModality,
      status: status,
      guidance: status == 'HIGH'
          ? 'Reduce one hard session and protect at least one low-load day.'
          : status == 'BUILDING'
          ? 'Keep hard sessions separated and avoid raising all modalities together.'
          : 'Load is controlled; progress duration or intensity, not both.',
    );
  }

  static double _roundTenth(num value) => (value.toDouble() * 10).round() / 10;
}
