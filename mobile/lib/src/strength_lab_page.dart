import 'package:flutter/material.dart';

import 'state/fitness_store.dart';
import 'strength_lab_engine.dart';

class StrengthLabPage extends StatefulWidget {
  const StrengthLabPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<StrengthLabPage> createState() => _StrengthLabPageState();
}

class _StrengthLabPageState extends State<StrengthLabPage> {
  late String _selectedLift;
  late TextEditingController _trainingMaxController;
  final _workWeightController = TextEditingController(text: '100');
  final _barWeightController = TextEditingController(text: '20');
  double _fastestVelocity = .55;
  double _currentVelocity = .46;
  double _velocityThreshold = 20;
  String _block = 'base';
  bool _savingTrainingMax = false;

  FitnessStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    _selectedLift = StrengthLabEngine.bigLifts.first;
    _trainingMaxController = TextEditingController();
    _syncTrainingMax();
  }

  @override
  void dispose() {
    _trainingMaxController.dispose();
    _workWeightController.dispose();
    _barWeightController.dispose();
    super.dispose();
  }

  void _syncTrainingMax() {
    final metric = StrengthLabEngine.dashboard(
      store.data,
    ).firstWhere((item) => item.lift == _selectedLift);
    final value = metric.trainingMax > 0
        ? metric.trainingMax
        : metric.estimatedOneRepMax > 0
        ? StrengthLabEngine.roundToPlate(metric.estimatedOneRepMax * .9)
        : 100;
    _trainingMaxController.text = value.toStringAsFixed(1);
    _workWeightController.text = value.toStringAsFixed(1);
  }

  double get _trainingMax =>
      double.tryParse(_trainingMaxController.text.replaceAll(',', '.')) ?? 0;
  double get _workWeight =>
      double.tryParse(_workWeightController.text.replaceAll(',', '.')) ?? 0;
  double get _barWeight =>
      double.tryParse(_barWeightController.text.replaceAll(',', '.')) ?? 20;

  Future<void> _saveTrainingMax() async {
    if (_savingTrainingMax) return;
    setState(() => _savingTrainingMax = true);
    try {
      await store.saveStrengthTrainingMax(_selectedLift, _trainingMax);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$_selectedLift training max saved locally: '
              '${_trainingMax.toStringAsFixed(1)} kg.',
            ),
          ),
        );
      }
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _savingTrainingMax = false);
    }
  }

  int get _readiness => store.todaysRecoveryPlan?.score ?? 70;

  int get _recentPainSeverity {
    if (store.data.logs.isEmpty) return 0;
    final logs = [...store.data.logs]
      ..sort((left, right) => right.completedAt.compareTo(left.completedAt));
    return logs.first.painSeverity;
  }

  int get _recentHeavyExposures {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return store.data.logs
        .where((log) => log.completedAt.isAfter(cutoff))
        .where(
          (log) => log.sets.any(
            (set) =>
                StrengthLabEngine.canonicalLift(set.exerciseName) ==
                    _selectedLift &&
                set.reps <= 3 &&
                set.setRpe >= 8,
          ),
        )
        .length;
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('STRENGTH LAB'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'DASHBOARD', icon: Icon(Icons.speed)),
            Tab(text: 'LOADING', icon: Icon(Icons.fitness_center)),
            Tab(text: 'PROTOCOLS', icon: Icon(Icons.rule)),
            Tab(text: 'MEET DAY', icon: Icon(Icons.emoji_events_outlined)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => TabBarView(
          children: [
            _dashboardTab(context),
            _loadingTab(context),
            _protocolsTab(context),
            _meetDayTab(context),
          ],
        ),
      ),
    ),
  );

  Widget _dashboardTab(BuildContext context) {
    final metrics = StrengthLabEngine.dashboard(store.data);
    final selected = metrics.firstWhere((item) => item.lift == _selectedLift);
    final oneRepMax = selected.estimatedOneRepMax > 0
        ? selected.estimatedOneRepMax
        : _trainingMax / .9;
    final table = StrengthLabEngine.repMaxTable(oneRepMax);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _StrengthHero(
          icon: Icons.monitor_heart_outlined,
          title: 'BIG-LIFT STRENGTH DASHBOARD',
          detail:
              'Uses submax tests and real workout sets. No maximal attempt is required.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: 245,
                child: Card(
                  color: metric.lift == _selectedLift
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedLift = metric.lift;
                        _syncTrainingMax();
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metric.lift.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            metric.hasData
                                ? '${metric.estimatedOneRepMax.toStringAsFixed(1)} kg e1RM'
                                : 'ADD A SUBMAX TEST',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            metric.hasData
                                ? '${metric.bestWeight.toStringAsFixed(1)} kg × '
                                      '${metric.bestReps} • ${metric.source}'
                                : 'Training max can still be managed manually.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
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
                  width: 275,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedLift,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'BIG LIFT'),
                    items: [
                      for (final lift in StrengthLabEngine.bigLifts)
                        DropdownMenuItem(value: lift, child: Text(lift)),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedLift = value;
                        _syncTrainingMax();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 210,
                  child: TextField(
                    controller: _trainingMaxController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'TRAINING MAX',
                      suffixText: 'kg',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _savingTrainingMax ? null : _saveTrainingMax,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('SAVE TRAINING MAX'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'REP-MAX CONVERSION TABLE',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('REPS')),
                DataColumn(label: Text('EST. LOAD')),
                DataColumn(label: Text('% e1RM')),
              ],
              rows: [
                for (final row in table)
                  DataRow(
                    cells: [
                      DataCell(Text('${row.reps}')),
                      DataCell(Text('${row.weight.toStringAsFixed(1)} kg')),
                      DataCell(Text('${row.percentage.toStringAsFixed(1)}%')),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _loadingTab(BuildContext context) {
    final warmup = StrengthLabEngine.warmupPlan(
      workWeight: _workWeight,
      barWeight: _barWeight,
    );
    final loading = StrengthLabEngine.loadBar(
      targetWeight: _workWeight,
      barWeight: _barWeight,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _StrengthHero(
          icon: Icons.balance,
          title: 'BARBELL LOADING ASSISTANT',
          detail:
              'Calculates the closest load and builds a progressive warm-up without junk fatigue.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 220,
              child: TextField(
                controller: _workWeightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'WORK WEIGHT',
                  suffixText: 'kg',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            SizedBox(
              width: 220,
              child: TextField(
                controller: _barWeightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'BAR WEIGHT',
                  suffixText: 'kg',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.fitness_center)),
            title: Text(
              loading.exact
                  ? '${loading.loadedWeight.toStringAsFixed(1)} KG — EXACT LOAD'
                  : '${loading.loadedWeight.toStringAsFixed(1)} KG — CLOSEST LOAD',
            ),
            subtitle: Text(
              loading.platesPerSide.isEmpty
                  ? 'Empty bar'
                  : 'PER SIDE: ${loading.platesPerSide.map((item) => item.toStringAsFixed(item == item.roundToDouble() ? 0 : 2)).join(' + ')}',
            ),
            trailing: Text(
              loading.exact
                  ? 'READY'
                  : '${loading.difference >= 0 ? '+' : ''}'
                        '${loading.difference.toStringAsFixed(1)} kg',
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'WARM-UP PLATE CALCULATOR',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final set in warmup)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${set.reps}')),
              title: Text('${set.label} — ${set.weight.toStringAsFixed(1)} kg'),
              subtitle: Text(
                set.plateLoad.platesPerSide.isEmpty
                    ? 'Empty bar • ${set.reps} reps'
                    : 'Per side: ${set.plateLoad.platesPerSide.join(' + ')} • '
                          '${set.reps} reps',
              ),
            ),
          ),
      ],
    );
  }

  Widget _protocolsTab(BuildContext context) {
    final protocol = StrengthLabEngine.topSetPlusBackoff(
      trainingMax: _trainingMax,
    );
    final gate = StrengthLabEngine.heavySingleGate(
      readinessScore: _readiness,
      painSeverity: _recentPainSeverity,
      heavyExposuresLastSevenDays: _recentHeavyExposures,
    );
    final velocity = StrengthLabEngine.velocityLoss(
      fastestVelocity: _fastestVelocity,
      currentVelocity: _currentVelocity,
      thresholdPercentage: _velocityThreshold,
    );
    final block = StrengthLabEngine.strengthBlock(block: _block);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _StrengthHero(
          icon: Icons.rule,
          title: 'TOP SET + BACK-OFF PROTOCOL',
          detail:
              'Hard enough to drive strength, bounded by RPE, readiness and rep-speed quality.',
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Wrap(
              spacing: 28,
              runSpacing: 14,
              children: [
                _ProtocolMetric(
                  label: 'TOP SET',
                  value:
                      '${protocol.topWeight.toStringAsFixed(1)} kg × '
                      '${protocol.topReps} @${protocol.topRpe.toStringAsFixed(1)}',
                ),
                _ProtocolMetric(
                  label: 'BACK-OFF',
                  value:
                      '${protocol.backoffSets} × ${protocol.backoffReps} @ '
                      '${protocol.backoffWeight.toStringAsFixed(1)} kg',
                ),
                _ProtocolMetric(
                  label: 'REST',
                  value: '${protocol.restSeconds ~/ 60} min',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          color: gate.status == HeavySingleStatus.blocked
              ? Theme.of(context).colorScheme.errorContainer
              : null,
          child: ListTile(
            leading: Icon(
              gate.status == HeavySingleStatus.allowed
                  ? Icons.verified_outlined
                  : gate.status == HeavySingleStatus.controlled
                  ? Icons.shield_outlined
                  : Icons.block,
            ),
            title: Text(gate.title),
            subtitle: Text(
              '${gate.reason} Readiness $_readiness/100 • '
              'cap ${(gate.loadCapPercentage * 100).round()}%.',
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'VELOCITY-LOSS STOP RULE',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _DecimalSlider(
          label: 'FASTEST REP',
          value: _fastestVelocity,
          min: .2,
          max: 1.2,
          suffix: ' m/s',
          onChanged: (value) => setState(() => _fastestVelocity = value),
        ),
        _DecimalSlider(
          label: 'CURRENT REP',
          value: _currentVelocity,
          min: .1,
          max: 1.2,
          suffix: ' m/s',
          onChanged: (value) => setState(() => _currentVelocity = value),
        ),
        _DecimalSlider(
          label: 'STOP THRESHOLD',
          value: _velocityThreshold,
          min: 10,
          max: 40,
          suffix: '%',
          divisions: 6,
          onChanged: (value) => setState(() => _velocityThreshold = value),
        ),
        Card(
          color: velocity.stopSet
              ? Theme.of(context).colorScheme.errorContainer
              : null,
          child: ListTile(
            leading: Icon(
              velocity.stopSet ? Icons.stop_circle_outlined : Icons.play_circle,
            ),
            title: Text(
              '${velocity.lossPercentage.toStringAsFixed(1)}% VELOCITY LOSS',
            ),
            subtitle: Text(velocity.cue),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'STRENGTH BLOCK TEMPLATES',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            DropdownButton<String>(
              value: _block,
              items: const [
                DropdownMenuItem(value: 'base', child: Text('BASE')),
                DropdownMenuItem(
                  value: 'intensification',
                  child: Text('INTENSIFICATION'),
                ),
                DropdownMenuItem(value: 'peak', child: Text('PEAK')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _block = value);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final week in block)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('W${week.week}')),
              title: Text(
                '${week.phase} • ${week.intensityPercentage.toStringAsFixed(1)}% TM',
              ),
              subtitle: Text(
                '${week.sets} × ${week.reps} • target RPE '
                '${week.targetRpe.toStringAsFixed(1)} • '
                '${StrengthLabEngine.roundToPlate(_trainingMax * week.intensityPercentage / 100).toStringAsFixed(1)} kg',
              ),
            ),
          ),
      ],
    );
  }

  Widget _meetDayTab(BuildContext context) {
    final metrics = StrengthLabEngine.dashboard(store.data);
    final metric = metrics.firstWhere((item) => item.lift == _selectedLift);
    final e1rm = metric.estimatedOneRepMax > 0
        ? metric.estimatedOneRepMax
        : _trainingMax / .9;
    final plan = StrengthLabEngine.meetDayAttempts(
      estimatedOneRepMax: e1rm,
      readinessScore: _readiness,
      experienceLevel: store.profile?.experienceLevel ?? 'Beginner',
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _StrengthHero(
          icon: Icons.emoji_events_outlined,
          title: 'MEET-DAY ATTEMPT PLANNER',
          detail:
              'Conservative opener, result-first second and readiness-aware third attempt.',
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _AttemptCard(
              number: 1,
              title: 'OPENER',
              weight: plan.opener,
              cue: 'Confidence and clean commands.',
            ),
            _AttemptCard(
              number: 2,
              title: 'SECURE',
              weight: plan.second,
              cue: 'Bank the total before chasing.',
            ),
            _AttemptCard(
              number: 3,
              title: 'PERFORMANCE',
              weight: plan.third,
              cue: 'Adjust after attempt-two speed.',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_selectedLift • ${e1rm.toStringAsFixed(1)} kg e1RM • '
                  'readiness $_readiness/100',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                for (final note in plan.notes)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.shield_outlined, size: 20),
                    title: Text(note),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Never take a third attempt that requires ignoring pain, failed commands '
          'or a clear technical breakdown. Competition decisions remain yours and '
          'your qualified coach’s.',
        ),
      ],
    );
  }
}

class _StrengthHero extends StatelessWidget {
  const _StrengthHero({
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

class _ProtocolMetric extends StatelessWidget {
  const _ProtocolMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 235,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 5),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    ),
  );
}

class _DecimalSlider extends StatelessWidget {
  const _DecimalSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChanged,
    this.divisions = 20,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String suffix;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label\n${value.toStringAsFixed(value >= 10 ? 0 : 2)}$suffix',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    ),
  );
}

class _AttemptCard extends StatelessWidget {
  const _AttemptCard({
    required this.number,
    required this.title,
    required this.weight,
    required this.cue,
  });

  final int number;
  final String title;
  final double weight;
  final String cue;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 285,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(child: Text('$number')),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '${weight.toStringAsFixed(1)} kg',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(cue),
          ],
        ),
      ),
    ),
  );
}
