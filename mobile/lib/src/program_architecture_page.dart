import 'package:flutter/material.dart';

import 'models/fitness_models.dart';
import 'program_architecture_engine.dart';
import 'state/fitness_store.dart';

class ProgramArchitecturePage extends StatefulWidget {
  const ProgramArchitecturePage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<ProgramArchitecturePage> createState() =>
      _ProgramArchitecturePageState();
}

class _ProgramArchitecturePageState extends State<ProgramArchitecturePage> {
  late ProgramArchitectureInput _input;
  late ProgramArchitectureResult _result;
  late DateTime _generationStamp;
  bool _saving = false;

  FitnessStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    final profile = store.profile;
    _input = ProgramArchitectureInput(
      goal: profile?.goal ?? 'Strength and muscle',
      daysPerWeek: (profile?.daysPerWeek ?? 3).clamp(2, 6),
      sessionMinutes: (profile?.sessionMinutes ?? 45).clamp(20, 120),
      experienceLevel: profile?.experienceLevel ?? 'Beginner',
    );
    _generationStamp = DateTime.now();
    _result = _buildResult();
  }

  ProgramArchitectureResult _buildResult() => ProgramArchitectureEngine.build(
    data: store.data,
    input: _input,
    generatedAt: _generationStamp,
  );

  void _update(ProgramArchitectureInput input) {
    setState(() {
      _input = input;
      _generationStamp = DateTime.now();
      _result = _buildResult();
    });
  }

  ProgramArchitectureInput _copyInput({
    String? goal,
    int? daysPerWeek,
    int? sessionMinutes,
    String? experienceLevel,
    int? mesocycleWeeks,
    ProgramVolumeMode? volumeMode,
    String? preferredSplit,
    bool? includeConditioning,
  }) => ProgramArchitectureInput(
    goal: goal ?? _input.goal,
    daysPerWeek: daysPerWeek ?? _input.daysPerWeek,
    sessionMinutes: sessionMinutes ?? _input.sessionMinutes,
    experienceLevel: experienceLevel ?? _input.experienceLevel,
    mesocycleWeeks: mesocycleWeeks ?? _input.mesocycleWeeks,
    volumeMode: volumeMode ?? _input.volumeMode,
    preferredSplit: preferredSplit ?? _input.preferredSplit,
    includeConditioning: includeConditioning ?? _input.includeConditioning,
  );

  Future<void> _saveProgram() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      for (final template in _result.templates) {
        await store.updateWorkoutTemplate(template);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_result.templates.length} architecture sessions saved locally.',
            ),
          ),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 3,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('PROGRAM ARCHITECTURE'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'DESIGN', icon: Icon(Icons.tune)),
            Tab(text: 'PROGRAM', icon: Icon(Icons.view_week_outlined)),
            Tab(text: 'AUDIT', icon: Icon(Icons.fact_check_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          _DesignTab(
            input: _input,
            options: ProgramArchitectureEngine.splitOptions(_input),
            onChanged: _update,
            copyInput: _copyInput,
          ),
          _ProgramTab(
            input: _input,
            result: _result,
            saving: _saving,
            onSave: _saveProgram,
          ),
          _AuditTab(input: _input, result: _result),
        ],
      ),
    ),
  );
}

class _DesignTab extends StatelessWidget {
  const _DesignTab({
    required this.input,
    required this.options,
    required this.onChanged,
    required this.copyInput,
  });

  final ProgramArchitectureInput input;
  final List<ProgramSplitOption> options;
  final ValueChanged<ProgramArchitectureInput> onChanged;
  final ProgramArchitectureInput Function({
    String? goal,
    int? daysPerWeek,
    int? sessionMinutes,
    String? experienceLevel,
    int? mesocycleWeeks,
    ProgramVolumeMode? volumeMode,
    String? preferredSplit,
    bool? includeConditioning,
  })
  copyInput;

  @override
  Widget build(BuildContext context) {
    final frequency = ProgramArchitectureEngine.recommendedFrequency(input);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _HeroCard(
          icon: Icons.architecture,
          title: 'MESOCYCLE PROGRAM WIZARD',
          detail:
              'Designs the split, exercise order, set budget and movement balance around your real week.',
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final controls = [
              _SliderControl(
                label: 'TRAINING DAYS',
                value: input.daysPerWeek,
                min: 2,
                max: 6,
                suffix: '/week',
                onChanged: (value) => onChanged(copyInput(daysPerWeek: value)),
              ),
              _SliderControl(
                label: 'SESSION BUDGET',
                value: input.sessionMinutes,
                min: 20,
                max: 120,
                divisions: 20,
                suffix: ' min',
                onChanged: (value) =>
                    onChanged(copyInput(sessionMinutes: value)),
              ),
              _SliderControl(
                label: 'MESOCYCLE',
                value: input.mesocycleWeeks,
                min: 3,
                max: 8,
                suffix: ' weeks',
                onChanged: (value) =>
                    onChanged(copyInput(mesocycleWeeks: value)),
              ),
            ];
            if (!wide) return Column(children: controls);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final control in controls) Expanded(child: control),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DropdownMenu<String>(
              initialSelection: input.goal,
              label: const Text('PRIMARY GOAL'),
              width: 250,
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'Strength', label: 'STRENGTH'),
                DropdownMenuEntry(
                  value: 'Muscle hypertrophy',
                  label: 'MUSCLE HYPERTROPHY',
                ),
                DropdownMenuEntry(
                  value: 'General fitness',
                  label: 'GENERAL FITNESS',
                ),
                DropdownMenuEntry(value: 'Calisthenics', label: 'CALISTHENICS'),
              ],
              onSelected: (value) {
                if (value != null) onChanged(copyInput(goal: value));
              },
            ),
            DropdownMenu<String>(
              initialSelection: input.experienceLevel,
              label: const Text('EXPERIENCE'),
              width: 210,
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'Beginner', label: 'BEGINNER'),
                DropdownMenuEntry(value: 'Intermediate', label: 'INTERMEDIATE'),
                DropdownMenuEntry(value: 'Advanced', label: 'ADVANCED'),
              ],
              onSelected: (value) {
                if (value != null) {
                  onChanged(copyInput(experienceLevel: value));
                }
              },
            ),
            SegmentedButton<ProgramVolumeMode>(
              segments: const [
                ButtonSegment(
                  value: ProgramVolumeMode.minimumEffective,
                  label: Text('MED'),
                ),
                ButtonSegment(
                  value: ProgramVolumeMode.balanced,
                  label: Text('BALANCED'),
                ),
                ButtonSegment(
                  value: ProgramVolumeMode.high,
                  label: Text('HIGH'),
                ),
              ],
              selected: {input.volumeMode},
              onSelectionChanged: (value) =>
                  onChanged(copyInput(volumeMode: value.first)),
            ),
            FilterChip(
              label: const Text('INCLUDE CONDITIONING'),
              selected: input.includeConditioning,
              onSelected: (value) =>
                  onChanged(copyInput(includeConditioning: value)),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'GOAL-SPECIFIC SPLIT SELECTOR',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        for (final option in options)
          Card(
            color:
                (input.preferredSplit.isEmpty &&
                        option.id == options.first.id) ||
                    option.id == input.preferredSplit
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            child: CheckboxListTile(
              value:
                  (input.preferredSplit.isEmpty &&
                      option.id == options.first.id) ||
                  option.id == input.preferredSplit,
              onChanged: (_) {
                onChanged(copyInput(preferredSplit: option.id));
              },
              title: Row(
                children: [
                  Expanded(child: Text(option.label)),
                  Text('${option.score}/100'),
                ],
              ),
              subtitle: Text(option.reason),
            ),
          ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FREQUENCY RECOMMENDATION',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in frequency.entries)
                      Chip(label: Text('${entry.key}: ${entry.value}×')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgramTab extends StatelessWidget {
  const _ProgramTab({
    required this.input,
    required this.result,
    required this.saving,
    required this.onSave,
  });

  final ProgramArchitectureInput input;
  final ProgramArchitectureResult result;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                child: Text('${result.templates.length}D'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.split.label,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${result.mesocycleWeeks} weeks • '
                      '${input.volumeMode.name} • ${input.sessionMinutes}′ cap',
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: saving || result.hasBlockingConflict ? null : onSave,
                icon: saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('SAVE ALL TO LIBRARY'),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      for (var index = 0; index < result.templates.length; index++)
        _SessionCard(
          index: index,
          template: result.templates[index],
          estimatedMinutes:
              result.estimatedMinutes[result.templates[index].id] ?? 0,
        ),
    ],
  );
}

class _AuditTab extends StatelessWidget {
  const _AuditTab({required this.input, required this.result});

  final ProgramArchitectureInput input;
  final ProgramArchitectureResult result;

  @override
  Widget build(BuildContext context) {
    final blocking = result.hasBlockingConflict;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _HeroCard(
          icon: blocking ? Icons.error_outline : Icons.verified_outlined,
          title: blocking
              ? 'ARCHITECTURE NEEDS REVISION'
              : 'ARCHITECTURE IS RELEASE-READY',
          detail:
              '${result.issues.length} audit finding(s) • '
              'MED ${result.minimumEffectiveDose} sets • '
              'MRV guard ${result.maximumRecoverableSets} sets',
          warning: blocking,
        ),
        const SizedBox(height: 16),
        _MetricSection(
          title: 'WEEKLY SET BUDGET',
          values: result.weeklySetBudget,
          suffix: 'sets',
        ),
        _MetricSection(
          title: 'MUSCLE FREQUENCY',
          values: result.muscleFrequency,
          suffix: 'sessions',
        ),
        _MetricSection(
          title: 'MOVEMENT BALANCE AUDIT',
          values: result.movementCoverage,
          suffix: 'slots',
        ),
        const SizedBox(height: 8),
        Text(
          'CONFLICT RESOLVER',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (result.issues.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('NO ARCHITECTURE CONFLICT'),
              subtitle: Text(
                'Time, movement balance and recoverable-volume guards passed.',
              ),
            ),
          )
        else
          for (final issue in result.issues)
            Card(
              child: ListTile(
                leading: Icon(
                  issue.severity == 'critical'
                      ? Icons.error_outline
                      : issue.severity == 'warning'
                      ? Icons.warning_amber
                      : Icons.info_outline,
                ),
                title: Text(issue.title),
                subtitle: Text(issue.detail),
                trailing: Text(issue.severity.toUpperCase()),
              ),
            ),
        if (result.adjustments.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'AUTOMATIC RESOLUTION NOTES',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          for (final adjustment in result.adjustments)
            ListTile(
              dense: true,
              leading: const Icon(Icons.auto_fix_high, size: 19),
              title: Text(adjustment),
            ),
        ],
      ],
    );
  }
}

class _SliderControl extends StatelessWidget {
  const _SliderControl({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChanged,
    this.divisions,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int? divisions;
  final String suffix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            '$label  $value$suffix',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: divisions ?? max - min,
            value: value.toDouble(),
            onChanged: (next) => onChanged(next.round()),
          ),
        ],
      ),
    ),
  );
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.index,
    required this.template,
    required this.estimatedMinutes,
  });

  final int index;
  final WorkoutTemplate template;
  final int estimatedMinutes;

  @override
  Widget build(BuildContext context) => Card(
    child: ExpansionTile(
      initiallyExpanded: index == 0,
      leading: CircleAvatar(child: Text('${index + 1}')),
      title: Text(template.name),
      subtitle: Text(
        '$estimatedMinutes′ estimated • '
        '${template.exercises.length} movements',
      ),
      children: [
        for (
          var exerciseIndex = 0;
          exerciseIndex < template.exercises.length;
          exerciseIndex++
        )
          ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 14,
              child: Text('${exerciseIndex + 1}'),
            ),
            title: Text(template.exercises[exerciseIndex]),
            subtitle: Text(
              template
                  .prescriptionFor(template.exercises[exerciseIndex])
                  .summary,
            ),
          ),
      ],
    ),
  );
}

class _MetricSection extends StatelessWidget {
  const _MetricSection({
    required this.title,
    required this.values,
    required this.suffix,
  });

  final String title;
  final Map<String, int> values;
  final String suffix;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in values.entries)
              Chip(label: Text('${entry.key}: ${entry.value} $suffix')),
          ],
        ),
      ],
    ),
  );
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.icon,
    required this.title,
    required this.detail,
    this.warning = false,
  });

  final IconData icon;
  final String title;
  final String detail;
  final bool warning;

  @override
  Widget build(BuildContext context) => Card(
    color: warning ? Theme.of(context).colorScheme.errorContainer : null,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, size: 42),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(detail),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
