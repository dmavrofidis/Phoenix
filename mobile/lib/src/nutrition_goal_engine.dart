import 'models/fitness_models.dart';

class NutritionTargets {
  const NutritionTargets({
    required this.calories,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    required this.fiberGrams,
    required this.sodiumLimitMilligrams,
    required this.goalLabel,
    required this.isTrainingDay,
  });

  final int calories;
  final double proteinGrams;
  final double carbohydrateGrams;
  final double fatGrams;
  final double fiberGrams;
  final double sodiumLimitMilligrams;
  final String goalLabel;
  final bool isTrainingDay;
}

class NutritionCoachMessage {
  const NutritionCoachMessage({required this.headline, required this.detail});

  final String headline;
  final String detail;
}

class NutritionGoalEngine {
  const NutritionGoalEngine._();

  static NutritionTargets calculate({
    required UserProfile? profile,
    required double currentWeightKilograms,
    bool isTrainingDay = true,
  }) {
    final goal = profile?.goal.toLowerCase() ?? 'γενική φυσική κατάσταση';
    final trainingDays = profile?.daysPerWeek ?? 3;
    var caloriesPerKilogram = 30.0;
    var proteinPerKilogram = 1.6;
    var goalLabel = 'Συντήρηση & απόδοση';

    if (goal.contains('απώλεια') || goal.contains('λίπος')) {
      caloriesPerKilogram = 26;
      proteinPerKilogram = 2;
      goalLabel = 'Ελεγχόμενη απώλεια λίπους';
    } else if (goal.contains('μυϊκ')) {
      caloriesPerKilogram = 33;
      proteinPerKilogram = 1.8;
      goalLabel = 'Μυϊκή ανάπτυξη';
    } else if (goal.contains('δύναμ')) {
      caloriesPerKilogram = 32;
      proteinPerKilogram = 1.8;
      goalLabel = 'Δύναμη & αποκατάσταση';
    }

    if (trainingDays >= 5) caloriesPerKilogram += 1;
    var calories = (currentWeightKilograms * caloriesPerKilogram).round().clamp(
      1500,
      4200,
    );
    if (!isTrainingDay) {
      calories = (calories * .9).round().clamp(1500, 4200);
      goalLabel = '$goalLabel • Rest day';
    } else {
      goalLabel = '$goalLabel • Training day';
    }
    final protein = currentWeightKilograms * proteinPerKilogram;
    final fat = currentWeightKilograms * .8;
    final carbohydrateCalories = calories - protein * 4 - fat * 9;
    final carbohydrates = (carbohydrateCalories / 4).clamp(80, 700).toDouble();

    return NutritionTargets(
      calories: calories,
      proteinGrams: protein,
      carbohydrateGrams: carbohydrates,
      fatGrams: fat,
      fiberGrams: (calories / 1000 * 14).clamp(25, 45).toDouble(),
      sodiumLimitMilligrams: 2300,
      goalLabel: goalLabel,
      isTrainingDay: isTrainingDay,
    );
  }

  static NutritionCoachMessage coach({
    required NutritionTargets targets,
    required int calories,
    required double protein,
  }) {
    if (calories == 0) {
      return const NutritionCoachMessage(
        headline: 'Ξεκίνα με την πρωτεΐνη',
        detail:
            'Κατάγραψε το πρώτο γεύμα και μοίρασε την πρωτεΐνη σε 3–5 γεύματα.',
      );
    }
    final caloriesLeft = targets.calories - calories;
    final proteinLeft = targets.proteinGrams - protein;
    if (caloriesLeft < -targets.calories * .1) {
      return NutritionCoachMessage(
        headline: 'Πέρασες τον στόχο θερμίδων',
        detail:
            'Δεν χρειάζεται τιμωρία. Επίλεξε απλό επόμενο γεύμα και συνέχισε κανονικά αύριο.',
      );
    }
    if (proteinLeft > 25 && caloriesLeft < 350) {
      return NutritionCoachMessage(
        headline: 'Χρειάζεσαι πυκνή πρωτεΐνη',
        detail:
            'Μένουν ${proteinLeft.round()} g πρωτεΐνης με λίγες θερμίδες διαθέσιμες.',
      );
    }
    if (caloriesLeft <= 0 && proteinLeft <= 10) {
      return const NutritionCoachMessage(
        headline: 'Ο ημερήσιος στόχος καλύφθηκε',
        detail:
            'Σταμάτα όταν χορτάσεις· η συνέπεια μετρά περισσότερο από την ακρίβεια.',
      );
    }
    return NutritionCoachMessage(
      headline: 'Υπόλοιπο ημέρας',
      detail:
          '${caloriesLeft.clamp(0, 9999).round()} kcal και '
          '${proteinLeft.clamp(0, 999).round()} g πρωτεΐνης μέχρι τον στόχο.',
    );
  }
}
