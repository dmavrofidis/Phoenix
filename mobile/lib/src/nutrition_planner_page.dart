import 'package:flutter/material.dart';

import 'nutrition_planner_engine.dart';
import 'state/fitness_store.dart';

class NutritionPlannerPage extends StatefulWidget {
  const NutritionPlannerPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<NutritionPlannerPage> createState() => _NutritionPlannerPageState();
}

class _NutritionPlannerPageState extends State<NutritionPlannerPage> {
  String _phase = 'Maintenance';
  int _proteinMeals = 4;
  int _trainingTime = 18 * 60;
  double _currentFiber = 18;
  String _sweatLevel = 'Medium';
  bool _hotConditions = false;
  int _trainingMinutes = 60;
  int _deficitWeeks = 8;
  int _readinessScore = 65;
  int _currentCalories = 1800;
  bool _saving = false;

  FitnessStore get store => widget.store;

  NutritionPhasePlan get _plan => NutritionPlannerEngine.phasePlan(
    weightKilograms: store.currentWeightKilograms,
    phase: _phase,
    trainingDaysPerWeek: store.profile?.daysPerWeek ?? 3,
  );

  Set<int> get _trainingWeekdays {
    final now = DateTime.now();
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    return {
      for (var offset = 0; offset < 7; offset++)
        if (store.isTrainingDayFor(monday.add(Duration(days: offset))))
          offset + 1,
    };
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _savePhase() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final plan = _plan;
      await store.saveNutritionPhase(
        phase: plan.phase,
        dailyCalories: plan.dailyCalories,
        durationWeeks: plan.durationWeeks,
        targetWeeklyChangePercent: plan.targetWeeklyChangePercent,
      );
      if (mounted) _message('Nutrition phase saved locally.');
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
        title: const Text('NUTRITION PLANNER'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'PHASE & WEEK', icon: Icon(Icons.calendar_view_week)),
            Tab(text: 'MACRO GUARDS', icon: Icon(Icons.donut_large)),
            Tab(text: 'TIMING & FLUIDS', icon: Icon(Icons.schedule)),
            Tab(text: 'BREAK & REVERSE', icon: Icon(Icons.swap_vert)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => TabBarView(
          children: [
            _phaseTab(context),
            _macroTab(context),
            _timingTab(context),
            _breakTab(context),
          ],
        ),
      ),
    ),
  );

  Widget _phaseTab(BuildContext context) {
    final plan = _plan;
    final budget = NutritionPlannerEngine.weeklyBudget(
      plan: plan,
      trainingWeekdays: _trainingWeekdays,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _PlannerHero(
          icon: Icons.calendar_view_week,
          title: 'GOAL-PHASE CALORIE PLANNER',
          detail:
              'Choose a phase, preserve a weekly budget and review the trend before changing intake.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final phase in NutritionPlannerEngine.phases)
              ChoiceChip(
                label: Text(phase.toUpperCase()),
                selected: phase == _phase,
                onSelected: (_) => setState(() {
                  _phase = phase;
                  _currentCalories = _plan.dailyCalories;
                }),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Metric(
              label: 'DAILY TARGET',
              value: '${plan.dailyCalories}',
              detail: 'KCAL',
            ),
            _Metric(
              label: 'MAINTENANCE',
              value: '${plan.maintenanceCalories}',
              detail: 'ESTIMATE',
            ),
            _Metric(
              label: 'WEEKLY RATE',
              value:
                  '${plan.targetWeeklyChangePercent >= 0 ? '+' : ''}${plan.targetWeeklyChangePercent.toStringAsFixed(2)}%',
              detail: 'BODY WEIGHT',
            ),
            _Metric(
              label: 'PHASE LENGTH',
              value: '${plan.durationWeeks}',
              detail: 'WEEKS',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('PHASE GUARDRAIL'),
            subtitle: Text(plan.guardrail),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _saving ? null : _savePhase,
            icon: const Icon(Icons.save_outlined),
            label: const Text('SAVE PHASE'),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'WEEKLY CALORIE BUDGET • ${budget.totalCalories} KCAL',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _WeeklyBudgetChart(budget: budget),
        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('THE WEEK IS THE BUDGET'),
            subtitle: Text(
              'Training days receive a small fuel bias while the seven-day total stays stable. No “earning” or “punishing” food.',
            ),
          ),
        ),
      ],
    );
  }

  Widget _macroTab(BuildContext context) {
    final plan = _plan;
    final protein = NutritionPlannerEngine.proteinDistribution(
      dailyProteinGrams: plan.proteinGrams,
      meals: _proteinMeals,
    );
    final carbs = NutritionPlannerEngine.carbTiming(
      dailyCarbohydrates: plan.carbohydrateGrams,
      isTrainingDay: true,
    );
    final fat = NutritionPlannerEngine.fatGuard(
      weightKilograms: store.currentWeightKilograms,
      dailyCalories: plan.dailyCalories,
      plannedFatGrams: plan.fatGrams,
    );
    final fiber = NutritionPlannerEngine.fiberProgression(
      currentGrams: _currentFiber,
      dailyCalories: plan.dailyCalories,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _PlannerHero(
          icon: Icons.donut_large,
          title: 'PROTEIN, CARBS, FAT & FIBER',
          detail:
              'Distribute protein, place useful carbohydrates and protect minimum fat and gradual fiber progression.',
        ),
        _PlannerSlider(
          label: 'PROTEIN MEALS',
          value: _proteinMeals,
          minimum: 3,
          maximum: 6,
          suffix: '',
          onChanged: (value) => setState(() => _proteinMeals = value),
        ),
        for (final meal in protein.meals)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${meal.grams.round()}g')),
              title: Text(meal.label),
              subtitle: Text('${meal.window} • ${meal.purpose}'),
            ),
          ),
        const SizedBox(height: 14),
        Text('CARB TIMING', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _MiniMetric(
                label: 'PRE',
                value: '${carbs.preWorkoutGrams.round()}g',
              ),
            ),
            Expanded(
              child: _MiniMetric(
                label: 'POST',
                value: '${carbs.postWorkoutGrams.round()}g',
              ),
            ),
            Expanded(
              child: _MiniMetric(
                label: 'OTHER',
                value: '${carbs.otherMealGrams.round()}g',
              ),
            ),
          ],
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.bolt),
            title: const Text('TRAINING-DAY CARBOHYDRATES'),
            subtitle: Text(carbs.guidance),
          ),
        ),
        const SizedBox(height: 14),
        _GuardCard(
          title:
              'FAT MINIMUM • ${fat.minimumGrams.toStringAsFixed(0)}g • ${fat.status}',
          detail: fat.action,
          alert: fat.shortfallGrams > 0,
        ),
        _PlannerSlider(
          label: 'CURRENT FIBER',
          value: _currentFiber.round(),
          minimum: 0,
          maximum: 50,
          suffix: 'g',
          onChanged: (value) =>
              setState(() => _currentFiber = value.toDouble()),
        ),
        Text(
          'FIBER TARGET PROGRESSION',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 105,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: fiber.steps.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) => SizedBox(
              width: 130,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WEEK ${fiber.steps[index].week}'),
                      const Spacer(),
                      Text(
                        '${fiber.steps[index].targetGrams.toStringAsFixed(0)}g',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Text(fiber.guidance),
      ],
    );
  }

  Widget _timingTab(BuildContext context) {
    final plan = _plan;
    final protein = NutritionPlannerEngine.proteinDistribution(
      dailyProteinGrams: plan.proteinGrams,
      meals: 4,
    );
    final carbs = NutritionPlannerEngine.carbTiming(
      dailyCarbohydrates: plan.carbohydrateGrams,
      isTrainingDay: true,
    );
    final timing = NutritionPlannerEngine.trainingMealTiming(
      trainingMinutesSinceMidnight: _trainingTime,
      protein: protein,
      carbohydrates: carbs,
    );
    final hydration = NutritionPlannerEngine.sodiumHydration(
      weightKilograms: store.currentWeightKilograms,
      trainingMinutes: _trainingMinutes,
      sweatLevel: _sweatLevel,
      hotConditions: _hotConditions,
      waterConsumedMilliliters: store.waterTodayMilliliters,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _PlannerHero(
          icon: Icons.schedule,
          title: 'TRAINING-DAY MEAL TIMING',
          detail:
              'Build a practical timeline around the session without rigid eating windows.',
        ),
        _PlannerSlider(
          label: 'TRAINING TIME',
          value: _trainingTime,
          minimum: 6 * 60,
          maximum: 22 * 60,
          suffix: _formatTime(_trainingTime),
          displayRawValue: false,
          onChanged: (value) => setState(() => _trainingTime = value),
        ),
        for (final slot in timing)
          Card(
            child: ListTile(
              leading: Container(
                width: 58,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      slot.time,
                      maxLines: 1,
                      softWrap: false,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
              title: Text(slot.label),
              subtitle: Text(
                '${slot.proteinGrams.round()}g protein • '
                '${slot.carbohydrateGrams.round()}g carbs\n${slot.purpose}',
              ),
              isThreeLine: true,
            ),
          ),
        const SizedBox(height: 18),
        Text(
          'SODIUM & HYDRATION CONTEXT',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _PlannerSlider(
          label: 'TRAINING DURATION',
          value: _trainingMinutes,
          minimum: 0,
          maximum: 180,
          suffix: 'min',
          onChanged: (value) => setState(() => _trainingMinutes = value),
        ),
        Wrap(
          spacing: 8,
          children: [
            for (final value in const ['Low', 'Medium', 'High'])
              ChoiceChip(
                label: Text('$value sweat'),
                selected: _sweatLevel == value,
                onSelected: (_) => setState(() => _sweatLevel = value),
              ),
            FilterChip(
              label: const Text('HOT CONDITIONS'),
              selected: _hotConditions,
              onSelected: (value) => setState(() => _hotConditions = value),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${hydration.waterTargetMilliliters} ML • ${hydration.status}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  '${hydration.trainingWaterMilliliters} ml attributed to training • '
                  '${hydration.sodiumFloorMilligrams}–${hydration.sodiumCeilingMilligrams} mg sodium in the training window.',
                ),
                const Divider(height: 24),
                for (final action in hydration.actions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Text('• $action'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _breakTab(BuildContext context) {
    final plan = _plan;
    final dietBreak = NutritionPlannerEngine.dietBreak(
      plan: plan,
      consecutiveDeficitWeeks: _deficitWeeks,
      adherence: store.weeklyMacroAdherence,
      readinessScore: _readinessScore,
    );
    final reverse = NutritionPlannerEngine.reverseDiet(
      currentCalories: _currentCalories,
      maintenanceCalories: plan.maintenanceCalories,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _PlannerHero(
          icon: Icons.swap_vert,
          title: 'DIET BREAK & REVERSE DIET',
          detail:
              'Plan maintenance transitions instead of reacting to one difficult week or one scale reading.',
        ),
        _PlannerSlider(
          label: 'CONSECUTIVE DEFICIT',
          value: _deficitWeeks,
          minimum: 0,
          maximum: 24,
          suffix: 'weeks',
          onChanged: (value) => setState(() => _deficitWeeks = value),
        ),
        _PlannerSlider(
          label: 'READINESS',
          value: _readinessScore,
          minimum: 0,
          maximum: 100,
          suffix: '/100',
          onChanged: (value) => setState(() => _readinessScore = value),
        ),
        Card(
          color: dietBreak.recommended
              ? const Color(0xFF3D321E)
              : const Color(0xFF153C2D),
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dietBreak.recommended
                      ? 'DIET BREAK RECOMMENDED'
                      : 'NO DIET BREAK TRIGGER',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(dietBreak.reason),
                const SizedBox(height: 10),
                Text(
                  dietBreak.recommended
                      ? '${dietBreak.durationDays} days • ${dietBreak.dailyCalories} kcal/day'
                      : '${dietBreak.dailyCalories} kcal/day • continue current phase',
                ),
                const Divider(height: 24),
                for (final rule in dietBreak.rules)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $rule'),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'REVERSE-DIET PLANNER',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _PlannerSlider(
          label: 'CURRENT CALORIES',
          value: _currentCalories,
          minimum: 1200,
          maximum: plan.maintenanceCalories.clamp(1200, 4500),
          suffix: 'kcal',
          onChanged: (value) => setState(() => _currentCalories = value),
        ),
        if (reverse.weeks.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('ALREADY AT ESTIMATED MAINTENANCE'),
            ),
          )
        else
          for (final week in reverse.weeks)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('W${week.week}')),
                title: Text('${week.dailyCalories} KCAL/DAY'),
                trailing: Text('+${week.change}'),
              ),
            ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.rule_outlined),
            title: const Text('REVERSE STOP RULE'),
            subtitle: Text(reverse.stopRule),
          ),
        ),
        const Text(
          'These outputs are conservative planning estimates, not medical nutrition therapy. '
          'Pregnancy, eating-disorder history, diabetes, kidney/heart conditions or prescribed restrictions require qualified care.',
          style: TextStyle(color: Colors.white54),
        ),
      ],
    );
  }

  static String _formatTime(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }
}

class _PlannerHero extends StatelessWidget {
  const _PlannerHero({
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
        colors: [Color(0xFF4B2A12), Color(0xFF111820)],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.orangeAccent.withValues(alpha: .3)),
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

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 154,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10)),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(detail, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    ),
  );
}

class _WeeklyBudgetChart extends StatelessWidget {
  const _WeeklyBudgetChart({required this.budget});

  final WeeklyCalorieBudget budget;

  @override
  Widget build(BuildContext context) {
    final maximum = budget.days.fold<int>(
      1,
      (value, item) => item.calories > value ? item.calories : value,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 170,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final day in budget.days)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${day.calories}',
                          style: const TextStyle(fontSize: 9),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 45 + day.calories / maximum * 65,
                          decoration: BoxDecoration(
                            color: day.isTrainingDay
                                ? const Color(0xFFFF6D00)
                                : const Color(0xFF546E7A),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(day.label, style: const TextStyle(fontSize: 9)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10)),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    ),
  );
}

class _GuardCard extends StatelessWidget {
  const _GuardCard({
    required this.title,
    required this.detail,
    required this.alert,
  });

  final String title;
  final String detail;
  final bool alert;

  @override
  Widget build(BuildContext context) => Card(
    color: alert ? Theme.of(context).colorScheme.errorContainer : null,
    child: ListTile(
      leading: const Icon(Icons.shield_outlined),
      title: Text(title),
      subtitle: Text(detail),
    ),
  );
}

class _PlannerSlider extends StatelessWidget {
  const _PlannerSlider({
    required this.label,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.suffix,
    required this.onChanged,
    this.displayRawValue = true,
  });

  final String label;
  final int value;
  final int minimum;
  final int maximum;
  final String suffix;
  final ValueChanged<int> onChanged;
  final bool displayRawValue;

  @override
  Widget build(BuildContext context) {
    final safeMaximum = maximum <= minimum ? minimum + 1 : maximum;
    final safeValue = value.clamp(minimum, safeMaximum);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          '$label • ${displayRawValue ? '$safeValue ' : ''}$suffix',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        Slider(
          value: safeValue.toDouble(),
          min: minimum.toDouble(),
          max: safeMaximum.toDouble(),
          divisions: safeMaximum - minimum,
          onChanged: (value) => onChanged(value.round()),
        ),
      ],
    );
  }
}
