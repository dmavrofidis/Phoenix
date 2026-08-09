import 'package:flutter/material.dart';

import 'sleep_stress_engine.dart';
import 'state/fitness_store.dart';

class SleepStressPage extends StatefulWidget {
  const SleepStressPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<SleepStressPage> createState() => _SleepStressPageState();
}

class _SleepStressPageState extends State<SleepStressPage> {
  TimeOfDay _bedtime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wake = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _caffeine = const TimeOfDay(hour: 14, minute: 0);
  double _screenFree = 30;
  double _stress = 3;
  final _stressContext = TextEditingController();
  bool _saving = false;

  FitnessStore get store => widget.store;

  @override
  void dispose() {
    _stressContext.dispose();
    super.dispose();
  }

  int _minutes(TimeOfDay value) => (value.hour * 60) + value.minute;

  String _clock(int minutes) {
    final normalized = minutes % 1440;
    final hours = normalized ~/ 60;
    final mins = normalized % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _saveSleep() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await store.saveSleepRoutine(
        day: DateTime.now(),
        bedtimeMinutes: _minutes(_bedtime),
        wakeMinutes: _minutes(_wake),
        lastCaffeineMinutes: _minutes(_caffeine),
        screenFreeMinutes: _screenFree.round(),
        windDownSteps: const [
          'Close demanding work',
          'Dim lights',
          'Phone away',
        ],
      );
      if (mounted) _message('Sleep routine saved locally.');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveStress() async {
    try {
      await store.saveStressCheckIn(
        level: _stress.round(),
        context: _stressContext.text,
      );
      _stressContext.clear();
      if (mounted) _message('Stress check-in saved.');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('SLEEP & STRESS'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'SCHEDULE', icon: Icon(Icons.bedtime_outlined)),
            Tab(text: 'WIND-DOWN', icon: Icon(Icons.nights_stay_outlined)),
            Tab(text: 'STRESS', icon: Icon(Icons.spa_outlined)),
            Tab(text: 'MORNING', icon: Icon(Icons.wb_sunny_outlined)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => TabBarView(
          children: [
            _scheduleTab(context),
            _windDownTab(context),
            _stressTab(context),
            _morningTab(context),
          ],
        ),
      ),
    ),
  );

  Widget _scheduleTab(BuildContext context) {
    final summary = SleepStressEngine.schedule(store.sleepRoutineLogs);
    final bedtimeScore = SleepStressEngine.bedtimeConsistency(
      store.sleepRoutineLogs,
    );
    final wakeScore = SleepStressEngine.wakeConsistency(store.sleepRoutineLogs);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _SleepHero(
          icon: Icons.bedtime_outlined,
          title: 'SLEEP SCHEDULE TRACKER',
          detail:
              'Track timing consistency and the available sleep window—not a medical sleep diagnosis.',
        ),
        const SizedBox(height: 14),
        _MetricWrap(
          children: [
            _Metric(
              label: 'BEDTIME',
              value: _clock(summary.bedtimeMinutes),
              detail: '${bedtimeScore.score}% • ${bedtimeScore.label}',
            ),
            _Metric(
              label: 'WAKE',
              value: _clock(summary.wakeMinutes),
              detail: '${wakeScore.score}% • ${wakeScore.label}',
            ),
            _Metric(
              label: 'WINDOW',
              value:
                  '${summary.durationMinutes ~/ 60}h ${summary.durationMinutes % 60}m',
              detail: summary.label,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _TimeButton(
              label: 'BEDTIME',
              value: _bedtime,
              onTap: () => _pickTime(_bedtime, (value) => _bedtime = value),
            ),
            _TimeButton(
              label: 'WAKE TIME',
              value: _wake,
              onTap: () => _pickTime(_wake, (value) => _wake = value),
            ),
            _TimeButton(
              label: 'LAST CAFFEINE',
              value: _caffeine,
              onTap: () => _pickTime(_caffeine, (value) => _caffeine = value),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SliderRow(
          label: 'SCREEN-FREE BUFFER',
          value: _screenFree,
          min: 0,
          max: 120,
          divisions: 8,
          suffix: '${_screenFree.round()} min',
          onChanged: (value) => setState(() => _screenFree = value),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _saving ? null : _saveSleep,
            icon: const Icon(Icons.save_outlined),
            label: const Text('SAVE TODAY'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('CONSISTENCY, NOT PERFECTION'),
            subtitle: Text(
              'The scores reflect average timing deviation. A planned late night can be context—not failure.',
            ),
          ),
        ),
      ],
    );
  }

  Widget _windDownTab(BuildContext context) {
    final latest = store.sleepRoutineLogs.firstOrNull;
    final bedtime = latest?.bedtimeMinutes ?? _minutes(_bedtime);
    final caffeine = SleepStressEngine.caffeineCutoff(
      bedtimeMinutes: bedtime,
      lastCaffeineMinutes: latest?.lastCaffeineMinutes ?? _minutes(_caffeine),
    );
    final screen = SleepStressEngine.screenFree(
      bedtimeMinutes: bedtime,
      actualMinutes: latest?.screenFreeMinutes ?? _screenFree.round(),
    );
    final routine = SleepStressEngine.windDownRoutine(
      bedtimeMinutes: bedtime,
      stressLevel: _stress.round(),
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _SleepHero(
          icon: Icons.nights_stay_outlined,
          title: 'EVENING WIND-DOWN',
          detail:
              'Turn bedtime into a sequence of low-friction cues with caffeine and screen boundaries.',
        ),
        const SizedBox(height: 14),
        Card(
          color: caffeine.status == 'ON TARGET'
              ? const Color(0xFF17382D)
              : const Color(0xFF422D23),
          child: ListTile(
            leading: const Icon(Icons.coffee_outlined),
            title: Text('CAFFEINE CUTOFF • ${_clock(caffeine.cutoffMinutes)}'),
            subtitle: Text('${caffeine.status} • ${caffeine.reason}'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.phone_android),
            title: Text('SCREEN-FREE START • ${_clock(screen.startMinutes)}'),
            subtitle: Text('${screen.status} • ${screen.cue}'),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'TONIGHT’S TIMELINE',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        for (final step in routine)
          Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  step.minutesBeforeBed == 0
                      ? '0'
                      : '-${step.minutesBeforeBed}',
                ),
              ),
              title: Text(step.title),
              subtitle: Text(step.detail),
            ),
          ),
      ],
    );
  }

  Widget _stressTab(BuildContext context) {
    final timeline = SleepStressEngine.stressTimeline(store.stressCheckInLogs);
    final protocols = SleepStressEngine.relaxationLibrary();
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _SleepHero(
          icon: Icons.spa_outlined,
          title: 'STRESS TIMELINE',
          detail:
              'Capture a quick 1–5 signal, keep the context, and choose a short non-clinical downshift protocol.',
        ),
        const SizedBox(height: 14),
        _MetricWrap(
          children: [
            _Metric(
              label: '14-DAY AVG',
              value: timeline.average.toStringAsFixed(1),
              detail: timeline.direction,
            ),
            _Metric(
              label: 'PEAK',
              value: '${timeline.peak}/5',
              detail: '${timeline.sampleSize} CHECK-IN(S)',
            ),
          ],
        ),
        _SliderRow(
          label: 'STRESS RIGHT NOW',
          value: _stress,
          min: 1,
          max: 5,
          divisions: 4,
          suffix: '${_stress.round()}/5',
          onChanged: (value) => setState(() => _stress = value),
        ),
        TextField(
          controller: _stressContext,
          maxLength: 160,
          decoration: const InputDecoration(
            labelText: 'OPTIONAL CONTEXT',
            hintText: 'Workload, travel, conflict, poor sleep…',
            prefixIcon: Icon(Icons.edit_note),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _saveStress,
            icon: const Icon(Icons.add_chart),
            label: const Text('LOG STRESS'),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'GUIDED RELAXATION LIBRARY',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        for (final protocol in protocols)
          Card(
            child: ExpansionTile(
              leading: CircleAvatar(child: Text('${protocol.minutes}m')),
              title: Text(protocol.title),
              subtitle: Text(protocol.stopRule),
              children: [
                for (final step in protocol.steps)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.arrow_right),
                    title: Text(step),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _morningTab(BuildContext context) {
    final timeline = SleepStressEngine.stressTimeline(store.stressCheckInLogs);
    final latestRecovery = store.data.recoveryChecks.isEmpty
        ? null
        : ([...store.data.recoveryChecks]..sort(
                (left, right) => right.recordedAt.compareTo(left.recordedAt),
              ))
              .first;
    final cutoff = DateTime.now().subtract(const Duration(hours: 72));
    final hard = store.data.logs
        .where(
          (item) => item.completedAt.isAfter(cutoff) && item.sessionRpe >= 8,
        )
        .length;
    final brief = SleepStressEngine.morningBrief(
      recovery: latestRecovery,
      stress: timeline,
      hardWorkoutsLast72Hours: hard,
    );
    final correlation = SleepStressEngine.trainingCorrelation(
      recoveryChecks: store.data.recoveryChecks,
      workouts: store.data.logs,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _SleepHero(
          icon: Icons.wb_sunny_outlined,
          title: 'FATIGUE-RISK MORNING BRIEF',
          detail:
              'Combine recent sleep, energy, soreness, stress and dense hard training into a conservative action.',
        ),
        const SizedBox(height: 14),
        Card(
          color: brief.score >= 70
              ? const Color(0xFF452428)
              : brief.score >= 40
              ? const Color(0xFF3D321E)
              : const Color(0xFF17382D),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${brief.score}/100',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  brief.status,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const Divider(height: 24),
                for (final driver in brief.drivers) Text('• $driver'),
                const SizedBox(height: 8),
                Text(brief.action),
              ],
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.query_stats),
            title: Text('SLEEP–TRAINING • ${correlation.label}'),
            subtitle: Text(
              '${correlation.sampleNights} matched night(s) • '
              '7h+ ${(correlation.wellRestedWorkoutRate * 100).round()}% vs '
              'short ${(correlation.shortSleepWorkoutRate * 100).round()}%\n'
              '${correlation.caution}',
            ),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.health_and_safety_outlined),
            title: Text('SAFETY BOUNDARY'),
            subtitle: Text(
              'Persistent severe fatigue, insomnia, anxiety or breathing problems deserve professional assessment.',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickTime(
    TimeOfDay initial,
    ValueChanged<TimeOfDay> update,
  ) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (selected != null) setState(() => update(selected));
  }
}

class _SleepHero extends StatelessWidget {
  const _SleepHero({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFF222A43),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, size: 34, color: const Color(0xFFAEC4FF)),
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
    width: 160,
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

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final TimeOfDay value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 190,
    child: OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.schedule),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text('$label\n${value.format(context)}'),
      ),
    ),
  );
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.suffix,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
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
        divisions: divisions,
        onChanged: onChanged,
      ),
    ],
  );
}
