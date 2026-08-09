import 'models/fitness_models.dart';
import 'recovery_engine.dart';

class PeriodizationPlan {
  const PeriodizationPlan({
    required this.week,
    required this.label,
    required this.headline,
    required this.detail,
    required this.volumeFactor,
    required this.rirAdjustment,
    required this.loadFactor,
  });

  final int week;
  final String label;
  final String headline;
  final String detail;
  final double volumeFactor;
  final int rirAdjustment;
  final double loadFactor;

  bool get isDeload => week == 4;
}

class DeloadAdvice {
  const DeloadAdvice({required this.recommended, required this.reason});

  final bool recommended;
  final String reason;
}

class PeriodizationEngine {
  const PeriodizationEngine._();

  static PeriodizationPlan currentPlan({
    required DateTime now,
    required List<WorkoutLog> logs,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    DateTime anchor;
    if (logs.isEmpty) {
      anchor = today.subtract(Duration(days: today.weekday - 1));
    } else {
      final oldest = logs.reduce(
        (left, right) =>
            left.completedAt.isBefore(right.completedAt) ? left : right,
      );
      final oldestDay = DateTime(
        oldest.completedAt.year,
        oldest.completedAt.month,
        oldest.completedAt.day,
      );
      anchor = oldestDay.subtract(Duration(days: oldestDay.weekday - 1));
    }
    final weeksSinceAnchor = today.difference(anchor).inDays ~/ 7;
    final week = weeksSinceAnchor % 4 + 1;
    return switch (week) {
      1 => const PeriodizationPlan(
        week: 1,
        label: 'FOUNDATION',
        headline: 'Βάση και τεχνική',
        detail: 'Χτίσε ποιοτικό όγκο με ένα επιπλέον RIR.',
        volumeFactor: .9,
        rirAdjustment: 1,
        loadFactor: .92,
      ),
      2 => const PeriodizationPlan(
        week: 2,
        label: 'BUILD',
        headline: 'Προοδευτική επιβάρυνση',
        detail: 'Κανονικός όγκος και σταθερή αύξηση επίδοσης.',
        volumeFactor: 1,
        rirAdjustment: 0,
        loadFactor: 1,
      ),
      3 => const PeriodizationPlan(
        week: 3,
        label: 'PEAK',
        headline: 'Κορύφωση κύκλου',
        detail: 'Μικρή αύξηση όγκου, χωρίς αποτυχία ή χαλαρή τεχνική.',
        volumeFactor: 1.12,
        rirAdjustment: -1,
        loadFactor: 1.03,
      ),
      _ => const PeriodizationPlan(
        week: 4,
        label: 'DELOAD',
        headline: 'Εβδομάδα αποφόρτισης',
        detail: 'Λιγότερα σετ, χαμηλότερο φορτίο και περισσότερη αποκατάσταση.',
        volumeFactor: .58,
        rirAdjustment: 2,
        loadFactor: .78,
      ),
    };
  }

  static DeloadAdvice deloadAdvice({
    required PeriodizationPlan plan,
    required List<WorkoutLog> logs,
    required List<RecoveryCheckIn> recoveryChecks,
    required DateTime now,
  }) {
    if (plan.isDeload) {
      return const DeloadAdvice(
        recommended: true,
        reason: 'Η τέταρτη εβδομάδα του κύκλου είναι προγραμματισμένο deload.',
      );
    }
    final threshold = now.subtract(const Duration(days: 7));
    final recentRecovery = recoveryChecks
        .where((item) => item.recordedAt.isAfter(threshold))
        .map(RecoveryEngine.evaluate)
        .toList();
    if (recentRecovery.length >= 3) {
      final average =
          recentRecovery.fold<int>(0, (sum, item) => sum + item.score) /
          recentRecovery.length;
      if (average < 52) {
        return const DeloadAdvice(
          recommended: true,
          reason: 'Το readiness παραμένει χαμηλό σε πολλαπλά check-ins.',
        );
      }
    }
    final hardSessions = logs
        .where(
          (log) => log.completedAt.isAfter(threshold) && log.sessionRpe >= 9,
        )
        .length;
    if (hardSessions >= 2) {
      return const DeloadAdvice(
        recommended: true,
        reason: 'Καταγράφηκαν τουλάχιστον δύο συνεδρίες RPE 9–10 σε 7 ημέρες.',
      );
    }
    return const DeloadAdvice(
      recommended: false,
      reason: 'Δεν υπάρχουν ενδείξεις για πρόωρη αποφόρτιση.',
    );
  }

  static WorkoutTemplate adaptWorkout(
    WorkoutTemplate template,
    PeriodizationPlan plan,
  ) {
    final prescriptions = <String, ExercisePrescription>{};
    for (final exercise in template.exercises) {
      final original = template.prescriptionFor(exercise);
      prescriptions[exercise] = ExercisePrescription(
        workingSets: (original.workingSets * plan.volumeFactor).round().clamp(
          1,
          10,
        ),
        minReps: original.minReps,
        maxReps: original.maxReps,
        targetRir: (original.targetRir + plan.rirAdjustment).clamp(1, 5),
        restSeconds: original.restSeconds,
        tempo: original.tempo,
        minHoldSeconds: original.minHoldSeconds,
        maxHoldSeconds: original.maxHoldSeconds,
        note: [
          if (original.note.isNotEmpty) original.note,
          '${plan.label}: περίπου ${(plan.loadFactor * 100).round()}% φορτίο',
        ].join(' • '),
      );
    }
    return template.copyWith(
      coachingCue: '${template.coachingCue} ${plan.label}: ${plan.detail}',
      exercisePrescriptions: prescriptions,
    );
  }
}
