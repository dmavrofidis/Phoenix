class EquipmentPreset {
  const EquipmentPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.keywords,
  });

  final String id;
  final String name;
  final String description;
  final List<String> keywords;
}

class EquipmentPresetCatalog {
  const EquipmentPresetCatalog._();

  static const presets = [
    EquipmentPreset(
      id: 'all',
      name: 'Όλος ο εξοπλισμός',
      description: 'Χωρίς περιορισμό στη βιβλιοθήκη ασκήσεων.',
      keywords: [],
    ),
    EquipmentPreset(
      id: 'home-basic',
      name: 'Home Basic',
      description: 'Σωματικό βάρος, αλτήρες, λάστιχα και πάγκος.',
      keywords: [
        'κάμψ',
        'push-up',
        'squat',
        'split',
        'hollow',
        'plank',
        'αλτήρ',
        'λάστιχ',
        'κωπηλατική',
        'farmer',
        'step-up',
        'pike',
      ],
    ),
    EquipmentPreset(
      id: 'treadmill-basic',
      name: 'Απλός διάδρομος',
      description: 'Περπάτημα ή ήπιο τρέξιμο σε οικιακό διάδρομο.',
      keywords: ['διάδρομ', 'treadmill', 'περπάτημα', 'walk'],
    ),
    EquipmentPreset(
      id: 'gym-full',
      name: 'Full Gym',
      description: 'Μπάρες, μηχανήματα, τροχαλίες, αλτήρες και conditioning.',
      keywords: [],
    ),
    EquipmentPreset(
      id: 'calisthenics',
      name: 'Calisthenics Park',
      description: 'Μονόζυγο, δίζυγο, κρίκοι και σωματικό βάρος.',
      keywords: [
        'έλξ',
        'pull-up',
        'chin-up',
        'κάμψ',
        'push-up',
        'dip',
        'pike',
        'hollow',
        'plank',
        'l-sit',
        'muscle-up',
        'handstand',
        'split squat',
      ],
    ),
    EquipmentPreset(
      id: 'recovery',
      name: 'Recovery Kit',
      description: 'Στρώμα, λάστιχο και ήπιες κινήσεις κινητικότητας.',
      keywords: [
        'breathing',
        'mobility',
        'stretch',
        '90/90',
        'cat',
        'wall',
        'dead bug',
        'bird dog',
      ],
    ),
  ];

  static EquipmentPreset byId(String id) =>
      presets.firstWhere((preset) => preset.id == id, orElse: () => presets[0]);

  static List<String> filterExercises(
    Iterable<String> exercises,
    String presetId,
  ) {
    final preset = byId(presetId);
    if (preset.keywords.isEmpty) return exercises.toList();
    return exercises.where((exercise) {
      final normalized = exercise.toLowerCase();
      return preset.keywords.any(normalized.contains);
    }).toList();
  }
}
