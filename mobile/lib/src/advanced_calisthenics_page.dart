import 'package:flutter/material.dart';

import 'advanced_calisthenics_engine.dart';
import 'calisthenics_engine.dart';
import 'state/fitness_store.dart';

class AdvancedCalisthenicsPage extends StatefulWidget {
  const AdvancedCalisthenicsPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<AdvancedCalisthenicsPage> createState() =>
      _AdvancedCalisthenicsPageState();
}

class _AdvancedCalisthenicsPageState extends State<AdvancedCalisthenicsPage> {
  final _falseGripSeconds = TextEditingController(text: '20');
  final _ringSupportSeconds = TextEditingController(text: '15');
  final _holdSeconds = TextEditingController(text: '10');
  final _repetitions = TextEditingController(text: '0');
  String _skillId = 'muscle-up';
  int _stage = 1;
  int _quality = 4;
  int _rpe = 7;
  int _jointPain = 0;
  bool _secureContact = true;
  int _daysPerWeek = 3;
  final Set<String> _selectedSkills = {'muscle-up', 'front-lever'};
  bool _saving = false;

  FitnessStore get store => widget.store;

  @override
  void dispose() {
    _falseGripSeconds.dispose();
    _ringSupportSeconds.dispose();
    _holdSeconds.dispose();
    _repetitions.dispose();
    super.dispose();
  }

  int _integer(TextEditingController controller) =>
      int.tryParse(controller.text) ?? 0;

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _saveFalseGrip() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final grip = _integer(_falseGripSeconds);
      final support = _integer(_ringSupportSeconds);
      await store.saveSkillAssessment(
        skillId: 'false-grip',
        value: grip.toDouble(),
        unit: 'seconds',
        level: CalisthenicsEngine.levelFor('false-grip', grip.toDouble()),
      );
      await store.saveSkillAssessment(
        skillId: 'ring-support',
        value: support.toDouble(),
        unit: 'seconds',
        level: CalisthenicsEngine.levelFor('ring-support', support.toDouble()),
      );
      if (mounted) _message('False-grip and ring-support readiness saved.');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveSkillLog() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final tree = AdvancedCalisthenicsEngine.tree(_skillId);
      final stage = tree.stages[_stage.clamp(1, tree.stages.length) - 1];
      await store.saveCalisthenicsSkillLog(
        skillId: _skillId,
        progression: 'Stage $_stage • ${stage.name}',
        holdSeconds: _integer(_holdSeconds),
        repetitions: _integer(_repetitions),
        quality: _quality,
        rpe: _rpe,
        elbowPain: _jointPain,
        straightArm: const {
          'front-lever',
          'back-lever',
          'planche',
          'ring-support',
        }.contains(_skillId),
      );
      if (mounted) _message('${tree.name} exposure saved locally.');
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
        title: const Text('ADVANCED CALISTHENICS'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'PROGRESSIONS', icon: Icon(Icons.account_tree_outlined)),
            Tab(text: 'READINESS', icon: Icon(Icons.verified_outlined)),
            Tab(text: 'TRACK', icon: Icon(Icons.query_stats)),
            Tab(text: 'SCHEDULE', icon: Icon(Icons.calendar_month_outlined)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => TabBarView(
          children: [
            _progressionsTab(context),
            _readinessTab(context),
            _trackingTab(context),
            _scheduleTab(context),
          ],
        ),
      ),
    ),
  );

  Widget _progressionsTab(BuildContext context) {
    final tree = AdvancedCalisthenicsEngine.tree(_skillId);
    final achieved = AdvancedCalisthenicsEngine.currentStage(
      _skillId,
      store.calisthenicsSkillLogs,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _CaliHero(
          icon: Icons.account_tree_outlined,
          title: 'SIX ADVANCED SKILL TREES',
          detail:
              'Every path advances through measurable, pain-free stages instead of random maximal attempts.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in AdvancedCalisthenicsEngine.trees)
              ChoiceChip(
                label: Text(option.name),
                selected: option.id == _skillId,
                onSelected: (_) => setState(() {
                  _skillId = option.id;
                  _stage = 1;
                }),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('$achieved/5')),
            title: Text('${tree.name} • ${tree.category}'),
            subtitle: Text('ENTRY: ${tree.entryRequirement}'),
          ),
        ),
        const SizedBox(height: 8),
        for (final stage in tree.stages)
          Card(
            color: stage.level <= achieved ? const Color(0xFF142318) : null,
            child: ExpansionTile(
              leading: CircleAvatar(child: Text('${stage.level}')),
              title: Text(stage.name),
              subtitle: Text(stage.target),
              trailing: Icon(
                stage.level <= achieved
                    ? Icons.verified
                    : Icons.lock_open_outlined,
              ),
              children: [
                ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: Text(stage.coachingCue),
                  subtitle: Text('SAFETY • ${stage.riskNote}'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _readinessTab(BuildContext context) {
    final result = AdvancedCalisthenicsEngine.falseGripReadiness(
      hangSeconds: _integer(_falseGripSeconds),
      ringSupportSeconds: _integer(_ringSupportSeconds),
      wristPain: _jointPain,
      secureContact: _secureContact,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _CaliHero(
          icon: Icons.verified_outlined,
          title: 'FALSE-GRIP READINESS TEST',
          detail:
              'Checks grip endurance, ring support, joint comfort and secure wrist contact before transitions.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _NumberField(
              controller: _falseGripSeconds,
              label: 'FALSE-GRIP HANG',
              suffix: 's',
              onChanged: () => setState(() {}),
            ),
            _NumberField(
              controller: _ringSupportSeconds,
              label: 'RING SUPPORT',
              suffix: 's',
              onChanged: () => setState(() {}),
            ),
            _Metric(label: 'READINESS', value: '${result.score}%'),
            _Metric(label: 'STATUS', value: result.level),
          ],
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          value: _secureContact,
          onChanged: (value) => setState(() => _secureContact = value),
          title: const Text('SECURE WRIST CONTACT'),
          subtitle: const Text('Grip does not slip during a controlled hang.'),
        ),
        _ScaleSlider(
          label: 'WRIST / ELBOW PAIN',
          value: _jointPain,
          minimum: 0,
          maximum: 5,
          onChanged: (value) => setState(() => _jointPain = value),
        ),
        for (final check in result.checks.entries)
          Card(
            child: ListTile(
              leading: Icon(
                check.value ? Icons.check_circle : Icons.pending_outlined,
                color: check.value ? Colors.greenAccent : Colors.orangeAccent,
              ),
              title: Text(check.key),
            ),
          ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.arrow_forward),
            title: const Text('NEXT ACTION'),
            subtitle: Text(result.nextAction),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _saving ? null : _saveFalseGrip,
            icon: const Icon(Icons.save_outlined),
            label: const Text('SAVE READINESS'),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'SKILL READINESS GATES',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final skill in AdvancedCalisthenicsEngine.skillIds)
          Builder(
            builder: (context) {
              final gate = AdvancedCalisthenicsEngine.readiness(
                skill,
                store.data,
                profile: store.profile,
              );
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${gate.score}')),
                  title: Text(AdvancedCalisthenicsEngine.tree(skill).name),
                  subtitle: Text(
                    '${gate.passedChecks}/${gate.totalChecks} checks • ${gate.action}',
                  ),
                  trailing: Text(gate.status),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _trackingTab(BuildContext context) {
    final tree = AdvancedCalisthenicsEngine.tree(_skillId);
    final stageCount = tree.stages.length;
    final straightArm = AdvancedCalisthenicsEngine.straightArmTrend(
      _skillId,
      store.calisthenicsSkillLogs,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _CaliHero(
          icon: Icons.query_stats,
          title: 'STRAIGHT-ARM STRENGTH TRACKING',
          detail:
              'Logs leverage, hold or reps, technical quality, effort and joint response for honest progression.',
        ),
        const SizedBox(height: 14),
        _SkillDropdown(
          value: _skillId,
          onChanged: (value) => setState(() {
            _skillId = value;
            _stage = 1;
          }),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          initialValue: _stage.clamp(1, stageCount),
          decoration: const InputDecoration(labelText: 'PROGRESSION STAGE'),
          items: [
            for (final stage in tree.stages)
              DropdownMenuItem(
                value: stage.level,
                child: Text('${stage.level} • ${stage.name}'),
              ),
          ],
          onChanged: (value) => setState(() => _stage = value ?? 1),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _NumberField(
              controller: _holdSeconds,
              label: 'BEST CLEAN HOLD',
              suffix: 's',
              onChanged: () {},
            ),
            _NumberField(
              controller: _repetitions,
              label: 'CLEAN REPS',
              onChanged: () {},
            ),
          ],
        ),
        _ScaleSlider(
          label: 'TECHNICAL QUALITY',
          value: _quality,
          minimum: 1,
          maximum: 5,
          onChanged: (value) => setState(() => _quality = value),
        ),
        _ScaleSlider(
          label: 'RPE',
          value: _rpe,
          minimum: 1,
          maximum: 10,
          onChanged: (value) => setState(() => _rpe = value),
        ),
        _ScaleSlider(
          label: 'ELBOW / WRIST PAIN',
          value: _jointPain,
          minimum: 0,
          maximum: 5,
          onChanged: (value) => setState(() => _jointPain = value),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _saving ? null : _saveSkillLog,
            icon: const Icon(Icons.save_outlined),
            label: const Text('SAVE SKILL EXPOSURE'),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Metric(
              label: 'BEST HOLD',
              value: '${straightArm.bestHoldSeconds}s',
            ),
            _Metric(label: 'EXPOSURES', value: '${straightArm.exposures}'),
            _Metric(
              label: 'QUALITY',
              value: straightArm.averageQuality.toStringAsFixed(1),
            ),
            _Metric(label: 'TREND', value: straightArm.status),
          ],
        ),
      ],
    );
  }

  Widget _scheduleTab(BuildContext context) {
    final schedule = AdvancedCalisthenicsEngine.exposureSchedule(
      selectedSkills: _selectedSkills,
      daysPerWeek: _daysPerWeek,
      data: store.data,
      profile: store.profile,
    );
    final deload = AdvancedCalisthenicsEngine.deloadDecision(
      store.calisthenicsSkillLogs,
    );
    const weekday = <int, String>{
      1: 'MON',
      2: 'TUE',
      3: 'WED',
      4: 'THU',
      5: 'FRI',
      6: 'SAT',
      7: 'SUN',
    };
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _CaliHero(
          icon: Icons.calendar_month_outlined,
          title: 'SKILL EXPOSURE SCHEDULER',
          detail:
              'Distributes up to three skills with 48-hour spacing, submaximal intent and a built-in deload decision.',
        ),
        const SizedBox(height: 14),
        Text(
          'SELECT UP TO 3 SKILLS',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tree in AdvancedCalisthenicsEngine.trees)
              FilterChip(
                label: Text(tree.name),
                selected: _selectedSkills.contains(tree.id),
                onSelected: (selected) {
                  setState(() {
                    if (selected && _selectedSkills.length < 3) {
                      _selectedSkills.add(tree.id);
                    } else if (!selected && _selectedSkills.length > 1) {
                      _selectedSkills.remove(tree.id);
                    }
                  });
                },
              ),
          ],
        ),
        _ScaleSlider(
          label: 'SKILL DAYS / WEEK',
          value: _daysPerWeek,
          minimum: 2,
          maximum: 5,
          onChanged: (value) => setState(() => _daysPerWeek = value),
        ),
        for (final day in schedule)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(weekday[day.weekday] ?? '?')),
              title: Text(
                day.focusSkills
                    .map((id) => AdvancedCalisthenicsEngine.tree(id).name)
                    .join(' + '),
              ),
              subtitle: Text(
                '${day.attemptsPerSkill} attempts/skill • '
                '${day.minimumHoursBeforeNext}h spacing • ${day.note}',
              ),
              trailing: Text(day.intensity),
            ),
          ),
        const SizedBox(height: 18),
        Card(
          color: deload.required ? const Color(0xFF2B190E) : null,
          child: ExpansionTile(
            leading: const CircleAvatar(child: Icon(Icons.battery_saver)),
            title: Text('CALISTHENICS DELOAD • ${deload.level}'),
            subtitle: Text(
              '${(deload.volumeMultiplier * 100).round()}% volume • '
              '${deload.reasons.isEmpty ? 'No current trigger' : deload.reasons.join(' • ')}',
            ),
            children: [
              for (final rule in deload.rules)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.shield_outlined, size: 20),
                  title: Text(rule),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CaliHero extends StatelessWidget {
  const _CaliHero({
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

class _SkillDropdown extends StatelessWidget {
  const _SkillDropdown({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: value,
    decoration: const InputDecoration(labelText: 'ADVANCED SKILL'),
    items: [
      for (final tree in AdvancedCalisthenicsEngine.trees)
        DropdownMenuItem(value: tree.id, child: Text(tree.name)),
    ],
    onChanged: (value) {
      if (value != null) onChanged(value);
    },
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
    width: 210,
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix.isEmpty ? null : suffix,
      ),
      onChanged: (_) => onChanged(),
    ),
  );
}

class _ScaleSlider extends StatelessWidget {
  const _ScaleSlider({
    required this.label,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int minimum;
  final int maximum;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 10),
      Text('$label • $value/$maximum'),
      Slider(
        value: value.toDouble(),
        min: minimum.toDouble(),
        max: maximum.toDouble(),
        divisions: maximum - minimum,
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
