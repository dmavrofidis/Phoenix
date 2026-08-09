import 'dart:math' as math;

import 'models/fitness_models.dart';

class WearableIntelligenceReport {
  const WearableIntelligenceReport({
    required this.stepsBaseline,
    required this.restingHeartRateBaseline,
    required this.sleepMinutesBaseline,
    required this.hrvAvailable,
    required this.qualityScore,
    required this.readinessContribution,
    required this.missingDays,
    required this.alerts,
    required this.sourceCounts,
  });

  final int stepsBaseline;
  final int restingHeartRateBaseline;
  final int sleepMinutesBaseline;
  final bool hrvAvailable;
  final int qualityScore;
  final int readinessContribution;
  final int missingDays;
  final List<String> alerts;
  final Map<String, int> sourceCounts;
}

class AthleteProgress {
  const AthleteProgress({
    required this.experiencePoints,
    required this.level,
    required this.skillExperience,
    required this.badges,
    required this.rarity,
  });

  final int experiencePoints;
  final int level;
  final Map<String, int> skillExperience;
  final List<String> badges;
  final Map<String, String> rarity;
}

class ChallengeTemplate {
  const ChallengeTemplate({
    required this.id,
    required this.title,
    required this.metric,
    required this.target,
    required this.maximumSafeTarget,
    required this.days,
  });

  final String id;
  final String title;
  final String metric;
  final double target;
  final double maximumSafeTarget;
  final int days;
}

class ChallengeProgress {
  const ChallengeProgress({
    required this.current,
    required this.target,
    required this.ratio,
    required this.completed,
    required this.activeDays,
    required this.report,
  });

  final double current;
  final double target;
  final double ratio;
  final bool completed;
  final Set<DateTime> activeDays;
  final String report;
}

class OnboardingAssessment {
  const OnboardingAssessment({
    required this.completedSteps,
    required this.totalSteps,
    required this.confidence,
    required this.tradeOff,
    required this.scheduleReality,
    required this.privacyBoundary,
    required this.actions,
  });

  final int completedSteps;
  final int totalSteps;
  final int confidence;
  final String tradeOff;
  final String scheduleReality;
  final String privacyBoundary;
  final List<String> actions;
}

class LoggingCompleteness {
  const LoggingCompleteness({
    required this.score,
    required this.present,
    required this.missing,
  });

  final int score;
  final List<String> present;
  final List<String> missing;
}

class CalendarDaySummary {
  const CalendarDaySummary({
    required this.day,
    required this.planned,
    required this.completed,
    required this.isDeload,
    required this.conflicts,
  });

  final DateTime day;
  final List<String> planned;
  final List<String> completed;
  final bool isDeload;
  final List<String> conflicts;
}

class AdvancedFeaturePackEngine {
  const AdvancedFeaturePackEngine._();

  static WearableIntelligenceReport wearable(
    FitnessData data, {
    required DateTime now,
  }) {
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 13));
    final samples =
        data.wearableSummaries
            .where(
              (item) => !item.day.isBefore(start) && !item.day.isAfter(now),
            )
            .toList()
          ..sort((a, b) => a.day.compareTo(b.day));
    int median(Iterable<int> values) {
      final sorted = values.where((value) => value > 0).toList()..sort();
      if (sorted.isEmpty) return 0;
      return sorted[sorted.length ~/ 2];
    }

    final steps = median(samples.map((item) => item.steps));
    final rhr = median(samples.map((item) => item.restingHeartRate));
    final sleep = median(samples.map((item) => item.sleepMinutes));
    final uniqueDays = samples
        .map((item) => DateTime(item.day.year, item.day.month, item.day.day))
        .toSet();
    final missing = 14 - uniqueDays.length;
    final completeFields = samples.fold<int>(
      0,
      (sum, item) =>
          sum +
          (item.steps > 0 ? 1 : 0) +
          (item.restingHeartRate > 0 ? 1 : 0) +
          (item.sleepMinutes > 0 ? 1 : 0),
    );
    final possible = math.max(1, samples.length * 3);
    final quality =
        ((completeFields / possible) * 70 + (uniqueDays.length / 14) * 30)
            .round()
            .clamp(0, 100);
    var readiness = 50;
    if (sleep >= 420) readiness += 15;
    if (sleep > 0 && sleep < 360) readiness -= 20;
    if (steps >= 6000) readiness += 5;
    if (rhr > 0 && data.recoveryChecks.isNotEmpty) {
      final personalRhr = data.recoveryChecks
          .map((item) => item.restingHeartRate)
          .where((value) => value > 0)
          .toList();
      if (personalRhr.isNotEmpty) {
        final baseline =
            personalRhr.reduce((a, b) => a + b) / personalRhr.length;
        if (rhr > baseline + 7) readiness -= 20;
      }
    }
    readiness = ((readiness * quality) / 100).round().clamp(0, 100);
    final alerts = <String>[];
    if (missing > 5) {
      alerts.add('Wearable coverage is too sparse for a strong trend claim.');
    }
    if (sleep > 0 && sleep < 360) {
      alerts.add('Median sleep is below six hours.');
    }
    if (samples.length >= 2 && samples.last.steps < steps * .55) {
      alerts.add('Latest steps are substantially below the personal baseline.');
    }
    return WearableIntelligenceReport(
      stepsBaseline: steps,
      restingHeartRateBaseline: rhr,
      sleepMinutesBaseline: sleep,
      hrvAvailable: false,
      qualityScore: quality,
      readinessContribution: readiness,
      missingDays: missing,
      alerts: alerts,
      sourceCounts: {
        for (final source in samples.map((item) => item.source).toSet())
          source: samples.where((item) => item.source == source).length,
      },
    );
  }

  static AthleteProgress athleteProgress(FitnessData data) {
    final sets = data.logs.fold<int>(0, (sum, item) => sum + item.sets.length);
    final xp =
        data.logs.length * 100 +
        sets * 5 +
        data.recoveryChecks.length * 10 +
        data.meals.length * 2 +
        data.skillAssessments.length * 40;
    final level = math.max(1, (math.sqrt(xp / 100)).floor() + 1);
    final skillXp = <String, int>{};
    for (final assessment in data.skillAssessments) {
      skillXp.update(
        assessment.skillId,
        (value) => value + assessment.level * 50 + assessment.value.round(),
        ifAbsent: () => assessment.level * 50 + assessment.value.round(),
      );
    }
    final badges = <String>[
      if (data.logs.isNotEmpty) 'First Session',
      if (data.logs.length >= 10) 'Consistency 10',
      if (data.strengthTests.isNotEmpty) 'Measured Strength',
      if (data.recoveryChecks.length >= 7) 'Recovery Reporter',
      if (data.meals.length >= 14) 'Nutrition Logger',
      if (skillXp.values.any((value) => value >= 300)) 'Skill Builder',
    ];
    return AthleteProgress(
      experiencePoints: xp,
      level: level,
      skillExperience: skillXp,
      badges: badges,
      rarity: {
        for (final badge in badges)
          badge: switch (badge) {
            'Skill Builder' => 'epic',
            'Measured Strength' || 'Recovery Reporter' => 'rare',
            _ => 'common',
          },
      },
    );
  }

  static const challengeTemplates = <ChallengeTemplate>[
    ChallengeTemplate(
      id: 'strength-8',
      title: 'Eight quality strength sessions',
      metric: 'workouts',
      target: 8,
      maximumSafeTarget: 16,
      days: 28,
    ),
    ChallengeTemplate(
      id: 'mobility-12',
      title: 'Twelve mobility exposures',
      metric: 'mobility',
      target: 12,
      maximumSafeTarget: 28,
      days: 28,
    ),
    ChallengeTemplate(
      id: 'steps-100k',
      title: 'One hundred thousand steps',
      metric: 'steps',
      target: 100000,
      maximumSafeTarget: 300000,
      days: 14,
    ),
    ChallengeTemplate(
      id: 'nutrition-10',
      title: 'Ten nutrition logging days',
      metric: 'nutrition-days',
      target: 10,
      maximumSafeTarget: 28,
      days: 14,
    ),
    ChallengeTemplate(
      id: 'recovery-10',
      title: 'Ten recovery check-ins',
      metric: 'recovery',
      target: 10,
      maximumSafeTarget: 28,
      days: 14,
    ),
  ];

  static ChallengeTemplate customChallenge({
    required String title,
    required String metric,
    required double target,
    required int days,
  }) {
    final known = challengeTemplates
        .where((item) => item.metric == metric)
        .firstOrNull;
    final maximum = known?.maximumSafeTarget ?? 1000;
    if (title.trim().length < 3 ||
        days < 3 ||
        days > 90 ||
        target <= 0 ||
        target > maximum) {
      throw const FormatException('Challenge exceeds the safe local limit.');
    }
    return ChallengeTemplate(
      id: 'custom-${title.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}',
      title: title.trim(),
      metric: metric,
      target: target,
      maximumSafeTarget: maximum,
      days: days,
    );
  }

  static ChallengeProgress challengeProgress(
    ChallengeTemplate challenge,
    FitnessData data, {
    required DateTime now,
  }) {
    final start = now.subtract(Duration(days: challenge.days));
    final activeDays = <DateTime>{};
    double current;
    switch (challenge.metric) {
      case 'workouts':
        final logs = data.logs.where(
          (item) => !item.completedAt.isBefore(start),
        );
        current = logs.length.toDouble();
        activeDays.addAll(logs.map((item) => _day(item.completedAt)));
      case 'mobility':
        final logs = data.mobilityScreenLogs.where(
          (item) => !item.recordedAt.isBefore(start),
        );
        current = logs.length.toDouble();
        activeDays.addAll(logs.map((item) => _day(item.recordedAt)));
      case 'steps':
        final logs = data.wearableSummaries.where(
          (item) => !item.day.isBefore(start),
        );
        current = logs.fold<double>(0, (sum, item) => sum + item.steps);
        activeDays.addAll(
          logs.where((item) => item.steps > 0).map((item) => _day(item.day)),
        );
      case 'nutrition-days':
        activeDays.addAll(
          data.meals
              .where((item) => !item.loggedAt.isBefore(start))
              .map((item) => _day(item.loggedAt)),
        );
        current = activeDays.length.toDouble();
      case 'recovery':
        final logs = data.recoveryChecks.where(
          (item) => !item.recordedAt.isBefore(start),
        );
        current = logs.length.toDouble();
        activeDays.addAll(logs.map((item) => _day(item.recordedAt)));
      default:
        current = 0;
    }
    final ratio = (current / challenge.target).clamp(0, 1).toDouble();
    return ChallengeProgress(
      current: current,
      target: challenge.target,
      ratio: ratio,
      completed: current >= challenge.target,
      activeDays: activeDays,
      report:
          '${challenge.title}: ${current.toStringAsFixed(0)}/${challenge.target.toStringAsFixed(0)} over ${challenge.days} days. ${current >= challenge.target ? 'Completed safely.' : 'Continue without exceeding recovery.'}',
    );
  }

  static OnboardingAssessment onboarding(FitnessData data) {
    final profile = data.profile;
    final completed = <bool>[
      profile != null,
      profile?.goal.isNotEmpty ?? false,
      profile?.experienceLevel.isNotEmpty ?? false,
      profile?.daysPerWeek != null,
      profile?.sessionMinutes != null,
      profile?.equipment.isNotEmpty ?? false,
      data.mealPresets.isNotEmpty,
      data.workoutReminders.isNotEmpty,
      data.preferences.hasVaultPin,
      data.templates.isNotEmpty,
    ].where((item) => item).length;
    final days = profile?.daysPerWeek ?? 0;
    final minutes = profile?.sessionMinutes ?? 0;
    return OnboardingAssessment(
      completedSteps: completed,
      totalSteps: 10,
      confidence: (completed * 10).clamp(0, 100),
      tradeOff: profile == null
          ? 'Complete the local profile before Phoenix proposes a trade-off.'
          : '${profile.goal} is prioritized; progress speed remains secondary to repeatability and safety.',
      scheduleReality: days == 0
          ? 'Training frequency is not configured.'
          : '$days day(s) × $minutes minutes must fit the real week before adding volume.',
      privacyBoundary:
          'Profile, movement confidence, nutrition preferences and reminders remain on this device unless explicitly exported.',
      actions: [
        if (data.workoutReminders.isEmpty)
          'Choose whether local reminders are useful.',
        if (!data.preferences.hasVaultPin)
          'Review optional profile-level PIN protection.',
        if (profile == null) 'Complete the modular profile assessment.',
      ],
    );
  }

  static LoggingCompleteness loggingCompleteness(ExerciseSetLog set) {
    final fields = <String, bool>{
      'repetitions or hold': set.reps > 0 || set.holdSeconds > 0,
      'load': set.weightKilograms >= 0,
      'RIR': set.rir >= 0 && set.rir <= 5,
      'set RPE': set.setRpe > 0,
      'velocity': set.velocityNote.isNotEmpty,
      'technique': set.techniqueChecks.isNotEmpty,
    };
    final present = fields.entries
        .where((item) => item.value)
        .map((item) => item.key)
        .toList();
    final missing = fields.entries
        .where((item) => !item.value)
        .map((item) => item.key)
        .toList();
    return LoggingCompleteness(
      score: ((present.length / fields.length) * 100).round(),
      present: present,
      missing: missing,
    );
  }

  static List<CalendarDaySummary> monthCalendar(
    FitnessData data, {
    required DateTime month,
  }) {
    final first = DateTime(month.year, month.month);
    final days = DateTime(month.year, month.month + 1, 0).day;
    return [
      for (var number = 1; number <= days; number++)
        _calendarDay(data, DateTime(first.year, first.month, number)),
    ];
  }

  static CalendarDaySummary _calendarDay(FitnessData data, DateTime day) {
    final key =
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final planned = <String>[];
    final specific = data.dateAssignments[key];
    final weekly = data.weeklyAssignments['${day.weekday}'];
    final templateId = specific ?? weekly;
    if (templateId != null) {
      planned.add(
        data.templates
                .where((item) => item.id == templateId)
                .map((item) => item.name)
                .firstOrNull ??
            templateId,
      );
    }
    final completed = data.logs
        .where((item) => _day(item.completedAt) == day)
        .map((item) => item.templateName)
        .toList();
    final conflicts = <String>[];
    if (planned.length > 1) {
      conflicts.add('Multiple plans compete for this day.');
    }
    if (completed.length > 1) {
      conflicts.add('Multiple completed sessions increase density.');
    }
    final week = ((day.difference(DateTime(day.year, 1, 1)).inDays) ~/ 7) + 1;
    return CalendarDaySummary(
      day: day,
      planned: planned,
      completed: completed,
      isDeload: week % 4 == 0,
      conflicts: conflicts,
    );
  }

  static DateTime _day(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
