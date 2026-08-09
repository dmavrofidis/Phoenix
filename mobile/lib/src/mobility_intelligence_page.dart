import 'package:flutter/material.dart';

import 'mobility_intelligence_engine.dart';
import 'state/fitness_store.dart';

class MobilityIntelligencePage extends StatefulWidget {
  const MobilityIntelligencePage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<MobilityIntelligencePage> createState() =>
      _MobilityIntelligencePageState();
}

class _MobilityIntelligencePageState extends State<MobilityIntelligencePage> {
  final _leftValue = TextEditingController(text: '10');
  final _rightValue = TextEditingController(text: '10');
  String _jointId = 'ankle-dorsiflexion';
  int _painLevel = 0;
  String _lift = 'Back squat';
  int _postureInterval = 60;
  bool _saving = false;

  FitnessStore get store => widget.store;

  @override
  void dispose() {
    _leftValue.dispose();
    _rightValue.dispose();
    super.dispose();
  }

  double _number(TextEditingController controller) =>
      double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;

  void _selectJoint(String jointId) {
    final definition = MobilityIntelligenceEngine.joint(jointId);
    setState(() {
      _jointId = jointId;
      _leftValue.text = definition.minimumTarget.toStringAsFixed(0);
      _rightValue.text = definition.minimumTarget.toStringAsFixed(0);
    });
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _saveScreen() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await store.saveMobilityScreen(
        jointId: _jointId,
        leftValue: _number(_leftValue),
        rightValue: _number(_rightValue),
        painLevel: _painLevel,
      );
      if (mounted) _message('Mobility screen saved for both sides.');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('MOBILITY INTELLIGENCE'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'SCREEN', icon: Icon(Icons.accessibility_new)),
            Tab(text: 'ASYMMETRY', icon: Icon(Icons.compare_arrows)),
            Tab(text: '5-MIN SNACKS', icon: Icon(Icons.timer_outlined)),
            Tab(text: 'MATCH & RETEST', icon: Icon(Icons.event_repeat)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => TabBarView(
          children: [
            _screenTab(context),
            _asymmetryTab(context),
            _snacksTab(context),
            _planningTab(context),
          ],
        ),
      ),
    ),
  );

  Widget _screenTab(BuildContext context) {
    final definition = MobilityIntelligenceEngine.joint(_jointId);
    final result = MobilityIntelligenceEngine.evaluate(
      jointId: _jointId,
      leftValue: _number(_leftValue),
      rightValue: _number(_rightValue),
      painLevel: _painLevel,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _MobilityHero(
          icon: Icons.accessibility_new,
          title: 'JOINT-BY-JOINT MOBILITY SCREEN',
          detail:
              'Four repeatable bilateral tests track ankle, hip, shoulder and thoracic motion without forcing range.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final joint in MobilityIntelligenceEngine.joints)
              ChoiceChip(
                label: Text(joint.name),
                selected: joint.id == _jointId,
                onSelected: (_) => _selectJoint(joint.id),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  definition.test.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text(definition.setup),
                const SizedBox(height: 5),
                Text(
                  'STOP RULE • ${definition.stopRule}',
                  style: const TextStyle(color: Colors.orangeAccent),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _NumberField(
              controller: _leftValue,
              label: 'LEFT',
              suffix: definition.unit,
              onChanged: () => setState(() {}),
            ),
            _NumberField(
              controller: _rightValue,
              label: 'RIGHT',
              suffix: definition.unit,
              onChanged: () => setState(() {}),
            ),
            _Metric(label: 'SCORE', value: '${result.score}/100'),
            _Metric(label: 'STATUS', value: result.status),
          ],
        ),
        _ScaleSlider(
          label: 'PAIN',
          value: _painLevel,
          maximum: 5,
          onChanged: (value) => setState(() => _painLevel = value),
        ),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.compare_arrows)),
            title: Text(
              'ASYMMETRY ${result.asymmetry.toStringAsFixed(1)}${definition.unit}',
            ),
            subtitle: Text(result.action),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _saving ? null : _saveScreen,
            icon: const Icon(Icons.save_outlined),
            label: const Text('SAVE BILATERAL SCREEN'),
          ),
        ),
      ],
    );
  }

  Widget _asymmetryTab(BuildContext context) {
    final latest = MobilityIntelligenceEngine.latestByJoint(
      store.mobilityScreenLogs,
    );
    final report = MobilityIntelligenceEngine.asymmetryReport(
      store.mobilityScreenLogs,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _MobilityHero(
          icon: Icons.compare_arrows,
          title: 'MOBILITY ASYMMETRY REPORT',
          detail:
              'Compares the latest left and right measurements using a tolerance specific to each joint.',
        ),
        const SizedBox(height: 14),
        if (report.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('NO BILATERAL SCREENS YET'),
              subtitle: Text(
                'Save one or more joint screens to build the report.',
              ),
            ),
          )
        else
          for (final item in report)
            Card(
              color: item.severity == 'HIGH'
                  ? Theme.of(context).colorScheme.errorContainer
                  : null,
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(item.weakerSide.substring(0, 1)),
                ),
                title: Text('${item.jointName} • ${item.severity}'),
                subtitle: Text(item.action),
                trailing: Text(
                  '${item.difference.toStringAsFixed(1)}${item.unit}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
        const SizedBox(height: 18),
        Text(
          'LATEST JOINT STATUS',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final definition in MobilityIntelligenceEngine.joints)
          Builder(
            builder: (context) {
              final log = latest[definition.id];
              final result = log == null
                  ? null
                  : MobilityIntelligenceEngine.evaluate(
                      jointId: definition.id,
                      leftValue: log.leftValue,
                      rightValue: log.rightValue,
                      painLevel: log.painLevel,
                    );
              return Card(
                child: ListTile(
                  title: Text(definition.name),
                  subtitle: Text(
                    log == null
                        ? 'Baseline not recorded'
                        : 'L ${log.leftValue.toStringAsFixed(1)} • '
                              'R ${log.rightValue.toStringAsFixed(1)} ${definition.unit}',
                  ),
                  trailing: Text(result?.status ?? 'DUE'),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _snacksTab(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const _MobilityHero(
        icon: Icons.timer_outlined,
        title: 'FIVE-MINUTE MOBILITY SNACKS',
        detail:
            'Short repeatable routines target the measured joint without turning warm-up into a workout.',
      ),
      const SizedBox(height: 14),
      for (final snack in MobilityIntelligenceEngine.snacks)
        Card(
          child: ExpansionTile(
            leading: CircleAvatar(child: Text('${snack.minutes}m')),
            title: Text(snack.name),
            subtitle: Text(
              MobilityIntelligenceEngine.joint(snack.focusJoint).name,
            ),
            children: [
              for (var index = 0; index < snack.drills.length; index++)
                ListTile(
                  leading: CircleAvatar(
                    radius: 14,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(snack.drills[index]),
                ),
              ListTile(
                leading: const Icon(Icons.repeat),
                title: Text(snack.dosing),
                subtitle: Text('STOP • ${snack.stopRule}'),
              ),
            ],
          ),
        ),
    ],
  );

  Widget _planningTab(BuildContext context) {
    final liftPlan = MobilityIntelligenceEngine.preLiftPlan(
      lift: _lift,
      logs: store.mobilityScreenLogs,
    );
    final breaks = MobilityIntelligenceEngine.postureBreaks(
      startMinutes: 9 * 60,
      endMinutes: 17 * 60,
      intervalMinutes: _postureInterval,
    );
    final retests = MobilityIntelligenceEngine.retestSchedule(
      store.mobilityScreenLogs,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _MobilityHero(
          icon: Icons.event_repeat,
          title: 'PRE-LIFT MOBILITY MATCHING',
          detail:
              'Uses the chosen lift and actual screen deficits to select a brief preparation plan and retest timing.',
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _lift,
          decoration: const InputDecoration(labelText: 'PRIMARY LIFT'),
          items: const [
            DropdownMenuItem(value: 'Back squat', child: Text('BACK SQUAT')),
            DropdownMenuItem(value: 'Deadlift', child: Text('DEADLIFT')),
            DropdownMenuItem(value: 'Bench press', child: Text('BENCH PRESS')),
            DropdownMenuItem(
              value: 'Overhead press',
              child: Text('OVERHEAD PRESS'),
            ),
          ],
          onChanged: (value) => setState(() => _lift = value ?? _lift),
        ),
        const SizedBox(height: 10),
        Card(
          child: ExpansionTile(
            initiallyExpanded: true,
            leading: CircleAvatar(child: Text('${liftPlan.minutes}m')),
            title: Text('${liftPlan.lift.toUpperCase()} PREP'),
            subtitle: Text(liftPlan.performanceRule),
            children: [
              for (final drill in liftPlan.drills)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.chevron_right),
                  title: Text(drill),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'POSTURE-BREAK REMINDER',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _ScaleSlider(
          label: 'INTERVAL MINUTES',
          value: _postureInterval,
          minimum: 30,
          maximum: 120,
          divisions: 3,
          onChanged: (value) => setState(() => _postureInterval = value),
        ),
        SizedBox(
          height: 105,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: breaks.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) => SizedBox(
              width: 170,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        breaks[index].label,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        breaks[index].actions.first,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'MOBILITY RETEST SCHEDULE',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final retest in retests)
          Card(
            child: ListTile(
              leading: const Icon(Icons.event_repeat),
              title: Text(retest.jointName),
              subtitle: Text(retest.reason),
              trailing: Text(
                '${retest.status}\n'
                '${retest.nextTestAt.day}/${retest.nextTestAt.month}',
                textAlign: TextAlign.end,
              ),
            ),
          ),
      ],
    );
  }
}

class _MobilityHero extends StatelessWidget {
  const _MobilityHero({
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
    required this.suffix,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 210,
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, suffixText: suffix),
      onChanged: (_) => onChanged(),
    ),
  );
}

class _ScaleSlider extends StatelessWidget {
  const _ScaleSlider({
    required this.label,
    required this.value,
    required this.maximum,
    required this.onChanged,
    this.minimum = 0,
    this.divisions,
  });

  final String label;
  final int value;
  final int minimum;
  final int maximum;
  final int? divisions;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 10),
      Text('$label • $value'),
      Slider(
        value: value.toDouble(),
        min: minimum.toDouble(),
        max: maximum.toDouble(),
        divisions: divisions ?? maximum - minimum,
        label: '$value',
        onChanged: (next) => onChanged(next.round()),
      ),
    ],
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 200,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    ),
  );
}
