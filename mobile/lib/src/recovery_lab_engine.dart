import 'dart:math' as math;

import 'models/fitness_models.dart';
import 'recovery_engine.dart';

class ReadinessBaseline {
  const ReadinessBaseline({
    required this.averageScore,
    required this.latestScore,
    required this.sampleDays,
  });

  final int averageScore;
  final int latestScore;
  final int sampleDays;

  int get deviation => latestScore - averageScore;
  String get label => sampleDays < 3
      ? 'Χρειάζονται περισσότερα check-ins'
      : deviation >= 8
      ? 'Πάνω από το προσωπικό baseline'
      : deviation <= -8
      ? 'Κάτω από το προσωπικό baseline'
      : 'Κοντά στο προσωπικό baseline';
}

class RecoveryRecommendation {
  const RecoveryRecommendation({
    required this.title,
    required this.detail,
    required this.iconName,
  });

  final String title;
  final String detail;
  final String iconName;
}

class FatigueCell {
  const FatigueCell({required this.date, required this.score});

  final DateTime date;
  final int? score;
}

class RecoveryCorrelation {
  const RecoveryCorrelation({
    required this.sampleSize,
    required this.value,
    required this.label,
  });

  final int sampleSize;
  final double value;
  final String label;
}

class ReturnRamp {
  const ReturnRamp({
    required this.day,
    required this.totalDays,
    required this.loadFactor,
    required this.volumeFactor,
  });

  final int day;
  final int totalDays;
  final double loadFactor;
  final double volumeFactor;

  double get progress => (day / totalDays).clamp(0, 1).toDouble();
}

class RecoveryLabEngine {
  const RecoveryLabEngine._();

  static ReadinessBaseline baseline(List<RecoveryCheckIn> checkIns) {
    if (checkIns.isEmpty) {
      return const ReadinessBaseline(
        averageScore: 0,
        latestScore: 0,
        sampleDays: 0,
      );
    }
    final sorted = [...checkIns]
      ..sort((left, right) => right.recordedAt.compareTo(left.recordedAt));
    final sample = sorted.take(14).toList();
    final scores = sample
        .map((checkIn) => RecoveryEngine.evaluate(checkIn).score)
        .toList();
    return ReadinessBaseline(
      averageScore:
          (scores.reduce((left, right) => left + right) / scores.length)
              .round(),
      latestScore: scores.first,
      sampleDays: scores.length,
    );
  }

  static List<RecoveryRecommendation> recommendations({
    required RecoveryCheckIn? latest,
    required bool isRestDay,
  }) {
    if (latest == null) {
      return const [
        RecoveryRecommendation(
          title: 'Κάνε readiness check-in',
          detail: 'Χρειάζονται δεδομένα για προσωπικές recovery προτάσεις.',
          iconName: 'checkin',
        ),
      ];
    }
    final plan = RecoveryEngine.evaluate(latest);
    return [
      if (latest.sleepHours < 7)
        const RecoveryRecommendation(
          title: 'Sleep extension',
          detail: 'Στόχευσε 30–60′ νωρίτερα στο κρεβάτι απόψε.',
          iconName: 'sleep',
        ),
      if (latest.steps > 0 && latest.steps < 5000)
        const RecoveryRecommendation(
          title: 'Ήπιο recovery walk',
          detail: '20–30′ άνετο περπάτημα για κυκλοφορία χωρίς κόπωση.',
          iconName: 'walk',
        ),
      if (latest.stress >= 4)
        const RecoveryRecommendation(
          title: 'Downshift breathing',
          detail: '5 λεπτά αναπνοή 4″ εισπνοή / 6″ εκπνοή.',
          iconName: 'breathing',
        ),
      if (latest.soreness >= 4)
        const RecoveryRecommendation(
          title: 'Mobility, όχι ένταση',
          detail: 'Ήπιο εύρος κίνησης και καθόλου επιθετικό stretching.',
          iconName: 'mobility',
        ),
      if (isRestDay && plan.score >= 55)
        const RecoveryRecommendation(
          title: 'Active rest',
          detail:
              'Κράτησε σήμερα χαμηλή ένταση και κανονική πρόσληψη πρωτεΐνης.',
          iconName: 'rest',
        ),
      if (plan.score >= 76 && !isRestDay)
        const RecoveryRecommendation(
          title: 'Κανονική προπόνηση',
          detail: 'Το readiness υποστηρίζει το πλάνο, με τεχνικό stop.',
          iconName: 'ready',
        ),
    ];
  }

  static List<FatigueCell> fatigueHeatmap({
    required List<RecoveryCheckIn> checkIns,
    required DateTime now,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    return [
      for (var offset = 27; offset >= 0; offset--)
        _fatigueCell(today.subtract(Duration(days: offset)), checkIns),
    ];
  }

  static RecoveryCorrelation performanceCorrelation({
    required List<RecoveryCheckIn> checkIns,
    required List<WorkoutLog> logs,
  }) {
    final readiness = <double>[];
    final performance = <double>[];
    for (final checkIn in checkIns) {
      final sameDayLogs = logs.where(
        (log) => _sameDay(log.completedAt, checkIn.recordedAt),
      );
      if (sameDayLogs.isEmpty) continue;
      readiness.add(RecoveryEngine.evaluate(checkIn).score.toDouble());
      performance.add(
        sameDayLogs.fold<double>(
          0,
          (sum, log) =>
              sum +
              log.sets.fold<double>(
                0,
                (volume, set) =>
                    volume +
                    (set.volume > 0 ? set.volume : set.reps + set.holdSeconds),
              ),
        ),
      );
    }
    if (readiness.length < 3) {
      return RecoveryCorrelation(
        sampleSize: readiness.length,
        value: 0,
        label: 'Χρειάζονται 3+ ημέρες με check-in και προπόνηση',
      );
    }
    final value = _pearson(readiness, performance);
    final label = value >= .45
        ? 'Το υψηλότερο readiness συνδέεται με καλύτερη απόδοση'
        : value <= -.45
        ? 'Η απόδοση πέφτει όταν πιέζεσαι — έλεγξε κόπωση και όγκο'
        : 'Δεν υπάρχει ακόμη καθαρή συσχέτιση';
    return RecoveryCorrelation(
      sampleSize: readiness.length,
      value: value,
      label: label,
    );
  }

  static ReturnRamp? returnRamp(RecoveryStatus status, DateTime now) {
    final started = status.returnStartedAt;
    if (started == null) return null;
    final day = now.difference(started).inDays + 1;
    if (day > 7) return null;
    final factors = [
      (.60, .55),
      (.65, .60),
      (.72, .70),
      (.80, .78),
      (.87, .86),
      (.93, .93),
      (1.0, 1.0),
    ];
    final index = (day - 1).clamp(0, 6);
    return ReturnRamp(
      day: day.clamp(1, 7),
      totalDays: 7,
      loadFactor: factors[index].$1,
      volumeFactor: factors[index].$2,
    );
  }

  static WorkoutTemplate applyReturnRamp(
    WorkoutTemplate template,
    ReturnRamp? ramp,
  ) {
    if (ramp == null || template.isRecoveryDay) return template;
    return template.copyWith(
      exercisePrescriptions: {
        for (final exercise in template.exercises)
          exercise: _rampPrescription(template.prescriptionFor(exercise), ramp),
      },
      coachingCue:
          '${template.coachingCue} Return ramp ημέρα ${ramp.day}/7: '
          'κανένα grind και κανένα τεστ μέγιστης προσπάθειας.',
    );
  }

  static ExercisePrescription _rampPrescription(
    ExercisePrescription original,
    ReturnRamp ramp,
  ) => ExercisePrescription(
    workingSets: math.max(
      1,
      (original.workingSets * ramp.volumeFactor).round(),
    ),
    minReps: original.minReps,
    maxReps: original.maxReps,
    targetRir: math.max(original.targetRir, ramp.day <= 3 ? 3 : 2),
    restSeconds: original.restSeconds + (ramp.day <= 3 ? 30 : 15),
    tempo: original.tempo,
    minHoldSeconds: original.minHoldSeconds,
    maxHoldSeconds: original.maxHoldSeconds == 0
        ? 0
        : math.max(10, (original.maxHoldSeconds * ramp.volumeFactor).round()),
    note:
        '${original.note}${original.note.isEmpty ? '' : ' • '}'
        'Return ramp ${(ramp.loadFactor * 100).round()}%',
  );

  static FatigueCell _fatigueCell(
    DateTime date,
    List<RecoveryCheckIn> checkIns,
  ) {
    for (final checkIn in checkIns) {
      if (_sameDay(checkIn.recordedAt, date)) {
        return FatigueCell(
          date: date,
          score: RecoveryEngine.evaluate(checkIn).score,
        );
      }
    }
    return FatigueCell(date: date, score: null);
  }

  static double _pearson(List<double> left, List<double> right) {
    final leftMean = left.reduce((a, b) => a + b) / left.length;
    final rightMean = right.reduce((a, b) => a + b) / right.length;
    var numerator = 0.0;
    var leftSquare = 0.0;
    var rightSquare = 0.0;
    for (var index = 0; index < left.length; index++) {
      final x = left[index] - leftMean;
      final y = right[index] - rightMean;
      numerator += x * y;
      leftSquare += x * x;
      rightSquare += y * y;
    }
    if (leftSquare == 0 || rightSquare == 0) return 0;
    return (numerator / math.sqrt(leftSquare * rightSquare))
        .clamp(-1, 1)
        .toDouble();
  }

  static bool _sameDay(DateTime left, DateTime right) =>
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
