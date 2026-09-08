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
import 'equipment_availability.dart';
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
import 'recommended_nutrition_page.dart';
import 'phoenix_copy.dart';
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
    if (result.type == SearchResultType.workout) {
      final template = result.template!;
      return l.text(
        '${template.exercises.length} ασκήσεις',
        '${template.exercises.length} exercises',
      );
    }
    if (result.type == SearchResultType.exercise) {
      return l.text(
        'Οδηγίες εκτέλεσης και σχετικό πρόγραμμα',
        'Exercise guide and program',
      );
    }
    if (result.type == SearchResultType.workoutLog) {
      return l.text(
        'Ολοκληρωμένη προπόνηση • άνοιγμα προόδου',
        'Completed workout • open analytics',
      );
    }
    if (result.type == SearchResultType.meal) {
      return l.text(
        'Καταγεγραμμένο γεύμα • άνοιγμα διατροφής',
        'Logged meal • open nutrition',
      );
    }
    return switch (result.route) {
      'analytics' => l.text(
        'Ρεκόρ, φόρτος, συνέπεια και εξαγωγές',
        'e1RM, PRs, workload, consistency and exports',
      ),
      'recovery' => l.text(
        'Ύπνος, ετοιμότητα, κόπωση και επιστροφή στην προπόνηση',
        'Sleep, readiness, fatigue and return to training',
      ),
      'mobility' => l.text(
        'Κινητικότητα και ασφαλής προετοιμασία',
        'Mobility and safe preparation',
      ),
      'nutrition' => l.text(
        'Γεύματα, θρεπτικά στοιχεία, νερό και λίστα αγορών',
        'Meals, macros, water and grocery list',
      ),
      'planner' => l.text(
        'Οργάνωση του εβδομαδιαίου προγράμματος',
        'Organize your weekly program',
      ),
      'coach' => l.text(
        'Καθημερινά βήματα και μακροπρόθεσμη καθοδήγηση',
        'Daily actions, plateau radar and long-term phases',
      ),
      'test' => l.text(
        'Ασφαλής εκτίμηση δύναμης',
        'AMRAP and safe estimated 1RM protocol',
      ),
      'calisthenics' => l.text(
        'Ασκήσεις σώματος, αξιολόγηση και εξάσκηση',
        'Skill trees, assessments, practice and hold analytics',
      ),
      'media' => l.text(
        'Μουσική, ιδιωτικές φωτογραφίες, αντίγραφα και κοινή χρήση',
        'Share cards, private photos, music, QR, PDF and wearable import',
      ),
      'reliability' => l.text(
        'Αποθήκευση, αντίγραφα, υπενθυμίσεις και έλεγχος έκδοσης',
        'Storage, migrations, profiles, reminders and release audit',
      ),
      'exercise-lab' => l.text(
        'Μύες, εξοπλισμός, ασφάλεια και πρόοδος ασκήσεων',
        'Muscles, equipment, safety flags and progression paths',
      ),
      'architecture' => l.text(
        'Σχεδιασμός κύκλου προπόνησης και έλεγχος κινήσεων',
        'Mesocycle wizard, split design, set budgets and movement audit',
      ),
      'strength-lab' => l.text(
        'Φορτία, βασικές άρσεις και προσπάθειες δύναμης',
        'Big-lift dashboard, plate loading, protocols and meet attempts',
      ),
      'hypertrophy' => l.text(
        'Όγκος προπόνησης και τεχνικές μυϊκής ανάπτυξης',
        'Volume landmarks, stimulus scoring and advanced set techniques',
      ),
      'conditioning' => l.text(
        'Ζώνες καρδιακού ρυθμού, διαλειμματική και αντοχή',
        'Heart-rate zones, interval builder, cardio load and benchmarks',
      ),
      'running' => l.text(
        'Ρυθμός, πλάνα 5 χλμ., αποστάσεις και παπούτσια',
        'Pace, 5K plans, mileage, shoes and running-load guard',
      ),
      'endurance' => l.text(
        'Ποδήλατο, κωπηλατική και συνολική αντοχή',
        'Cycling power zones, rowing splits and multi-sport load',
      ),
      'advanced-cali' => l.text(
        'Προχωρημένες δεξιότητες σώματος και κανόνες αποφόρτισης',
        'Advanced skill trees, readiness, exposure and deload rules',
      ),
      'mobility-intelligence' => l.text(
        'Έλεγχοι αρθρώσεων, ασυμμετρίες και επανέλεγχοι',
        'Joint screens, asymmetry, five-minute snacks and retests',
      ),
      'recovery-intelligence' => l.text(
        'Τάσεις αποκατάστασης, έλλειμμα ύπνου και παρεμβάσεις',
        'Recovery trends, sleep debt, RHR alerts and interventions',
      ),
      'nutrition-planner' => l.text(
        'Στόχοι θερμίδων, κατανομή θρεπτικών στοιχείων και μεταβάσεις',
        'Goal phases, weekly calories, macro timing and diet transitions',
      ),
      'recommended-nutrition' => l.text(
        'Απλά εβδομαδιαία γεύματα για τον στόχο και τις επιλογές σου',
        'Simple weekly meals adapted to your goal and preferences',
      ),
      'meal-intelligence' => l.text(
        'Υλικά, απόθεμα τροφίμων, κόστος και μαγείρεμα για πολλές ημέρες',
        'Ingredient builder, pantry, expiry, budget and batch cooking',
      ),
      'body-composition' => l.text(
        'Βάρος, μετρήσεις, σύγκριση φωτογραφιών και προβολές',
        'Smoothed weight, measurements, photo compare and projections',
      ),
      'habit-builder' => l.text(
        'Καθημερινές συνήθειες, συνέχεια και συσχετίσεις',
        'Daily checklist, streak protection, stacking and correlations',
      ),
      'sleep-stress' => l.text(
        'Ωράριο, καφεΐνη, χαλάρωση, άγχος και κόπωση',
        'Schedule, caffeine cutoff, wind-down, stress and fatigue brief',
      ),
      'advanced-coach' => l.text(
        'Εξηγήσιμες προτάσεις, ανασκοπήσεις και ασφάλεια',
        'Explainable recommendations, feedback, reviews and safety',
      ),
      'analytics-studio' => l.text(
        'Προσαρμοσμένες μετρήσεις, συγκρίσεις και προβλέψεις',
        'Custom metrics, comparisons, monotony, heatmaps and forecasts',
      ),
      'reports' => l.text(
        'Αναφορές προπόνησης, διατροφής, αποκατάστασης και δύναμης',
        'Training, nutrition, recovery, strength and coach reports',
      ),
      _ => result.subtitle,
    };
  }

  String _title(PhoenixSearchResult result) {
    final l = context.l10n;
    if (result.template != null) {
      return PhoenixCopy.workoutName(l, result.template!);
    }
    if (result.type == SearchResultType.exercise) {
      return PhoenixCopy.exerciseName(l, result.title);
    }
    if (result.type == SearchResultType.workoutLog) {
      return PhoenixCopy.workoutNameFromRaw(l, result.title);
    }
    if (result.type == SearchResultType.meal) {
      return PhoenixCopy.mealNameFromRaw(l, result.title);
    }
    return switch (result.route) {
      'analytics' => l.text('Αναλυτικά στοιχεία', 'Advanced analytics'),
      'recovery' => l.text('Αποκατάσταση', 'Recovery lab'),
      'mobility' => l.text('Κινητικότητα', 'Mobility lab'),
      'nutrition' => l.text('Διατροφή', 'Nutrition'),
      'planner' => l.text('Εβδομαδιαίος προγραμματισμός', 'Weekly planner'),
      'coach' => l.text('Καθοδήγηση Phoenix', 'Phoenix coach'),
      'test' => l.text('Έλεγχος δύναμης', 'Strength test lab'),
      'calisthenics' => l.text(
        'Ασκήσεις με το βάρος του σώματος',
        'Bodyweight training lab',
      ),
      'media' => l.text('Μουσική και αρχεία', 'Music and files'),
      'reliability' => l.text('Έλεγχος αξιοπιστίας', 'Reliability center'),
      'exercise-lab' => l.text('Ανάλυση ασκήσεων', 'Exercise intelligence'),
      'architecture' => l.text(
        'Σχεδιασμός προγράμματος',
        'Program architecture',
      ),
      'strength-lab' => l.text('Δύναμη', 'Strength lab'),
      'hypertrophy' => l.text('Μυϊκή ανάπτυξη', 'Hypertrophy lab'),
      'conditioning' => l.text('Φυσική κατάσταση', 'Conditioning lab'),
      'running' => l.text('Τρέξιμο', 'Running lab'),
      'endurance' => l.text('Ποδήλατο και κωπηλατική', 'Cycling and rowing'),
      'advanced-cali' => l.text(
        'Προχωρημένες ασκήσεις σώματος',
        'Advanced bodyweight training',
      ),
      'mobility-intelligence' => l.text(
        'Ανάλυση κινητικότητας',
        'Mobility intelligence',
      ),
      'recovery-intelligence' => l.text(
        'Ανάλυση αποκατάστασης',
        'Recovery intelligence',
      ),
      'recommended-nutrition' => l.text(
        'Το διατροφικό μου πλάνο',
        'Recommended meal plan',
      ),
      'nutrition-planner' => l.text(
        'Προγραμματισμός διατροφής',
        'Nutrition planner',
      ),
      'meal-intelligence' => l.text('Ανάλυση γευμάτων', 'Meal intelligence'),
      'body-composition' => l.text('Σύσταση σώματος', 'Body composition'),
      'habit-builder' => l.text('Καθημερινές συνήθειες', 'Habit builder'),
      'sleep-stress' => l.text('Ύπνος και άγχος', 'Sleep and stress'),
      'advanced-coach' => l.text('Προχωρημένη καθοδήγηση', 'Advanced coach'),
      'analytics-studio' => l.text('Εργαστήριο αναλύσεων', 'Analytics studio'),
      'reports' => l.text('Αναφορές', 'Reports studio'),
      _ => result.title,
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
        'recommended-nutrition' => RecommendedNutritionPage(
          store: widget.store,
        ),
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
      final guide = ExerciseGuideCatalog.forExercise(
        result.title,
        atHome: EquipmentAvailability.isHome(widget.store.profile),
      );
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
      appBar: AppBar(title: Text(l.text('Αναζήτηση', 'Global search'))),
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
                      ? l.text('Χρήσιμα εργαλεία', 'Quick tools')
                      : l.text(
                          '${results.length} αποτελέσματα',
                          '${results.length} results',
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
                            _title(result),
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
