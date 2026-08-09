class ExercisePrescription {
  const ExercisePrescription({
    required this.workingSets,
    required this.minReps,
    required this.maxReps,
    required this.targetRir,
    required this.restSeconds,
    required this.tempo,
    this.minHoldSeconds = 0,
    this.maxHoldSeconds = 0,
    this.note = '',
  });

  final int workingSets;
  final int minReps;
  final int maxReps;
  final int targetRir;
  final int restSeconds;
  final String tempo;
  final int minHoldSeconds;
  final int maxHoldSeconds;
  final String note;

  bool get isTimed => maxHoldSeconds > 0;

  String get targetLabel =>
      isTimed ? '$minHoldSeconds–$maxHoldSeconds″' : '$minReps–$maxReps επαν.';

  String get summary {
    final rest = restSeconds >= 120 ? '${restSeconds ~/ 60}′' : '$restSeconds″';
    return '$workingSets σετ × $targetLabel • RIR $targetRir • $rest';
  }

  Map<String, Object> toJson() => {
    'workingSets': workingSets,
    'minReps': minReps,
    'maxReps': maxReps,
    'targetRir': targetRir,
    'restSeconds': restSeconds,
    'tempo': tempo,
    'minHoldSeconds': minHoldSeconds,
    'maxHoldSeconds': maxHoldSeconds,
    'note': note,
  };

  factory ExercisePrescription.fromJson(Map<String, dynamic> json) =>
      ExercisePrescription(
        workingSets: json['workingSets'] as int? ?? 3,
        minReps: json['minReps'] as int? ?? 8,
        maxReps: json['maxReps'] as int? ?? 12,
        targetRir: json['targetRir'] as int? ?? 2,
        restSeconds: json['restSeconds'] as int? ?? 90,
        tempo: json['tempo'] as String? ?? '2–1–2',
        minHoldSeconds: json['minHoldSeconds'] as int? ?? 0,
        maxHoldSeconds: json['maxHoldSeconds'] as int? ?? 0,
        note: json['note'] as String? ?? '',
      );
}

class WorkoutBlock {
  const WorkoutBlock({
    required this.id,
    required this.type,
    required this.exercises,
  });

  final String id;
  final String type;
  final List<String> exercises;

  bool get isSuperset => type == 'superset';
  bool get isCircuit => type == 'circuit';

  String get label => isSuperset ? 'SUPERSET' : 'CIRCUIT';

  Map<String, Object> toJson() => {
    'id': id,
    'type': type,
    'exercises': exercises,
  };

  factory WorkoutBlock.fromJson(Map<String, dynamic> json) => WorkoutBlock(
    id: json['id'] as String,
    type: json['type'] as String? ?? 'superset',
    exercises: List<String>.from(json['exercises'] as List? ?? const []),
  );
}

class WorkoutTemplate {
  const WorkoutTemplate({
    required this.id,
    required this.name,
    required this.exercises,
    this.prescription = '3 σετ × 8–12 • RIR 1–2',
    this.coachingCue = 'Σταμάτα το σετ μόλις αρχίσει να χαλάει η τεχνική.',
    this.restSeconds = 90,
    this.exercisePrescriptions = const {},
    this.isFavorite = false,
    this.tags = const [],
    this.sessionType = 'workout',
    this.equipmentPreset = 'all',
    this.blocks = const [],
  });

  final String id;
  final String name;
  final List<String> exercises;
  final String prescription;
  final String coachingCue;
  final int restSeconds;
  final Map<String, ExercisePrescription> exercisePrescriptions;
  final bool isFavorite;
  final List<String> tags;
  final String sessionType;
  final String equipmentPreset;
  final List<WorkoutBlock> blocks;

  bool get isRecoveryDay => sessionType == 'recovery';

  WorkoutBlock? blockFor(String exercise) {
    for (final block in blocks) {
      if (block.exercises.contains(exercise)) return block;
    }
    return null;
  }

  ExercisePrescription prescriptionFor(String exercise) =>
      exercisePrescriptions[exercise] ??
      ExercisePrescription(
        workingSets: 3,
        minReps: 8,
        maxReps: 12,
        targetRir: 2,
        restSeconds: restSeconds,
        tempo: '2–1–2',
      );

  WorkoutTemplate copyWith({
    String? id,
    String? name,
    List<String>? exercises,
    String? prescription,
    String? coachingCue,
    int? restSeconds,
    Map<String, ExercisePrescription>? exercisePrescriptions,
    bool? isFavorite,
    List<String>? tags,
    String? sessionType,
    String? equipmentPreset,
    List<WorkoutBlock>? blocks,
  }) => WorkoutTemplate(
    id: id ?? this.id,
    name: name ?? this.name,
    exercises: exercises ?? this.exercises,
    prescription: prescription ?? this.prescription,
    coachingCue: coachingCue ?? this.coachingCue,
    restSeconds: restSeconds ?? this.restSeconds,
    exercisePrescriptions: exercisePrescriptions ?? this.exercisePrescriptions,
    isFavorite: isFavorite ?? this.isFavorite,
    tags: tags ?? this.tags,
    sessionType: sessionType ?? this.sessionType,
    equipmentPreset: equipmentPreset ?? this.equipmentPreset,
    blocks: blocks ?? this.blocks,
  );

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'exercises': exercises,
    'prescription': prescription,
    'coachingCue': coachingCue,
    'restSeconds': restSeconds,
    'exercisePrescriptions': exercisePrescriptions.map(
      (name, value) => MapEntry(name, value.toJson()),
    ),
    'isFavorite': isFavorite,
    'tags': tags,
    'sessionType': sessionType,
    'equipmentPreset': equipmentPreset,
    'blocks': blocks.map((item) => item.toJson()).toList(),
  };

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    final encodedPrescriptions =
        json['exercisePrescriptions'] as Map<String, dynamic>? ?? const {};
    return WorkoutTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      exercises: List<String>.from(json['exercises'] as List),
      prescription: json['prescription'] as String? ?? '3 σετ × 8–12 • RIR 1–2',
      coachingCue:
          json['coachingCue'] as String? ??
          'Σταμάτα το σετ μόλις αρχίσει να χαλάει η τεχνική.',
      restSeconds: json['restSeconds'] as int? ?? 90,
      exercisePrescriptions: encodedPrescriptions.map(
        (name, value) => MapEntry(
          name,
          ExercisePrescription.fromJson(value as Map<String, dynamic>),
        ),
      ),
      isFavorite: json['isFavorite'] as bool? ?? false,
      tags: List<String>.from(json['tags'] as List? ?? const []),
      sessionType: json['sessionType'] as String? ?? 'workout',
      equipmentPreset: json['equipmentPreset'] as String? ?? 'all',
      blocks: (json['blocks'] as List? ?? const [])
          .map((item) => WorkoutBlock.fromJson(item as Map<String, dynamic>))
          .where((block) => block.exercises.length >= 2)
          .toList(),
    );
  }
}

class ProgramVersion {
  const ProgramVersion({
    required this.id,
    required this.templateId,
    required this.savedAt,
    required this.snapshot,
  });

  final String id;
  final String templateId;
  final DateTime savedAt;
  final WorkoutTemplate snapshot;

  Map<String, Object> toJson() => {
    'id': id,
    'templateId': templateId,
    'savedAt': savedAt.toIso8601String(),
    'snapshot': snapshot.toJson(),
  };

  factory ProgramVersion.fromJson(Map<String, dynamic> json) => ProgramVersion(
    id: json['id'] as String,
    templateId: json['templateId'] as String,
    savedAt: DateTime.parse(json['savedAt'] as String),
    snapshot: WorkoutTemplate.fromJson(
      json['snapshot'] as Map<String, dynamic>,
    ),
  );
}

class WorkoutLog {
  const WorkoutLog({
    required this.templateName,
    required this.completedAt,
    required this.minutes,
    this.sets = const [],
    this.sessionRpe = 0,
    this.notes = '',
    this.painArea = '',
    this.painSeverity = 0,
  });

  final String templateName;
  final DateTime completedAt;
  final int minutes;
  final List<ExerciseSetLog> sets;
  final int sessionRpe;
  final String notes;
  final String painArea;
  final int painSeverity;

  Map<String, Object> toJson() => {
    'templateName': templateName,
    'completedAt': completedAt.toIso8601String(),
    'minutes': minutes,
    'sets': sets.map((item) => item.toJson()).toList(),
    'sessionRpe': sessionRpe,
    'notes': notes,
    'painArea': painArea,
    'painSeverity': painSeverity,
  };

  factory WorkoutLog.fromJson(Map<String, dynamic> json) => WorkoutLog(
    templateName: json['templateName'] as String,
    completedAt: DateTime.parse(json['completedAt'] as String),
    minutes: json['minutes'] as int,
    sets: (json['sets'] as List? ?? const [])
        .map((item) => ExerciseSetLog.fromJson(item as Map<String, dynamic>))
        .toList(),
    sessionRpe: json['sessionRpe'] as int? ?? 0,
    notes: json['notes'] as String? ?? '',
    painArea: json['painArea'] as String? ?? '',
    painSeverity: json['painSeverity'] as int? ?? 0,
  );
}

class ExerciseSetLog {
  const ExerciseSetLog({
    required this.exerciseName,
    required this.reps,
    required this.weightKilograms,
    required this.rir,
    required this.holdSeconds,
    required this.loggedAt,
    this.setRpe = 0,
    this.velocityNote = '',
    this.techniqueChecks = const [],
    this.isAmrap = false,
  });

  final String exerciseName;
  final int reps;
  final double weightKilograms;
  final int rir;
  final int holdSeconds;
  final DateTime loggedAt;
  final int setRpe;
  final String velocityNote;
  final List<String> techniqueChecks;
  final bool isAmrap;

  double get volume => weightKilograms * reps;

  Map<String, Object> toJson() => {
    'exerciseName': exerciseName,
    'reps': reps,
    'weightKilograms': weightKilograms,
    'rir': rir,
    'holdSeconds': holdSeconds,
    'loggedAt': loggedAt.toIso8601String(),
    'setRpe': setRpe,
    'velocityNote': velocityNote,
    'techniqueChecks': techniqueChecks,
    'isAmrap': isAmrap,
  };

  factory ExerciseSetLog.fromJson(Map<String, dynamic> json) => ExerciseSetLog(
    exerciseName: json['exerciseName'] as String,
    reps: json['reps'] as int? ?? 0,
    weightKilograms: (json['weightKilograms'] as num? ?? 0).toDouble(),
    rir: json['rir'] as int? ?? 2,
    holdSeconds: json['holdSeconds'] as int? ?? 0,
    loggedAt: DateTime.parse(json['loggedAt'] as String),
    setRpe: json['setRpe'] as int? ?? 0,
    velocityNote: json['velocityNote'] as String? ?? '',
    techniqueChecks: List<String>.from(
      json['techniqueChecks'] as List? ?? const [],
    ),
    isAmrap: json['isAmrap'] as bool? ?? false,
  );
}

class StrengthTestResult {
  const StrengthTestResult({
    required this.id,
    required this.exerciseName,
    required this.weightKilograms,
    required this.reps,
    required this.estimatedOneRepMax,
    required this.protocol,
    required this.recordedAt,
  });

  final String id;
  final String exerciseName;
  final double weightKilograms;
  final int reps;
  final double estimatedOneRepMax;
  final String protocol;
  final DateTime recordedAt;

  Map<String, Object> toJson() => {
    'id': id,
    'exerciseName': exerciseName,
    'weightKilograms': weightKilograms,
    'reps': reps,
    'estimatedOneRepMax': estimatedOneRepMax,
    'protocol': protocol,
    'recordedAt': recordedAt.toIso8601String(),
  };

  factory StrengthTestResult.fromJson(Map<String, dynamic> json) =>
      StrengthTestResult(
        id: json['id'] as String,
        exerciseName: json['exerciseName'] as String,
        weightKilograms: (json['weightKilograms'] as num).toDouble(),
        reps: json['reps'] as int,
        estimatedOneRepMax: (json['estimatedOneRepMax'] as num).toDouble(),
        protocol: json['protocol'] as String? ?? 'amrap',
        recordedAt: DateTime.parse(json['recordedAt'] as String),
      );
}

class HypertrophyCheckIn {
  const HypertrophyCheckIn({
    required this.id,
    required this.muscle,
    required this.pump,
    required this.disruption,
    required this.soreness,
    required this.recordedAt,
  });

  final String id;
  final String muscle;
  final int pump;
  final int disruption;
  final int soreness;
  final DateTime recordedAt;

  Map<String, Object> toJson() => {
    'id': id,
    'muscle': muscle,
    'pump': pump,
    'disruption': disruption,
    'soreness': soreness,
    'recordedAt': recordedAt.toIso8601String(),
  };

  factory HypertrophyCheckIn.fromJson(Map<String, dynamic> json) =>
      HypertrophyCheckIn(
        id: json['id'] as String,
        muscle: json['muscle'] as String,
        pump: json['pump'] as int,
        disruption: json['disruption'] as int,
        soreness: json['soreness'] as int,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
      );
}

class HypertrophyTechniqueLog {
  const HypertrophyTechniqueLog({
    required this.id,
    required this.technique,
    required this.exercise,
    required this.muscle,
    required this.weightKilograms,
    required this.activationReps,
    required this.miniSetReps,
    required this.recordedAt,
  });

  final String id;
  final String technique;
  final String exercise;
  final String muscle;
  final double weightKilograms;
  final int activationReps;
  final List<int> miniSetReps;
  final DateTime recordedAt;

  int get totalReps =>
      activationReps + miniSetReps.fold<int>(0, (sum, item) => sum + item);

  Map<String, Object> toJson() => {
    'id': id,
    'technique': technique,
    'exercise': exercise,
    'muscle': muscle,
    'weightKilograms': weightKilograms,
    'activationReps': activationReps,
    'miniSetReps': miniSetReps,
    'recordedAt': recordedAt.toIso8601String(),
  };

  factory HypertrophyTechniqueLog.fromJson(Map<String, dynamic> json) =>
      HypertrophyTechniqueLog(
        id: json['id'] as String,
        technique: json['technique'] as String,
        exercise: json['exercise'] as String,
        muscle: json['muscle'] as String,
        weightKilograms: (json['weightKilograms'] as num).toDouble(),
        activationReps: json['activationReps'] as int,
        miniSetReps: List<int>.from(json['miniSetReps'] as List? ?? const []),
        recordedAt: DateTime.parse(json['recordedAt'] as String),
      );
}

class CardioSessionLog {
  const CardioSessionLog({
    required this.id,
    required this.modality,
    required this.durationMinutes,
    required this.rpe,
    required this.averageHeartRate,
    required this.targetZone,
    required this.recordedAt,
    this.notes = '',
  });

  final String id;
  final String modality;
  final int durationMinutes;
  final int rpe;
  final int averageHeartRate;
  final int targetZone;
  final DateTime recordedAt;
  final String notes;

  int get sessionLoad => durationMinutes * rpe;

  Map<String, Object> toJson() => {
    'id': id,
    'modality': modality,
    'durationMinutes': durationMinutes,
    'rpe': rpe,
    'averageHeartRate': averageHeartRate,
    'targetZone': targetZone,
    'recordedAt': recordedAt.toIso8601String(),
    'notes': notes,
  };

  factory CardioSessionLog.fromJson(Map<String, dynamic> json) =>
      CardioSessionLog(
        id: json['id'] as String,
        modality: json['modality'] as String,
        durationMinutes: json['durationMinutes'] as int,
        rpe: json['rpe'] as int,
        averageHeartRate: json['averageHeartRate'] as int? ?? 0,
        targetZone: json['targetZone'] as int? ?? 0,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        notes: json['notes'] as String? ?? '',
      );
}

class ConditioningBenchmarkResult {
  const ConditioningBenchmarkResult({
    required this.id,
    required this.test,
    required this.value,
    required this.unit,
    required this.score,
    required this.label,
    required this.recordedAt,
  });

  final String id;
  final String test;
  final double value;
  final String unit;
  final double score;
  final String label;
  final DateTime recordedAt;

  Map<String, Object> toJson() => {
    'id': id,
    'test': test,
    'value': value,
    'unit': unit,
    'score': score,
    'label': label,
    'recordedAt': recordedAt.toIso8601String(),
  };

  factory ConditioningBenchmarkResult.fromJson(Map<String, dynamic> json) =>
      ConditioningBenchmarkResult(
        id: json['id'] as String,
        test: json['test'] as String,
        value: (json['value'] as num).toDouble(),
        unit: json['unit'] as String,
        score: (json['score'] as num).toDouble(),
        label: json['label'] as String,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
      );
}

class RunningSessionLog {
  const RunningSessionLog({
    required this.id,
    required this.distanceKilometers,
    required this.durationSeconds,
    required this.rpe,
    required this.surface,
    required this.elevationGainMeters,
    required this.cadenceStepsPerMinute,
    required this.shoeId,
    required this.recordedAt,
    this.notes = '',
  });

  final String id;
  final double distanceKilometers;
  final int durationSeconds;
  final int rpe;
  final String surface;
  final int elevationGainMeters;
  final int cadenceStepsPerMinute;
  final String shoeId;
  final DateTime recordedAt;
  final String notes;

  Map<String, Object> toJson() => {
    'id': id,
    'distanceKilometers': distanceKilometers,
    'durationSeconds': durationSeconds,
    'rpe': rpe,
    'surface': surface,
    'elevationGainMeters': elevationGainMeters,
    'cadenceStepsPerMinute': cadenceStepsPerMinute,
    'shoeId': shoeId,
    'recordedAt': recordedAt.toIso8601String(),
    'notes': notes,
  };

  factory RunningSessionLog.fromJson(Map<String, dynamic> json) =>
      RunningSessionLog(
        id: json['id'] as String,
        distanceKilometers: (json['distanceKilometers'] as num).toDouble(),
        durationSeconds: json['durationSeconds'] as int,
        rpe: json['rpe'] as int,
        surface: json['surface'] as String,
        elevationGainMeters: json['elevationGainMeters'] as int? ?? 0,
        cadenceStepsPerMinute: json['cadenceStepsPerMinute'] as int? ?? 0,
        shoeId: json['shoeId'] as String? ?? '',
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        notes: json['notes'] as String? ?? '',
      );
}

class RunningShoe {
  const RunningShoe({
    required this.id,
    required this.name,
    required this.startingKilometers,
    required this.retirementKilometers,
    required this.addedAt,
  });

  final String id;
  final String name;
  final double startingKilometers;
  final double retirementKilometers;
  final DateTime addedAt;

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'startingKilometers': startingKilometers,
    'retirementKilometers': retirementKilometers,
    'addedAt': addedAt.toIso8601String(),
  };

  factory RunningShoe.fromJson(Map<String, dynamic> json) => RunningShoe(
    id: json['id'] as String,
    name: json['name'] as String,
    startingKilometers: (json['startingKilometers'] as num? ?? 0).toDouble(),
    retirementKilometers: (json['retirementKilometers'] as num? ?? 700)
        .toDouble(),
    addedAt: DateTime.parse(json['addedAt'] as String),
  );
}

class CyclingSessionLog {
  const CyclingSessionLog({
    required this.id,
    required this.durationMinutes,
    required this.averagePowerWatts,
    required this.normalizedPowerWatts,
    required this.cadenceRpm,
    required this.rpe,
    required this.workoutType,
    required this.recordedAt,
    this.notes = '',
  });

  final String id;
  final int durationMinutes;
  final int averagePowerWatts;
  final int normalizedPowerWatts;
  final int cadenceRpm;
  final int rpe;
  final String workoutType;
  final DateTime recordedAt;
  final String notes;

  Map<String, Object> toJson() => {
    'id': id,
    'durationMinutes': durationMinutes,
    'averagePowerWatts': averagePowerWatts,
    'normalizedPowerWatts': normalizedPowerWatts,
    'cadenceRpm': cadenceRpm,
    'rpe': rpe,
    'workoutType': workoutType,
    'recordedAt': recordedAt.toIso8601String(),
    'notes': notes,
  };

  factory CyclingSessionLog.fromJson(Map<String, dynamic> json) =>
      CyclingSessionLog(
        id: json['id'] as String,
        durationMinutes: json['durationMinutes'] as int,
        averagePowerWatts: json['averagePowerWatts'] as int,
        normalizedPowerWatts: json['normalizedPowerWatts'] as int? ?? 0,
        cadenceRpm: json['cadenceRpm'] as int? ?? 0,
        rpe: json['rpe'] as int,
        workoutType: json['workoutType'] as String,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        notes: json['notes'] as String? ?? '',
      );
}

class RowingSessionLog {
  const RowingSessionLog({
    required this.id,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.strokeRate,
    required this.rpe,
    required this.benchmarkType,
    required this.recordedAt,
    this.notes = '',
  });

  final String id;
  final int distanceMeters;
  final int durationSeconds;
  final int strokeRate;
  final int rpe;
  final String benchmarkType;
  final DateTime recordedAt;
  final String notes;

  Map<String, Object> toJson() => {
    'id': id,
    'distanceMeters': distanceMeters,
    'durationSeconds': durationSeconds,
    'strokeRate': strokeRate,
    'rpe': rpe,
    'benchmarkType': benchmarkType,
    'recordedAt': recordedAt.toIso8601String(),
    'notes': notes,
  };

  factory RowingSessionLog.fromJson(Map<String, dynamic> json) =>
      RowingSessionLog(
        id: json['id'] as String,
        distanceMeters: json['distanceMeters'] as int,
        durationSeconds: json['durationSeconds'] as int,
        strokeRate: json['strokeRate'] as int? ?? 0,
        rpe: json['rpe'] as int,
        benchmarkType: json['benchmarkType'] as String? ?? 'Training',
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        notes: json['notes'] as String? ?? '',
      );
}

class CalisthenicsSkillLog {
  const CalisthenicsSkillLog({
    required this.id,
    required this.skillId,
    required this.progression,
    required this.holdSeconds,
    required this.repetitions,
    required this.quality,
    required this.rpe,
    required this.elbowPain,
    required this.straightArm,
    required this.recordedAt,
    this.notes = '',
  });

  final String id;
  final String skillId;
  final String progression;
  final int holdSeconds;
  final int repetitions;
  final int quality;
  final int rpe;
  final int elbowPain;
  final bool straightArm;
  final DateTime recordedAt;
  final String notes;

  Map<String, Object> toJson() => {
    'id': id,
    'skillId': skillId,
    'progression': progression,
    'holdSeconds': holdSeconds,
    'repetitions': repetitions,
    'quality': quality,
    'rpe': rpe,
    'elbowPain': elbowPain,
    'straightArm': straightArm,
    'recordedAt': recordedAt.toIso8601String(),
    'notes': notes,
  };

  factory CalisthenicsSkillLog.fromJson(Map<String, dynamic> json) =>
      CalisthenicsSkillLog(
        id: json['id'] as String,
        skillId: json['skillId'] as String,
        progression: json['progression'] as String,
        holdSeconds: json['holdSeconds'] as int? ?? 0,
        repetitions: json['repetitions'] as int? ?? 0,
        quality: json['quality'] as int,
        rpe: json['rpe'] as int,
        elbowPain: json['elbowPain'] as int? ?? 0,
        straightArm: json['straightArm'] as bool? ?? false,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        notes: json['notes'] as String? ?? '',
      );
}

class MobilityScreenLog {
  const MobilityScreenLog({
    required this.id,
    required this.jointId,
    required this.leftValue,
    required this.rightValue,
    required this.painLevel,
    required this.recordedAt,
    this.notes = '',
  });

  final String id;
  final String jointId;
  final double leftValue;
  final double rightValue;
  final int painLevel;
  final DateTime recordedAt;
  final String notes;

  Map<String, Object> toJson() => {
    'id': id,
    'jointId': jointId,
    'leftValue': leftValue,
    'rightValue': rightValue,
    'painLevel': painLevel,
    'recordedAt': recordedAt.toIso8601String(),
    'notes': notes,
  };

  factory MobilityScreenLog.fromJson(Map<String, dynamic> json) =>
      MobilityScreenLog(
        id: json['id'] as String,
        jointId: json['jointId'] as String,
        leftValue: (json['leftValue'] as num).toDouble(),
        rightValue: (json['rightValue'] as num).toDouble(),
        painLevel: json['painLevel'] as int? ?? 0,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        notes: json['notes'] as String? ?? '',
      );
}

class SkillAssessmentResult {
  const SkillAssessmentResult({
    required this.id,
    required this.skillId,
    required this.value,
    required this.unit,
    required this.level,
    required this.recordedAt,
  });

  final String id;
  final String skillId;
  final double value;
  final String unit;
  final int level;
  final DateTime recordedAt;

  Map<String, Object> toJson() => {
    'id': id,
    'skillId': skillId,
    'value': value,
    'unit': unit,
    'level': level,
    'recordedAt': recordedAt.toIso8601String(),
  };

  factory SkillAssessmentResult.fromJson(Map<String, dynamic> json) =>
      SkillAssessmentResult(
        id: json['id'] as String,
        skillId: json['skillId'] as String,
        value: (json['value'] as num).toDouble(),
        unit: json['unit'] as String,
        level: json['level'] as int,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
      );
}

class WeightEntry {
  const WeightEntry({required this.kilograms, required this.recordedAt});

  final double kilograms;
  final DateTime recordedAt;

  Map<String, Object> toJson() => {
    'kilograms': kilograms,
    'recordedAt': recordedAt.toIso8601String(),
  };

  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
    kilograms: (json['kilograms'] as num).toDouble(),
    recordedAt: DateTime.parse(json['recordedAt'] as String),
  );
}

class MealEntry {
  const MealEntry({
    required this.name,
    required this.calories,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    required this.loggedAt,
    this.fiberGrams = 0,
    this.sodiumMilligrams = 0,
    this.presetId = '',
    this.photoEncodedBytes = '',
  });

  final String name;
  final int calories;
  final double proteinGrams;
  final double carbohydrateGrams;
  final double fatGrams;
  final DateTime loggedAt;
  final double fiberGrams;
  final double sodiumMilligrams;
  final String presetId;
  final String photoEncodedBytes;

  Map<String, Object> toJson() => {
    'name': name,
    'calories': calories,
    'proteinGrams': proteinGrams,
    'carbohydrateGrams': carbohydrateGrams,
    'fatGrams': fatGrams,
    'loggedAt': loggedAt.toIso8601String(),
    'fiberGrams': fiberGrams,
    'sodiumMilligrams': sodiumMilligrams,
    'presetId': presetId,
    'photoEncodedBytes': photoEncodedBytes,
  };

  factory MealEntry.fromJson(Map<String, dynamic> json) => MealEntry(
    name: json['name'] as String,
    calories: json['calories'] as int,
    proteinGrams: (json['proteinGrams'] as num).toDouble(),
    carbohydrateGrams: (json['carbohydrateGrams'] as num).toDouble(),
    fatGrams: (json['fatGrams'] as num).toDouble(),
    loggedAt: DateTime.parse(json['loggedAt'] as String),
    fiberGrams: (json['fiberGrams'] as num? ?? 0).toDouble(),
    sodiumMilligrams: (json['sodiumMilligrams'] as num? ?? 0).toDouble(),
    presetId: json['presetId'] as String? ?? '',
    photoEncodedBytes: json['photoEncodedBytes'] as String? ?? '',
  );
}

class HydrationEntry {
  const HydrationEntry({required this.milliliters, required this.loggedAt});

  final int milliliters;
  final DateTime loggedAt;

  Map<String, Object> toJson() => {
    'milliliters': milliliters,
    'loggedAt': loggedAt.toIso8601String(),
  };

  factory HydrationEntry.fromJson(Map<String, dynamic> json) => HydrationEntry(
    milliliters: json['milliliters'] as int,
    loggedAt: DateTime.parse(json['loggedAt'] as String),
  );
}

class MealPreset {
  const MealPreset({
    required this.id,
    required this.name,
    required this.calories,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    this.fiberGrams = 0,
    this.sodiumMilligrams = 0,
    this.ingredients = const [],
  });

  final String id;
  final String name;
  final int calories;
  final double proteinGrams;
  final double carbohydrateGrams;
  final double fatGrams;
  final double fiberGrams;
  final double sodiumMilligrams;
  final List<String> ingredients;

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'calories': calories,
    'proteinGrams': proteinGrams,
    'carbohydrateGrams': carbohydrateGrams,
    'fatGrams': fatGrams,
    'fiberGrams': fiberGrams,
    'sodiumMilligrams': sodiumMilligrams,
    'ingredients': ingredients,
  };

  factory MealPreset.fromJson(Map<String, dynamic> json) => MealPreset(
    id: json['id'] as String,
    name: json['name'] as String,
    calories: json['calories'] as int,
    proteinGrams: (json['proteinGrams'] as num).toDouble(),
    carbohydrateGrams: (json['carbohydrateGrams'] as num).toDouble(),
    fatGrams: (json['fatGrams'] as num).toDouble(),
    fiberGrams: (json['fiberGrams'] as num? ?? 0).toDouble(),
    sodiumMilligrams: (json['sodiumMilligrams'] as num? ?? 0).toDouble(),
    ingredients: List<String>.from(json['ingredients'] as List? ?? const []),
  );
}

class RecoveryCheckIn {
  const RecoveryCheckIn({
    required this.sleepHours,
    required this.energy,
    required this.soreness,
    required this.stress,
    required this.recordedAt,
    this.sorenessAreas = const {},
    this.steps = 0,
    this.restingHeartRate = 0,
  });

  final double sleepHours;
  final int energy;
  final int soreness;
  final int stress;
  final DateTime recordedAt;
  final Map<String, int> sorenessAreas;
  final int steps;
  final int restingHeartRate;

  Map<String, Object> toJson() => {
    'sleepHours': sleepHours,
    'energy': energy,
    'soreness': soreness,
    'stress': stress,
    'recordedAt': recordedAt.toIso8601String(),
    'sorenessAreas': sorenessAreas,
    'steps': steps,
    'restingHeartRate': restingHeartRate,
  };

  factory RecoveryCheckIn.fromJson(Map<String, dynamic> json) =>
      RecoveryCheckIn(
        sleepHours: (json['sleepHours'] as num).toDouble(),
        energy: json['energy'] as int,
        soreness: json['soreness'] as int,
        stress: json['stress'] as int,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        sorenessAreas:
            (json['sorenessAreas'] as Map<String, dynamic>? ?? const {}).map(
              (key, value) => MapEntry(key, value as int),
            ),
        steps: json['steps'] as int? ?? 0,
        restingHeartRate: json['restingHeartRate'] as int? ?? 0,
      );
}

class RecoveryStatus {
  const RecoveryStatus({
    this.illnessMode = false,
    this.pausedUntil,
    this.returnStartedAt,
  });

  final bool illnessMode;
  final DateTime? pausedUntil;
  final DateTime? returnStartedAt;

  Map<String, Object?> toJson() => {
    'illnessMode': illnessMode,
    'pausedUntil': pausedUntil?.toIso8601String(),
    'returnStartedAt': returnStartedAt?.toIso8601String(),
  };

  factory RecoveryStatus.fromJson(Map<String, dynamic> json) => RecoveryStatus(
    illnessMode: json['illnessMode'] as bool? ?? false,
    pausedUntil: json['pausedUntil'] == null
        ? null
        : DateTime.parse(json['pausedUntil'] as String),
    returnStartedAt: json['returnStartedAt'] == null
        ? null
        : DateTime.parse(json['returnStartedAt'] as String),
  );
}

class AppPreferences {
  const AppPreferences({
    this.languageCode = 'el',
    this.highContrast = false,
    this.themePreset = 'iron',
    this.hapticFeedback = true,
    this.audioCues = false,
    this.audioCueStyle = 'minimal',
    this.countdownCueSeconds = 3,
    this.lockTimeoutMinutes = 5,
    this.vaultPinHash = '',
    this.textScale = 1,
    this.reducedMotion = false,
    this.colorVisionMode = 'standard',
    this.readabilityFont = false,
    this.oneHandMode = false,
    this.touchTargetScale = 1,
    this.voiceLabels = true,
  });

  final String languageCode;
  final bool highContrast;
  final String themePreset;
  final bool hapticFeedback;
  final bool audioCues;
  final String audioCueStyle;
  final int countdownCueSeconds;
  final int lockTimeoutMinutes;
  final String vaultPinHash;
  final double textScale;
  final bool reducedMotion;
  final String colorVisionMode;
  final bool readabilityFont;
  final bool oneHandMode;
  final double touchTargetScale;
  final bool voiceLabels;

  bool get hasVaultPin => vaultPinHash.isNotEmpty;

  AppPreferences copyWith({
    String? languageCode,
    bool? highContrast,
    String? themePreset,
    bool? hapticFeedback,
    bool? audioCues,
    String? audioCueStyle,
    int? countdownCueSeconds,
    int? lockTimeoutMinutes,
    String? vaultPinHash,
    double? textScale,
    bool? reducedMotion,
    String? colorVisionMode,
    bool? readabilityFont,
    bool? oneHandMode,
    double? touchTargetScale,
    bool? voiceLabels,
  }) => AppPreferences(
    languageCode: languageCode ?? this.languageCode,
    highContrast: highContrast ?? this.highContrast,
    themePreset: themePreset ?? this.themePreset,
    hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    audioCues: audioCues ?? this.audioCues,
    audioCueStyle: audioCueStyle ?? this.audioCueStyle,
    countdownCueSeconds: countdownCueSeconds ?? this.countdownCueSeconds,
    lockTimeoutMinutes: lockTimeoutMinutes ?? this.lockTimeoutMinutes,
    vaultPinHash: vaultPinHash ?? this.vaultPinHash,
    textScale: textScale ?? this.textScale,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    colorVisionMode: colorVisionMode ?? this.colorVisionMode,
    readabilityFont: readabilityFont ?? this.readabilityFont,
    oneHandMode: oneHandMode ?? this.oneHandMode,
    touchTargetScale: touchTargetScale ?? this.touchTargetScale,
    voiceLabels: voiceLabels ?? this.voiceLabels,
  );

  Map<String, Object> toJson() => {
    'languageCode': languageCode,
    'highContrast': highContrast,
    'themePreset': themePreset,
    'hapticFeedback': hapticFeedback,
    'audioCues': audioCues,
    'audioCueStyle': audioCueStyle,
    'countdownCueSeconds': countdownCueSeconds,
    'lockTimeoutMinutes': lockTimeoutMinutes,
    'vaultPinHash': vaultPinHash,
    'textScale': textScale,
    'reducedMotion': reducedMotion,
    'colorVisionMode': colorVisionMode,
    'readabilityFont': readabilityFont,
    'oneHandMode': oneHandMode,
    'touchTargetScale': touchTargetScale,
    'voiceLabels': voiceLabels,
  };

  factory AppPreferences.fromJson(Map<String, dynamic> json) => AppPreferences(
    languageCode: json['languageCode'] as String? ?? 'el',
    highContrast: json['highContrast'] as bool? ?? false,
    themePreset: json['themePreset'] as String? ?? 'iron',
    hapticFeedback: json['hapticFeedback'] as bool? ?? true,
    audioCues: json['audioCues'] as bool? ?? false,
    audioCueStyle: json['audioCueStyle'] as String? ?? 'minimal',
    countdownCueSeconds: json['countdownCueSeconds'] as int? ?? 3,
    lockTimeoutMinutes: json['lockTimeoutMinutes'] as int? ?? 5,
    vaultPinHash: json['vaultPinHash'] as String? ?? '',
    textScale: (json['textScale'] as num? ?? 1).toDouble().clamp(1, 1.6),
    reducedMotion: json['reducedMotion'] as bool? ?? false,
    colorVisionMode: json['colorVisionMode'] as String? ?? 'standard',
    readabilityFont: json['readabilityFont'] as bool? ?? false,
    oneHandMode: json['oneHandMode'] as bool? ?? false,
    touchTargetScale: (json['touchTargetScale'] as num? ?? 1).toDouble().clamp(
      1,
      1.5,
    ),
    voiceLabels: json['voiceLabels'] as bool? ?? true,
  );
}

class WorkoutReminder {
  const WorkoutReminder({
    required this.id,
    required this.weekday,
    required this.minutesSinceMidnight,
    this.templateId = '',
    this.enabled = true,
  });

  final String id;
  final int weekday;
  final int minutesSinceMidnight;
  final String templateId;
  final bool enabled;

  String get timeLabel =>
      '${(minutesSinceMidnight ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutesSinceMidnight % 60).toString().padLeft(2, '0')}';

  Map<String, Object> toJson() => {
    'id': id,
    'weekday': weekday,
    'minutesSinceMidnight': minutesSinceMidnight,
    'templateId': templateId,
    'enabled': enabled,
  };

  factory WorkoutReminder.fromJson(Map<String, dynamic> json) =>
      WorkoutReminder(
        id: json['id'] as String,
        weekday: json['weekday'] as int,
        minutesSinceMidnight: json['minutesSinceMidnight'] as int,
        templateId: json['templateId'] as String? ?? '',
        enabled: json['enabled'] as bool? ?? true,
      );
}

class ProgressPhoto {
  const ProgressPhoto({
    required this.id,
    required this.encodedBytes,
    required this.mimeType,
    required this.recordedAt,
    this.note = '',
    this.weightKilograms,
  });

  final String id;
  final String encodedBytes;
  final String mimeType;
  final DateTime recordedAt;
  final String note;
  final double? weightKilograms;

  Map<String, Object?> toJson() => {
    'id': id,
    'encodedBytes': encodedBytes,
    'mimeType': mimeType,
    'recordedAt': recordedAt.toIso8601String(),
    'note': note,
    'weightKilograms': weightKilograms,
  };

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) => ProgressPhoto(
    id: json['id'] as String,
    encodedBytes: json['encodedBytes'] as String,
    mimeType: json['mimeType'] as String? ?? 'image/jpeg',
    recordedAt: DateTime.parse(json['recordedAt'] as String),
    note: json['note'] as String? ?? '',
    weightKilograms: (json['weightKilograms'] as num?)?.toDouble(),
  );
}

class SpotifyAuthConfig {
  const SpotifyAuthConfig({
    this.clientId = '',
    this.redirectUri = '',
    this.pkceVerifier = '',
    this.pkceChallenge = '',
    this.configuredAt,
  });

  final String clientId;
  final String redirectUri;
  final String pkceVerifier;
  final String pkceChallenge;
  final DateTime? configuredAt;

  bool get isConfigured =>
      clientId.isNotEmpty &&
      redirectUri.isNotEmpty &&
      pkceVerifier.isNotEmpty &&
      pkceChallenge.isNotEmpty;

  Map<String, Object?> toJson() => {
    'clientId': clientId,
    'redirectUri': redirectUri,
    'pkceVerifier': pkceVerifier,
    'pkceChallenge': pkceChallenge,
    'configuredAt': configuredAt?.toIso8601String(),
  };

  factory SpotifyAuthConfig.fromJson(Map<String, dynamic> json) =>
      SpotifyAuthConfig(
        clientId: json['clientId'] as String? ?? '',
        redirectUri: json['redirectUri'] as String? ?? '',
        pkceVerifier: json['pkceVerifier'] as String? ?? '',
        pkceChallenge: json['pkceChallenge'] as String? ?? '',
        configuredAt: json['configuredAt'] == null
            ? null
            : DateTime.parse(json['configuredAt'] as String),
      );
}

class WearableDailySummary {
  const WearableDailySummary({
    required this.id,
    required this.day,
    required this.source,
    this.steps = 0,
    this.restingHeartRate = 0,
    this.sleepMinutes = 0,
  });

  final String id;
  final DateTime day;
  final String source;
  final int steps;
  final int restingHeartRate;
  final int sleepMinutes;

  Map<String, Object> toJson() => {
    'id': id,
    'day': day.toIso8601String(),
    'source': source,
    'steps': steps,
    'restingHeartRate': restingHeartRate,
    'sleepMinutes': sleepMinutes,
  };

  factory WearableDailySummary.fromJson(Map<String, dynamic> json) =>
      WearableDailySummary(
        id: json['id'] as String,
        day: DateTime.parse(json['day'] as String),
        source: json['source'] as String? ?? 'import',
        steps: json['steps'] as int? ?? 0,
        restingHeartRate: json['restingHeartRate'] as int? ?? 0,
        sleepMinutes: json['sleepMinutes'] as int? ?? 0,
      );
}

class CustomExerciseDefinition {
  const CustomExerciseDefinition({
    required this.id,
    required this.name,
    required this.primaryMuscles,
    required this.movementPattern,
    this.secondaryMuscles = const [],
    this.difficulty = 2,
    this.skillDemand = 2,
    this.equipment = const ['bodyweight'],
    this.cautionAreas = const [],
    this.regression = '',
    this.progression = '',
    this.notes = '',
  });

  final String id;
  final String name;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final String movementPattern;
  final int difficulty;
  final int skillDemand;
  final List<String> equipment;
  final List<String> cautionAreas;
  final String regression;
  final String progression;
  final String notes;

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'primaryMuscles': primaryMuscles,
    'secondaryMuscles': secondaryMuscles,
    'movementPattern': movementPattern,
    'difficulty': difficulty,
    'skillDemand': skillDemand,
    'equipment': equipment,
    'cautionAreas': cautionAreas,
    'regression': regression,
    'progression': progression,
    'notes': notes,
  };

  factory CustomExerciseDefinition.fromJson(Map<String, dynamic> json) =>
      CustomExerciseDefinition(
        id: json['id'] as String,
        name: json['name'] as String,
        primaryMuscles: (json['primaryMuscles'] as List? ?? const [])
            .map((item) => item as String)
            .toList(),
        secondaryMuscles: (json['secondaryMuscles'] as List? ?? const [])
            .map((item) => item as String)
            .toList(),
        movementPattern: json['movementPattern'] as String? ?? 'other',
        difficulty: (json['difficulty'] as int? ?? 2).clamp(1, 5),
        skillDemand: (json['skillDemand'] as int? ?? 2).clamp(1, 5),
        equipment: (json['equipment'] as List? ?? const ['bodyweight'])
            .map((item) => item as String)
            .toList(),
        cautionAreas: (json['cautionAreas'] as List? ?? const [])
            .map((item) => item as String)
            .toList(),
        regression: json['regression'] as String? ?? '',
        progression: json['progression'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
      );
}

class RecoveryInterventionLog {
  const RecoveryInterventionLog({
    required this.id,
    required this.intervention,
    required this.durationMinutes,
    required this.temperatureCelsius,
    required this.beforeScore,
    required this.afterScore,
    required this.recordedAt,
    this.notes = '',
  });

  final String id;
  final String intervention;
  final int durationMinutes;
  final double temperatureCelsius;
  final int beforeScore;
  final int afterScore;
  final DateTime recordedAt;
  final String notes;

  int get response => afterScore - beforeScore;

  Map<String, Object> toJson() => {
    'id': id,
    'intervention': intervention,
    'durationMinutes': durationMinutes,
    'temperatureCelsius': temperatureCelsius,
    'beforeScore': beforeScore,
    'afterScore': afterScore,
    'recordedAt': recordedAt.toIso8601String(),
    'notes': notes,
  };

  factory RecoveryInterventionLog.fromJson(Map<String, dynamic> json) =>
      RecoveryInterventionLog(
        id: json['id'] as String,
        intervention: json['intervention'] as String,
        durationMinutes: json['durationMinutes'] as int,
        temperatureCelsius: (json['temperatureCelsius'] as num? ?? 0)
            .toDouble(),
        beforeScore: json['beforeScore'] as int,
        afterScore: json['afterScore'] as int,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        notes: json['notes'] as String? ?? '',
      );
}

class NutritionPhaseLog {
  const NutritionPhaseLog({
    required this.id,
    required this.phase,
    required this.dailyCalories,
    required this.durationWeeks,
    required this.targetWeeklyChangePercent,
    required this.startedAt,
    required this.recordedAt,
  });

  final String id;
  final String phase;
  final int dailyCalories;
  final int durationWeeks;
  final double targetWeeklyChangePercent;
  final DateTime startedAt;
  final DateTime recordedAt;

  Map<String, Object> toJson() => {
    'id': id,
    'phase': phase,
    'dailyCalories': dailyCalories,
    'durationWeeks': durationWeeks,
    'targetWeeklyChangePercent': targetWeeklyChangePercent,
    'startedAt': startedAt.toIso8601String(),
    'recordedAt': recordedAt.toIso8601String(),
  };

  factory NutritionPhaseLog.fromJson(Map<String, dynamic> json) =>
      NutritionPhaseLog(
        id: json['id'] as String,
        phase: json['phase'] as String,
        dailyCalories: json['dailyCalories'] as int,
        durationWeeks: json['durationWeeks'] as int,
        targetWeeklyChangePercent: (json['targetWeeklyChangePercent'] as num)
            .toDouble(),
        startedAt: DateTime.parse(json['startedAt'] as String),
        recordedAt: DateTime.parse(json['recordedAt'] as String),
      );
}

class PantryItem {
  const PantryItem({
    required this.id,
    required this.ingredientId,
    required this.name,
    required this.quantityGrams,
    required this.costPer100Grams,
    required this.updatedAt,
    this.expiresAt,
  });

  final String id;
  final String ingredientId;
  final String name;
  final double quantityGrams;
  final double costPer100Grams;
  final DateTime updatedAt;
  final DateTime? expiresAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'ingredientId': ingredientId,
    'name': name,
    'quantityGrams': quantityGrams,
    'costPer100Grams': costPer100Grams,
    'updatedAt': updatedAt.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
  };

  factory PantryItem.fromJson(Map<String, dynamic> json) => PantryItem(
    id: json['id'] as String,
    ingredientId: json['ingredientId'] as String,
    name: json['name'] as String,
    quantityGrams: (json['quantityGrams'] as num).toDouble(),
    costPer100Grams: (json['costPer100Grams'] as num? ?? 0).toDouble(),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    expiresAt: json['expiresAt'] == null
        ? null
        : DateTime.parse(json['expiresAt'] as String),
  );
}

class BodyMeasurementLog {
  const BodyMeasurementLog({
    required this.id,
    required this.weightKilograms,
    required this.waistCentimeters,
    required this.neckCentimeters,
    required this.chestCentimeters,
    required this.hipsCentimeters,
    required this.upperArmCentimeters,
    required this.thighCentimeters,
    required this.recordedAt,
    this.notes = '',
  });

  final String id;
  final double weightKilograms;
  final double waistCentimeters;
  final double neckCentimeters;
  final double chestCentimeters;
  final double hipsCentimeters;
  final double upperArmCentimeters;
  final double thighCentimeters;
  final DateTime recordedAt;
  final String notes;

  Map<String, Object> toJson() => {
    'id': id,
    'weightKilograms': weightKilograms,
    'waistCentimeters': waistCentimeters,
    'neckCentimeters': neckCentimeters,
    'chestCentimeters': chestCentimeters,
    'hipsCentimeters': hipsCentimeters,
    'upperArmCentimeters': upperArmCentimeters,
    'thighCentimeters': thighCentimeters,
    'recordedAt': recordedAt.toIso8601String(),
    'notes': notes,
  };

  factory BodyMeasurementLog.fromJson(Map<String, dynamic> json) =>
      BodyMeasurementLog(
        id: json['id'] as String,
        weightKilograms: (json['weightKilograms'] as num).toDouble(),
        waistCentimeters: (json['waistCentimeters'] as num? ?? 0).toDouble(),
        neckCentimeters: (json['neckCentimeters'] as num? ?? 0).toDouble(),
        chestCentimeters: (json['chestCentimeters'] as num? ?? 0).toDouble(),
        hipsCentimeters: (json['hipsCentimeters'] as num? ?? 0).toDouble(),
        upperArmCentimeters: (json['upperArmCentimeters'] as num? ?? 0)
            .toDouble(),
        thighCentimeters: (json['thighCentimeters'] as num? ?? 0).toDouble(),
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        notes: json['notes'] as String? ?? '',
      );
}

class HealthHabit {
  const HealthHabit({
    required this.id,
    required this.name,
    required this.category,
    required this.targetDaysPerWeek,
    required this.minimumVersion,
    required this.stackAfter,
    required this.preferredMinutesSinceMidnight,
    required this.createdAt,
    this.active = true,
  });

  final String id;
  final String name;
  final String category;
  final int targetDaysPerWeek;
  final String minimumVersion;
  final String stackAfter;
  final int preferredMinutesSinceMidnight;
  final DateTime createdAt;
  final bool active;

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'targetDaysPerWeek': targetDaysPerWeek,
    'minimumVersion': minimumVersion,
    'stackAfter': stackAfter,
    'preferredMinutesSinceMidnight': preferredMinutesSinceMidnight,
    'createdAt': createdAt.toIso8601String(),
    'active': active,
  };

  factory HealthHabit.fromJson(Map<String, dynamic> json) => HealthHabit(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    targetDaysPerWeek: json['targetDaysPerWeek'] as int,
    minimumVersion: json['minimumVersion'] as String? ?? '',
    stackAfter: json['stackAfter'] as String? ?? '',
    preferredMinutesSinceMidnight:
        json['preferredMinutesSinceMidnight'] as int? ?? 1080,
    createdAt: DateTime.parse(json['createdAt'] as String),
    active: json['active'] as bool? ?? true,
  );

  HealthHabit copyWith({
    String? name,
    String? category,
    int? targetDaysPerWeek,
    String? minimumVersion,
    String? stackAfter,
    int? preferredMinutesSinceMidnight,
    bool? active,
  }) => HealthHabit(
    id: id,
    name: name ?? this.name,
    category: category ?? this.category,
    targetDaysPerWeek: targetDaysPerWeek ?? this.targetDaysPerWeek,
    minimumVersion: minimumVersion ?? this.minimumVersion,
    stackAfter: stackAfter ?? this.stackAfter,
    preferredMinutesSinceMidnight:
        preferredMinutesSinceMidnight ?? this.preferredMinutesSinceMidnight,
    createdAt: createdAt,
    active: active ?? this.active,
  );
}

class HabitCheckIn {
  const HabitCheckIn({
    required this.id,
    required this.habitId,
    required this.day,
    required this.completed,
    required this.usedMinimum,
    required this.frictionLevel,
    required this.reflection,
    required this.recordedAt,
  });

  final String id;
  final String habitId;
  final DateTime day;
  final bool completed;
  final bool usedMinimum;
  final int frictionLevel;
  final String reflection;
  final DateTime recordedAt;

  Map<String, Object> toJson() => {
    'id': id,
    'habitId': habitId,
    'day': day.toIso8601String(),
    'completed': completed,
    'usedMinimum': usedMinimum,
    'frictionLevel': frictionLevel,
    'reflection': reflection,
    'recordedAt': recordedAt.toIso8601String(),
  };

  factory HabitCheckIn.fromJson(Map<String, dynamic> json) => HabitCheckIn(
    id: json['id'] as String,
    habitId: json['habitId'] as String,
    day: DateTime.parse(json['day'] as String),
    completed: json['completed'] as bool? ?? false,
    usedMinimum: json['usedMinimum'] as bool? ?? false,
    frictionLevel: json['frictionLevel'] as int? ?? 0,
    reflection: json['reflection'] as String? ?? '',
    recordedAt: DateTime.parse(json['recordedAt'] as String),
  );
}

class SleepRoutineLog {
  const SleepRoutineLog({
    required this.id,
    required this.day,
    required this.bedtimeMinutes,
    required this.wakeMinutes,
    required this.lastCaffeineMinutes,
    required this.screenFreeMinutes,
    required this.windDownSteps,
    required this.recordedAt,
  });

  final String id;
  final DateTime day;
  final int bedtimeMinutes;
  final int wakeMinutes;
  final int lastCaffeineMinutes;
  final int screenFreeMinutes;
  final List<String> windDownSteps;
  final DateTime recordedAt;

  Map<String, Object> toJson() => {
    'id': id,
    'day': day.toIso8601String(),
    'bedtimeMinutes': bedtimeMinutes,
    'wakeMinutes': wakeMinutes,
    'lastCaffeineMinutes': lastCaffeineMinutes,
    'screenFreeMinutes': screenFreeMinutes,
    'windDownSteps': windDownSteps,
    'recordedAt': recordedAt.toIso8601String(),
  };

  factory SleepRoutineLog.fromJson(Map<String, dynamic> json) =>
      SleepRoutineLog(
        id: json['id'] as String,
        day: DateTime.parse(json['day'] as String),
        bedtimeMinutes: json['bedtimeMinutes'] as int,
        wakeMinutes: json['wakeMinutes'] as int,
        lastCaffeineMinutes: json['lastCaffeineMinutes'] as int? ?? 840,
        screenFreeMinutes: json['screenFreeMinutes'] as int? ?? 0,
        windDownSteps: List<String>.from(
          json['windDownSteps'] as List? ?? const [],
        ),
        recordedAt: DateTime.parse(json['recordedAt'] as String),
      );
}

class StressCheckInLog {
  const StressCheckInLog({
    required this.id,
    required this.level,
    required this.context,
    required this.recordedAt,
  });

  final String id;
  final int level;
  final String context;
  final DateTime recordedAt;

  Map<String, Object> toJson() => {
    'id': id,
    'level': level,
    'context': context,
    'recordedAt': recordedAt.toIso8601String(),
  };

  factory StressCheckInLog.fromJson(Map<String, dynamic> json) =>
      StressCheckInLog(
        id: json['id'] as String,
        level: json['level'] as int,
        context: json['context'] as String? ?? '',
        recordedAt: DateTime.parse(json['recordedAt'] as String),
      );
}

class CoachRecommendationFeedback {
  const CoachRecommendationFeedback({
    required this.id,
    required this.recommendationId,
    required this.accepted,
    required this.helpful,
    required this.note,
    required this.recordedAt,
  });

  final String id;
  final String recommendationId;
  final bool accepted;
  final bool helpful;
  final String note;
  final DateTime recordedAt;

  Map<String, Object> toJson() => {
    'id': id,
    'recommendationId': recommendationId,
    'accepted': accepted,
    'helpful': helpful,
    'note': note,
    'recordedAt': recordedAt.toIso8601String(),
  };

  factory CoachRecommendationFeedback.fromJson(Map<String, dynamic> json) =>
      CoachRecommendationFeedback(
        id: json['id'] as String,
        recommendationId: json['recommendationId'] as String,
        accepted: json['accepted'] as bool? ?? false,
        helpful: json['helpful'] as bool? ?? false,
        note: json['note'] as String? ?? '',
        recordedAt: DateTime.parse(json['recordedAt'] as String),
      );
}

class AnalyticsAnnotation {
  const AnalyticsAnnotation({
    required this.id,
    required this.date,
    required this.category,
    required this.label,
    required this.note,
    required this.recordedAt,
  });

  final String id;
  final DateTime date;
  final String category;
  final String label;
  final String note;
  final DateTime recordedAt;

  Map<String, Object> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'label': label,
    'note': note,
    'recordedAt': recordedAt.toIso8601String(),
  };

  factory AnalyticsAnnotation.fromJson(Map<String, dynamic> json) =>
      AnalyticsAnnotation(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        category: json['category'] as String,
        label: json['label'] as String,
        note: json['note'] as String? ?? '',
        recordedAt: DateTime.parse(json['recordedAt'] as String),
      );
}

class UserProfile {
  const UserProfile({
    required this.goal,
    required this.trainingPlace,
    required this.equipment,
    required this.daysPerWeek,
    required this.heightCentimeters,
    required this.weightKilograms,
    this.age,
    this.experienceLevel = 'Αρχάριος',
    this.sessionMinutes = 45,
    this.limitations = '',
  });

  final String goal;
  final String trainingPlace;
  final String equipment;
  final int daysPerWeek;
  final int heightCentimeters;
  final double weightKilograms;
  final int? age;
  final String experienceLevel;
  final int sessionMinutes;
  final String limitations;

  Map<String, Object?> toJson() => {
    'goal': goal,
    'trainingPlace': trainingPlace,
    'equipment': equipment,
    'daysPerWeek': daysPerWeek,
    'heightCentimeters': heightCentimeters,
    'weightKilograms': weightKilograms,
    'age': age,
    'experienceLevel': experienceLevel,
    'sessionMinutes': sessionMinutes,
    'limitations': limitations,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    goal: json['goal'] as String,
    trainingPlace: json['trainingPlace'] as String,
    equipment: json['equipment'] as String,
    daysPerWeek: json['daysPerWeek'] as int,
    heightCentimeters: json['heightCentimeters'] as int,
    weightKilograms: (json['weightKilograms'] as num).toDouble(),
    age: json['age'] as int?,
    experienceLevel: json['experienceLevel'] as String? ?? 'Αρχάριος',
    sessionMinutes: json['sessionMinutes'] as int? ?? 45,
    limitations: json['limitations'] as String? ?? '',
  );
}

class CapabilityState {
  const CapabilityState({
    required this.capabilityId,
    this.enabled = true,
    this.guardLevel = 50,
    this.mode = 'balanced',
    this.note = '',
    this.runCount = 0,
    this.lastResult = '',
    this.updatedAt,
  });

  final int capabilityId;
  final bool enabled;
  final int guardLevel;
  final String mode;
  final String note;
  final int runCount;
  final String lastResult;
  final DateTime? updatedAt;

  Map<String, Object?> toJson() => {
    'capabilityId': capabilityId,
    'enabled': enabled,
    'guardLevel': guardLevel,
    'mode': mode,
    'note': note,
    'runCount': runCount,
    'lastResult': lastResult,
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory CapabilityState.fromJson(Map<String, dynamic> json) =>
      CapabilityState(
        capabilityId: json['capabilityId'] as int,
        enabled: json['enabled'] as bool? ?? true,
        guardLevel: (json['guardLevel'] as int? ?? 50).clamp(0, 100),
        mode: json['mode'] as String? ?? 'balanced',
        note: json['note'] as String? ?? '',
        runCount: (json['runCount'] as int? ?? 0).clamp(0, 1000000),
        lastResult: json['lastResult'] as String? ?? '',
        updatedAt: json['updatedAt'] == null
            ? null
            : DateTime.tryParse(json['updatedAt'] as String),
      );

  CapabilityState copyWith({
    bool? enabled,
    int? guardLevel,
    String? mode,
    String? note,
    int? runCount,
    String? lastResult,
    DateTime? updatedAt,
  }) => CapabilityState(
    capabilityId: capabilityId,
    enabled: enabled ?? this.enabled,
    guardLevel: guardLevel ?? this.guardLevel,
    mode: mode ?? this.mode,
    note: note ?? this.note,
    runCount: runCount ?? this.runCount,
    lastResult: lastResult ?? this.lastResult,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

class FitnessData {
  const FitnessData({
    required this.profile,
    required this.templates,
    required this.logs,
    required this.weights,
    required this.meals,
    required this.spotifyUrl,
    this.recoveryChecks = const [],
    this.weeklyAssignments = const {},
    this.programVersions = const [],
    this.hydration = const [],
    this.mealPresets = const [],
    this.recoveryStatus = const RecoveryStatus(),
    this.preferences = const AppPreferences(),
    this.dateAssignments = const {},
    this.strengthTests = const [],
    this.skillAssessments = const [],
    this.progressPhotos = const [],
    this.workoutPlaylists = const {},
    this.exerciseVideoUrls = const {},
    this.spotifyAuth = const SpotifyAuthConfig(),
    this.wearableSummaries = const [],
    this.workoutReminders = const [],
    this.customExercises = const [],
    this.strengthTrainingMaxes = const {},
    this.hypertrophyCheckIns = const [],
    this.hypertrophyTechniqueLogs = const [],
    this.cardioSessions = const [],
    this.conditioningBenchmarks = const [],
    this.runningSessions = const [],
    this.runningShoes = const [],
    this.cyclingSessions = const [],
    this.rowingSessions = const [],
    this.calisthenicsSkillLogs = const [],
    this.mobilityScreenLogs = const [],
    this.recoveryInterventions = const [],
    this.nutritionPhaseLogs = const [],
    this.pantryItems = const [],
    this.favoriteIngredientIds = const [],
    this.bodyMeasurementLogs = const [],
    this.healthHabits = const [],
    this.habitCheckIns = const [],
    this.sleepRoutineLogs = const [],
    this.stressCheckInLogs = const [],
    this.coachRecommendationFeedback = const [],
    this.analyticsDashboardMetrics = const [
      'sessions',
      'volume',
      'readiness',
      'bodyweight',
    ],
    this.analyticsAnnotations = const [],
    this.capabilityStates = const [],
  });

  final UserProfile? profile;
  final List<WorkoutTemplate> templates;
  final List<WorkoutLog> logs;
  final List<WeightEntry> weights;
  final List<MealEntry> meals;
  final String spotifyUrl;
  final List<RecoveryCheckIn> recoveryChecks;
  final Map<String, String> weeklyAssignments;
  final List<ProgramVersion> programVersions;
  final List<HydrationEntry> hydration;
  final List<MealPreset> mealPresets;
  final RecoveryStatus recoveryStatus;
  final AppPreferences preferences;
  final Map<String, String> dateAssignments;
  final List<StrengthTestResult> strengthTests;
  final List<SkillAssessmentResult> skillAssessments;
  final List<ProgressPhoto> progressPhotos;
  final Map<String, String> workoutPlaylists;
  final Map<String, String> exerciseVideoUrls;
  final SpotifyAuthConfig spotifyAuth;
  final List<WearableDailySummary> wearableSummaries;
  final List<WorkoutReminder> workoutReminders;
  final List<CustomExerciseDefinition> customExercises;
  final Map<String, double> strengthTrainingMaxes;
  final List<HypertrophyCheckIn> hypertrophyCheckIns;
  final List<HypertrophyTechniqueLog> hypertrophyTechniqueLogs;
  final List<CardioSessionLog> cardioSessions;
  final List<ConditioningBenchmarkResult> conditioningBenchmarks;
  final List<RunningSessionLog> runningSessions;
  final List<RunningShoe> runningShoes;
  final List<CyclingSessionLog> cyclingSessions;
  final List<RowingSessionLog> rowingSessions;
  final List<CalisthenicsSkillLog> calisthenicsSkillLogs;
  final List<MobilityScreenLog> mobilityScreenLogs;
  final List<RecoveryInterventionLog> recoveryInterventions;
  final List<NutritionPhaseLog> nutritionPhaseLogs;
  final List<PantryItem> pantryItems;
  final List<String> favoriteIngredientIds;
  final List<BodyMeasurementLog> bodyMeasurementLogs;
  final List<HealthHabit> healthHabits;
  final List<HabitCheckIn> habitCheckIns;
  final List<SleepRoutineLog> sleepRoutineLogs;
  final List<StressCheckInLog> stressCheckInLogs;
  final List<CoachRecommendationFeedback> coachRecommendationFeedback;
  final List<String> analyticsDashboardMetrics;
  final List<AnalyticsAnnotation> analyticsAnnotations;
  final List<CapabilityState> capabilityStates;

  Map<String, Object?> toJson() => {
    'profile': profile?.toJson(),
    'templates': templates.map((item) => item.toJson()).toList(),
    'logs': logs.map((item) => item.toJson()).toList(),
    'weights': weights.map((item) => item.toJson()).toList(),
    'meals': meals.map((item) => item.toJson()).toList(),
    'spotifyUrl': spotifyUrl,
    'recoveryChecks': recoveryChecks.map((item) => item.toJson()).toList(),
    'weeklyAssignments': weeklyAssignments,
    'programVersions': programVersions.map((item) => item.toJson()).toList(),
    'hydration': hydration.map((item) => item.toJson()).toList(),
    'mealPresets': mealPresets.map((item) => item.toJson()).toList(),
    'recoveryStatus': recoveryStatus.toJson(),
    'preferences': preferences.toJson(),
    'dateAssignments': dateAssignments,
    'strengthTests': strengthTests.map((item) => item.toJson()).toList(),
    'skillAssessments': skillAssessments.map((item) => item.toJson()).toList(),
    'progressPhotos': progressPhotos.map((item) => item.toJson()).toList(),
    'workoutPlaylists': workoutPlaylists,
    'exerciseVideoUrls': exerciseVideoUrls,
    'spotifyAuth': spotifyAuth.toJson(),
    'wearableSummaries': wearableSummaries
        .map((item) => item.toJson())
        .toList(),
    'workoutReminders': workoutReminders.map((item) => item.toJson()).toList(),
    'customExercises': customExercises.map((item) => item.toJson()).toList(),
    'strengthTrainingMaxes': strengthTrainingMaxes,
    'hypertrophyCheckIns': hypertrophyCheckIns
        .map((item) => item.toJson())
        .toList(),
    'hypertrophyTechniqueLogs': hypertrophyTechniqueLogs
        .map((item) => item.toJson())
        .toList(),
    'cardioSessions': cardioSessions.map((item) => item.toJson()).toList(),
    'conditioningBenchmarks': conditioningBenchmarks
        .map((item) => item.toJson())
        .toList(),
    'runningSessions': runningSessions.map((item) => item.toJson()).toList(),
    'runningShoes': runningShoes.map((item) => item.toJson()).toList(),
    'cyclingSessions': cyclingSessions.map((item) => item.toJson()).toList(),
    'rowingSessions': rowingSessions.map((item) => item.toJson()).toList(),
    'calisthenicsSkillLogs': calisthenicsSkillLogs
        .map((item) => item.toJson())
        .toList(),
    'mobilityScreenLogs': mobilityScreenLogs
        .map((item) => item.toJson())
        .toList(),
    'recoveryInterventions': recoveryInterventions
        .map((item) => item.toJson())
        .toList(),
    'nutritionPhaseLogs': nutritionPhaseLogs
        .map((item) => item.toJson())
        .toList(),
    'pantryItems': pantryItems.map((item) => item.toJson()).toList(),
    'favoriteIngredientIds': favoriteIngredientIds,
    'bodyMeasurementLogs': bodyMeasurementLogs
        .map((item) => item.toJson())
        .toList(),
    'healthHabits': healthHabits.map((item) => item.toJson()).toList(),
    'habitCheckIns': habitCheckIns.map((item) => item.toJson()).toList(),
    'sleepRoutineLogs': sleepRoutineLogs.map((item) => item.toJson()).toList(),
    'stressCheckInLogs': stressCheckInLogs
        .map((item) => item.toJson())
        .toList(),
    'coachRecommendationFeedback': coachRecommendationFeedback
        .map((item) => item.toJson())
        .toList(),
    'analyticsDashboardMetrics': analyticsDashboardMetrics,
    'analyticsAnnotations': analyticsAnnotations
        .map((item) => item.toJson())
        .toList(),
    'capabilityStates': capabilityStates.map((item) => item.toJson()).toList(),
  };

  factory FitnessData.fromJson(Map<String, dynamic> json) {
    final defaultPresets = FitnessData.initial().mealPresets;
    return FitnessData(
      profile: json['profile'] == null
          ? null
          : UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
      templates: (json['templates'] as List? ?? const [])
          .map((item) => WorkoutTemplate.fromJson(item as Map<String, dynamic>))
          .toList(),
      logs: (json['logs'] as List? ?? const [])
          .map((item) => WorkoutLog.fromJson(item as Map<String, dynamic>))
          .toList(),
      weights: (json['weights'] as List? ?? const [])
          .map((item) => WeightEntry.fromJson(item as Map<String, dynamic>))
          .toList(),
      meals: (json['meals'] as List? ?? const [])
          .map((item) => MealEntry.fromJson(item as Map<String, dynamic>))
          .toList(),
      spotifyUrl: json['spotifyUrl'] as String? ?? '',
      recoveryChecks: (json['recoveryChecks'] as List? ?? const [])
          .map((item) => RecoveryCheckIn.fromJson(item as Map<String, dynamic>))
          .toList(),
      weeklyAssignments:
          (json['weeklyAssignments'] as Map<String, dynamic>? ?? const {}).map(
            (key, value) => MapEntry(key, value as String),
          ),
      programVersions: (json['programVersions'] as List? ?? const [])
          .map((item) => ProgramVersion.fromJson(item as Map<String, dynamic>))
          .toList(),
      hydration: (json['hydration'] as List? ?? const [])
          .map((item) => HydrationEntry.fromJson(item as Map<String, dynamic>))
          .toList(),
      mealPresets:
          (json.containsKey('mealPresets')
                  ? json['mealPresets'] as List? ?? const []
                  : defaultPresets)
              .map(
                (item) => item is MealPreset
                    ? item
                    : MealPreset.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      recoveryStatus: json['recoveryStatus'] == null
          ? const RecoveryStatus()
          : RecoveryStatus.fromJson(
              json['recoveryStatus'] as Map<String, dynamic>,
            ),
      preferences: json['preferences'] == null
          ? const AppPreferences()
          : AppPreferences.fromJson(
              json['preferences'] as Map<String, dynamic>,
            ),
      dateAssignments:
          (json['dateAssignments'] as Map<String, dynamic>? ?? const {}).map(
            (key, value) => MapEntry(key, value as String),
          ),
      strengthTests: (json['strengthTests'] as List? ?? const [])
          .map(
            (item) => StrengthTestResult.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      skillAssessments: (json['skillAssessments'] as List? ?? const [])
          .map(
            (item) =>
                SkillAssessmentResult.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      progressPhotos: (json['progressPhotos'] as List? ?? const [])
          .map((item) => ProgressPhoto.fromJson(item as Map<String, dynamic>))
          .toList(),
      workoutPlaylists:
          (json['workoutPlaylists'] as Map<String, dynamic>? ?? const {}).map(
            (key, value) => MapEntry(key, value as String),
          ),
      exerciseVideoUrls:
          (json['exerciseVideoUrls'] as Map<String, dynamic>? ?? const {}).map(
            (key, value) => MapEntry(key, value as String),
          ),
      spotifyAuth: json['spotifyAuth'] == null
          ? const SpotifyAuthConfig()
          : SpotifyAuthConfig.fromJson(
              json['spotifyAuth'] as Map<String, dynamic>,
            ),
      wearableSummaries: (json['wearableSummaries'] as List? ?? const [])
          .map(
            (item) =>
                WearableDailySummary.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      workoutReminders: (json['workoutReminders'] as List? ?? const [])
          .map((item) => WorkoutReminder.fromJson(item as Map<String, dynamic>))
          .toList(),
      customExercises: (json['customExercises'] as List? ?? const [])
          .map(
            (item) =>
                CustomExerciseDefinition.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      strengthTrainingMaxes:
          (json['strengthTrainingMaxes'] as Map<String, dynamic>? ?? const {})
              .map((key, value) => MapEntry(key, (value as num).toDouble())),
      hypertrophyCheckIns: (json['hypertrophyCheckIns'] as List? ?? const [])
          .map(
            (item) => HypertrophyCheckIn.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      hypertrophyTechniqueLogs:
          (json['hypertrophyTechniqueLogs'] as List? ?? const [])
              .map(
                (item) => HypertrophyTechniqueLog.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
      cardioSessions: (json['cardioSessions'] as List? ?? const [])
          .map(
            (item) => CardioSessionLog.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      conditioningBenchmarks:
          (json['conditioningBenchmarks'] as List? ?? const [])
              .map(
                (item) => ConditioningBenchmarkResult.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
      runningSessions: (json['runningSessions'] as List? ?? const [])
          .map(
            (item) => RunningSessionLog.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      runningShoes: (json['runningShoes'] as List? ?? const [])
          .map((item) => RunningShoe.fromJson(item as Map<String, dynamic>))
          .toList(),
      cyclingSessions: (json['cyclingSessions'] as List? ?? const [])
          .map(
            (item) => CyclingSessionLog.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      rowingSessions: (json['rowingSessions'] as List? ?? const [])
          .map(
            (item) => RowingSessionLog.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      calisthenicsSkillLogs:
          (json['calisthenicsSkillLogs'] as List? ?? const [])
              .map(
                (item) =>
                    CalisthenicsSkillLog.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      mobilityScreenLogs: (json['mobilityScreenLogs'] as List? ?? const [])
          .map(
            (item) => MobilityScreenLog.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      recoveryInterventions:
          (json['recoveryInterventions'] as List? ?? const [])
              .map(
                (item) => RecoveryInterventionLog.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
      nutritionPhaseLogs: (json['nutritionPhaseLogs'] as List? ?? const [])
          .map(
            (item) => NutritionPhaseLog.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      pantryItems: (json['pantryItems'] as List? ?? const [])
          .map((item) => PantryItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      favoriteIngredientIds: List<String>.from(
        json['favoriteIngredientIds'] as List? ?? const [],
      ),
      bodyMeasurementLogs: (json['bodyMeasurementLogs'] as List? ?? const [])
          .map(
            (item) => BodyMeasurementLog.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      healthHabits: (json['healthHabits'] as List? ?? const [])
          .map((item) => HealthHabit.fromJson(item as Map<String, dynamic>))
          .toList(),
      habitCheckIns: (json['habitCheckIns'] as List? ?? const [])
          .map((item) => HabitCheckIn.fromJson(item as Map<String, dynamic>))
          .toList(),
      sleepRoutineLogs: (json['sleepRoutineLogs'] as List? ?? const [])
          .map((item) => SleepRoutineLog.fromJson(item as Map<String, dynamic>))
          .toList(),
      stressCheckInLogs: (json['stressCheckInLogs'] as List? ?? const [])
          .map(
            (item) => StressCheckInLog.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      coachRecommendationFeedback:
          (json['coachRecommendationFeedback'] as List? ?? const [])
              .map(
                (item) => CoachRecommendationFeedback.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
      analyticsDashboardMetrics: List<String>.from(
        json['analyticsDashboardMetrics'] as List? ??
            const ['sessions', 'volume', 'readiness', 'bodyweight'],
      ),
      analyticsAnnotations: (json['analyticsAnnotations'] as List? ?? const [])
          .map(
            (item) =>
                AnalyticsAnnotation.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      capabilityStates: (json['capabilityStates'] as List? ?? const [])
          .map((item) => CapabilityState.fromJson(item as Map<String, dynamic>))
          .where((item) => item.capabilityId >= 279 && item.capabilityId <= 567)
          .toList(),
    );
  }

  FitnessData copyWith({
    UserProfile? profile,
    bool clearProfile = false,
    List<WorkoutTemplate>? templates,
    List<WorkoutLog>? logs,
    List<WeightEntry>? weights,
    List<MealEntry>? meals,
    String? spotifyUrl,
    List<RecoveryCheckIn>? recoveryChecks,
    Map<String, String>? weeklyAssignments,
    List<ProgramVersion>? programVersions,
    List<HydrationEntry>? hydration,
    List<MealPreset>? mealPresets,
    RecoveryStatus? recoveryStatus,
    AppPreferences? preferences,
    Map<String, String>? dateAssignments,
    List<StrengthTestResult>? strengthTests,
    List<SkillAssessmentResult>? skillAssessments,
    List<ProgressPhoto>? progressPhotos,
    Map<String, String>? workoutPlaylists,
    Map<String, String>? exerciseVideoUrls,
    SpotifyAuthConfig? spotifyAuth,
    List<WearableDailySummary>? wearableSummaries,
    List<WorkoutReminder>? workoutReminders,
    List<CustomExerciseDefinition>? customExercises,
    Map<String, double>? strengthTrainingMaxes,
    List<HypertrophyCheckIn>? hypertrophyCheckIns,
    List<HypertrophyTechniqueLog>? hypertrophyTechniqueLogs,
    List<CardioSessionLog>? cardioSessions,
    List<ConditioningBenchmarkResult>? conditioningBenchmarks,
    List<RunningSessionLog>? runningSessions,
    List<RunningShoe>? runningShoes,
    List<CyclingSessionLog>? cyclingSessions,
    List<RowingSessionLog>? rowingSessions,
    List<CalisthenicsSkillLog>? calisthenicsSkillLogs,
    List<MobilityScreenLog>? mobilityScreenLogs,
    List<RecoveryInterventionLog>? recoveryInterventions,
    List<NutritionPhaseLog>? nutritionPhaseLogs,
    List<PantryItem>? pantryItems,
    List<String>? favoriteIngredientIds,
    List<BodyMeasurementLog>? bodyMeasurementLogs,
    List<HealthHabit>? healthHabits,
    List<HabitCheckIn>? habitCheckIns,
    List<SleepRoutineLog>? sleepRoutineLogs,
    List<StressCheckInLog>? stressCheckInLogs,
    List<CoachRecommendationFeedback>? coachRecommendationFeedback,
    List<String>? analyticsDashboardMetrics,
    List<AnalyticsAnnotation>? analyticsAnnotations,
    List<CapabilityState>? capabilityStates,
  }) => FitnessData(
    profile: clearProfile ? null : profile ?? this.profile,
    templates: templates ?? this.templates,
    logs: logs ?? this.logs,
    weights: weights ?? this.weights,
    meals: meals ?? this.meals,
    spotifyUrl: spotifyUrl ?? this.spotifyUrl,
    recoveryChecks: recoveryChecks ?? this.recoveryChecks,
    weeklyAssignments: weeklyAssignments ?? this.weeklyAssignments,
    programVersions: programVersions ?? this.programVersions,
    hydration: hydration ?? this.hydration,
    mealPresets: mealPresets ?? this.mealPresets,
    recoveryStatus: recoveryStatus ?? this.recoveryStatus,
    preferences: preferences ?? this.preferences,
    dateAssignments: dateAssignments ?? this.dateAssignments,
    strengthTests: strengthTests ?? this.strengthTests,
    skillAssessments: skillAssessments ?? this.skillAssessments,
    progressPhotos: progressPhotos ?? this.progressPhotos,
    workoutPlaylists: workoutPlaylists ?? this.workoutPlaylists,
    exerciseVideoUrls: exerciseVideoUrls ?? this.exerciseVideoUrls,
    spotifyAuth: spotifyAuth ?? this.spotifyAuth,
    wearableSummaries: wearableSummaries ?? this.wearableSummaries,
    workoutReminders: workoutReminders ?? this.workoutReminders,
    customExercises: customExercises ?? this.customExercises,
    strengthTrainingMaxes: strengthTrainingMaxes ?? this.strengthTrainingMaxes,
    hypertrophyCheckIns: hypertrophyCheckIns ?? this.hypertrophyCheckIns,
    hypertrophyTechniqueLogs:
        hypertrophyTechniqueLogs ?? this.hypertrophyTechniqueLogs,
    cardioSessions: cardioSessions ?? this.cardioSessions,
    conditioningBenchmarks:
        conditioningBenchmarks ?? this.conditioningBenchmarks,
    runningSessions: runningSessions ?? this.runningSessions,
    runningShoes: runningShoes ?? this.runningShoes,
    cyclingSessions: cyclingSessions ?? this.cyclingSessions,
    rowingSessions: rowingSessions ?? this.rowingSessions,
    calisthenicsSkillLogs: calisthenicsSkillLogs ?? this.calisthenicsSkillLogs,
    mobilityScreenLogs: mobilityScreenLogs ?? this.mobilityScreenLogs,
    recoveryInterventions: recoveryInterventions ?? this.recoveryInterventions,
    nutritionPhaseLogs: nutritionPhaseLogs ?? this.nutritionPhaseLogs,
    pantryItems: pantryItems ?? this.pantryItems,
    favoriteIngredientIds: favoriteIngredientIds ?? this.favoriteIngredientIds,
    bodyMeasurementLogs: bodyMeasurementLogs ?? this.bodyMeasurementLogs,
    healthHabits: healthHabits ?? this.healthHabits,
    habitCheckIns: habitCheckIns ?? this.habitCheckIns,
    sleepRoutineLogs: sleepRoutineLogs ?? this.sleepRoutineLogs,
    stressCheckInLogs: stressCheckInLogs ?? this.stressCheckInLogs,
    coachRecommendationFeedback:
        coachRecommendationFeedback ?? this.coachRecommendationFeedback,
    analyticsDashboardMetrics:
        analyticsDashboardMetrics ?? this.analyticsDashboardMetrics,
    analyticsAnnotations: analyticsAnnotations ?? this.analyticsAnnotations,
    capabilityStates: capabilityStates ?? this.capabilityStates,
  );

  factory FitnessData.initial() => const FitnessData(
    profile: null,
    templates: [
      WorkoutTemplate(
        id: 'iron-hybrid',
        name: 'IRON HYBRID — Full Body',
        exercises: [
          'Goblet squat',
          'Πιέσεις στήθους με αλτήρες',
          'Κωπηλατική με στήριξη στήθους',
          'Ρουμανικές άρσεις με αλτήρες',
          'Farmer carry',
        ],
        prescription: '3 σετ × 6–10 • RIR 1–2 • 2′ διάλειμμα',
        coachingCue: 'Δυνατές επαναλήψεις, ουδέτερη μέση, κανένα βιαστικό σετ.',
        restSeconds: 120,
      ),
      WorkoutTemplate(
        id: 'calisthenics-strength',
        name: 'CALISTHENICS — Strict Strength',
        exercises: [
          'Κάμψεις με παύση 1″',
          'Αυστηρές έλξεις',
          'Pike push-ups',
          'Bulgarian split squat',
          'Hollow body hold',
        ],
        prescription: '3–4 σετ • RIR 1–2 • 90″ διάλειμμα',
        coachingCue: 'Μηδέν κλέψιμο: πλήρης έλεγχος και τεχνικό stop.',
      ),
      WorkoutTemplate(
        id: 'iron-engine',
        name: 'IRON ENGINE — Conditioning',
        exercises: [
          'Step-ups',
          'Farmer carry',
          'Κωπηλατικό εργόμετρο',
          'Sled push',
        ],
        prescription: '4 γύροι • 40″ δουλειά / 20″ αλλαγή • RPE 7–8',
        coachingCue: 'Σταθερός ρυθμός· όχι sprint όταν χαλάει η στάση.',
        restSeconds: 60,
      ),
    ],
    logs: [],
    weights: [],
    meals: [],
    mealPresets: [
      MealPreset(
        id: 'preset-power-breakfast',
        name: 'Power πρωινό',
        calories: 560,
        proteinGrams: 35,
        carbohydrateGrams: 68,
        fatGrams: 16,
        fiberGrams: 10,
        sodiumMilligrams: 320,
        ingredients: ['Βρώμη', 'Γιαούρτι', 'Μπανάνα', 'Μούρα', 'Καρύδια'],
      ),
      MealPreset(
        id: 'preset-chicken-rice',
        name: 'Κοτόπουλο & ρύζι',
        calories: 690,
        proteinGrams: 52,
        carbohydrateGrams: 82,
        fatGrams: 15,
        fiberGrams: 8,
        sodiumMilligrams: 610,
        ingredients: ['Στήθος κοτόπουλου', 'Ρύζι', 'Μπρόκολο', 'Ελαιόλαδο'],
      ),
      MealPreset(
        id: 'preset-recovery-bowl',
        name: 'Recovery bowl',
        calories: 480,
        proteinGrams: 30,
        carbohydrateGrams: 55,
        fatGrams: 15,
        fiberGrams: 12,
        sodiumMilligrams: 420,
        ingredients: ['Γιαούρτι', 'Βρώμη', 'Μούρα', 'Μέλι', 'Σπόροι chia'],
      ),
    ],
    spotifyUrl: '',
  );
}
