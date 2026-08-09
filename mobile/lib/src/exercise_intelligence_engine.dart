import 'models/fitness_models.dart';

class ExerciseIntelligenceProfile {
  const ExerciseIntelligenceProfile({
    required this.name,
    required this.category,
    required this.movementPattern,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.difficulty,
    required this.skillDemand,
    required this.equipment,
    required this.cautionAreas,
    required this.regression,
    required this.progression,
    required this.isCustom,
    this.notes = '',
  });

  final String name;
  final String category;
  final String movementPattern;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final int difficulty;
  final int skillDemand;
  final List<String> equipment;
  final List<String> cautionAreas;
  final String regression;
  final String progression;
  final bool isCustom;
  final String notes;

  String get difficultyLabel => switch (difficulty) {
    1 => 'FOUNDATION',
    2 => 'BEGINNER',
    3 => 'INTERMEDIATE',
    4 => 'ADVANCED',
    _ => 'EXPERT',
  };
}

class ExerciseExplorerFilter {
  const ExerciseExplorerFilter({
    this.query = '',
    this.movementPattern = '',
    this.muscle = '',
    this.equipment = '',
    this.maxDifficulty = 5,
    this.availableOnly = false,
    this.avoidAreas = const [],
  });

  final String query;
  final String movementPattern;
  final String muscle;
  final String equipment;
  final int maxDifficulty;
  final bool availableOnly;
  final List<String> avoidAreas;
}

class ExerciseSubstitutionScore {
  const ExerciseSubstitutionScore({
    required this.profile,
    required this.score,
    required this.reasons,
  });

  final ExerciseIntelligenceProfile profile;
  final int score;
  final List<String> reasons;
}

class ExerciseIntelligenceEngine {
  const ExerciseIntelligenceEngine._();

  static const catalogNames = <String>[
    'Goblet squat',
    'Back squat',
    'Front squat',
    'Goblet squat σε πάγκο',
    'Καθίσματα σε πάγκο με σακίδιο',
    'Bulgarian split squat',
    'Bulgarian split squat με στήριξη',
    'Ανάστροφες προβολές με στήριξη',
    'Step-ups σε σταθερό πάγκο',
    'Pistol squat to box',
    'Ρουμανικές άρσεις με αλτήρες',
    'Ρουμανικές άρσεις με σακίδιο',
    'Trap-bar deadlift',
    'Trap-bar deadlift από υπερύψωση',
    'Hip thrust με παύση',
    'Γέφυρες γλουτών',
    'Άρσεις γάμπας',
    'Πιέσεις στήθους με αλτήρες',
    'Πιέσεις πάγκου',
    'Κάμψεις',
    'Κάμψεις με παύση 1″',
    'Κάμψεις σε υπερυψωμένη επιφάνεια',
    'Κάμψεις κλειστής λαβής',
    'Pike push-ups',
    'Πιέσεις ώμων με αλτήρες',
    'Πιέσεις ώμων με λάστιχο',
    'Landmine press',
    'Βυθίσεις',
    'Αυστηρές έλξεις',
    'Υποβοηθούμενες έλξεις',
    'Weighted pull-up',
    'Έλξεις τροχαλίας ουδέτερη λαβή',
    'Κωπηλατική με στήριξη στήθους',
    'Μονόχειρη κωπηλατική με αλτήρα',
    'Κωπηλατική με λάστιχο — αργό tempo',
    'Face pulls',
    'Scapular pull-ups',
    'Dead bug',
    'Hollow body hold',
    'Arch body hold',
    'Pallof press με λάστιχο',
    'Hanging knee raises',
    'Hanging leg raises',
    'Farmer carry',
    'Suitcase carry',
    'Handstand wall hold',
    'Wall handstand',
    'L-sit tuck hold',
    'Ring support hold',
    'Bear crawl',
    'Mountain climbers',
    'Sled push',
    'Air bike intervals',
    'Κωπηλατικό εργόμετρο',
    'Zone 2 bike',
    'Brisk walk',
  ];

  static List<ExerciseIntelligenceProfile> allProfiles(FitnessData data) {
    final names = <String>{...catalogNames};
    for (final template in data.templates) {
      names.addAll(template.exercises);
    }
    for (final log in data.logs) {
      names.addAll(log.sets.map((item) => item.exerciseName));
    }
    final customByName = {
      for (final item in data.customExercises) _normal(item.name): item,
    };
    final profiles = [
      for (final name in names)
        profileFor(name, custom: customByName[_normal(name)]),
      for (final item in data.customExercises)
        if (!names.any((name) => _normal(name) == _normal(item.name)))
          profileFor(item.name, custom: item),
    ];
    profiles.sort((left, right) => left.name.compareTo(right.name));
    return profiles;
  }

  static ExerciseIntelligenceProfile profileFor(
    String exercise, {
    CustomExerciseDefinition? custom,
  }) {
    if (custom != null) {
      return ExerciseIntelligenceProfile(
        name: custom.name,
        category: _categoryForPattern(custom.movementPattern),
        movementPattern: custom.movementPattern,
        primaryMuscles: custom.primaryMuscles,
        secondaryMuscles: custom.secondaryMuscles,
        difficulty: custom.difficulty,
        skillDemand: custom.skillDemand,
        equipment: custom.equipment,
        cautionAreas: custom.cautionAreas,
        regression: custom.regression,
        progression: custom.progression,
        isCustom: true,
        notes: custom.notes,
      );
    }
    final normalized = _normal(exercise);
    final preferredToken = normalized.contains('γαμπ')
        ? 'γαμπ'
        : normalized.contains('scapular')
        ? 'scapular'
        : '';
    final seed = _seeds.firstWhere(
      (item) => preferredToken.isNotEmpty
          ? item.matches.contains(preferredToken)
          : item.matches.any(normalized.contains),
      orElse: () => _fallbackSeed,
    );
    return ExerciseIntelligenceProfile(
      name: exercise,
      category: seed.category,
      movementPattern: seed.pattern,
      primaryMuscles: seed.primary,
      secondaryMuscles: seed.secondary,
      difficulty: seed.difficulty,
      skillDemand: seed.skill,
      equipment: _equipmentFor(exercise, seed.equipment),
      cautionAreas: seed.cautions,
      regression: seed.regression,
      progression: seed.progression,
      isCustom: false,
    );
  }

  static List<ExerciseIntelligenceProfile> explore({
    required FitnessData data,
    required ExerciseExplorerFilter filter,
  }) {
    final query = _normal(filter.query);
    final pattern = _normal(filter.movementPattern);
    final muscle = _normal(filter.muscle);
    final equipment = _normal(filter.equipment);
    final avoid = filter.avoidAreas.map(_normal).toSet();
    return allProfiles(data).where((profile) {
      final searchable = _normal(
        [
          profile.name,
          profile.category,
          profile.movementPattern,
          ...profile.primaryMuscles,
          ...profile.secondaryMuscles,
          ...profile.equipment,
        ].join(' '),
      );
      if (query.isNotEmpty && !searchable.contains(query)) return false;
      if (pattern.isNotEmpty && _normal(profile.movementPattern) != pattern) {
        return false;
      }
      if (muscle.isNotEmpty &&
          ![
            ...profile.primaryMuscles,
            ...profile.secondaryMuscles,
          ].any((item) => _normal(item) == muscle)) {
        return false;
      }
      if (equipment.isNotEmpty &&
          !profile.equipment.any((item) => _normal(item) == equipment)) {
        return false;
      }
      if (profile.difficulty > filter.maxDifficulty) return false;
      if (filter.availableOnly &&
          !isEquipmentCompatible(profile, data.profile)) {
        return false;
      }
      if (avoid.isNotEmpty &&
          profile.cautionAreas.any((item) => avoid.contains(_normal(item)))) {
        return false;
      }
      return true;
    }).toList();
  }

  static bool isEquipmentCompatible(
    ExerciseIntelligenceProfile profile,
    UserProfile? user,
  ) {
    if (profile.equipment.every(
      (item) => const {'bodyweight', 'floor', 'wall'}.contains(_normal(item)),
    )) {
      return true;
    }
    if (user == null) return true;
    final available = _normal('${user.trainingPlace} ${user.equipment}');
    if (available.contains('γυμναστηρ') ||
        available.contains('gym') ||
        available.contains('πληρε')) {
      return true;
    }
    return profile.equipment.every((item) {
      final normalized = _normal(item);
      if (const {'bodyweight', 'floor', 'wall'}.contains(normalized)) {
        return true;
      }
      return _equipmentAliases[normalized]?.any(available.contains) ??
          available.contains(normalized);
    });
  }

  static List<ExerciseSubstitutionScore> rankedSubstitutions({
    required String exercise,
    required FitnessData data,
    Iterable<String> avoidAreas = const [],
    int limit = 8,
  }) {
    final custom = data.customExercises
        .where((item) => _normal(item.name) == _normal(exercise))
        .firstOrNull;
    final target = profileFor(exercise, custom: custom);
    final avoid = avoidAreas.map(_normal).toSet();
    final ranked = <ExerciseSubstitutionScore>[];
    for (final candidate in allProfiles(data)) {
      if (_normal(candidate.name) == _normal(target.name)) continue;
      if (candidate.cautionAreas.any((item) => avoid.contains(_normal(item)))) {
        continue;
      }
      var score = 0;
      final reasons = <String>[];
      if (candidate.movementPattern == target.movementPattern) {
        score += 42;
        reasons.add('same movement pattern');
      }
      final primaryOverlap = candidate.primaryMuscles
          .map(_normal)
          .toSet()
          .intersection(target.primaryMuscles.map(_normal).toSet())
          .length;
      if (primaryOverlap > 0) {
        score += (primaryOverlap * 14).clamp(0, 28);
        reasons.add('primary muscle match');
      }
      final secondaryOverlap = candidate.secondaryMuscles
          .map(_normal)
          .toSet()
          .intersection(target.secondaryMuscles.map(_normal).toSet())
          .length;
      score += (secondaryOverlap * 5).clamp(0, 10);
      if (isEquipmentCompatible(candidate, data.profile)) {
        score += 12;
        reasons.add('available equipment');
      }
      final difficultyGap = (candidate.difficulty - target.difficulty).abs();
      score += (10 - difficultyGap * 3).clamp(0, 10);
      if (_normal(target.regression) == _normal(candidate.name) ||
          _normal(target.progression) == _normal(candidate.name)) {
        score += 15;
        reasons.add('direct progression link');
      }
      if (candidate.isCustom) {
        score += 2;
        reasons.add('personal exercise');
      }
      if (score >= 25) {
        ranked.add(
          ExerciseSubstitutionScore(
            profile: candidate,
            score: score.clamp(0, 100),
            reasons: reasons,
          ),
        );
      }
    }
    ranked.sort((left, right) {
      final byScore = right.score.compareTo(left.score);
      return byScore != 0
          ? byScore
          : left.profile.name.compareTo(right.profile.name);
    });
    return ranked.take(limit.clamp(1, 20)).toList();
  }

  static List<ExerciseIntelligenceProfile> progressionPath(
    String exercise,
    FitnessData data,
  ) {
    final all = allProfiles(data);
    ExerciseIntelligenceProfile? find(String name) =>
        all.where((item) => _normal(item.name) == _normal(name)).firstOrNull;
    final start = find(exercise) ?? profileFor(exercise);
    final path = <ExerciseIntelligenceProfile>[];
    final visited = <String>{};

    void prependRegressions(ExerciseIntelligenceProfile item) {
      final previous = find(item.regression);
      if (previous == null || !visited.add(_normal(previous.name))) return;
      prependRegressions(previous);
      path.add(previous);
    }

    visited.add(_normal(start.name));
    prependRegressions(start);
    path.add(start);
    var current = start;
    while (current.progression.isNotEmpty && path.length < 8) {
      final next = find(current.progression);
      if (next == null || !visited.add(_normal(next.name))) break;
      path.add(next);
      current = next;
    }
    return path;
  }

  static Map<String, int> muscleCoverage(FitnessData data) {
    final counts = <String, int>{};
    for (final profile in allProfiles(data)) {
      for (final muscle in profile.primaryMuscles) {
        counts.update(muscle, (value) => value + 2, ifAbsent: () => 2);
      }
      for (final muscle in profile.secondaryMuscles) {
        counts.update(muscle, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    final entries = counts.entries.toList()
      ..sort((left, right) => right.value.compareTo(left.value));
    return Map.fromEntries(entries);
  }

  static String _categoryForPattern(String pattern) {
    final normalized = _normal(pattern);
    if (normalized.contains('carry') ||
        normalized.contains('locomotion') ||
        normalized.contains('conditioning')) {
      return 'CONDITIONING';
    }
    if (normalized.contains('isometric') || normalized.contains('skill')) {
      return 'SKILL';
    }
    return 'STRENGTH';
  }

  static List<String> _equipmentFor(String exercise, List<String> fallback) {
    final name = _normal(exercise);
    if (name.contains('αλτηρ') || name.contains('dumbbell')) {
      return const ['dumbbells'];
    }
    if (name.contains('goblet')) return const ['dumbbells'];
    if (name.contains('landmine')) return const ['barbell', 'landmine base'];
    if (name.contains('face pull')) return const ['resistance band'];
    if (name.contains('brisk walk')) return const ['bodyweight'];
    if (name.contains('λαστιχ') || name.contains('band')) {
      return const ['resistance band'];
    }
    if (name.contains('τροχαλ') || name.contains('cable')) {
      return const ['cable machine'];
    }
    if (name.contains('barbell') ||
        name.contains('back squat') ||
        name.contains('front squat') ||
        name.contains('πιεσεισ παγκου')) {
      return const ['barbell', 'rack'];
    }
    if (name.contains('pull-up') ||
        name.contains('ελξεισ') ||
        name.contains('hanging')) {
      return const ['pull-up bar'];
    }
    if (name.contains('ring')) return const ['gymnastic rings'];
    if (name.contains('sled')) return const ['sled'];
    if (name.contains('bike')) return const ['bike'];
    if (name.contains('εργομετρο')) return const ['rowing machine'];
    if (name.contains('σακιδιο')) return const ['backpack'];
    return fallback;
  }

  static String _normal(String value) {
    var normalized = value.trim().toLowerCase();
    const replacements = <String, String>{
      'ά': 'α',
      'έ': 'ε',
      'ή': 'η',
      'ί': 'ι',
      'ϊ': 'ι',
      'ΐ': 'ι',
      'ό': 'ο',
      'ύ': 'υ',
      'ϋ': 'υ',
      'ΰ': 'υ',
      'ώ': 'ω',
      'ς': 'σ',
    };
    for (final entry in replacements.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }
    return normalized;
  }

  static const _equipmentAliases = <String, List<String>>{
    'dumbbells': ['αλτηρ', 'dumbbell'],
    'resistance band': ['λαστιχ', 'band'],
    'pull-up bar': ['μονοζυγ', 'pull-up bar'],
    'barbell': ['μπαρ', 'barbell'],
    'rack': ['rack', 'κλουβι'],
    'bench': ['παγκο', 'bench'],
    'backpack': ['σακιδιο', 'backpack'],
    'gymnastic rings': ['κρικ', 'ring'],
  };

  static const _fallbackSeed = _ExerciseSeed(
    matches: [],
    category: 'STRENGTH',
    pattern: 'other',
    primary: ['full body'],
    secondary: [],
    difficulty: 2,
    skill: 2,
    equipment: ['bodyweight'],
    cautions: [],
  );

  static const _seeds = <_ExerciseSeed>[
    _ExerciseSeed(
      matches: ['pistol'],
      category: 'SKILL',
      pattern: 'squat',
      primary: ['quadriceps', 'glutes'],
      secondary: ['core', 'calves'],
      difficulty: 5,
      skill: 5,
      equipment: ['bodyweight'],
      cautions: ['knee', 'ankle', 'balance'],
      regression: 'Bulgarian split squat με στήριξη',
    ),
    _ExerciseSeed(
      matches: ['bulgarian', 'προβολ', 'step-up'],
      category: 'STRENGTH',
      pattern: 'single-leg squat',
      primary: ['quadriceps', 'glutes'],
      secondary: ['adductors', 'core'],
      difficulty: 3,
      skill: 3,
      equipment: ['bodyweight', 'bench'],
      cautions: ['knee', 'balance'],
      regression: 'Ανάστροφες προβολές με στήριξη',
      progression: 'Pistol squat to box',
    ),
    _ExerciseSeed(
      matches: ['squat', 'καθισματα', 'πιεσεισ ποδιων'],
      category: 'STRENGTH',
      pattern: 'squat',
      primary: ['quadriceps', 'glutes'],
      secondary: ['adductors', 'core'],
      difficulty: 3,
      skill: 3,
      equipment: ['bodyweight'],
      cautions: ['knee', 'hip', 'back'],
      regression: 'Goblet squat σε πάγκο',
      progression: 'Front squat',
    ),
    _ExerciseSeed(
      matches: ['trap-bar', 'deadlift', 'ρουμανικ', 'αρσεισ'],
      category: 'STRENGTH',
      pattern: 'hinge',
      primary: ['hamstrings', 'glutes'],
      secondary: ['back', 'forearms', 'core'],
      difficulty: 3,
      skill: 3,
      equipment: ['dumbbells'],
      cautions: ['back', 'hamstring'],
      regression: 'Hip thrust με παύση',
      progression: 'Trap-bar deadlift',
    ),
    _ExerciseSeed(
      matches: ['hip thrust', 'γεφυρ'],
      category: 'STRENGTH',
      pattern: 'hip extension',
      primary: ['glutes'],
      secondary: ['hamstrings', 'core'],
      difficulty: 2,
      skill: 2,
      equipment: ['floor'],
      cautions: ['back'],
      progression: 'Ρουμανικές άρσεις με αλτήρες',
    ),
    _ExerciseSeed(
      matches: ['γαμπ'],
      category: 'STRENGTH',
      pattern: 'ankle extension',
      primary: ['calves'],
      secondary: ['feet'],
      difficulty: 1,
      skill: 1,
      equipment: ['bodyweight'],
      cautions: ['ankle'],
    ),
    _ExerciseSeed(
      matches: ['βυθισ', 'dip'],
      category: 'STRENGTH',
      pattern: 'vertical push',
      primary: ['chest', 'triceps'],
      secondary: ['front delts'],
      difficulty: 4,
      skill: 4,
      equipment: ['dip bars'],
      cautions: ['shoulder', 'elbow', 'sternum'],
      regression: 'Κάμψεις κλειστής λαβής',
    ),
    _ExerciseSeed(
      matches: ['pike', 'πιεσεισ ωμων', 'landmine'],
      category: 'STRENGTH',
      pattern: 'vertical push',
      primary: ['shoulders', 'triceps'],
      secondary: ['upper chest', 'core'],
      difficulty: 3,
      skill: 3,
      equipment: ['bodyweight'],
      cautions: ['shoulder', 'back'],
      regression: 'Πιέσεις ώμων με λάστιχο',
      progression: 'Pike push-ups',
    ),
    _ExerciseSeed(
      matches: ['καμψεισ', 'push-up', 'πιεσεισ στηθουσ', 'πιεσεισ παγκου'],
      category: 'STRENGTH',
      pattern: 'horizontal push',
      primary: ['chest', 'triceps'],
      secondary: ['front delts', 'core'],
      difficulty: 2,
      skill: 2,
      equipment: ['bodyweight'],
      cautions: ['shoulder', 'wrist', 'elbow'],
      regression: 'Κάμψεις σε υπερυψωμένη επιφάνεια',
      progression: 'Κάμψεις με παύση 1″',
    ),
    _ExerciseSeed(
      matches: ['weighted pull-up'],
      category: 'STRENGTH',
      pattern: 'vertical pull',
      primary: ['lats', 'biceps'],
      secondary: ['upper back', 'forearms', 'core'],
      difficulty: 5,
      skill: 4,
      equipment: ['pull-up bar'],
      cautions: ['shoulder', 'elbow'],
      regression: 'Αυστηρές έλξεις',
    ),
    _ExerciseSeed(
      matches: ['ελξεισ', 'pull-up', 'τροχαλιασ'],
      category: 'STRENGTH',
      pattern: 'vertical pull',
      primary: ['lats', 'biceps'],
      secondary: ['upper back', 'forearms', 'core'],
      difficulty: 3,
      skill: 3,
      equipment: ['pull-up bar'],
      cautions: ['shoulder', 'elbow'],
      regression: 'Υποβοηθούμενες έλξεις',
      progression: 'Weighted pull-up',
    ),
    _ExerciseSeed(
      matches: ['scapular'],
      category: 'SKILL',
      pattern: 'scapular control',
      primary: ['lower traps', 'serratus'],
      secondary: ['lats', 'forearms'],
      difficulty: 2,
      skill: 3,
      equipment: ['pull-up bar'],
      cautions: ['shoulder', 'elbow'],
      progression: 'Υποβοηθούμενες έλξεις',
    ),
    _ExerciseSeed(
      matches: ['κωπηλατικη', 'row', 'face pull'],
      category: 'STRENGTH',
      pattern: 'horizontal pull',
      primary: ['upper back', 'lats'],
      secondary: ['rear delts', 'biceps', 'forearms'],
      difficulty: 2,
      skill: 2,
      equipment: ['dumbbells'],
      cautions: ['shoulder', 'back'],
      regression: 'Κωπηλατική με λάστιχο — αργό tempo',
      progression: 'Κωπηλατική με στήριξη στήθους',
    ),
    _ExerciseSeed(
      matches: ['hanging leg', 'hanging knee', 'κρεμαστ'],
      category: 'STRENGTH',
      pattern: 'trunk flexion',
      primary: ['abs'],
      secondary: ['hip flexors', 'forearms', 'lats'],
      difficulty: 4,
      skill: 4,
      equipment: ['pull-up bar'],
      cautions: ['shoulder', 'back'],
      regression: 'Hollow body hold',
      progression: 'Hanging leg raises',
    ),
    _ExerciseSeed(
      matches: ['hollow', 'dead bug', 'arch body'],
      category: 'STRENGTH',
      pattern: 'anti-extension',
      primary: ['abs'],
      secondary: ['hip flexors', 'serratus'],
      difficulty: 2,
      skill: 2,
      equipment: ['floor'],
      cautions: ['back'],
      regression: 'Dead bug',
      progression: 'Hollow body hold',
    ),
    _ExerciseSeed(
      matches: ['pallof'],
      category: 'STRENGTH',
      pattern: 'anti-rotation',
      primary: ['obliques', 'abs'],
      secondary: ['glutes', 'shoulders'],
      difficulty: 2,
      skill: 2,
      equipment: ['resistance band'],
      cautions: ['back'],
    ),
    _ExerciseSeed(
      matches: ['farmer', 'suitcase', 'carry'],
      category: 'CONDITIONING',
      pattern: 'loaded carry',
      primary: ['forearms', 'core'],
      secondary: ['traps', 'glutes', 'calves'],
      difficulty: 2,
      skill: 2,
      equipment: ['dumbbells'],
      cautions: ['grip', 'back'],
      regression: 'Suitcase carry',
      progression: 'Farmer carry',
    ),
    _ExerciseSeed(
      matches: ['handstand'],
      category: 'SKILL',
      pattern: 'inverted support',
      primary: ['shoulders', 'triceps'],
      secondary: ['core', 'wrists', 'upper back'],
      difficulty: 5,
      skill: 5,
      equipment: ['wall'],
      cautions: ['wrist', 'shoulder', 'neck', 'balance'],
      regression: 'Pike push-ups',
      progression: 'Wall handstand',
    ),
    _ExerciseSeed(
      matches: ['l-sit'],
      category: 'SKILL',
      pattern: 'straight-arm support',
      primary: ['abs', 'hip flexors'],
      secondary: ['triceps', 'shoulders', 'quadriceps'],
      difficulty: 4,
      skill: 5,
      equipment: ['parallettes'],
      cautions: ['wrist', 'shoulder', 'hip'],
      regression: 'L-sit tuck hold',
    ),
    _ExerciseSeed(
      matches: ['ring support'],
      category: 'SKILL',
      pattern: 'straight-arm support',
      primary: ['triceps', 'chest'],
      secondary: ['shoulders', 'core'],
      difficulty: 4,
      skill: 5,
      equipment: ['gymnastic rings'],
      cautions: ['shoulder', 'elbow', 'wrist'],
      regression: 'Κάμψεις κλειστής λαβής',
    ),
    _ExerciseSeed(
      matches: ['bear crawl', 'mountain climber'],
      category: 'CONDITIONING',
      pattern: 'locomotion',
      primary: ['core', 'shoulders'],
      secondary: ['hip flexors', 'quadriceps'],
      difficulty: 2,
      skill: 2,
      equipment: ['floor'],
      cautions: ['wrist', 'shoulder', 'back'],
    ),
    _ExerciseSeed(
      matches: ['sled'],
      category: 'CONDITIONING',
      pattern: 'locomotion',
      primary: ['quadriceps', 'glutes'],
      secondary: ['calves', 'core', 'shoulders'],
      difficulty: 3,
      skill: 2,
      equipment: ['sled'],
      cautions: ['knee', 'ankle'],
    ),
    _ExerciseSeed(
      matches: ['air bike', 'zone 2 bike', 'εργομετρο', 'brisk walk'],
      category: 'CONDITIONING',
      pattern: 'cyclical conditioning',
      primary: ['cardiorespiratory'],
      secondary: ['legs', 'core'],
      difficulty: 2,
      skill: 1,
      equipment: ['bike'],
      cautions: ['cardiorespiratory'],
    ),
  ];
}

class _ExerciseSeed {
  const _ExerciseSeed({
    required this.matches,
    required this.category,
    required this.pattern,
    required this.primary,
    required this.secondary,
    required this.difficulty,
    required this.skill,
    required this.equipment,
    required this.cautions,
    this.regression = '',
    this.progression = '',
  });

  final List<String> matches;
  final String category;
  final String pattern;
  final List<String> primary;
  final List<String> secondary;
  final int difficulty;
  final int skill;
  final List<String> equipment;
  final List<String> cautions;
  final String regression;
  final String progression;
}
