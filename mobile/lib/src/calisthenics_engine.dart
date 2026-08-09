import 'models/fitness_models.dart';

class SkillNodeProgress {
  const SkillNodeProgress({
    required this.id,
    required this.name,
    required this.category,
    required this.level,
    required this.maxLevel,
    required this.unlocked,
    required this.prerequisiteIds,
    required this.nextTarget,
    required this.progress,
  });

  final String id;
  final String name;
  final String category;
  final int level;
  final int maxLevel;
  final bool unlocked;
  final List<String> prerequisiteIds;
  final String nextTarget;
  final double progress;
}

class PrerequisiteCheck {
  const PrerequisiteCheck({
    required this.title,
    required this.detail,
    required this.passed,
    required this.route,
  });

  final String title;
  final String detail;
  final bool passed;
  final String route;
}

class WeightedCalisthenicsPlan {
  const WeightedCalisthenicsPlan({
    required this.exercise,
    required this.currentLoad,
    required this.nextLoad,
    required this.target,
    required this.ready,
    required this.reason,
  });

  final String exercise;
  final double currentLoad;
  final double nextLoad;
  final String target;
  final bool ready;
  final String reason;
}

class HoldAnalyticsPoint {
  const HoldAnalyticsPoint({
    required this.skill,
    required this.bestSeconds,
    required this.previousBestSeconds,
    required this.attempts,
    required this.changePercent,
  });

  final String skill;
  final int bestSeconds;
  final int previousBestSeconds;
  final int attempts;
  final double changePercent;
}

class CalisthenicsEngine {
  const CalisthenicsEngine._();

  static int levelFor(String skillId, double value) => switch (skillId) {
    'pull-up' =>
      value >= 15
          ? 5
          : value >= 10
          ? 4
          : value >= 5
          ? 3
          : value >= 1
          ? 2
          : value > 0
          ? 1
          : 0,
    'push-up' =>
      value >= 40
          ? 5
          : value >= 25
          ? 4
          : value >= 15
          ? 3
          : value >= 5
          ? 2
          : value > 0
          ? 1
          : 0,
    'handstand' =>
      value >= 45
          ? 5
          : value >= 20
          ? 4
          : value >= 10
          ? 3
          : value >= 3
          ? 2
          : value > 0
          ? 1
          : 0,
    'l-sit' =>
      value >= 30
          ? 5
          : value >= 15
          ? 4
          : value >= 8
          ? 3
          : value >= 3
          ? 2
          : value > 0
          ? 1
          : 0,
    'hollow-hold' =>
      value >= 60
          ? 5
          : value >= 40
          ? 4
          : value >= 25
          ? 3
          : value >= 15
          ? 2
          : value > 0
          ? 1
          : 0,
    'false-grip' || 'ring-support' =>
      value >= 45
          ? 5
          : value >= 30
          ? 4
          : value >= 20
          ? 3
          : value >= 10
          ? 2
          : value > 0
          ? 1
          : 0,
    'mobility-overhead' || 'mobility-squat' => (value / 20).floor().clamp(0, 5),
    _ => 0,
  };

  static SkillAssessmentResult? latest(
    List<SkillAssessmentResult> assessments,
    String skillId,
  ) {
    final matching =
        assessments.where((item) => item.skillId == skillId).toList()
          ..sort((left, right) => right.recordedAt.compareTo(left.recordedAt));
    return matching.isEmpty ? null : matching.first;
  }

  static List<SkillNodeProgress> skillTree(FitnessData data) {
    int level(String id) => latest(data.skillAssessments, id)?.level ?? 0;
    final hollow = level('hollow-hold');
    final push = level('push-up');
    final pull = level('pull-up');
    final handstand = level('handstand');
    final lSit = level('l-sit');
    final overhead = level('mobility-overhead');
    final squatMobility = level('mobility-squat');

    SkillNodeProgress node({
      required String id,
      required String name,
      required String category,
      required int current,
      required List<String> prerequisites,
      required bool unlocked,
      required String target,
    }) => SkillNodeProgress(
      id: id,
      name: name,
      category: category,
      level: current,
      maxLevel: 5,
      unlocked: unlocked,
      prerequisiteIds: prerequisites,
      nextTarget: current >= 5 ? 'MASTERED • maintain quality' : target,
      progress: (current / 5).clamp(0, 1),
    );

    return [
      node(
        id: 'hollow-hold',
        name: 'Hollow Body',
        category: 'CORE',
        current: hollow,
        prerequisites: const [],
        unlocked: true,
        target: '15″ clean hollow hold',
      ),
      node(
        id: 'push-up',
        name: 'Push-up',
        category: 'PUSH',
        current: push,
        prerequisites: const ['hollow-hold'],
        unlocked: hollow >= 1,
        target: '5 strict push-ups',
      ),
      node(
        id: 'pull-up',
        name: 'Pull-up',
        category: 'PULL',
        current: pull,
        prerequisites: const ['hollow-hold'],
        unlocked: hollow >= 1,
        target: '1 strict pull-up',
      ),
      node(
        id: 'handstand',
        name: 'Handstand',
        category: 'SKILL',
        current: handstand,
        prerequisites: const ['push-up', 'mobility-overhead'],
        unlocked: push >= 2 && overhead >= 2,
        target: '3″ controlled wall-free hold',
      ),
      node(
        id: 'l-sit',
        name: 'L-sit',
        category: 'SKILL',
        current: lSit,
        prerequisites: const ['hollow-hold', 'push-up'],
        unlocked: hollow >= 2 && push >= 2,
        target: '3″ tuck L-sit',
      ),
      node(
        id: 'weighted-pull-up',
        name: 'Weighted Pull-up',
        category: 'STRENGTH',
        current: pull >= 5
            ? 2
            : pull >= 4
            ? 1
            : 0,
        prerequisites: const ['pull-up'],
        unlocked: pull >= 4,
        target: '+2.5 kg × 5 strict',
      ),
      node(
        id: 'pistol-squat',
        name: 'Pistol Squat',
        category: 'LEGS',
        current: squatMobility >= 4 ? 1 : 0,
        prerequisites: const ['mobility-squat'],
        unlocked: squatMobility >= 3,
        target: 'Controlled box pistol',
      ),
    ];
  }

  static List<PrerequisiteCheck> prerequisites(
    FitnessData data, {
    UserProfile? profile,
  }) {
    final push = latest(data.skillAssessments, 'push-up')?.value ?? 0;
    final pull = latest(data.skillAssessments, 'pull-up')?.value ?? 0;
    final hollow = latest(data.skillAssessments, 'hollow-hold')?.value ?? 0;
    final overhead =
        latest(data.skillAssessments, 'mobility-overhead')?.value ?? 0;
    final squat = latest(data.skillAssessments, 'mobility-squat')?.value ?? 0;
    final limitations = profile?.limitations.toLowerCase() ?? '';
    return [
      PrerequisiteCheck(
        title: 'Core control',
        detail: '${hollow.toStringAsFixed(0)}″ hollow hold • target 20″',
        passed: hollow >= 20,
        route: 'hollow-hold',
      ),
      PrerequisiteCheck(
        title: 'Push capacity',
        detail: '${push.toStringAsFixed(0)} strict reps • target 10',
        passed: push >= 10,
        route: 'push-up',
      ),
      PrerequisiteCheck(
        title: 'Pull capacity',
        detail: '${pull.toStringAsFixed(0)} strict reps • target 5',
        passed: pull >= 5,
        route: 'pull-up',
      ),
      PrerequisiteCheck(
        title: 'Overhead mobility',
        detail: '${overhead.toStringAsFixed(0)}/100 • target 60',
        passed:
            overhead >= 60 &&
            !limitations.contains('ώμ') &&
            !limitations.contains('shoulder'),
        route: 'mobility-overhead',
      ),
      PrerequisiteCheck(
        title: 'Deep squat mobility',
        detail: '${squat.toStringAsFixed(0)}/100 • target 60',
        passed:
            squat >= 60 &&
            !limitations.contains('γόνα') &&
            !limitations.contains('knee'),
        route: 'mobility-squat',
      ),
    ];
  }

  static WeightedCalisthenicsPlan weightedPullUpPlan(FitnessData data) {
    final pullUp = latest(data.skillAssessments, 'pull-up');
    var bestLoad = 0.0;
    var bestRepsAtLoad = 0;
    for (final log in data.logs) {
      for (final set in log.sets) {
        final name = set.exerciseName.toLowerCase();
        if (!(name.contains('έλξεις') || name.contains('pull-up'))) continue;
        if (set.weightKilograms > bestLoad ||
            (set.weightKilograms == bestLoad && set.reps > bestRepsAtLoad)) {
          bestLoad = set.weightKilograms;
          bestRepsAtLoad = set.reps;
        }
      }
    }
    final baseReady = (pullUp?.value ?? 0) >= 10;
    final addLoad = bestLoad == 0 ? baseReady : bestRepsAtLoad >= 8;
    return WeightedCalisthenicsPlan(
      exercise: 'Weighted Pull-up',
      currentLoad: bestLoad,
      nextLoad: addLoad ? bestLoad + 2.5 : bestLoad,
      target: bestLoad == 0 ? '3 × 5 strict' : '3 × 5–8 • RIR 1–2',
      ready: baseReady,
      reason: !baseReady
          ? 'Χρειάζονται 10 strict pull-ups πριν προστεθεί βάρος.'
          : addLoad
          ? 'Το επάνω όριο επαναλήψεων επιτεύχθηκε: +2.5 kg.'
          : 'Κράτησε το φορτίο μέχρι να φτάσεις 8 καθαρές επαναλήψεις.',
    );
  }

  static List<HoldAnalyticsPoint> holdAnalytics(FitnessData data) {
    final values = <String, List<_TimedAttempt>>{};
    for (final log in data.logs) {
      for (final set in log.sets) {
        if (set.holdSeconds <= 0) continue;
        values
            .putIfAbsent(set.exerciseName, () => [])
            .add(_TimedAttempt(log.completedAt, set.holdSeconds));
      }
    }
    for (final assessment in data.skillAssessments) {
      if (assessment.unit != 'seconds') continue;
      final label = switch (assessment.skillId) {
        'handstand' => 'Handstand',
        'l-sit' => 'L-sit',
        'hollow-hold' => 'Hollow body hold',
        _ => assessment.skillId,
      };
      values
          .putIfAbsent(label, () => [])
          .add(_TimedAttempt(assessment.recordedAt, assessment.value.round()));
    }
    final result = <HoldAnalyticsPoint>[];
    for (final entry in values.entries) {
      final attempts = entry.value
        ..sort((left, right) => left.date.compareTo(right.date));
      if (attempts.isEmpty) continue;
      final latestHalf = attempts.skip((attempts.length / 2).floor()).toList();
      final previousHalf = attempts
          .take((attempts.length / 2).floor())
          .toList();
      final best = latestHalf
          .map((item) => item.seconds)
          .reduce((left, right) => left > right ? left : right);
      final previous = previousHalf.isEmpty
          ? 0
          : previousHalf
                .map((item) => item.seconds)
                .reduce((left, right) => left > right ? left : right);
      result.add(
        HoldAnalyticsPoint(
          skill: entry.key,
          bestSeconds: best,
          previousBestSeconds: previous,
          attempts: attempts.length,
          changePercent: previous <= 0 ? 0 : (best - previous) / previous * 100,
        ),
      );
    }
    result.sort((left, right) => right.bestSeconds.compareTo(left.bestSeconds));
    return result;
  }

  static WorkoutTemplate buildSkillSession({
    required Set<String> skillIds,
    required String id,
    int minutes = 30,
  }) {
    final selected = skillIds.isEmpty ? {'handstand', 'pull-up'} : skillIds;
    final exercises = <String>[];
    void add(String exercise) {
      if (!exercises.contains(exercise)) exercises.add(exercise);
    }

    add('Wrist preparation');
    if (selected.contains('handstand')) {
      add('Handstand στον τοίχο');
      add('Wall handstand shoulder taps');
    }
    if (selected.contains('pull-up')) {
      add('Scapular pull-ups');
      add('Αυστηρές έλξεις');
    }
    if (selected.contains('push-up')) {
      add('Κάμψεις με παύση 1″');
      add('Pseudo planche lean');
    }
    if (selected.contains('l-sit')) {
      add('Tuck L-sit');
      add('Compression lifts');
    }
    if (selected.contains('hollow-hold')) add('Hollow body hold');
    add('90/90 breathing');

    final capped = exercises.take(minutes <= 25 ? 5 : 8).toList();
    return WorkoutTemplate(
      id: id,
      name:
          'SKILL SESSION — ${selected.map((id) => id.toUpperCase()).join(' + ')}',
      exercises: capped,
      prescription: '4–6 ποιοτικές προσπάθειες • ποτέ μέχρι τεχνική αποτυχία',
      coachingCue:
          'Σταμάτα κάθε προσπάθεια όταν χαθεί η θέση. Ποιότητα πάνω από χρόνο.',
      restSeconds: 90,
      tags: const ['Calisthenics', 'Skill'],
      sessionType: 'workout',
      equipmentPreset: 'calisthenics',
      exercisePrescriptions: {
        for (final exercise in capped)
          exercise: ExercisePrescription(
            workingSets: exercise.contains('breathing') ? 2 : 4,
            minReps:
                exercise.contains('hold') ||
                    exercise.contains('Handstand') ||
                    exercise.contains('L-sit')
                ? 0
                : 3,
            maxReps:
                exercise.contains('hold') ||
                    exercise.contains('Handstand') ||
                    exercise.contains('L-sit')
                ? 0
                : 8,
            targetRir: 3,
            restSeconds: exercise.contains('breathing') ? 30 : 90,
            tempo: 'Controlled',
            minHoldSeconds:
                exercise.contains('hold') ||
                    exercise.contains('Handstand') ||
                    exercise.contains('L-sit')
                ? 8
                : 0,
            maxHoldSeconds:
                exercise.contains('hold') ||
                    exercise.contains('Handstand') ||
                    exercise.contains('L-sit')
                ? 30
                : 0,
            note: 'Technical stop.',
          ),
      },
    );
  }
}

class _TimedAttempt {
  const _TimedAttempt(this.date, this.seconds);

  final DateTime date;
  final int seconds;
}
