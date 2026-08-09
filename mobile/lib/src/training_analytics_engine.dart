import 'models/fitness_models.dart';

class MuscleVolume {
  const MuscleVolume({
    required this.muscle,
    required this.sets,
    required this.minimumTarget,
    required this.maximumTarget,
  });

  final String muscle;
  final int sets;
  final int minimumTarget;
  final int maximumTarget;

  double get progress => (sets / maximumTarget).clamp(0, 1).toDouble();
  String get status => sets < minimumTarget
      ? 'Χαμηλά'
      : sets > maximumTarget
      ? 'Υψηλά'
      : 'Στόχος';
}

class WeeklyTrainingReport {
  const WeeklyTrainingReport({
    required this.workouts,
    required this.workoutTarget,
    required this.sets,
    required this.minutes,
    required this.averageRpe,
    required this.painFlags,
    required this.headline,
    required this.action,
  });

  final int workouts;
  final int workoutTarget;
  final int sets;
  final int minutes;
  final double averageRpe;
  final int painFlags;
  final String headline;
  final String action;
}

class TrainingAnalyticsEngine {
  const TrainingAnalyticsEngine._();

  static List<MuscleVolume> weeklyMuscleVolume(
    List<WorkoutLog> logs, {
    required DateTime now,
  }) {
    final threshold = now.subtract(const Duration(days: 7));
    final totals = <String, int>{};
    for (final workout in logs.where(
      (item) => item.completedAt.isAfter(threshold),
    )) {
      for (final set in workout.sets) {
        for (final muscle in musclesForExercise(set.exerciseName)) {
          totals[muscle] = (totals[muscle] ?? 0) + 1;
        }
      }
    }
    const orderedMuscles = [
      'Στήθος',
      'Πλάτη',
      'Ώμοι',
      'Τετρακέφαλοι',
      'Οπίσθιοι μηριαίοι',
      'Γλουτοί',
      'Κορμός',
      'Χέρια',
    ];
    return [
      for (final muscle in orderedMuscles)
        MuscleVolume(
          muscle: muscle,
          sets: totals[muscle] ?? 0,
          minimumTarget: muscle == 'Χέρια' ? 4 : 6,
          maximumTarget: muscle == 'Κορμός' ? 14 : 16,
        ),
    ];
  }

  static Set<String> musclesForExercise(String exercise) {
    final name = exercise.toLowerCase();
    final muscles = <String>{};
    if (_containsAny(name, [
      'πιέσεις στήθους',
      'κάμψεις',
      'push-up',
      'βυθίσεις',
      'dip',
    ])) {
      muscles.addAll(['Στήθος', 'Ώμοι', 'Χέρια']);
    }
    if (_containsAny(name, ['έλξεις', 'κωπηλα', 'pull', 'face pull'])) {
      muscles.addAll(['Πλάτη', 'Χέρια']);
    }
    if (_containsAny(name, ['pike', 'πιέσεις ώμων', 'landmine', 'handstand'])) {
      muscles.addAll(['Ώμοι', 'Χέρια']);
    }
    if (_containsAny(name, [
      'squat',
      'καθίσ',
      'bulgarian',
      'προβολ',
      'pistol',
      'step-up',
      'sled',
    ])) {
      muscles.addAll(['Τετρακέφαλοι', 'Γλουτοί']);
    }
    if (_containsAny(name, [
      'ρουμανικ',
      'deadlift',
      'trap-bar',
      'hip thrust',
      'γέφυρ',
    ])) {
      muscles.addAll(['Οπίσθιοι μηριαίοι', 'Γλουτοί']);
    }
    if (_containsAny(name, [
      'hollow',
      'dead bug',
      'pallof',
      'carry',
      'farmer',
      'suitcase',
      'hanging',
      'l-sit',
    ])) {
      muscles.add('Κορμός');
    }
    if (muscles.isEmpty) muscles.add('Κορμός');
    return muscles;
  }

  static WeeklyTrainingReport weeklyReport({
    required List<WorkoutLog> logs,
    required int workoutTarget,
    required DateTime now,
  }) {
    final threshold = now.subtract(const Duration(days: 7));
    final recent = logs
        .where((item) => item.completedAt.isAfter(threshold))
        .toList();
    final setCount = recent.fold<int>(
      0,
      (sum, workout) => sum + workout.sets.length,
    );
    final minutes = recent.fold<int>(
      0,
      (sum, workout) => sum + workout.minutes,
    );
    final rated = recent.where((item) => item.sessionRpe > 0).toList();
    final averageRpe = rated.isEmpty
        ? 0.0
        : rated.fold<int>(0, (sum, workout) => sum + workout.sessionRpe) /
              rated.length;
    final painFlags = recent.where((item) => item.painSeverity >= 3).length;

    String headline;
    String action;
    if (painFlags > 0) {
      headline = 'Υπάρχει pain flag';
      action =
          'Μην πιέσεις την ενοχλημένη περιοχή. Επίλεξε ασφαλή εναλλακτική ή αξιολόγηση.';
    } else if (recent.length >= workoutTarget && averageRpe <= 8) {
      headline = 'Ισχυρή εβδομάδα';
      action =
          'Ο στόχος καλύφθηκε με ελεγχόμενη ένταση. Προτεραιότητα στην αποκατάσταση.';
    } else if (averageRpe >= 8.8) {
      headline = 'Υψηλή αντιληπτή κόπωση';
      action = 'Κράτησε μεγαλύτερο RIR ή ενεργοποίησε πρόωρο deload.';
    } else if (recent.length < workoutTarget) {
      headline = 'Χτίζεις συνέπεια';
      action =
          'Μένουν ${(workoutTarget - recent.length).clamp(0, workoutTarget)} προπονήσεις για τον στόχο.';
    } else {
      headline = 'Σταθερή πρόοδος';
      action = 'Συνέχισε με καθαρή τεχνική και μικρές αυξήσεις.';
    }

    return WeeklyTrainingReport(
      workouts: recent.length,
      workoutTarget: workoutTarget,
      sets: setCount,
      minutes: minutes,
      averageRpe: averageRpe,
      painFlags: painFlags,
      headline: headline,
      action: action,
    );
  }

  static bool _containsAny(String value, List<String> terms) =>
      terms.any(value.contains);
}
