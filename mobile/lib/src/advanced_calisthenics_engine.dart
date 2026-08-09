import 'calisthenics_engine.dart';
import 'models/fitness_models.dart';

class AdvancedSkillStage {
  const AdvancedSkillStage({
    required this.level,
    required this.name,
    required this.target,
    required this.coachingCue,
    required this.minimumHoldSeconds,
    required this.minimumReps,
    required this.riskNote,
  });

  final int level;
  final String name;
  final String target;
  final String coachingCue;
  final int minimumHoldSeconds;
  final int minimumReps;
  final String riskNote;
}

class AdvancedSkillTree {
  const AdvancedSkillTree({
    required this.id,
    required this.name,
    required this.category,
    required this.stages,
    required this.entryRequirement,
  });

  final String id;
  final String name;
  final String category;
  final List<AdvancedSkillStage> stages;
  final String entryRequirement;
}

class FalseGripReadiness {
  const FalseGripReadiness({
    required this.score,
    required this.ready,
    required this.level,
    required this.checks,
    required this.nextAction,
  });

  final int score;
  final bool ready;
  final String level;
  final Map<String, bool> checks;
  final String nextAction;
}

class StraightArmTrend {
  const StraightArmTrend({
    required this.skillId,
    required this.bestHoldSeconds,
    required this.averageQuality,
    required this.exposures,
    required this.painFlags,
    required this.changeSeconds,
    required this.status,
  });

  final String skillId;
  final int bestHoldSeconds;
  final double averageQuality;
  final int exposures;
  final int painFlags;
  final int changeSeconds;
  final String status;
}

class SkillReadiness {
  const SkillReadiness({
    required this.skillId,
    required this.score,
    required this.status,
    required this.passedChecks,
    required this.totalChecks,
    required this.action,
  });

  final String skillId;
  final int score;
  final String status;
  final int passedChecks;
  final int totalChecks;
  final String action;
}

class SkillExposureDay {
  const SkillExposureDay({
    required this.weekday,
    required this.focusSkills,
    required this.attemptsPerSkill,
    required this.intensity,
    required this.minimumHoursBeforeNext,
    required this.note,
  });

  final int weekday;
  final List<String> focusSkills;
  final int attemptsPerSkill;
  final String intensity;
  final int minimumHoursBeforeNext;
  final String note;
}

class CalisthenicsDeloadDecision {
  const CalisthenicsDeloadDecision({
    required this.required,
    required this.level,
    required this.volumeMultiplier,
    required this.reasons,
    required this.rules,
  });

  final bool required;
  final String level;
  final double volumeMultiplier;
  final List<String> reasons;
  final List<String> rules;
}

class AdvancedCalisthenicsEngine {
  const AdvancedCalisthenicsEngine._();

  static const skillIds = <String>[
    'muscle-up',
    'front-lever',
    'back-lever',
    'planche',
    'handstand-push-up',
    'ring-support',
  ];

  static List<AdvancedSkillTree> get trees => [
    _tree(
      id: 'muscle-up',
      name: 'MUSCLE-UP',
      category: 'PULL + TRANSITION',
      entryRequirement:
          '8 strict pull-ups, 15 strict push-ups, pain-free shoulders',
      stages: const [
        (
          'Scapular pull + hollow swing',
          '3×8 controlled',
          0,
          8,
          'No aggressive kip.',
        ),
        (
          'Chest-to-bar pull-up',
          '5 clean reps',
          0,
          5,
          'Stop below painful height.',
        ),
        (
          'Low-ring transition',
          '5 slow transitions',
          0,
          5,
          'Keep rings close.',
        ),
        (
          'Band-assisted muscle-up',
          '3×3 without chicken wing',
          0,
          3,
          'Use equal arms.',
        ),
        (
          'Strict muscle-up',
          '1 repeatable rep',
          0,
          1,
          'No maximal attempts under fatigue.',
        ),
      ],
    ),
    _tree(
      id: 'front-lever',
      name: 'FRONT LEVER',
      category: 'STRAIGHT-ARM PULL',
      entryRequirement: '8 strict pull-ups and 30s hollow hold',
      stages: const [
        ('Scapular depression hold', '20s', 20, 0, 'Elbows fully locked.'),
        ('Tuck front lever', '12s', 12, 0, 'Posterior pelvic tilt.'),
        ('Advanced tuck lever', '10s', 10, 0, 'No elbow softness.'),
        (
          'One-leg front lever',
          '8s each side',
          8,
          0,
          'Alternate sides evenly.',
        ),
        ('Full front lever', '5s clean hold', 5, 0, 'Stop before lumbar arch.'),
      ],
    ),
    _tree(
      id: 'back-lever',
      name: 'BACK LEVER',
      category: 'STRAIGHT-ARM EXTENSION',
      entryRequirement: '30s ring support and pain-free shoulder extension',
      stages: const [
        (
          'German hang control',
          '15s pain-free',
          15,
          0,
          'Never force shoulder depth.',
        ),
        ('Tuck back lever', '12s', 12, 0, 'Keep rings turned consistently.'),
        ('Advanced tuck back lever', '10s', 10, 0, 'Locked elbows only.'),
        (
          'Straddle back lever',
          '8s',
          8,
          0,
          'Reduce range if biceps tendon complains.',
        ),
        (
          'Full back lever',
          '5s clean hold',
          5,
          0,
          'No loaded stretching under fatigue.',
        ),
      ],
    ),
    _tree(
      id: 'planche',
      name: 'PLANCHE',
      category: 'STRAIGHT-ARM PUSH',
      entryRequirement: '20 push-ups, 20s hollow hold and pain-free wrists',
      stages: const [
        (
          'Planche lean',
          '20s with protraction',
          20,
          0,
          'Use tolerable wrist angle.',
        ),
        ('Tuck planche', '10s', 10, 0, 'Lock elbows; stop if they bend.'),
        ('Advanced tuck planche', '8s', 8, 0, 'Small progressive leans only.'),
        ('Straddle planche', '5s', 5, 0, 'Avoid daily maximal attempts.'),
        (
          'Full planche',
          '3s controlled',
          3,
          0,
          'Quality exposure, not grind time.',
        ),
      ],
    ),
    _tree(
      id: 'handstand-push-up',
      name: 'HANDSTAND PUSH-UP',
      category: 'VERTICAL PUSH',
      entryRequirement: '20s wall handstand, 15 push-ups and overhead mobility',
      stages: const [
        ('Pike push-up', '10 clean reps', 0, 10, 'Head travels between hands.'),
        (
          'Elevated pike push-up',
          '8 clean reps',
          0,
          8,
          'No cervical compression.',
        ),
        ('Wall eccentric HSPU', '5×5s descent', 0, 5, 'Use a padded target.'),
        (
          'Partial wall HSPU',
          '5 controlled reps',
          0,
          5,
          'Increase range gradually.',
        ),
        (
          'Full wall HSPU',
          '3 strict reps',
          0,
          3,
          'Stop before line or depth degrades.',
        ),
      ],
    ),
    _tree(
      id: 'ring-support',
      name: 'RING SUPPORT',
      category: 'RING STABILITY',
      entryRequirement: '10 push-ups and pain-free elbows',
      stages: const [
        ('Foot-assisted support', '30s', 30, 0, 'Shoulders depressed.'),
        ('Neutral ring support', '20s', 20, 0, 'Rings close to hips.'),
        ('Turned-out support', '15s', 15, 0, 'Rotate only as control allows.'),
        ('Support with knee raise', '8 reps', 0, 8, 'No shoulder shrug.'),
        (
          'Stable RTO support',
          '30s',
          30,
          0,
          'Maintain locked elbows pain-free.',
        ),
      ],
    ),
  ];

  static AdvancedSkillTree tree(String skillId) =>
      trees.firstWhere((tree) => tree.id == skillId, orElse: () => trees.first);

  static int currentStage(String skillId, List<CalisthenicsSkillLog> logs) {
    final stages = tree(skillId).stages;
    var achieved = 0;
    for (final log in logs.where((item) => item.skillId == skillId)) {
      if (log.quality < 4 || log.elbowPain >= 2) continue;
      final explicitStage = _stageFromProgression(log.progression);
      if (explicitStage > 0) {
        if (explicitStage > achieved) achieved = explicitStage;
        continue;
      }
      for (final stage in stages) {
        final holdPassed =
            stage.minimumHoldSeconds > 0 &&
            log.holdSeconds >= stage.minimumHoldSeconds;
        final repPassed =
            stage.minimumReps > 0 && log.repetitions >= stage.minimumReps;
        if ((holdPassed || repPassed) && stage.level > achieved) {
          achieved = stage.level;
        }
      }
    }
    return achieved.clamp(0, stages.length);
  }

  static FalseGripReadiness falseGripReadiness({
    required int hangSeconds,
    required int ringSupportSeconds,
    required int wristPain,
    required bool secureContact,
  }) {
    final checks = <String, bool>{
      '20s false-grip hang': hangSeconds >= 20,
      '15s stable ring support': ringSupportSeconds >= 15,
      'Pain ≤ 1/5': wristPain <= 1,
      'Secure wrist contact': secureContact,
    };
    final passed = checks.values.where((value) => value).length;
    final score = (passed / checks.length * 100).round();
    return FalseGripReadiness(
      score: score,
      ready: passed == checks.length,
      level: passed == checks.length
          ? 'READY'
          : passed >= 3
          ? 'BUILDING'
          : 'NOT READY',
      checks: checks,
      nextAction: wristPain >= 2
          ? 'Pause loaded false grip and use a pain-free neutral grip.'
          : hangSeconds < 20
          ? 'Build 4×10–20s assisted false-grip hangs.'
          : ringSupportSeconds < 15
          ? 'Build stable neutral ring support before transitions.'
          : 'Practice low-ring transitions with equal arms.',
    );
  }

  static StraightArmTrend straightArmTrend(
    String skillId,
    List<CalisthenicsSkillLog> logs,
  ) {
    final selected =
        logs
            .where((item) => item.skillId == skillId && item.straightArm)
            .toList()
          ..sort((left, right) => left.recordedAt.compareTo(right.recordedAt));
    if (selected.isEmpty) {
      return StraightArmTrend(
        skillId: skillId,
        bestHoldSeconds: 0,
        averageQuality: 0,
        exposures: 0,
        painFlags: 0,
        changeSeconds: 0,
        status: 'NO DATA',
      );
    }
    final half = (selected.length / 2).ceil();
    final recent = selected.skip(selected.length - half).toList();
    final earlier = selected.take(selected.length - half).toList();
    int best(List<CalisthenicsSkillLog> values) => values.isEmpty
        ? 0
        : values
              .map((item) => item.holdSeconds)
              .reduce((left, right) => left > right ? left : right);
    final recentBest = best(recent);
    final earlierBest = best(earlier);
    final quality =
        selected.fold<int>(0, (sum, item) => sum + item.quality) /
        selected.length;
    final pain = selected.where((item) => item.elbowPain >= 2).length;
    return StraightArmTrend(
      skillId: skillId,
      bestHoldSeconds: best(selected),
      averageQuality: quality,
      exposures: selected.length,
      painFlags: pain,
      changeSeconds: recentBest - earlierBest,
      status: pain > 0
          ? 'PAIN FLAG'
          : quality >= 4 && recentBest >= earlierBest
          ? 'PROGRESSING'
          : 'HOLD',
    );
  }

  static SkillReadiness readiness(
    String skillId,
    FitnessData data, {
    UserProfile? profile,
  }) {
    double assessment(String id) =>
        CalisthenicsEngine.latest(data.skillAssessments, id)?.value ?? 0;
    final pull = assessment('pull-up');
    final push = assessment('push-up');
    final hollow = assessment('hollow-hold');
    final handstand = assessment('handstand');
    final overhead = assessment('mobility-overhead');
    final falseGrip = assessment('false-grip');
    final ringSupport = assessment('ring-support');
    final limits = profile?.limitations.toLowerCase() ?? '';
    final painFree =
        !limits.contains('shoulder') &&
        !limits.contains('elbow') &&
        !limits.contains('wrist') &&
        !limits.contains('ώμ') &&
        !limits.contains('αγκ') &&
        !limits.contains('καρπ');
    final checks = switch (skillId) {
      'muscle-up' => [pull >= 8, push >= 15, falseGrip >= 20, painFree],
      'front-lever' => [pull >= 8, hollow >= 30, painFree],
      'back-lever' => [ringSupport >= 20, overhead >= 60, painFree],
      'planche' => [push >= 20, hollow >= 20, painFree],
      'handstand-push-up' => [
        handstand >= 20,
        push >= 15,
        overhead >= 60,
        painFree,
      ],
      'ring-support' => [push >= 10, painFree],
      _ => [painFree],
    };
    final passed = checks.where((value) => value).length;
    final score = (passed / checks.length * 100).round();
    final status = score == 100
        ? 'READY'
        : score >= 60
        ? 'BUILD BASE'
        : 'FOUNDATION';
    return SkillReadiness(
      skillId: skillId,
      score: score,
      status: status,
      passedChecks: passed,
      totalChecks: checks.length,
      action: score == 100
          ? 'Use the next unmastered stage for quality submaximal exposures.'
          : painFree
          ? 'Build the listed entry requirements before harder leverage.'
          : 'Use only pain-free regressions and address the limitation first.',
    );
  }

  static List<SkillExposureDay> exposureSchedule({
    required Set<String> selectedSkills,
    required int daysPerWeek,
    required FitnessData data,
    UserProfile? profile,
  }) {
    final selected = selectedSkills.isEmpty
        ? {'muscle-up', 'front-lever'}
        : selectedSkills.take(3).toSet();
    final days = daysPerWeek.clamp(2, 5);
    final weekdays = switch (days) {
      2 => [1, 4],
      3 => [1, 3, 6],
      4 => [1, 2, 4, 6],
      _ => [1, 2, 4, 5, 7],
    };
    final ready = {
      for (final skill in selected)
        skill: readiness(skill, data, profile: profile).score,
    };
    return [
      for (var index = 0; index < weekdays.length; index++)
        SkillExposureDay(
          weekday: weekdays[index],
          focusSkills: [
            for (final skill in selected.toList().asMap().entries)
              if ((skill.key + index) % days < 2) skill.value,
          ].take(2).toList(),
          attemptsPerSkill: index == days - 1 ? 3 : 4,
          intensity: index == days - 1
              ? 'EASY TECHNIQUE'
              : ready.values.every((score) => score >= 80)
              ? 'SUBMAXIMAL'
              : 'FOUNDATION',
          minimumHoursBeforeNext: 48,
          note: index == days - 1
              ? 'Keep this exposure easy and finish fresher than you started.'
              : 'Stop each attempt at the first technical break.',
        ),
    ].where((day) => day.focusSkills.isNotEmpty).toList();
  }

  static CalisthenicsDeloadDecision deloadDecision(
    List<CalisthenicsSkillLog> logs, {
    DateTime? now,
  }) {
    final anchor = now ?? DateTime.now();
    final recent = logs
        .where(
          (item) => item.recordedAt.isAfter(
            anchor.subtract(const Duration(days: 10)),
          ),
        )
        .toList();
    final highRpe = recent.where((item) => item.rpe >= 9).length;
    final painFlags = recent.where((item) => item.elbowPain >= 2).length;
    final lowQuality = recent.where((item) => item.quality <= 2).length;
    final straightArmExposures = recent
        .where((item) => item.straightArm)
        .length;
    final reasons = <String>[
      if (painFlags > 0) '$painFlags elbow/wrist pain exposure(s)',
      if (highRpe >= 3) '$highRpe near-max skill exposures',
      if (lowQuality >= 3) '$lowQuality low-quality exposures',
      if (straightArmExposures >= 6)
        '$straightArmExposures straight-arm exposures in 10 days',
    ];
    final severe = painFlags >= 2 || (highRpe >= 3 && lowQuality >= 3);
    final required = reasons.isNotEmpty;
    return CalisthenicsDeloadDecision(
      required: required,
      level: severe
          ? 'FULL DELOAD'
          : required
          ? 'REDUCE'
          : 'NORMAL',
      volumeMultiplier: severe
          ? .4
          : required
          ? .6
          : 1,
      reasons: reasons,
      rules: [
        if (required) 'Remove maximal holds and failed repetitions.',
        if (required) 'Use easier leverage and 40–60% of normal attempts.',
        if (painFlags > 0)
          'Keep every drill pain-free; seek qualified care if symptoms persist.',
        if (!required) 'Keep 1–3 reps or 3–5 seconds in reserve.',
        'Do not combine more than two high-tension skills in one session.',
        'Keep at least 48 hours between straight-arm exposures.',
      ],
    );
  }

  static AdvancedSkillTree _tree({
    required String id,
    required String name,
    required String category,
    required String entryRequirement,
    required List<(String, String, int, int, String)> stages,
  }) => AdvancedSkillTree(
    id: id,
    name: name,
    category: category,
    entryRequirement: entryRequirement,
    stages: [
      for (var index = 0; index < stages.length; index++)
        AdvancedSkillStage(
          level: index + 1,
          name: stages[index].$1,
          target: stages[index].$2,
          minimumHoldSeconds: stages[index].$3,
          minimumReps: stages[index].$4,
          riskNote: stages[index].$5,
          coachingCue: index == stages.length - 1
              ? 'Own the position; never chase a shaky record.'
              : 'Pass the target twice before moving to the next leverage.',
        ),
    ],
  );

  static int _stageFromProgression(String progression) {
    final match = RegExp(
      r'(?:stage|level)\s*(\d)',
      caseSensitive: false,
    ).firstMatch(progression);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }
}
