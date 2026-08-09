import 'package:flutter/material.dart';

import 'advanced_feature_pack_engine.dart';
import 'state/fitness_store.dart';

class AdvancedFeaturePackPage extends StatelessWidget {
  const AdvancedFeaturePackPage({super.key, required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 5,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('ATHLETE INTELLIGENCE'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'WEARABLES', icon: Icon(Icons.watch_outlined)),
            Tab(text: 'PROGRESS', icon: Icon(Icons.military_tech_outlined)),
            Tab(text: 'CHALLENGES', icon: Icon(Icons.flag_outlined)),
            Tab(text: 'ASSESSMENT', icon: Icon(Icons.fact_check_outlined)),
            Tab(text: 'CALENDAR', icon: Icon(Icons.calendar_month_outlined)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => TabBarView(
          children: [
            _WearablesTab(store: store),
            _ProgressTab(store: store),
            _ChallengesTab(store: store),
            _AssessmentTab(store: store),
            _CalendarTab(store: store),
          ],
        ),
      ),
    ),
  );
}

class _WearablesTab extends StatelessWidget {
  const _WearablesTab({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final report = AdvancedFeaturePackEngine.wearable(
      store.data,
      now: DateTime.now(),
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _FeatureHero(
          icon: Icons.watch_outlined,
          title: 'WEARABLE QUALITY & READINESS',
          detail:
              'Fourteen-day personal medians. Missing data lowers confidence instead of being silently guessed.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Metric(label: 'QUALITY', value: '${report.qualityScore}%'),
            _Metric(
              label: 'READINESS INPUT',
              value: '${report.readinessContribution}/100',
            ),
            _Metric(label: 'STEPS BASELINE', value: '${report.stepsBaseline}'),
            _Metric(
              label: 'RHR BASELINE',
              value: report.restingHeartRateBaseline == 0
                  ? 'NO DATA'
                  : '${report.restingHeartRateBaseline} bpm',
            ),
            _Metric(
              label: 'SLEEP BASELINE',
              value: report.sleepMinutesBaseline == 0
                  ? 'NO DATA'
                  : '${report.sleepMinutesBaseline} min',
            ),
            _Metric(label: 'MISSING DAYS', value: '${report.missingDays}/14'),
          ],
        ),
        const SizedBox(height: 14),
        _InfoCard(
          title: 'SOURCE COMPARISON',
          lines: report.sourceCounts.isEmpty
              ? const ['No wearable source has been imported in this window.']
              : report.sourceCounts.entries
                    .map((item) => '${item.key}: ${item.value} day(s)')
                    .toList(),
        ),
        _InfoCard(
          title: 'QUALITY ALERTS',
          lines: report.alerts.isEmpty
              ? const ['No quality alert for the current 14-day window.']
              : report.alerts,
        ),
        const _InfoCard(
          title: 'HRV STATUS',
          lines: [
            'HRV is marked unavailable because the current Phoenix data model does not capture it. No synthetic value is shown.',
          ],
        ),
      ],
    );
  }
}

class _ProgressTab extends StatelessWidget {
  const _ProgressTab({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final progress = AdvancedFeaturePackEngine.athleteProgress(store.data);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _FeatureHero(
          icon: Icons.military_tech_outlined,
          title: 'LOCAL XP & BADGES',
          detail:
              'Experience is derived from completed sessions, detailed sets, check-ins, nutrition and skill assessments.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Metric(label: 'LEVEL', value: '${progress.level}'),
            _Metric(label: 'TOTAL XP', value: '${progress.experiencePoints}'),
            _Metric(label: 'BADGES', value: '${progress.badges.length}'),
            _Metric(
              label: 'SKILLS TRACKED',
              value: '${progress.skillExperience.length}',
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (progress.badges.isEmpty)
          const _InfoCard(
            title: 'NEXT MILESTONE',
            lines: ['Complete one session to earn First Session.'],
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final badge in progress.badges)
                    Chip(
                      avatar: const Icon(Icons.workspace_premium, size: 18),
                      label: Text(
                        '$badge · ${progress.rarity[badge]?.toUpperCase()}',
                      ),
                    ),
                ],
              ),
            ),
          ),
        _InfoCard(
          title: 'SKILL EXPERIENCE',
          lines: progress.skillExperience.isEmpty
              ? const ['No skill assessment is available yet.']
              : progress.skillExperience.entries
                    .map((item) => '${item.key}: ${item.value} XP')
                    .toList(),
        ),
      ],
    );
  }
}

class _ChallengesTab extends StatelessWidget {
  const _ChallengesTab({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const _FeatureHero(
        icon: Icons.flag_outlined,
        title: 'SAFE CHALLENGES',
        detail:
            'Every challenge has a duration and a hard maximum. Progress comes only from locally recorded evidence.',
      ),
      const SizedBox(height: 14),
      for (final challenge in AdvancedFeaturePackEngine.challengeTemplates)
        Builder(
          builder: (context) {
            final progress = AdvancedFeaturePackEngine.challengeProgress(
              challenge,
              store.data,
              now: DateTime.now(),
            );
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            challenge.title.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Text('${(progress.ratio * 100).round()}%'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: progress.ratio),
                    const SizedBox(height: 9),
                    Text(progress.report),
                    Text(
                      'Safety ceiling: ${challenge.maximumSafeTarget.toStringAsFixed(0)} · ${progress.activeDays.length} active day(s)',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
    ],
  );
}

class _AssessmentTab extends StatelessWidget {
  const _AssessmentTab({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final assessment = AdvancedFeaturePackEngine.onboarding(store.data);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _FeatureHero(
          icon: Icons.fact_check_outlined,
          title: 'MODULAR ONBOARDING ASSESSMENT',
          detail:
              'Ten checks cover goals, schedule, equipment, nutrition setup, reminders, privacy and the first program.',
        ),
        const SizedBox(height: 14),
        _Metric(
          label: 'ASSESSMENT CONFIDENCE',
          value:
              '${assessment.confidence}% · ${assessment.completedSteps}/${assessment.totalSteps}',
        ),
        const SizedBox(height: 14),
        _InfoCard(title: 'GOAL TRADE-OFF', lines: [assessment.tradeOff]),
        _InfoCard(
          title: 'SCHEDULE REALITY',
          lines: [assessment.scheduleReality],
        ),
        _InfoCard(
          title: 'PRIVACY BOUNDARY',
          lines: [assessment.privacyBoundary],
        ),
        _InfoCard(
          title: 'NEXT ACTIONS',
          lines: assessment.actions.isEmpty
              ? const ['The ten local onboarding checks are complete.']
              : assessment.actions,
        ),
      ],
    );
  }
}

class _CalendarTab extends StatelessWidget {
  const _CalendarTab({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = AdvancedFeaturePackEngine.monthCalendar(
      store.data,
      month: now,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _FeatureHero(
          icon: Icons.calendar_month_outlined,
          title: '${_monthName(now.month)} ${now.year}'.toUpperCase(),
          detail:
              'Plans, completions, density conflicts and every fourth-week deload marker in one local view.',
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: .72,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final hasActivity =
                day.planned.isNotEmpty || day.completed.isNotEmpty;
            return Tooltip(
              message: [
                ...day.planned.map((item) => 'Planned: $item'),
                ...day.completed.map((item) => 'Done: $item'),
                ...day.conflicts,
              ].join('\n'),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: hasActivity
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: day.conflicts.isNotEmpty
                        ? Theme.of(context).colorScheme.error
                        : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Text(
                        '${day.day.day}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const Spacer(),
                      if (day.completed.isNotEmpty)
                        const Icon(Icons.check_circle, size: 16),
                      if (day.planned.isNotEmpty)
                        const Icon(Icons.fitness_center, size: 16),
                      if (day.isDeload)
                        const Icon(Icons.low_priority, size: 14),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _monthName(int month) => const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][month - 1];
}

class _FeatureHero extends StatelessWidget {
  const _FeatureHero({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.primaryContainer,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, size: 34),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(detail),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, letterSpacing: .8)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    ),
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text('• $line'),
            ),
        ],
      ),
    ),
  );
}
