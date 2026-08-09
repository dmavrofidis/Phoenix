import 'dart:math' as math;

import 'models/fitness_models.dart';

class IngredientDefinition {
  const IngredientDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.caloriesPer100Grams,
    required this.proteinPer100Grams,
    required this.carbohydratesPer100Grams,
    required this.fatPer100Grams,
    required this.fiberPer100Grams,
    required this.sodiumPer100Grams,
    required this.referenceCostPer100Grams,
    required this.defaultShelfDays,
  });

  final String id;
  final String name;
  final String category;
  final double caloriesPer100Grams;
  final double proteinPer100Grams;
  final double carbohydratesPer100Grams;
  final double fatPer100Grams;
  final double fiberPer100Grams;
  final double sodiumPer100Grams;
  final double referenceCostPer100Grams;
  final int defaultShelfDays;
}

class IngredientPortion {
  const IngredientPortion({required this.ingredientId, required this.grams});

  final String ingredientId;
  final double grams;
}

class RecipeNutrition {
  const RecipeNutrition({
    required this.calories,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    required this.fiberGrams,
    required this.sodiumMilligrams,
    required this.totalWeightGrams,
  });

  final int calories;
  final double proteinGrams;
  final double carbohydrateGrams;
  final double fatGrams;
  final double fiberGrams;
  final double sodiumMilligrams;
  final double totalWeightGrams;
}

class MacroMealSuggestion {
  const MacroMealSuggestion({
    required this.name,
    required this.portions,
    required this.nutrition,
    required this.matchScore,
    required this.pantryCoverage,
    required this.reason,
  });

  final String name;
  final List<IngredientPortion> portions;
  final RecipeNutrition nutrition;
  final int matchScore;
  final double pantryCoverage;
  final String reason;
}

class ExpiryReminder {
  const ExpiryReminder({
    required this.item,
    required this.daysRemaining,
    required this.status,
    required this.action,
  });

  final PantryItem item;
  final int? daysRemaining;
  final String status;
  final String action;
}

class BudgetGroceryItem {
  const BudgetGroceryItem({
    required this.ingredientId,
    required this.name,
    required this.requiredGrams,
    required this.pantryGrams,
    required this.buyGrams,
    required this.estimatedCost,
  });

  final String ingredientId;
  final String name;
  final double requiredGrams;
  final double pantryGrams;
  final double buyGrams;
  final double estimatedCost;
}

class BudgetGroceryPlan {
  const BudgetGroceryPlan({
    required this.items,
    required this.estimatedTotalCost,
    required this.pantrySavings,
  });

  final List<BudgetGroceryItem> items;
  final double estimatedTotalCost;
  final double pantrySavings;
}

class BatchCookingPlan {
  const BatchCookingPlan({
    required this.name,
    required this.servings,
    required this.portions,
    required this.perServing,
    required this.total,
    required this.grocery,
    required this.prepSteps,
    required this.storageRule,
  });

  final String name;
  final int servings;
  final List<IngredientPortion> portions;
  final RecipeNutrition perServing;
  final RecipeNutrition total;
  final BudgetGroceryPlan grocery;
  final List<String> prepSteps;
  final String storageRule;
}

class MealIntelligenceEngine {
  const MealIntelligenceEngine._();

  static const catalog = <IngredientDefinition>[
    IngredientDefinition(
      id: 'chicken-breast',
      name: 'Chicken breast',
      category: 'Protein',
      caloriesPer100Grams: 165,
      proteinPer100Grams: 31,
      carbohydratesPer100Grams: 0,
      fatPer100Grams: 3.6,
      fiberPer100Grams: 0,
      sodiumPer100Grams: 74,
      referenceCostPer100Grams: 1.05,
      defaultShelfDays: 2,
    ),
    IngredientDefinition(
      id: 'greek-yogurt',
      name: 'Greek yogurt 2%',
      category: 'Protein',
      caloriesPer100Grams: 73,
      proteinPer100Grams: 10,
      carbohydratesPer100Grams: 4,
      fatPer100Grams: 2,
      fiberPer100Grams: 0,
      sodiumPer100Grams: 36,
      referenceCostPer100Grams: .55,
      defaultShelfDays: 7,
    ),
    IngredientDefinition(
      id: 'eggs',
      name: 'Whole eggs',
      category: 'Protein',
      caloriesPer100Grams: 143,
      proteinPer100Grams: 13,
      carbohydratesPer100Grams: .7,
      fatPer100Grams: 9.5,
      fiberPer100Grams: 0,
      sodiumPer100Grams: 140,
      referenceCostPer100Grams: .7,
      defaultShelfDays: 21,
    ),
    IngredientDefinition(
      id: 'lentils',
      name: 'Cooked lentils',
      category: 'Protein & fiber',
      caloriesPer100Grams: 116,
      proteinPer100Grams: 9,
      carbohydratesPer100Grams: 20,
      fatPer100Grams: .4,
      fiberPer100Grams: 8,
      sodiumPer100Grams: 2,
      referenceCostPer100Grams: .22,
      defaultShelfDays: 4,
    ),
    IngredientDefinition(
      id: 'rice',
      name: 'Cooked rice',
      category: 'Carbohydrate',
      caloriesPer100Grams: 130,
      proteinPer100Grams: 2.7,
      carbohydratesPer100Grams: 28,
      fatPer100Grams: .3,
      fiberPer100Grams: .4,
      sodiumPer100Grams: 1,
      referenceCostPer100Grams: .18,
      defaultShelfDays: 4,
    ),
    IngredientDefinition(
      id: 'oats',
      name: 'Oats',
      category: 'Carbohydrate',
      caloriesPer100Grams: 389,
      proteinPer100Grams: 17,
      carbohydratesPer100Grams: 66,
      fatPer100Grams: 7,
      fiberPer100Grams: 11,
      sodiumPer100Grams: 2,
      referenceCostPer100Grams: .28,
      defaultShelfDays: 180,
    ),
    IngredientDefinition(
      id: 'potato',
      name: 'Potato',
      category: 'Carbohydrate',
      caloriesPer100Grams: 77,
      proteinPer100Grams: 2,
      carbohydratesPer100Grams: 17,
      fatPer100Grams: .1,
      fiberPer100Grams: 2.2,
      sodiumPer100Grams: 6,
      referenceCostPer100Grams: .16,
      defaultShelfDays: 21,
    ),
    IngredientDefinition(
      id: 'wholegrain-bread',
      name: 'Wholegrain bread',
      category: 'Carbohydrate',
      caloriesPer100Grams: 247,
      proteinPer100Grams: 13,
      carbohydratesPer100Grams: 41,
      fatPer100Grams: 3.4,
      fiberPer100Grams: 7,
      sodiumPer100Grams: 430,
      referenceCostPer100Grams: .42,
      defaultShelfDays: 5,
    ),
    IngredientDefinition(
      id: 'mixed-vegetables',
      name: 'Mixed vegetables',
      category: 'Vegetable',
      caloriesPer100Grams: 55,
      proteinPer100Grams: 3,
      carbohydratesPer100Grams: 10,
      fatPer100Grams: .5,
      fiberPer100Grams: 4,
      sodiumPer100Grams: 45,
      referenceCostPer100Grams: .32,
      defaultShelfDays: 5,
    ),
    IngredientDefinition(
      id: 'berries',
      name: 'Berries',
      category: 'Fruit',
      caloriesPer100Grams: 57,
      proteinPer100Grams: .7,
      carbohydratesPer100Grams: 14,
      fatPer100Grams: .3,
      fiberPer100Grams: 2.4,
      sodiumPer100Grams: 1,
      referenceCostPer100Grams: .9,
      defaultShelfDays: 4,
    ),
    IngredientDefinition(
      id: 'banana',
      name: 'Banana',
      category: 'Fruit',
      caloriesPer100Grams: 89,
      proteinPer100Grams: 1.1,
      carbohydratesPer100Grams: 23,
      fatPer100Grams: .3,
      fiberPer100Grams: 2.6,
      sodiumPer100Grams: 1,
      referenceCostPer100Grams: .25,
      defaultShelfDays: 5,
    ),
    IngredientDefinition(
      id: 'olive-oil',
      name: 'Olive oil',
      category: 'Fat',
      caloriesPer100Grams: 884,
      proteinPer100Grams: 0,
      carbohydratesPer100Grams: 0,
      fatPer100Grams: 100,
      fiberPer100Grams: 0,
      sodiumPer100Grams: 0,
      referenceCostPer100Grams: 1.1,
      defaultShelfDays: 365,
    ),
    IngredientDefinition(
      id: 'peanut-butter',
      name: 'Peanut butter',
      category: 'Fat & protein',
      caloriesPer100Grams: 588,
      proteinPer100Grams: 25,
      carbohydratesPer100Grams: 20,
      fatPer100Grams: 50,
      fiberPer100Grams: 6,
      sodiumPer100Grams: 17,
      referenceCostPer100Grams: .75,
      defaultShelfDays: 120,
    ),
  ];

  static IngredientDefinition ingredient(String id) =>
      catalog.firstWhere((item) => item.id == id, orElse: () => catalog.first);

  static RecipeNutrition recipeNutrition(List<IngredientPortion> portions) {
    var calories = 0.0;
    var protein = 0.0;
    var carbohydrates = 0.0;
    var fat = 0.0;
    var fiber = 0.0;
    var sodium = 0.0;
    var weight = 0.0;
    for (final portion in portions) {
      final item = ingredient(portion.ingredientId);
      final factor = portion.grams.clamp(0, 5000) / 100;
      calories += item.caloriesPer100Grams * factor;
      protein += item.proteinPer100Grams * factor;
      carbohydrates += item.carbohydratesPer100Grams * factor;
      fat += item.fatPer100Grams * factor;
      fiber += item.fiberPer100Grams * factor;
      sodium += item.sodiumPer100Grams * factor;
      weight += portion.grams.clamp(0, 5000);
    }
    return RecipeNutrition(
      calories: calories.round(),
      proteinGrams: protein,
      carbohydrateGrams: carbohydrates,
      fatGrams: fat,
      fiberGrams: fiber,
      sodiumMilligrams: sodium,
      totalWeightGrams: weight,
    );
  }

  static List<IngredientPortion> scaleRecipe({
    required List<IngredientPortion> portions,
    required int originalServings,
    required int targetServings,
  }) {
    if (originalServings <= 0 || targetServings <= 0) return const [];
    final factor = targetServings / originalServings;
    return [
      for (final portion in portions)
        IngredientPortion(
          ingredientId: portion.ingredientId,
          grams: portion.grams * factor,
        ),
    ];
  }

  static List<MealEntry> recentFoods(List<MealEntry> meals, {int limit = 8}) {
    final sorted = [...meals]
      ..sort((left, right) => right.loggedAt.compareTo(left.loggedAt));
    final names = <String>{};
    final result = <MealEntry>[];
    for (final meal in sorted) {
      if (!names.add(meal.name.trim().toLowerCase())) continue;
      result.add(meal);
      if (result.length == limit) break;
    }
    return result;
  }

  static List<MacroMealSuggestion> macroSuggestions({
    required double proteinRemaining,
    required double carbohydrateRemaining,
    required double fatRemaining,
    required int calorieRemaining,
    required List<PantryItem> pantry,
  }) {
    const recipes = <(String, List<IngredientPortion>, String)>[
      (
        'Chicken rice bowl',
        [
          IngredientPortion(ingredientId: 'chicken-breast', grams: 160),
          IngredientPortion(ingredientId: 'rice', grams: 220),
          IngredientPortion(ingredientId: 'mixed-vegetables', grams: 180),
          IngredientPortion(ingredientId: 'olive-oil', grams: 10),
        ],
        'High-protein main meal with adjustable rice.',
      ),
      (
        'Yogurt oat bowl',
        [
          IngredientPortion(ingredientId: 'greek-yogurt', grams: 250),
          IngredientPortion(ingredientId: 'oats', grams: 60),
          IngredientPortion(ingredientId: 'berries', grams: 120),
        ],
        'Protein, carbohydrate and fiber with no cooking.',
      ),
      (
        'Lentil potato bowl',
        [
          IngredientPortion(ingredientId: 'lentils', grams: 220),
          IngredientPortion(ingredientId: 'potato', grams: 250),
          IngredientPortion(ingredientId: 'mixed-vegetables', grams: 150),
          IngredientPortion(ingredientId: 'olive-oil', grams: 10),
        ],
        'Budget-friendly plant meal with high fiber.',
      ),
      (
        'Egg toast plate',
        [
          IngredientPortion(ingredientId: 'eggs', grams: 150),
          IngredientPortion(ingredientId: 'wholegrain-bread', grams: 100),
          IngredientPortion(ingredientId: 'mixed-vegetables', grams: 150),
        ],
        'Compact mixed meal from common ingredients.',
      ),
    ];
    final pantryById = {
      for (final item in pantry) item.ingredientId: item.quantityGrams,
    };
    final result = <MacroMealSuggestion>[];
    for (final recipe in recipes) {
      final nutrition = recipeNutrition(recipe.$2);
      final macroCloseness =
          [
            _closeness(nutrition.proteinGrams, math.max(1.0, proteinRemaining)),
            _closeness(
              nutrition.carbohydrateGrams,
              math.max(1.0, carbohydrateRemaining),
            ),
            _closeness(nutrition.fatGrams, math.max(1.0, fatRemaining)),
            _closeness(
              nutrition.calories.toDouble(),
              math.max(1, calorieRemaining).toDouble(),
            ),
          ].reduce((left, right) => left + right) /
          4;
      final totalIngredients = recipe.$2.length;
      final available = recipe.$2
          .where(
            (portion) =>
                (pantryById[portion.ingredientId] ?? 0) >= portion.grams,
          )
          .length;
      final coverage = totalIngredients == 0
          ? 0.0
          : available / totalIngredients;
      result.add(
        MacroMealSuggestion(
          name: recipe.$1,
          portions: recipe.$2,
          nutrition: nutrition,
          matchScore: (macroCloseness * 80 + coverage * 20).round(),
          pantryCoverage: coverage,
          reason: recipe.$3,
        ),
      );
    }
    result.sort((left, right) => right.matchScore.compareTo(left.matchScore));
    return result;
  }

  static List<ExpiryReminder> expiryReminders(
    List<PantryItem> pantry, {
    required DateTime now,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final result =
        pantry.map((item) {
          final expiry = item.expiresAt;
          final days = expiry == null
              ? null
              : DateTime(
                  expiry.year,
                  expiry.month,
                  expiry.day,
                ).difference(today).inDays;
          return ExpiryReminder(
            item: item,
            daysRemaining: days,
            status: days == null
                ? 'NO DATE'
                : days < 0
                ? 'EXPIRED'
                : days == 0
                ? 'USE TODAY'
                : days <= 3
                ? 'USE SOON'
                : 'FRESH',
            action: days == null
                ? 'Add an expiry date when known.'
                : days < 0
                ? 'Discard if unsafe; do not rely on smell alone for high-risk foods.'
                : days <= 3
                ? 'Prioritize in the next meal or freeze safely.'
                : 'Keep normal storage and stock rotation.',
          );
        }).toList()..sort((left, right) {
          final leftDays = left.daysRemaining ?? 99999;
          final rightDays = right.daysRemaining ?? 99999;
          return leftDays.compareTo(rightDays);
        });
    return result;
  }

  static BudgetGroceryPlan budgetGrocery({
    required List<IngredientPortion> portions,
    required List<PantryItem> pantry,
  }) {
    final requiredById = <String, double>{};
    for (final item in portions) {
      requiredById.update(
        item.ingredientId,
        (value) => value + item.grams,
        ifAbsent: () => item.grams,
      );
    }
    final pantryById = {for (final item in pantry) item.ingredientId: item};
    var total = 0.0;
    var savings = 0.0;
    final items = <BudgetGroceryItem>[];
    for (final entry in requiredById.entries) {
      final definition = ingredient(entry.key);
      final pantryItem = pantryById[entry.key];
      final available = pantryItem?.quantityGrams ?? 0;
      final costPer100 = pantryItem != null && pantryItem.costPer100Grams > 0
          ? pantryItem.costPer100Grams
          : definition.referenceCostPer100Grams;
      final buy = math.max(0.0, entry.value - available);
      final cost = buy / 100 * costPer100;
      final saved = math.min(entry.value, available) / 100 * costPer100;
      total += cost;
      savings += saved;
      items.add(
        BudgetGroceryItem(
          ingredientId: entry.key,
          name: definition.name,
          requiredGrams: entry.value,
          pantryGrams: available,
          buyGrams: buy,
          estimatedCost: cost,
        ),
      );
    }
    items.sort(
      (left, right) => right.estimatedCost.compareTo(left.estimatedCost),
    );
    return BudgetGroceryPlan(
      items: items,
      estimatedTotalCost: total,
      pantrySavings: savings,
    );
  }

  static BatchCookingPlan batchCooking({
    required MacroMealSuggestion recipe,
    required int servings,
    required List<PantryItem> pantry,
  }) {
    final safeServings = servings.clamp(2, 12);
    final scaled = scaleRecipe(
      portions: recipe.portions,
      originalServings: 1,
      targetServings: safeServings,
    );
    return BatchCookingPlan(
      name: recipe.name,
      servings: safeServings,
      portions: scaled,
      perServing: recipe.nutrition,
      total: recipeNutrition(scaled),
      grocery: budgetGrocery(portions: scaled, pantry: pantry),
      prepSteps: const [
        'Weigh and organize ingredients before heating.',
        'Cook protein/starch to food-safe doneness and prepare vegetables.',
        'Cool promptly, divide evenly and label each container.',
      ],
      storageRule:
          'Refrigerate promptly and use per ingredient safety guidance; freeze extra portions when needed.',
    );
  }

  static double _closeness(double value, double target) =>
      (1 - (value - target).abs() / target).clamp(0, 1).toDouble();
}
