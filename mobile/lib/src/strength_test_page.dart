import 'package:flutter/material.dart';

import 'phoenix_l10n.dart';
import 'state/fitness_store.dart';

class StrengthTestPage extends StatefulWidget {
  const StrengthTestPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<StrengthTestPage> createState() => _StrengthTestPageState();
}

class _StrengthTestPageState extends State<StrengthTestPage> {
  final _weight = TextEditingController();
  final _reps = TextEditingController();
  final Set<int> _checks = {};
  late String _exercise;
  String _protocol = 'submax';
  bool _saving = false;

  static const _safetySteps = [
    'Έκανα προοδευτικό warm-up 3–5 σετ',
    'Υπάρχουν safety bars ή spotter όπου χρειάζεται',
    'Δεν υπάρχει πόνος, ζάλη ή αδιαθεσία',
    'Θα σταματήσω στην πρώτη καθαρή απώλεια τεχνικής',
  ];

  @override
  void initState() {
    super.initState();
    _exercise = widget.store.exerciseLibrary.first;
  }

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    super.dispose();
  }

  bool get _recoveryAllowsTest {
    final plan = widget.store.todaysRecoveryPlan;
    return plan == null || plan.score >= 55;
  }

  Future<void> _save() async {
    final l = context.l10n;
    if (_checks.length != _safetySteps.length) {
      _message(
        l.text(
          'Επιβεβαίωσε ολόκληρο το safety protocol.',
          'Confirm the complete safety protocol.',
        ),
      );
      return;
    }
    if (!_recoveryAllowsTest) {
      _message(
        l.text(
          'Το σημερινό readiness είναι πολύ χαμηλό για test.',
          'Today’s readiness is too low for testing.',
        ),
      );
      return;
    }
    final weight = double.tryParse(_weight.text.replaceAll(',', '.'));
    final reps = int.tryParse(_reps.text);
    if (weight == null || reps == null) {
      _message(
        l.text('Έλεγξε βάρος και επαναλήψεις.', 'Check weight and reps.'),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final result = await widget.store.saveStrengthTest(
        exerciseName: _exercise,
        weightKilograms: weight,
        reps: reps,
        protocol: _protocol,
      );
      if (mounted) {
        _message(
          l.text(
            'Ασφαλής εκτίμηση: ${result.estimatedOneRepMax.toStringAsFixed(1)} kg e1RM.',
            'Safe estimate: ${result.estimatedOneRepMax.toStringAsFixed(1)} kg e1RM.',
          ),
        );
        _weight.clear();
        _reps.clear();
        setState(_checks.clear);
      }
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('STRENGTH TEST LAB')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          children: [
            Text(
              l.text('Test χωρίς ριψοκίνδυνο 1RM', 'Test without a risky 1RM'),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              l.text(
                'Submax ή AMRAP με τεχνικό stop. Το Phoenix υπολογίζει e1RM χωρίς υποχρεωτική μονή μέγιστη επανάληψη.',
                'Use a submax or technical-stop AMRAP. Phoenix estimates 1RM without requiring a maximal single.',
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            if (!_recoveryAllowsTest)
              Card(
                color: const Color(0xFF2A1111),
                child: ListTile(
                  leading: const Icon(
                    Icons.health_and_safety_outlined,
                    color: Colors.redAccent,
                  ),
                  title: Text(l.text('TEST BLOCKED', 'TEST BLOCKED')),
                  subtitle: Text(
                    l.text(
                      'Readiness κάτω από 55. Μετέφερε το test σε καλύτερη ημέρα.',
                      'Readiness is below 55. Move the test to a better day.',
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'submax',
                  label: Text(l.text('Submax 3–8', 'Submax 3–8')),
                  icon: const Icon(Icons.shield_outlined),
                ),
                ButtonSegment(
                  value: 'amrap',
                  label: const Text('AMRAP 6–20'),
                  icon: const Icon(Icons.speed),
                ),
              ],
              selected: {_protocol},
              onSelectionChanged: (value) =>
                  setState(() => _protocol = value.first),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _exercise,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l.text('Άσκηση', 'Exercise'),
                border: const OutlineInputBorder(),
              ),
              items: widget.store.exerciseLibrary
                  .map(
                    (exercise) => DropdownMenuItem(
                      value: exercise,
                      child: Text(exercise, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _exercise = value!),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weight,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l.text('Βάρος', 'Weight'),
                      suffixText: 'kg',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _reps,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l.text('Καθαρές επαναλήψεις', 'Clean reps'),
                      helperText: _protocol == 'submax' ? '3–8' : '6–20',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'SAFETY PROTOCOL',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            for (var index = 0; index < _safetySteps.length; index++)
              CheckboxListTile(
                value: _checks.contains(index),
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l.isEnglish
                      ? const [
                          'I completed 3–5 progressive warm-up sets',
                          'Safety bars or a spotter are available where needed',
                          'There is no pain, dizziness or illness',
                          'I will stop at the first clear technique breakdown',
                        ][index]
                      : _safetySteps[index],
                ),
                onChanged: (value) => setState(() {
                  if (value == true) {
                    _checks.add(index);
                  } else {
                    _checks.remove(index);
                  }
                }),
              ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _saving || !_recoveryAllowsTest ? null : _save,
              icon: const Icon(Icons.calculate_outlined),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  l.text('Καταγραφή ασφαλούς test', 'Save safe test'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.text('ΙΣΤΟΡΙΚΟ TEST', 'TEST HISTORY'),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.store.data.strengthTests.isEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.science_outlined),
                  title: Text(l.text('Δεν υπάρχει test ακόμα', 'No test yet')),
                  subtitle: Text(
                    l.text(
                      'Ξεκίνα μόνο όταν είσαι ξεκούραστος και χωρίς πόνο.',
                      'Start only when recovered and pain-free.',
                    ),
                  ),
                ),
              )
            else
              for (final result in widget.store.data.strengthTests)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.military_tech_outlined),
                    title: Text(result.exerciseName),
                    subtitle: Text(
                      '${result.weightKilograms.toStringAsFixed(1)} kg × ${result.reps} • ${result.protocol.toUpperCase()}',
                    ),
                    trailing: Text(
                      '${result.estimatedOneRepMax.toStringAsFixed(1)}\ne1RM',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
