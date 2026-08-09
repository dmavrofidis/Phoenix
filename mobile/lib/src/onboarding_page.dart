import 'package:flutter/material.dart';

import 'models/fitness_models.dart';
import 'phoenix_l10n.dart';
import 'state/fitness_store.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _equipmentController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _limitationsController = TextEditingController();

  String _goal = 'Μυϊκή ανάπτυξη';
  String _trainingPlace = 'Γυμναστήριο';
  String _experienceLevel = 'Αρχάριος';
  int _daysPerWeek = 3;
  int _sessionMinutes = 45;
  bool _saving = false;

  @override
  void dispose() {
    _equipmentController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _limitationsController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.store.saveProfile(
        UserProfile(
          goal: _goal,
          trainingPlace: _trainingPlace,
          equipment: _equipmentController.text.trim(),
          daysPerWeek: _daysPerWeek,
          heightCentimeters: int.parse(_heightController.text),
          weightKilograms: double.parse(
            _weightController.text.replaceAll(',', '.'),
          ),
          age: _ageController.text.trim().isEmpty
              ? null
              : int.parse(_ageController.text),
          experienceLevel: _experienceLevel,
          sessionMinutes: _sessionMinutes,
          limitations: _limitationsController.text.trim(),
        ),
      );
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _requiredNumber(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Συμπλήρωσε $label.';
    if (double.tryParse(value.replaceAll(',', '.')) == null) {
      return 'Γράψε έναν έγκυρο αριθμό.';
    }
    return null;
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
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            key: const ValueKey('onboarding-scroll'),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'PHOENIX',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => widget.store.updatePreferences(
                      languageCode: widget.store.isEnglish ? 'el' : 'en',
                    ),
                    icon: const Icon(Icons.language),
                    label: Text(widget.store.isEnglish ? 'ΕΛ' : 'EN'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                l.text('Ας ξεκινήσουμε\nσωστά.', 'Let’s start\nright.'),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l.text(
                  'Με βάση τα στοιχεία σου θα προταθεί ένα αρχικό πρόγραμμα και '
                      'θα ενεργοποιηθεί η καταγραφή προπονήσεων.',
                  'Your details will generate a safe starter program and enable '
                      'workout tracking.',
                ),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .68),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              _SectionLabel(
                icon: Icons.flag_outlined,
                label: l.text('Κύριος στόχος', 'Primary goal'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _goal,
                decoration: const InputDecoration(border: OutlineInputBorder()),
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
              const SizedBox(height: 20),
              _SectionLabel(
                icon: Icons.fitness_center,
                label: l.text('Χώρος προπόνησης', 'Training location'),
              ),
              const SizedBox(height: 10),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'Γυμναστήριο',
                    label: Text(l.text('Γυμναστήριο', 'Gym')),
                    icon: const Icon(Icons.fitness_center),
                  ),
                  ButtonSegment(
                    value: 'Σπίτι',
                    label: Text(l.text('Σπίτι', 'Home')),
                    icon: const Icon(Icons.home_outlined),
                  ),
                ],
                selected: {_trainingPlace},
                onSelectionChanged: (value) =>
                    setState(() => _trainingPlace = value.first),
              ),
              const SizedBox(height: 20),
              _SectionLabel(
                icon: Icons.sports_gymnastics,
                label: l.text('Διαθέσιμος εξοπλισμός', 'Available equipment'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _equipmentController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l.text(
                    'π.χ. αλτήρες, λάστιχα, πλήρες γυμναστήριο',
                    'e.g. dumbbells, bands, full gym',
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l.text(
                        'Πρόσθεσε τον διαθέσιμο εξοπλισμό.',
                        'Add your available equipment.',
                      )
                    : null,
              ),
              const SizedBox(height: 20),
              _SectionLabel(
                icon: Icons.calendar_month_outlined,
                label: l.text(
                  '$_daysPerWeek ημέρες την εβδομάδα',
                  '$_daysPerWeek days per week',
                ),
              ),
              Slider(
                value: _daysPerWeek.toDouble(),
                min: 1,
                max: 7,
                divisions: 6,
                label: '$_daysPerWeek',
                onChanged: (value) =>
                    setState(() => _daysPerWeek = value.round()),
              ),
              const SizedBox(height: 16),
              _SectionLabel(
                icon: Icons.trending_up,
                label: l.text('Επίπεδο εμπειρίας', 'Experience level'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _experienceLevel,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const ['Αρχάριος', 'Μέτριος', 'Προχωρημένος']
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(experienceLabel(value)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _experienceLevel = value!),
              ),
              const SizedBox(height: 20),
              _SectionLabel(
                icon: Icons.timer_outlined,
                label: l.text(
                  '$_sessionMinutes λεπτά ανά προπόνηση',
                  '$_sessionMinutes minutes per workout',
                ),
              ),
              Slider(
                value: _sessionMinutes.toDouble(),
                min: 30,
                max: 90,
                divisions: 4,
                label: l.text(
                  '$_sessionMinutes λεπτά',
                  '$_sessionMinutes minutes',
                ),
                onChanged: (value) =>
                    setState(() => _sessionMinutes = value.round()),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l.text('Ύψος', 'Height'),
                        suffixText: 'cm',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => _requiredNumber(value, 'το ύψος'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l.text('Βάρος', 'Weight'),
                        suffixText: 'kg',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => _requiredNumber(value, 'το βάρος'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l.text('Ηλικία (προαιρετικά)', 'Age (optional)'),
                  suffixText: l.text('έτη', 'years'),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  return int.tryParse(value) == null
                      ? l.text('Γράψε μια έγκυρη ηλικία.', 'Enter a valid age.')
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _limitationsController,
                minLines: 2,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l.text(
                    'Περιορισμοί ή ενοχλήσεις (προαιρετικά)',
                    'Limitations or pain (optional)',
                  ),
                  hintText: l.text(
                    'π.χ. αποφυγή αλμάτων ή ενόχληση στο γόνατο',
                    'e.g. avoid jumping or knee discomfort',
                  ),
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: .45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lock_outline, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l.text(
                          'Όλα τα δεδομένα αποθηκεύονται μόνο στη συσκευή σου.',
                          'All data stays only on your device.',
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving ? null : _continue,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    l.text(
                      'Δημιουργία αρχικού προγράμματος',
                      'Create starter program',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l.text(
                  'Το πρόγραμμα είναι μια αρχική deterministic πρόταση και '
                      'μπορείς να το προσαρμόσεις όποτε θέλεις. Οι περιορισμοί '
                      'καταγράφονται για να τους βλέπεις, δεν αποτελούν ιατρική '
                      'αξιολόγηση.',
                  'The program is a deterministic starting point that you can '
                      'edit at any time. Limitations are stored for visibility and '
                      'are not a medical assessment.',
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: .5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
