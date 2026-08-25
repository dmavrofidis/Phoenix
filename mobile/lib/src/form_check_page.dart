import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'equipment_availability.dart';
import 'exercise_guide.dart';
import 'phoenix_l10n.dart';
import 'state/fitness_store.dart';

class FormCheckPage extends StatefulWidget {
  const FormCheckPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<FormCheckPage> createState() => _FormCheckPageState();
}

class _FormCheckPageState extends State<FormCheckPage> {
  final _picker = ImagePicker();
  Uint8List? _photo;
  String? _exercise;
  bool _busy = false;

  Future<void> _capture() async {
    setState(() => _busy = true);
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 78,
        maxWidth: 1400,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() => _photo = bytes);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final exercises = widget.store.recommendedWorkout.exercises;
    final exercise = _exercise ?? exercises.first;
    final guide = ExerciseGuideCatalog.forExercise(
      exercise,
      atHome: EquipmentAvailability.isHome(widget.store.profile),
    );
    final enabled = widget.store.preferences.formCoachEnabled;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.text('Τοπικός έλεγχος στάσης', 'Local form check')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          Text(
            l.text(
              'Δες τη στάση σου χωρίς αποστολή βίντεο',
              'Review your form without uploading video',
            ),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            l.text(
              'Η φωτογραφία μένει μόνο στη μνήμη όσο αυτή η σελίδα είναι ανοιχτή. Δεν αποθηκεύεται στο ιστορικό και δεν ανεβαίνει πουθενά.',
              'The photo stays only in memory while this page is open. It is not saved to history or uploaded anywhere.',
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: SwitchListTile(
              value: enabled,
              onChanged: (value) => widget.store.updatePrivateHealthOptions(
                formCoachEnabled: value,
              ),
              secondary: const Icon(Icons.lock_outline_rounded),
              title: Text(
                l.text(
                  'Ενεργοποίηση μόνο για αυτή τη συσκευή',
                  'Enable only on this device',
                ),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                l.text(
                  'Το Phoenix δεν κάνει ιατρική αξιολόγηση και δεν αντικαθιστά προπονητή ή φυσικοθεραπευτή.',
                  'Phoenix does not provide a medical assessment or replace a coach or physiotherapist.',
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: exercise,
            decoration: InputDecoration(
              labelText: l.text('Άσκηση', 'Exercise'),
              prefixIcon: const Icon(Icons.fitness_center_outlined),
            ),
            items: [
              for (final item in exercises)
                DropdownMenuItem(value: item, child: Text(item)),
            ],
            onChanged: (value) => setState(() {
              _exercise = value;
              _photo = null;
            }),
          ),
          const SizedBox(height: 14),
          if (_photo == null)
            Container(
              height: 280,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt_outlined, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      l.text(
                        'Στήριξε το κινητό σε σταθερό σημείο και φρόντισε να φαίνεται όλο το σώμα.',
                        'Place the phone on a stable surface and keep your full body visible.',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(_photo!, fit: BoxFit.cover),
                    const IgnorePointer(
                      child: CustomPaint(painter: _FormGridPainter()),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: IconButton.filledTonal(
                        tooltip: l.text('Διαγραφή φωτογραφίας', 'Delete photo'),
                        onPressed: () => setState(() => _photo = null),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const ValueKey('local-form-capture'),
              onPressed: enabled && !_busy ? _capture : null,
              icon: _busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.camera_alt_outlined),
              label: Text(
                l.text(
                  _photo == null
                      ? 'Βγάλε φωτογραφία στάσης'
                      : 'Βγάλε νέα φωτογραφία',
                  _photo == null ? 'Capture form photo' : 'Capture a new photo',
                ),
              ),
            ),
          ),
          if (guide != null) ...[
            const SizedBox(height: 22),
            Text(
              l.text('Σύγκρινε αυτά τα σημεία', 'Compare these checkpoints'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Text('1')),
              title: Text(guide.execution),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Text('2')),
              title: Text(
                l.text('Απόφυγε αυτό', 'Avoid this'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(guide.avoid),
            ),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: const Icon(Icons.health_and_safety_outlined),
                title: Text(
                  l.text('Σταμάτα αν εμφανιστεί πόνος', 'Stop if pain appears'),
                ),
                subtitle: Text(
                  l.text(
                    'Η φωτογραφία βοηθά μόνο στη σύγκριση με τις οδηγίες. Αν υπάρχει ενόχληση ή αβεβαιότητα, ζήτησε κατάλληλη επαγγελματική καθοδήγηση.',
                    'The photo only helps you compare against the instructions. If there is discomfort or uncertainty, seek appropriate professional guidance.',
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FormGridPainter extends CustomPainter {
  const _FormGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .5)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    for (final fraction in const [.25, .5, .75]) {
      canvas.drawLine(
        Offset(0, size.height * fraction),
        Offset(size.width, size.height * fraction),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
