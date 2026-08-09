import 'models/fitness_models.dart';
import 'training_schedule.dart';

enum CoachPriority { critical, high, normal, optional }

class CoachAction {
  const CoachAction({
    required this.id,
    required this.title,
    required this.detail,
    required this.priority,
    required this.iconKey,
    this.route = '',
  });

  final String id;
  final String title;
  final String detail;
  final CoachPriority priority;
  final String iconKey;
  final String route;
}

class DailyCoachPlan {
  const DailyCoachPlan({
    required this.score,
    required this.headline,
    required this.actions,
  });

  final int score;
  final String headline;
  final List<CoachAction> actions;
}

class PlateauInsight {
  const PlateauInsight({
    required this.exerciseName,
    required this.sessions,
    required this.changePercent,
    required this.recommendation,
  });

  final String exerciseName;
  final int sessions;
  final double changePercent;
  final String recommendation;
}

class MissedWorkoutSuggestion {
  const MissedWorkoutSuggestion({
    required this.workout,
    required this.suggestedDate,
    required this.reason,
  });

  final ScheduledWorkout workout;
  final DateTime suggestedDate;
  final String reason;
}

class TechniqueChecklist {
  const TechniqueChecklist({
    required this.exerciseName,
    required this.items,
    required this.stopRule,
  });

  final String exerciseName;
  final List<String> items;
  final String stopRule;
}

class SetQualityScore {
  const SetQualityScore({
    required this.score,
    required this.grade,
    required this.feedback,
  });

  final int score;
  final String grade;
  final List<String> feedback;
}

class TrainingPhase {
  const TrainingPhase({
    required this.weekStart,
    required this.weekEnd,
    required this.name,
    required this.focus,
    required this.volumePercent,
    required this.intensityPercent,
    required this.isCurrent,
  });

  final int weekStart;
  final int weekEnd;
  final String name;
  final String focus;
  final int volumePercent;
  final int intensityPercent;
  final bool isCurrent;
}

class DeterministicCoachEngine {
  const DeterministicCoachEngine._();

  static DailyCoachPlan dailyPlan({
    required FitnessData data,
    required TrainingSchedule schedule,
    required int recoveryScore,
    required int caloriesToday,
    required int calorieTarget,
    required double proteinToday,
    required double proteinTarget,
    required int hydrationToday,
    required int hydrationTarget,
    required DateTime now,
  }) {
    final actions = <CoachAction>[];
    final next = schedule.nextEntry(now);
    if (next != null && next.isOverdue(now)) {
      actions.add(
        CoachAction(
          id: 'reschedule',
          title: 'Μετέφερε τη χαμένη προπόνηση',
          detail:
              '${next.template.name} έμεινε πίσω. Μετάφερέ την στην επόμενη διαθέσιμη ημέρα.',
          priority: CoachPriority.high,
          iconKey: 'calendar',
          route: 'coach',
        ),
      );
    } else if (next != null && next.isToday(now)) {
      actions.add(
        CoachAction(
          id: 'workout',
          title: recoveryScore > 0 && recoveryScore < 55
              ? 'Εκτέλεσε την recovery εκδοχή'
              : 'Εκτέλεσε τη σημερινή αποστολή',
          detail:
              '${next.template.name} • ${next.template.exercises.length} ασκήσεις.',
          priority: CoachPriority.high,
          iconKey: 'workout',
          route: 'workout',
        ),
      );
    }
    if (recoveryScore == 0) {
      actions.add(
        const CoachAction(
          id: 'check-in',
          title: 'Κάνε readiness check-in',
          detail: '30″ για προσαρμογή όγκου, RIR και φορτίου.',
          priority: CoachPriority.high,
          iconKey: 'recovery',
          route: 'recovery',
        ),
      );
    } else if (recoveryScore < 55) {
      actions.add(
        const CoachAction(
          id: 'recovery',
          title: 'Προστάτευσε την αποκατάσταση',
          detail: 'Χαμηλό readiness: κράτησε δύο RIR και απόφυγε AMRAP.',
          priority: CoachPriority.critical,
          iconKey: 'recovery',
          route: 'recovery',
        ),
      );
    }
    if (hydrationToday < hydrationTarget * .55) {
      actions.add(
        CoachAction(
          id: 'water',
          title: 'Κλείσε το hydration gap',
          detail: '$hydrationToday/$hydrationTarget ml μέχρι τώρα.',
          priority: CoachPriority.normal,
          iconKey: 'water',
          route: 'nutrition',
        ),
      );
    }
    if (proteinToday < proteinTarget * .7) {
      actions.add(
        CoachAction(
          id: 'protein',
          title: 'Προτεραιότητα στην πρωτεΐνη',
          detail:
              '${proteinToday.toStringAsFixed(0)}/${proteinTarget.toStringAsFixed(0)} g σήμερα.',
          priority: CoachPriority.normal,
          iconKey: 'nutrition',
          route: 'nutrition',
        ),
      );
    }
    if (caloriesToday > calorieTarget * 1.12) {
      actions.add(
        const CoachAction(
          id: 'calories',
          title: 'Οι θερμίδες πέρασαν το εύρος',
          detail: 'Συνέχισε με νερό και ένα ελαφρύ, πρωτεϊνικό γεύμα.',
          priority: CoachPriority.normal,
          iconKey: 'nutrition',
          route: 'nutrition',
        ),
      );
    }
    if (actions.isEmpty) {
      actions.add(
        const CoachAction(
          id: 'steady',
          title: 'Η ημέρα είναι εντός πλάνου',
          detail: 'Συνέχισε τη βασική ρουτίνα χωρίς περιττές αλλαγές.',
          priority: CoachPriority.optional,
          iconKey: 'done',
        ),
      );
    }
    actions.sort(
      (left, right) => left.priority.index.compareTo(right.priority.index),
    );
    final deductions = actions.fold<int>(
      0,
      (sum, action) =>
          sum +
          switch (action.priority) {
            CoachPriority.critical => 22,
            CoachPriority.high => 12,
            CoachPriority.normal => 6,
            CoachPriority.optional => 0,
          },
    );
    final score = (100 - deductions).clamp(0, 100);
    return DailyCoachPlan(
      score: score,
      headline: score >= 85
          ? 'Καθαρή πορεία'
          : score >= 65
          ? 'Μερικές στοχευμένες κινήσεις'
          : 'Προτεραιότητα στον έλεγχο',
      actions: actions.take(5).toList(),
    );
  }

  static List<PlateauInsight> plateaus(List<WorkoutLog> logs) {
    final byExercise = <String, List<_PerformancePoint>>{};
    final ordered = logs.toList()
      ..sort((left, right) => left.completedAt.compareTo(right.completedAt));
    for (final log in ordered) {
      final bestByExercise = <String, double>{};
      for (final set in log.sets) {
        if (set.reps <= 0 || set.weightKilograms <= 0) continue;
        final e1rm = set.weightKilograms * (1 + set.reps / 30);
        final previous = bestByExercise[set.exerciseName] ?? 0;
        if (e1rm > previous) bestByExercise[set.exerciseName] = e1rm;
      }
      for (final entry in bestByExercise.entries) {
        byExercise
            .putIfAbsent(entry.key, () => [])
            .add(_PerformancePoint(log.completedAt, entry.value));
      }
    }
    final insights = <PlateauInsight>[];
    for (final entry in byExercise.entries) {
      final points = entry.value;
      if (points.length < 4) continue;
      final recent = points.sublist(points.length - 4);
      final baseline = recent.first.value;
      final bestLater = recent
          .skip(1)
          .map((item) => item.value)
          .reduce((left, right) => left > right ? left : right);
      final change = baseline <= 0
          ? 0.0
          : (bestLater - baseline) / baseline * 100;
      if (change < 1.5) {
        insights.add(
          PlateauInsight(
            exerciseName: entry.key,
            sessions: recent.length,
            changePercent: change,
            recommendation:
                'Μείωσε 5–8% το φορτίο για μία τεχνική εβδομάδα και ξαναχτίσε με 2 RIR.',
          ),
        );
      }
    }
    insights.sort(
      (left, right) => left.changePercent.compareTo(right.changePercent),
    );
    return insights;
  }

  static MissedWorkoutSuggestion? missedWorkout(
    TrainingSchedule schedule,
    DateTime now,
  ) {
    ScheduledWorkout? missed;
    for (final entry in schedule.entries) {
      if (entry.isOverdue(now)) {
        missed = entry;
        break;
      }
    }
    if (missed == null) return null;
    var candidate = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    for (var attempt = 0; attempt < 7; attempt++) {
      final occupied = schedule.entries.any(
        (entry) =>
            entry.date.year == candidate.year &&
            entry.date.month == candidate.month &&
            entry.date.day == candidate.day &&
            !entry.isCompleted,
      );
      if (!occupied) {
        return MissedWorkoutSuggestion(
          workout: missed,
          suggestedDate: candidate,
          reason: 'Η πρώτη ημέρα χωρίς άλλη προγραμματισμένη συνεδρία.',
        );
      }
      candidate = candidate.add(const Duration(days: 1));
    }
    return MissedWorkoutSuggestion(
      workout: missed,
      suggestedDate: candidate,
      reason: 'Μεταφορά μετά το τρέχον εβδομαδιαίο πλάνο.',
    );
  }

  static TechniqueChecklist techniqueFor(String exercise) {
    final name = exercise.toLowerCase();
    if (_containsAny(name, ['squat', 'κάθισμα', 'προβολ', 'bulgarian'])) {
      return TechniqueChecklist(
        exerciseName: exercise,
        items: const [
          'Τρίποδο πέλμα σταθερό στο έδαφος',
          'Γόνατο ακολουθεί τη γραμμή των δαχτύλων',
          'Κορμός σφιχτός χωρίς κατάρρευση στη βάση',
        ],
        stopRule:
            'Stop αν εμφανιστεί οξύς πόνος ή χαθεί ο έλεγχος του γονάτου.',
      );
    }
    if (_containsAny(name, ['deadlift', 'άρσεις', 'ρουμανικ', 'hinge'])) {
      return TechniqueChecklist(
        exerciseName: exercise,
        items: const [
          'Ουδέτερη μέση και πλευρά κλειδωμένα',
          'Το φορτίο μένει κοντά στο σώμα',
          'Η κίνηση ξεκινά από ισχίο, όχι από τη μέση',
        ],
        stopRule: 'Stop πριν στρογγυλέψει η μέση ή χαθεί η πίεση στα πέλματα.',
      );
    }
    if (_containsAny(name, ['πιέσεις', 'push', 'press', 'κάμψεις'])) {
      return TechniqueChecklist(
        exerciseName: exercise,
        items: const [
          'Ωμοπλάτες σταθερές και ώμοι μακριά από τα αυτιά',
          'Καρποί ουδέτεροι πάνω από τον πήχη',
          'Ελεγχόμενη κάθοδος χωρίς αναπήδηση',
        ],
        stopRule: 'Stop αν ο ώμος πονά ή η μέση υπερεκτείνεται.',
      );
    }
    if (_containsAny(name, ['έλξεις', 'pull', 'κωπηλατική', 'row'])) {
      return TechniqueChecklist(
        exerciseName: exercise,
        items: const [
          'Ξεκίνα με έλεγχο της ωμοπλάτης',
          'Αγκώνες κινούνται χωρίς τίναγμα του κορμού',
          'Πλήρες ανώδυνο εύρος και αργή επιστροφή',
        ],
        stopRule: 'Stop όταν χρειάζεται κλέψιμο ή χάνεται η θέση του ώμου.',
      );
    }
    return TechniqueChecklist(
      exerciseName: exercise,
      items: const [
        'Σταθερή αρχική θέση',
        'Ελεγχόμενο πλήρες εύρος χωρίς πόνο',
        'Ίδιος ρυθμός από την πρώτη ως την τελευταία επανάληψη',
      ],
      stopRule: 'Τεχνικό stop πριν από αποτυχία ή απώλεια ελέγχου.',
    );
  }

  static SetQualityScore setQuality({
    required ExerciseSetLog set,
    required ExercisePrescription prescription,
  }) {
    var score = 100;
    final feedback = <String>[];
    if (!prescription.isTimed &&
        (set.reps < prescription.minReps || set.reps > prescription.maxReps)) {
      score -= 14;
      feedback.add('Οι επαναλήψεις ήταν εκτός στόχου.');
    }
    if (set.rir < prescription.targetRir - 1) {
      score -= 18;
      feedback.add('Το σετ πήγε πιο κοντά στην αποτυχία από το πλάνο.');
    } else if (set.rir > prescription.targetRir + 2) {
      score -= 8;
      feedback.add('Υπήρχε πολύ μεγαλύτερο απόθεμα από τον στόχο.');
    }
    if (set.setRpe >= 10) {
      score -= 15;
      feedback.add('RPE 10: κράτησέ το μόνο για προγραμματισμένο test.');
    }
    if (set.velocityNote == 'grinding') {
      score -= 14;
      feedback.add('Grinding επανάληψη: σταμάτα νωρίτερα στο επόμενο σετ.');
    } else if (set.velocityNote == 'explosive' ||
        set.velocityNote == 'steady') {
      score += 2;
    }
    final checklist = techniqueFor(set.exerciseName);
    if (set.techniqueChecks.length < checklist.items.length) {
      score -= (checklist.items.length - set.techniqueChecks.length) * 5;
      feedback.add('Δεν επιβεβαιώθηκε ολόκληρο το τεχνικό checklist.');
    }
    score = score.clamp(0, 100);
    if (feedback.isEmpty) feedback.add('Το σετ έμεινε ακριβώς μέσα στο πλάνο.');
    return SetQualityScore(
      score: score,
      grade: score >= 90
          ? 'ELITE'
          : score >= 78
          ? 'SOLID'
          : score >= 60
          ? 'CONTROL'
          : 'RESET',
      feedback: feedback,
    );
  }

  static List<TrainingPhase> phaseRoadmap({
    required UserProfile? profile,
    required List<WorkoutLog> logs,
    required DateTime now,
  }) {
    final currentWeek = ((logs.length ~/ (profile?.daysPerWeek ?? 3)) % 16) + 1;
    final goal = profile?.goal ?? 'Γενική φυσική κατάσταση';
    final phases = <TrainingPhase>[
      const TrainingPhase(
        weekStart: 1,
        weekEnd: 4,
        name: 'FOUNDATION',
        focus: 'Τεχνική, σταθερότητα και ανθεκτικότητα ιστών',
        volumePercent: 85,
        intensityPercent: 70,
        isCurrent: false,
      ),
      TrainingPhase(
        weekStart: 5,
        weekEnd: 8,
        name: 'BUILD',
        focus: goal == 'Απώλεια λίπους'
            ? 'Διατήρηση δύναμης και πυκνότητα προπόνησης'
            : 'Προοδευτική επιβάρυνση και ποιοτικός όγκος',
        volumePercent: 100,
        intensityPercent: 82,
        isCurrent: false,
      ),
      const TrainingPhase(
        weekStart: 9,
        weekEnd: 12,
        name: 'INTENSIFY',
        focus: 'Βαρύτερα ποιοτικά σετ χωρίς τεχνική αποτυχία',
        volumePercent: 88,
        intensityPercent: 92,
        isCurrent: false,
      ),
      const TrainingPhase(
        weekStart: 13,
        weekEnd: 16,
        name: 'REALIZE & RESET',
        focus: 'Ασφαλές test, consolidation και deload',
        volumePercent: 65,
        intensityPercent: 78,
        isCurrent: false,
      ),
    ];
    return [
      for (final phase in phases)
        TrainingPhase(
          weekStart: phase.weekStart,
          weekEnd: phase.weekEnd,
          name: phase.name,
          focus: phase.focus,
          volumePercent: phase.volumePercent,
          intensityPercent: phase.intensityPercent,
          isCurrent:
              currentWeek >= phase.weekStart && currentWeek <= phase.weekEnd,
        ),
    ];
  }

  static bool _containsAny(String input, Iterable<String> values) =>
      values.any(input.contains);
}

class _PerformancePoint {
  const _PerformancePoint(this.date, this.value);

  final DateTime date;
  final double value;
}
