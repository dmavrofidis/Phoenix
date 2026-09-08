import 'dart:math' as math;

import 'nutrition_goal_engine.dart';

class RecommendedFoodPortion {
  const RecommendedFoodPortion({
    required this.id,
    required this.greekName,
    required this.englishName,
    required this.grams,
  });

  final String id;
  final String greekName;
  final String englishName;
  final int grams;
}

class RecommendedMeal {
  const RecommendedMeal({
    required this.slotGreek,
    required this.slotEnglish,
    required this.titleGreek,
    required this.titleEnglish,
    required this.ingredients,
    required this.calories,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    required this.fiberGrams,
    required this.prepMinutes,
  });

  final String slotGreek;
  final String slotEnglish;
  final String titleGreek;
  final String titleEnglish;
  final List<RecommendedFoodPortion> ingredients;
  final int calories;
  final double proteinGrams;
  final double carbohydrateGrams;
  final double fatGrams;
  final double fiberGrams;
  final int prepMinutes;
}

class RecommendedNutritionDay {
  const RecommendedNutritionDay({
    required this.date,
    required this.targets,
    required this.meals,
  });

  final DateTime date;
  final NutritionTargets targets;
  final List<RecommendedMeal> meals;

  int get estimatedCalories =>
      meals.fold(0, (total, meal) => total + meal.calories);
  double get estimatedProtein =>
      meals.fold(0, (total, meal) => total + meal.proteinGrams);
}

class RecommendedGroceryItem {
  const RecommendedGroceryItem({
    required this.id,
    required this.greekName,
    required this.englishName,
    required this.grams,
  });

  final String id;
  final String greekName;
  final String englishName;
  final int grams;
}

class RecommendedNutritionWeek {
  const RecommendedNutritionWeek({
    required this.days,
    required this.groceryItems,
  });

  final List<RecommendedNutritionDay> days;
  final List<RecommendedGroceryItem> groceryItems;
}

class RecommendedNutritionEngine {
  const RecommendedNutritionEngine._();

  static const supportedDietStyles = {
    'balanced',
    'mediterranean',
    'vegetarian',
    'vegan',
  };

  static RecommendedNutritionWeek buildWeek({
    required DateTime startDate,
    required NutritionTargets Function(DateTime date) targetsForDate,
    required String dietStyle,
    required int mealsPerDay,
    required String budgetMode,
    required bool quickPrep,
    bool noCooking = false,
  }) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final style = supportedDietStyles.contains(dietStyle)
        ? dietStyle
        : 'balanced';
    final mealCount = mealsPerDay.clamp(3, 5);
    final economy = budgetMode == 'economy';
    final days = <RecommendedNutritionDay>[];
    final groceries = <String, double>{};

    for (var dayIndex = 0; dayIndex < 7; dayIndex++) {
      final date = start.add(Duration(days: dayIndex));
      final targets = targetsForDate(date);
      final slots = _slots(mealCount);
      final meals = <RecommendedMeal>[];
      for (var slotIndex = 0; slotIndex < slots.length; slotIndex++) {
        final slot = slots[slotIndex];
        final recipe = _recipeFor(
          slot: slot.kind,
          dietStyle: style,
          economy: economy,
          quickPrep: quickPrep,
          noCooking: noCooking,
          rotation: dayIndex + slotIndex,
        );
        final meal = _scaledMeal(
          recipe,
          slot: slot,
          targetCalories: targets.calories * slot.share,
        );
        meals.add(meal);
        for (final ingredient in meal.ingredients) {
          groceries.update(
            ingredient.id,
            (value) => value + ingredient.grams,
            ifAbsent: () => ingredient.grams.toDouble(),
          );
        }
      }
      days.add(
        RecommendedNutritionDay(date: date, targets: targets, meals: meals),
      );
    }

    final groceryItems =
        groceries.entries.map((entry) {
            final food = _food(entry.key);
            return RecommendedGroceryItem(
              id: entry.key,
              greekName: food.greekName,
              englishName: food.englishName,
              grams: _roundTo(entry.value, 50),
            );
          }).toList()
          ..sort((left, right) => left.greekName.compareTo(right.greekName));

    return RecommendedNutritionWeek(days: days, groceryItems: groceryItems);
  }

  static _PlanRecipe _recipeFor({
    required String slot,
    required String dietStyle,
    required bool economy,
    required bool quickPrep,
    required bool noCooking,
    required int rotation,
  }) {
    final styleMatches = _recipes
        .where(
          (recipe) =>
              recipe.slot == slot && recipe.dietStyles.contains(dietStyle),
        )
        .toList();
    var candidates = styleMatches
        .where((recipe) => !economy || recipe.economy)
        .where((recipe) => !quickPrep || recipe.prepMinutes <= 15)
        .where((recipe) => !noCooking || recipe.prepMinutes <= 5)
        .toList();
    if (candidates.isEmpty) {
      candidates = styleMatches
          .where((recipe) => !economy || recipe.economy)
          .where((recipe) => !noCooking || recipe.prepMinutes <= 5)
          .toList();
    }
    if (candidates.isEmpty) candidates = styleMatches;
    return candidates[rotation % candidates.length];
  }

  static RecommendedMeal _scaledMeal(
    _PlanRecipe recipe, {
    required _MealSlot slot,
    required double targetCalories,
  }) {
    final base = _nutrition(recipe.ingredients);
    final scale = base.calories <= 0
        ? 1.0
        : (targetCalories / base.calories).clamp(.55, 2.25).toDouble();
    final portions = recipe.ingredients.map((ingredient) {
      final food = _food(ingredient.foodId);
      return RecommendedFoodPortion(
        id: food.id,
        greekName: food.greekName,
        englishName: food.englishName,
        grams: math.max(5, _roundTo(ingredient.grams * scale, 5)),
      );
    }).toList();
    final nutrition = _nutrition([
      for (final portion in portions)
        _RecipeIngredient(foodId: portion.id, grams: portion.grams.toDouble()),
    ]);
    return RecommendedMeal(
      slotGreek: slot.greekLabel,
      slotEnglish: slot.englishLabel,
      titleGreek: recipe.greekTitle,
      titleEnglish: recipe.englishTitle,
      ingredients: portions,
      calories: nutrition.calories.round(),
      proteinGrams: nutrition.protein,
      carbohydrateGrams: nutrition.carbohydrates,
      fatGrams: nutrition.fat,
      fiberGrams: nutrition.fiber,
      prepMinutes: recipe.prepMinutes,
    );
  }

  static _MealNutrition _nutrition(List<_RecipeIngredient> ingredients) {
    var calories = 0.0;
    var protein = 0.0;
    var carbohydrates = 0.0;
    var fat = 0.0;
    var fiber = 0.0;
    for (final ingredient in ingredients) {
      final food = _food(ingredient.foodId);
      final factor = ingredient.grams / 100;
      calories += food.calories * factor;
      protein += food.protein * factor;
      carbohydrates += food.carbohydrates * factor;
      fat += food.fat * factor;
      fiber += food.fiber * factor;
    }
    return _MealNutrition(
      calories: calories,
      protein: protein,
      carbohydrates: carbohydrates,
      fat: fat,
      fiber: fiber,
    );
  }

  static List<_MealSlot> _slots(int meals) => switch (meals) {
    3 => const [
      _MealSlot('breakfast', 'ΠΡΩΙΝΟ', 'BREAKFAST', .28),
      _MealSlot('main', 'ΚΥΡΙΟ ΓΕΥΜΑ', 'MAIN MEAL', .36),
      _MealSlot('main', 'ΒΡΑΔΙΝΟ', 'DINNER', .36),
    ],
    5 => const [
      _MealSlot('breakfast', 'ΠΡΩΙΝΟ', 'BREAKFAST', .22),
      _MealSlot('snack', 'ΜΙΚΡΟ ΓΕΥΜΑ', 'SMALL MEAL', .12),
      _MealSlot('main', 'ΜΕΣΗΜΕΡΙΑΝΟ', 'LUNCH', .28),
      _MealSlot('snack', 'ΜΙΚΡΟ ΓΕΥΜΑ', 'SMALL MEAL', .12),
      _MealSlot('main', 'ΒΡΑΔΙΝΟ', 'DINNER', .26),
    ],
    _ => const [
      _MealSlot('breakfast', 'ΠΡΩΙΝΟ', 'BREAKFAST', .25),
      _MealSlot('main', 'ΜΕΣΗΜΕΡΙΑΝΟ', 'LUNCH', .30),
      _MealSlot('snack', 'ΜΙΚΡΟ ΓΕΥΜΑ', 'SMALL MEAL', .15),
      _MealSlot('main', 'ΒΡΑΔΙΝΟ', 'DINNER', .30),
    ],
  };

  static _PlanFood _food(String id) =>
      _foods.firstWhere((item) => item.id == id);

  static int _roundTo(double value, int step) => (value / step).round() * step;

  static const _foods = <_PlanFood>[
    _PlanFood('oats', 'Βρώμη', 'Oats', 389, 17, 66, 7, 11),
    _PlanFood(
      'greek-yogurt',
      'Γιαούρτι 2%',
      'Greek yogurt 2%',
      73,
      10,
      4,
      2,
      0,
    ),
    _PlanFood('soy-yogurt', 'Γιαούρτι σόγιας', 'Soy yogurt', 62, 4, 5, 3, 1),
    _PlanFood('banana', 'Μπανάνα', 'Banana', 89, 1.1, 23, .3, 2.6),
    _PlanFood('berries', 'Μούρα', 'Berries', 57, .7, 14, .3, 2.4),
    _PlanFood('eggs', 'Αυγά', 'Eggs', 143, 13, .7, 9.5, 0),
    _PlanFood(
      'wholegrain-bread',
      'Ψωμί ολικής',
      'Wholegrain bread',
      247,
      13,
      41,
      3.4,
      7,
    ),
    _PlanFood(
      'chicken',
      'Στήθος κοτόπουλου',
      'Chicken breast',
      165,
      31,
      0,
      3.6,
      0,
    ),
    _PlanFood('tuna', 'Τόνος σε νερό', 'Tuna in water', 116, 26, 0, 1, 0),
    _PlanFood('rice', 'Μαγειρεμένο ρύζι', 'Cooked rice', 130, 2.7, 28, .3, .4),
    _PlanFood('potato', 'Πατάτα', 'Potato', 77, 2, 17, .1, 2.2),
    _PlanFood(
      'lentils',
      'Μαγειρεμένες φακές',
      'Cooked lentils',
      116,
      9,
      20,
      .4,
      8,
    ),
    _PlanFood(
      'beans',
      'Μαγειρεμένα φασόλια',
      'Cooked beans',
      127,
      8.7,
      23,
      .5,
      6.4,
    ),
    _PlanFood('tofu', 'Τόφου', 'Tofu', 144, 17, 3, 8.7, 2.3),
    _PlanFood(
      'vegetables',
      'Ανάμεικτα λαχανικά',
      'Mixed vegetables',
      55,
      3,
      10,
      .5,
      4,
    ),
    _PlanFood('olive-oil', 'Ελαιόλαδο', 'Olive oil', 884, 0, 0, 100, 0),
    _PlanFood(
      'peanut-butter',
      'Φυστικοβούτυρο',
      'Peanut butter',
      588,
      25,
      20,
      50,
      6,
    ),
  ];

  static const _recipes = <_PlanRecipe>[
    _PlanRecipe(
      slot: 'breakfast',
      greekTitle: 'Μπολ γιαουρτιού με βρώμη',
      englishTitle: 'Yogurt oat bowl',
      dietStyles: {'balanced', 'mediterranean', 'vegetarian'},
      prepMinutes: 5,
      economy: true,
      ingredients: [
        _RecipeIngredient(foodId: 'greek-yogurt', grams: 250),
        _RecipeIngredient(foodId: 'oats', grams: 60),
        _RecipeIngredient(foodId: 'banana', grams: 120),
      ],
    ),
    _PlanRecipe(
      slot: 'breakfast',
      greekTitle: 'Αυγά με ψωμί ολικής',
      englishTitle: 'Eggs with wholegrain toast',
      dietStyles: {'balanced', 'mediterranean', 'vegetarian'},
      prepMinutes: 10,
      economy: true,
      ingredients: [
        _RecipeIngredient(foodId: 'eggs', grams: 150),
        _RecipeIngredient(foodId: 'wholegrain-bread', grams: 90),
        _RecipeIngredient(foodId: 'vegetables', grams: 120),
      ],
    ),
    _PlanRecipe(
      slot: 'breakfast',
      greekTitle: 'Vegan βρώμη με φρούτο',
      englishTitle: 'Vegan oats with fruit',
      dietStyles: {'balanced', 'vegetarian', 'vegan'},
      prepMinutes: 5,
      economy: true,
      ingredients: [
        _RecipeIngredient(foodId: 'soy-yogurt', grams: 250),
        _RecipeIngredient(foodId: 'oats', grams: 70),
        _RecipeIngredient(foodId: 'banana', grams: 120),
        _RecipeIngredient(foodId: 'peanut-butter', grams: 15),
      ],
    ),
    _PlanRecipe(
      slot: 'main',
      greekTitle: 'Κοτόπουλο με ρύζι και λαχανικά',
      englishTitle: 'Chicken rice vegetable bowl',
      dietStyles: {'balanced', 'mediterranean'},
      prepMinutes: 25,
      economy: true,
      ingredients: [
        _RecipeIngredient(foodId: 'chicken', grams: 170),
        _RecipeIngredient(foodId: 'rice', grams: 230),
        _RecipeIngredient(foodId: 'vegetables', grams: 200),
        _RecipeIngredient(foodId: 'olive-oil', grams: 10),
      ],
    ),
    _PlanRecipe(
      slot: 'main',
      greekTitle: 'Γρήγορο πιάτο τόνου και πατάτας',
      englishTitle: 'Quick tuna potato plate',
      dietStyles: {'balanced', 'mediterranean'},
      prepMinutes: 12,
      economy: true,
      ingredients: [
        _RecipeIngredient(foodId: 'tuna', grams: 160),
        _RecipeIngredient(foodId: 'potato', grams: 350),
        _RecipeIngredient(foodId: 'vegetables', grams: 180),
        _RecipeIngredient(foodId: 'olive-oil', grams: 10),
      ],
    ),
    _PlanRecipe(
      slot: 'main',
      greekTitle: 'Φακές με ρύζι και λαχανικά',
      englishTitle: 'Lentil rice vegetable bowl',
      dietStyles: {'balanced', 'mediterranean', 'vegetarian', 'vegan'},
      prepMinutes: 20,
      economy: true,
      ingredients: [
        _RecipeIngredient(foodId: 'lentils', grams: 260),
        _RecipeIngredient(foodId: 'rice', grams: 180),
        _RecipeIngredient(foodId: 'vegetables', grams: 180),
        _RecipeIngredient(foodId: 'olive-oil', grams: 10),
      ],
    ),
    _PlanRecipe(
      slot: 'main',
      greekTitle: 'Σαλάτα φασολιών με ψωμί',
      englishTitle: 'Bean salad with wholegrain bread',
      dietStyles: {'balanced', 'mediterranean', 'vegetarian', 'vegan'},
      prepMinutes: 5,
      economy: true,
      ingredients: [
        _RecipeIngredient(foodId: 'beans', grams: 280),
        _RecipeIngredient(foodId: 'wholegrain-bread', grams: 100),
        _RecipeIngredient(foodId: 'vegetables', grams: 220),
        _RecipeIngredient(foodId: 'olive-oil', grams: 10),
      ],
    ),
    _PlanRecipe(
      slot: 'main',
      greekTitle: 'Τόφου με ρύζι και λαχανικά',
      englishTitle: 'Tofu rice vegetable bowl',
      dietStyles: {'vegetarian', 'vegan'},
      prepMinutes: 15,
      economy: false,
      ingredients: [
        _RecipeIngredient(foodId: 'tofu', grams: 220),
        _RecipeIngredient(foodId: 'rice', grams: 220),
        _RecipeIngredient(foodId: 'vegetables', grams: 200),
        _RecipeIngredient(foodId: 'olive-oil', grams: 8),
      ],
    ),
    _PlanRecipe(
      slot: 'main',
      greekTitle: 'Αυγά με πατάτα και σαλάτα',
      englishTitle: 'Egg potato salad plate',
      dietStyles: {'balanced', 'mediterranean', 'vegetarian'},
      prepMinutes: 15,
      economy: true,
      ingredients: [
        _RecipeIngredient(foodId: 'eggs', grams: 180),
        _RecipeIngredient(foodId: 'potato', grams: 350),
        _RecipeIngredient(foodId: 'vegetables', grams: 200),
        _RecipeIngredient(foodId: 'olive-oil', grams: 8),
      ],
    ),
    _PlanRecipe(
      slot: 'snack',
      greekTitle: 'Γιαούρτι με μούρα',
      englishTitle: 'Yogurt with berries',
      dietStyles: {'balanced', 'mediterranean', 'vegetarian'},
      prepMinutes: 2,
      economy: true,
      ingredients: [
        _RecipeIngredient(foodId: 'greek-yogurt', grams: 250),
        _RecipeIngredient(foodId: 'berries', grams: 100),
      ],
    ),
    _PlanRecipe(
      slot: 'snack',
      greekTitle: 'Ψωμί με φυστικοβούτυρο και μπανάνα',
      englishTitle: 'Peanut butter banana toast',
      dietStyles: {'balanced', 'mediterranean', 'vegetarian', 'vegan'},
      prepMinutes: 3,
      economy: true,
      ingredients: [
        _RecipeIngredient(foodId: 'wholegrain-bread', grams: 70),
        _RecipeIngredient(foodId: 'peanut-butter', grams: 20),
        _RecipeIngredient(foodId: 'banana', grams: 100),
      ],
    ),
    _PlanRecipe(
      slot: 'snack',
      greekTitle: 'Γιαούρτι σόγιας με βρώμη',
      englishTitle: 'Soy yogurt with oats',
      dietStyles: {'vegetarian', 'vegan'},
      prepMinutes: 2,
      economy: false,
      ingredients: [
        _RecipeIngredient(foodId: 'soy-yogurt', grams: 250),
        _RecipeIngredient(foodId: 'oats', grams: 35),
        _RecipeIngredient(foodId: 'berries', grams: 80),
      ],
    ),
  ];
}

class _MealSlot {
  const _MealSlot(this.kind, this.greekLabel, this.englishLabel, this.share);

  final String kind;
  final String greekLabel;
  final String englishLabel;
  final double share;
}

class _PlanFood {
  const _PlanFood(
    this.id,
    this.greekName,
    this.englishName,
    this.calories,
    this.protein,
    this.carbohydrates,
    this.fat,
    this.fiber,
  );

  final String id;
  final String greekName;
  final String englishName;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fiber;
}

class _RecipeIngredient {
  const _RecipeIngredient({required this.foodId, required this.grams});

  final String foodId;
  final double grams;
}

class _PlanRecipe {
  const _PlanRecipe({
    required this.slot,
    required this.greekTitle,
    required this.englishTitle,
    required this.dietStyles,
    required this.prepMinutes,
    required this.economy,
    required this.ingredients,
  });

  final String slot;
  final String greekTitle;
  final String englishTitle;
  final Set<String> dietStyles;
  final int prepMinutes;
  final bool economy;
  final List<_RecipeIngredient> ingredients;
}

class _MealNutrition {
  const _MealNutrition({
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.fiber,
  });

  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fiber;
}
