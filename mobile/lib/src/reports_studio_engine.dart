import 'models/fitness_models.dart';
import 'training_analytics_engine.dart';

enum PhoenixReportKind {
  weekly,
  monthly,
  nutrition,
  recovery,
  strength,
  calisthenics,
  coach,
}

class PhoenixReport {
  const PhoenixReport({
    required this.kind,
    required this.title,
    required this.periodLabel,
    required this.summary,
    required this.metrics,
    required this.actions,
    required this.generatedAt,
  });

  final PhoenixReportKind kind;
  final String title;
  final String periodLabel;
  final String summary;
  final List<ReportMetric> metrics;
  final List<String> actions;
  final DateTime generatedAt;

  String get plainText => [
    title,
    periodLabel,
    summary,
    ...metrics.map((item) => '${item.label}: ${item.value}'),
    if (actions.isNotEmpty) 'Next: ${actions.join(' | ')}',
    'Generated locally by Phoenix.',
  ].join('\n');
}

class ReportMetric {
  const ReportMetric(this.label, this.value, [this.detail = '']);

  final String label;
  final String value;
  final String detail;
}

class ReportsStudioEngine {
  const ReportsStudioEngine._();

  static PhoenixReport build({
    required FitnessData data,
    required PhoenixReportKind kind,
    required DateTime now,
  }) {
    return switch (kind) {
      PhoenixReportKind.weekly => _weekly(data, now),
      PhoenixReportKind.monthly => _monthly(data, now),
      PhoenixReportKind.nutrition => _nutrition(data, now),
      PhoenixReportKind.recovery => _recovery(data, now),
      PhoenixReportKind.strength => _strength(data, now),
      PhoenixReportKind.calisthenics => _calisthenics(data, now),
      PhoenixReportKind.coach => _coach(data, now),
    };
  }

  static PhoenixReport _weekly(FitnessData data, DateTime now) {
    final target = data.profile?.daysPerWeek ?? 3;
    final report = TrainingAnalyticsEngine.weeklyReport(
      logs: data.logs,
      workoutTarget: target,
      now: now,
    );
    return PhoenixReport(
      kind: PhoenixReportKind.weekly,
      title: 'WEEKLY ATHLETE REPORT',
      periodLabel: 'Last 7 days',
      summary: report.headline,
      metrics: [
        ReportMetric('Sessions', '${report.workouts}/${report.workoutTarget}'),
        ReportMetric('Working sets', '${report.sets}'),
        ReportMetric('Training time', '${report.minutes} min'),
        ReportMetric('Average RPE', report.averageRpe.toStringAsFixed(1)),
        ReportMetric('Pain flags', '${report.painFlags}'),
      ],
      actions: [report.action],
      generatedAt: now,
    );
  }

  static PhoenixReport _monthly(FitnessData data, DateTime now) {
    final logs = _within(data.logs, now, 28, (item) => item.completedAt);
    final previous = _within(
      data.logs,
      now.subtract(const Duration(days: 28)),
      28,
      (item) => item.completedAt,
    );
    final minutes = logs.fold<int>(0, (sum, item) => sum + item.minutes);
    final sets = logs.fold<int>(0, (sum, item) => sum + item.sets.length);
    final change = logs.length - previous.length;
    return PhoenixReport(
      kind: PhoenixReportKind.monthly,
      title: 'MONTHLY PROGRESS REPORT',
      periodLabel: 'Last 28 days',
      summary: logs.isEmpty
          ? 'Start logging sessions to build your first monthly baseline.'
          : 'A four-week snapshot of consistency and training exposure.',
      metrics: [
        ReportMetric(
          'Sessions',
          '${logs.length}',
          '${change >= 0 ? '+' : ''}$change vs previous 28D',
        ),
        ReportMetric('Working sets', '$sets'),
        ReportMetric('Training time', '$minutes min'),
        ReportMetric(
          'Active templates',
          '${logs.map((item) => item.templateName).toSet().length}',
        ),
      ],
      actions: [
        if (logs.length < (data.profile?.daysPerWeek ?? 3) * 3)
          'Prioritize a sustainable weekly rhythm before adding volume.',
        if (logs.isNotEmpty)
          'Keep the next block focused on one measurable priority.',
      ],
      generatedAt: now,
    );
  }

  static PhoenixReport _nutrition(FitnessData data, DateTime now) {
    final meals = _within(data.meals, now, 7, (item) => item.loggedAt);
    final days = meals.map((item) => _day(item.loggedAt)).toSet().length;
    final calories = meals.fold<int>(0, (sum, item) => sum + item.calories);
    final protein = meals.fold<double>(
      0,
      (sum, item) => sum + item.proteinGrams,
    );
    final averageCalories = days == 0 ? 0 : calories / days;
    final averageProtein = days == 0 ? 0 : protein / days;
    final targetCalories = _estimatedCalories(data.profile);
    final targetProtein = (data.profile?.weightKilograms ?? 70) * 1.8;
    return PhoenixReport(
      kind: PhoenixReportKind.nutrition,
      title: 'NUTRITION ADHERENCE REPORT',
      periodLabel: 'Last 7 days',
      summary: days == 0
          ? 'No meals logged yet — this report will stay honest until data exists.'
          : 'Average intake is based only on days with logged meals.',
      metrics: [
        ReportMetric('Logged days', '$days/7'),
        ReportMetric(
          'Avg calories',
          '${averageCalories.round()} kcal',
          'target ~${targetCalories.round()} kcal',
        ),
        ReportMetric(
          'Avg protein',
          '${averageProtein.toStringAsFixed(0)} g',
          'target ~${targetProtein.toStringAsFixed(0)} g',
        ),
        ReportMetric('Meals logged', '${meals.length}'),
      ],
      actions: [
        if (days < 5)
          'Log at least one anchor meal daily to make the trend useful.',
        if (days >= 5 && averageProtein < targetProtein * .85)
          'Bring protein closer to target with one predictable high-protein meal.',
        if (days >= 5 && averageProtein >= targetProtein * .85)
          'Protein consistency is solid; keep the same simple anchors.',
      ],
      generatedAt: now,
    );
  }

  static PhoenixReport _recovery(FitnessData data, DateTime now) {
    final checks = _within(
      data.recoveryChecks,
      now,
      7,
      (item) => item.recordedAt,
    );
    final sleep = _average(checks.map((item) => item.sleepHours));
    final energy = _average(checks.map((item) => item.energy.toDouble()));
    final stress = _average(checks.map((item) => item.stress.toDouble()));
    final soreness = _average(checks.map((item) => item.soreness.toDouble()));
    final priority = sleep < 7 || stress >= 3.5 || soreness >= 3.5
        ? 'Reduce optional intensity and protect sleep before chasing progression.'
        : 'Recovery markers are stable enough for the planned work.';
    return PhoenixReport(
      kind: PhoenixReportKind.recovery,
      title: 'RECOVERY REPORT',
      periodLabel: 'Last 7 days',
      summary: checks.isEmpty
          ? 'No recovery check-ins yet — no readiness claim is made.'
          : priority,
      metrics: [
        ReportMetric('Check-ins', '${checks.length}/7'),
        ReportMetric('Sleep', '${sleep.toStringAsFixed(1)} h'),
        ReportMetric('Energy', '${energy.toStringAsFixed(1)}/5'),
        ReportMetric('Stress', '${stress.toStringAsFixed(1)}/5'),
        ReportMetric('Soreness', '${soreness.toStringAsFixed(1)}/5'),
      ],
      actions: [
        if (checks.length < 5)
          'Add a quick morning check-in for a more reliable recovery signal.',
        priority,
      ],
      generatedAt: now,
    );
  }

  static PhoenixReport _strength(FitnessData data, DateTime now) {
    final maxes = data.strengthTrainingMaxes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final tests = _within(
      data.strengthTests,
      now,
      90,
      (item) => item.recordedAt,
    );
    return PhoenixReport(
      kind: PhoenixReportKind.strength,
      title: 'STRENGTH REPORT',
      periodLabel: 'Current training maxes · recent 90 days',
      summary: maxes.isEmpty
          ? 'Set a training max or log a strength test to establish a strength baseline.'
          : 'Training maxes are planning inputs, not a reason to force a maximal attempt.',
      metrics: [
        for (final item in maxes.take(4))
          ReportMetric(item.key, '${item.value.toStringAsFixed(1)} kg'),
        ReportMetric('Recent strength tests', '${tests.length}'),
      ],
      actions: [
        if (maxes.isNotEmpty)
          'Progress only when technique and recovery remain stable.',
        if (maxes.isEmpty)
          'Use the Strength Lab to add conservative training maxes.',
      ],
      generatedAt: now,
    );
  }

  static PhoenixReport _calisthenics(FitnessData data, DateTime now) {
    final logs = _within(
      data.calisthenicsSkillLogs,
      now,
      28,
      (item) => item.recordedAt,
    );
    final quality = _average(logs.map((item) => item.quality.toDouble()));
    final pain = logs.where((item) => item.elbowPain >= 3).length;
    return PhoenixReport(
      kind: PhoenixReportKind.calisthenics,
      title: 'CALISTHENICS SKILL REPORT',
      periodLabel: 'Last 28 days',
      summary: logs.isEmpty
          ? 'Log a skill exposure to begin tracking quality and tolerance.'
          : 'Quality matters more than rushing to the next progression.',
      metrics: [
        ReportMetric('Skill exposures', '${logs.length}'),
        ReportMetric(
          'Skills practiced',
          '${logs.map((item) => item.skillId).toSet().length}',
        ),
        ReportMetric('Average quality', '${quality.toStringAsFixed(1)}/5'),
        ReportMetric('Elbow pain flags', '$pain'),
      ],
      actions: [
        if (pain > 0)
          'Back off straight-arm volume and use a pain-free regression.',
        if (logs.isNotEmpty && pain == 0)
          'Keep the same progression until quality is consistently high.',
      ],
      generatedAt: now,
    );
  }

  static PhoenixReport _coach(FitnessData data, DateTime now) {
    final profile = data.profile;
    final weekly = _weekly(data, now);
    final recovery = _recovery(data, now);
    return PhoenixReport(
      kind: PhoenixReportKind.coach,
      title: 'COACH HANDOFF',
      periodLabel: 'Local summary · no cloud sharing',
      summary: profile == null
          ? 'Complete the profile to create a useful handoff brief.'
          : '${profile.goal} · ${profile.daysPerWeek} days/week · ${profile.trainingPlace}.',
      metrics: [
        ReportMetric('Weekly sessions', weekly.metrics.first.value),
        ReportMetric('Recovery check-ins', recovery.metrics.first.value),
        ReportMetric(
          'Limitations',
          profile?.limitations.trim().isEmpty ?? true
              ? 'None recorded'
              : profile!.limitations,
        ),
        ReportMetric('Recent pain flags', weekly.metrics.last.value),
      ],
      actions: [
        'Review current goal, constraints and recent tolerance before changing the plan.',
        'This is a training summary, not medical advice.',
      ],
      generatedAt: now,
    );
  }

  static List<T> _within<T>(
    List<T> source,
    DateTime end,
    int days,
    DateTime Function(T) date,
  ) {
    final start = end.subtract(Duration(days: days));
    return source
        .where(
          (item) => !date(item).isBefore(start) && !date(item).isAfter(end),
        )
        .toList();
  }

  static double _average(Iterable<double> values) {
    final list = values.toList();
    return list.isEmpty ? 0 : list.reduce((a, b) => a + b) / list.length;
  }

  static DateTime _day(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static double _estimatedCalories(UserProfile? profile) {
    final weight = profile?.weightKilograms ?? 70;
    return weight *
        (profile?.goal.toLowerCase().contains('loss') ?? false ? 28 : 33);
  }
}
