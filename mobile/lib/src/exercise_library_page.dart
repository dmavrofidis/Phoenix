import 'package:flutter/material.dart';

import 'equipment_availability.dart';
import 'exercise_guide.dart';
import 'phoenix_copy.dart';
import 'phoenix_l10n.dart';
import 'state/fitness_store.dart';

class ExerciseLibraryPage extends StatefulWidget {
  const ExerciseLibraryPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<ExerciseLibraryPage> createState() => _ExerciseLibraryPageState();
}

class _ExerciseLibraryPageState extends State<ExerciseLibraryPage> {
  final _searchController = TextEditingController();
  bool _onlyAvailable = true;
  String _category = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final query = _searchController.text.trim().toLowerCase();
    final matchingCategory = _entries.where(
      (entry) => _category == 'all' || entry.category == _category,
    );
    final matchingSearch = matchingCategory.where((entry) {
      if (query.isEmpty) return true;
      final localized = PhoenixCopy.exerciseName(l, entry.exercise);
      return entry.exercise.toLowerCase().contains(query) ||
          localized.toLowerCase().contains(query);
    });
    final hiddenByEquipment = matchingSearch
        .where(
          (entry) => !EquipmentAvailability.supportsExercise(
            entry.exercise,
            widget.store.profile,
          ),
        )
        .length;
    final visible = matchingSearch
        .where(
          (entry) =>
              !_onlyAvailable ||
              EquipmentAvailability.supportsExercise(
                entry.exercise,
                widget.store.profile,
              ),
        )
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text(l.text('Οδηγοί ασκήσεων', 'Exercise guides'))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1060),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
            children: [
              _LibraryIntro(visibleCount: visible.length),
              const SizedBox(height: 14),
              TextField(
                key: const ValueKey('exercise-library-search'),
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l.text(
                    'Αναζήτησε μια άσκηση',
                    'Search for an exercise',
                  ),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l.text('Καθαρισμός', 'Clear'),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final category in _categories) ...[
                      ChoiceChip(
                        selected: _category == category.id,
                        label: Text(l.text(category.greek, category.english)),
                        onSelected: (_) =>
                            setState(() => _category = category.id),
                      ),
                      const SizedBox(width: 7),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: SwitchListTile(
                  key: const ValueKey('only-my-equipment-switch'),
                  value: _onlyAvailable,
                  onChanged: (value) => setState(() => _onlyAvailable = value),
                  secondary: const Icon(Icons.verified_outlined),
                  title: Text(
                    l.text('Μόνο όσα μπορώ να κάνω', 'Only exercises I can do'),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    l.text(
                      _onlyAvailable
                          ? 'Χρησιμοποιείται ακριβώς ο εξοπλισμός που δήλωσες.'
                          : 'Οι υπόλοιπες επιλογές εμφανίζουν τι λείπει.',
                      _onlyAvailable
                          ? 'Uses exactly the equipment in your profile.'
                          : 'Other options explain what is missing.',
                    ),
                  ),
                ),
              ),
              if (_onlyAvailable && hiddenByEquipment > 0) ...[
                const SizedBox(height: 8),
                Text(
                  l.text(
                    '$hiddenByEquipment ${hiddenByEquipment == 1 ? 'άσκηση δεν εμφανίζεται' : 'ασκήσεις δεν εμφανίζονται'} επειδή χρειάζονται άλλο εξοπλισμό.',
                    '$hiddenByEquipment ${hiddenByEquipment == 1 ? 'exercise is hidden' : 'exercises are hidden'} because they need other equipment.',
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (visible.isEmpty)
                _EmptyLibrary(
                  onShowAll: () => setState(() {
                    _category = 'all';
                    _onlyAvailable = false;
                    _searchController.clear();
                  }),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 900
                        ? 3
                        : constraints.maxWidth >= 600
                        ? 2
                        : 1;
                    final gap = 12.0;
                    final cardWidth =
                        (constraints.maxWidth - gap * (columns - 1)) / columns;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final entry in visible)
                          SizedBox(
                            width: cardWidth,
                            child: _ExerciseGuideCard(
                              entry: entry,
                              missingEquipment:
                                  EquipmentAvailability.missingEquipmentForExercise(
                                    entry.exercise,
                                    widget.store.profile,
                                  ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryIntro extends StatelessWidget {
  const _LibraryIntro({required this.visibleCount});

  final int visibleCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: .16),
            colors.surfaceContainerLow,
          ],
        ),
        border: Border.all(color: colors.primary.withValues(alpha: .25)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.slideshow_rounded, color: colors.primary),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.text(
                    'Δες την κίνηση πριν ξεκινήσεις',
                    'See the movement before you start',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  context.l10n.text(
                    'Αρχική, ενδιάμεση και τελική θέση, απλές οδηγίες και το συνηθισμένο λάθος που πρέπει να αποφύγεις.',
                    'Start, middle and finish positions, simple cues and the common mistake to avoid.',
                  ),
                  style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.text(
                    '$visibleCount διαθέσιμοι οδηγοί',
                    '$visibleCount guides available',
                  ),
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseGuideCard extends StatelessWidget {
  const _ExerciseGuideCard({
    required this.entry,
    required this.missingEquipment,
  });

  final _LibraryExercise entry;
  final List<String> missingEquipment;

  @override
  Widget build(BuildContext context) {
    final guide = ExerciseGuideCatalog.forExercise(
      entry.exercise,
      atHome: entry.atHome,
    );
    if (guide == null) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    final available = missingEquipment.isEmpty;
    final displayName = PhoenixCopy.exerciseName(context.l10n, entry.exercise);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('exercise-library-${entry.exercise}'),
        onTap: () => showExerciseGuide(context, entry.exercise, guide),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExerciseGuidePreview(
                guide: guide,
                semanticLabel: context.l10n.text(
                  'Οπτικός οδηγός για την άσκηση $displayName',
                  'Visual guide for $displayName',
                ),
                height: 142,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(height: 12),
              Text(
                displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              Text(
                guide.localizedEquipmentLabel(context.l10n),
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .35,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    available
                        ? Icons.check_circle_outline_rounded
                        : Icons.info_outline_rounded,
                    size: 18,
                    color: available ? colors.secondary : colors.error,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      available
                          ? context.l10n.text(
                              'Ταιριάζει στον εξοπλισμό σου',
                              'Matches your equipment',
                            )
                          : context.l10n.text(
                              'Χρειάζεται: ${_missingLabel(context, missingEquipment)}',
                              'Needs: ${_missingLabel(context, missingEquipment)}',
                            ),
                      style: TextStyle(
                        color: available
                            ? colors.onSurfaceVariant
                            : colors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: FilledButton.tonalIcon(
                  onPressed: () =>
                      showExerciseGuide(context, entry.exercise, guide),
                  icon: const Icon(Icons.play_circle_outline_rounded),
                  label: Text(
                    context.l10n.text('Δες βήμα-βήμα', 'See step by step'),
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

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.onShowAll});

  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 42),
          const SizedBox(height: 10),
          Text(
            context.l10n.text(
              'Δεν βρέθηκε διαθέσιμη άσκηση.',
              'No available exercise was found.',
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onShowAll,
            child: Text(
              context.l10n.text('Δες όλους τους οδηγούς', 'Show all guides'),
            ),
          ),
        ],
      ),
    ),
  );
}

String _missingLabel(BuildContext context, List<String> missing) {
  final l = context.l10n;
  return missing
      .map(
        (item) => switch (item) {
          'band' => l.text('λάστιχο', 'resistance band'),
          'dumbbells' => l.text('αλτήρες', 'dumbbells'),
          'pull-up-bar' => l.text('μονόζυγο', 'pull-up bar'),
          'treadmill' => l.text('διάδρομος', 'treadmill'),
          'backpack' => l.text('σακίδιο', 'backpack'),
          'bench' => l.text('σταθερός πάγκος', 'stable bench'),
          'barbell' => l.text('μπάρα', 'barbell'),
          _ => l.text('εξοπλισμός γυμναστηρίου', 'gym equipment'),
        },
      )
      .join(', ');
}

class _LibraryExercise {
  const _LibraryExercise({
    required this.exercise,
    required this.category,
    this.atHome = true,
  });

  final String exercise;
  final String category;
  final bool atHome;
}

class _LibraryCategory {
  const _LibraryCategory(this.id, this.greek, this.english);

  final String id;
  final String greek;
  final String english;
}

const _categories = [
  _LibraryCategory('all', 'Όλα', 'All'),
  _LibraryCategory('bodyweight', 'Χωρίς εξοπλισμό', 'No equipment'),
  _LibraryCategory('dumbbells', 'Αλτήρες', 'Dumbbells'),
  _LibraryCategory('bands', 'Λάστιχο', 'Band'),
  _LibraryCategory('walking', 'Περπάτημα', 'Walking'),
  _LibraryCategory('pull-up', 'Μονόζυγο', 'Pull-up bar'),
];

const _entries = <_LibraryExercise>[
  _LibraryExercise(
    exercise: 'Κάθισμα και σήκωμα από καρέκλα',
    category: 'bodyweight',
  ),
  _LibraryExercise(exercise: 'Κάμψεις στον τοίχο', category: 'bodyweight'),
  _LibraryExercise(exercise: 'Bird dog', category: 'bodyweight'),
  _LibraryExercise(
    exercise: 'Γέφυρα γλουτών στο πάτωμα',
    category: 'bodyweight',
  ),
  _LibraryExercise(exercise: 'Hip hinge χωρίς βάρος', category: 'bodyweight'),
  _LibraryExercise(
    exercise: 'Κάμψεις σε σταθερό τραπέζι',
    category: 'bodyweight',
  ),
  _LibraryExercise(
    exercise: 'Ανάστροφες προβολές με στήριξη',
    category: 'bodyweight',
  ),
  _LibraryExercise(exercise: 'Dead bug', category: 'bodyweight'),
  _LibraryExercise(exercise: 'Goblet squat με αλτήρα', category: 'dumbbells'),
  _LibraryExercise(
    exercise: 'Ρουμανικές άρσεις με αλτήρες',
    category: 'dumbbells',
  ),
  _LibraryExercise(
    exercise: 'Μονόχειρη κωπηλατική με αλτήρα',
    category: 'dumbbells',
  ),
  _LibraryExercise(exercise: 'Πιέσεις ώμων με αλτήρες', category: 'dumbbells'),
  _LibraryExercise(exercise: 'Κωπηλατική με λάστιχο', category: 'bands'),
  _LibraryExercise(exercise: 'Πιέσεις ώμων με λάστιχο', category: 'bands'),
  _LibraryExercise(exercise: 'Band face pulls', category: 'bands'),
  _LibraryExercise(exercise: 'Υποβοηθούμενες έλξεις', category: 'pull-up'),
  _LibraryExercise(exercise: 'Περπάτημα σε απλό διάδρομο', category: 'walking'),
  _LibraryExercise(
    exercise: 'Περπάτημα σε εξωτερικό χώρο',
    category: 'walking',
    atHome: false,
  ),
];
