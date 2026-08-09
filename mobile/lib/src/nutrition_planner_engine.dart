import 'dart:math' as math;

class NutritionPhasePlan {
  const NutritionPhasePlan({
    required this.phase,
    required this.dailyCalories,
    required this.maintenanceCalories,
    required this.durationWeeks,
    required this.targetWeeklyChangePercent,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    required this.guardrail,
  });

  final String phase;
  final int dailyCalories;
  final int maintenanceCalories;
  final int durationWeeks;
  final double targetWeeklyChangePercent;
  final double proteinGrams;
  final double carbohydrateGrams;
  final double fatGrams;
  final String guardrail;
}

class WeeklyCalorieDay {
  const WeeklyCalorieDay({
    required this.weekday,
    required this.label,
    required this.calories,
    required this.isTrainingDay,
  });

  final int weekday;
  final String label;
  final int calories;
  final bool isTrainingDay;
}

class WeeklyCalorieBudget {
  const WeeklyCalorieBudget({
    required this.totalCalories,
    required this.averageCalories,
    required this.days,
  });

  final int totalCalories;
  final int averageCalories;
  final List<WeeklyCalorieDay> days;
}

class ProteinServing {
  const ProteinServing({
    required this.label,
    required this.grams,
    required this.window,
    required this.purpose,
  });

  final String label;
  final double grams;
  final String window;
  final String purpose;
}

class ProteinDistributionPlan {
  const ProteinDistributionPlan({
    required this.dailyTarget,
    required this.meals,
    required this.minimumPerMeal,
    required this.maximumGapHours,
  });

  final double dailyTarget;
  final List<ProteinServing> meals;
  final double minimumPerMeal;
  final int maximumGapHours;
}

class CarbTimingPlan {
  const CarbTimingPlan({
    required this.dailyCarbohydrates,
    required this.preWorkoutGrams,
    required this.postWorkoutGrams,
    required this.otherMealGrams,
    required this.guidance,
  });

  final double dailyCarbohydrates;
  final double preWorkoutGrams;
  final double postWorkoutGrams;
  final double otherMealGrams;
  final String guidance;
}

class FatMinimumGuard {
  const FatMinimumGuard({
    required this.minimumGrams,
    required this.plannedGrams,
    required this.shortfallGrams,
    required this.status,
    required this.action,
  });

  final double minimumGrams;
  final double plannedGrams;
  final double shortfallGrams;
  final String status;
  final String action;
}

class FiberProgressionStep {
  const FiberProgressionStep({required this.week, required this.targetGrams});

  final int week;
  final double targetGrams;
}

class FiberProgressionPlan {
  const FiberProgressionPlan({
    required this.currentGrams,
    required this.finalTargetGrams,
    required this.steps,
    required this.guidance,
  });

  final double currentGrams;
  final double finalTargetGrams;
  final List<FiberProgressionStep> steps;
  final String guidance;
}

class SodiumHydrationContext {
  const SodiumHydrationContext({
    required this.waterTargetMilliliters,
    required this.trainingWaterMilliliters,
    required this.sodiumFloorMilligrams,
    required this.sodiumCeilingMilligrams,
    required this.status,
    required this.actions,
  });

  final int waterTargetMilliliters;
  final int trainingWaterMilliliters;
  final int sodiumFloorMilligrams;
  final int sodiumCeilingMilligrams;
  final String status;
  final List<String> actions;
}

class MealTimingSlot {
  const MealTimingSlot({
    required this.label,
    required this.time,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.purpose,
  });

  final String label;
  final String time;
  final double proteinGrams;
  final double carbohydrateGrams;
  final String purpose;
}

class DietBreakPlan {
  const DietBreakPlan({
    required this.recommended,
    required this.durationDays,
    required this.dailyCalories,
    required this.reason,
    required this.rules,
  });

  final bool recommended;
  final int durationDays;
  final int dailyCalories;
  final String reason;
  final List<String> rules;
}

class ReverseDietWeek {
  const ReverseDietWeek({
    required this.week,
    required this.dailyCalories,
    required this.change,
  });

  final int week;
  final int dailyCalories;
  final int change;
}

class ReverseDietPlan {
  const ReverseDietPlan({
    required this.startCalories,
    required this.maintenanceCalories,
    required this.incrementCalories,
    required this.weeks,
    required this.stopRule,
  });

  final int startCalories;
  final int maintenanceCalories;
  final int incrementCalories;
  final List<ReverseDietWeek> weeks;
  final String stopRule;
}

class NutritionPlannerEngine {
  const NutritionPlannerEngine._();

  static const phases = <String>[
    'Fat loss',
    'Maintenance',
    'Muscle gain',
    'Performance',
  ];

  static NutritionPhasePlan phasePlan({
    required double weightKilograms,
    required String phase,
    required int trainingDaysPerWeek,
  }) {
    final safeWeight = weightKilograms.clamp(40, 250).toDouble();
    final maintenancePerKilogram = trainingDaysPerWeek >= 5
        ? 33.0
        : trainingDaysPerWeek >= 3
        ? 31.0
        : 29.0;
    final maintenance = (safeWeight * maintenancePerKilogram).round().clamp(
      1500,
      4500,
    );
    final factor = switch (phase) {
      'Fat loss' => .82,
      'Muscle gain' => 1.08,
      'Performance' => 1.03,
      _ => 1.0,
    };
    final calories = (maintenance * factor).round().clamp(1500, 4500);
    final proteinPerKilogram = switch (phase) {
      'Fat loss' => 2.0,
      'Muscle gain' => 1.8,
      _ => 1.7,
    };
    final protein = safeWeight * proteinPerKilogram;
    final fat = math.max(safeWeight * .7, calories * .22 / 9);
    final carbs = math.max(80, (calories - protein * 4 - fat * 9) / 4);
    final weeklyChange = (calories - maintenance) * 7 / 7700 / safeWeight * 100;
    final duration = switch (phase) {
      'Fat loss' => 12,
      'Muscle gain' => 16,
      _ => 8,
    };
    return NutritionPhasePlan(
      phase: phases.contains(phase) ? phase : 'Maintenance',
      dailyCalories: calories,
      maintenanceCalories: maintenance,
      durationWeeks: duration,
      targetWeeklyChangePercent: weeklyChange,
      proteinGrams: protein,
      carbohydrateGrams: carbs.toDouble(),
      fatGrams: fat,
      guardrail: phase == 'Fat loss'
          ? 'Review after two weeks of weight-trend data; do not cut calories from one high weigh-in.'
          : phase == 'Muscle gain'
          ? 'Use the smallest surplus that supports training and a slow weight trend.'
          : 'Hold calories steady long enough to separate signal from daily noise.',
    );
  }

  static WeeklyCalorieBudget weeklyBudget({
    required NutritionPhasePlan plan,
    required Set<int> trainingWeekdays,
  }) {
    final safeTrainingDays = {
      for (final day in trainingWeekdays)
        if (day >= 1 && day <= 7) day,
    };
    final total = plan.dailyCalories * 7;
    final trainingCalories = safeTrainingDays.isEmpty
        ? plan.dailyCalories
        : (plan.dailyCalories * 1.06).round();
    final restDays = 7 - safeTrainingDays.length;
    final restCalories = restDays == 0
        ? trainingCalories
        : ((total - trainingCalories * safeTrainingDays.length) / restDays)
              .round()
              .clamp(1200, 4500);
    final values = [
      for (var day = 1; day <= 7; day++)
        safeTrainingDays.contains(day) ? trainingCalories : restCalories,
    ];
    final difference = total - values.fold<int>(0, (sum, item) => sum + item);
    values[6] = (values[6] + difference).clamp(1200, 4500);
    const labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return WeeklyCalorieBudget(
      totalCalories: values.fold<int>(0, (sum, item) => sum + item),
      averageCalories: (values.fold<int>(0, (sum, item) => sum + item) / 7)
          .round(),
      days: [
        for (var index = 0; index < 7; index++)
          WeeklyCalorieDay(
            weekday: index + 1,
            label: labels[index],
            calories: values[index],
            isTrainingDay: safeTrainingDays.contains(index + 1),
          ),
      ],
    );
  }

  static ProteinDistributionPlan proteinDistribution({
    required double dailyProteinGrams,
    required int meals,
  }) {
    final count = meals.clamp(3, 6);
    final base = dailyProteinGrams / count;
    const labels = [
      'FIRST MEAL',
      'MIDDAY',
      'PRE-WORKOUT',
      'POST-WORKOUT',
      'EVENING',
      'PRE-SLEEP',
    ];
    const windows = [
      '07:00–09:00',
      '11:00–13:00',
      '14:00–17:00',
      '17:00–20:00',
      '20:00–22:00',
      '22:00–23:30',
    ];
    final servings = [
      for (var index = 0; index < count; index++)
        ProteinServing(
          label: labels[index],
          grams: index == count - 1
              ? dailyProteinGrams - base * (count - 1)
              : base,
          window: windows[index],
          purpose: index == count - 1
              ? 'Complete the daily target without force-feeding.'
              : 'Spread a meaningful protein dose across the day.',
        ),
    ];
    return ProteinDistributionPlan(
      dailyTarget: dailyProteinGrams,
      meals: servings,
      minimumPerMeal: math.min(25, base),
      maximumGapHours: 5,
    );
  }

  static CarbTimingPlan carbTiming({
    required double dailyCarbohydrates,
    required bool isTrainingDay,
  }) {
    if (!isTrainingDay) {
      return CarbTimingPlan(
        dailyCarbohydrates: dailyCarbohydrates,
        preWorkoutGrams: 0,
        postWorkoutGrams: 0,
        otherMealGrams: dailyCarbohydrates,
        guidance:
            'Rest day: distribute carbohydrates by preference and keep fiber-rich sources prominent.',
      );
    }
    final pre = dailyCarbohydrates * .25;
    final post = dailyCarbohydrates * .30;
    return CarbTimingPlan(
      dailyCarbohydrates: dailyCarbohydrates,
      preWorkoutGrams: pre,
      postWorkoutGrams: post,
      otherMealGrams: dailyCarbohydrates - pre - post,
      guidance:
          'Place the pre-workout share 1–3 hours before training and the post-workout share in the next main meal.',
    );
  }

  static FatMinimumGuard fatGuard({
    required double weightKilograms,
    required int dailyCalories,
    required double plannedFatGrams,
  }) {
    final minimum = math.max(weightKilograms * .6, dailyCalories * .20 / 9);
    final shortfall = math.max(0.0, minimum - plannedFatGrams);
    return FatMinimumGuard(
      minimumGrams: minimum,
      plannedGrams: plannedFatGrams,
      shortfallGrams: shortfall,
      status: shortfall > 0 ? 'BELOW FLOOR' : 'PROTECTED',
      action: shortfall > 0
          ? 'Add ${shortfall.ceil()}g fat by reducing discretionary carbohydrate calories, not protein.'
          : 'Planned fat stays above the conservative floor.',
    );
  }

  static FiberProgressionPlan fiberProgression({
    required double currentGrams,
    required int dailyCalories,
  }) {
    final target = (dailyCalories / 1000 * 14).clamp(25, 45).toDouble();
    final start = currentGrams.clamp(0, target).toDouble();
    final weeks = math.max(1, ((target - start) / 3).ceil());
    return FiberProgressionPlan(
      currentGrams: currentGrams,
      finalTargetGrams: target,
      steps: [
        for (var week = 1; week <= weeks; week++)
          FiberProgressionStep(
            week: week,
            targetGrams: math.min(target, start + week * 3),
          ),
      ],
      guidance:
          'Increase gradually with fluids. Hold the current step if bloating or bowel discomfort rises.',
    );
  }

  static SodiumHydrationContext sodiumHydration({
    required double weightKilograms,
    required int trainingMinutes,
    required String sweatLevel,
    required bool hotConditions,
    required int waterConsumedMilliliters,
  }) {
    final base = (weightKilograms * 35).round();
    final hourlyTrainingWater = switch (sweatLevel) {
      'High' => 750,
      'Low' => 400,
      _ => 550,
    };
    final heatBonus = hotConditions ? 250 : 0;
    final trainingWater =
        ((hourlyTrainingWater + heatBonus) * trainingMinutes / 60).round();
    final target = (base + trainingWater).clamp(1800, 6000);
    final sodiumPerHour = switch (sweatLevel) {
      'High' => (600, 900),
      'Low' => (200, 400),
      _ => (350, 650),
    };
    final hours = trainingMinutes / 60;
    final floor = (sodiumPerHour.$1 * hours).round();
    final ceiling = (sodiumPerHour.$2 * hours).round();
    final ratio = target == 0 ? 0.0 : waterConsumedMilliliters / target;
    return SodiumHydrationContext(
      waterTargetMilliliters: target,
      trainingWaterMilliliters: trainingWater,
      sodiumFloorMilligrams: floor,
      sodiumCeilingMilligrams: ceiling,
      status: ratio >= 1
          ? 'TARGET REACHED'
          : ratio >= .7
          ? 'ON TRACK'
          : 'BEHIND',
      actions: [
        'Spread fluids across the day; avoid forcing large volumes at once.',
        if (trainingMinutes >= 60)
          'For the training window, pair fluids with food/electrolytes according to sweat loss.',
        'Medical sodium or fluid restrictions always override this context.',
      ],
    );
  }

  static List<MealTimingSlot> trainingMealTiming({
    required int trainingMinutesSinceMidnight,
    required ProteinDistributionPlan protein,
    required CarbTimingPlan carbohydrates,
  }) {
    final proteinPerMeal = protein.dailyTarget / 4;
    return [
      MealTimingSlot(
        label: 'FOUNDATION MEAL',
        time: _time(math.min(9 * 60, trainingMinutesSinceMidnight - 300)),
        proteinGrams: proteinPerMeal,
        carbohydrateGrams: carbohydrates.otherMealGrams * .45,
        purpose: 'Start daily protein distribution and normal hydration.',
      ),
      MealTimingSlot(
        label: 'PRE-WORKOUT',
        time: _time(trainingMinutesSinceMidnight - 120),
        proteinGrams: proteinPerMeal,
        carbohydrateGrams: carbohydrates.preWorkoutGrams,
        purpose: 'Familiar, digestible food 1–3 hours before training.',
      ),
      MealTimingSlot(
        label: 'POST-WORKOUT',
        time: _time(trainingMinutesSinceMidnight + 60),
        proteinGrams: proteinPerMeal,
        carbohydrateGrams: carbohydrates.postWorkoutGrams,
        purpose: 'A normal meal; no urgent shake is required.',
      ),
      MealTimingSlot(
        label: 'FINAL PROTEIN',
        time: _time(math.max(21 * 60, trainingMinutesSinceMidnight + 240)),
        proteinGrams: protein.dailyTarget - proteinPerMeal * 3,
        carbohydrateGrams: carbohydrates.otherMealGrams * .55,
        purpose: 'Complete targets while respecting appetite and sleep.',
      ),
    ];
  }

  static DietBreakPlan dietBreak({
    required NutritionPhasePlan plan,
    required int consecutiveDeficitWeeks,
    required double adherence,
    required int readinessScore,
  }) {
    final recommended =
        plan.phase == 'Fat loss' &&
        (consecutiveDeficitWeeks >= 8 ||
            readinessScore < 50 ||
            adherence < .65);
    final duration = consecutiveDeficitWeeks >= 12 || readinessScore < 45
        ? 14
        : 7;
    return DietBreakPlan(
      recommended: recommended,
      durationDays: recommended ? duration : 0,
      dailyCalories: recommended
          ? plan.maintenanceCalories
          : plan.dailyCalories,
      reason: recommended
          ? 'Extended deficit or recovery/adherence signal supports a planned maintenance phase.'
          : 'No diet break trigger is present; continue and review the two-week trend.',
      rules: const [
        'Move calories to estimated maintenance, not an unrestricted intake.',
        'Keep protein, meal structure and training technique consistent.',
        'Expect temporary scale movement from glycogen and food volume.',
      ],
    );
  }

  static ReverseDietPlan reverseDiet({
    required int currentCalories,
    required int maintenanceCalories,
  }) {
    final start = currentCalories.clamp(1200, 4500);
    final maintenance = maintenanceCalories.clamp(start, 5000);
    final difference = maintenance - start;
    final increment = difference <= 0
        ? 0
        : difference > 800
        ? 150
        : difference > 350
        ? 100
        : 75;
    final weeks = <ReverseDietWeek>[];
    var calories = start;
    for (var week = 1; week <= 12 && calories < maintenance; week++) {
      final next = math.min(maintenance, calories + increment);
      weeks.add(
        ReverseDietWeek(
          week: week,
          dailyCalories: next,
          change: next - calories,
        ),
      );
      calories = next;
    }
    return ReverseDietPlan(
      startCalories: start,
      maintenanceCalories: maintenance,
      incrementCalories: increment,
      weeks: weeks,
      stopRule:
          'Hold or stop additions when the two-week weight trend exceeds the intended phase rate.',
    );
  }

  static String _time(int minutes) {
    final normalized = minutes.clamp(0, 1439);
    final hour = normalized ~/ 60;
    final minute = normalized % 60;
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }
}
