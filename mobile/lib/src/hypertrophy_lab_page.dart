import 'package:flutter/material.dart';

import 'exercise_intelligence_engine.dart';
import 'hypertrophy_engine.dart';
import 'models/fitness_models.dart';
import 'state/fitness_store.dart';

class HypertrophyLabPage extends StatefulWidget {
  const HypertrophyLabPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<HypertrophyLabPage> createState() => _HypertrophyLabPageState();
}

class _HypertrophyLabPageState extends State<HypertrophyLabPage> {
  String _muscle = 'chest';
  int _pump = 3;
  int _disruption = 3;
  int _soreness = 2;
  String _technique = 'MYO-REPS';
  late String _exercise;
  final _loadController = TextEditingController(text: '20');
  bool _saving = false;

  FitnessStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    _exercise = ExerciseIntelligenceEngine.allProfiles(store.data).first.name;
  }

  @override
  void dispose() {
    _loadController.dispose();
    super.dispose();
  }

  MuscleVolumeLandmark get _landmark => HypertrophyEngine.volumeLandmarks(
    store.data,
  ).firstWhere((item) => item.muscle == _muscle);

  HypertrophyCheckIn? get _latestCheckIn {
    final matches = store.hypertrophyCheckIns
        .where((item) => item.muscle == _muscle)
        .toList();
    matches.sort((left, right) => right.recordedAt.compareTo(left.recordedAt));
    return matches.firstOrNull;
  }

  Future<void> _saveCheckIn() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await store.saveHypertrophyCheckIn(
        muscle: _muscle,
        pump: _pump,
        disruption: _disruption,
        soreness: _soreness,
      );
      if (mounted) _message('$_muscle stimulus check-in saved locally.');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveTechnique() async {
    if (_saving) return;
    final prescription = HypertrophyEngine.technique(_technique);
    final load =
        double.tryParse(_loadController.text.replaceAll(',', '.')) ?? -1;
    setState(() => _saving = true);
    try {
      await store.saveHypertrophyTechniqueLog(
        technique: prescription.technique,
        exercise: _exercise,
        muscle: _muscle,
        weightKilograms: load,
        activationReps: prescription.activationReps,
        miniSetReps: List<int>.filled(
          prescription.rounds,
          prescription.miniSetReps,
        ),
      );
      if (mounted) {
        _message(
          '${prescription.technique} logged with its full cluster data.',
        );
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
        title: const Text('HYPERTROPHY LAB'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'VOLUME', icon: Icon(Icons.equalizer)),
            Tab(text: 'STIMULUS', icon: Icon(Icons.bolt_outlined)),
            Tab(text: 'TECHNIQUES', icon: Icon(Icons.layers_outlined)),
            Tab(text: 'SPECIALIZE', icon: Icon(Icons.auto_graph)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => TabBarView(
          children: [
            _volumeTab(context),
            _stimulusTab(context),
            _techniquesTab(context),
            _specializationTab(context),
          ],
        ),
      ),
    ),
  );

  Widget _musclePicker() => DropdownButtonFormField<String>(
    initialValue: _muscle,
    isExpanded: true,
    decoration: const InputDecoration(labelText: 'MUSCLE GROUP'),
    items: [
      for (final muscle in HypertrophyEngine.muscles)
        DropdownMenuItem(value: muscle, child: Text(muscle.toUpperCase())),
    ],
    onChanged: (value) {
      if (value != null) setState(() => _muscle = value);
    },
  );

  Widget _volumeTab(BuildContext context) {
    final landmarks = HypertrophyEngine.volumeLandmarks(store.data);
    final landmark = _landmark;
    final recommendation = HypertrophyEngine.volumeProgression(
      landmark: landmark,
      latestCheckIn: _latestCheckIn,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _LabHero(
          icon: Icons.equalizer,
          title: 'MUSCLE-GROUP VOLUME LANDMARKS',
          detail:
              'MEV, adaptive range and MRV are guardrails, recalculated from experience and real weekly sets.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final item in landmarks)
              SizedBox(
                width: 220,
                child: Card(
                  color: item.muscle == _muscle
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: InkWell(
                    onTap: () => setState(() => _muscle = item.muscle),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.muscle.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${item.currentWeeklySets} SETS • ${item.zone}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'MEV ${item.minimumEffective} • '
                            'MAV ${item.maximumAdaptive} • '
                            'MRV ${item.maximumRecoverable}',
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
            child: Column(
              children: [
                SizedBox(width: 300, child: _musclePicker()),
                _RatingSlider(
                  label: 'PUMP',
                  value: _pump,
                  onChanged: (value) => setState(() => _pump = value),
                ),
                _RatingSlider(
                  label: 'MUSCLE DISRUPTION',
                  value: _disruption,
                  onChanged: (value) => setState(() => _disruption = value),
                ),
                _RatingSlider(
                  label: 'SORENESS',
                  value: _soreness,
                  onChanged: (value) => setState(() => _soreness = value),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _saveCheckIn,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('SAVE PUMP & DISRUPTION CHECK-IN'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                '${recommendation.setChange >= 0 ? '+' : ''}'
                '${recommendation.setChange}',
              ),
            ),
            title: Text(recommendation.action),
            subtitle: Text(recommendation.reason),
          ),
        ),
      ],
    );
  }

  Widget _stimulusTab(BuildContext context) {
    final scores = HypertrophyEngine.stimulusFatigue(
      store.data,
      muscle: _muscle,
    ).take(30);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _LabHero(
          icon: Icons.bolt_outlined,
          title: 'STIMULUS-TO-FATIGUE SCORING',
          detail:
              'Ranks exercises by target stimulus, stability, skill cost and systemic fatigue.',
        ),
        const SizedBox(height: 14),
        SizedBox(width: 300, child: _musclePicker()),
        const SizedBox(height: 14),
        for (final score in scores)
          Card(
            child: ExpansionTile(
              leading: CircleAvatar(
                child: Text(score.ratio.toStringAsFixed(1)),
              ),
              title: Text(score.exercise),
              subtitle: Text(
                '${score.muscle} • stimulus ${score.stimulus} • '
                'fatigue ${score.fatigue}',
              ),
              trailing: score.lengthenedBias
                  ? const Chip(label: Text('LENGTHENED'))
                  : null,
              children: [
                ListTile(
                  title: const Text('EXECUTION CUE'),
                  subtitle: Text(score.cue),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _techniquesTab(BuildContext context) {
    final prescription = HypertrophyEngine.technique(_technique);
    final exercises = ExerciseIntelligenceEngine.allProfiles(store.data)
        .where((item) => item.primaryMuscles.contains(_muscle))
        .map((item) => item.name)
        .toSet()
        .toList();
    if (!exercises.contains(_exercise) && exercises.isNotEmpty) {
      _exercise = exercises.first;
    }
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _LabHero(
          icon: Icons.layers_outlined,
          title: 'ADVANCED SET TECHNIQUE LOGGING',
          detail:
              'Myo-reps, drop sets and rest-pause are logged as structured clusters with explicit stop rules.',
        ),
        const SizedBox(height: 14),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'MYO-REPS', label: Text('MYO-REPS')),
            ButtonSegment(value: 'DROP SET', label: Text('DROP SET')),
            ButtonSegment(value: 'REST-PAUSE', label: Text('REST-PAUSE')),
          ],
          selected: {_technique},
          onSelectionChanged: (value) {
            setState(() => _technique = value.first);
          },
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prescription.technique,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Activation ${prescription.activationReps} reps • '
                  '${prescription.rounds} × ${prescription.miniSetReps} mini reps • '
                  '${prescription.restSeconds}s rest'
                  '${prescription.loadDropPercentage > 0 ? ' • ${prescription.loadDropPercentage.round()}% load drop' : ''}',
                ),
                const SizedBox(height: 8),
                Text(prescription.stopRule),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(width: 260, child: _musclePicker()),
            SizedBox(
              width: 320,
              child: DropdownButtonFormField<String>(
                initialValue: exercises.contains(_exercise) ? _exercise : null,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'EXERCISE'),
                items: [
                  for (final exercise in exercises)
                    DropdownMenuItem(value: exercise, child: Text(exercise)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _exercise = value);
                },
              ),
            ),
            SizedBox(
              width: 190,
              child: TextField(
                controller: _loadController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'LOAD',
                  suffixText: 'kg',
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: _saving || exercises.isEmpty ? null : _saveTechnique,
              icon: const Icon(Icons.add_chart),
              label: const Text('LOG TECHNIQUE'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'RECENT TECHNIQUE SETS',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (store.hypertrophyTechniqueLogs.isEmpty)
          const Card(
            child: ListTile(
              title: Text('NO ADVANCED SETS LOGGED'),
              subtitle: Text(
                'Use intensifiers selectively, usually on the final stable exercise.',
              ),
            ),
          )
        else
          for (final log in store.hypertrophyTechniqueLogs.take(12))
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${log.totalReps}')),
                title: Text('${log.technique} • ${log.exercise}'),
                subtitle: Text(
                  '${log.weightKilograms.toStringAsFixed(1)} kg • '
                  '${log.activationReps} + ${log.miniSetReps.join('/')} reps',
                ),
              ),
            ),
      ],
    );
  }

  Widget _specializationTab(BuildContext context) {
    final landmark = _landmark;
    final baseline = landmark.currentWeeklySets > 0
        ? landmark.currentWeeklySets
        : landmark.minimumEffective;
    final block = HypertrophyEngine.specializationBlock(
      landmark: landmark,
      baselineSets: baseline,
    );
    final frequency = HypertrophyEngine.recommendedFrequency(
      weeklySets: block[2].targetSets,
      muscle: _muscle,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _LabHero(
          icon: Icons.auto_graph,
          title: 'HYPERTROPHY SPECIALIZATION BLOCK',
          detail:
              'Three progressive exposures followed by a deload, bounded by the selected muscle’s MRV.',
        ),
        const SizedBox(height: 14),
        SizedBox(width: 300, child: _musclePicker()),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('$frequency×')),
            title: const Text('PER-MUSCLE FREQUENCY PLANNER'),
            subtitle: Text(
              '${_muscle.toUpperCase()} • ${block[2].targetSets} peak-week sets • '
              '$frequency sessions/week',
            ),
          ),
        ),
        const SizedBox(height: 14),
        for (final week in block)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('W${week.week}')),
              title: Text(
                '${week.targetSets} SETS • ${week.frequency} EXPOSURES',
              ),
              subtitle: Text('${week.intensityTechnique} — ${week.note}'),
            ),
          ),
        const SizedBox(height: 14),
        const Card(
          child: ListTile(
            leading: Icon(Icons.shield_outlined),
            title: Text('VOLUME PROGRESSION RULE'),
            subtitle: Text(
              'Add at most one weekly set after a favorable check-in. '
              'Never progress volume and intensifier density simultaneously.',
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingSlider extends StatelessWidget {
  const _RatingSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 165,
        child: Text(
          '$label  $value/5',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Expanded(
        child: Slider(
          min: 1,
          max: 5,
          divisions: 4,
          value: value.toDouble(),
          onChanged: (next) => onChanged(next.round()),
        ),
      ),
    ],
  );
}

class _LabHero extends StatelessWidget {
  const _LabHero({
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
