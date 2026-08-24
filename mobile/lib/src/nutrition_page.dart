import 'dart:math' as math;
import 'dart:convert';

import 'package:flutter/material.dart';

import 'models/fitness_models.dart';
import 'nutrition_pro_widgets.dart';
import 'nutrition_planner_page.dart';
import 'photo_meal_scan_page.dart';
import 'phoenix_copy.dart';
import 'phoenix_l10n.dart';
import 'recommended_nutrition_page.dart';
import 'state/fitness_store.dart';

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key, required this.store});

  final FitnessStore store;

  Future<void> _addMeal(BuildContext context) async {
    final input = await showModalBottomSheet<_MealInput>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _MealEntrySheet(),
    );
    if (input == null || !context.mounted) return;
    try {
      await store.addMeal(
        name: input.name,
        calories: input.calories,
        proteinGrams: input.protein,
        carbohydrateGrams: input.carbohydrates,
        fatGrams: input.fat,
        fiberGrams: input.fiber,
        sodiumMilligrams: input.sodium,
      );
      if (input.saveAsPreset) {
        await store.createMealPreset(
          name: input.name,
          calories: input.calories,
          proteinGrams: input.protein,
          carbohydrateGrams: input.carbohydrates,
          fatGrams: input.fat,
          fiberGrams: input.fiber,
          sodiumMilligrams: input.sodium,
          ingredients: input.ingredients,
        );
      }
    } on FormatException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.text('Διατροφή', 'Nutrition'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.text(
                      'Στόχοι, θρεπτικά στοιχεία και καθοδήγηση — όλα στη συσκευή σου.',
                      'Targets, macros and guidance — all local.',
                    ),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .55),
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filled(
              tooltip: context.l10n.text(
                'Καταγραφή γεύματος με φωτογραφία',
                'Photo meal scan',
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PhotoMealScanPage(store: store),
                ),
              ),
              icon: const Icon(Icons.camera_alt_outlined),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: context.l10n.text(
                'Προγραμματισμός διατροφής',
                'Nutrition planner',
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => NutritionPlannerPage(store: store),
                ),
              ),
              icon: const Icon(Icons.calendar_view_week),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: context.l10n.text('Προσθήκη γεύματος', 'Add meal'),
              onPressed: () => _addMeal(context),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _DailyNutritionCard(store: store),
        const SizedBox(height: 12),
        _RecommendedPlanCard(store: store),
        const SizedBox(height: 12),
        HydrationCard(store: store),
        const SizedBox(height: 12),
        MealPresetsCard(store: store),
        const SizedBox(height: 12),
        MicronutrientCard(store: store),
        const SizedBox(height: 12),
        _MacroChart(
          protein: store.proteinToday,
          carbohydrates: store.carbohydratesToday,
          fat: store.fatToday,
        ),
        const SizedBox(height: 12),
        WeeklyNutritionCard(store: store),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.text(
                  'Τα σημερινά γεύματα',
                  'Today’s meal timeline',
                ),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              '${store.todaysMeals.length}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (store.todaysMeals.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.restaurant_outlined,
                    size: 36,
                    color: Colors.white.withValues(alpha: .35),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.text(
                      'Δεν έχει καταγραφεί γεύμα σήμερα.',
                      'No meals logged today.',
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          for (final meal in store.todaysMealsChronological) ...[
            _MealTile(
              meal: meal,
              onDelete: () async {
                await store.removeMeal(meal);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.l10n.text(
                        'Το γεύμα διαγράφηκε.',
                        'Meal deleted.',
                      ),
                    ),
                    action: SnackBarAction(
                      label: context.l10n.text('ΑΝΑΙΡΕΣΗ', 'UNDO'),
                      onPressed: store.undoLastMutation,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        const SizedBox(height: 18),
        Text(
          context.l10n.text(
            'Οι στόχοι είναι συντηρητική αρχική εκτίμηση από βάρος, στόχο και '
                'συχνότητα προπόνησης — όχι ιατρική ή διαιτολογική σύσταση.',
            'Targets are a conservative estimate based on weight, goal and '
                'training frequency — not medical or dietary advice.',
          ),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: .42),
          ),
        ),
      ],
    );
  }
}

class _RecommendedPlanCard extends StatelessWidget {
  const _RecommendedPlanCard({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final preferences = store.preferences;
    final style = switch (preferences.nutritionDietStyle) {
      'mediterranean' => l.text('Μεσογειακή', 'Mediterranean'),
      'vegetarian' => l.text('Χορτοφαγική', 'Vegetarian'),
      'vegan' => l.text('Αυστηρά χορτοφαγική', 'Vegan'),
      _ => l.text('Ισορροπημένη', 'Balanced'),
    };
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => RecommendedNutritionPage(store: store),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.text(
                        'Το δικό σου πρόγραμμα διατροφής',
                        'Your recommended meal plan',
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.text(
                        '$style • ${preferences.nutritionMealsPerDay} γεύματα • λίστα αγορών',
                        '$style • ${preferences.nutritionMealsPerDay} meals • grocery list',
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.savings_outlined, size: 16),
                          label: Text(l.text('Οικονομικό', 'Economy')),
                          onPressed: () => store.updateNutritionPlanPreferences(
                            budgetMode: 'economy',
                          ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.timer_outlined, size: 16),
                          label: Text(l.text('Γρήγορο', 'Quick')),
                          onPressed: () => store.updateNutritionPlanPreferences(
                            quickPrep: true,
                            noCooking: false,
                          ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.no_food_outlined, size: 16),
                          label: Text(l.text('Χωρίς μαγείρεμα', 'No cooking')),
                          onPressed: () => store.updateNutritionPlanPreferences(
                            quickPrep: true,
                            noCooking: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyNutritionCard extends StatelessWidget {
  const _DailyNutritionCard({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final targets = store.nutritionTargets;
    final coach = store.nutritionCoach;
    final calorieProgress = (store.caloriesToday / targets.calories)
        .clamp(0, 1.2)
        .toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.text('Σημερινός στόχος', 'Today’s target'),
                    style: const TextStyle(
                      color: Color(0xFFFF3D00),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Text(
                  targets.goalLabel.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFFF9E80),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${store.caloriesToday}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 5),
                  child: Text(
                    '/ ${targets.calories} kcal',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .5),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${(calorieProgress * 100).round().clamp(0, 999)}%',
                  style: const TextStyle(
                    color: Color(0xFFFF9E80),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: calorieProgress.clamp(0, 1),
                minHeight: 9,
                backgroundColor: Colors.white.withValues(alpha: .08),
                color: calorieProgress > 1
                    ? const Color(0xFFFFB74D)
                    : const Color(0xFFFF3D00),
              ),
            ),
            const SizedBox(height: 18),
            _MacroValue(
              label: context.l10n.text('Πρωτεΐνη', 'Protein'),
              value: store.proteinToday,
              target: targets.proteinGrams,
              color: const Color(0xFFFF3D00),
            ),
            const SizedBox(height: 10),
            _MacroValue(
              label: context.l10n.text('Υδατάνθρακες', 'Carbohydrates'),
              value: store.carbohydratesToday,
              target: targets.carbohydrateGrams,
              color: const Color(0xFFFFA000),
            ),
            const SizedBox(height: 10),
            _MacroValue(
              label: context.l10n.text('Λιπαρά', 'Fat'),
              value: store.fatToday,
              target: targets.fatGrams,
              color: const Color(0xFFB0BEC5),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6E40).withValues(alpha: .08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFFFF9E80),
                    size: 19,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coach.headline,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          coach.detail,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .58),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroValue extends StatelessWidget {
  const _MacroValue({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  final String label;
  final double value;
  final double target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = target <= 0
        ? 0.0
        : (value / target).clamp(0, 1).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .58),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${value.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} g',
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: .07),
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MacroChart extends StatelessWidget {
  const _MacroChart({
    required this.protein,
    required this.carbohydrates,
    required this.fat,
  });

  final double protein;
  final double carbohydrates;
  final double fat;

  @override
  Widget build(BuildContext context) {
    final totalEnergy = protein * 4 + carbohydrates * 4 + fat * 9;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Semantics(
              label: totalEnergy == 0
                  ? 'Δεν υπάρχουν θρεπτικά στοιχεία σήμερα.'
                  : 'Κατανομή θρεπτικών στοιχείων: ${protein.toStringAsFixed(1)} γραμμάρια '
                        'πρωτεΐνη, ${carbohydrates.toStringAsFixed(1)} γραμμάρια '
                        'υδατάνθρακες και ${fat.toStringAsFixed(1)} γραμμάρια '
                        'λιπαρά.',
              child: SizedBox.square(
                dimension: 130,
                child: CustomPaint(
                  painter: _MacroRingPainter(
                    protein: protein,
                    carbohydrates: carbohydrates,
                    fat: fat,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.text(
                      'Κατανομή θρεπτικών στοιχείων',
                      'Macro distribution',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  const _LegendDot(
                    color: Color(0xFFFF3D00),
                    label: 'Πρωτεΐνη · 4 kcal/g',
                  ),
                  const _LegendDot(
                    color: Color(0xFFFFA000),
                    label: 'Υδατάνθρακες · 4 kcal/g',
                  ),
                  const _LegendDot(
                    color: Color(0xFFB0BEC5),
                    label: 'Λιπαρά · 9 kcal/g',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

class _MacroRingPainter extends CustomPainter {
  const _MacroRingPainter({
    required this.protein,
    required this.carbohydrates,
    required this.fat,
  });

  final double protein;
  final double carbohydrates;
  final double fat;

  @override
  void paint(Canvas canvas, Size size) {
    final values = [protein * 4, carbohydrates * 4, fat * 9];
    final total = values.fold<double>(0, (sum, value) => sum + value);
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .36;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final basePaint = Paint()
      ..color = Colors.white.withValues(alpha: .08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    canvas.drawCircle(center, radius, basePaint);
    if (total <= 0) return;

    const colors = [Color(0xFFFF3D00), Color(0xFFFFA000), Color(0xFFB0BEC5)];
    var start = -math.pi / 2;
    for (var index = 0; index < values.length; index++) {
      final sweep = math.pi * 2 * values[index] / total;
      canvas.drawArc(
        rect,
        start,
        math.max(0, sweep - .035),
        false,
        Paint()
          ..color = colors[index]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 18
          ..strokeCap = StrokeCap.butt,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _MacroRingPainter oldDelegate) =>
      oldDelegate.protein != protein ||
      oldDelegate.carbohydrates != carbohydrates ||
      oldDelegate.fat != fat;
}

class _MealTile extends StatelessWidget {
  const _MealTile({required this.meal, required this.onDelete});

  final MealEntry meal;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: meal.photoEncodedBytes.isEmpty
              ? null
              : MemoryImage(base64Decode(meal.photoEncodedBytes)),
          child: meal.photoEncodedBytes.isNotEmpty
              ? null
              : Text(
                  '${meal.loggedAt.hour.toString().padLeft(2, '0')}:'
                  '${meal.loggedAt.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
        title: Text(PhoenixCopy.mealName(context.l10n, meal)),
        subtitle: Text(
          'Π ${meal.proteinGrams.toStringAsFixed(1)}  •  '
          'Υ ${meal.carbohydrateGrams.toStringAsFixed(1)}  •  '
          'Λ ${meal.fatGrams.toStringAsFixed(1)} g\n'
          'Ίνες ${meal.fiberGrams.toStringAsFixed(1)} g  •  '
          'Νάτριο ${meal.sodiumMilligrams.toStringAsFixed(0)} mg',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${meal.calories} kcal',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            IconButton(
              tooltip: context.l10n.text('Διαγραφή γεύματος', 'Delete meal'),
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealInput {
  const _MealInput({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.fiber,
    required this.sodium,
    required this.saveAsPreset,
    required this.ingredients,
  });

  final String name;
  final int calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fiber;
  final double sodium;
  final bool saveAsPreset;
  final List<String> ingredients;
}

class _MealEntrySheet extends StatefulWidget {
  const _MealEntrySheet();

  @override
  State<_MealEntrySheet> createState() => _MealEntrySheetState();
}

class _MealEntrySheetState extends State<_MealEntrySheet> {
  final _name = TextEditingController();
  final _calories = TextEditingController();
  final _protein = TextEditingController();
  final _carbohydrates = TextEditingController();
  final _fat = TextEditingController();
  final _fiber = TextEditingController();
  final _sodium = TextEditingController();
  final _ingredients = TextEditingController();
  bool _saveAsPreset = false;

  @override
  void dispose() {
    _name.dispose();
    _calories.dispose();
    _protein.dispose();
    _carbohydrates.dispose();
    _fat.dispose();
    _fiber.dispose();
    _sodium.dispose();
    _ingredients.dispose();
    super.dispose();
  }

  double _number(TextEditingController controller) =>
      double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;

  void _submit() {
    Navigator.of(context).pop(
      _MealInput(
        name: _name.text,
        calories: int.tryParse(_calories.text) ?? 0,
        protein: _number(_protein),
        carbohydrates: _number(_carbohydrates),
        fat: _number(_fat),
        fiber: _number(_fiber),
        sodium: _number(_sodium),
        saveAsPreset: _saveAsPreset,
        ingredients: _ingredients.text
            .split(',')
            .map((ingredient) => ingredient.trim())
            .where((ingredient) => ingredient.isNotEmpty)
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Καταγραφή γεύματος',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Όνομα γεύματος',
                hintText: 'π.χ. Πρωινό',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _calories,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Θερμίδες',
                suffixText: 'kcal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MacroField(controller: _protein, label: 'Πρωτεΐνη'),
                const SizedBox(width: 8),
                _MacroField(controller: _carbohydrates, label: 'Υδατ/κες'),
                const SizedBox(width: 8),
                _MacroField(controller: _fat, label: 'Λιπαρά'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MacroField(controller: _fiber, label: 'Φυτικές ίνες'),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _sodium,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Νάτριο',
                      suffixText: 'mg',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _saveAsPreset,
              onChanged: (value) => setState(() => _saveAsPreset = value),
              title: const Text('Αποθήκευση ως έτοιμο γεύμα'),
              subtitle: const Text(
                'Θα μπορείς να το καταγράφεις ξανά με ένα άγγιγμα.',
              ),
            ),
            if (_saveAsPreset) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _ingredients,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Υλικά για λίστα αγορών',
                  hintText: 'π.χ. κοτόπουλο, ρύζι, μπρόκολο',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.add),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Αποθήκευση γεύματος'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroField extends StatelessWidget {
  const _MacroField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffixText: 'g',
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
