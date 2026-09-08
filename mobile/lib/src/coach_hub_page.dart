import 'package:flutter/material.dart';

import 'deterministic_coach_engine.dart';
import 'nutrition_page.dart';
import 'phoenix_copy.dart';
import 'phoenix_l10n.dart';
import 'recovery_lab_page.dart';
import 'state/fitness_store.dart';
import 'strength_test_page.dart';

class CoachHubPage extends StatefulWidget {
  const CoachHubPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<CoachHubPage> createState() => _CoachHubPageState();
}

class _CoachHubPageState extends State<CoachHubPage> {
  late String _techniqueExercise;

  @override
  void initState() {
    super.initState();
    _techniqueExercise = widget.store.exerciseLibrary.first;
  }

  IconData _actionIcon(String key) => switch (key) {
    'calendar' => Icons.event_repeat_outlined,
    'workout' => Icons.fitness_center,
    'recovery' => Icons.monitor_heart_outlined,
    'water' => Icons.water_drop_outlined,
    'nutrition' => Icons.restaurant_outlined,
    _ => Icons.check_circle_outline,
  };

  Color _priorityColor(CoachPriority priority) => switch (priority) {
    CoachPriority.critical => const Color(0xFFEF5350),
    CoachPriority.high => const Color(0xFFFF8A65),
    CoachPriority.normal => const Color(0xFF42A5F5),
    CoachPriority.optional => const Color(0xFF66BB6A),
  };

  Future<void> _openAction(CoachAction action) async {
    Widget? page = switch (action.route) {
      'recovery' => RecoveryLabPage(store: widget.store),
      'nutrition' => NutritionPage(store: widget.store),
      _ => null,
    };
    if (page != null) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => page));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final l = context.l10n;
        final targets = widget.store.nutritionTargets;
        final plan = DeterministicCoachEngine.dailyPlan(
          data: widget.store.data,
          schedule: widget.store.weeklySchedule,
          recoveryScore: widget.store.todaysRecoveryPlan?.score ?? 0,
          caloriesToday: widget.store.caloriesToday,
          calorieTarget: targets.calories,
          proteinToday: widget.store.proteinToday,
          proteinTarget: targets.proteinGrams,
          hydrationToday: widget.store.waterTodayMilliliters,
          hydrationTarget: widget.store.hydrationTargetMilliliters,
          now: DateTime.now(),
        );
        final plateaus = DeterministicCoachEngine.plateaus(
          widget.store.data.logs,
        );
        final missed = DeterministicCoachEngine.missedWorkout(
          widget.store.weeklySchedule,
          DateTime.now(),
        );
        final technique = DeterministicCoachEngine.techniqueFor(
          _techniqueExercise,
        );
        final phases = DeterministicCoachEngine.phaseRoadmap(
          profile: widget.store.profile,
          logs: widget.store.data.logs,
          now: DateTime.now(),
        );
        return Scaffold(
          appBar: AppBar(title: const Text('PHOENIX COACH')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 36),
            children: [
              _CoachScoreCard(plan: plan),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.text('ΣΗΜΕΡΙΝΟ ACTION PLAN', 'TODAY’S ACTION PLAN'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Text('${plan.actions.length}/5'),
                ],
              ),
              const SizedBox(height: 9),
              for (final action in plan.actions)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: () => _openAction(action),
                    leading: CircleAvatar(
                      backgroundColor: _priorityColor(
                        action.priority,
                      ).withValues(alpha: .15),
                      child: Icon(
                        _actionIcon(action.iconKey),
                        color: _priorityColor(action.priority),
                      ),
                    ),
                    title: Text(
                      action.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(action.detail),
                    trailing: action.route.isEmpty
                        ? null
                        : const Icon(Icons.chevron_right),
                  ),
                ),
              if (missed != null) ...[
                const SizedBox(height: 10),
                _RescheduleCard(
                  suggestion: missed,
                  onApply: () async {
                    await widget.store.rescheduleWorkout(
                      template: missed.workout.template,
                      targetDate: missed.suggestedDate,
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l.text(
                            'Η προπόνηση μεταφέρθηκε στις ${missed.suggestedDate.day}/${missed.suggestedDate.month}.',
                            'Workout moved to ${missed.suggestedDate.day}/${missed.suggestedDate.month}.',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'PLATEAU RADAR',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Text('${plateaus.length}'),
                ],
              ),
              const SizedBox(height: 8),
              if (plateaus.isEmpty)
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.trending_up,
                      color: Color(0xFF66BB6A),
                    ),
                    title: Text(
                      l.text('Δεν ανιχνεύεται plateau', 'No plateau detected'),
                    ),
                    subtitle: Text(
                      l.text(
                        'Χρειάζονται τουλάχιστον 4 μετρήσιμες συνεδρίες ανά άσκηση.',
                        'At least 4 measurable sessions per exercise are required.',
                      ),
                    ),
                  ),
                )
              else
                for (final plateau in plateaus)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.horizontal_rule,
                        color: Color(0xFFFFB74D),
                      ),
                      title: Text(
                        plateau.exerciseName,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(plateau.recommendation),
                      trailing: Text(
                        '${plateau.changePercent.toStringAsFixed(1)}%',
                      ),
                    ),
                  ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'TECHNIQUE CHECKLIST',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => StrengthTestPage(store: widget.store),
                      ),
                    ),
                    icon: const Icon(Icons.science_outlined),
                    label: const Text('TEST LAB'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _techniqueExercise,
                isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: widget.store.exerciseLibrary
                    .map(
                      (exercise) => DropdownMenuItem(
                        value: exercise,
                        child: Text(exercise, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _techniqueExercise = value!),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final item in technique.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: Color(0xFF66BB6A),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(item)),
                            ],
                          ),
                        ),
                      const Divider(),
                      Text(
                        technique.stopRule,
                        style: const TextStyle(
                          color: Color(0xFFFFAB91),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                l.text('16-ΕΒΔΟΜΑΔΩΝ ROADMAP', '16-WEEK ROADMAP'),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              for (final phase in phases) _PhaseCard(phase: phase),
            ],
          ),
        );
      },
    );
  }
}

class _CoachScoreCard extends StatelessWidget {
  const _CoachScoreCard({required this.plan});

  final DailyCoachPlan plan;

  @override
  Widget build(BuildContext context) {
    final color = plan.score >= 85
        ? const Color(0xFF66BB6A)
        : plan.score >= 65
        ? const Color(0xFFFFB74D)
        : const Color(0xFFEF5350);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: .22), const Color(0xFF111111)],
        ),
        border: Border.all(color: color.withValues(alpha: .55)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 78,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: plan.score / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white10,
                  color: color,
                ),
                Center(
                  child: Text(
                    '${plan.score}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 23,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DAILY CONTROL SCORE',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  plan.headline,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Deterministic • local • explainable',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RescheduleCard extends StatelessWidget {
  const _RescheduleCard({required this.suggestion, required this.onApply});

  final MissedWorkoutSuggestion suggestion;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFF21170D),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text(
              'Μεταφορά προπόνησης που χάθηκε',
              'Missed-workout rescheduler',
            ),
            style: const TextStyle(
              color: Color(0xFFFFB74D),
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${PhoenixCopy.workoutName(context.l10n, suggestion.workout.template)} → '
            '${suggestion.suggestedDate.day}/${suggestion.suggestedDate.month}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          Text(suggestion.reason),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: onApply,
            icon: const Icon(Icons.event_available_outlined),
            label: const Text('Εφαρμογή μεταφοράς'),
          ),
        ],
      ),
    ),
  );
}

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({required this.phase});

  final TrainingPhase phase;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    color: phase.isCurrent ? const Color(0xFF182218) : null,
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 58,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: phase.isCurrent
                  ? const Color(0x3366BB6A)
                  : Colors.white.withValues(alpha: .05),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              'W${phase.weekStart}–${phase.weekEnd}',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${phase.name}${phase.isCurrent ? ' • NOW' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(phase.focus, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 5),
                Text(
                  'Volume ${phase.volumePercent}% • Intensity ${phase.intensityPercent}%',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
