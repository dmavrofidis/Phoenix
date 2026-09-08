import 'package:flutter/material.dart';

import 'equipment_availability.dart';
import 'models/fitness_models.dart';
import 'phoenix_l10n.dart';
import 'state/fitness_store.dart';

class SimpleEquipmentPage extends StatefulWidget {
  const SimpleEquipmentPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<SimpleEquipmentPage> createState() => _SimpleEquipmentPageState();
}

class _SimpleEquipmentPageState extends State<SimpleEquipmentPage> {
  late String _place;
  late Set<String> _selected;
  bool _saving = false;

  static const _options = <_EquipmentOption>[
    _EquipmentOption(
      id: 'chair',
      greek: 'Σταθερή καρέκλα',
      english: 'Stable chair',
      icon: Icons.chair_alt_outlined,
    ),
    _EquipmentOption(
      id: 'dumbbells',
      greek: 'Αλτήρες ή βαράκια',
      english: 'Dumbbells',
      icon: Icons.fitness_center_rounded,
    ),
    _EquipmentOption(
      id: 'treadmill',
      greek: 'Απλός διάδρομος',
      english: 'Basic treadmill',
      icon: Icons.directions_walk_rounded,
    ),
    _EquipmentOption(
      id: 'pullup',
      greek: 'Μονόζυγο',
      english: 'Pull-up bar',
      icon: Icons.horizontal_rule_rounded,
    ),
    _EquipmentOption(
      id: 'bands',
      greek: 'Λάστιχο αντίστασης',
      english: 'Resistance band',
      icon: Icons.gesture_rounded,
    ),
    _EquipmentOption(
      id: 'bench',
      greek: 'Πάγκος',
      english: 'Bench',
      icon: Icons.airline_seat_flat_outlined,
    ),
    _EquipmentOption(
      id: 'fullGym',
      greek: 'Πλήρες γυμναστήριο',
      english: 'Full gym',
      icon: Icons.apartment_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final profile = widget.store.profile;
    final equipment = profile?.equipment.toLowerCase() ?? '';
    _place = EquipmentAvailability.isHome(profile) ? 'home' : 'gym';
    _selected = {
      if (equipment.contains('καρέκ') || equipment.contains('chair')) 'chair',
      if (EquipmentAvailability.hasDumbbells(profile)) 'dumbbells',
      if (EquipmentAvailability.hasTreadmill(profile)) 'treadmill',
      if (EquipmentAvailability.hasPullUpBar(profile)) 'pullup',
      if (EquipmentAvailability.hasBands(profile)) 'bands',
      if (equipment.contains('πάγκο') || equipment.contains('bench')) 'bench',
      if (equipment.contains('πλήρες γυμναστήριο') ||
          equipment.contains('full gym'))
        'fullGym',
    };
  }

  Future<void> _save() async {
    final profile = widget.store.profile;
    if (profile == null || _saving) return;
    setState(() => _saving = true);
    try {
      final equipment = _selected.contains('fullGym')
          ? 'Πλήρες γυμναστήριο'
          : [
              'Σωματικό βάρος',
              if (_selected.contains('chair')) 'Σταθερή καρέκλα',
              if (_selected.contains('dumbbells')) 'Αλτήρες',
              if (_selected.contains('treadmill')) 'Απλός διάδρομος',
              if (_selected.contains('pullup')) 'Μονόζυγο',
              if (_selected.contains('bands')) 'Λάστιχο αντίστασης',
              if (_selected.contains('bench')) 'Πάγκος',
            ].join(', ');
      await widget.store.updateProfile(
        UserProfile(
          goal: profile.goal,
          trainingPlace: _place == 'home' ? 'Σπίτι' : 'Γυμναστήριο',
          equipment: equipment,
          daysPerWeek: profile.daysPerWeek,
          heightCentimeters: profile.heightCentimeters,
          weightKilograms: profile.weightKilograms,
          age: profile.age,
          experienceLevel: profile.experienceLevel,
          sessionMinutes: profile.sessionMinutes,
          limitations: profile.limitations,
        ),
        refreshCorePrograms: true,
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final profile = widget.store.profile;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.text('Τι έχω διαθέσιμο', 'Available equipment')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          Text(
            l.text(
              'Το Phoenix θα δείχνει μόνο ασκήσεις που μπορείς πραγματικά να κάνεις.',
              'Phoenix will only show exercises you can actually perform.',
            ),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            l.text(
              'Αν δεν επιλέξεις κάτι, θα χρησιμοποιούνται μόνο το σώμα σου, το πάτωμα και ένας ασφαλής τοίχος.',
              'If you select nothing, only bodyweight, the floor and a safe wall will be used.',
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'home',
                icon: const Icon(Icons.home_outlined),
                label: Text(l.text('Σπίτι', 'Home')),
              ),
              ButtonSegment(
                value: 'gym',
                icon: const Icon(Icons.apartment_outlined),
                label: Text(l.text('Γυμναστήριο', 'Gym')),
              ),
            ],
            selected: {_place},
            onSelectionChanged: (value) => setState(() => _place = value.first),
          ),
          const SizedBox(height: 16),
          for (final option in _options)
            Card(
              child: CheckboxListTile(
                key: ValueKey('equipment-${option.id}'),
                value: _selected.contains(option.id),
                secondary: Icon(option.icon),
                title: Text(
                  l.text(option.greek, option.english),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                onChanged: (value) => setState(() {
                  if (option.id == 'fullGym' && value == true) {
                    _selected = {'fullGym'};
                  } else {
                    _selected.remove('fullGym');
                    if (value == true) {
                      _selected.add(option.id);
                    } else {
                      _selected.remove(option.id);
                    }
                  }
                }),
              ),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const ValueKey('save-simple-equipment'),
            onPressed: profile == null || _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(
              profile == null
                  ? l.text('Χρειάζεται πρώτα προφίλ', 'Create a profile first')
                  : l.text('Αποθήκευση επιλογών', 'Save choices'),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l.text(
              'Τα βασικά προγράμματα θα ανανεωθούν. Τα προσωπικά σου προγράμματα και το ιστορικό δεν διαγράφονται.',
              'Core programs will refresh. Your custom programs and history are not deleted.',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentOption {
  const _EquipmentOption({
    required this.id,
    required this.greek,
    required this.english,
    required this.icon,
  });

  final String id;
  final String greek;
  final String english;
  final IconData icon;
}
