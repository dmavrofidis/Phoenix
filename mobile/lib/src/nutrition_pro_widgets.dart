import 'package:flutter/material.dart';

import 'models/fitness_models.dart';
import 'phoenix_copy.dart';
import 'phoenix_l10n.dart';
import 'state/fitness_store.dart';

class HydrationCard extends StatelessWidget {
  const HydrationCard({super.key, required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final current = store.waterTodayMilliliters;
    final target = store.hydrationTargetMilliliters;
    final progress = (current / target).clamp(0, 1.2).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop_outlined, color: Color(0xFF4FC3F7)),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    context.l10n.text('Νερό', 'Hydration'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Color(0xFF81D4FA),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '$current / $target ml',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: .07),
                color: const Color(0xFF29B6F6),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => store.addWater(250),
                  icon: const Icon(Icons.add, size: 17),
                  label: const Text('250 ml'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => store.addWater(500),
                  icon: const Icon(Icons.add, size: 17),
                  label: const Text('500 ml'),
                ),
                if (store.todaysHydration.isNotEmpty)
                  TextButton.icon(
                    onPressed: () =>
                        store.removeHydration(store.todaysHydration.first),
                    icon: const Icon(Icons.undo, size: 17),
                    label: const Text('Αναίρεση'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MicronutrientCard extends StatelessWidget {
  const MicronutrientCard({super.key, required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final targets = store.nutritionTargets;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FIBER & SODIUM',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            const SizedBox(height: 14),
            _NutrientProgress(
              label: 'Φυτικές ίνες',
              value: store.fiberToday,
              target: targets.fiberGrams,
              unit: 'g',
              color: const Color(0xFF81C784),
            ),
            const SizedBox(height: 12),
            _NutrientProgress(
              label: 'Νάτριο',
              value: store.sodiumToday,
              target: targets.sodiumLimitMilligrams,
              unit: 'mg',
              color: store.sodiumToday > targets.sodiumLimitMilligrams
                  ? const Color(0xFFEF5350)
                  : const Color(0xFF90A4AE),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientProgress extends StatelessWidget {
  const _NutrientProgress({
    required this.label,
    required this.value,
    required this.target,
    required this.unit,
    required this.color,
  });

  final String label;
  final double value;
  final double target;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = (value / target).clamp(0, 1).toDouble();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '${value.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit',
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 6),
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

class MealPresetsCard extends StatelessWidget {
  const MealPresetsCard({super.key, required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
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
                    context.l10n.text('Έτοιμα γεύματα', 'Meal presets'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => showGroceryList(context, store),
                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: const Text('Λίστα αγορών'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Ένα άγγιγμα για καταγραφή. Τα υλικά τροφοδοτούν αυτόματα τη '
              'λίστα αγορών.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .52),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 138,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: store.data.mealPresets.length,
                separatorBuilder: (_, _) => const SizedBox(width: 9),
                itemBuilder: (context, index) {
                  final preset = store.data.mealPresets[index];
                  return _PresetTile(
                    preset: preset,
                    onAdd: () async {
                      await store.addMealFromPreset(preset);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${PhoenixCopy.mealPresetName(context.l10n, preset)}: καταγράφηκε',
                          ),
                        ),
                      );
                    },
                    onDelete: preset.id.startsWith('custom-meal-')
                        ? () => store.deleteMealPreset(preset.id)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.preset,
    required this.onAdd,
    required this.onDelete,
  });

  final MealPreset preset;
  final VoidCallback onAdd;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .22),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  PhoenixCopy.mealPresetName(context.l10n, preset),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              if (onDelete != null)
                InkWell(
                  onTap: onDelete,
                  child: const Icon(Icons.close, size: 16),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${preset.calories} kcal • Π ${preset.proteinGrams.round()} g',
            style: const TextStyle(color: Color(0xFFFFAB91), fontSize: 11),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Καταγραφή'),
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyNutritionCard extends StatelessWidget {
  const WeeklyNutritionCard({super.key, required this.store});

  final FitnessStore store;

  static const _days = ['Δ', 'Τ', 'Τ', 'Π', 'Π', 'Σ', 'Κ'];

  @override
  Widget build(BuildContext context) {
    final summaries = store.weeklyNutritionSummaries;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'NUTRITION • 7 ΗΜΕΡΕΣ',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(
                  '${(store.weeklyMacroAdherence * 100).round()}% adherence',
                  style: const TextStyle(
                    color: Color(0xFFFF9E80),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${store.nutritionConsistencyStreak} ημέρες consistency streak',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .58),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var index = 0; index < summaries.length; index++)
                    Expanded(
                      child: _DayBar(
                        label: _days[summaries[index].date.weekday - 1],
                        calories: summaries[index].calories,
                        target: store
                            .nutritionTargetsForDate(summaries[index].date)
                            .calories,
                        adherence: summaries[index].adherence,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.insights_outlined,
                  size: 17,
                  color: Color(0xFFFF8A65),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Οι μπάρες συγκρίνουν θερμίδες training/rest day· το '
                    'χρώμα δείχνει συνολική macro συνέπεια.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .46),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.label,
    required this.calories,
    required this.target,
    required this.adherence,
  });

  final String label;
  final int calories;
  final int target;
  final double adherence;

  @override
  Widget build(BuildContext context) {
    final ratio = (calories / target).clamp(0, 1.15).toDouble();
    final color = adherence >= .8
        ? const Color(0xFF66BB6A)
        : adherence >= .55
        ? const Color(0xFFFFA726)
        : calories == 0
        ? Colors.white24
        : const Color(0xFFFF6E40);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            calories == 0 ? '—' : '${(calories / 100).round() * 100}',
            style: const TextStyle(fontSize: 9, color: Colors.white54),
          ),
          const SizedBox(height: 4),
          Container(
            height: 72 * ratio + 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(7),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

Future<void> showGroceryList(BuildContext context, FitnessStore store) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _GroceryListSheet(store: store),
  );
}

class _GroceryListSheet extends StatefulWidget {
  const _GroceryListSheet({required this.store});

  final FitnessStore store;

  @override
  State<_GroceryListSheet> createState() => _GroceryListSheetState();
}

class _GroceryListSheetState extends State<_GroceryListSheet> {
  final Set<String> _checked = {};

  @override
  Widget build(BuildContext context) {
    final items = widget.store.groceryList;
    return FractionallySizedBox(
      heightFactor: .82,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Αυτόματη λίστα αγορών',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(
              '${items.length} μοναδικά υλικά από '
              '${widget.store.data.mealPresets.length} έτοιμα γεύματα.',
              style: TextStyle(color: Colors.white.withValues(alpha: .55)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  for (final item in items)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _checked.contains(item.name),
                      onChanged: (_) => setState(() {
                        if (!_checked.add(item.name)) {
                          _checked.remove(item.name);
                        }
                      }),
                      title: Text(item.name),
                      subtitle: item.presetCount > 1
                          ? Text('Σε ${item.presetCount} presets')
                          : null,
                    ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  _checked.isEmpty
                      ? 'Κλείσιμο'
                      : '${_checked.length} επιλέχθηκαν',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
