import 'models/fitness_models.dart';

enum AchievementKind {
  firstSession,
  ironWeek,
  fiftySets,
  tenSessions,
  recoveryHabit,
  nutritionHabit,
}

class PhoenixAchievement {
  const PhoenixAchievement({
    required this.kind,
    required this.title,
    required this.description,
    required this.current,
    required this.target,
  });

  final AchievementKind kind;
  final String title;
  final String description;
  final int current;
  final int target;

  bool get unlocked => current >= target;
  double get progress => (current / target).clamp(0, 1).toDouble();
}

class AchievementEngine {
  const AchievementEngine._();

  static List<PhoenixAchievement> calculate(
    FitnessData data, {
    required int workoutsThisWeek,
    required int weeklyTarget,
  }) {
    final totalSets = data.logs.fold<int>(
      0,
      (total, workout) => total + workout.sets.length,
    );
    final mealDays = data.meals
        .map(
          (meal) => DateTime(
            meal.loggedAt.year,
            meal.loggedAt.month,
            meal.loggedAt.day,
          ),
        )
        .toSet()
        .length;
    final recoveryDays = data.recoveryChecks
        .map(
          (checkIn) => DateTime(
            checkIn.recordedAt.year,
            checkIn.recordedAt.month,
            checkIn.recordedAt.day,
          ),
        )
        .toSet()
        .length;

    return [
      PhoenixAchievement(
        kind: AchievementKind.firstSession,
        title: 'FIRST FIRE',
        description: 'Ολοκλήρωσε την πρώτη προπόνηση.',
        current: data.logs.length,
        target: 1,
      ),
      PhoenixAchievement(
        kind: AchievementKind.ironWeek,
        title: 'IRON WEEK',
        description: 'Κάλυψε τον εβδομαδιαίο στόχο.',
        current: workoutsThisWeek,
        target: weeklyTarget,
      ),
      PhoenixAchievement(
        kind: AchievementKind.fiftySets,
        title: 'VOLUME 50',
        description: 'Κατάγραψε συνολικά 50 σετ.',
        current: totalSets,
        target: 50,
      ),
      PhoenixAchievement(
        kind: AchievementKind.tenSessions,
        title: 'CONSISTENCY X',
        description: 'Ολοκλήρωσε 10 συνεδρίες.',
        current: data.logs.length,
        target: 10,
      ),
      PhoenixAchievement(
        kind: AchievementKind.recoveryHabit,
        title: 'BODY SIGNAL',
        description: 'Κάνε readiness check-in σε 3 ημέρες.',
        current: recoveryDays,
        target: 3,
      ),
      PhoenixAchievement(
        kind: AchievementKind.nutritionHabit,
        title: 'FUEL LOG',
        description: 'Κατάγραψε διατροφή σε 5 ημέρες.',
        current: mealDays,
        target: 5,
      ),
    ];
  }
}
