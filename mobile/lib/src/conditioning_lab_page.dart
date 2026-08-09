import 'package:flutter/material.dart';

import 'conditioning_engine.dart';
import 'state/fitness_store.dart';

class ConditioningLabPage extends StatefulWidget {
  const ConditioningLabPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<ConditioningLabPage> createState() => _ConditioningLabPageState();
}

class _ConditioningLabPageState extends State<ConditioningLabPage> {
  int _restingHeartRate = 60;
  int _zone2Minutes = 30;
  String _intervalGoal = 'vo2';
  late String _modality;
  int _sessionRpe = 5;
  int _sessionZone = 2;
  final _sessionMinutes = TextEditingController(text: '30');
  final _averageHr = TextEditingController(text: '130');
  String _benchmarkTest = 'cooper-12';
  final _benchmarkValue = TextEditingController(text: '2400');
  bool _saving = false;

  FitnessStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    _modality = ConditioningEngine.modalitySelector(
      profile: store.profile,
    ).first;
  }

  @override
  void dispose() {
    _sessionMinutes.dispose();
    _averageHr.dispose();
    _benchmarkValue.dispose();
    super.dispose();
  }

  int get _age => store.profile?.age ?? 30;

  Future<void> _saveSession() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await store.saveCardioSession(
        modality: _modality,
        durationMinutes: int.tryParse(_sessionMinutes.text) ?? 0,
        rpe: _sessionRpe,
        averageHeartRate: int.tryParse(_averageHr.text) ?? 0,
        targetZone: _sessionZone,
      );
      if (mounted) _message('RPE-based cardio session saved locally.');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveBenchmark() async {
    if (_saving) return;
    final value =
        double.tryParse(_benchmarkValue.text.replaceAll(',', '.')) ?? 0;
    final assessment = ConditioningEngine.benchmark(
      test: _benchmarkTest,
      value: value,
      age: _age,
    );
    setState(() => _saving = true);
    try {
      await store.saveConditioningBenchmark(
        test: assessment.test,
        value: value,
        unit: _benchmarkUnit,
        score: assessment.estimatedVo2Max > 0
            ? assessment.estimatedVo2Max
            : assessment.score,
        label: assessment.label,
      );
      if (mounted) _message('${assessment.test} benchmark saved locally.');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String get _benchmarkUnit => switch (_benchmarkTest) {
    'cooper-12' => 'meters',
    'row-2000' => 'seconds',
    'bike-20' => 'watts/kg',
    _ => 'bpm drop',
  };

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
        title: const Text('CONDITIONING LAB'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'ZONES', icon: Icon(Icons.favorite_outline)),
            Tab(text: 'BUILDER', icon: Icon(Icons.timer_outlined)),
            Tab(text: 'LOAD', icon: Icon(Icons.stacked_line_chart)),
            Tab(text: 'BENCHMARKS', icon: Icon(Icons.flag_outlined)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => TabBarView(
          children: [
            _zonesTab(context),
            _builderTab(context),
            _loadTab(context),
            _benchmarkTab(context),
          ],
        ),
      ),
    ),
  );

  Widget _zonesTab(BuildContext context) {
    final zones = ConditioningEngine.heartRateZones(
      age: _age,
      restingHeartRate: _restingHeartRate,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _ConditioningHero(
          icon: Icons.favorite_outline,
          title: 'HEART-RATE ZONE CALCULATOR',
          detail:
              'Uses heart-rate reserve and your resting pulse. The talk test remains the practical guardrail.',
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 190,
                  child: Text(
                    'RESTING HR\n$_restingHeartRate bpm • age $_age',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: _restingHeartRate.toDouble(),
                    min: 40,
                    max: 100,
                    divisions: 60,
                    onChanged: (value) =>
                        setState(() => _restingHeartRate = value.round()),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final zone in zones)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('Z${zone.zone}')),
              title: Text(
                '${zone.label} • ${zone.minimumBpm}–${zone.maximumBpm} bpm',
              ),
              subtitle: Text(zone.purpose),
            ),
          ),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            leading: Icon(Icons.record_voice_over_outlined),
            title: Text('ZONE 2 TALK TEST'),
            subtitle: Text(
              'You can speak in full sentences, breathing is elevated but controlled, '
              'and pace can be sustained without a late-session surge.',
            ),
          ),
        ),
      ],
    );
  }

  Widget _builderTab(BuildContext context) {
    final modalities = ConditioningEngine.modalitySelector(
      profile: store.profile,
      goal: _intervalGoal == 'sprint' ? 'sprint' : 'aerobic',
    );
    if (!modalities.contains(_modality)) _modality = modalities.first;
    final zone2 = ConditioningEngine.zone2Session(
      modality: _modality,
      minutes: _zone2Minutes,
      experienceLevel: store.profile?.experienceLevel ?? 'Beginner',
    );
    final interval = ConditioningEngine.intervalSession(
      modality: _modality,
      goal: _intervalGoal,
      experienceLevel: store.profile?.experienceLevel ?? 'Beginner',
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _ConditioningHero(
          icon: Icons.timer_outlined,
          title: 'CONDITIONING SESSION BUILDER',
          detail:
              'Builds sustainable Zone 2 or repeatable intervals with a clear output stop rule.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 280,
              child: DropdownButtonFormField<String>(
                initialValue: _modality,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'MODALITY'),
                items: [
                  for (final item in modalities)
                    DropdownMenuItem(value: item, child: Text(item)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _modality = value);
                },
              ),
            ),
            SizedBox(
              width: 250,
              child: DropdownButtonFormField<String>(
                initialValue: _intervalGoal,
                decoration: const InputDecoration(labelText: 'INTERVAL GOAL'),
                items: const [
                  DropdownMenuItem(value: 'vo2', child: Text('VO2')),
                  DropdownMenuItem(
                    value: 'threshold',
                    child: Text('THRESHOLD'),
                  ),
                  DropdownMenuItem(value: 'tempo', child: Text('TEMPO')),
                  DropdownMenuItem(value: 'sprint', child: Text('SPRINT')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _intervalGoal = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                SizedBox(
                  width: 180,
                  child: Text(
                    'ZONE 2 DURATION\n$_zone2Minutes minutes',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: _zone2Minutes.toDouble(),
                    min: 20,
                    max: 75,
                    divisions: 11,
                    onChanged: (value) =>
                        setState(() => _zone2Minutes = value.round()),
                  ),
                ),
              ],
            ),
          ),
        ),
        _SessionPlanCard(plan: zone2),
        const SizedBox(height: 10),
        _SessionPlanCard(plan: interval),
        const SizedBox(height: 16),
        Text(
          'WORK-TO-REST RATIO PRESETS',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in ConditioningEngine.workRestPresets())
              Chip(
                label: Text(
                  '${preset.label} ${preset.workSeconds}s:'
                  '${preset.restSeconds}s × ${preset.rounds}',
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RPE-BASED CARDIO LOG',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 180,
                      child: TextField(
                        controller: _sessionMinutes,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'MINUTES'),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: TextField(
                        controller: _averageHr,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'AVERAGE HR',
                        ),
                      ),
                    ),
                  ],
                ),
                _IntegerSlider(
                  label: 'SESSION RPE',
                  value: _sessionRpe,
                  min: 1,
                  max: 10,
                  onChanged: (value) => setState(() => _sessionRpe = value),
                ),
                _IntegerSlider(
                  label: 'TARGET ZONE',
                  value: _sessionZone,
                  min: 1,
                  max: 5,
                  onChanged: (value) => setState(() => _sessionZone = value),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _saveSession,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('SAVE CARDIO SESSION'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _loadTab(BuildContext context) {
    final summary = ConditioningEngine.weeklyLoad(store.cardioSessions);
    final risk = ConditioningEngine.interferenceRisk(
      strengthDays: store.profile?.daysPerWeek ?? 3,
      cardio: summary,
    );
    final progression = ConditioningEngine.aerobicBaseProgression(
      baselineMinutes: _zone2Minutes,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _ConditioningHero(
          icon: Icons.stacked_line_chart,
          title: 'WEEKLY CARDIO LOAD',
          detail:
              'Session-RPE load, high-intensity density and strength interference are tracked together.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _LoadMetric(label: 'MINUTES', value: '${summary.totalMinutes}'),
            _LoadMetric(label: 'RPE LOAD', value: '${summary.totalLoad}'),
            _LoadMetric(label: 'SESSIONS', value: '${summary.sessions}'),
            _LoadMetric(
              label: 'HARD DAYS',
              value: '${summary.highIntensitySessions}',
            ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          color: risk.level == 'HIGH'
              ? Theme.of(context).colorScheme.errorContainer
              : null,
          child: ExpansionTile(
            leading: const Icon(Icons.compare_arrows),
            title: Text(risk.title),
            subtitle: Text('Interference score ${risk.score}/100'),
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
        const SizedBox(height: 18),
        Text(
          'AEROBIC BASE PROGRESSION',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final week in progression)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('W${week.week}')),
              title: Text(
                '${week.sessions} × ${week.minutesPerSession} MINUTES',
              ),
              subtitle: Text(
                week.deload
                    ? 'DELOAD — easy Zone 2 only'
                    : 'Add duration only while talk-test pace remains stable.',
              ),
            ),
          ),
      ],
    );
  }

  Widget _benchmarkTab(BuildContext context) {
    final value =
        double.tryParse(_benchmarkValue.text.replaceAll(',', '.')) ?? 0;
    final assessment = ConditioningEngine.benchmark(
      test: _benchmarkTest,
      value: value,
      age: _age,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _ConditioningHero(
          icon: Icons.flag_outlined,
          title: 'CONDITIONING BENCHMARK TESTS',
          detail:
              'Repeatable field tests for aerobic progress, without requiring an all-out medical-style test.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 290,
              child: DropdownButtonFormField<String>(
                initialValue: _benchmarkTest,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'BENCHMARK'),
                items: const [
                  DropdownMenuItem(
                    value: 'cooper-12',
                    child: Text('12-MINUTE COOPER'),
                  ),
                  DropdownMenuItem(
                    value: 'row-2000',
                    child: Text('2K ROW TIME'),
                  ),
                  DropdownMenuItem(
                    value: 'bike-20',
                    child: Text('20-MIN BIKE W/KG'),
                  ),
                  DropdownMenuItem(
                    value: 'step-recovery',
                    child: Text('STEP HR RECOVERY'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _benchmarkTest = value;
                    _benchmarkValue.text = switch (value) {
                      'cooper-12' => '2400',
                      'row-2000' => '500',
                      'bike-20' => '2.5',
                      _ => '25',
                    };
                  });
                },
              ),
            ),
            SizedBox(
              width: 220,
              child: TextField(
                controller: _benchmarkValue,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'RESULT',
                  suffixText: _benchmarkUnit,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                assessment.estimatedVo2Max > 0
                    ? assessment.estimatedVo2Max.toStringAsFixed(0)
                    : assessment.score.toStringAsFixed(0),
              ),
            ),
            title: Text('${assessment.test} • ${assessment.label}'),
            subtitle: Text(assessment.cue),
            trailing: FilledButton(
              onPressed: _saving || value <= 0 ? null : _saveBenchmark,
              child: const Text('SAVE RESULT'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (store.conditioningBenchmarks.isEmpty)
          const Card(
            child: ListTile(
              title: Text('NO BENCHMARK HISTORY'),
              subtitle: Text('Repeat the same test every 6–8 weeks.'),
            ),
          )
        else
          for (final result in store.conditioningBenchmarks.take(12))
            Card(
              child: ListTile(
                title: Text('${result.test} • ${result.label}'),
                subtitle: Text(
                  '${result.value.toStringAsFixed(1)} ${result.unit} • '
                  'score ${result.score.toStringAsFixed(1)}',
                ),
              ),
            ),
      ],
    );
  }
}

class _ConditioningHero extends StatelessWidget {
  const _ConditioningHero({
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

class _SessionPlanCard extends StatelessWidget {
  const _SessionPlanCard({required this.plan});

  final ConditioningSessionPlan plan;

  @override
  Widget build(BuildContext context) => Card(
    child: ExpansionTile(
      leading: CircleAvatar(child: Text('Z${plan.targetZone}')),
      title: Text('${plan.name} • ${plan.totalMinutes} MIN'),
      subtitle: Text('${plan.modality} • target RPE ${plan.targetRpe}'),
      children: [
        ListTile(
          title: Text(
            plan.rounds == 1
                ? '${plan.workSeconds ~/ 60} min continuous work'
                : '${plan.rounds} × ${plan.workSeconds}s work / '
                      '${plan.restSeconds}s recovery',
          ),
          subtitle: Text(
            '${plan.warmupMinutes} min warm-up • '
            '${plan.cooldownMinutes} min cooldown\n${plan.stopRule}',
          ),
        ),
      ],
    ),
  );
}

class _IntegerSlider extends StatelessWidget {
  const _IntegerSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 150,
        child: Text(
          '$label  $value',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Expanded(
        child: Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          onChanged: (next) => onChanged(next.round()),
        ),
      ),
    ],
  );
}

class _LoadMetric extends StatelessWidget {
  const _LoadMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 190,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    ),
  );
}
