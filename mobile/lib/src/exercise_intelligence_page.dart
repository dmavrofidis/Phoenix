import 'package:flutter/material.dart';

import 'exercise_guide.dart';
import 'exercise_intelligence_engine.dart';
import 'models/fitness_models.dart';
import 'state/fitness_store.dart';

class ExerciseIntelligencePage extends StatefulWidget {
  const ExerciseIntelligencePage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<ExerciseIntelligencePage> createState() =>
      _ExerciseIntelligencePageState();
}

class _ExerciseIntelligencePageState extends State<ExerciseIntelligencePage> {
  final _query = TextEditingController();
  String _pattern = '';
  String _muscle = '';
  String _equipment = '';
  int _maxDifficulty = 5;
  bool _availableOnly = false;
  bool _safeForLimitations = false;
  String _pathExercise = '';

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  FitnessStore get store => widget.store;

  List<String> get _limitationAreas {
    final limitations = store.profile?.limitations.toLowerCase() ?? '';
    final areas = <String>[];
    const aliases = <String, List<String>>{
      'knee': ['knee', 'γόνα'],
      'shoulder': ['shoulder', 'ώμ'],
      'back': ['back', 'μέση', 'πλάτ'],
      'wrist': ['wrist', 'καρπ'],
      'hip': ['hip', 'ισχ'],
      'ankle': ['ankle', 'αστράγ'],
    };
    for (final entry in aliases.entries) {
      if (entry.value.any(limitations.contains)) areas.add(entry.key);
    }
    return areas;
  }

  List<ExerciseIntelligenceProfile> get _all =>
      ExerciseIntelligenceEngine.allProfiles(store.data);

  List<ExerciseIntelligenceProfile> get _results =>
      ExerciseIntelligenceEngine.explore(
        data: store.data,
        filter: ExerciseExplorerFilter(
          query: _query.text,
          movementPattern: _pattern,
          muscle: _muscle,
          equipment: _equipment,
          maxDifficulty: _maxDifficulty,
          availableOnly: _availableOnly,
          avoidAreas: _safeForLimitations ? _limitationAreas : const [],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final all = _all;
    if (_pathExercise.isEmpty && all.isNotEmpty) {
      _pathExercise = all.first.name;
    }
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('EXERCISE INTELLIGENCE'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'EXPLORE', icon: Icon(Icons.manage_search)),
              Tab(text: 'PATHS', icon: Icon(Icons.account_tree_outlined)),
              Tab(text: 'BUILDER', icon: Icon(Icons.add_circle_outline)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ExplorerTab(
              results: _results,
              query: _query,
              pattern: _pattern,
              muscle: _muscle,
              equipment: _equipment,
              maxDifficulty: _maxDifficulty,
              availableOnly: _availableOnly,
              safeForLimitations: _safeForLimitations,
              hasLimitations: _limitationAreas.isNotEmpty,
              patterns: _values(all, (item) => [item.movementPattern]),
              muscles: _values(
                all,
                (item) => [...item.primaryMuscles, ...item.secondaryMuscles],
              ),
              equipmentOptions: _values(all, (item) => item.equipment),
              onChanged:
                  ({
                    String? pattern,
                    String? muscle,
                    String? equipment,
                    int? maxDifficulty,
                    bool? availableOnly,
                    bool? safeForLimitations,
                  }) {
                    setState(() {
                      if (pattern != null) _pattern = pattern;
                      if (muscle != null) _muscle = muscle;
                      if (equipment != null) _equipment = equipment;
                      if (maxDifficulty != null) {
                        _maxDifficulty = maxDifficulty;
                      }
                      if (availableOnly != null) {
                        _availableOnly = availableOnly;
                      }
                      if (safeForLimitations != null) {
                        _safeForLimitations = safeForLimitations;
                      }
                    });
                  },
              onOpen: _showProfile,
              onQueryChanged: () => setState(() {}),
            ),
            _PathsTab(
              store: store,
              all: all,
              selectedExercise: _pathExercise,
              onSelected: (value) => setState(() => _pathExercise = value),
              onOpen: _showProfile,
            ),
            _BuilderTab(
              store: store,
              onAdd: _openBuilder,
              onDelete: (id) async {
                await store.removeCustomExercise(id);
                if (mounted) setState(() {});
              },
              onOpen: _showProfile,
            ),
          ],
        ),
      ),
    );
  }

  List<String> _values(
    List<ExerciseIntelligenceProfile> profiles,
    List<String> Function(ExerciseIntelligenceProfile item) pick,
  ) {
    final values = <String>{};
    for (final profile in profiles) {
      values.addAll(pick(profile));
    }
    final sorted = values.where((item) => item.trim().isNotEmpty).toList()
      ..sort();
    return sorted;
  }

  Future<void> _showProfile(ExerciseIntelligenceProfile profile) async {
    final guide = ExerciseGuideCatalog.forExercise(
      profile.name,
      atHome: store.profile?.trainingPlace == 'Σπίτι',
    );
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text(
              profile.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Tag(profile.category),
                _Tag(profile.movementPattern.toUpperCase()),
                _Tag(profile.difficultyLabel),
                _Tag('SKILL ${profile.skillDemand}/5'),
                if (profile.isCustom) const _Tag('PERSONAL'),
              ],
            ),
            const SizedBox(height: 18),
            _DetailBlock(
              title: 'PRIMARY MUSCLES',
              value: profile.primaryMuscles.join(' • '),
            ),
            _DetailBlock(
              title: 'SECONDARY MUSCLES',
              value: profile.secondaryMuscles.isEmpty
                  ? '—'
                  : profile.secondaryMuscles.join(' • '),
            ),
            _DetailBlock(
              title: 'EQUIPMENT MATRIX',
              value: profile.equipment.join(' • '),
            ),
            _DetailBlock(
              title: 'CAUTION FLAGS',
              value: profile.cautionAreas.isEmpty
                  ? 'No catalogued caution flag'
                  : profile.cautionAreas.join(' • '),
              warning: profile.cautionAreas.isNotEmpty,
            ),
            _DetailBlock(
              title: 'REGRESSION → PROGRESSION',
              value:
                  '${profile.regression.isEmpty ? '—' : profile.regression}  →  '
                  '${profile.progression.isEmpty ? '—' : profile.progression}',
            ),
            if (profile.notes.isNotEmpty)
              _DetailBlock(title: 'PERSONAL NOTES', value: profile.notes),
            if (guide != null)
              FilledButton.icon(
                onPressed: () =>
                    showExerciseGuide(context, profile.name, guide),
                icon: const Icon(Icons.image_outlined),
                label: const Text('OPEN VISUAL GUIDE'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openBuilder() async {
    final name = TextEditingController();
    final primary = TextEditingController();
    final secondary = TextEditingController();
    final equipment = TextEditingController(text: 'bodyweight');
    final cautions = TextEditingController();
    final regression = TextEditingController();
    final progression = TextEditingController();
    final notes = TextEditingController();
    var pattern = 'horizontal push';
    var difficulty = 2;
    var skill = 2;
    final definition = await showDialog<CustomExerciseDefinition>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('CUSTOM EXERCISE BUILDER'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Field(controller: name, label: 'Exercise name'),
                  DropdownButtonFormField<String>(
                    initialValue: pattern,
                    decoration: const InputDecoration(
                      labelText: 'Movement pattern',
                    ),
                    items:
                        const [
                              'squat',
                              'hinge',
                              'horizontal push',
                              'vertical push',
                              'horizontal pull',
                              'vertical pull',
                              'single-leg squat',
                              'anti-extension',
                              'anti-rotation',
                              'loaded carry',
                              'straight-arm support',
                              'locomotion',
                              'cyclical conditioning',
                              'other',
                            ]
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) pattern = value;
                    },
                  ),
                  _Field(
                    controller: primary,
                    label: 'Primary muscles (comma separated)',
                  ),
                  _Field(
                    controller: secondary,
                    label: 'Secondary muscles (comma separated)',
                  ),
                  _Field(
                    controller: equipment,
                    label: 'Equipment (comma separated)',
                  ),
                  _Field(
                    controller: cautions,
                    label: 'Caution areas (comma separated)',
                  ),
                  _Field(controller: regression, label: 'Regression'),
                  _Field(controller: progression, label: 'Progression'),
                  _Field(
                    controller: notes,
                    label: 'Technique or setup notes',
                    maxLines: 2,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _RatingControl(
                          label: 'DIFFICULTY',
                          value: difficulty,
                          onChanged: (value) =>
                              setDialogState(() => difficulty = value),
                        ),
                      ),
                      Expanded(
                        child: _RatingControl(
                          label: 'SKILL DEMAND',
                          value: skill,
                          onChanged: (value) =>
                              setDialogState(() => skill = value),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                CustomExerciseDefinition(
                  id: '',
                  name: name.text,
                  primaryMuscles: _split(primary.text),
                  secondaryMuscles: _split(secondary.text),
                  movementPattern: pattern,
                  difficulty: difficulty,
                  skillDemand: skill,
                  equipment: _split(equipment.text),
                  cautionAreas: _split(cautions.text),
                  regression: regression.text,
                  progression: progression.text,
                  notes: notes.text,
                ),
              ),
              child: const Text('SAVE EXERCISE'),
            ),
          ],
        ),
      ),
    );
    for (final controller in [
      name,
      primary,
      secondary,
      equipment,
      cautions,
      regression,
      progression,
      notes,
    ]) {
      controller.dispose();
    }
    if (definition == null) return;
    try {
      await store.saveCustomExercise(definition);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Personal exercise saved locally.')),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }

  static List<String> _split(String input) => input
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

class _ExplorerTab extends StatelessWidget {
  const _ExplorerTab({
    required this.results,
    required this.query,
    required this.pattern,
    required this.muscle,
    required this.equipment,
    required this.maxDifficulty,
    required this.availableOnly,
    required this.safeForLimitations,
    required this.hasLimitations,
    required this.patterns,
    required this.muscles,
    required this.equipmentOptions,
    required this.onChanged,
    required this.onOpen,
    required this.onQueryChanged,
  });

  final List<ExerciseIntelligenceProfile> results;
  final TextEditingController query;
  final String pattern;
  final String muscle;
  final String equipment;
  final int maxDifficulty;
  final bool availableOnly;
  final bool safeForLimitations;
  final bool hasLimitations;
  final List<String> patterns;
  final List<String> muscles;
  final List<String> equipmentOptions;
  final void Function({
    String? pattern,
    String? muscle,
    String? equipment,
    int? maxDifficulty,
    bool? availableOnly,
    bool? safeForLimitations,
  })
  onChanged;
  final ValueChanged<ExerciseIntelligenceProfile> onOpen;
  final VoidCallback onQueryChanged;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      TextField(
        controller: query,
        onChanged: (_) => onQueryChanged(),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          labelText: 'Search exercise, muscle, pattern or equipment',
          suffixText: '${results.length} MATCHES',
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _FilterMenu(
            label: 'PATTERN',
            value: pattern,
            values: patterns,
            onChanged: (value) => onChanged(pattern: value),
          ),
          _FilterMenu(
            label: 'MUSCLE',
            value: muscle,
            values: muscles,
            onChanged: (value) => onChanged(muscle: value),
          ),
          _FilterMenu(
            label: 'EQUIPMENT',
            value: equipment,
            values: equipmentOptions,
            onChanged: (value) => onChanged(equipment: value),
          ),
          FilterChip(
            label: const Text('AVAILABLE EQUIPMENT'),
            selected: availableOnly,
            onSelected: (value) => onChanged(availableOnly: value),
          ),
          if (hasLimitations)
            FilterChip(
              label: const Text('SAFE FOR MY LIMITATIONS'),
              selected: safeForLimitations,
              onSelected: (value) => onChanged(safeForLimitations: value),
            ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Text('MAX DIFFICULTY $maxDifficulty/5'),
          Expanded(
            child: Slider(
              min: 1,
              max: 5,
              divisions: 4,
              value: maxDifficulty.toDouble(),
              onChanged: (value) => onChanged(maxDifficulty: value.round()),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      if (results.isEmpty)
        const _EmptyCard(
          title: 'NO SAFE MATCH',
          detail: 'Relax one filter or increase maximum difficulty.',
        )
      else
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1050
                ? 3
                : constraints.maxWidth >= 650
                ? 2
                : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: columns == 1 ? 2.4 : 1.55,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final profile = results[index];
                return _ExerciseCard(profile: profile, onTap: onOpen);
              },
            );
          },
        ),
    ],
  );
}

class _PathsTab extends StatelessWidget {
  const _PathsTab({
    required this.store,
    required this.all,
    required this.selectedExercise,
    required this.onSelected,
    required this.onOpen,
  });

  final FitnessStore store;
  final List<ExerciseIntelligenceProfile> all;
  final String selectedExercise;
  final ValueChanged<String> onSelected;
  final ValueChanged<ExerciseIntelligenceProfile> onOpen;

  @override
  Widget build(BuildContext context) {
    final selected = all.any((item) => item.name == selectedExercise)
        ? selectedExercise
        : all.firstOrNull?.name ?? '';
    final path = selected.isEmpty
        ? const <ExerciseIntelligenceProfile>[]
        : ExerciseIntelligenceEngine.progressionPath(selected, store.data);
    final avoid = (store.profile?.limitations ?? '').split(RegExp(r'[,;/]'));
    final substitutions = selected.isEmpty
        ? const <ExerciseSubstitutionScore>[]
        : ExerciseIntelligenceEngine.rankedSubstitutions(
            exercise: selected,
            data: store.data,
            avoidAreas: avoid,
          );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        DropdownButtonFormField<String>(
          initialValue: selected.isEmpty ? null : selected,
          decoration: const InputDecoration(
            labelText: 'Exercise progression',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final profile in all)
              DropdownMenuItem(value: profile.name, child: Text(profile.name)),
          ],
          onChanged: (value) {
            if (value != null) onSelected(value);
          },
        ),
        const SizedBox(height: 18),
        Text(
          'REGRESSION → PROGRESSION GRAPH',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        if (path.length <= 1)
          const _EmptyCard(
            title: 'NO COMPLETE PATH YET',
            detail: 'Add regression and progression links in the builder.',
          )
        else
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: path.length,
              separatorBuilder: (_, _) => const Icon(Icons.arrow_forward),
              itemBuilder: (context, index) {
                final item = path[index];
                final active = item.name == selected;
                return ActionChip(
                  avatar: CircleAvatar(child: Text('${item.difficulty}')),
                  label: SizedBox(
                    width: 150,
                    child: Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  backgroundColor: active
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  onPressed: () => onOpen(item),
                );
              },
            ),
          ),
        const SizedBox(height: 22),
        Text(
          'SCORED SUBSTITUTIONS',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        const Text(
          'Ranked by movement pattern, muscles, difficulty, equipment and caution flags.',
        ),
        const SizedBox(height: 10),
        for (final item in substitutions)
          Card(
            child: ListTile(
              onTap: () => onOpen(item.profile),
              leading: CircleAvatar(child: Text('${item.score}')),
              title: Text(item.profile.name),
              subtitle: Text(item.reasons.join(' • ')),
              trailing: Text(item.profile.difficultyLabel),
            ),
          ),
      ],
    );
  }
}

class _BuilderTab extends StatelessWidget {
  const _BuilderTab({
    required this.store,
    required this.onAdd,
    required this.onDelete,
    required this.onOpen,
  });

  final FitnessStore store;
  final VoidCallback onAdd;
  final ValueChanged<String> onDelete;
  final ValueChanged<ExerciseIntelligenceProfile> onOpen;

  @override
  Widget build(BuildContext context) {
    final coverage = ExerciseIntelligenceEngine.muscleCoverage(store.data);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Icon(Icons.add_chart, size: 40),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CUSTOM EXERCISE BUILDER',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Create a local exercise with muscles, equipment, safety flags and a progression path.',
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('NEW EXERCISE'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'MUSCLE MAP COVERAGE',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in coverage.entries.take(16))
              Chip(label: Text('${entry.key}  ${entry.value}')),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'PERSONAL EXERCISES (${store.customExercises.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (store.customExercises.isEmpty)
          const _EmptyCard(
            title: 'NO PERSONAL EXERCISES',
            detail:
                'The built-in taxonomy is ready. Add only movements you actually use.',
          )
        else
          for (final definition in store.customExercises)
            Card(
              child: ListTile(
                onTap: () => onOpen(
                  ExerciseIntelligenceEngine.profileFor(
                    definition.name,
                    custom: definition,
                  ),
                ),
                leading: CircleAvatar(child: Text('${definition.difficulty}')),
                title: Text(definition.name),
                subtitle: Text(
                  '${definition.movementPattern} • '
                  '${definition.primaryMuscles.join(', ')}',
                ),
                trailing: IconButton(
                  tooltip: 'Delete personal exercise',
                  onPressed: () => onDelete(definition.id),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.profile, required this.onTap});

  final ExerciseIntelligenceProfile profile;
  final ValueChanged<ExerciseIntelligenceProfile> onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => onTap(profile),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    profile.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (profile.isCustom)
                  const Icon(Icons.person_outline, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                _Tag(profile.movementPattern.toUpperCase()),
                _Tag(profile.difficultyLabel),
              ],
            ),
            const Spacer(),
            Text(
              profile.primaryMuscles.join(' • '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              profile.equipment.join(' • '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (profile.cautionAreas.isNotEmpty)
              Text(
                'CAUTION: ${profile.cautionAreas.join(', ')}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _FilterMenu extends StatelessWidget {
  const _FilterMenu({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => DropdownMenu<String>(
    initialSelection: value,
    label: Text(label),
    width: 220,
    dropdownMenuEntries: [
      const DropdownMenuEntry(value: '', label: 'ALL'),
      for (final item in values)
        DropdownMenuEntry(value: item, label: item.toUpperCase()),
    ],
    onSelected: (value) => onChanged(value ?? ''),
  );
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.45),
      ),
    ),
    child: Text(label, style: const TextStyle(fontSize: 10)),
  );
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({
    required this.title,
    required this.value,
    this.warning = false,
  });

  final String title;
  final String value;
  final bool warning;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: warning ? Theme.of(context).colorScheme.error : null,
          ),
        ),
        const SizedBox(height: 3),
        Text(value),
      ],
    ),
  );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.info_outline),
      title: Text(title),
      subtitle: Text(detail),
    ),
  );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

class _RatingControl extends StatelessWidget {
  const _RatingControl({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('$label $value/5'),
      Slider(
        min: 1,
        max: 5,
        divisions: 4,
        value: value.toDouble(),
        onChanged: (value) => onChanged(value.round()),
      ),
    ],
  );
}
