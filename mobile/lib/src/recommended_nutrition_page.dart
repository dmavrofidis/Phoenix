import 'package:flutter/material.dart';

import 'phoenix_l10n.dart';
import 'recommended_nutrition_engine.dart';
import 'state/fitness_store.dart';

class RecommendedNutritionPage extends StatefulWidget {
  const RecommendedNutritionPage({super.key, required this.store, this.now});

  final FitnessStore store;
  final DateTime? now;

  @override
  State<RecommendedNutritionPage> createState() =>
      _RecommendedNutritionPageState();
}

class _RecommendedNutritionPageState extends State<RecommendedNutritionPage> {
  late int _selectedDay;

  FitnessStore get store => widget.store;

  DateTime get _today {
    final value = widget.now ?? DateTime.now();
    return DateTime(value.year, value.month, value.day);
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _today.weekday - 1;
  }

  RecommendedNutritionWeek _week() {
    final start = _today.subtract(Duration(days: _today.weekday - 1));
    final preferences = store.preferences;
    return RecommendedNutritionEngine.buildWeek(
      startDate: start,
      targetsForDate: store.nutritionTargetsForDate,
      dietStyle: preferences.nutritionDietStyle,
      mealsPerDay: preferences.nutritionMealsPerDay,
      budgetMode: preferences.nutritionBudgetMode,
      quickPrep: preferences.nutritionQuickPrep,
      noCooking: preferences.nutritionNoCooking,
    );
  }

  Future<void> _update({
    String? dietStyle,
    int? mealsPerDay,
    String? budgetMode,
    bool? quickPrep,
    bool? noCooking,
  }) async {
    await store.updateNutritionPlanPreferences(
      dietStyle: dietStyle,
      mealsPerDay: mealsPerDay,
      budgetMode: budgetMode,
      quickPrep: quickPrep,
      noCooking: noCooking,
    );
    if (mounted) setState(() {});
  }

  Future<void> _logMeal(RecommendedMeal meal) async {
    final isEnglish = context.l10n.isEnglish;
    await store.addMeal(
      name: isEnglish ? meal.titleEnglish : meal.titleGreek,
      calories: meal.calories,
      proteinGrams: meal.proteinGrams,
      carbohydrateGrams: meal.carbohydrateGrams,
      fatGrams: meal.fatGrams,
      fiberGrams: meal.fiberGrams,
      sodiumMilligrams: 0,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.text(
            'Το προτεινόμενο γεύμα καταγράφηκε.',
            'Suggested meal logged.',
          ),
        ),
        action: SnackBarAction(
          label: context.l10n.text('ΑΝΑΙΡΕΣΗ', 'UNDO'),
          onPressed: store.undoLastMutation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final preferences = store.preferences;
    final week = _week();
    final selected = week.days[_selectedDay.clamp(0, 6)];
    final profileGoal =
        store.profile?.goal ??
        l.text('Γενική φυσική κατάσταση', 'General fitness');
    return Scaffold(
      appBar: AppBar(
        title: Text(l.text('Το διατροφικό μου πλάνο', 'My meal plan')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: .15),
                  Theme.of(context).colorScheme.surfaceContainer,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: .2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: .14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.ramen_dining_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l.text('Έτοιμο για εσένα', 'Built for you'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.text(
                      'Απλό εβδομαδιαίο πρόγραμμα για $profileGoal',
                      'A simple weekly plan for $profileGoal',
                    ),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.text(
                      'Οι ποσότητες προσαρμόζονται αυτόματα στο βάρος, τον στόχο και τις ημέρες προπόνησής σου.',
                      'Portions adapt automatically to your weight, goal and training days.',
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ExpansionTile(
              key: const ValueKey('nutrition-plan-options'),
              leading: const Icon(Icons.tune_rounded),
              title: Text(
                l.text('Οι επιλογές μου', 'My choices'),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              subtitle: Text(
                l.text(
                  '${_dietLabel(l, preferences.nutritionDietStyle)} • ${preferences.nutritionMealsPerDay} γεύματα',
                  '${_dietLabel(l, preferences.nutritionDietStyle)} • ${preferences.nutritionMealsPerDay} meals',
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.text('Τρόπος διατροφής', 'Eating style')),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final style
                              in RecommendedNutritionEngine.supportedDietStyles)
                            ChoiceChip(
                              label: Text(_dietLabel(l, style)),
                              selected: preferences.nutritionDietStyle == style,
                              onSelected: (_) => _update(dietStyle: style),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(l.text('Γεύματα την ημέρα', 'Meals per day')),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final count in const [3, 4, 5])
                            ChoiceChip(
                              label: Text('$count'),
                              selected:
                                  preferences.nutritionMealsPerDay == count,
                              onSelected: (_) => _update(mealsPerDay: count),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(l.text('Κόστος', 'Budget')),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text(l.text('Κανονικό', 'Standard')),
                            selected:
                                preferences.nutritionBudgetMode == 'standard',
                            onSelected: (_) => _update(budgetMode: 'standard'),
                          ),
                          ChoiceChip(
                            label: Text(l.text('Οικονομικό', 'Economy')),
                            selected:
                                preferences.nutritionBudgetMode == 'economy',
                            onSelected: (_) => _update(budgetMode: 'economy'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: preferences.nutritionQuickPrep,
                        onChanged: (value) => _update(quickPrep: value),
                        secondary: const Icon(Icons.timer_outlined),
                        title: Text(
                          l.text('Γρήγορη προετοιμασία', 'Quick prep'),
                        ),
                        subtitle: Text(
                          l.text(
                            'Προτίμηση σε γεύματα έως 15 λεπτά.',
                            'Prefer meals that take up to 15 minutes.',
                          ),
                        ),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: preferences.nutritionNoCooking,
                        onChanged: (value) => _update(
                          noCooking: value,
                          quickPrep: value ? true : null,
                        ),
                        secondary: const Icon(Icons.no_food_outlined),
                        title: Text(l.text('Χωρίς μαγείρεμα', 'No cooking')),
                        subtitle: Text(
                          l.text(
                            'Έτοιμα υλικά και γεύματα που στήνονται σε έως 5 λεπτά.',
                            'Ready ingredients and meals assembled in up to 5 minutes.',
                          ),
                        ),
                      ),
                      Text(
                        l.text(
                          'Οι επιλογές αποθηκεύονται μόνο σε αυτή τη συσκευή.',
                          'Your choices stay only on this device.',
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l.text('Η εβδομάδα μου', 'My week'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var index = 0; index < week.days.length; index++) ...[
                  ChoiceChip(
                    label: Text(_dayLabel(l, week.days[index].date)),
                    selected: _selectedDay == index,
                    avatar: week.days[index].targets.isTrainingDay
                        ? const Icon(Icons.fitness_center, size: 16)
                        : const Icon(Icons.bedtime_outlined, size: 16),
                    onSelected: (_) => setState(() => _selectedDay = index),
                  ),
                  const SizedBox(width: 7),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _DaySummary(day: selected),
          const SizedBox(height: 12),
          for (final meal in selected.meals) ...[
            _MealCard(meal: meal, onLog: () => _logMeal(meal)),
            const SizedBox(height: 10),
          ],
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.shopping_basket_outlined),
              title: Text(
                l.text('Λίστα αγορών 7 ημερών', '7-day grocery list'),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                l.text(
                  '${week.groceryItems.length} βασικά τρόφιμα',
                  '${week.groceryItems.length} basic foods',
                ),
              ),
              children: [
                for (final item in week.groceryItems)
                  ListTile(
                    dense: true,
                    title: Text(
                      l.isEnglish ? item.englishName : item.greekName,
                    ),
                    trailing: Text('${item.grams} g'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.health_and_safety_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l.text(
                        'Το πλάνο είναι πρακτική εκτίμηση, όχι ιατρική δίαιτα. Αλλεργίες, εγκυμοσύνη, νεφρική νόσος, διαβήτης ή ειδικές ανάγκες απαιτούν επαγγελματία υγείας. Μην τρως κάτι που δεν σου ταιριάζει.',
                        'This plan is a practical estimate, not medical nutrition therapy. Allergies, pregnancy, kidney disease, diabetes or special needs require a health professional. Never eat something that is unsafe for you.',
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _dietLabel(PhoenixL10n l, String style) => switch (style) {
    'mediterranean' => l.text('Μεσογειακή', 'Mediterranean'),
    'vegetarian' => l.text('Χορτοφαγική', 'Vegetarian'),
    'vegan' => l.text('Αυστηρά χορτοφαγική', 'Vegan'),
    _ => l.text('Ισορροπημένη', 'Balanced'),
  };

  static String _dayLabel(PhoenixL10n l, DateTime date) {
    const greek = ['ΔΕΥ', 'ΤΡΙ', 'ΤΕΤ', 'ΠΕΜ', 'ΠΑΡ', 'ΣΑΒ', 'ΚΥΡ'];
    const english = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final names = l.isEnglish ? english : greek;
    return '${names[date.weekday - 1]} ${date.day}';
  }
}

class _DaySummary extends StatelessWidget {
  const _DaySummary({required this.day});

  final RecommendedNutritionDay day;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final calorieDelta = day.estimatedCalories - day.targets.calories;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  day.targets.isTrainingDay
                      ? Icons.fitness_center
                      : Icons.bedtime_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    day.targets.isTrainingDay
                        ? l.text('Ημέρα προπόνησης', 'Training day')
                        : l.text('Ημέρα ξεκούρασης', 'Rest day'),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Text(
                  '${day.targets.calories} kcal',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l.text(
                '${day.meals.length} γεύματα • περίπου ${day.estimatedCalories} kcal • ${day.estimatedProtein.round()} g πρωτεΐνη',
                '${day.meals.length} meals • about ${day.estimatedCalories} kcal • ${day.estimatedProtein.round()} g protein',
              ),
            ),
            if (calorieDelta.abs() > day.targets.calories * .1) ...[
              const SizedBox(height: 6),
              Text(
                l.text(
                  'Ρύθμισε ελαφρά τις μερίδες σύμφωνα με την πείνα σου.',
                  'Adjust portions slightly according to your hunger.',
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, required this.onLog});

  final RecommendedMeal meal;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.isEnglish ? meal.slotEnglish : meal.slotGreek,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              l.isEnglish ? meal.titleEnglish : meal.titleGreek,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            for (final ingredient in meal.ingredients)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '• ${l.isEnglish ? ingredient.englishName : ingredient.greekName} — ${ingredient.grams} g',
                ),
              ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _MetricChip(label: '${meal.calories} kcal'),
                _MetricChip(
                  label: l.text(
                    '${meal.proteinGrams.round()} g πρωτεΐνη',
                    '${meal.proteinGrams.round()} g protein',
                  ),
                ),
                _MetricChip(
                  label: l.text(
                    '${meal.prepMinutes} λεπτά',
                    '${meal.prepMinutes} min',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onLog,
                icon: const Icon(Icons.add_circle_outline),
                label: Text(l.text('Καταγραφή γεύματος', 'Log meal')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: const TextStyle(fontSize: 11)),
  );
}
