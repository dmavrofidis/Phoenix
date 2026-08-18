import 'package:flutter/material.dart';

import 'equipment_quick_choices.dart';
import 'models/fitness_models.dart';
import 'phoenix_l10n.dart';
import 'state/fitness_store.dart';

class ProfileEditorPage extends StatefulWidget {
  const ProfileEditorPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<ProfileEditorPage> createState() => _ProfileEditorPageState();
}

class _ProfileEditorPageState extends State<ProfileEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _equipment;
  late final TextEditingController _height;
  late final TextEditingController _weight;
  late final TextEditingController _age;
  late final TextEditingController _limitations;
  late String _goal;
  late String _place;
  late String _experience;
  late int _days;
  late int _minutes;
  bool _refreshPrograms = false;
  bool _saving = false;

  UserProfile get _profile =>
      widget.store.profile ??
      const UserProfile(
        goal: 'Γενική φυσική κατάσταση',
        trainingPlace: 'Γυμναστήριο',
        equipment: 'Πλήρες γυμναστήριο',
        daysPerWeek: 3,
        heightCentimeters: 175,
        weightKilograms: 75,
      );

  @override
  void initState() {
    super.initState();
    final profile = _profile;
    _goal = profile.goal;
    _place = profile.trainingPlace;
    _experience = profile.experienceLevel;
    _days = profile.daysPerWeek;
    _minutes = profile.sessionMinutes;
    _equipment = TextEditingController(text: profile.equipment);
    _height = TextEditingController(text: '${profile.heightCentimeters}');
    _weight = TextEditingController(
      text: profile.weightKilograms.toStringAsFixed(1),
    );
    _age = TextEditingController(text: profile.age?.toString() ?? '');
    _limitations = TextEditingController(text: profile.limitations);
  }

  @override
  void dispose() {
    _equipment.dispose();
    _height.dispose();
    _weight.dispose();
    _age.dispose();
    _limitations.dispose();
    super.dispose();
  }

  String? _number(String? value) =>
      double.tryParse((value ?? '').replaceAll(',', '.')) == null
      ? context.l10n.text(
          'Χρειάζεται έγκυρος αριθμός.',
          'Enter a valid number.',
        )
      : null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.store.updateProfile(
        UserProfile(
          goal: _goal,
          trainingPlace: _place,
          equipment: _equipment.text.trim(),
          daysPerWeek: _days,
          heightCentimeters: int.parse(_height.text),
          weightKilograms: double.parse(_weight.text.replaceAll(',', '.')),
          age: _age.text.trim().isEmpty ? null : int.parse(_age.text),
          experienceLevel: _experience,
          sessionMinutes: _minutes,
          limitations: _limitations.text.trim(),
        ),
        refreshCorePrograms: _refreshPrograms,
      );
      if (mounted) Navigator.of(context).pop();
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    String goalLabel(String value) => switch (value) {
      'Μυϊκή ανάπτυξη' => l.text(value, 'Muscle gain'),
      'Δύναμη' => l.text(value, 'Strength'),
      'Απώλεια λίπους' => l.text(value, 'Fat loss'),
      _ => l.text(value, 'General fitness'),
    };
    String experienceLabel(String value) => switch (value) {
      'Αρχάριος' => l.text(value, 'Beginner'),
      'Μέτριος' => l.text(value, 'Intermediate'),
      _ => l.text(value, 'Advanced'),
    };
    return Scaffold(
      appBar: AppBar(title: Text(l.text('ΕΠΕΞΕΡΓΑΣΙΑ ΠΡΟΦΙΛ', 'EDIT PROFILE'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          children: [
            Text(
              l.text('Το πλάνο στα μέτρα σου', 'Your plan, your parameters'),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              l.text(
                'Αλλάζεις τα στοιχεία σου χωρίς να χάνεται το ιστορικό.',
                'Update your details without losing your history.',
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 22),
            DropdownButtonFormField<String>(
              initialValue: _goal,
              decoration: InputDecoration(
                labelText: l.text('Κύριος στόχος', 'Primary goal'),
                border: const OutlineInputBorder(),
              ),
              items:
                  const [
                        'Μυϊκή ανάπτυξη',
                        'Δύναμη',
                        'Απώλεια λίπους',
                        'Γενική φυσική κατάσταση',
                      ]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(goalLabel(value)),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _goal = value!),
            ),
            const SizedBox(height: 14),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'Γυμναστήριο',
                  icon: const Icon(Icons.fitness_center),
                  label: Text(l.text('Γυμναστήριο', 'Gym')),
                ),
                ButtonSegment(
                  value: 'Σπίτι',
                  icon: const Icon(Icons.home_outlined),
                  label: Text(l.text('Σπίτι', 'Home')),
                ),
              ],
              selected: {_place},
              onSelectionChanged: (value) =>
                  setState(() => _place = value.first),
            ),
            const SizedBox(height: 14),
            EquipmentQuickChoices(controller: _equipment),
            const SizedBox(height: 10),
            TextFormField(
              key: const ValueKey('profile-equipment-input'),
              controller: _equipment,
              decoration: InputDecoration(
                labelText: l.text(
                  'Διαθέσιμος εξοπλισμός',
                  'Available equipment',
                ),
                border: const OutlineInputBorder(),
              ),
              validator: (value) => (value ?? '').trim().isEmpty
                  ? l.text('Πρόσθεσε εξοπλισμό.', 'Add your equipment.')
                  : null,
            ),
            const SizedBox(height: 18),
            Text(
              l.text('$_days ημέρες προπόνησης', '$_days training days'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Slider(
              value: _days.toDouble(),
              min: 1,
              max: 7,
              divisions: 6,
              label: '$_days',
              onChanged: (value) => setState(() => _days = value.round()),
            ),
            DropdownButtonFormField<String>(
              initialValue: _experience,
              decoration: InputDecoration(
                labelText: l.text('Επίπεδο εμπειρίας', 'Experience level'),
                border: const OutlineInputBorder(),
              ),
              items: const ['Αρχάριος', 'Μέτριος', 'Προχωρημένος']
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(experienceLabel(value)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _experience = value!),
            ),
            const SizedBox(height: 18),
            Text(
              l.text(
                '$_minutes λεπτά ανά συνεδρία',
                '$_minutes minutes per session',
              ),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Slider(
              value: _minutes.toDouble(),
              min: 20,
              max: 120,
              divisions: 10,
              label: '$_minutes',
              onChanged: (value) => setState(() => _minutes = value.round()),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _height,
                    keyboardType: TextInputType.number,
                    validator: _number,
                    decoration: InputDecoration(
                      labelText: l.text('Ύψος', 'Height'),
                      suffixText: 'cm',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _weight,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _number,
                    decoration: InputDecoration(
                      labelText: l.text('Βάρος', 'Weight'),
                      suffixText: 'kg',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _age,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l.text('Ηλικία (προαιρετικά)', 'Age (optional)'),
                border: const OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value ?? '').trim().isNotEmpty &&
                      int.tryParse(value!) == null
                  ? l.text('Μη έγκυρη ηλικία.', 'Invalid age.')
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _limitations,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l.text(
                  'Περιορισμοί ή ενοχλήσεις',
                  'Limitations or pain',
                ),
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              value: _refreshPrograms,
              onChanged: (value) => setState(() => _refreshPrograms = value),
              contentPadding: EdgeInsets.zero,
              title: Text(
                l.text(
                  'Ανανέωση βασικών προγραμμάτων',
                  'Refresh core programs',
                ),
              ),
              subtitle: Text(
                l.text(
                  'Οι αλλαγές σε χώρο, εξοπλισμό ή στόχο εφαρμόζονται αυτόματα. Τα δικά σου προγράμματα παραμένουν.',
                  'Changes to place, equipment, or goal apply automatically. Your own programs stay untouched.',
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(l.text('Αποθήκευση προφίλ', 'Save profile')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
