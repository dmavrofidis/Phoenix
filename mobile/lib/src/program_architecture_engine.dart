import 'exercise_intelligence_engine.dart';
import 'models/fitness_models.dart';
import 'training_program_engine.dart';

enum ProgramVolumeMode { minimumEffective, balanced, high }

class ProgramArchitectureInput {
  const ProgramArchitectureInput({
    required this.goal,
    required this.daysPerWeek,
    required this.sessionMinutes,
    required this.experienceLevel,
    this.mesocycleWeeks = 4,
    this.volumeMode = ProgramVolumeMode.balanced,
    this.preferredSplit = '',
    this.includeConditioning = false,
  });

  final String goal;
  final int daysPerWeek;
  final int sessionMinutes;
  final String experienceLevel;
  final int mesocycleWeeks;
  final ProgramVolumeMode volumeMode;
  final String preferredSplit;
  final bool includeConditioning;
}

class ProgramSplitOption {
  const ProgramSplitOption({
    required this.id,
    required this.label,
    required this.score,
    required this.reason,
  });

  final String id;
  final String label;
  final int score;
  final String reason;
}

class ProgramArchitectureIssue {
  const ProgramArchitectureIssue({
    required this.code,
    required this.title,
    required this.detail,
    required this.severity,
  });

  final String code;
  final String title;
  final String detail;
  final String severity;
}

class ProgramArchitectureResult {
  const ProgramArchitectureResult({
    required this.split,
    required this.mesocycleWeeks,
    required this.templates,
    required this.estimatedMinutes,
    required this.weeklySetBudget,
    required this.muscleFrequency,
    required this.movementCoverage,
    required this.issues,
    required this.adjustments,
    required this.minimumEffectiveDose,
    required this.maximumRecoverableSets,
  });

  final ProgramSplitOption split;
  final int mesocycleWeeks;
  final List<WorkoutTemplate> templates;
  final Map<String, int> estimatedMinutes;
  final Map<String, int> weeklySetBudget;
  final Map<String, int> muscleFrequency;
  final Map<String, int> movementCoverage;
  final List<ProgramArchitectureIssue> issues;
  final List<String> adjustments;
  final int minimumEffectiveDose;
  final int maximumRecoverableSets;

  bool get hasBlockingConflict =>
      issues.any((item) => item.severity == 'critical');
}

class ProgramArchitectureEngine {
  const ProgramArchitectureEngine._();

  static List<ProgramSplitOption> splitOptions(ProgramArchitectureInput input) {
    final goal = _normalize(input.goal);
    final days = input.daysPerWeek.clamp(2, 6);
    final options = <ProgramSplitOption>[
      ProgramSplitOption(
        id: 'full-body',
        label: 'FULL BODY ROTATION',
        score:
            72 +
            (days <= 3 ? 18 : 0) +
            (goal.contains('δυνα') || goal.contains('strength') ? 5 : 0),
        reason:
            'High movement frequency with simple recovery management for 2–4 days.',
      ),
      ProgramSplitOption(
        id: 'upper-lower',
        label: 'UPPER / LOWER',
        score:
            70 +
            (days == 4 ? 22 : 0) +
            (goal.contains('δυνα') || goal.contains('muscle') ? 5 : 0),
        reason:
            'Balanced twice-weekly exposure and clear session-duration control.',
      ),
      ProgramSplitOption(
        id: 'push-pull-legs',
        label: 'PUSH / PULL / LEGS',
        score:
            64 +
            (days >= 5 ? 22 : 0) +
            (goal.contains('μυ') ||
                    goal.contains('hypertrophy') ||
                    goal.contains('muscle')
                ? 10
                : 0),
        reason:
            'Higher local volume capacity when five or six sessions are realistic.',
      ),
      ProgramSplitOption(
        id: 'hybrid',
        label: 'STRENGTH / CALISTHENICS HYBRID',
        score:
            68 +
            (days >= 3 && days <= 5 ? 14 : 0) +
            (goal.contains('calisthenics') || goal.contains('καλλ') ? 12 : 0),
        reason:
            'Combines loaded strength, strict bodyweight skills and conditioning.',
      ),
    ];
    options.sort((left, right) => right.score.compareTo(left.score));
    return options;
  }

  static ProgramArchitectureResult build({
    required FitnessData data,
    required ProgramArchitectureInput input,
    DateTime? generatedAt,
  }) {
    if (input.daysPerWeek < 2 || input.daysPerWeek > 6) {
      throw const FormatException('Program architecture supports 2–6 days.');
    }
    if (input.sessionMinutes < 20 || input.sessionMinutes > 120) {
      throw const FormatException('Session budget must be 20–120 minutes.');
    }
    if (input.mesocycleWeeks < 3 || input.mesocycleWeeks > 8) {
      throw const FormatException('Mesocycle must be 3–8 weeks.');
    }
    final options = splitOptions(input);
    final split = input.preferredSplit.isEmpty
        ? options.first
        : options.firstWhere(
            (item) => item.id == input.preferredSplit,
            orElse: () => options.first,
          );
    final setsPerExercise = switch (input.volumeMode) {
      ProgramVolumeMode.minimumEffective => 2,
      ProgramVolumeMode.balanced => 3,
      ProgramVolumeMode.high => 4,
    };
    final maxExercises = (input.sessionMinutes / 8).floor().clamp(3, 9);
    final sessions = _sessionPatterns(
      split.id,
      input.daysPerWeek,
      includeConditioning: input.includeConditioning,
    );
    final allProfiles = ExerciseIntelligenceEngine.allProfiles(data)
        .where(
          (item) =>
              item.difficulty <= _difficultyCap(input.experienceLevel) &&
              ExerciseIntelligenceEngine.isEquipmentCompatible(
                item,
                data.profile,
              ),
        )
        .toList();
    final timestamp = (generatedAt ?? DateTime.now()).microsecondsSinceEpoch
        .toString();
    final templates = <WorkoutTemplate>[];
    final estimatedMinutes = <String, int>{};
    final adjustments = <String>[];

    for (var day = 0; day < sessions.length; day++) {
      final patterns = sessions[day];
      final selected = <ExerciseIntelligenceProfile>[];
      for (final pattern in patterns) {
        final candidate = _bestForPattern(
          allProfiles,
          pattern,
          selected.map((item) => item.name).toSet(),
          input,
        );
        if (candidate != null) selected.add(candidate);
        if (selected.length >= maxExercises) break;
      }
      if (selected.length < 3) {
        for (final candidate in allProfiles) {
          if (selected.any((item) => item.name == candidate.name)) continue;
          selected.add(candidate);
          if (selected.length >= 3) break;
        }
      }
      final ordered = optimizeOrder(selected);
      final id = 'custom-architecture-$timestamp-${day + 1}';
      final exercises = ordered.map((item) => item.name).toList();
      final basePrescriptions = TrainingProgramEngine.prescriptionsFor(
        exercises,
        goal: input.goal,
        experienceLevel: input.experienceLevel,
        templateId: id,
      );
      final prescriptions = {
        for (final exercise in exercises)
          exercise: ExercisePrescription(
            workingSets: setsPerExercise,
            minReps: basePrescriptions[exercise]!.minReps,
            maxReps: basePrescriptions[exercise]!.maxReps,
            targetRir: basePrescriptions[exercise]!.targetRir,
            restSeconds: basePrescriptions[exercise]!.restSeconds,
            tempo: basePrescriptions[exercise]!.tempo,
            minHoldSeconds: basePrescriptions[exercise]!.minHoldSeconds,
            maxHoldSeconds: basePrescriptions[exercise]!.maxHoldSeconds,
            note: basePrescriptions[exercise]!.note,
          ),
      };
      final estimated = estimateSessionMinutes(
        exerciseCount: exercises.length,
        setsPerExercise: setsPerExercise,
        restSeconds: _restSeconds(input.goal),
      );
      var finalExercises = exercises;
      if (estimated > input.sessionMinutes && exercises.length > 3) {
        final removeCount = ((estimated - input.sessionMinutes) / 7)
            .ceil()
            .clamp(1, exercises.length - 3);
        finalExercises = exercises
            .take(exercises.length - removeCount)
            .toList();
        adjustments.add(
          'Day ${day + 1}: removed $removeCount low-priority movement(s) '
          'to respect the ${input.sessionMinutes}′ session budget.',
        );
      }
      final template = WorkoutTemplate(
        id: id,
        name: '${split.label} — DAY ${day + 1}',
        exercises: finalExercises,
        prescription:
            '$setsPerExercise sets • RIR ${setsPerExercise >= 4 ? '2–3' : '1–3'} '
            '• ${input.sessionMinutes}′ cap',
        coachingCue:
            'Follow the optimized order. Stop a set when technique or rep speed breaks.',
        restSeconds: _restSeconds(input.goal),
        exercisePrescriptions: {
          for (final entry in prescriptions.entries)
            if (finalExercises.contains(entry.key)) entry.key: entry.value,
        },
        tags: [
          'Architecture',
          split.label,
          'W${input.mesocycleWeeks}',
          input.volumeMode.name,
        ],
        equipmentPreset: data.profile?.equipment ?? 'auto',
      );
      templates.add(template);
      estimatedMinutes[id] = estimateSessionMinutes(
        exerciseCount: finalExercises.length,
        setsPerExercise: setsPerExercise,
        restSeconds: template.restSeconds,
      );
    }

    final weeklySets = _weeklySetBudget(
      templates,
      setsPerExercise: setsPerExercise,
      data: data,
    );
    final frequency = _muscleFrequency(templates, data);
    final movementCoverage = _movementCoverage(templates, data);
    final minDose = _minimumEffectiveDose(input.experienceLevel);
    final maxRecoverable = _maximumRecoverableSets(input.experienceLevel);
    final issues = audit(
      input: input,
      weeklySetBudget: weeklySets,
      muscleFrequency: frequency,
      movementCoverage: movementCoverage,
      estimatedMinutes: estimatedMinutes,
      minimumEffectiveDose: minDose,
      maximumRecoverableSets: maxRecoverable,
    );
    adjustments.addAll(resolveConflicts(issues));

    return ProgramArchitectureResult(
      split: split,
      mesocycleWeeks: input.mesocycleWeeks,
      templates: templates,
      estimatedMinutes: estimatedMinutes,
      weeklySetBudget: weeklySets,
      muscleFrequency: frequency,
      movementCoverage: movementCoverage,
      issues: issues,
      adjustments: adjustments.toSet().toList(),
      minimumEffectiveDose: minDose,
      maximumRecoverableSets: maxRecoverable,
    );
  }

  static List<ExerciseIntelligenceProfile> optimizeOrder(
    List<ExerciseIntelligenceProfile> exercises,
  ) {
    final ordered = List<ExerciseIntelligenceProfile>.from(exercises);
    ordered.sort((left, right) {
      final leftScore = _orderScore(left);
      final rightScore = _orderScore(right);
      final byScore = rightScore.compareTo(leftScore);
      return byScore != 0 ? byScore : left.name.compareTo(right.name);
    });
    return ordered;
  }

  static int estimateSessionMinutes({
    required int exerciseCount,
    required int setsPerExercise,
    required int restSeconds,
  }) {
    final workSeconds = exerciseCount * setsPerExercise * 42;
    final rest = exerciseCount * (setsPerExercise - 1) * restSeconds;
    final transitions = exerciseCount * 90;
    return ((workSeconds + rest + transitions) / 60).ceil();
  }

  static List<ProgramArchitectureIssue> audit({
    required ProgramArchitectureInput input,
    required Map<String, int> weeklySetBudget,
    required Map<String, int> muscleFrequency,
    required Map<String, int> movementCoverage,
    required Map<String, int> estimatedMinutes,
    required int minimumEffectiveDose,
    required int maximumRecoverableSets,
  }) {
    final issues = <ProgramArchitectureIssue>[];
    const essentialPatterns = {
      'squat',
      'hinge',
      'horizontal push',
      'horizontal pull',
      'vertical push',
      'vertical pull',
      'anti-extension',
    };
    final missing = essentialPatterns
        .where((item) => (movementCoverage[item] ?? 0) == 0)
        .toList();
    if (missing.isNotEmpty) {
      issues.add(
        ProgramArchitectureIssue(
          code: 'movement-gap',
          title: 'MOVEMENT BALANCE GAP',
          detail: 'Missing: ${missing.join(', ')}.',
          severity: missing.length >= 3 ? 'critical' : 'warning',
        ),
      );
    }
    for (final entry in weeklySetBudget.entries) {
      if (entry.value > maximumRecoverableSets) {
        issues.add(
          ProgramArchitectureIssue(
            code: 'mrv-${entry.key}',
            title: 'RECOVERABLE VOLUME GUARD',
            detail:
                '${entry.key}: ${entry.value} sets exceeds the '
                '$maximumRecoverableSets-set guard.',
            severity: 'critical',
          ),
        );
      } else if (entry.value < minimumEffectiveDose &&
          _isMajorMuscle(entry.key)) {
        issues.add(
          ProgramArchitectureIssue(
            code: 'med-${entry.key}',
            title: 'MINIMUM EFFECTIVE DOSE',
            detail:
                '${entry.key}: ${entry.value} sets is below the '
                '$minimumEffectiveDose-set reference.',
            severity: 'info',
          ),
        );
      }
    }
    for (final entry in muscleFrequency.entries) {
      if (entry.value < 2 &&
          input.daysPerWeek >= 4 &&
          _isMajorMuscle(entry.key)) {
        issues.add(
          ProgramArchitectureIssue(
            code: 'frequency-${entry.key}',
            title: 'LOW MUSCLE FREQUENCY',
            detail: '${entry.key} appears in only ${entry.value} session.',
            severity: 'warning',
          ),
        );
      }
    }
    for (final entry in estimatedMinutes.entries) {
      if (entry.value > input.sessionMinutes) {
        issues.add(
          ProgramArchitectureIssue(
            code: 'time-${entry.key}',
            title: 'SESSION BUDGET CONFLICT',
            detail:
                '${entry.value}′ estimated exceeds ${input.sessionMinutes}′.',
            severity: 'critical',
          ),
        );
      }
    }
    return issues;
  }

  static List<String> resolveConflicts(List<ProgramArchitectureIssue> issues) {
    final actions = <String>[];
    for (final issue in issues) {
      if (issue.code == 'movement-gap') {
        actions.add(
          'Use the Exercise Intelligence substitutions to add the missing '
          'movement without extending the session.',
        );
      } else if (issue.code.startsWith('mrv-')) {
        actions.add(
          'Reduce one set from the flagged muscle on its lowest-priority day.',
        );
      } else if (issue.code.startsWith('med-')) {
        actions.add(
          'Add one targeted set only if recovery and adherence remain stable.',
        );
      } else if (issue.code.startsWith('frequency-')) {
        actions.add('Distribute the same weekly sets over a second exposure.');
      } else if (issue.code.startsWith('time-')) {
        actions.add(
          'Remove the final accessory or convert two movements into a superset.',
        );
      }
    }
    return actions.toSet().toList();
  }

  static Map<String, int> recommendedFrequency(ProgramArchitectureInput input) {
    final target = input.daysPerWeek <= 3
        ? 2
        : input.goal.toLowerCase().contains('hypertrophy') ||
              input.goal.toLowerCase().contains('μυ')
        ? 2
        : 2;
    return {
      'major muscles': target,
      'skills': input.daysPerWeek >= 4 ? 3 : 2,
      'conditioning': input.includeConditioning ? 2 : 0,
    };
  }

  static List<List<String>> _sessionPatterns(
    String split,
    int days, {
    required bool includeConditioning,
  }) {
    const fullBody = [
      [
        'squat',
        'horizontal push',
        'horizontal pull',
        'hinge',
        'anti-extension',
      ],
      [
        'hinge',
        'vertical push',
        'vertical pull',
        'single-leg squat',
        'anti-rotation',
      ],
      [
        'single-leg squat',
        'horizontal push',
        'horizontal pull',
        'hip extension',
        'loaded carry',
      ],
    ];
    const upper = [
      'horizontal push',
      'horizontal pull',
      'vertical push',
      'vertical pull',
      'anti-extension',
    ];
    const lower = [
      'squat',
      'hinge',
      'single-leg squat',
      'hip extension',
      'loaded carry',
    ];
    const push = [
      'horizontal push',
      'vertical push',
      'squat',
      'anti-extension',
      'loaded carry',
    ];
    const pull = [
      'horizontal pull',
      'vertical pull',
      'hinge',
      'anti-rotation',
      'loaded carry',
    ];
    const legs = [
      'squat',
      'hinge',
      'single-leg squat',
      'hip extension',
      'ankle extension',
    ];
    final sessions = <List<String>>[];
    for (var day = 0; day < days; day++) {
      final patterns = switch (split) {
        'upper-lower' => day.isEven ? upper : lower,
        'push-pull-legs' => switch (day % 3) {
          0 => push,
          1 => pull,
          _ => legs,
        },
        'hybrid' => switch (day % 4) {
          0 => upper,
          1 => lower,
          2 => fullBody[day % fullBody.length],
          _ => [
            'inverted support',
            'vertical pull',
            'straight-arm support',
            'single-leg squat',
            'anti-extension',
          ],
        },
        _ => fullBody[day % fullBody.length],
      };
      sessions.add([
        ...patterns,
        if (includeConditioning && day == days - 1) 'cyclical conditioning',
      ]);
    }
    return sessions;
  }

  static ExerciseIntelligenceProfile? _bestForPattern(
    List<ExerciseIntelligenceProfile> profiles,
    String pattern,
    Set<String> excluded,
    ProgramArchitectureInput input,
  ) {
    final candidates = profiles
        .where(
          (item) =>
              item.movementPattern == pattern && !excluded.contains(item.name),
        )
        .toList();
    candidates.sort((left, right) {
      final leftScore = _candidateScore(left, input);
      final rightScore = _candidateScore(right, input);
      return rightScore.compareTo(leftScore);
    });
    return candidates.firstOrNull;
  }

  static int _candidateScore(
    ExerciseIntelligenceProfile profile,
    ProgramArchitectureInput input,
  ) {
    var score = 50;
    final experienceCap = _difficultyCap(input.experienceLevel);
    score += 10 - (profile.difficulty - experienceCap).abs() * 3;
    if (profile.category == 'STRENGTH') score += 8;
    if (input.volumeMode == ProgramVolumeMode.minimumEffective &&
        profile.primaryMuscles.length > 1) {
      score += 8;
    }
    if (profile.isCustom) score += 4;
    return score;
  }

  static int _orderScore(ExerciseIntelligenceProfile profile) {
    const patternPriority = <String, int>{
      'inverted support': 95,
      'straight-arm support': 92,
      'squat': 86,
      'hinge': 84,
      'vertical push': 80,
      'vertical pull': 80,
      'horizontal push': 76,
      'horizontal pull': 76,
      'single-leg squat': 70,
      'hip extension': 58,
      'anti-extension': 50,
      'anti-rotation': 48,
      'loaded carry': 40,
      'cyclical conditioning': 20,
    };
    return (patternPriority[profile.movementPattern] ?? 35) +
        profile.skillDemand * 2;
  }

  static Map<String, int> _weeklySetBudget(
    List<WorkoutTemplate> templates, {
    required int setsPerExercise,
    required FitnessData data,
  }) {
    final custom = {
      for (final item in data.customExercises) _normalize(item.name): item,
    };
    final budget = <String, int>{};
    for (final template in templates) {
      for (final exercise in template.exercises) {
        final profile = ExerciseIntelligenceEngine.profileFor(
          exercise,
          custom: custom[_normalize(exercise)],
        );
        for (final muscle in profile.primaryMuscles) {
          budget.update(
            muscle,
            (value) => value + setsPerExercise,
            ifAbsent: () => setsPerExercise,
          );
        }
      }
    }
    return _sortedCounts(budget);
  }

  static Map<String, int> _muscleFrequency(
    List<WorkoutTemplate> templates,
    FitnessData data,
  ) {
    final custom = {
      for (final item in data.customExercises) _normalize(item.name): item,
    };
    final frequency = <String, int>{};
    for (final template in templates) {
      final muscles = <String>{};
      for (final exercise in template.exercises) {
        muscles.addAll(
          ExerciseIntelligenceEngine.profileFor(
            exercise,
            custom: custom[_normalize(exercise)],
          ).primaryMuscles,
        );
      }
      for (final muscle in muscles) {
        frequency.update(muscle, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    return _sortedCounts(frequency);
  }

  static Map<String, int> _movementCoverage(
    List<WorkoutTemplate> templates,
    FitnessData data,
  ) {
    final custom = {
      for (final item in data.customExercises) _normalize(item.name): item,
    };
    final coverage = <String, int>{};
    for (final template in templates) {
      for (final exercise in template.exercises) {
        final pattern = ExerciseIntelligenceEngine.profileFor(
          exercise,
          custom: custom[_normalize(exercise)],
        ).movementPattern;
        coverage.update(pattern, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    return _sortedCounts(coverage);
  }

  static Map<String, int> _sortedCounts(Map<String, int> values) {
    final entries = values.entries.toList()
      ..sort((left, right) {
        final byValue = right.value.compareTo(left.value);
        return byValue != 0 ? byValue : left.key.compareTo(right.key);
      });
    return Map.fromEntries(entries);
  }

  static int _difficultyCap(String experience) {
    final normalized = _normalize(experience);
    if (normalized.contains('advanced') || normalized.contains('προχωρη')) {
      return 5;
    }
    if (normalized.contains('intermediate') || normalized.contains('μετρι')) {
      return 4;
    }
    return 3;
  }

  static int _minimumEffectiveDose(String experience) {
    final normalized = _normalize(experience);
    return normalized.contains('advanced') || normalized.contains('προχωρη')
        ? 8
        : normalized.contains('intermediate') || normalized.contains('μετρι')
        ? 6
        : 4;
  }

  static int _maximumRecoverableSets(String experience) {
    final normalized = _normalize(experience);
    return normalized.contains('advanced') || normalized.contains('προχωρη')
        ? 22
        : normalized.contains('intermediate') || normalized.contains('μετρι')
        ? 20
        : 18;
  }

  static int _restSeconds(String goal) {
    final normalized = _normalize(goal);
    return normalized.contains('δυνα') || normalized.contains('strength')
        ? 150
        : 90;
  }

  static bool _isMajorMuscle(String muscle) => const {
    'chest',
    'lats',
    'upper back',
    'quadriceps',
    'hamstrings',
    'glutes',
    'shoulders',
  }.contains(muscle);

  static String _normalize(String value) => value.trim().toLowerCase();
}
