import 'models/fitness_models.dart';

class TrainingProgramEngine {
  const TrainingProgramEngine._();

  static Map<String, ExercisePrescription> prescriptionsFor(
    Iterable<String> exercises, {
    required String goal,
    required String experienceLevel,
    required String templateId,
  }) => {
    for (final exercise in exercises)
      exercise: prescriptionFor(
        exercise,
        goal: goal,
        experienceLevel: experienceLevel,
        templateId: templateId,
      ),
  };

  static ExercisePrescription prescriptionFor(
    String exercise, {
    required String goal,
    required String experienceLevel,
    required String templateId,
  }) {
    final name = exercise.toLowerCase();
    final isBeginner = experienceLevel == 'Αρχάριος';
    final isAdvanced = experienceLevel == 'Προχωρημένος';
    final isStrengthGoal = goal == 'Δύναμη';
    final isMuscleGoal = goal == 'Μυϊκή ανάπτυξη';

    if (templateId == 'iron-engine') {
      return const ExercisePrescription(
        workingSets: 4,
        minReps: 0,
        maxReps: 0,
        targetRir: 2,
        restSeconds: 20,
        tempo: 'σταθερό',
        minHoldSeconds: 40,
        maxHoldSeconds: 40,
        note: 'RPE 7–8 • καθαρή τεχνική σε όλους τους γύρους',
      );
    }

    if (name.contains('handstand') ||
        name.contains('l-sit') ||
        name.contains('hollow') ||
        name.contains('arch body hold')) {
      return ExercisePrescription(
        workingSets: isBeginner ? 3 : 4,
        minReps: 0,
        maxReps: 0,
        targetRir: 3,
        restSeconds: 90,
        tempo: 'ισομετρικό',
        minHoldSeconds: isBeginner ? 10 : 15,
        maxHoldSeconds: isBeginner ? 20 : 30,
        note: 'Ποιοτικές προσπάθειες • ποτέ μέχρι τεχνική αποτυχία',
      );
    }

    if (name.contains('farmer') ||
        name.contains('suitcase') ||
        name.contains('φορτωμένο σακίδιο')) {
      return const ExercisePrescription(
        workingSets: 3,
        minReps: 0,
        maxReps: 0,
        targetRir: 2,
        restSeconds: 90,
        tempo: 'σταθερό βάδισμα',
        minHoldSeconds: 30,
        maxHoldSeconds: 45,
        note: 'Χρόνος ανά διαδρομή • κορμός ψηλά',
      );
    }

    if (name.contains('scapular')) {
      return const ExercisePrescription(
        workingSets: 4,
        minReps: 5,
        maxReps: 8,
        targetRir: 3,
        restSeconds: 75,
        tempo: '2–1–2',
        note: 'Ίσιοι αγκώνες • μικρό και ελεγχόμενο εύρος',
      );
    }

    if (_isUnilateral(name)) {
      return ExercisePrescription(
        workingSets: 3,
        minReps: isStrengthGoal ? 6 : 8,
        maxReps: isStrengthGoal ? 10 : 12,
        targetRir: 2,
        restSeconds: isStrengthGoal ? 120 : 90,
        tempo: '3–1–1',
        note: 'Επαναλήψεις ανά πλευρά',
      );
    }

    if (_isHeavyCompound(name)) {
      if (isStrengthGoal) {
        return ExercisePrescription(
          workingSets: isBeginner ? 2 : 3,
          minReps: 5,
          maxReps: 8,
          targetRir: 2,
          restSeconds: 150,
          tempo: '2–1–1',
          note: 'Αύξησε φορτίο μόνο όταν όλα τα σετ μένουν στο εύρος',
        );
      }
      return ExercisePrescription(
        workingSets: isAdvanced && isMuscleGoal ? 4 : 3,
        minReps: 6,
        maxReps: 10,
        targetRir: 2,
        restSeconds: 120,
        tempo: '3–1–1',
        note: 'Πλήρες ελεγχόμενο εύρος',
      );
    }

    if (_isBodyweightCompound(name)) {
      return ExercisePrescription(
        workingSets: isAdvanced ? 4 : 3,
        minReps: isStrengthGoal ? 5 : 6,
        maxReps: isStrengthGoal ? 8 : 10,
        targetRir: 2,
        restSeconds: isAdvanced ? 120 : 90,
        tempo: '3–1–1',
        note: 'Αυστηρές επαναλήψεις • χωρίς ορμή',
      );
    }

    if (_isCore(name)) {
      return const ExercisePrescription(
        workingSets: 3,
        minReps: 8,
        maxReps: 12,
        targetRir: 2,
        restSeconds: 60,
        tempo: '2–1–2',
        note: 'Σταμάτα πριν χαθεί η θέση της μέσης',
      );
    }

    if (_isAccessory(name)) {
      return ExercisePrescription(
        workingSets: isMuscleGoal ? 3 : 2,
        minReps: 10,
        maxReps: 15,
        targetRir: 2,
        restSeconds: 75,
        tempo: '2–1–2',
        note: 'Έλεγχος πάνω από φορτίο',
      );
    }

    return const ExercisePrescription(
      workingSets: 3,
      minReps: 8,
      maxReps: 12,
      targetRir: 2,
      restSeconds: 90,
      tempo: '2–1–2',
      note: 'Τεχνικό stop πριν χαλάσει η κίνηση',
    );
  }

  static bool _isHeavyCompound(String name) =>
      name.contains('trap-bar') ||
      name.contains('front squat') ||
      name.contains('goblet squat') ||
      name.contains('καθίσματα') ||
      name.contains('ρουμανικ') ||
      name.contains('πιέσεις στήθους') ||
      name.contains('πιέσεις πάγκου') ||
      name.contains('κωπηλατική με στήριξη') ||
      name.contains('landmine') ||
      name.contains('έλξεις τροχαλίας') ||
      name.contains('έλξεις με βάρος');

  static bool _isBodyweightCompound(String name) =>
      name.contains('κάμψεις') ||
      name.contains('push-up') ||
      name.contains('pike') ||
      name.contains('αυστηρές έλξεις') ||
      name.contains('υποβοηθούμενες έλξεις') ||
      name.contains('βυθίσεις') ||
      name.contains('pistol');

  static bool _isUnilateral(String name) =>
      name.contains('bulgarian') ||
      name.contains('βουλγαρ') ||
      name.contains('προβολ') ||
      name.contains('step-up') ||
      name.contains('μονόχειρη κωπηλατική');

  static bool _isCore(String name) =>
      name.contains('dead bug') ||
      name.contains('pallof') ||
      name.contains('hanging knee') ||
      name.contains('hanging leg');

  static bool _isAccessory(String name) =>
      name.contains('face pull') ||
      name.contains('λάστιχο') ||
      name.contains('γάμπ') ||
      name.contains('hip thrust') ||
      name.contains('γέφυρ') ||
      name.contains('εκτάσεις') ||
      name.contains('κάμψεις δικεφάλων');
}
