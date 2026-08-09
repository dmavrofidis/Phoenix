import 'package:flutter/material.dart';

import 'advanced_analytics_page.dart';
import 'advanced_calisthenics_page.dart';
import 'advanced_coach_page.dart';
import 'analytics_studio_page.dart';
import 'body_composition_page.dart';
import 'capability_studio_page.dart';
import 'calisthenics_lab_page.dart';
import 'coach_hub_page.dart';
import 'conditioning_lab_page.dart';
import 'control_center_page.dart';
import 'cycling_rowing_lab_page.dart';
import 'data_validation_page.dart';
import 'education_library.dart';
import 'exercise_intelligence_page.dart';
import 'experience_settings_page.dart';
import 'habit_builder_page.dart';
import 'hypertrophy_lab_page.dart';
import 'local_collaboration_page.dart';
import 'media_portability_page.dart';
import 'meal_intelligence_page.dart';
import 'mobility_intelligence_page.dart';
import 'mobility_page.dart';
import 'nutrition_page.dart';
import 'nutrition_planner_page.dart';
import 'phoenix_l10n.dart';
import 'photo_meal_scan_page.dart';
import 'profile_editor_page.dart';
import 'program_architecture_page.dart';
import 'recovery_intelligence_page.dart';
import 'recovery_lab_page.dart';
import 'reliability_center_page.dart';
import 'reports_studio_page.dart';
import 'running_lab_page.dart';
import 'sleep_stress_page.dart';
import 'state/fitness_store.dart';
import 'strength_lab_page.dart';
import 'strength_test_page.dart';
import 'structured_import_export_page.dart';
import 'vault_security_page.dart';
import 'weekly_planner_page.dart';

class PhoenixToolboxPage extends StatefulWidget {
  const PhoenixToolboxPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<PhoenixToolboxPage> createState() => _PhoenixToolboxPageState();
}

class _PhoenixToolboxPageState extends State<PhoenixToolboxPage> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Widget _pageFor(String route) => switch (route) {
    'planner' => WeeklyPlannerPage(store: widget.store),
    'architecture' => ProgramArchitecturePage(store: widget.store),
    'exercise-lab' => ExerciseIntelligencePage(store: widget.store),
    'education' => const EducationLibraryPage(),
    'collaboration' => LocalCollaborationPage(store: widget.store),
    'test' => StrengthTestPage(store: widget.store),
    'strength-lab' => StrengthLabPage(store: widget.store),
    'hypertrophy' => HypertrophyLabPage(store: widget.store),
    'calisthenics' => CalisthenicsLabPage(store: widget.store),
    'advanced-cali' => AdvancedCalisthenicsPage(store: widget.store),
    'conditioning' => ConditioningLabPage(store: widget.store),
    'running' => RunningLabPage(store: widget.store),
    'endurance' => CyclingRowingLabPage(store: widget.store),
    'mobility' => MobilityPage(store: widget.store),
    'mobility-intelligence' => MobilityIntelligencePage(store: widget.store),
    'nutrition' => NutritionPage(store: widget.store),
    'photo-meal' => PhotoMealScanPage(store: widget.store),
    'nutrition-planner' => NutritionPlannerPage(store: widget.store),
    'meal-intelligence' => MealIntelligencePage(store: widget.store),
    'body-composition' => BodyCompositionPage(store: widget.store),
    'recovery' => RecoveryLabPage(store: widget.store),
    'recovery-intelligence' => RecoveryIntelligencePage(store: widget.store),
    'habit-builder' => HabitBuilderPage(store: widget.store),
    'sleep-stress' => SleepStressPage(store: widget.store),
    'coach' => CoachHubPage(store: widget.store),
    'advanced-coach' => AdvancedCoachPage(store: widget.store),
    'analytics' => AdvancedAnalyticsPage(store: widget.store),
    'analytics-studio' => AnalyticsStudioPage(store: widget.store),
    'reports' => ReportsStudioPage(store: widget.store),
    'capability-studio' => CapabilityStudioPage(store: widget.store),
    'control' => ControlCenterPage(store: widget.store),
    'media' => MediaPortabilityPage(store: widget.store),
    'reliability' => ReliabilityCenterPage(store: widget.store),
    'validation' => DataValidationPage(store: widget.store),
    'vault' => VaultSecurityPage(store: widget.store),
    'profile' => ProfileEditorPage(store: widget.store),
    'settings' => ExperienceSettingsPage(store: widget.store),
    'structured-transfer' => StructuredImportExportPage(store: widget.store),
    _ => ControlCenterPage(store: widget.store),
  };

  Future<void> _open(String route) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => _pageFor(route)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final normalized = _query.text.trim().toLowerCase();
    final visible = _tools.where((tool) {
      if (normalized.isEmpty) return true;
      return tool.searchText.contains(normalized);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.text('ΕΡΓΑΛΕΙΟΘΗΚΗ PHOENIX', 'PHOENIX TOOLBOX')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          Text(
            l.text(
              'Όλες οι δυνατότητες του Phoenix, οργανωμένες ανά στόχο.',
              'Every Phoenix capability, organized by goal.',
            ),
            style: TextStyle(color: Colors.white.withValues(alpha: .68)),
          ),
          const SizedBox(height: 14),
          SearchBar(
            key: const ValueKey('phoenix-toolbox-search'),
            controller: _query,
            leading: const Icon(Icons.search),
            hintText: l.text(
              'Αναζήτησε εργαλείο ή στόχο…',
              'Find a tool or goal…',
            ),
            trailing: [
              if (_query.text.isNotEmpty)
                IconButton(
                  tooltip: l.text('Καθαρισμός', 'Clear'),
                  onPressed: () {
                    _query.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.close),
                ),
            ],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          if (visible.isEmpty)
            _EmptyToolbox(query: _query.text)
          else
            for (final category in _ToolCategory.values)
              if (visible.any((tool) => tool.category == category)) ...[
                _ToolSection(
                  category: category,
                  tools: visible
                      .where((tool) => tool.category == category)
                      .toList(),
                  onOpen: _open,
                ),
                const SizedBox(height: 14),
              ],
        ],
      ),
    );
  }
}

class _ToolSection extends StatelessWidget {
  const _ToolSection({
    required this.category,
    required this.tools,
    required this.onOpen,
  });

  final _ToolCategory category;
  final List<_ToolEntry> tools;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
            child: Row(
              children: [
                Icon(
                  category.icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 9),
                Text(
                  category.label(l),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          for (var index = 0; index < tools.length; index++) ...[
            if (index > 0) const Divider(height: 1, indent: 58),
            ListTile(
              key: ValueKey('phoenix-tool-${tools[index].route}'),
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: .12),
                child: Icon(
                  tools[index].icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 21,
                ),
              ),
              title: Text(
                tools[index].title(l),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(tools[index].description(l)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onOpen(tools[index].route),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyToolbox extends StatelessWidget {
  const _EmptyToolbox({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 54, horizontal: 24),
    child: Column(
      children: [
        const Icon(Icons.search_off, size: 52, color: Colors.white30),
        const SizedBox(height: 12),
        Text(
          context.l10n.text(
            'Δεν βρέθηκε εργαλείο για «$query».',
            'No tool found for “$query”.',
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    ),
  );
}

enum _ToolCategory { training, health, insights, data }

extension on _ToolCategory {
  IconData get icon => switch (this) {
    _ToolCategory.training => Icons.fitness_center,
    _ToolCategory.health => Icons.favorite_outline,
    _ToolCategory.insights => Icons.insights_outlined,
    _ToolCategory.data => Icons.shield_outlined,
  };

  String label(PhoenixL10n l) => switch (this) {
    _ToolCategory.training => l.text('ΠΡΟΠΟΝΗΣΗ', 'TRAINING'),
    _ToolCategory.health => l.text('ΥΓΕΙΑ & ΔΙΑΤΡΟΦΗ', 'HEALTH & NUTRITION'),
    _ToolCategory.insights => l.text('COACH & ΑΝΑΛΥΣΗ', 'COACH & INSIGHTS'),
    _ToolCategory.data => l.text('ΔΕΔΟΜΕΝΑ & ΡΥΘΜΙΣΕΙΣ', 'DATA & SETTINGS'),
  };
}

class _ToolEntry {
  const _ToolEntry({
    required this.route,
    required this.category,
    required this.icon,
    required this.greekTitle,
    required this.englishTitle,
    required this.greekDescription,
    required this.englishDescription,
    this.keywords = '',
  });

  final String route;
  final _ToolCategory category;
  final IconData icon;
  final String greekTitle;
  final String englishTitle;
  final String greekDescription;
  final String englishDescription;
  final String keywords;

  String title(PhoenixL10n l) => l.text(greekTitle, englishTitle);
  String description(PhoenixL10n l) =>
      l.text(greekDescription, englishDescription);
  String get searchText =>
      '$greekTitle $englishTitle $greekDescription $englishDescription $keywords'
          .toLowerCase();
}

const _tools = <_ToolEntry>[
  _ToolEntry(
    route: 'education',
    category: _ToolCategory.insights,
    icon: Icons.school_outlined,
    greekTitle: 'Phoenix Education',
    englishTitle: 'Phoenix Education',
    greekDescription: 'Offline cues, λάθη, effort, nutrition και recovery.',
    englishDescription:
        'Offline cues, errors, effort, nutrition, and recovery.',
    keywords:
        'education cue tutorial error rpe rir pain warmup nutrition recovery',
  ),
  _ToolEntry(
    route: 'collaboration',
    category: _ToolCategory.data,
    icon: Icons.group_work_outlined,
    greekTitle: 'Local Collaboration',
    englishTitle: 'Local Collaboration',
    greekDescription:
        'Expiring coach views, session codes και approval preview.',
    englishDescription:
        'Expiring coach views, session codes, and approval preview.',
    keywords: 'coach export snapshot share code partner challenge redacted',
  ),
  _ToolEntry(
    route: 'structured-transfer',
    category: _ToolCategory.data,
    icon: Icons.import_export_outlined,
    greekTitle: 'Structured Import / Export',
    englishTitle: 'Structured Import / Export',
    greekDescription: 'Workout/nutrition CSV, GPX, ICS και selective restore.',
    englishDescription:
        'Workout/nutrition CSV, GPX, ICS, and selective restore.',
    keywords: 'csv strong hevy gpx ics schema incremental selective restore',
  ),
  _ToolEntry(
    route: 'planner',
    category: _ToolCategory.training,
    icon: Icons.calendar_view_week,
    greekTitle: 'Εβδομαδιαίο πλάνο',
    englishTitle: 'Weekly Planner',
    greekDescription: 'Οργάνωσε προπονήσεις και ημέρες αποκατάστασης.',
    englishDescription: 'Organize training and recovery days.',
    keywords: 'schedule calendar πρόγραμμα ημερολόγιο',
  ),
  _ToolEntry(
    route: 'architecture',
    category: _ToolCategory.training,
    icon: Icons.architecture_outlined,
    greekTitle: 'Αρχιτέκτονας προγράμματος',
    englishTitle: 'Program Architect',
    greekDescription: 'Σχεδίασε mesocycle, split και εβδομαδιαίο όγκο.',
    englishDescription: 'Design mesocycles, splits and weekly volume.',
    keywords: 'builder design mesocycle split volume',
  ),
  _ToolEntry(
    route: 'exercise-lab',
    category: _ToolCategory.training,
    icon: Icons.hub_outlined,
    greekTitle: 'Βιβλιοθήκη ασκήσεων',
    englishTitle: 'Exercise Intelligence',
    greekDescription: 'Μύες, εξοπλισμός, ασφάλεια και παραλλαγές.',
    englishDescription: 'Muscles, equipment, safety and substitutions.',
    keywords: 'exercise guide taxonomy progression substitution άσκηση',
  ),
  _ToolEntry(
    route: 'test',
    category: _ToolCategory.training,
    icon: Icons.speed_outlined,
    greekTitle: 'Τεστ δύναμης',
    englishTitle: 'Strength Test',
    greekDescription: 'Ασφαλές AMRAP και εκτίμηση 1RM.',
    englishDescription: 'Safe AMRAP and estimated 1RM testing.',
    keywords: 'amrap e1rm 1rm',
  ),
  _ToolEntry(
    route: 'strength-lab',
    category: _ToolCategory.training,
    icon: Icons.fitness_center,
    greekTitle: 'Strength Lab',
    englishTitle: 'Strength Lab',
    greekDescription: 'Μεγάλα lifts, πλάκες, πρωτόκολλα και προσπάθειες.',
    englishDescription: 'Big lifts, plate loading, protocols and attempts.',
    keywords: 'barbell powerlifting plates strength δύναμη',
  ),
  _ToolEntry(
    route: 'hypertrophy',
    category: _ToolCategory.training,
    icon: Icons.equalizer,
    greekTitle: 'Υπερτροφία',
    englishTitle: 'Hypertrophy Lab',
    greekDescription: 'Όγκος ανά μυ, stimulus και τεχνικές έντασης.',
    englishDescription: 'Muscle volume, stimulus and intensity techniques.',
    keywords: 'mev mav mrv volume muscle',
  ),
  _ToolEntry(
    route: 'calisthenics',
    category: _ToolCategory.training,
    icon: Icons.sports_gymnastics,
    greekTitle: 'Calisthenics Lab',
    englishTitle: 'Calisthenics Lab',
    greekDescription: 'Skill trees, assessments και practice sessions.',
    englishDescription: 'Skill trees, assessments and practice sessions.',
    keywords: 'handstand pull up l-sit skills καλλισθενική',
  ),
  _ToolEntry(
    route: 'advanced-cali',
    category: _ToolCategory.training,
    icon: Icons.sports_martial_arts,
    greekTitle: 'Προχωρημένη καλλισθενική',
    englishTitle: 'Advanced Calisthenics',
    greekDescription: 'Muscle-up, levers, planche και readiness.',
    englishDescription: 'Muscle-up, levers, planche and readiness.',
    keywords: 'rings false grip straight arm',
  ),
  _ToolEntry(
    route: 'conditioning',
    category: _ToolCategory.training,
    icon: Icons.favorite_outline,
    greekTitle: 'Conditioning Lab',
    englishTitle: 'Conditioning Lab',
    greekDescription: 'Ζώνες καρδιακού ρυθμού, intervals και benchmarks.',
    englishDescription: 'Heart-rate zones, intervals and benchmarks.',
    keywords: 'cardio aerobic zone 2 conditioning αντοχή',
  ),
  _ToolEntry(
    route: 'running',
    category: _ToolCategory.training,
    icon: Icons.directions_run,
    greekTitle: 'Running Lab',
    englishTitle: 'Running Lab',
    greekDescription: 'Ρυθμός, 5K πλάνα, χιλιόμετρα και παπούτσια.',
    englishDescription: 'Pace, 5K plans, mileage and shoes.',
    keywords: 'run pace 5k mileage race τρέξιμο',
  ),
  _ToolEntry(
    route: 'endurance',
    category: _ToolCategory.training,
    icon: Icons.pedal_bike,
    greekTitle: 'Ποδήλατο & κωπηλατική',
    englishTitle: 'Cycling & Rowing',
    greekDescription: 'FTP, power zones, rowing splits και multisport load.',
    englishDescription: 'FTP, power zones, rowing splits and multisport load.',
    keywords: 'bike erg watts cycling rowing ποδήλατο κωπηλατική',
  ),
  _ToolEntry(
    route: 'mobility',
    category: _ToolCategory.training,
    icon: Icons.accessibility_new,
    greekTitle: 'Mobility Lab',
    englishTitle: 'Mobility Lab',
    greekDescription: 'Κινητικότητα και ασφαλής προετοιμασία.',
    englishDescription: 'Mobility and safe session preparation.',
    keywords: 'warmup stretch κινητικότητα ζέσταμα',
  ),
  _ToolEntry(
    route: 'mobility-intelligence',
    category: _ToolCategory.training,
    icon: Icons.accessibility,
    greekTitle: 'Mobility Intelligence',
    englishTitle: 'Mobility Intelligence',
    greekDescription: 'Joint screens, ασυμμετρίες και επανέλεγχοι.',
    englishDescription: 'Joint screens, asymmetry and retesting.',
    keywords: 'ankle hip shoulder thoracic screen',
  ),
  _ToolEntry(
    route: 'nutrition',
    category: _ToolCategory.health,
    icon: Icons.lunch_dining_outlined,
    greekTitle: 'Διατροφή',
    englishTitle: 'Nutrition Pro',
    greekDescription: 'Γεύματα, macros, νερό και grocery list.',
    englishDescription: 'Meals, macros, water and grocery list.',
    keywords: 'meal calories protein macros νερό γεύμα',
  ),
  _ToolEntry(
    route: 'photo-meal',
    category: _ToolCategory.health,
    icon: Icons.photo_camera_outlined,
    greekTitle: 'Photo Meal Scan',
    englishTitle: 'Photo Meal Scan',
    greekDescription: 'Τοπική φωτογραφία και διαφανής εκτίμηση γεύματος.',
    englishDescription: 'Local photo and transparent meal estimate.',
    keywords: 'camera gallery food scan φωτογραφία',
  ),
  _ToolEntry(
    route: 'nutrition-planner',
    category: _ToolCategory.health,
    icon: Icons.calendar_month_outlined,
    greekTitle: 'Πλάνο διατροφής',
    englishTitle: 'Nutrition Planner',
    greekDescription: 'Θερμίδες, macros, timing και diet transitions.',
    englishDescription: 'Calories, macros, timing and diet transitions.',
    keywords: 'diet calorie phase protein carbs fiber',
  ),
  _ToolEntry(
    route: 'meal-intelligence',
    category: _ToolCategory.health,
    icon: Icons.soup_kitchen_outlined,
    greekTitle: 'Meal Intelligence',
    englishTitle: 'Meal Intelligence',
    greekDescription: 'Συνταγές, pantry, budget και batch cooking.',
    englishDescription: 'Recipes, pantry, budget and batch cooking.',
    keywords: 'ingredient recipe grocery expiry pantry',
  ),
  _ToolEntry(
    route: 'body-composition',
    category: _ToolCategory.health,
    icon: Icons.monitor_weight_outlined,
    greekTitle: 'Σύσταση σώματος',
    englishTitle: 'Body Composition',
    greekDescription: 'Βάρος, μετρήσεις, φωτογραφίες και προβολές.',
    englishDescription: 'Weight, measurements, photos and projections.',
    keywords: 'weight waist body fat progress photo βάρος',
  ),
  _ToolEntry(
    route: 'recovery',
    category: _ToolCategory.health,
    icon: Icons.monitor_heart_outlined,
    greekTitle: 'Recovery Lab',
    englishTitle: 'Recovery Lab',
    greekDescription: 'Readiness, ύπνος, κόπωση και επιστροφή.',
    englishDescription: 'Readiness, sleep, fatigue and return to training.',
    keywords: 'recovery sleep soreness αποκατάσταση ύπνος',
  ),
  _ToolEntry(
    route: 'recovery-intelligence',
    category: _ToolCategory.health,
    icon: Icons.query_stats,
    greekTitle: 'Recovery Intelligence',
    englishTitle: 'Recovery Intelligence',
    greekDescription: 'Trends, sleep debt, RHR alerts και interventions.',
    englishDescription: 'Trends, sleep debt, RHR alerts and interventions.',
    keywords: 'stress resting heart rate baseline forecast',
  ),
  _ToolEntry(
    route: 'habit-builder',
    category: _ToolCategory.health,
    icon: Icons.add_task,
    greekTitle: 'Συνήθειες',
    englishTitle: 'Habit Builder',
    greekDescription: 'Καθημερινό checklist, streaks και μικρές δράσεις.',
    englishDescription: 'Daily checklist, streaks and small actions.',
    keywords: 'habit streak checklist συνήθεια',
  ),
  _ToolEntry(
    route: 'sleep-stress',
    category: _ToolCategory.health,
    icon: Icons.bedtime_outlined,
    greekTitle: 'Ύπνος & στρες',
    englishTitle: 'Sleep & Stress',
    greekDescription: 'Πρόγραμμα ύπνου, caffeine cutoff και χαλάρωση.',
    englishDescription: 'Sleep schedule, caffeine cutoff and relaxation.',
    keywords: 'bedtime wake caffeine stress ύπνος στρες',
  ),
  _ToolEntry(
    route: 'coach',
    category: _ToolCategory.insights,
    icon: Icons.psychology_alt_outlined,
    greekTitle: 'Phoenix Coach',
    englishTitle: 'Phoenix Coach',
    greekDescription: 'Σημερινές ενέργειες, plateau radar και φάσεις.',
    englishDescription: 'Daily actions, plateau radar and phases.',
    keywords: 'coach recommendation plateau reschedule',
  ),
  _ToolEntry(
    route: 'advanced-coach',
    category: _ToolCategory.insights,
    icon: Icons.account_tree_outlined,
    greekTitle: 'Advanced Coach',
    englishTitle: 'Advanced Coach',
    greekDescription: 'Εξηγήσιμες προτάσεις, feedback και safety rules.',
    englishDescription: 'Explainable advice, feedback and safety rules.',
    keywords: 'recommendation confidence review safety',
  ),
  _ToolEntry(
    route: 'analytics',
    category: _ToolCategory.insights,
    icon: Icons.analytics_outlined,
    greekTitle: 'Προηγμένα analytics',
    englishTitle: 'Advanced Analytics',
    greekDescription: 'e1RM, PRs, φόρτος, συνέπεια και exports.',
    englishDescription: 'e1RM, PRs, workload, consistency and exports.',
    keywords: 'statistics pr load progress analytics',
  ),
  _ToolEntry(
    route: 'analytics-studio',
    category: _ToolCategory.insights,
    icon: Icons.dashboard_customize_outlined,
    greekTitle: 'Analytics Studio',
    englishTitle: 'Analytics Studio',
    greekDescription: 'Custom metrics, συγκρίσεις, heatmaps και forecasts.',
    englishDescription: 'Custom metrics, comparisons, heatmaps and forecasts.',
    keywords: 'dashboard monotony strain forecast',
  ),
  _ToolEntry(
    route: 'reports',
    category: _ToolCategory.insights,
    icon: Icons.description_outlined,
    greekTitle: 'Reports Studio',
    englishTitle: 'Reports Studio',
    greekDescription: 'Τοπικά reports προόδου και coach handoff.',
    englishDescription: 'Local progress reports and coach handoff.',
    keywords: 'report weekly monthly print copy pdf αναφορά',
  ),
  _ToolEntry(
    route: 'capability-studio',
    category: _ToolCategory.insights,
    icon: Icons.hub_outlined,
    greekTitle: 'Capability Studio 289',
    englishTitle: 'Capability Studio 289',
    greekDescription:
        '289 persisted local-first controls, audits και planners.',
    englishDescription:
        '289 persisted local-first controls, audits, and planners.',
    keywords: '289 roadmap capability audit planner security accessibility',
  ),
  _ToolEntry(
    route: 'control',
    category: _ToolCategory.data,
    icon: Icons.tune,
    greekTitle: 'Κέντρο ελέγχου',
    englishTitle: 'Control Center',
    greekDescription: 'Κεντρική πρόσβαση σε προφίλ, δεδομένα και ρυθμίσεις.',
    englishDescription: 'Central access to profiles, data and settings.',
    keywords: 'control settings profile data',
  ),
  _ToolEntry(
    route: 'media',
    category: _ToolCategory.data,
    icon: Icons.qr_code_2,
    greekTitle: 'Media & Portability',
    englishTitle: 'Media & Portability',
    greekDescription: 'Backups, QR, PDF, φωτογραφίες και wearable import.',
    englishDescription: 'Backups, QR, PDF, photos and wearable import.',
    keywords: 'backup export import share photo wearable',
  ),
  _ToolEntry(
    route: 'reliability',
    category: _ToolCategory.data,
    icon: Icons.verified_user_outlined,
    greekTitle: 'Κέντρο αξιοπιστίας',
    englishTitle: 'Reliability Center',
    greekDescription: 'SQLite, migrations, profiles, reminders και audit.',
    englishDescription: 'SQLite, migrations, profiles, reminders and audit.',
    keywords: 'database diagnostics release migration',
  ),
  _ToolEntry(
    route: 'validation',
    category: _ToolCategory.data,
    icon: Icons.fact_check_outlined,
    greekTitle: 'Έλεγχος δεδομένων',
    englishTitle: 'Data Validation',
    greekDescription: 'Έλεγξε και επισκεύασε τοπικές ασυνέπειες.',
    englishDescription: 'Inspect and repair local inconsistencies.',
    keywords: 'repair integrity validation δεδομένα',
  ),
  _ToolEntry(
    route: 'vault',
    category: _ToolCategory.data,
    icon: Icons.lock_outline,
    greekTitle: 'Ιδιωτικό Vault',
    englishTitle: 'Private Vault',
    greekDescription: 'PIN, timeout και προστασία ιδιωτικών δεδομένων.',
    englishDescription: 'PIN, timeout and private-data protection.',
    keywords: 'security privacy pin lock ασφάλεια',
  ),
  _ToolEntry(
    route: 'profile',
    category: _ToolCategory.data,
    icon: Icons.person_outline,
    greekTitle: 'Προφίλ αθλητή',
    englishTitle: 'Athlete Profile',
    greekDescription: 'Στόχος, εμπειρία, εξοπλισμός και περιορισμοί.',
    englishDescription: 'Goal, experience, equipment and limitations.',
    keywords: 'profile goal equipment athlete προφίλ',
  ),
  _ToolEntry(
    route: 'settings',
    category: _ToolCategory.data,
    icon: Icons.settings_outlined,
    greekTitle: 'Εμπειρία εφαρμογής',
    englishTitle: 'App Experience',
    greekDescription: 'Γλώσσα, θέμα, αντίθεση και feedback.',
    englishDescription: 'Language, theme, contrast and feedback.',
    keywords: 'language theme contrast accessibility ρυθμίσεις',
  ),
];
