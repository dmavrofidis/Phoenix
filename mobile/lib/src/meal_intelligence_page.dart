import 'package:flutter/material.dart';

import 'meal_intelligence_engine.dart';
import 'state/fitness_store.dart';

class MealIntelligencePage extends StatefulWidget {
  const MealIntelligencePage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<MealIntelligencePage> createState() => _MealIntelligencePageState();
}

class _MealIntelligencePageState extends State<MealIntelligencePage> {
  final _recipeName = TextEditingController(text: 'Phoenix power bowl');
  final List<IngredientPortion> _portions = [
    const IngredientPortion(ingredientId: 'greek-yogurt', grams: 250),
    const IngredientPortion(ingredientId: 'oats', grams: 60),
    const IngredientPortion(ingredientId: 'berries', grams: 120),
  ];
  String _ingredientId = 'banana';
  int _ingredientGrams = 100;
  int _originalServings = 2;
  int _targetServings = 4;
  String _pantryIngredientId = 'chicken-breast';
  int _pantryQuantity = 500;
  double _pantryCost = 1;
  int _expiryDays = 3;
  int _batchServings = 5;
  bool _saving = false;

  FitnessStore get store => widget.store;

  @override
  void dispose() {
    _recipeName.dispose();
    super.dispose();
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  void _addIngredient() {
    setState(() {
      final index = _portions.indexWhere(
        (item) => item.ingredientId == _ingredientId,
      );
      if (index == -1) {
        _portions.add(
          IngredientPortion(
            ingredientId: _ingredientId,
            grams: _ingredientGrams.toDouble(),
          ),
        );
      } else {
        final current = _portions[index];
        _portions[index] = IngredientPortion(
          ingredientId: current.ingredientId,
          grams: current.grams + _ingredientGrams,
        );
      }
    });
  }

  Future<void> _logServing() async {
    if (_saving || _portions.isEmpty) return;
    setState(() => _saving = true);
    try {
      final servingPortions = MealIntelligenceEngine.scaleRecipe(
        portions: _portions,
        originalServings: _originalServings,
        targetServings: 1,
      );
      final nutrition = MealIntelligenceEngine.recipeNutrition(servingPortions);
      await store.addMeal(
        name: _recipeName.text.trim().isEmpty
            ? 'Ingredient recipe'
            : _recipeName.text.trim(),
        calories: nutrition.calories,
        proteinGrams: nutrition.proteinGrams,
        carbohydrateGrams: nutrition.carbohydrateGrams,
        fatGrams: nutrition.fatGrams,
        fiberGrams: nutrition.fiberGrams,
        sodiumMilligrams: nutrition.sodiumMilligrams,
      );
      if (mounted) _message('One calculated serving logged.');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _savePantry() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final ingredient = MealIntelligenceEngine.ingredient(_pantryIngredientId);
      await store.savePantryItem(
        ingredientId: ingredient.id,
        name: ingredient.name,
        quantityGrams: _pantryQuantity.toDouble(),
        costPer100Grams: _pantryCost,
        expiresAt: DateTime.now().add(Duration(days: _expiryDays)),
      );
      if (mounted) _message('${ingredient.name} saved to pantry.');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('MEAL INTELLIGENCE'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'BUILDER', icon: Icon(Icons.calculate_outlined)),
            Tab(text: 'LIBRARY', icon: Icon(Icons.favorite_border)),
            Tab(text: 'PANTRY', icon: Icon(Icons.kitchen_outlined)),
            Tab(text: 'BUDGET & PREP', icon: Icon(Icons.soup_kitchen_outlined)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => TabBarView(
          children: [
            _builderTab(context),
            _libraryTab(context),
            _pantryTab(context),
            _budgetTab(context),
          ],
        ),
      ),
    ),
  );

  Widget _builderTab(BuildContext context) {
    final total = MealIntelligenceEngine.recipeNutrition(_portions);
    final perServing = MealIntelligenceEngine.recipeNutrition(
      MealIntelligenceEngine.scaleRecipe(
        portions: _portions,
        originalServings: _originalServings,
        targetServings: 1,
      ),
    );
    final scaled = MealIntelligenceEngine.scaleRecipe(
      portions: _portions,
      originalServings: _originalServings,
      targetServings: _targetServings,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _MealHero(
          icon: Icons.calculate_outlined,
          title: 'INGREDIENT-LEVEL MEAL BUILDER',
          detail:
              'Build from weighed ingredients, calculate real macros and scale the recipe without retyping.',
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _recipeName,
          decoration: const InputDecoration(labelText: 'RECIPE NAME'),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _ingredientId,
          decoration: const InputDecoration(labelText: 'INGREDIENT'),
          items: [
            for (final item in MealIntelligenceEngine.catalog)
              DropdownMenuItem(value: item.id, child: Text(item.name)),
          ],
          onChanged: (value) =>
              setState(() => _ingredientId = value ?? _ingredientId),
        ),
        _MealSlider(
          label: 'PORTION',
          value: _ingredientGrams,
          minimum: 10,
          maximum: 500,
          suffix: 'g',
          onChanged: (value) => setState(() => _ingredientGrams = value),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _addIngredient,
            icon: const Icon(Icons.add),
            label: const Text('ADD INGREDIENT'),
          ),
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < _portions.length; index++)
          Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${_portions[index].grams.round()}g'),
              ),
              title: Text(
                MealIntelligenceEngine.ingredient(
                  _portions[index].ingredientId,
                ).name,
              ),
              trailing: IconButton(
                tooltip: 'Remove ingredient',
                onPressed: () => setState(() => _portions.removeAt(index)),
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        const SizedBox(height: 12),
        _NutritionSummary(
          title: 'RECIPE TOTAL • ${total.totalWeightGrams.round()}G',
          nutrition: total,
        ),
        _MealSlider(
          label: 'ORIGINAL SERVINGS',
          value: _originalServings,
          minimum: 1,
          maximum: 12,
          suffix: '',
          onChanged: (value) => setState(() => _originalServings = value),
        ),
        _NutritionSummary(title: 'PER SERVING', nutrition: perServing),
        _MealSlider(
          label: 'SCALE TO',
          value: _targetServings,
          minimum: 1,
          maximum: 12,
          suffix: 'servings',
          onChanged: (value) => setState(() => _targetServings = value),
        ),
        Card(
          child: ExpansionTile(
            title: Text('SCALED RECIPE • $_targetServings SERVINGS'),
            children: [
              for (final portion in scaled)
                ListTile(
                  dense: true,
                  title: Text(
                    MealIntelligenceEngine.ingredient(
                      portion.ingredientId,
                    ).name,
                  ),
                  trailing: Text('${portion.grams.round()}g'),
                ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _saving || _portions.isEmpty ? null : _logServing,
            icon: const Icon(Icons.restaurant_outlined),
            label: const Text('LOG ONE SERVING'),
          ),
        ),
      ],
    );
  }

  Widget _libraryTab(BuildContext context) {
    final recent = MealIntelligenceEngine.recentFoods(store.data.meals);
    final favorites = store.favoriteIngredientIds.toSet();
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _MealHero(
          icon: Icons.favorite_border,
          title: 'FAVORITES & RECENT FOODS',
          detail:
              'Pin common ingredients and duplicate a recent meal with one deliberate action.',
        ),
        const SizedBox(height: 16),
        Text(
          'FAVORITE INGREDIENT LIBRARY',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final item in MealIntelligenceEngine.catalog)
          Card(
            child: ListTile(
              leading: Icon(
                favorites.contains(item.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: favorites.contains(item.id) ? Colors.redAccent : null,
              ),
              title: Text(item.name),
              subtitle: Text(
                '${item.category} • ${item.caloriesPer100Grams.round()} kcal/100g',
              ),
              onTap: () async {
                await store.toggleFavoriteIngredient(item.id);
              },
            ),
          ),
        const SizedBox(height: 18),
        Text(
          'RECENT-FOOD SHORTCUTS',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (recent.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.history),
              title: Text('NO RECENT MEALS'),
              subtitle: Text('Logged meals will appear here once per name.'),
            ),
          )
        else
          for (final meal in recent)
            Card(
              child: ListTile(
                leading: const Icon(Icons.history),
                title: Text(meal.name),
                subtitle: Text(
                  '${meal.calories} kcal • ${meal.proteinGrams.round()}g protein',
                ),
                trailing: IconButton(
                  tooltip: 'Duplicate meal',
                  onPressed: () async {
                    await store.duplicateMeal(meal);
                    if (mounted) _message('${meal.name} duplicated.');
                  },
                  icon: const Icon(Icons.copy),
                ),
              ),
            ),
      ],
    );
  }

  Widget _pantryTab(BuildContext context) {
    final reminders = MealIntelligenceEngine.expiryReminders(
      store.pantryItems,
      now: DateTime.now(),
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _MealHero(
          icon: Icons.kitchen_outlined,
          title: 'PANTRY INVENTORY & EXPIRY',
          detail:
              'Track usable quantity, reference cost and expiry so meal planning starts with food already owned.',
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _pantryIngredientId,
          decoration: const InputDecoration(labelText: 'PANTRY INGREDIENT'),
          items: [
            for (final item in MealIntelligenceEngine.catalog)
              DropdownMenuItem(value: item.id, child: Text(item.name)),
          ],
          onChanged: (value) => setState(
            () => _pantryIngredientId = value ?? _pantryIngredientId,
          ),
        ),
        _MealSlider(
          label: 'QUANTITY',
          value: _pantryQuantity,
          minimum: 0,
          maximum: 3000,
          suffix: 'g',
          onChanged: (value) => setState(() => _pantryQuantity = value),
        ),
        _MealSlider(
          label: 'COST / 100G',
          value: (_pantryCost * 100).round(),
          minimum: 0,
          maximum: 500,
          suffix: '¢',
          onChanged: (value) => setState(() => _pantryCost = value / 100),
        ),
        _MealSlider(
          label: 'EXPIRES IN',
          value: _expiryDays,
          minimum: 0,
          maximum: 60,
          suffix: 'days',
          onChanged: (value) => setState(() => _expiryDays = value),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _saving ? null : _savePantry,
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('SAVE TO PANTRY'),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'EXPIRY-DATE REMINDERS',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (reminders.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.inventory_2_outlined),
              title: Text('PANTRY IS EMPTY'),
            ),
          )
        else
          for (final reminder in reminders)
            Card(
              color:
                  reminder.status == 'EXPIRED' || reminder.status == 'USE TODAY'
                  ? Theme.of(context).colorScheme.errorContainer
                  : null,
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${reminder.item.quantityGrams.round()}g'),
                ),
                title: Text(
                  '${reminder.item.name.toUpperCase()} • ${reminder.status}',
                ),
                subtitle: Text(reminder.action),
                trailing: IconButton(
                  tooltip: 'Remove pantry item',
                  onPressed: () => store.removePantryItem(reminder.item.id),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.health_and_safety_outlined),
            title: Text('FOOD-SAFETY OVERRIDE'),
            subtitle: Text(
              'Expiry reminders support stock rotation; packaging guidance, cold-chain safety and qualified public-health advice override the app.',
            ),
          ),
        ),
      ],
    );
  }

  Widget _budgetTab(BuildContext context) {
    final target = store.nutritionTargets;
    final suggestions = MealIntelligenceEngine.macroSuggestions(
      proteinRemaining: (target.proteinGrams - store.proteinToday).clamp(
        0,
        500,
      ),
      carbohydrateRemaining:
          (target.carbohydrateGrams - store.carbohydratesToday).clamp(0, 800),
      fatRemaining: (target.fatGrams - store.fatToday).clamp(0, 300),
      calorieRemaining: (target.calories - store.caloriesToday).clamp(0, 5000),
      pantry: store.pantryItems,
    );
    final batch = MealIntelligenceEngine.batchCooking(
      recipe: suggestions.first,
      servings: _batchServings,
      pantry: store.pantryItems,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _MealHero(
          icon: Icons.soup_kitchen_outlined,
          title: 'MACRO-AWARE BUDGET & BATCH PREP',
          detail:
              'Rank complete meals against remaining macros, pantry coverage and estimated grocery cost.',
        ),
        const SizedBox(height: 14),
        Text(
          'MACRO-AWARE MEAL SUGGESTIONS',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final suggestion in suggestions)
          Card(
            child: ExpansionTile(
              leading: CircleAvatar(child: Text('${suggestion.matchScore}')),
              title: Text(suggestion.name.toUpperCase()),
              subtitle: Text(
                '${suggestion.nutrition.calories} kcal • '
                '${suggestion.nutrition.proteinGrams.round()}P • '
                '${suggestion.nutrition.carbohydrateGrams.round()}C • '
                '${suggestion.nutrition.fatGrams.round()}F • '
                '${(suggestion.pantryCoverage * 100).round()}% pantry',
              ),
              children: [
                ListTile(title: Text(suggestion.reason)),
                for (final portion in suggestion.portions)
                  ListTile(
                    dense: true,
                    title: Text(
                      MealIntelligenceEngine.ingredient(
                        portion.ingredientId,
                      ).name,
                    ),
                    trailing: Text('${portion.grams.round()}g'),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 18),
        _MealSlider(
          label: 'BATCH SERVINGS',
          value: _batchServings,
          minimum: 2,
          maximum: 12,
          suffix: '',
          onChanged: (value) => setState(() => _batchServings = value),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${batch.name.toUpperCase()} • ${batch.servings} CONTAINERS',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  '${batch.perServing.calories} kcal and '
                  '${batch.perServing.proteinGrams.round()}g protein per serving',
                ),
                const Divider(height: 24),
                for (final step in batch.prepSteps)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Text('• $step'),
                  ),
                Text(
                  'STORAGE • ${batch.storageRule}',
                  style: const TextStyle(color: Colors.orangeAccent),
                ),
              ],
            ),
          ),
        ),
        Text(
          'BUDGET GROCERY MODE • ~€${batch.grocery.estimatedTotalCost.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final item in batch.grocery.items)
          Card(
            child: ListTile(
              title: Text(item.name),
              subtitle: Text(
                '${item.requiredGrams.round()}g needed • '
                '${item.pantryGrams.round()}g in pantry',
              ),
              trailing: Text(
                item.buyGrams <= 0
                    ? 'OWNED'
                    : '${item.buyGrams.round()}g\n€${item.estimatedCost.toStringAsFixed(2)}',
                textAlign: TextAlign.end,
              ),
            ),
          ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.savings_outlined),
            title: Text(
              'PANTRY SAVINGS • ~€${batch.grocery.pantrySavings.toStringAsFixed(2)}',
            ),
            subtitle: const Text(
              'Reference prices are planning estimates; edit pantry cost with your real receipt price.',
            ),
          ),
        ),
      ],
    );
  }
}

class _MealHero extends StatelessWidget {
  const _MealHero({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1F3D2C), Color(0xFF111820)],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.greenAccent.withValues(alpha: .2)),
    ),
    child: Row(
      children: [
        CircleAvatar(radius: 25, child: Icon(icon)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              Text(detail),
            ],
          ),
        ),
      ],
    ),
  );
}

class _NutritionSummary extends StatelessWidget {
  const _NutritionSummary({required this.title, required this.nutrition});

  final String title;
  final RecipeNutrition nutrition;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              _Macro(label: 'KCAL', value: '${nutrition.calories}'),
              _Macro(
                label: 'PROTEIN',
                value: '${nutrition.proteinGrams.toStringAsFixed(1)}g',
              ),
              _Macro(
                label: 'CARBS',
                value: '${nutrition.carbohydrateGrams.toStringAsFixed(1)}g',
              ),
              _Macro(
                label: 'FAT',
                value: '${nutrition.fatGrams.toStringAsFixed(1)}g',
              ),
              _Macro(
                label: 'FIBER',
                value: '${nutrition.fiberGrams.toStringAsFixed(1)}g',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _Macro extends StatelessWidget {
  const _Macro({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 9, color: Colors.white54)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
    ],
  );
}

class _MealSlider extends StatelessWidget {
  const _MealSlider({
    required this.label,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.suffix,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int minimum;
  final int maximum;
  final String suffix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),
      Text(
        '$label • $value $suffix',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      Slider(
        value: value.clamp(minimum, maximum).toDouble(),
        min: minimum.toDouble(),
        max: maximum.toDouble(),
        divisions: maximum - minimum,
        onChanged: (value) => onChanged(value.round()),
      ),
    ],
  );
}
