import 'package:flutter/material.dart';

import 'running_engine.dart';
import 'state/fitness_store.dart';

class RunningLabPage extends StatefulWidget {
  const RunningLabPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<RunningLabPage> createState() => _RunningLabPageState();
}

class _RunningLabPageState extends State<RunningLabPage> {
  final _distance = TextEditingController(text: '5');
  final _minutes = TextEditingController(text: '25');
  final _seconds = TextEditingController(text: '0');
  final _targetDistance = TextEditingController(text: '10');
  final _weeklyKilometers = TextEditingController(text: '15');
  final _runElevation = TextEditingController(text: '50');
  final _runCadence = TextEditingController(text: '165');
  final _shoeName = TextEditingController(text: 'Daily Trainer');
  String _surface = 'Road';
  String _shoeId = '';
  int _runRpe = 5;
  bool _saving = false;

  FitnessStore get store => widget.store;

  @override
  void dispose() {
    _distance.dispose();
    _minutes.dispose();
    _seconds.dispose();
    _targetDistance.dispose();
    _weeklyKilometers.dispose();
    _runElevation.dispose();
    _runCadence.dispose();
    _shoeName.dispose();
    super.dispose();
  }

  double get _distanceValue =>
      double.tryParse(_distance.text.replaceAll(',', '.')) ?? 0;
  int get _durationSeconds =>
      (int.tryParse(_minutes.text) ?? 0) * 60 +
      (int.tryParse(_seconds.text) ?? 0);
  double get _weeklyValue =>
      double.tryParse(_weeklyKilometers.text.replaceAll(',', '.')) ?? 0;

  Future<void> _saveRun() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await store.saveRunningSession(
        distanceKilometers: _distanceValue,
        durationSeconds: _durationSeconds,
        rpe: _runRpe,
        surface: _surface,
        elevationGainMeters: int.tryParse(_runElevation.text) ?? 0,
        cadenceStepsPerMinute: int.tryParse(_runCadence.text) ?? 0,
        shoeId: _shoeId,
      );
      if (mounted) _message('Run saved with surface, elevation and cadence.');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveShoe() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final shoe = await store.saveRunningShoe(name: _shoeName.text);
      if (mounted) {
        setState(() => _shoeId = shoe.id);
        _message('${shoe.name} added to the mileage tracker.');
      }
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('RUNNING LAB'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'PACE', icon: Icon(Icons.speed)),
            Tab(text: 'PLANS', icon: Icon(Icons.route_outlined)),
            Tab(text: 'LOG RUN', icon: Icon(Icons.directions_run)),
            Tab(text: 'LOAD', icon: Icon(Icons.query_stats)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => TabBarView(
          children: [
            _paceTab(context),
            _plansTab(context),
            _logTab(context),
            _loadTab(context),
          ],
        ),
      ),
    ),
  );

  Widget _paceTab(BuildContext context) {
    final pace = RunningEngine.pace(
      distanceKilometers: _distanceValue,
      durationSeconds: _durationSeconds,
    );
    final target =
        double.tryParse(_targetDistance.text.replaceAll(',', '.')) ?? 0;
    final prediction = RunningEngine.predictRace(
      sourceDistanceKilometers: _distanceValue,
      sourceSeconds: _durationSeconds,
      targetDistanceKilometers: target,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _RunHero(
          icon: Icons.speed,
          title: 'RUNNING PACE CALCULATOR',
          detail:
              'Converts distance and time into pace, speed and a transparent race estimate.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _NumberField(
              controller: _distance,
              label: 'DISTANCE',
              suffix: 'km',
              onChanged: () => setState(() {}),
            ),
            _NumberField(
              controller: _minutes,
              label: 'MINUTES',
              onChanged: () => setState(() {}),
            ),
            _NumberField(
              controller: _seconds,
              label: 'SECONDS',
              onChanged: () => setState(() {}),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _RunMetric(label: 'PACE', value: pace.formattedPace),
            _RunMetric(
              label: 'SPEED',
              value: '${pace.kilometersPerHour.toStringAsFixed(1)} km/h',
            ),
            _RunMetric(label: 'TIME', value: '${_durationSeconds ~/ 60} min'),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'RACE PACE PREDICTOR',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _NumberField(
          controller: _targetDistance,
          label: 'TARGET DISTANCE',
          suffix: 'km',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.flag_outlined)),
            title: Text(
              '${target.toStringAsFixed(1)} KM • ${prediction.formattedTime}',
            ),
            subtitle: Text(
              '${prediction.pace.formattedPace} • '
              '${prediction.confidence} confidence from the source distance',
            ),
          ),
        ),
      ],
    );
  }

  Widget _plansTab(BuildContext context) {
    final runWalk = RunningEngine.runWalkProgression(
      experienceLevel: store.profile?.experienceLevel ?? 'Beginner',
    );
    final plan = RunningEngine.fiveKPlan(
      currentWeeklyKilometers: _weeklyValue,
      daysPerWeek: store.profile?.daysPerWeek ?? 3,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _RunHero(
          icon: Icons.route_outlined,
          title: 'RUN/WALK + 5K PLAN BUILDER',
          detail:
              'Progresses time and distance conservatively with recovery weeks and a guarded long run.',
        ),
        const SizedBox(height: 14),
        _NumberField(
          controller: _weeklyKilometers,
          label: 'CURRENT WEEKLY DISTANCE',
          suffix: 'km',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 16),
        Text(
          'RUN/WALK PROGRESSION',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 178,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: runWalk.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final week = runWalk[index];
              return SizedBox(
                width: 220,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'W${week.week} ${week.deload ? 'RECOVERY' : ''}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${week.runSeconds}s run / '
                          '${week.walkSeconds}s walk',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${week.rounds} rounds • ${week.sessions} sessions • '
                          '${week.totalMinutes} min',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        Text('8-WEEK 5K PLAN', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final week in plan)
          Card(
            child: ExpansionTile(
              leading: CircleAvatar(child: Text('W${week.week}')),
              title: Text(
                '${week.weeklyKilometers.toStringAsFixed(1)} KM '
                '${week.recoveryFocus ? '• RECOVERY' : ''}',
              ),
              subtitle: Text(
                'Long ${week.longRunKilometers.toStringAsFixed(1)} km • '
                'easy ${week.easyKilometers.toStringAsFixed(1)} km/session',
              ),
              children: [
                ListTile(
                  title: const Text('QUALITY SESSION'),
                  subtitle: Text(week.qualitySession),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _logTab(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const _RunHero(
        icon: Icons.directions_run,
        title: 'RUN LOG',
        detail:
            'Stores distance, pace, RPE, surface, elevation, cadence and shoe mileage locally.',
      ),
      const SizedBox(height: 14),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _NumberField(
            controller: _distance,
            label: 'DISTANCE',
            suffix: 'km',
            onChanged: () => setState(() {}),
          ),
          _NumberField(
            controller: _minutes,
            label: 'MINUTES',
            onChanged: () => setState(() {}),
          ),
          _NumberField(
            controller: _seconds,
            label: 'SECONDS',
            onChanged: () => setState(() {}),
          ),
          _NumberField(
            controller: _runElevation,
            label: 'ELEVATION GAIN',
            suffix: 'm',
            onChanged: () {},
          ),
          _NumberField(
            controller: _runCadence,
            label: 'CADENCE',
            suffix: 'spm',
            onChanged: () {},
          ),
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<String>(
              initialValue: _surface,
              decoration: const InputDecoration(labelText: 'SURFACE'),
              items: [
                for (final item in RunningEngine.surfaces)
                  DropdownMenuItem(value: item, child: Text(item)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _surface = value);
              },
            ),
          ),
          SizedBox(
            width: 260,
            child: DropdownButtonFormField<String>(
              initialValue: _shoeId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'RUNNING SHOE'),
              items: [
                const DropdownMenuItem(value: '', child: Text('NO SHOE')),
                for (final shoe in store.runningShoes)
                  DropdownMenuItem(value: shoe.id, child: Text(shoe.name)),
              ],
              onChanged: (value) => setState(() => _shoeId = value ?? ''),
            ),
          ),
        ],
      ),
      _RunRpeSlider(
        value: _runRpe,
        onChanged: (value) => setState(() => _runRpe = value),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: FilledButton.icon(
          onPressed: _saving ? null : _saveRun,
          icon: const Icon(Icons.save_outlined),
          label: const Text('SAVE RUN'),
        ),
      ),
      const SizedBox(height: 18),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _shoeName,
                  decoration: const InputDecoration(labelText: 'NEW SHOE NAME'),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: _saving ? null : _saveShoe,
                icon: const Icon(Icons.add),
                label: const Text('ADD SHOE'),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _loadTab(BuildContext context) {
    final current = RunningEngine.weeklyMileage(store.runningSessions);
    final previous = RunningEngine.weeklyMileage(
      store.runningSessions,
      weeksAgo: 1,
    );
    final pain = store.data.logs.isEmpty
        ? 0
        : store.data.logs.first.painSeverity;
    final risk = RunningEngine.injuryRisk(
      currentWeek: current,
      previousWeek: previous,
      painSeverity: pain,
    );
    final requestedLong = _weeklyValue * .4;
    final longGuard = RunningEngine.longRunGuard(
      previousLongestKilometers: previous.longestRunKilometers,
      requestedKilometers: requestedLong,
      plannedWeeklyKilometers: _weeklyValue,
      recentPainSeverity: pain,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _RunHero(
          icon: Icons.query_stats,
          title: 'WEEKLY MILEAGE & INJURY GUARD',
          detail:
              'Tracks distance, long-run share, hard sessions, elevation, cadence and shoe wear.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _RunMetric(
              label: 'WEEKLY KM',
              value: current.kilometers.toStringAsFixed(1),
            ),
            _RunMetric(label: 'RUNS', value: '${current.sessions}'),
            _RunMetric(
              label: 'LONG RUN',
              value: '${current.longestRunKilometers.toStringAsFixed(1)} km',
            ),
            _RunMetric(
              label: 'CADENCE',
              value: '${current.averageCadence.toStringAsFixed(0)} spm',
            ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          color: risk.level == 'HIGH'
              ? Theme.of(context).colorScheme.errorContainer
              : null,
          child: ExpansionTile(
            leading: const Icon(Icons.health_and_safety_outlined),
            title: Text('${risk.level} RUNNING LOAD RISK'),
            subtitle: Text(
              'Score ${risk.score}/100 • mileage '
              '${risk.mileageChangePercentage.toStringAsFixed(1)}%',
            ),
            children: [
              for (final action in risk.actions)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.shield_outlined, size: 20),
                  title: Text(action),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.route_outlined)),
            title: Text('LONG-RUN GUARD • ${longGuard.status}'),
            subtitle: Text(longGuard.reason),
            trailing: Text(
              '${longGuard.allowedKilometers.toStringAsFixed(1)} km',
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text('SHOE MILEAGE', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (store.runningShoes.isEmpty)
          const Card(
            child: ListTile(
              title: Text('NO RUNNING SHOES'),
              subtitle: Text(
                'Add a shoe in Log Run to track its real mileage.',
              ),
            ),
          )
        else
          for (final shoe in store.runningShoes)
            Card(
              child: ListTile(
                leading: const Icon(Icons.directions_run),
                title: Text(shoe.name),
                subtitle: Text(
                  '${RunningEngine.shoeMileage(shoe, store.runningSessions).toStringAsFixed(1)} / '
                  '${shoe.retirementKilometers.toStringAsFixed(0)} km',
                ),
              ),
            ),
      ],
    );
  }
}

class _RunHero extends StatelessWidget {
  const _RunHero({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(radius: 28, child: Icon(icon)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(detail),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.suffix = '',
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 200,
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix.isEmpty ? null : suffix,
      ),
      onChanged: (_) => onChanged(),
    ),
  );
}

class _RunMetric extends StatelessWidget {
  const _RunMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 210,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    ),
  );
}

class _RunRpeSlider extends StatelessWidget {
  const _RunRpeSlider({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 120,
        child: Text(
          'RUN RPE $value',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Expanded(
        child: Slider(
          value: value.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: (next) => onChanged(next.round()),
        ),
      ),
    ],
  );
}
