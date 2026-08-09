import 'models/fitness_models.dart';
import 'nutrition_goal_engine.dart';

class DailyNutritionSummary {
  const DailyNutritionSummary({
    required this.date,
    required this.calories,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    required this.fiberGrams,
    required this.sodiumMilligrams,
    required this.waterMilliliters,
    required this.adherence,
  });

  final DateTime date;
  final int calories;
  final double proteinGrams;
  final double carbohydrateGrams;
  final double fatGrams;
  final double fiberGrams;
  final double sodiumMilligrams;
  final int waterMilliliters;
  final double adherence;
}

class GroceryItem {
  const GroceryItem({required this.name, required this.presetCount});

  final String name;
  final int presetCount;
}

class NutritionAnalyticsEngine {
  const NutritionAnalyticsEngine._();

  static List<DailyNutritionSummary> weeklySummaries({
    required List<MealEntry> meals,
    required List<HydrationEntry> hydration,
    required DateTime now,
    required NutritionTargets Function(DateTime date) targetsForDate,
  }) {
    final today = _dateOnly(now);
    return [
      for (var offset = 6; offset >= 0; offset--)
        _summaryFor(
          today.subtract(Duration(days: offset)),
          meals,
          hydration,
          targetsForDate,
        ),
    ];
  }

  static double weeklyMacroAdherence(List<DailyNutritionSummary> summaries) {
    final logged = summaries.where((day) => day.calories > 0).toList();
    if (logged.isEmpty) return 0;
    return logged.fold<double>(0, (sum, day) => sum + day.adherence) /
        logged.length;
  }

  static int consistencyStreak({
    required List<MealEntry> meals,
    required DateTime now,
    required NutritionTargets Function(DateTime date) targetsForDate,
  }) {
    var cursor = _dateOnly(now);
    if (!_hasMealOn(cursor, meals)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (_hasMealOn(cursor, meals)) {
      final targets = targetsForDate(cursor);
      final dailyMeals = meals.where((meal) => _sameDay(meal.loggedAt, cursor));
      final calories = dailyMeals.fold<int>(
        0,
        (sum, meal) => sum + meal.calories,
      );
      final protein = dailyMeals.fold<double>(
        0,
        (sum, meal) => sum + meal.proteinGrams,
      );
      final fiber = dailyMeals.fold<double>(
        0,
        (sum, meal) => sum + meal.fiberGrams,
      );
      final consistent =
          calories >= targets.calories * .7 &&
          calories <= targets.calories * 1.15 &&
          protein >= targets.proteinGrams * .75 &&
          fiber >= targets.fiberGrams * .5;
      if (!consistent) break;
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static List<GroceryItem> groceryList(List<MealPreset> presets) {
    final names = <String, ({String display, int count})>{};
    for (final preset in presets) {
      for (final ingredient in preset.ingredients) {
        final display = ingredient.trim();
        if (display.isEmpty) continue;
        final key = display.toLowerCase();
        final existing = names[key];
        names[key] = (
          display: existing?.display ?? display,
          count: (existing?.count ?? 0) + 1,
        );
      }
    }
    final result = [
      for (final entry in names.values)
        GroceryItem(name: entry.display, presetCount: entry.count),
    ]..sort((left, right) => left.name.compareTo(right.name));
    return result;
  }

  static DailyNutritionSummary _summaryFor(
    DateTime date,
    List<MealEntry> meals,
    List<HydrationEntry> hydration,
    NutritionTargets Function(DateTime date) targetsForDate,
  ) {
    final dailyMeals = meals
        .where((meal) => _sameDay(meal.loggedAt, date))
        .toList();
    final targets = targetsForDate(date);
    final calories = dailyMeals.fold<int>(
      0,
      (sum, meal) => sum + meal.calories,
    );
    final protein = dailyMeals.fold<double>(
      0,
      (sum, meal) => sum + meal.proteinGrams,
    );
    final carbohydrates = dailyMeals.fold<double>(
      0,
      (sum, meal) => sum + meal.carbohydrateGrams,
    );
    final fat = dailyMeals.fold<double>(0, (sum, meal) => sum + meal.fatGrams);
    final fiber = dailyMeals.fold<double>(
      0,
      (sum, meal) => sum + meal.fiberGrams,
    );
    final sodium = dailyMeals.fold<double>(
      0,
      (sum, meal) => sum + meal.sodiumMilligrams,
    );
    final water = hydration
        .where((entry) => _sameDay(entry.loggedAt, date))
        .fold<int>(0, (sum, entry) => sum + entry.milliliters);
    final adherence = calories == 0
        ? 0.0
        : [
                _closeness(calories.toDouble(), targets.calories.toDouble()),
                _closeness(protein, targets.proteinGrams),
                _closeness(carbohydrates, targets.carbohydrateGrams),
                _closeness(fat, targets.fatGrams),
              ].fold<double>(0, (sum, value) => sum + value) /
              4;
    return DailyNutritionSummary(
      date: date,
      calories: calories,
      proteinGrams: protein,
      carbohydrateGrams: carbohydrates,
      fatGrams: fat,
      fiberGrams: fiber,
      sodiumMilligrams: sodium,
      waterMilliliters: water,
      adherence: adherence,
    );
  }

  static double _closeness(double value, double target) {
    if (target <= 0) return 0;
    return (1 - (value - target).abs() / target).clamp(0, 1).toDouble();
  }

  static bool _hasMealOn(DateTime date, List<MealEntry> meals) =>
      meals.any((meal) => _sameDay(meal.loggedAt, date));

  static bool _sameDay(DateTime left, DateTime right) =>
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
