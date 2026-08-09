import 'package:flutter/material.dart';

import 'advanced_analytics_page.dart';
import 'advanced_coach_page.dart';
import 'analytics_studio_page.dart';
import 'body_composition_page.dart';
import 'advanced_calisthenics_page.dart';
import 'coach_hub_page.dart';
import 'conditioning_lab_page.dart';
import 'cycling_rowing_lab_page.dart';
import 'calisthenics_lab_page.dart';
import 'exercise_guide.dart';
import 'exercise_intelligence_page.dart';
import 'global_search_engine.dart';
import 'habit_builder_page.dart';
import 'hypertrophy_lab_page.dart';
import 'media_portability_page.dart';
import 'meal_intelligence_page.dart';
import 'mobility_intelligence_page.dart';
import 'mobility_page.dart';
import 'nutrition_page.dart';
import 'nutrition_planner_page.dart';
import 'phoenix_l10n.dart';
import 'program_editor_page.dart';
import 'program_architecture_page.dart';
import 'recovery_lab_page.dart';
import 'recovery_intelligence_page.dart';
import 'reliability_center_page.dart';
import 'reports_studio_page.dart';
import 'running_lab_page.dart';
import 'sleep_stress_page.dart';
import 'state/fitness_store.dart';
import 'strength_test_page.dart';
import 'strength_lab_page.dart';
import 'weekly_planner_page.dart';

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  IconData _icon(SearchResultType type) => switch (type) {
    SearchResultType.workout => Icons.fitness_center,
    SearchResultType.exercise => Icons.sports_gymnastics,
    SearchResultType.workoutLog => Icons.history,
    SearchResultType.meal => Icons.restaurant_outlined,
    SearchResultType.tool => Icons.grid_view_outlined,
  };

  String _subtitle(PhoenixSearchResult result) {
    final l = context.l10n;
    if (!l.isEnglish) return result.subtitle;
    if (result.type == SearchResultType.workout) {
      final template = result.template!;
      final tags = template.tags.isEmpty
          ? ''
          : ' • ${template.tags.join(' • ')}';
      return '${template.exercises.length} exercises$tags';
    }
    if (result.type == SearchResultType.exercise) {
      return 'Exercise guide and program';
    }
    if (result.type == SearchResultType.workoutLog) {
      return 'Completed workout • open analytics';
    }
    if (result.type == SearchResultType.meal) {
      return 'Logged meal • open nutrition';
    }
    return switch (result.route) {
      'analytics' => 'e1RM, PRs, workload, consistency and exports',
      'recovery' => 'Sleep, readiness, fatigue and return to training',
      'mobility' => 'Mobility and safe preparation',
      'nutrition' => 'Meals, macros, water and grocery list',
      'planner' => 'Organize your weekly program',
      'coach' => 'Daily actions, plateau radar and long-term phases',
      'test' => 'AMRAP and safe estimated 1RM protocol',
      'calisthenics' => 'Skill trees, assessments, practice and hold analytics',
      'media' =>
        'Share cards, private photos, Spotify, QR, PDF and wearable import',
      'reliability' =>
        'SQLite, migrations, profiles, reminders and final release audit',
      'exercise-lab' =>
        'Taxonomy, muscles, equipment, safety flags and progression paths',
      'architecture' =>
        'Mesocycle wizard, split design, set budgets and movement audit',
      'strength-lab' =>
        'Big-lift dashboard, plate loading, protocols and meet attempts',
      'hypertrophy' =>
        'Volume landmarks, stimulus scoring and advanced set techniques',
      'conditioning' =>
        'Heart-rate zones, interval builder, cardio load and benchmarks',
      'running' => 'Pace, 5K plans, mileage, shoes and running-load guard',
      'endurance' =>
        'FTP, cycling power zones, rowing splits and multi-sport load',
      'advanced-cali' =>
        'Six advanced skill trees, readiness, exposure and deload rules',
      'mobility-intelligence' =>
        'Joint screens, asymmetry, five-minute snacks and retests',
      'recovery-intelligence' =>
        'Recovery trends, sleep debt, RHR alerts and interventions',
      'nutrition-planner' =>
        'Goal phases, weekly calories, macro timing and diet transitions',
      'meal-intelligence' =>
        'Ingredient builder, pantry, expiry, budget and batch cooking',
      'body-composition' =>
        'Smoothed weight, measurements, photo compare and projections',
      'habit-builder' =>
        'Daily checklist, streak protection, stacking and correlations',
      'sleep-stress' =>
        'Schedule, caffeine cutoff, wind-down, stress and fatigue brief',
      'advanced-coach' =>
        'Explainable recommendations, feedback, reviews and safety',
      'analytics-studio' =>
        'Custom metrics, comparisons, monotony, heatmaps and forecasts',
      'reports' =>
        'Weekly, nutrition, recovery, strength and coach handoff reports',
      _ => result.subtitle,
    };
  }

  Future<void> _open(PhoenixSearchResult result) async {
    Widget? page;
    if (result.template != null) {
      page = ProgramEditorPage(store: widget.store, template: result.template!);
    } else {
      page = switch (result.route) {
        'analytics' => AdvancedAnalyticsPage(store: widget.store),
        'recovery' => RecoveryLabPage(store: widget.store),
        'mobility' => MobilityPage(store: widget.store),
        'nutrition' => NutritionPage(store: widget.store),
        'planner' => WeeklyPlannerPage(store: widget.store),
        'coach' => CoachHubPage(store: widget.store),
        'test' => StrengthTestPage(store: widget.store),
        'calisthenics' => CalisthenicsLabPage(store: widget.store),
        'media' => MediaPortabilityPage(store: widget.store),
        'reliability' => ReliabilityCenterPage(store: widget.store),
        'exercise-lab' => ExerciseIntelligencePage(store: widget.store),
        'architecture' => ProgramArchitecturePage(store: widget.store),
        'strength-lab' => StrengthLabPage(store: widget.store),
        'hypertrophy' => HypertrophyLabPage(store: widget.store),
        'conditioning' => ConditioningLabPage(store: widget.store),
        'running' => RunningLabPage(store: widget.store),
        'endurance' => CyclingRowingLabPage(store: widget.store),
        'advanced-cali' => AdvancedCalisthenicsPage(store: widget.store),
        'mobility-intelligence' => MobilityIntelligencePage(
          store: widget.store,
        ),
        'recovery-intelligence' => RecoveryIntelligencePage(
          store: widget.store,
        ),
        'nutrition-planner' => NutritionPlannerPage(store: widget.store),
        'meal-intelligence' => MealIntelligencePage(store: widget.store),
        'body-composition' => BodyCompositionPage(store: widget.store),
        'habit-builder' => HabitBuilderPage(store: widget.store),
        'sleep-stress' => SleepStressPage(store: widget.store),
        'advanced-coach' => AdvancedCoachPage(store: widget.store),
        'analytics-studio' => AnalyticsStudioPage(store: widget.store),
        'reports' => ReportsStudioPage(store: widget.store),
        _ => null,
      };
    }
    if (result.type == SearchResultType.exercise) {
      final guide = ExerciseGuideCatalog.forExercise(result.title);
      if (guide != null) {
        await showExerciseGuide(context, result.title, guide);
      } else if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ExerciseIntelligencePage(store: widget.store),
          ),
        );
      }
      return;
    }
    if (page != null && mounted) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (context) => page!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final results = GlobalSearchEngine.search(widget.store.data, _query.text);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.text('ΚΑΘΟΛΙΚΗ ΑΝΑΖΗΤΗΣΗ', 'GLOBAL SEARCH')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
            child: SearchBar(
              controller: _query,
              autoFocus: true,
              leading: const Icon(Icons.search),
              hintText: l.text(
                'Άσκηση, πρόγραμμα, γεύμα ή εργαλείο…',
                'Exercise, workout, meal or tool…',
              ),
              trailing: [
                if (_query.text.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      _query.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close),
                  ),
              ],
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  _query.text.trim().isEmpty
                      ? l.text('ΓΡΗΓΟΡΑ ΕΡΓΑΛΕΙΑ', 'QUICK TOOLS')
                      : l.text(
                          '${results.length} ΑΠΟΤΕΛΕΣΜΑΤΑ',
                          '${results.length} RESULTS',
                        ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 54,
                            color: Colors.white30,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l.text('Δεν βρέθηκε κάτι.', 'Nothing found.'),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 28),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 5),
                    itemBuilder: (context, index) {
                      final result = results[index];
                      return Card(
                        child: ListTile(
                          onTap: () => _open(result),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: .55),
                            child: Icon(_icon(result.type)),
                          ),
                          title: Text(
                            result.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            _subtitle(result),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
