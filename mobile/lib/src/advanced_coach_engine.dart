import 'deterministic_coach_engine.dart';
import 'models/fitness_models.dart';

enum CoachConfidence { low, medium, high }

class ExplainedCoachRecommendation {
  const ExplainedCoachRecommendation({
    required this.action,
    required this.confidence,
    required this.confidencePercent,
    required this.why,
    required this.ruleTrace,
    required this.personalAcceptanceRate,
  });

  final CoachAction action;
  final CoachConfidence confidence;
  final int confidencePercent;
  final List<String> why;
  final List<String> ruleTrace;
  final double personalAcceptanceRate;
}

class CoachGoalPriority {
  const CoachGoalPriority({
    required this.goal,
    required this.rank,
    required this.status,
    required this.reason,
  });

  final String goal;
  final int rank;
  final String status;
  final String reason;
}

class CoachLearningSummary {
  const CoachLearningSummary({
    required this.feedbackCount,
    required this.acceptanceRate,
    required this.helpfulRate,
    required this.learnedPreference,
  });

  final int feedbackCount;
  final double acceptanceRate;
  final double helpfulRate;
  final String learnedPreference;
}

class CoachReview {
  const CoachReview({
    required this.period,
    required this.score,
    required this.wins,
    required this.gaps,
    required this.nextFocus,
  });

  final String period;
  final int score;
  final List<String> wins;
  final List<String> gaps;
  final String nextFocus;
}

class GoalDriftReport {
  const GoalDriftReport({
    required this.detected,
    required this.profileGoal,
    required this.observedBehavior,
    required this.reason,
    required this.action,
  });

  final bool detected;
  final String profileGoal;
  final String observedBehavior;
  final String reason;
  final String action;
}

class CoachSafetyEscalation {
  const CoachSafetyEscalation({
    required this.level,
    required this.title,
    required this.triggers,
    required this.action,
    required this.professionalHelp,
  });

  final int level;
  final String title;
  final List<String> triggers;
  final String action;
  final bool professionalHelp;
}

class AdvancedCoachEngine {
  const AdvancedCoachEngine._();

  static List<ExplainedCoachRecommendation> explain({
    required DailyCoachPlan plan,
    required FitnessData data,
  }) {
    final feedback = data.coachRecommendationFeedback;
    final results = plan.actions.map((action) {
      final history = feedback
          .where((item) => item.recommendationId == action.id)
          .toList();
      final acceptance = history.isEmpty
          ? .5
          : history.where((item) => item.accepted).length / history.length;
      final why = _why(action, data);
      final evidencePoints = why.length + (history.isEmpty ? 0 : 1);
      final base = switch (action.priority) {
        CoachPriority.critical => 86,
        CoachPriority.high => 78,
        CoachPriority.normal => 68,
        CoachPriority.optional => 58,
      };
      final confidence = (base + evidencePoints * 3 + ((acceptance - .5) * 10))
          .round()
          .clamp(35, 96);
      return ExplainedCoachRecommendation(
        action: action,
        confidence: confidence >= 82
            ? CoachConfidence.high
            : confidence >= 65
            ? CoachConfidence.medium
            : CoachConfidence.low,
        confidencePercent: confidence,
        why: why,
        ruleTrace: ruleTrace(action.id),
        personalAcceptanceRate: acceptance,
      );
    }).toList();
    results.sort((left, right) {
      final priority = left.action.priority.index.compareTo(
        right.action.priority.index,
      );
      if (priority != 0) return priority;
      final learned = right.personalAcceptanceRate.compareTo(
        left.personalAcceptanceRate,
      );
      if (learned != 0) return learned;
      return right.confidencePercent.compareTo(left.confidencePercent);
    });
    return results;
  }

  static List<String> _why(CoachAction action, FitnessData data) {
    final latestRecovery = data.recoveryChecks.firstOrNull;
    return switch (action.id) {
      'recovery' => [
        'The latest readiness signal is below the normal training gate.',
        if (latestRecovery != null)
          'Sleep ${latestRecovery.sleepHours.toStringAsFixed(1)}h, energy ${latestRecovery.energy}/5, soreness ${latestRecovery.soreness}/5.',
      ],
      'check-in' => [
        'No recovery check-in is available for today.',
        'Load adjustment needs a current sleep, energy and soreness signal.',
      ],
      'protein' => [
        'Logged protein is below the current daily target trajectory.',
      ],
      'water' => ['Logged hydration is below 55% of today’s local target.'],
      'calories' => ['Logged calories exceeded the target by more than 12%.'],
      'reschedule' => [
        'A planned training session is overdue.',
        'The rule protects spacing before adding another session.',
      ],
      'workout' => [
        'A scheduled session is due today.',
        'Recovery status is checked before keeping full volume.',
      ],
      _ => ['No active risk or adherence rule requires a larger change.'],
    };
  }

  static List<String> ruleTrace(String recommendationId) =>
      switch (recommendationId) {
        'recovery' => [
          'R-REC-01: readiness score < 55',
          'R-REC-02: preserve ≥2 RIR',
          'R-SAFE-01: suppress AMRAP work',
        ],
        'check-in' => [
          'R-DATA-01: readiness signal missing',
          'R-REC-00: request current input before auto-regulation',
        ],
        'water' => [
          'R-NUT-04: hydration < 55% of target',
          'R-NUT-05: prioritize gradual fluid intake',
        ],
        'protein' => [
          'R-NUT-02: protein < 70% of target trajectory',
          'R-NUT-03: prefer food-first completion',
        ],
        'calories' => [
          'R-NUT-06: calories > 112% of target',
          'R-NUT-07: no compensatory restriction',
        ],
        'reschedule' => [
          'R-SCH-01: incomplete session date < today',
          'R-SCH-02: select first unoccupied future day',
        ],
        'workout' => [
          'R-SCH-03: scheduled session date = today',
          'R-REC-03: apply recovery gate',
        ],
        _ => ['R-BASE-01: continue stable behavior without unnecessary change'],
      };

  static List<CoachGoalPriority> prioritizeGoals({
    required String profileGoal,
    required int recoveryScore,
    required bool painFlag,
    required double nutritionAdherence,
  }) {
    final priorities = <CoachGoalPriority>[];
    if (painFlag || recoveryScore < 45) {
      priorities.add(
        CoachGoalPriority(
          goal: 'Recovery & safety',
          rank: 1,
          status: 'OVERRIDES',
          reason: painFlag
              ? 'A pain flag overrides performance progression.'
              : 'Low readiness overrides intensity and volume progression.',
        ),
      );
    }
    priorities.add(
      CoachGoalPriority(
        goal: profileGoal,
        rank: priorities.length + 1,
        status: priorities.isEmpty ? 'PRIMARY' : 'PROTECTED',
        reason: 'This is the athlete’s explicit profile goal.',
      ),
    );
    priorities.add(
      CoachGoalPriority(
        goal: 'Nutrition adherence',
        rank: priorities.length + 1,
        status: nutritionAdherence >= .8 ? 'MAINTAIN' : 'SUPPORT',
        reason: nutritionAdherence >= .8
            ? 'Adherence is sufficient; avoid extra complexity.'
            : 'Consistency supports the primary goal before tighter targets.',
      ),
    );
    return priorities;
  }

  static CoachLearningSummary learning(
    List<CoachRecommendationFeedback> feedback,
  ) {
    if (feedback.isEmpty) {
      return const CoachLearningSummary(
        feedbackCount: 0,
        acceptanceRate: 0,
        helpfulRate: 0,
        learnedPreference: 'No personal preference signal yet.',
      );
    }
    final accepted = feedback.where((item) => item.accepted).length;
    final helpful = feedback.where((item) => item.helpful).length;
    final byId = <String, List<CoachRecommendationFeedback>>{};
    for (final item in feedback) {
      byId.putIfAbsent(item.recommendationId, () => []).add(item);
    }
    final ranked = byId.entries.toList()
      ..sort(
        (left, right) => right.value
            .where((item) => item.accepted)
            .length
            .compareTo(left.value.where((item) => item.accepted).length),
      );
    return CoachLearningSummary(
      feedbackCount: feedback.length,
      acceptanceRate: accepted / feedback.length,
      helpfulRate: helpful / feedback.length,
      learnedPreference:
          'Most accepted action: ${ranked.first.key.replaceAll('-', ' ')}.',
    );
  }

  static CoachReview weeklyReview({
    required FitnessData data,
    required DateTime now,
    required double nutritionAdherence,
  }) => _review(
    data: data,
    now: now,
    days: 7,
    nutritionAdherence: nutritionAdherence,
    period: 'WEEKLY REVIEW',
  );

  static CoachReview monthlyReview({
    required FitnessData data,
    required DateTime now,
    required double nutritionAdherence,
  }) => _review(
    data: data,
    now: now,
    days: 30,
    nutritionAdherence: nutritionAdherence,
    period: 'MONTHLY REVIEW',
  );

  static CoachReview _review({
    required FitnessData data,
    required DateTime now,
    required int days,
    required double nutritionAdherence,
    required String period,
  }) {
    final cutoff = now.subtract(Duration(days: days));
    final workouts = data.logs.where(
      (item) => item.completedAt.isAfter(cutoff),
    );
    final recovery = data.recoveryChecks.where(
      (item) => item.recordedAt.isAfter(cutoff),
    );
    final workoutCount = workouts.length;
    final recoveryCount = recovery.length;
    final target = data.profile?.daysPerWeek ?? 3;
    final expected = (target * days / 7).round().clamp(1, 31);
    final adherence = (workoutCount / expected).clamp(0, 1);
    final score =
        ((adherence * .55 +
                    nutritionAdherence * .3 +
                    (recoveryCount > 0 ? .15 : 0)) *
                100)
            .round();
    final wins = <String>[
      if (workoutCount > 0) '$workoutCount completed training session(s)',
      if (nutritionAdherence >= .8) 'Nutrition adherence above 80%',
      if (recoveryCount >= (days / 3).round())
        '$recoveryCount recovery check-in(s)',
    ];
    final gaps = <String>[
      if (workoutCount < expected)
        '${expected - workoutCount} session(s) below the planned cadence',
      if (nutritionAdherence < .8) 'Nutrition consistency below 80%',
      if (recoveryCount == 0) 'No recovery trend data',
    ];
    return CoachReview(
      period: period,
      score: score.clamp(0, 100),
      wins: wins.isEmpty ? const ['A review baseline is now available'] : wins,
      gaps: gaps.isEmpty ? const ['No material consistency gap'] : gaps,
      nextFocus: gaps.isEmpty
          ? 'Keep the current system unchanged for the next period.'
          : gaps.first,
    );
  }

  static GoalDriftReport goalDrift(FitnessData data, {DateTime? now}) {
    final anchor = now ?? DateTime.now();
    final cutoff = anchor.subtract(const Duration(days: 28));
    final recent = data.logs.where((item) => item.completedAt.isAfter(cutoff));
    final strengthSessions = recent
        .where(
          (item) =>
              item.sets.any((set) => set.weightKilograms > 0 && set.reps <= 8),
        )
        .length;
    final conditioningSessions =
        data.cardioSessions
            .where((item) => item.recordedAt.isAfter(cutoff))
            .length +
        data.runningSessions
            .where((item) => item.recordedAt.isAfter(cutoff))
            .length +
        data.cyclingSessions
            .where((item) => item.recordedAt.isAfter(cutoff))
            .length +
        data.rowingSessions
            .where((item) => item.recordedAt.isAfter(cutoff))
            .length;
    final observed = conditioningSessions > strengthSessions * 1.5
        ? 'Conditioning-dominant'
        : strengthSessions > conditioningSessions * 1.5
        ? 'Strength-dominant'
        : 'Mixed training';
    final goal = data.profile?.goal ?? 'General fitness';
    final expectsStrength =
        goal.toLowerCase().contains('strength') || goal.contains('Δύναμη');
    final expectsFatLoss =
        goal.toLowerCase().contains('fat') || goal.contains('λίπους');
    final drift =
        (expectsStrength && observed == 'Conditioning-dominant') ||
        (!expectsFatLoss &&
            conditioningSessions >= 4 &&
            strengthSessions == 0 &&
            observed == 'Conditioning-dominant');
    return GoalDriftReport(
      detected: drift,
      profileGoal: goal,
      observedBehavior: observed,
      reason: drift
          ? 'The last 28 days emphasize a different training mode than the profile goal.'
          : 'Recent training broadly matches the explicit profile goal.',
      action: drift
          ? 'Confirm the goal before changing the program—behavior may reflect a deliberate new priority.'
          : 'Keep the profile goal and review again after another training block.',
    );
  }

  static CoachSafetyEscalation safetyEscalation(
    FitnessData data, {
    DateTime? now,
  }) {
    final anchor = now ?? DateTime.now();
    final cutoff = anchor.subtract(const Duration(days: 14));
    final recentPain = data.logs
        .where(
          (item) => item.completedAt.isAfter(cutoff) && item.painSeverity >= 3,
        )
        .toList();
    final severePain = recentPain.where((item) => item.painSeverity >= 4);
    final lowRecovery = data.recoveryChecks
        .where((item) => item.recordedAt.isAfter(cutoff))
        .where(
          (item) =>
              item.sleepHours < 6 ||
              item.energy <= 2 ||
              item.soreness >= 5 ||
              item.stress >= 5,
        )
        .length;
    final triggers = <String>[
      if (data.recoveryStatus.illnessMode) 'Illness mode is active',
      if (severePain.isNotEmpty)
        '${severePain.length} severe pain log(s) in 14 days',
      if (recentPain.length >= 3) 'Repeated pain flags',
      if (lowRecovery >= 3) 'Repeated low-recovery mornings',
    ];
    final professional =
        data.recoveryStatus.illnessMode ||
        severePain.isNotEmpty ||
        recentPain.length >= 3;
    final level = professional
        ? 3
        : lowRecovery >= 3
        ? 2
        : triggers.isNotEmpty
        ? 1
        : 0;
    return CoachSafetyEscalation(
      level: level,
      title: level == 3
          ? 'STOP & SEEK ASSESSMENT'
          : level == 2
          ? 'RECOVERY ESCALATION'
          : level == 1
          ? 'CAUTION'
          : 'NO SAFETY ESCALATION',
      triggers: triggers.isEmpty
          ? const ['No red-flag rule triggered']
          : triggers,
      action: level == 3
          ? 'Pause hard training. Persistent or severe symptoms need qualified medical assessment.'
          : level == 2
          ? 'Use recovery work or rest and reassess after two easier days.'
          : 'Continue with normal technical stop rules and symptom monitoring.',
      professionalHelp: professional,
    );
  }
}
