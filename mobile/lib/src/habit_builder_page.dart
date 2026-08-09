import 'package:flutter/material.dart';

import 'habit_builder_engine.dart';
import 'models/fitness_models.dart';
import 'state/fitness_store.dart';

class HabitBuilderPage extends StatefulWidget {
  const HabitBuilderPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<HabitBuilderPage> createState() => _HabitBuilderPageState();
}

class _HabitBuilderPageState extends State<HabitBuilderPage> {
  final _name = TextEditingController(text: '10-minute mobility');
  final _minimum = TextEditingController(text: 'Do one mobility drill');
  final _stack = TextEditingController(text: 'closing my laptop');
  final _reflection = TextEditingController();
  String _category = 'Movement';
  double _days = 5;
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 30);
  bool _saving = false;

  FitnessStore get store => widget.store;

  @override
  void dispose() {
    _name.dispose();
    _minimum.dispose();
    _stack.dispose();
    _reflection.dispose();
    super.dispose();
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _createHabit() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await store.saveHealthHabit(
        name: _name.text,
        category: _category,
        targetDaysPerWeek: _days.round(),
        minimumVersion: _minimum.text,
        stackAfter: _stack.text,
        preferredMinutesSinceMidnight: (_time.hour * 60) + _time.minute,
      );
      if (mounted) _message('Habit saved locally.');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _checkIn(
    HealthHabit habit, {
    required bool completed,
    required bool minimum,
  }) async {
    final friction = await showDialog<int>(
      context: context,
      builder: (context) =>
          _FrictionDialog(habit: habit, completed: completed, minimum: minimum),
    );
    if (friction == null || !mounted) return;
    await store.saveHabitCheckIn(
      habitId: habit.id,
      day: DateTime.now(),
      completed: completed,
      usedMinimum: minimum,
      frictionLevel: friction,
      reflection: _reflection.text,
    );
    _reflection.clear();
    if (mounted) _message(minimum ? 'Minimum day protected.' : 'Habit logged.');
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('HABIT BUILDER'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'TODAY', icon: Icon(Icons.checklist)),
            Tab(text: 'BUILD', icon: Icon(Icons.add_task)),
            Tab(text: 'SYSTEM', icon: Icon(Icons.account_tree_outlined)),
            Tab(text: 'INSIGHTS', icon: Icon(Icons.insights_outlined)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => TabBarView(
          children: [
            _todayTab(context),
            _buildTab(context),
            _systemTab(context),
            _insightsTab(context),
          ],
        ),
      ),
    ),
  );

  Widget _todayTab(BuildContext context) {
    final items = HabitBuilderEngine.dailyChecklist(
      habits: store.healthHabits,
      checkIns: store.habitCheckIns,
      day: DateTime.now(),
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _HabitHero(
          icon: Icons.bolt,
          title: 'TODAY’S SYSTEM',
          detail:
              'Full repetitions build the score. Minimum days protect continuity without pretending they are full wins.',
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          const _EmptyHabitCard()
        else
          for (final item in items) _ChecklistCard(item: item, onLog: _checkIn),
        const SizedBox(height: 12),
        TextField(
          controller: _reflection,
          maxLength: 300,
          decoration: const InputDecoration(
            labelText: 'OPTIONAL REFLECTION FOR NEXT CHECK-IN',
            hintText: 'What helped—or what got in the way?',
            prefixIcon: Icon(Icons.edit_note),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const _HabitHero(
        icon: Icons.construction,
        title: 'DESIGN A REPEATABLE HABIT',
        detail:
            'Give the behavior a clear trigger, realistic weekly target and tiny fallback for difficult days.',
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _name,
        maxLength: 60,
        decoration: const InputDecoration(
          labelText: 'HABIT',
          prefixIcon: Icon(Icons.flag_outlined),
        ),
      ),
      DropdownButtonFormField<String>(
        initialValue: _category,
        decoration: const InputDecoration(
          labelText: 'CATEGORY',
          prefixIcon: Icon(Icons.category_outlined),
        ),
        items: const [
          DropdownMenuItem(value: 'Movement', child: Text('Movement')),
          DropdownMenuItem(value: 'Nutrition', child: Text('Nutrition')),
          DropdownMenuItem(value: 'Recovery', child: Text('Recovery')),
          DropdownMenuItem(value: 'Mindset', child: Text('Mindset')),
        ],
        onChanged: (value) => setState(() => _category = value ?? _category),
      ),
      const SizedBox(height: 12),
      _LabeledSlider(
        label: 'WEEKLY TARGET',
        value: _days,
        min: 1,
        max: 7,
        suffix: '${_days.round()} day(s)',
        onChanged: (value) => setState(() => _days = value),
      ),
      TextField(
        controller: _minimum,
        maxLength: 100,
        decoration: const InputDecoration(
          labelText: 'MINIMUM-DAY VERSION',
          hintText: 'A useful action under two minutes',
          prefixIcon: Icon(Icons.compress),
        ),
      ),
      TextField(
        controller: _stack,
        maxLength: 100,
        decoration: const InputDecoration(
          labelText: 'AFTER THIS EXISTING ACTION',
          prefixIcon: Icon(Icons.link),
        ),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.schedule),
        title: const Text('PREFERRED TIME'),
        subtitle: Text(_time.format(context)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final selected = await showTimePicker(
            context: context,
            initialTime: _time,
          );
          if (selected != null) setState(() => _time = selected);
        },
      ),
      Align(
        alignment: Alignment.centerRight,
        child: FilledButton.icon(
          onPressed: _saving ? null : _createHabit,
          icon: const Icon(Icons.add_task),
          label: const Text('CREATE HABIT'),
        ),
      ),
      const SizedBox(height: 18),
      Text('ACTIVE HABITS', style: Theme.of(context).textTheme.titleMedium),
      for (final habit in store.healthHabits)
        Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${habit.targetDaysPerWeek}×')),
            title: Text(habit.name),
            subtitle: Text(
              '${habit.category} • minimum: ${habit.minimumVersion}',
            ),
            trailing: IconButton(
              tooltip: 'Delete habit',
              onPressed: () => store.removeHealthHabit(habit.id),
              icon: const Icon(Icons.delete_outline),
            ),
          ),
        ),
    ],
  );

  Widget _systemTab(BuildContext context) {
    final habit = store.healthHabits.firstOrNull;
    if (habit == null) return const _EmptySystem();
    final streak = HabitBuilderEngine.streakProtection(
      habit: habit,
      checkIns: store.habitCheckIns,
      now: DateTime.now(),
    );
    final friction = HabitBuilderEngine.frictionAudit(
      habit: habit,
      checkIns: store.habitCheckIns,
    );
    final stacks = HabitBuilderEngine.stackSuggestions(habit);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _HabitHero(
          icon: Icons.account_tree_outlined,
          title: 'BEHAVIOR SYSTEM',
          detail:
              'Engineer the cue and environment. Motivation is useful, but the repeatable system carries difficult days.',
        ),
        const SizedBox(height: 14),
        _MetricRow(
          children: [
            _Metric(
              label: 'STREAK',
              value: '${streak.days}d',
              detail: streak.status,
            ),
            _Metric(
              label: 'MINIMUM',
              value: '${streak.minimumDays}',
              detail: 'PROTECTED DAYS',
            ),
            _Metric(
              label: 'FRICTION',
              value: friction.average.toStringAsFixed(1),
              detail: friction.label,
            ),
          ],
        ),
        Card(
          color: const Color(0xFF17382D),
          child: ListTile(
            leading: const Icon(Icons.event_available),
            title: const Text('IMPLEMENTATION INTENTION'),
            subtitle: Text(HabitBuilderEngine.implementationIntention(habit)),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.compress),
            title: const Text('MINIMUM-DAY FALLBACK'),
            subtitle: Text(
              '${HabitBuilderEngine.minimumDayFallback(habit)}\n${streak.nextAction}',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'HABIT-STACK OPTIONS',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        for (final suggestion in stacks)
          Card(
            child: ListTile(
              leading: const Icon(Icons.link),
              title: Text('$suggestion → ${habit.name}'),
            ),
          ),
        const SizedBox(height: 12),
        Card(
          color: friction.average >= 3.5
              ? const Color(0xFF422D23)
              : const Color(0xFF242D3B),
          child: ListTile(
            leading: const Icon(Icons.tune),
            title: Text(
              'FRICTION AUDIT • ${friction.highFrictionDays} HARD DAY(S)',
            ),
            subtitle: Text(friction.action),
          ),
        ),
      ],
    );
  }

  Widget _insightsTab(BuildContext context) {
    final habit = store.healthHabits.firstOrNull;
    if (habit == null) return const _EmptySystem();
    final score = HabitBuilderEngine.weeklyScore(
      habit: habit,
      checkIns: store.habitCheckIns,
      now: DateTime.now(),
    );
    final reflection = HabitBuilderEngine.reflectionSummary(
      habit: habit,
      checkIns: store.habitCheckIns,
    );
    final correlation = HabitBuilderEngine.progressCorrelation(
      habit: habit,
      checkIns: store.habitCheckIns,
      recoveryChecks: store.data.recoveryChecks,
      workouts: store.data.logs,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _HabitHero(
          icon: Icons.insights,
          title: 'HABIT PROGRESS',
          detail:
              'Review adherence and associations with readiness or training—without turning correlation into a medical claim.',
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Text(
                  '${score.percent}%',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'WEEKLY HABIT SCORE • ${score.label}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: score.percent / 100),
                const SizedBox(height: 8),
                Text(
                  '${score.points.toStringAsFixed(1)} weighted repetition(s) / ${score.target} target',
                ),
              ],
            ),
          ),
        ),
        _MetricRow(
          children: [
            _Metric(
              label: 'READINESS',
              value:
                  '${correlation.readinessLift >= 0 ? '+' : ''}${correlation.readinessLift.toStringAsFixed(1)}',
              detail: 'POINT LIFT',
            ),
            _Metric(
              label: 'WORKOUT RATE',
              value:
                  '${correlation.workoutLift >= 0 ? '+' : ''}${(correlation.workoutLift * 100).toStringAsFixed(0)}%',
              detail: correlation.label,
            ),
            _Metric(
              label: 'SAMPLE',
              value: '${correlation.sampleDays}d',
              detail: 'MATCHED DAYS',
            ),
          ],
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.science_outlined),
            title: Text(correlation.label),
            subtitle: Text(correlation.caution),
          ),
        ),
        const SizedBox(height: 12),
        Text('REFLECTION LOOP', style: Theme.of(context).textTheme.titleMedium),
        Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${reflection.count}')),
            title: Text(reflection.latest),
            subtitle: Text(reflection.prompt),
          ),
        ),
      ],
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.item, required this.onLog});

  final HabitChecklistItem item;
  final Future<void> Function(
    HealthHabit habit, {
    required bool completed,
    required bool minimum,
  })
  onLog;

  @override
  Widget build(BuildContext context) {
    final streak = HabitBuilderEngine.streakProtection(
      habit: item.habit,
      checkIns: item.checkIn == null ? const [] : [item.checkIn!],
      now: DateTime.now(),
    );
    final done = item.checkIn?.completed == true;
    final minimum = item.checkIn?.usedMinimum == true;
    return Card(
      color: done
          ? const Color(0xFF17382D)
          : minimum
          ? const Color(0xFF3D321E)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(done ? Icons.check_circle : Icons.radio_button_unchecked),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.habit.name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '${item.habit.category} • ${item.status} • ${streak.status}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: done
                      ? null
                      : () =>
                            onLog(item.habit, completed: true, minimum: false),
                  icon: const Icon(Icons.done_all),
                  label: const Text('FULL REP'),
                ),
                OutlinedButton.icon(
                  onPressed: done || minimum
                      ? null
                      : () =>
                            onLog(item.habit, completed: false, minimum: true),
                  icon: const Icon(Icons.compress),
                  label: const Text('MINIMUM DAY'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FrictionDialog extends StatefulWidget {
  const _FrictionDialog({
    required this.habit,
    required this.completed,
    required this.minimum,
  });

  final HealthHabit habit;
  final bool completed;
  final bool minimum;

  @override
  State<_FrictionDialog> createState() => _FrictionDialogState();
}

class _FrictionDialogState extends State<_FrictionDialog> {
  double value = 2;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.minimum ? 'Minimum day' : 'Full repetition'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.habit.name),
        const SizedBox(height: 18),
        Text('How much friction? ${value.round()}/5'),
        Slider(
          value: value,
          min: 0,
          max: 5,
          divisions: 5,
          onChanged: (next) => setState(() => value = next),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('CANCEL'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, value.round()),
        child: const Text('SAVE'),
      ),
    ],
  );
}

class _HabitHero extends StatelessWidget {
  const _HabitHero({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFF172E27),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, size: 34, color: const Color(0xFF71E6A5)),
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

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Wrap(spacing: 10, runSpacing: 10, children: children),
  );
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
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(detail, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    ),
  );
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String suffix;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$label • $suffix',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      Slider(
        value: value,
        min: min,
        max: max,
        divisions: (max - min).round(),
        onChanged: onChanged,
      ),
    ],
  );
}

class _EmptyHabitCard extends StatelessWidget {
  const _EmptyHabitCard();

  @override
  Widget build(BuildContext context) => const Card(
    child: ListTile(
      leading: Icon(Icons.add_task),
      title: Text('NO HABITS YET'),
      subtitle: Text(
        'Open BUILD and create one clear behavior with a minimum-day fallback.',
      ),
    ),
  );
}

class _EmptySystem extends StatelessWidget {
  const _EmptySystem();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        'Create your first habit in BUILD to unlock the behavior system.',
        textAlign: TextAlign.center,
      ),
    ),
  );
}
