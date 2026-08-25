import 'models/fitness_models.dart';

enum DailyCompanionKind { fullWorkout, shortWorkout, recovery, walk }

class DailyCompanionCheckIn {
  const DailyCompanionCheckIn({
    required this.date,
    required this.minutes,
    required this.energy,
    required this.location,
    required this.painArea,
  });

  final DateTime date;
  final int minutes;
  final int energy;
  final String location;
  final String painArea;

  bool isFor(DateTime value) =>
      date.year == value.year &&
      date.month == value.month &&
      date.day == value.day;
}

class DailyCompanionPlan {
  const DailyCompanionPlan({
    required this.kind,
    required this.titleGreek,
    required this.titleEnglish,
    required this.reasonGreek,
    required this.reasonEnglish,
    required this.encouragementGreek,
    required this.encouragementEnglish,
    required this.minutes,
    required this.workout,
  });

  final DailyCompanionKind kind;
  final String titleGreek;
  final String titleEnglish;
  final String reasonGreek;
  final String reasonEnglish;
  final String encouragementGreek;
  final String encouragementEnglish;
  final int minutes;
  final WorkoutTemplate workout;
}

class PhoenixStarterPath {
  const PhoenixStarterPath({
    required this.id,
    required this.titleGreek,
    required this.titleEnglish,
    required this.subtitleGreek,
    required this.subtitleEnglish,
  });

  final String id;
  final String titleGreek;
  final String titleEnglish;
  final String subtitleGreek;
  final String subtitleEnglish;
}

class DailyCompanionEngine {
  const DailyCompanionEngine._();

  static const paths = <PhoenixStarterPath>[
    PhoenixStarterPath(
      id: 'restart14',
      titleGreek: 'Ξεκινώ ξανά — 14 ημέρες',
      titleEnglish: 'Restart — 14 days',
      subtitleGreek: 'Μικρά βήματα χωρίς πίεση για τελειότητα',
      subtitleEnglish: 'Small steps without pressure for perfection',
    ),
    PhoenixStarterPath(
      id: 'dumbbells',
      titleGreek: 'Έχω μόνο αλτήρες',
      titleEnglish: 'I only have dumbbells',
      subtitleGreek: 'Απλές προπονήσεις δύναμης στο σπίτι',
      subtitleEnglish: 'Simple strength workouts at home',
    ),
    PhoenixStarterPath(
      id: 'treadmill',
      titleGreek: 'Έχω έναν διάδρομο',
      titleEnglish: 'I have a treadmill',
      subtitleGreek: 'Περπάτημα και σταδιακή βελτίωση αντοχής',
      subtitleEnglish: 'Walking and gradual endurance progress',
    ),
    PhoenixStarterPath(
      id: 'bodyweight',
      titleGreek: 'Χωρίς εξοπλισμό',
      titleEnglish: 'No equipment',
      subtitleGreek: 'Κίνηση με το σώμα και σταθερά έπιπλα',
      subtitleEnglish: 'Bodyweight movement with stable furniture',
    ),
    PhoenixStarterPath(
      id: 'strength',
      titleGreek: 'Θέλω να δυναμώσω',
      titleEnglish: 'I want to get stronger',
      subtitleGreek: 'Σταδιακή πρόοδος με ό,τι διαθέτεις',
      subtitleEnglish: 'Gradual progress with what you have',
    ),
    PhoenixStarterPath(
      id: 'weightCare',
      titleGreek: 'Φροντίζω το βάρος μου',
      titleEnglish: 'I am caring for my weight',
      subtitleGreek: 'Κίνηση και απλή διατροφή χωρίς ακραίους κανόνες',
      subtitleEnglish: 'Movement and simple food without extreme rules',
    ),
  ];

  static DailyCompanionCheckIn? checkInFrom(AppPreferences preferences) {
    final date = DateTime.tryParse(preferences.dailyCheckInDate);
    if (date == null) return null;
    return DailyCompanionCheckIn(
      date: date,
      minutes: preferences.dailyMinutes,
      energy: preferences.dailyEnergy,
      location: preferences.dailyLocation,
      painArea: preferences.dailyPainArea,
    );
  }

  static PhoenixStarterPath pathFor(String id) =>
      paths.firstWhere((path) => path.id == id, orElse: () => paths.first);

  static DailyCompanionPlan buildPlan({
    required DailyCompanionCheckIn checkIn,
    required AppPreferences preferences,
    required WorkoutTemplate recommended,
    required WorkoutTemplate recovery,
    UserProfile? profile,
  }) {
    final hasPain = checkIn.painArea.trim().isNotEmpty;
    if (hasPain || checkIn.energy == 1) {
      final painGreek = _painLabel(checkIn.painArea, english: false);
      final painEnglish = _painLabel(checkIn.painArea, english: true);
      return DailyCompanionPlan(
        kind: DailyCompanionKind.recovery,
        titleGreek: 'Σήμερα προστατεύουμε το σώμα σου',
        titleEnglish: 'Today we protect your body',
        reasonGreek: hasPain
            ? 'Δήλωσες ενόχληση: $painGreek. Προτείνεται μόνο ήπια κίνηση.'
            : 'Η ενέργειά σου είναι πολύ χαμηλή. Η αποκατάσταση μετρά ως φροντίδα.',
        reasonEnglish: hasPain
            ? 'You reported discomfort in $painEnglish. Only gentle movement is suggested.'
            : 'Your energy is very low. Recovery still counts as care.',
        encouragementGreek:
            'Δεν χρειάζεται να αποδείξεις τίποτα σήμερα. Σταμάτα αν πονάς.',
        encouragementEnglish:
            'You do not have to prove anything today. Stop if pain appears.',
        minutes: checkIn.minutes.clamp(5, 20),
        workout: recovery,
      );
    }

    final equipment = profile?.equipment.toLowerCase() ?? '';
    final path = preferences.starterPath;
    final hasTreadmill =
        equipment.contains('διάδρο') || equipment.contains('treadmill');
    final wantsWalk =
        checkIn.location == 'outside' || (path == 'treadmill' && hasTreadmill);
    if (wantsWalk) {
      final onTreadmill = path == 'treadmill' && hasTreadmill;
      final exercise = onTreadmill
          ? 'Περπάτημα σε απλό διάδρομο'
          : 'Περπάτημα σε εξωτερικό χώρο';
      return DailyCompanionPlan(
        kind: DailyCompanionKind.walk,
        titleGreek: onTreadmill
            ? 'Ήρεμο περπάτημα στον διάδρομο'
            : 'Βγαίνουμε για ένα απλό περπάτημα',
        titleEnglish: onTreadmill
            ? 'Gentle treadmill walk'
            : 'Let us take a simple walk',
        reasonGreek:
            'Ταιριάζει στον χώρο, στον χρόνο και στην ενέργεια που δήλωσες.',
        reasonEnglish: 'It fits the place, time and energy you selected.',
        encouragementGreek: 'Κράτησε ρυθμό που σου επιτρέπει να μιλάς άνετα.',
        encouragementEnglish:
            'Keep a pace that still lets you speak comfortably.',
        minutes: checkIn.minutes,
        workout: _simpleTemplate(
          id: onTreadmill ? 'daily-treadmill' : 'daily-walk',
          name: onTreadmill
              ? 'ΣΗΜΕΡΑ — Ήρεμος διάδρομος'
              : 'ΣΗΜΕΡΑ — Ήρεμο περπάτημα',
          exercises: [exercise],
          minutes: checkIn.minutes,
          sessionType: 'cardio',
        ),
      );
    }

    final needsBodyweight =
        checkIn.location == 'home' &&
        profile != null &&
        !profile.trainingPlace.toLowerCase().contains('σπί');
    final base = needsBodyweight || path == 'bodyweight'
        ? _bodyweightTemplate()
        : recommended;
    final short = checkIn.minutes <= 10 || checkIn.energy == 2;
    final adapted = _adaptWorkout(
      base,
      minutes: checkIn.minutes,
      energy: checkIn.energy,
    );
    return DailyCompanionPlan(
      kind: short
          ? DailyCompanionKind.shortWorkout
          : DailyCompanionKind.fullWorkout,
      titleGreek: short
          ? 'Το μικρό βήμα που ταιριάζει σήμερα'
          : 'Η προπόνησή σου για σήμερα',
      titleEnglish: short
          ? 'The small step that fits today'
          : 'Your workout for today',
      reasonGreek: short
          ? 'Κρατήσαμε μόνο τα απαραίτητα για να χωρέσει στη μέρα σου.'
          : 'Προσαρμόστηκε στον χρόνο, στην ενέργεια και στον εξοπλισμό σου.',
      reasonEnglish: short
          ? 'We kept only the essentials so it fits your day.'
          : 'Adapted to your time, energy and available equipment.',
      encouragementGreek: path == 'restart14'
          ? 'Ο στόχος σήμερα είναι να εμφανιστείς — όχι να εξαντληθείς.'
          : 'Σταμάτα με την αίσθηση ότι θα μπορούσες να κάνεις λίγο ακόμη.',
      encouragementEnglish: path == 'restart14'
          ? 'Today the goal is to show up, not to exhaust yourself.'
          : 'Finish feeling that you could still do a little more.',
      minutes: checkIn.minutes,
      workout: adapted,
    );
  }

  static int returnMoments(List<WorkoutLog> logs) {
    if (logs.isEmpty) return 0;
    final days =
        logs
            .map(
              (log) => DateTime(
                log.completedAt.year,
                log.completedAt.month,
                log.completedAt.day,
              ),
            )
            .toSet()
            .toList()
          ..sort();
    var returns = 1;
    for (var index = 1; index < days.length; index++) {
      if (days[index].difference(days[index - 1]).inDays >= 3) returns++;
    }
    return returns;
  }

  static WorkoutTemplate _adaptWorkout(
    WorkoutTemplate template, {
    required int minutes,
    required int energy,
  }) {
    final exerciseCount = switch (minutes) {
      <= 5 => 2,
      <= 10 => 3,
      <= 20 => 4,
      _ => template.exercises.length,
    };
    final exercises = template.exercises.take(exerciseCount).toList();
    final workingSets = minutes <= 5 || energy == 2
        ? 1
        : minutes <= 20
        ? 2
        : 3;
    final prescriptions = <String, ExercisePrescription>{};
    for (final exercise in exercises) {
      final original = template.prescriptionFor(exercise);
      prescriptions[exercise] = ExercisePrescription(
        workingSets: workingSets,
        minReps: original.minReps,
        maxReps: original.maxReps,
        targetRir: energy <= 2 ? 4 : original.targetRir.clamp(2, 4),
        restSeconds: original.restSeconds.clamp(45, 120),
        tempo: original.tempo,
        minHoldSeconds: original.minHoldSeconds,
        maxHoldSeconds: original.maxHoldSeconds,
        note: original.note,
      );
    }
    return template.copyWith(
      id: 'daily-${template.id}',
      name: 'ΣΗΜΕΡΑ — ${template.name}',
      exercises: exercises,
      prescription: '$workingSets ήρεμα σετ • άνετη τεχνική',
      coachingCue:
          'Η σημερινή εκδοχή είναι μικρότερη επίτηδες. Η συνέπεια αξίζει περισσότερο από την εξάντληση.',
      exercisePrescriptions: prescriptions,
      blocks: const [],
    );
  }

  static WorkoutTemplate _bodyweightTemplate() => _simpleTemplate(
    id: 'daily-bodyweight',
    name: 'ΣΗΜΕΡΑ — Χωρίς εξοπλισμό',
    exercises: const [
      'Κάθισμα και σήκωμα από καρέκλα',
      'Κάμψεις στον τοίχο',
      'Bird dog',
      'Γέφυρα γλουτών στο πάτωμα',
    ],
    minutes: 20,
  );

  static WorkoutTemplate _simpleTemplate({
    required String id,
    required String name,
    required List<String> exercises,
    required int minutes,
    String sessionType = 'workout',
  }) {
    final timed = sessionType == 'cardio';
    return WorkoutTemplate(
      id: id,
      name: name,
      exercises: exercises,
      prescription: timed
          ? '$minutes λεπτά • άνετος ρυθμός'
          : '2 ήρεμα σετ • άνετη τεχνική',
      coachingCue: timed
          ? 'Κράτησε ρυθμό που σου επιτρέπει να μιλάς.'
          : 'Κινήσου αργά και σταμάτα πριν χαλάσει η τεχνική.',
      restSeconds: 60,
      sessionType: sessionType,
      equipmentPreset: 'none',
      exercisePrescriptions: {
        for (final exercise in exercises)
          exercise: ExercisePrescription(
            workingSets: timed ? 1 : 2,
            minReps: timed ? 1 : 6,
            maxReps: timed ? 1 : 10,
            targetRir: 4,
            restSeconds: 60,
            tempo: 'αργά και ελεγχόμενα',
            minHoldSeconds: timed ? minutes * 60 : 0,
            maxHoldSeconds: timed ? minutes * 60 : 0,
          ),
      },
    );
  }

  static String _painLabel(String value, {required bool english}) =>
      switch (value) {
        'shoulder' => english ? 'the shoulder' : 'ώμος',
        'back' => english ? 'the back' : 'μέση ή πλάτη',
        'knee' => english ? 'the knee' : 'γόνατο',
        _ => english ? 'another area' : 'άλλο σημείο',
      };
}
