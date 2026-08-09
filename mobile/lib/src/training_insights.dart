import 'models/fitness_models.dart';

class ProgressionSuggestion {
  const ProgressionSuggestion({
    required this.headline,
    required this.detail,
    required this.targetReps,
    required this.targetWeightKilograms,
    required this.targetHoldSeconds,
  });

  final String headline;
  final String detail;
  final int targetReps;
  final double targetWeightKilograms;
  final int targetHoldSeconds;
}

class ExerciseRecord {
  const ExerciseRecord({
    required this.exerciseName,
    required this.bestEstimatedOneRepMax,
    required this.maxWeightKilograms,
    required this.maxReps,
    required this.maxHoldSeconds,
  });

  final String exerciseName;
  final double bestEstimatedOneRepMax;
  final double maxWeightKilograms;
  final int maxReps;
  final int maxHoldSeconds;

  bool get hasWeightedRecord => maxWeightKilograms > 0;
  bool get hasHoldRecord => maxHoldSeconds > 0;
}

class TrainingInsights {
  const TrainingInsights._();

  static ProgressionSuggestion suggestionFor(
    String exerciseName,
    Iterable<ExerciseSetLog> sets, {
    ExercisePrescription? prescription,
  }) {
    final matching =
        sets.where((set) => set.exerciseName == exerciseName).toList()
          ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    if (matching.isEmpty) {
      final targetReps = prescription?.isTimed == true
          ? 0
          : prescription?.minReps ?? 8;
      final targetHold = prescription?.isTimed == true
          ? prescription!.minHoldSeconds
          : 0;
      return ProgressionSuggestion(
        headline: 'Καθιέρωσε baseline',
        detail:
            'Ξεκίνα στο κάτω όριο και κράτησε RIR '
            '${prescription?.targetRir ?? 2}.',
        targetReps: targetReps,
        targetWeightKilograms: 0,
        targetHoldSeconds: targetHold,
      );
    }

    final last = matching.first;
    final nextVariant = _nextCalisthenicsVariant(exerciseName);
    if (last.holdSeconds > 0) {
      final maxHold = prescription?.maxHoldSeconds ?? 30;
      final minHold = prescription?.minHoldSeconds ?? 10;
      final targetRir = prescription?.targetRir ?? 2;
      if (last.holdSeconds >= maxHold &&
          last.rir >= targetRir &&
          nextVariant != null) {
        return ProgressionSuggestion(
          headline: 'Ξεκλείδωσε επόμενη παραλλαγή',
          detail: 'Δοκίμασε $nextVariant με καθαρή τεχνική.',
          targetReps: 0,
          targetWeightKilograms: 0,
          targetHoldSeconds: minHold,
        );
      }
      final increase = last.rir >= targetRir ? 5 : 2;
      final nextHold = (last.holdSeconds + increase)
          .clamp(minHold, maxHold)
          .toInt();
      return ProgressionSuggestion(
        headline: nextHold > last.holdSeconds
            ? '+${nextHold - last.holdSeconds} δευτερόλεπτα'
            : 'Σταθεροποίηση χρόνου',
        detail: nextHold > last.holdSeconds
            ? 'Κράτησε την ίδια παραλλαγή χωρίς απώλεια θέσης.'
            : 'Κράτησε τον χρόνο και βελτίωσε την ποιότητα.',
        targetReps: 0,
        targetWeightKilograms: last.weightKilograms,
        targetHoldSeconds: nextHold,
      );
    }

    if (last.weightKilograms > 0) {
      final minReps = prescription?.minReps ?? 6;
      final maxReps = prescription?.maxReps ?? 8;
      final targetRir = prescription?.targetRir ?? 2;
      if (last.reps >= maxReps && last.rir >= targetRir) {
        final targetWeight = _roundToHalf(last.weightKilograms + 2.5);
        return ProgressionSuggestion(
          headline: '+2,5 kg',
          detail: 'Έπιασες το πάνω όριο με επαρκές απόθεμα.',
          targetReps: minReps,
          targetWeightKilograms: targetWeight,
          targetHoldSeconds: 0,
        );
      }
      if (last.rir == 0) {
        return ProgressionSuggestion(
          headline: 'Επανάληψη φορτίου',
          detail: 'Σταθεροποίησε την επίδοση πριν αυξήσεις κιλά.',
          targetReps: last.reps,
          targetWeightKilograms: last.weightKilograms,
          targetHoldSeconds: 0,
        );
      }
      return ProgressionSuggestion(
        headline: '+1 επανάληψη',
        detail: 'Χτίσε το εύρος πριν αυξήσεις ξανά φορτίο.',
        targetReps: (last.reps + 1).clamp(minReps, maxReps).toInt(),
        targetWeightKilograms: last.weightKilograms,
        targetHoldSeconds: 0,
      );
    }

    final minReps = prescription?.minReps ?? 6;
    final maxReps = prescription?.maxReps ?? 12;
    final targetRir = prescription?.targetRir ?? 2;
    if (last.reps >= maxReps && last.rir >= targetRir && nextVariant != null) {
      return ProgressionSuggestion(
        headline: 'Επόμενη παραλλαγή',
        detail: 'Δοκίμασε $nextVariant στο κάτω όριο του εύρους.',
        targetReps: minReps,
        targetWeightKilograms: 0,
        targetHoldSeconds: 0,
      );
    }
    final targetReps = last.rir >= 1 ? last.reps + 1 : last.reps;
    return ProgressionSuggestion(
      headline: last.rir >= 1 ? '+1 επανάληψη' : 'Σταθεροποίηση',
      detail: last.rir >= 1
          ? 'Διατήρησε την ίδια παραλλαγή και τεχνική.'
          : 'Επανάλαβε την επίδοση με καλύτερο έλεγχο.',
      targetReps: targetReps.clamp(minReps, maxReps).toInt(),
      targetWeightKilograms: 0,
      targetHoldSeconds: 0,
    );
  }

  static List<ExerciseRecord> recordsFrom(Iterable<WorkoutLog> logs) {
    final grouped = <String, List<ExerciseSetLog>>{};
    for (final log in logs) {
      for (final set in log.sets) {
        grouped.putIfAbsent(set.exerciseName, () => []).add(set);
      }
    }
    final records =
        grouped.entries.map((entry) {
          var bestOneRepMax = 0.0;
          var maxWeight = 0.0;
          var maxReps = 0;
          var maxHold = 0;
          for (final set in entry.value) {
            if (set.weightKilograms > maxWeight) {
              maxWeight = set.weightKilograms;
            }
            if (set.reps > maxReps) {
              maxReps = set.reps;
            }
            if (set.holdSeconds > maxHold) {
              maxHold = set.holdSeconds;
            }
            if (set.weightKilograms > 0 && set.reps > 0) {
              final estimate = set.weightKilograms * (1 + set.reps / 30);
              if (estimate > bestOneRepMax) {
                bestOneRepMax = estimate;
              }
            }
          }
          return ExerciseRecord(
            exerciseName: entry.key,
            bestEstimatedOneRepMax: bestOneRepMax,
            maxWeightKilograms: maxWeight,
            maxReps: maxReps,
            maxHoldSeconds: maxHold,
          );
        }).toList()..sort((a, b) {
          final aScore =
              a.bestEstimatedOneRepMax + a.maxReps + a.maxHoldSeconds;
          final bScore =
              b.bestEstimatedOneRepMax + b.maxReps + b.maxHoldSeconds;
          return bScore.compareTo(aScore);
        });
    return records;
  }

  static double _roundToHalf(double value) => (value * 2).round() / 2;

  static String? _nextCalisthenicsVariant(String exerciseName) {
    const progressions = {
      'Κάμψεις σε υπερυψωμένη επιφάνεια': 'κανονικές κάμψεις',
      'Κάμψεις': 'archer push-ups',
      'Archer push-ups': 'μονόχειρες κάμψεις progression',
      'Ανάστροφες έλξεις': 'έλξεις με λάστιχο ή αρνητικές',
      'Έλξεις': 'έλξεις με πρόσθετο βάρος',
      'Handstand στον τοίχο': 'ελεύθερο handstand',
      'Tuck L-sit': 'L-sit με ένα πόδι',
      'Hollow body hold': 'hollow rocks',
      'Pistol squat progression': 'πλήρες pistol squat',
    };
    return progressions[exerciseName];
  }
}
