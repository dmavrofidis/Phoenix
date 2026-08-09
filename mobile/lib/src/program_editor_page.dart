import 'package:flutter/material.dart';

import 'equipment_presets.dart';
import 'exercise_guide.dart';
import 'models/fitness_models.dart';
import 'state/fitness_store.dart';

class ProgramEditorPage extends StatefulWidget {
  const ProgramEditorPage({
    super.key,
    required this.store,
    required this.template,
  });

  final FitnessStore store;
  final WorkoutTemplate template;

  @override
  State<ProgramEditorPage> createState() => _ProgramEditorPageState();
}

class _ProgramEditorPageState extends State<ProgramEditorPage> {
  late final TextEditingController _name;
  late final TextEditingController _tags;
  late final List<String> _exercises;
  late final Map<String, ExercisePrescription> _prescriptions;
  late final List<WorkoutBlock> _blocks;
  late String _sessionType;
  late String _equipmentPreset;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.template.name);
    _tags = TextEditingController(text: widget.template.tags.join(', '));
    _exercises = List<String>.from(widget.template.exercises);
    _prescriptions = {
      for (final exercise in _exercises)
        exercise: widget.template.prescriptionFor(exercise),
    };
    _blocks = List<WorkoutBlock>.from(widget.template.blocks);
    _sessionType = widget.template.sessionType;
    _equipmentPreset = widget.template.equipmentPreset;
  }

  @override
  void dispose() {
    _name.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _addExercise() async {
    final available = EquipmentPresetCatalog.filterExercises(
      widget.store.exerciseLibrary,
      _equipmentPreset,
    ).where((exercise) => !_exercises.contains(exercise)).toList();
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ExercisePickerSheet(exercises: available),
    );
    if (selected == null) return;
    setState(() {
      _exercises.add(selected);
      _prescriptions[selected] = widget.store.prescriptionForNewExercise(
        exercise: selected,
        templateId: widget.template.id,
      );
    });
  }

  Future<void> _editPrescription(String exercise) async {
    final edited = await showModalBottomSheet<ExercisePrescription>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _PrescriptionEditorSheet(
        exercise: exercise,
        prescription: _prescriptions[exercise]!,
      ),
    );
    if (edited == null) return;
    setState(() => _prescriptions[exercise] = edited);
  }

  void _removeExercise(String exercise) {
    if (_exercises.length == 1) {
      _message('Το πρόγραμμα χρειάζεται τουλάχιστον μία άσκηση.');
      return;
    }
    setState(() {
      _exercises.remove(exercise);
      _prescriptions.remove(exercise);
      _blocks
        ..removeWhere((block) => block.exercises.contains(exercise))
        ..removeWhere((block) => block.exercises.length < 2);
    });
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      final exercise = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, exercise);
    });
  }

  Future<void> _buildBlock(String type) async {
    final occupied = {for (final block in _blocks) ...block.exercises};
    final selected = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _BlockBuilderSheet(
        type: type,
        exercises: _exercises,
        initiallyUnavailable: occupied,
      ),
    );
    if (selected == null || selected.length < 2) return;
    setState(() {
      _blocks.add(
        WorkoutBlock(
          id: '$type-${DateTime.now().microsecondsSinceEpoch}',
          type: type,
          exercises: selected,
        ),
      );
    });
  }

  void _removeBlock(WorkoutBlock block) {
    setState(() => _blocks.remove(block));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.store.updateWorkoutTemplate(
        widget.template.copyWith(
          name: _name.text,
          exercises: List<String>.from(_exercises),
          exercisePrescriptions: {
            for (final exercise in _exercises)
              exercise: _prescriptions[exercise]!,
          },
          tags: _tags.text
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toSet()
              .take(6)
              .toList(),
          sessionType: _sessionType,
          equipmentPreset: _equipmentPreset,
          blocks: List<WorkoutBlock>.from(_blocks),
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } on FormatException catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _message(error.message);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PROGRAM BUILDER'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text(
              'ΑΠΟΘΗΚΕΥΣΗ',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Όνομα προγράμματος',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_exercises.length} ασκήσεις • σύρε για αλλαγή σειράς',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _exercises.length >= 12 ? null : _addExercise,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Άσκηση'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  title: const Text(
                    'ΡΥΘΜΙΣΕΙΣ ΠΡΟΓΡΑΜΜΑΤΟΣ',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: .8,
                    ),
                  ),
                  subtitle: Text(
                    '${_sessionType == 'recovery' ? 'Rest day' : 'Workout'}'
                    ' • ${EquipmentPresetCatalog.byId(_equipmentPreset).name}'
                    '${_blocks.isEmpty ? '' : ' • ${_blocks.length} blocks'}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  children: [
                    TextField(
                      controller: _tags,
                      decoration: const InputDecoration(
                        labelText: 'Tags (χωρισμένα με κόμμα)',
                        prefixIcon: Icon(Icons.sell_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _sessionType,
                            decoration: const InputDecoration(
                              labelText: 'Τύπος',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'workout',
                                child: Text('Προπόνηση'),
                              ),
                              DropdownMenuItem(
                                value: 'recovery',
                                child: Text('Rest day'),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => _sessionType = value!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _equipmentPreset,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Equipment preset',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              for (final preset
                                  in EquipmentPresetCatalog.presets)
                                DropdownMenuItem(
                                  value: preset.id,
                                  child: Text(
                                    preset.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: (value) =>
                                setState(() => _equipmentPreset = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _buildBlock('superset'),
                            icon: const Icon(Icons.link),
                            label: const Text('Superset'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _buildBlock('circuit'),
                            icon: const Icon(Icons.sync),
                            label: const Text('Circuit'),
                          ),
                        ),
                      ],
                    ),
                    if (_blocks.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          for (final block in _blocks)
                            InputChip(
                              avatar: Icon(
                                block.isSuperset ? Icons.link : Icons.sync,
                                size: 16,
                              ),
                              label: Text(
                                '${block.label} • ${block.exercises.length}',
                              ),
                              onDeleted: () => _removeBlock(block),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
              itemCount: _exercises.length,
              onReorderItem: _reorder,
              buildDefaultDragHandles: false,
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                final prescription = _prescriptions[exercise]!;
                final guide = ExerciseGuideCatalog.forExercise(exercise);
                return Card(
                  key: ValueKey(exercise),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(0, 8, 10, 8),
                            child: Icon(Icons.drag_indicator),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 25,
                                    height: 25,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0x22FF3D00),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Color(0xFFFF8A65),
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      exercise,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  if (guide != null)
                                    const Icon(
                                      Icons.photo_library_outlined,
                                      size: 16,
                                      color: Colors.white38,
                                    ),
                                ],
                              ),
                              if (_blocks.any(
                                (block) => block.exercises.contains(exercise),
                              )) ...[
                                const SizedBox(height: 6),
                                Builder(
                                  builder: (context) {
                                    final block = _blocks.firstWhere(
                                      (item) =>
                                          item.exercises.contains(exercise),
                                    );
                                    return Text(
                                      block.label,
                                      style: const TextStyle(
                                        color: Color(0xFF81C784),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: .8,
                                      ),
                                    );
                                  },
                                ),
                              ],
                              const SizedBox(height: 7),
                              Text(
                                prescription.summary,
                                style: const TextStyle(
                                  color: Color(0xFFFFAB91),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Tempo ${prescription.tempo}'
                                '${prescription.note.isEmpty ? '' : ' • ${prescription.note}'}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: .45),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          children: [
                            IconButton(
                              tooltip: 'Ρύθμιση άσκησης',
                              onPressed: () => _editPrescription(exercise),
                              icon: const Icon(Icons.tune),
                            ),
                            IconButton(
                              tooltip: 'Αφαίρεση άσκησης',
                              onPressed: () => _removeExercise(exercise),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.save_outlined),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Text(_saving ? 'Αποθήκευση…' : 'Αποθήκευση προγράμματος'),
          ),
        ),
      ),
    );
  }
}

class _BlockBuilderSheet extends StatefulWidget {
  const _BlockBuilderSheet({
    required this.type,
    required this.exercises,
    required this.initiallyUnavailable,
  });

  final String type;
  final List<String> exercises;
  final Set<String> initiallyUnavailable;

  @override
  State<_BlockBuilderSheet> createState() => _BlockBuilderSheetState();
}

class _BlockBuilderSheetState extends State<_BlockBuilderSheet> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final isSuperset = widget.type == 'superset';
    final maxItems = isSuperset ? 2 : 8;
    return FractionallySizedBox(
      heightFactor: .72,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSuperset ? 'Νέο superset' : 'Νέο circuit',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(
              isSuperset
                  ? 'Διάλεξε ακριβώς 2 ασκήσεις που θα εκτελούνται εναλλάξ.'
                  : 'Διάλεξε 2–8 ασκήσεις που θα εκτελούνται κυκλικά.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .55),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  for (final exercise in widget.exercises)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _selected.contains(exercise),
                      title: Text(exercise),
                      subtitle: widget.initiallyUnavailable.contains(exercise)
                          ? const Text('Χρησιμοποιείται ήδη σε άλλο block')
                          : null,
                      onChanged:
                          widget.initiallyUnavailable.contains(exercise) ||
                              (!_selected.contains(exercise) &&
                                  _selected.length >= maxItems)
                          ? null
                          : (selected) => setState(() {
                              if (selected == true) {
                                _selected.add(exercise);
                              } else {
                                _selected.remove(exercise);
                              }
                            }),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    _selected.length < 2 ||
                        (isSuperset && _selected.length != 2)
                    ? null
                    : () => Navigator.of(context).pop(
                        widget.exercises
                            .where(_selected.contains)
                            .toList(growable: false),
                      ),
                icon: const Icon(Icons.check),
                label: Text(
                  _selected.length < 2
                      ? 'Διάλεξε τουλάχιστον 2'
                      : 'Δημιουργία ${isSuperset ? 'superset' : 'circuit'}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExercisePickerSheet extends StatefulWidget {
  const _ExercisePickerSheet({required this.exercises});

  final List<String> exercises;

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final filtered = widget.exercises
        .where((exercise) => exercise.toLowerCase().contains(query))
        .toList();
    return FractionallySizedBox(
      heightFactor: .82,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Βιβλιοθήκη ασκήσεων',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Αναζήτηση άσκησης',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('Δεν βρέθηκε διαθέσιμη άσκηση.'))
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final exercise = filtered[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            child: Icon(Icons.fitness_center, size: 18),
                          ),
                          title: Text(exercise),
                          trailing: const Icon(Icons.add_circle_outline),
                          onTap: () => Navigator.of(context).pop(exercise),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrescriptionEditorSheet extends StatefulWidget {
  const _PrescriptionEditorSheet({
    required this.exercise,
    required this.prescription,
  });

  final String exercise;
  final ExercisePrescription prescription;

  @override
  State<_PrescriptionEditorSheet> createState() =>
      _PrescriptionEditorSheetState();
}

class _PrescriptionEditorSheetState extends State<_PrescriptionEditorSheet> {
  late final TextEditingController _sets;
  late final TextEditingController _minReps;
  late final TextEditingController _maxReps;
  late final TextEditingController _rir;
  late final TextEditingController _rest;
  late final TextEditingController _tempo;
  late final TextEditingController _minHold;
  late final TextEditingController _maxHold;
  late final TextEditingController _note;
  String? _error;

  @override
  void initState() {
    super.initState();
    final item = widget.prescription;
    _sets = TextEditingController(text: '${item.workingSets}');
    _minReps = TextEditingController(text: '${item.minReps}');
    _maxReps = TextEditingController(text: '${item.maxReps}');
    _rir = TextEditingController(text: '${item.targetRir}');
    _rest = TextEditingController(text: '${item.restSeconds}');
    _tempo = TextEditingController(text: item.tempo);
    _minHold = TextEditingController(text: '${item.minHoldSeconds}');
    _maxHold = TextEditingController(text: '${item.maxHoldSeconds}');
    _note = TextEditingController(text: item.note);
  }

  @override
  void dispose() {
    for (final controller in [
      _sets,
      _minReps,
      _maxReps,
      _rir,
      _rest,
      _tempo,
      _minHold,
      _maxHold,
      _note,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  int _number(TextEditingController controller) =>
      int.tryParse(controller.text) ?? -1;

  void _save() {
    final sets = _number(_sets);
    final minReps = _number(_minReps);
    final maxReps = _number(_maxReps);
    final rir = _number(_rir);
    final rest = _number(_rest);
    final minHold = _number(_minHold);
    final maxHold = _number(_maxHold);
    final timed = widget.prescription.isTimed;
    if (sets < 1 ||
        sets > 10 ||
        rir < 0 ||
        rir > 5 ||
        rest < 15 ||
        rest > 600 ||
        (!timed && (minReps < 1 || maxReps < minReps || maxReps > 100)) ||
        (timed && (minHold < 1 || maxHold < minHold || maxHold > 600))) {
      setState(() {
        _error = 'Έλεγξε σετ, εύρος, RIR και διάλειμμα.';
      });
      return;
    }
    Navigator.of(context).pop(
      ExercisePrescription(
        workingSets: sets,
        minReps: timed ? 0 : minReps,
        maxReps: timed ? 0 : maxReps,
        targetRir: rir,
        restSeconds: rest,
        tempo: _tempo.text.trim().isEmpty ? '2–1–2' : _tempo.text.trim(),
        minHoldSeconds: timed ? minHold : 0,
        maxHoldSeconds: timed ? maxHold : 0,
        note: _note.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timed = widget.prescription.isTimed;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ρύθμιση άσκησης',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              widget.exercise,
              style: const TextStyle(
                color: Color(0xFFFF9E80),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _NumberField(controller: _sets, label: 'Σετ'),
                const SizedBox(width: 8),
                if (timed) ...[
                  _NumberField(controller: _minHold, label: 'Min sec'),
                  const SizedBox(width: 8),
                  _NumberField(controller: _maxHold, label: 'Max sec'),
                ] else ...[
                  _NumberField(controller: _minReps, label: 'Min επαν.'),
                  const SizedBox(width: 8),
                  _NumberField(controller: _maxReps, label: 'Max επαν.'),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _NumberField(controller: _rir, label: 'RIR'),
                const SizedBox(width: 8),
                _NumberField(controller: _rest, label: 'Διάλειμμα s'),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _tempo,
                    decoration: const InputDecoration(
                      labelText: 'Tempo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _note,
              decoration: const InputDecoration(
                labelText: 'Σημείωση τεχνικής',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Color(0xFFEF9A9A))),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 13),
                  child: Text('Εφαρμογή ρύθμισης'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
