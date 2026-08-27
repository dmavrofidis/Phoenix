import 'models/fitness_models.dart';

class Restart14Day {
  const Restart14Day({
    required this.day,
    required this.titleGreek,
    required this.titleEnglish,
    required this.focusGreek,
    required this.focusEnglish,
    required this.workout,
  });

  final int day;
  final String titleGreek;
  final String titleEnglish;
  final String focusGreek;
  final String focusEnglish;
  final WorkoutTemplate workout;
}

class Restart14Engine {
  const Restart14Engine._();

  static final RegExp _dayPattern = RegExp(
    r'^ΕΠΑΝΕΚΚΙΝΗΣΗ 14 • ΗΜΕΡΑ (\d{1,2})',
  );

  static Set<int> completedDayNumbers(List<WorkoutLog> logs) => logs
      .map((log) => _dayPattern.firstMatch(log.templateName))
      .whereType<RegExpMatch>()
      .map((match) => int.tryParse(match.group(1) ?? ''))
      .whereType<int>()
      .where((day) => day >= 1 && day <= 14)
      .toSet();

  static int completedDays(List<WorkoutLog> logs) =>
      completedDayNumbers(logs).length;

  static int currentDay(List<WorkoutLog> logs) {
    final completed = completedDayNumbers(logs);
    for (var day = 1; day <= 14; day += 1) {
      if (!completed.contains(day)) return day;
    }
    return 14;
  }

  static bool isComplete(List<WorkoutLog> logs) => completedDays(logs) >= 14;

  static Restart14Day dayPlan({
    required int day,
    required int availableMinutes,
    required int energy,
    bool hasChair = true,
  }) {
    final safeDay = day.clamp(1, 14);
    final blueprint = _days[safeDay - 1];
    final minuteCap = availableMinutes.clamp(5, 40);
    final setCap = energy <= 2 || minuteCap <= 5
        ? 1
        : minuteCap <= 10
        ? 2
        : blueprint.sets;
    final exercises = blueprint.exercises
        .map(
          (exercise) =>
              !hasChair && exercise == 'Κάθισμα και σήκωμα από καρέκλα'
              ? 'Καθίσματα με το βάρος του σώματος'
              : exercise,
        )
        .take(minuteCap <= 5 ? 2 : blueprint.exercises.length)
        .toList();
    return Restart14Day(
      day: safeDay,
      titleGreek: blueprint.titleGreek,
      titleEnglish: blueprint.titleEnglish,
      focusGreek: blueprint.focusGreek,
      focusEnglish: blueprint.focusEnglish,
      workout: WorkoutTemplate(
        id: 'restart14-day-$safeDay',
        name: 'ΕΠΑΝΕΚΚΙΝΗΣΗ 14 • ΗΜΕΡΑ $safeDay — ${blueprint.titleGreek}',
        exercises: exercises,
        prescription: '$setCap ήρεμα σετ • χωρίς εξάντληση',
        coachingCue:
            'Κάνε μόνο ό,τι νιώθεις ελεγχόμενο. Το πρόγραμμα δεν μηδενίζεται αν λείψεις.',
        restSeconds: 60,
        sessionType: blueprint.recovery ? 'recovery' : 'workout',
        equipmentPreset: 'none',
        tags: const ['restart14', 'beginner', 'home', 'no-equipment'],
        exercisePrescriptions: {
          for (final exercise in exercises)
            exercise: ExercisePrescription(
              workingSets: setCap,
              minReps: blueprint.recovery ? 4 : 6,
              maxReps: blueprint.recovery ? 6 : 10,
              targetRir: energy <= 2 ? 5 : 4,
              restSeconds: 60,
              tempo: 'αργά και ελεγχόμενα',
              note: 'Σταμάτα πριν κουραστεί η τεχνική σου.',
            ),
        },
      ),
    );
  }

  static const _days = <_RestartBlueprint>[
    _RestartBlueprint(
      titleGreek: 'Απλώς εμφανίσου',
      titleEnglish: 'Just show up',
      focusGreek: 'Καρέκλα και τοίχος — δύο κινήσεις είναι αρκετές.',
      focusEnglish: 'Chair and wall — two movements are enough.',
      exercises: ['Κάθισμα και σήκωμα από καρέκλα', 'Κάμψεις στον τοίχο'],
      sets: 1,
    ),
    _RestartBlueprint(
      titleGreek: 'Ήρεμος κορμός',
      titleEnglish: 'Calm core',
      focusGreek: 'Σταθερότητα στο πάτωμα, χωρίς βιασύνη.',
      focusEnglish: 'Floor stability without rushing.',
      exercises: ['Bird dog', 'Γέφυρα γλουτών στο πάτωμα'],
      sets: 1,
    ),
    _RestartBlueprint(
      titleGreek: 'Οι τέσσερις βάσεις',
      titleEnglish: 'The four foundations',
      focusGreek: 'Ένα μικρό πέρασμα από όλο το σώμα.',
      focusEnglish: 'One small full-body round.',
      exercises: [
        'Κάθισμα και σήκωμα από καρέκλα',
        'Κάμψεις στον τοίχο',
        'Bird dog',
        'Γέφυρα γλουτών στο πάτωμα',
      ],
      sets: 1,
    ),
    _RestartBlueprint(
      titleGreek: 'Ημέρα φροντίδας',
      titleEnglish: 'Care day',
      focusGreek: 'Λίγη κίνηση για να νιώσεις καλύτερα, όχι για επίδοση.',
      focusEnglish: 'A little movement to feel better, not to perform.',
      exercises: ['Bird dog', 'Γέφυρα γλουτών στο πάτωμα'],
      sets: 1,
      recovery: true,
    ),
    _RestartBlueprint(
      titleGreek: 'Χτίζουμε σταθερότητα',
      titleEnglish: 'Building stability',
      focusGreek: 'Δύο ήρεμα σετ στις βασικές κινήσεις.',
      focusEnglish: 'Two calm sets of the basic movements.',
      exercises: [
        'Κάθισμα και σήκωμα από καρέκλα',
        'Κάμψεις στον τοίχο',
        'Bird dog',
      ],
      sets: 2,
    ),
    _RestartBlueprint(
      titleGreek: 'Πόδια και κορμός',
      titleEnglish: 'Legs and core',
      focusGreek: 'Μικρή ενδυνάμωση με ασφαλή σημεία στήριξης.',
      focusEnglish: 'Small strength work with stable support.',
      exercises: [
        'Κάθισμα και σήκωμα από καρέκλα',
        'Γέφυρα γλουτών στο πάτωμα',
        'Bird dog',
      ],
      sets: 2,
    ),
    _RestartBlueprint(
      titleGreek: 'Η ελάχιστη ημέρα μετράει',
      titleEnglish: 'The minimum day counts',
      focusGreek: 'Πέντε λεπτά αρκούν για να κρατήσεις επαφή.',
      focusEnglish: 'Five minutes are enough to stay connected.',
      exercises: ['Κάμψεις στον τοίχο', 'Bird dog'],
      sets: 1,
      recovery: true,
    ),
    _RestartBlueprint(
      titleGreek: 'Ξεκινά η δεύτερη εβδομάδα',
      titleEnglish: 'Week two begins',
      focusGreek: 'Επαναλαμβάνουμε όσα ήδη γνωρίζεις.',
      focusEnglish: 'Repeat what you already know.',
      exercises: [
        'Κάθισμα και σήκωμα από καρέκλα',
        'Κάμψεις στον τοίχο',
        'Bird dog',
        'Γέφυρα γλουτών στο πάτωμα',
      ],
      sets: 2,
    ),
    _RestartBlueprint(
      titleGreek: 'Έλεγχος, όχι ταχύτητα',
      titleEnglish: 'Control, not speed',
      focusGreek: 'Αργές επαναλήψεις και άνετη αναπνοή.',
      focusEnglish: 'Slow repetitions and comfortable breathing.',
      exercises: [
        'Κάθισμα και σήκωμα από καρέκλα',
        'Κάμψεις στον τοίχο',
        'Γέφυρα γλουτών στο πάτωμα',
      ],
      sets: 2,
    ),
    _RestartBlueprint(
      titleGreek: 'Όλο το σώμα, ήρεμα',
      titleEnglish: 'Calm full body',
      focusGreek: 'Μια πλήρης αλλά σύντομη προπόνηση.',
      focusEnglish: 'A complete but short workout.',
      exercises: [
        'Κάθισμα και σήκωμα από καρέκλα',
        'Κάμψεις στον τοίχο',
        'Bird dog',
        'Γέφυρα γλουτών στο πάτωμα',
      ],
      sets: 2,
    ),
    _RestartBlueprint(
      titleGreek: 'Ανάσα και αποκατάσταση',
      titleEnglish: 'Breathe and recover',
      focusGreek: 'Χαμηλώνουμε ένταση χωρίς να χάνουμε τη συνέχεια.',
      focusEnglish: 'Lower the intensity without losing continuity.',
      exercises: ['Bird dog', 'Γέφυρα γλουτών στο πάτωμα'],
      sets: 1,
      recovery: true,
    ),
    _RestartBlueprint(
      titleGreek: 'Λίγο πιο δυνατός',
      titleEnglish: 'A little stronger',
      focusGreek: 'Μόνο αν νιώθεις καλά, πρόσθεσε ένα ήρεμο σετ.',
      focusEnglish: 'Only if you feel well, add one calm set.',
      exercises: [
        'Κάθισμα και σήκωμα από καρέκλα',
        'Κάμψεις στον τοίχο',
        'Bird dog',
        'Γέφυρα γλουτών στο πάτωμα',
      ],
      sets: 3,
    ),
    _RestartBlueprint(
      titleGreek: 'Κρατάμε το καλό',
      titleEnglish: 'Keep what works',
      focusGreek: 'Επίλεξε έλεγχο και καθαρή τεχνική.',
      focusEnglish: 'Choose control and clean technique.',
      exercises: [
        'Κάθισμα και σήκωμα από καρέκλα',
        'Κάμψεις στον τοίχο',
        'Γέφυρα γλουτών στο πάτωμα',
      ],
      sets: 2,
    ),
    _RestartBlueprint(
      titleGreek: 'Δεν τελειώνεις — συνεχίζεις',
      titleEnglish: 'Not an ending — a continuation',
      focusGreek:
          'Ολοκλήρωσε τις τέσσερις βάσεις και κράτησε την εκδοχή που σου ταιριάζει.',
      focusEnglish:
          'Complete the four foundations and keep the version that fits you.',
      exercises: [
        'Κάθισμα και σήκωμα από καρέκλα',
        'Κάμψεις στον τοίχο',
        'Bird dog',
        'Γέφυρα γλουτών στο πάτωμα',
      ],
      sets: 2,
    ),
  ];
}

class _RestartBlueprint {
  const _RestartBlueprint({
    required this.titleGreek,
    required this.titleEnglish,
    required this.focusGreek,
    required this.focusEnglish,
    required this.exercises,
    required this.sets,
    this.recovery = false,
  });

  final String titleGreek;
  final String titleEnglish;
  final String focusGreek;
  final String focusEnglish;
  final List<String> exercises;
  final int sets;
  final bool recovery;
}
