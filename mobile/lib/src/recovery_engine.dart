import 'models/fitness_models.dart';

enum RecoveryMode { ready, controlled, recovery }

class RecoveryPlan {
  const RecoveryPlan({
    required this.score,
    required this.mode,
    required this.label,
    required this.headline,
    required this.detail,
    required this.setReduction,
    required this.rirIncrease,
    required this.restBonusSeconds,
    required this.loadFactor,
  });

  final int score;
  final RecoveryMode mode;
  final String label;
  final String headline;
  final String detail;
  final int setReduction;
  final int rirIncrease;
  final int restBonusSeconds;
  final double loadFactor;

  bool get adjustsWorkout => mode != RecoveryMode.ready;
}

class RecoveryEngine {
  const RecoveryEngine._();

  static RecoveryPlan evaluate(RecoveryCheckIn checkIn) {
    final sleepScore = (((checkIn.sleepHours - 4) / 4) * 100).clamp(0, 100);
    final energyScore = checkIn.energy * 20;
    final sorenessScore = (6 - checkIn.soreness) * 20;
    final stressScore = (6 - checkIn.stress) * 20;
    final score =
        (sleepScore * .35 +
                energyScore * .30 +
                sorenessScore * .20 +
                stressScore * .15)
            .round()
            .clamp(0, 100);

    if (score >= 76) {
      return RecoveryPlan(
        score: score,
        mode: RecoveryMode.ready,
        label: 'GREEN',
        headline: 'Έτοιμος για πλήρη ένταση',
        detail:
            'Κράτησε το κανονικό πλάνο και άφησε την τεχνική να ορίσει το όριο.',
        setReduction: 0,
        rirIncrease: 0,
        restBonusSeconds: 0,
        loadFactor: 1,
      );
    }
    if (score >= 55) {
      return RecoveryPlan(
        score: score,
        mode: RecoveryMode.controlled,
        label: 'AMBER',
        headline: 'Ελεγχόμενη ένταση σήμερα',
        detail:
            'Ένα λιγότερο σετ, περισσότερο απόθεμα και καθόλου κυνήγι ρεκόρ.',
        setReduction: 1,
        rirIncrease: 1,
        restBonusSeconds: 15,
        loadFactor: .90,
      );
    }
    return RecoveryPlan(
      score: score,
      mode: RecoveryMode.recovery,
      label: 'RED',
      headline: 'Προτεραιότητα στην αποκατάσταση',
      detail:
          'Μείωσε όγκο και φορτίο. Αν υπάρχει πόνος, ζάλη ή αδιαθεσία, σταμάτα.',
      setReduction: 2,
      rirIncrease: 2,
      restBonusSeconds: 30,
      loadFactor: .75,
    );
  }

  static WorkoutTemplate adaptWorkout(
    WorkoutTemplate template,
    RecoveryCheckIn checkIn,
  ) {
    final plan = evaluate(checkIn);
    if (!plan.adjustsWorkout) return template;

    final adaptedPrescriptions = <String, ExercisePrescription>{};
    for (final exercise in template.exercises) {
      final original = template.prescriptionFor(exercise);
      adaptedPrescriptions[exercise] = ExercisePrescription(
        workingSets: (original.workingSets - plan.setReduction).clamp(1, 10),
        minReps: original.minReps,
        maxReps: original.maxReps,
        targetRir: (original.targetRir + plan.rirIncrease).clamp(0, 5),
        restSeconds: original.restSeconds + plan.restBonusSeconds,
        tempo: original.tempo,
        minHoldSeconds: original.minHoldSeconds,
        maxHoldSeconds:
            plan.mode == RecoveryMode.recovery && original.maxHoldSeconds > 0
            ? (original.maxHoldSeconds * .8).round()
            : original.maxHoldSeconds,
        note: [
          if (original.note.isNotEmpty) original.note,
          'Recovery ${plan.label}: περίπου ${(plan.loadFactor * 100).round()}% φορτίο',
        ].join(' • '),
      );
    }

    return template.copyWith(
      coachingCue: '${template.coachingCue} ${plan.headline}: ${plan.detail}',
      exercisePrescriptions: adaptedPrescriptions,
    );
  }
}
