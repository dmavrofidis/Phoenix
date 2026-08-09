import 'package:flutter/material.dart';

import 'advanced_coach_engine.dart';
import 'deterministic_coach_engine.dart';
import 'state/fitness_store.dart';

class AdvancedCoachPage extends StatefulWidget {
  const AdvancedCoachPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<AdvancedCoachPage> createState() => _AdvancedCoachPageState();
}

class _AdvancedCoachPageState extends State<AdvancedCoachPage> {
  FitnessStore get store => widget.store;

  DailyCoachPlan get _plan {
    final targets = store.nutritionTargets;
    return DeterministicCoachEngine.dailyPlan(
      data: store.data,
      schedule: store.weeklySchedule,
      recoveryScore: store.todaysRecoveryPlan?.score ?? 0,
      caloriesToday: store.caloriesToday,
      calorieTarget: targets.calories,
      proteinToday: store.proteinToday,
      proteinTarget: targets.proteinGrams,
      hydrationToday: store.waterTodayMilliliters,
      hydrationTarget: store.hydrationTargetMilliliters,
      now: DateTime.now(),
    );
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _feedback(
    String id, {
    required bool accepted,
    required bool helpful,
  }) async {
    await store.saveCoachRecommendationFeedback(
      recommendationId: id,
      accepted: accepted,
      helpful: helpful,
    );
    if (mounted) {
      _message(accepted ? 'Recommendation accepted.' : 'Feedback saved.');
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('ADVANCED COACH'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'EXPLAIN', icon: Icon(Icons.psychology_alt_outlined)),
            Tab(text: 'PRIORITIES', icon: Icon(Icons.low_priority)),
            Tab(text: 'REVIEWS', icon: Icon(Icons.fact_check_outlined)),
            Tab(text: 'SAFETY', icon: Icon(Icons.health_and_safety_outlined)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => TabBarView(
          children: [
            _explainTab(context),
            _prioritiesTab(context),
            _reviewsTab(context),
            _safetyTab(context),
          ],
        ),
      ),
    ),
  );

  Widget _explainTab(BuildContext context) {
    final recommendations = AdvancedCoachEngine.explain(
      plan: _plan,
      data: store.data,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _CoachHero(
          icon: Icons.psychology_alt_outlined,
          title: 'EXPLAINABLE RECOMMENDATIONS',
          detail:
              'Every card exposes its evidence, confidence and deterministic rule trace. No hidden AI decision.',
        ),
        const SizedBox(height: 14),
        for (final item in recommendations)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _ConfidenceBadge(item: item),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.action.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(item.action.detail),
                  const Divider(height: 24),
                  const Text(
                    'WHY THIS APPEARS',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  for (final reason in item.why) Text('• $reason'),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('COACHING RULE TRACE'),
                    subtitle: Text(
                      '${item.ruleTrace.length} deterministic rules',
                    ),
                    children: [
                      for (final rule in item.ruleTrace)
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.account_tree_outlined),
                          title: Text(rule),
                        ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () => _feedback(
                          item.action.id,
                          accepted: true,
                          helpful: true,
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text('ACCEPT'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _feedback(
                          item.action.id,
                          accepted: false,
                          helpful: false,
                        ),
                        icon: const Icon(Icons.close),
                        label: const Text('NOT FOR ME'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _prioritiesTab(BuildContext context) {
    final pain = store.data.logs.any((item) => item.painSeverity >= 3);
    final priorities = AdvancedCoachEngine.prioritizeGoals(
      profileGoal: store.profile?.goal ?? 'General fitness',
      recoveryScore: store.todaysRecoveryPlan?.score ?? 70,
      painFlag: pain,
      nutritionAdherence: store.weeklyMacroAdherence,
    );
    final learning = AdvancedCoachEngine.learning(
      store.coachRecommendationFeedback,
    );
    final drift = AdvancedCoachEngine.goalDrift(store.data);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _CoachHero(
          icon: Icons.low_priority,
          title: 'COMPETING-GOAL PRIORITIES',
          detail:
              'Safety can override performance; the explicit profile goal remains visible and user-controlled.',
        ),
        const SizedBox(height: 14),
        for (final priority in priorities)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${priority.rank}')),
              title: Text(
                '${priority.goal} • ${priority.status}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(priority.reason),
            ),
          ),
        const SizedBox(height: 14),
        Text('COACH LEARNING', style: Theme.of(context).textTheme.titleMedium),
        _MetricWrap(
          children: [
            _Metric(
              label: 'FEEDBACK',
              value: '${learning.feedbackCount}',
              detail: 'LOCAL RESPONSES',
            ),
            _Metric(
              label: 'ACCEPTED',
              value: '${(learning.acceptanceRate * 100).round()}%',
              detail: 'ACTION RATE',
            ),
            _Metric(
              label: 'HELPFUL',
              value: '${(learning.helpfulRate * 100).round()}%',
              detail: 'RATING RATE',
            ),
          ],
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('LEARNED PERSONAL PREFERENCE'),
            subtitle: Text(learning.learnedPreference),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          color: drift.detected
              ? const Color(0xFF3D321E)
              : const Color(0xFF17382D),
          child: ListTile(
            leading: Icon(
              drift.detected ? Icons.alt_route : Icons.route_outlined,
            ),
            title: Text(
              drift.detected ? 'GOAL DRIFT DETECTED' : 'GOAL ALIGNMENT',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              '${drift.profileGoal} → ${drift.observedBehavior}\n'
              '${drift.reason}\n${drift.action}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _reviewsTab(BuildContext context) {
    final weekly = AdvancedCoachEngine.weeklyReview(
      data: store.data,
      now: DateTime.now(),
      nutritionAdherence: store.weeklyMacroAdherence,
    );
    final monthly = AdvancedCoachEngine.monthlyReview(
      data: store.data,
      now: DateTime.now(),
      nutritionAdherence: store.weeklyMacroAdherence,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _CoachHero(
          icon: Icons.fact_check_outlined,
          title: 'COACH REVIEWS',
          detail:
              'Weekly and monthly reviews summarize adherence, wins, gaps and one next focus from local data.',
        ),
        const SizedBox(height: 14),
        _ReviewCard(review: weekly),
        _ReviewCard(review: monthly),
      ],
    );
  }

  Widget _safetyTab(BuildContext context) {
    final safety = AdvancedCoachEngine.safetyEscalation(store.data);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _CoachHero(
          icon: Icons.health_and_safety_outlined,
          title: 'COACH SAFETY ESCALATION',
          detail:
              'Pain, illness and repeated low recovery can stop progression and point beyond app coaching.',
        ),
        const SizedBox(height: 14),
        Card(
          color: safety.level >= 3
              ? const Color(0xFF452428)
              : safety.level >= 2
              ? const Color(0xFF3D321E)
              : const Color(0xFF17382D),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LEVEL ${safety.level}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  safety.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const Divider(height: 24),
                for (final trigger in safety.triggers) Text('• $trigger'),
                const SizedBox(height: 10),
                Text(safety.action),
              ],
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(
              safety.professionalHelp
                  ? Icons.medical_information_outlined
                  : Icons.verified_user_outlined,
            ),
            title: Text(
              safety.professionalHelp
                  ? 'APP COACHING LIMIT REACHED'
                  : 'NORMAL SELF-MONITORING',
            ),
            subtitle: Text(
              safety.professionalHelp
                  ? 'Phoenix cannot diagnose or clear injury or illness. Seek qualified assessment.'
                  : 'Continue normal pain-free technique gates and readiness checks.',
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.item});

  final ExplainedCoachRecommendation item;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: switch (item.confidence) {
        CoachConfidence.high => const Color(0xFF1E5A3D),
        CoachConfidence.medium => const Color(0xFF55481F),
        CoachConfidence.low => const Color(0xFF4B3333),
      },
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      '${item.confidence.name.toUpperCase()} ${item.confidencePercent}%',
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
    ),
  );
}

class _CoachHero extends StatelessWidget {
  const _CoachHero({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFF2A253E),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, size: 34, color: const Color(0xFFD2B7FF)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
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

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final CoachReview review;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(child: Text('${review.score}')),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  review.period,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          const Text('WINS', style: TextStyle(fontWeight: FontWeight.w900)),
          for (final win in review.wins) Text('• $win'),
          const SizedBox(height: 10),
          const Text('GAPS', style: TextStyle(fontWeight: FontWeight.w900)),
          for (final gap in review.gaps) Text('• $gap'),
          const SizedBox(height: 10),
          Text('NEXT FOCUS • ${review.nextFocus}'),
        ],
      ),
    ),
  );
}

class _MetricWrap extends StatelessWidget {
  const _MetricWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 10, runSpacing: 10, children: children);
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 150,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(detail),
          ],
        ),
      ),
    ),
  );
}
