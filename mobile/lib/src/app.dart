import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'active_workout_page.dart';
import 'advanced_coach_page.dart';
import 'advanced_calisthenics_page.dart';
import 'advanced_analytics_page.dart';
import 'analytics_studio_page.dart';
import 'body_composition_page.dart';
import 'control_center_page.dart';
import 'conditioning_lab_page.dart';
import 'cycling_rowing_lab_page.dart';
import 'coach_hub_page.dart';
import 'calisthenics_lab_page.dart';
import 'data_validation_page.dart';
import 'exercise_guide.dart';
import 'exercise_intelligence_page.dart';
import 'experience_settings_page.dart';
import 'fitness_charts.dart';
import 'global_search_page.dart';
import 'habit_builder_page.dart';
import 'hypertrophy_lab_page.dart';
import 'media_portability_page.dart';
import 'meal_intelligence_page.dart';
import 'models/fitness_models.dart';
import 'mobility_intelligence_page.dart';
import 'mobility_page.dart';
import 'nutrition_page.dart';
import 'nutrition_planner_page.dart';
import 'onboarding_page.dart';
import 'phoenix_l10n.dart';
import 'phoenix_toolbox_page.dart';
import 'photo_meal_scan_page.dart';
import 'profile_editor_page.dart';
import 'program_architecture_page.dart';
import 'program_editor_page.dart';
import 'program_history_page.dart';
import 'recovery_engine.dart';
import 'recovery_intelligence_page.dart';
import 'recovery_lab_page.dart';
import 'recovery_widgets.dart';
import 'reliability_center_page.dart';
import 'reports_studio_page.dart';
import 'running_lab_page.dart';
import 'sleep_stress_page.dart';
import 'state/fitness_store.dart';
import 'spotify_card.dart';
import 'training_history.dart';
import 'training_intelligence_widgets.dart';
import 'training_schedule.dart';
import 'strength_test_page.dart';
import 'strength_lab_page.dart';
import 'weekly_planner_page.dart';
import 'vault_security_page.dart';

class PhoenixApp extends StatefulWidget {
  const PhoenixApp({super.key, required this.store});

  final FitnessStore store;

  @override
  State<PhoenixApp> createState() => _PhoenixAppState();
}

class _PhoenixAppState extends State<PhoenixApp> with WidgetsBindingObserver {
  DateTime? _backgroundedAt;
  bool _privacyShielded = false;

  FitnessStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _backgroundedAt ??= DateTime.now();
      if (!_privacyShielded && mounted) {
        setState(() => _privacyShielded = true);
      }
      return;
    }
    if (state == AppLifecycleState.resumed && _backgroundedAt != null) {
      final elapsed = DateTime.now().difference(_backgroundedAt!);
      final timeout = store.preferences.lockTimeoutMinutes;
      if (store.hasVaultPin &&
          (timeout == 0 || elapsed >= Duration(minutes: timeout))) {
        store.lockVault();
      }
      _backgroundedAt = null;
      if (_privacyShielded && mounted) {
        setState(() => _privacyShielded = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final previewScreen = Uri.base.queryParameters['preview'] == '1'
            ? Uri.base.queryParameters['screen']
            : null;
        final home = switch (previewScreen) {
          'control' => ControlCenterPage(store: store),
          'builder' => ProgramEditorPage(
            store: store,
            template: store.data.templates.first,
          ),
          'mobility' => MobilityPage(store: store),
          'mobility-intelligence' => MobilityIntelligencePage(store: store),
          'planner' => WeeklyPlannerPage(store: store),
          'history' => ProgramHistoryPage(
            store: store,
            templateId: store.data.templates.first.id,
          ),
          'recovery' => RecoveryLabPage(store: store),
          'recovery-intelligence' => RecoveryIntelligencePage(store: store),
          'nutrition-planner' => NutritionPlannerPage(store: store),
          'meal-intelligence' => MealIntelligencePage(store: store),
          'body-composition' => BodyCompositionPage(store: store),
          'habit-builder' => HabitBuilderPage(store: store),
          'sleep-stress' => SleepStressPage(store: store),
          'analytics' => AdvancedAnalyticsPage(store: store),
          'analytics-studio' => AnalyticsStudioPage(store: store),
          'reports' => ReportsStudioPage(store: store),
          'settings' => ExperienceSettingsPage(store: store),
          'search' => GlobalSearchPage(store: store),
          'validation' => DataValidationPage(store: store),
          'profile' => ProfileEditorPage(store: store),
          'vault' => VaultSecurityPage(store: store),
          'coach' => CoachHubPage(store: store),
          'advanced-coach' => AdvancedCoachPage(store: store),
          'test' => StrengthTestPage(store: store),
          'calisthenics' => CalisthenicsLabPage(store: store),
          'advanced-cali' => AdvancedCalisthenicsPage(store: store),
          'media' => MediaPortabilityPage(store: store),
          'reliability' => ReliabilityCenterPage(store: store),
          'exercise-lab' => ExerciseIntelligencePage(store: store),
          'architecture' => ProgramArchitecturePage(store: store),
          'strength-lab' => StrengthLabPage(store: store),
          'hypertrophy' => HypertrophyLabPage(store: store),
          'conditioning' => ConditioningLabPage(store: store),
          'running' => RunningLabPage(store: store),
          'endurance' => CyclingRowingLabPage(store: store),
          _ => OnboardingGate(store: store),
        };
        return MaterialApp(
          title: 'Phoenix',
          debugShowCheckedModeBanner: false,
          locale: Locale(store.preferences.languageCode),
          supportedLocales: const [
            Locale('el'),
            Locale('en'),
            Locale('de'),
            Locale('es'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: ThemeMode.dark,
          darkTheme: _phoenixTheme(store.preferences),
          builder: (context, child) {
            final media = MediaQuery.of(context);
            final systemScale = media.textScaler.scale(16) / 16;
            final combinedScale = (systemScale * store.preferences.textScale)
                .clamp(.8, 2.0);
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(combinedScale),
                disableAnimations:
                    media.disableAnimations || store.preferences.reducedMotion,
              ),
              child: FocusTraversalGroup(
                policy: ReadingOrderTraversalPolicy(),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: _privacyShielded ? const _PrivacyShield() : home,
        );
      },
    );
  }
}

class _PrivacyShield extends StatelessWidget {
  const _PrivacyShield();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Semantics(
        label: 'Phoenix private screen hidden',
        child: const Icon(Icons.shield_outlined, size: 72),
      ),
    ),
  );
}

ThemeData _phoenixTheme(AppPreferences preferences) {
  final themeSeed = switch (preferences.themePreset) {
    'ocean' => const Color(0xFF29B6F6),
    'forest' => const Color(0xFF66BB6A),
    _ => const Color(0xFFFF3D00),
  };
  final seed = switch (preferences.colorVisionMode) {
    'deuteranopia' => const Color(0xFF4D9DE0),
    'tritanopia' => const Color(0xFFE1559A),
    _ => themeSeed,
  };
  final highContrast = preferences.highContrast;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ).copyWith(
        surface: highContrast ? Colors.black : const Color(0xFF141210),
        onSurface: highContrast ? Colors.white : null,
        outline: highContrast ? Colors.white70 : null,
      );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    fontFamilyFallback: preferences.readabilityFont
        ? const ['Verdana', 'Arial', 'sans-serif']
        : null,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity(
      horizontal: (preferences.touchTargetScale - 1) * 4,
      vertical: (preferences.touchTargetScale - 1) * 4,
    ),
    pageTransitionsTheme: preferences.reducedMotion
        ? const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: _NoPageTransitionsBuilder(),
              TargetPlatform.iOS: _NoPageTransitionsBuilder(),
              TargetPlatform.macOS: _NoPageTransitionsBuilder(),
              TargetPlatform.windows: _NoPageTransitionsBuilder(),
              TargetPlatform.linux: _NoPageTransitionsBuilder(),
            },
          )
        : const PageTransitionsTheme(),
    scaffoldBackgroundColor: highContrast
        ? Colors.black
        : const Color(0xFF080808),
    cardTheme: CardThemeData(
      color: highContrast ? const Color(0xFF050505) : const Color(0xFF141210),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: highContrast ? Colors.white54 : seed.withValues(alpha: .12),
          width: highContrast ? 1.4 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: highContrast ? Colors.black : const Color(0xFF100E0D),
      indicatorColor: seed.withValues(alpha: highContrast ? .45 : .28),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          color: highContrast ? Colors.white : null,
          fontWeight: highContrast ? FontWeight.w800 : null,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: seed,
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: highContrast ? Colors.white70 : Colors.white24,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: seed, width: 2),
      ),
    ),
  );
}

class _NoPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}

class OnboardingGate extends StatelessWidget {
  const OnboardingGate({super.key, required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (store.needsOnboarding) {
          return OnboardingPage(store: store);
        }
        return PhoenixShell(store: store);
      },
    );
  }
}

class PhoenixShell extends StatefulWidget {
  const PhoenixShell({super.key, required this.store});

  final FitnessStore store;

  @override
  State<PhoenixShell> createState() => _PhoenixShellState();
}

void _openWorkout(
  BuildContext context,
  FitnessStore store,
  WorkoutTemplate template,
) {
  if (!store.hasActiveWorkout) store.startWorkout(template);
  if (!store.hasActiveWorkout) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Οι προπονήσεις είναι σε pause mode. Άνοιξε το Recovery Lab.',
        ),
      ),
    );
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => ActiveWorkoutPage(store: store),
    ),
  );
}

void _openProgramEditor(
  BuildContext context,
  FitnessStore store,
  WorkoutTemplate template,
) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => ProgramEditorPage(store: store, template: template),
    ),
  );
}

class _PhoenixShellState extends State<PhoenixShell> {
  late int _index = switch (Uri.base.queryParameters['screen']) {
    'workouts' => 1,
    'nutrition' => 2,
    'progress' => 3,
    _ => 0,
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final pages = [
          DashboardPage(store: widget.store),
          WorkoutsPage(store: widget.store),
          NutritionPage(store: widget.store),
          ProgressPage(store: widget.store),
        ];
        final labels = [
          context.l10n.text('Αρχική', 'Home'),
          context.l10n.text('Προπόνηση', 'Training'),
          context.l10n.text('Διατροφή', 'Nutrition'),
          context.l10n.text('Πρόοδος', 'Progress'),
        ];
        const icons = [
          Icons.space_dashboard_outlined,
          Icons.fitness_center_outlined,
          Icons.restaurant_outlined,
          Icons.show_chart,
        ];
        return CallbackShortcuts(
          bindings: {
            for (var index = 0; index < pages.length; index++)
              SingleActivator(switch (index) {
                0 => LogicalKeyboardKey.digit1,
                1 => LogicalKeyboardKey.digit2,
                2 => LogicalKeyboardKey.digit3,
                _ => LogicalKeyboardKey.digit4,
              }, control: true): () =>
                  setState(() => _index = index),
          },
          child: Focus(
            autofocus: true,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final desktop = constraints.maxWidth >= 900;
                return Scaffold(
                  body: SafeArea(
                    child: desktop
                        ? Row(
                            children: [
                              NavigationRail(
                                extended: constraints.maxWidth >= 1200,
                                selectedIndex: _index,
                                onDestinationSelected: (value) =>
                                    setState(() => _index = value),
                                labelType: constraints.maxWidth >= 1200
                                    ? NavigationRailLabelType.none
                                    : NavigationRailLabelType.all,
                                destinations: [
                                  for (
                                    var index = 0;
                                    index < labels.length;
                                    index++
                                  )
                                    NavigationRailDestination(
                                      icon: Icon(icons[index]),
                                      label: Text(labels[index]),
                                    ),
                                ],
                              ),
                              const VerticalDivider(width: 1),
                              Expanded(child: pages[_index]),
                            ],
                          )
                        : pages[_index],
                  ),
                  bottomNavigationBar: desktop
                      ? null
                      : NavigationBar(
                          selectedIndex: _index,
                          onDestinationSelected: (value) =>
                              setState(() => _index = value),
                          destinations: [
                            for (var index = 0; index < labels.length; index++)
                              NavigationDestination(
                                icon: Icon(icons[index]),
                                label: labels[index],
                              ),
                          ],
                        ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final latestWeight = store.data.weights.isEmpty
        ? null
        : store.data.weights.first.kilograms;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'PHOENIX  //  TODAY',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton.filledTonal(
              tooltip: context.l10n.text('Αναζήτηση', 'Search'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => GlobalSearchPage(store: store),
                ),
              ),
              icon: const Icon(Icons.search),
            ),
            const SizedBox(width: 7),
            IconButton.filledTonal(
              tooltip: 'Control Center',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => ControlCenterPage(store: store),
                ),
              ),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.text('Καλώς επέστρεψες', 'Welcome back'),
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.text(
            'Μικρά βήματα. Μεγάλη αλλαγή.',
            'Small steps. Serious progress.',
          ),
          style: TextStyle(color: Colors.white.withValues(alpha: .6)),
        ),
        const SizedBox(height: 20),
        RecoveryCheckInCard(store: store),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => RecoveryLabPage(store: store),
              ),
            ),
            icon: const Icon(Icons.monitor_heart_outlined),
            label: Text(
              context.l10n.text('Άνοιγμα Recovery Lab', 'Open Recovery Lab'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _DailyMissionCard(
          store: store,
          template: store.recommendedWorkout,
          active: store.hasActiveWorkout,
          onStart: () => _openWorkout(context, store, store.recommendedWorkout),
        ),
        if (store.hasActiveWorkout) ...[
          const SizedBox(height: 12),
          _ActiveWorkoutCard(store: store),
        ],
        if (store.dueWorkoutReminders(DateTime.now()).isNotEmpty) ...[
          const SizedBox(height: 12),
          _DueReminderCard(store: store),
        ],
        const SizedBox(height: 12),
        _TodayActionsCard(store: store),
        const SizedBox(height: 12),
        _PhoenixBriefCard(store: store),
        const SizedBox(height: 12),
        PeriodizationCard(store: store),
        const SizedBox(height: 12),
        _DailyExercisesCard(template: store.recommendedWorkout),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                value: '${store.workoutsThisWeek}',
                label: 'Προπονήσεις\n7 ημερών',
                icon: Icons.local_fire_department,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                value: latestWeight == null
                    ? '—'
                    : '${latestWeight.toStringAsFixed(1)} kg',
                label: 'Τελευταίο\nβάρος',
                icon: Icons.monitor_weight_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                value: '${store.lifetimeSets}',
                label: 'Συνολικά\nσετ',
                icon: Icons.layers_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                value: store.bestEstimatedOneRepMax == 0
                    ? '—'
                    : '${store.bestEstimatedOneRepMax.toStringAsFixed(1)} kg',
                label: 'Καλύτερο\ne1RM',
                icon: Icons.military_tech_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                value: '${store.caloriesToday}',
                label: 'Θερμίδες\nσήμερα',
                icon: Icons.local_dining_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                value: '${store.proteinToday.toStringAsFixed(1)} g',
                label: 'Πρωτεΐνη\nσήμερα',
                icon: Icons.egg_alt_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SpotifyCard(store: store),
      ],
    );
  }
}

class _TodayActionsCard extends StatelessWidget {
  const _TodayActionsCard({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Future<void> addWater() async {
      await store.addWater(250);
      await store.feedback(success: true);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l.text('+250 ml νερό καταγράφηκαν.', '+250 ml water logged.'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.text('ΣΗΜΕΡΙΝΕΣ ΕΝΕΡΓΕΙΕΣ', 'TODAY ACTIONS'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickAction(
                  icon: Icons.photo_camera_outlined,
                  label: l.text('Photo meal', 'Photo meal'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PhotoMealScanPage(store: store),
                    ),
                  ),
                ),
                _QuickAction(
                  icon: Icons.lunch_dining_outlined,
                  label: l.text('Γεύμα', 'Meal'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => NutritionPage(store: store),
                    ),
                  ),
                ),
                _QuickAction(
                  icon: Icons.water_drop_outlined,
                  label: '+250 ml',
                  onTap: addWater,
                ),
                _QuickAction(
                  icon: Icons.psychology_alt_outlined,
                  label: l.text('Coach', 'Coach'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CoachHubPage(store: store),
                    ),
                  ),
                ),
                _QuickAction(
                  icon: Icons.grid_view_rounded,
                  label: l.text('Όλα τα εργαλεία', 'All tools'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PhoenixToolboxPage(store: store),
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

class _DueReminderCard extends StatelessWidget {
  const _DueReminderCard({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final reminders = store.dueWorkoutReminders(DateTime.now());
    final reminder = reminders.first;
    final template = reminder.templateId.isEmpty
        ? store.recommendedWorkout
        : store.data.templates.firstWhere(
            (item) => item.id == reminder.templateId,
            orElse: () => store.recommendedWorkout,
          );
    return Card(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
      child: ListTile(
        leading: Icon(
          Icons.notifications_active,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          'WORKOUT REMINDER • ${reminder.timeLabel}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(template.name),
        trailing: FilledButton(
          onPressed: () => _openWorkout(context, store, template),
          child: const Text('START'),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
    avatar: Icon(icon, size: 18),
    label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    onPressed: onTap,
    side: BorderSide(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: .35),
    ),
  );
}

class _PhoenixBriefCard extends StatelessWidget {
  const _PhoenixBriefCard({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final now = DateTime.now();
    final next = store.weeklySchedule.nextEntry(now);
    final recovery = store.todaysRecoveryPlan;
    final nutrition = store.nutritionCoach;
    final trainingText = next == null
        ? l.text(
            'Ο εβδομαδιαίος στόχος ολοκληρώθηκε.',
            'The weekly training target is complete.',
          )
        : next.isOverdue(now)
        ? l.text(
            '${next.template.name.split(' — ').first} παραμένει σε εκκρεμότητα.',
            '${next.template.name.split(' — ').first} is still pending.',
          )
        : next.isToday(now)
        ? l.text(
            '${next.template.name.split(' — ').first} είναι η σημερινή αποστολή.',
            '${next.template.name.split(' — ').first} is today’s mission.',
          )
        : l.text(
            'Επόμενη προπόνηση ${next.date.day}/${next.date.month}.',
            'Next workout: ${next.date.day}/${next.date.month}.',
          );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFFFF6E40), size: 20),
                SizedBox(width: 9),
                Text(
                  'PHOENIX BRIEF',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            _BriefLine(icon: Icons.fitness_center, text: trainingText),
            const SizedBox(height: 9),
            _BriefLine(
              icon: Icons.battery_charging_full,
              text: recovery == null
                  ? l.text(
                      'Κάνε readiness check-in πριν από βαριά προπόνηση.',
                      'Complete a readiness check-in before heavy training.',
                    )
                  : l.isEnglish
                  ? '${switch (recovery.mode) {
                      RecoveryMode.ready => 'Ready for full intensity',
                      RecoveryMode.controlled => 'Controlled intensity',
                      RecoveryMode.recovery => 'Recovery takes priority',
                    }} (${recovery.score}/100).'
                  : '${recovery.headline} (${recovery.score}/100).',
              color: switch (recovery?.mode) {
                RecoveryMode.ready => const Color(0xFF81C784),
                RecoveryMode.controlled => const Color(0xFFFFB74D),
                RecoveryMode.recovery => const Color(0xFFEF9A9A),
                null => const Color(0xFFFFAB91),
              },
            ),
            const SizedBox(height: 9),
            _BriefLine(
              icon: Icons.restaurant,
              text: l.isEnglish
                  ? '${store.caloriesToday}/${store.nutritionTargets.calories} kcal • '
                        '${store.proteinToday.toStringAsFixed(0)}/'
                        '${store.nutritionTargets.proteinGrams.toStringAsFixed(0)} g protein'
                  : '${nutrition.headline}: ${nutrition.detail}',
              color: const Color(0xFFFFCC80),
            ),
          ],
        ),
      ),
    );
  }
}

class _BriefLine extends StatelessWidget {
  const _BriefLine({
    required this.icon,
    required this.text,
    this.color = const Color(0xFFFF8A65),
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .68),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  final _search = TextEditingController();
  bool _favoritesOnly = false;
  String _selectedTag = 'Όλα';

  FitnessStore get store => widget.store;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<WorkoutTemplate> get _filteredTemplates {
    final query = _search.text.trim().toLowerCase();
    final templates = store.data.templates.where((template) {
      final matchesQuery =
          query.isEmpty ||
          template.name.toLowerCase().contains(query) ||
          template.exercises.any(
            (exercise) => exercise.toLowerCase().contains(query),
          );
      final matchesFavorite = !_favoritesOnly || template.isFavorite;
      final matchesTag =
          _selectedTag == 'Όλα' || template.tags.contains(_selectedTag);
      return matchesQuery && matchesFavorite && matchesTag;
    }).toList();
    templates.sort((left, right) {
      if (left.isFavorite != right.isFavorite) {
        return left.isFavorite ? -1 : 1;
      }
      return left.name.compareTo(right.name);
    });
    return templates;
  }

  Set<String> get _tags => {
    for (final template in store.data.templates) ...template.tags,
  };

  Future<void> _duplicate(WorkoutTemplate template) async {
    try {
      final copy = await store.duplicateWorkoutTemplate(template);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Δημιουργήθηκε: ${copy.name}')));
    } on FormatException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _delete(WorkoutTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Διαγραφή προγράμματος;'),
        content: Text(
          'Το “${template.name}” και το ιστορικό του θα αφαιρεθούν από τη '
          'συσκευή.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Άκυρο'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Διαγραφή'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await store.deleteCustomWorkout(template.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Το πρόγραμμα διαγράφηκε.'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: store.undoLastMutation,
          ),
        ),
      );
    } on FormatException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final templates = _filteredTemplates;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          context.l10n.text('Προπονήσεις', 'Training'),
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.text(
            'Το πλάνο της εβδομάδας και ολόκληρη η βιβλιοθήκη σου.',
            'Your weekly plan and complete workout library.',
          ),
          style: TextStyle(color: Colors.white.withValues(alpha: .6)),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => ProgramArchitecturePage(store: store),
                  ),
                ),
                icon: const Icon(Icons.architecture_outlined),
                label: const Text('Program Architecture'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => StrengthLabPage(store: store),
                  ),
                ),
                icon: const Icon(Icons.speed),
                label: const Text('Strength Lab'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => HypertrophyLabPage(store: store),
                  ),
                ),
                icon: const Icon(Icons.equalizer),
                label: const Text('Hypertrophy Lab'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => ConditioningLabPage(store: store),
                  ),
                ),
                icon: const Icon(Icons.favorite_outline),
                label: const Text('Conditioning Lab'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => RunningLabPage(store: store),
                  ),
                ),
                icon: const Icon(Icons.directions_run),
                label: const Text('Running Lab'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => CyclingRowingLabPage(store: store),
                  ),
                ),
                icon: const Icon(Icons.pedal_bike),
                label: const Text('Cycling & Rowing Lab'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        ExerciseIntelligencePage(store: store),
                  ),
                ),
                icon: const Icon(Icons.hub_outlined),
                label: const Text('Exercise Intelligence'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => MobilityPage(store: store),
                  ),
                ),
                icon: const Icon(Icons.self_improvement),
                label: const Text('Mobility Lab'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        MobilityIntelligencePage(store: store),
                  ),
                ),
                icon: const Icon(Icons.accessibility_new),
                label: const Text('Mobility Intelligence'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => WeeklyPlannerPage(store: store),
                  ),
                ),
                icon: const Icon(Icons.edit_calendar_outlined),
                label: const Text('Weekly Planner'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => CalisthenicsLabPage(store: store),
                  ),
                ),
                icon: const Icon(Icons.sports_gymnastics),
                label: const Text('Calisthenics Lab'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        AdvancedCalisthenicsPage(store: store),
                  ),
                ),
                icon: const Icon(Icons.sports_martial_arts),
                label: const Text('Advanced Calisthenics'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => MediaPortabilityPage(store: store),
                  ),
                ),
                icon: const Icon(Icons.ios_share),
                label: const Text('Media & Portability'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _WeeklyScheduleCard(store: store),
        const SizedBox(height: 28),
        Text(
          context.l10n.text('ΟΛΑ ΤΑ ΠΡΟΓΡΑΜΜΑΤΑ', 'ALL PROGRAMS'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: store.hasActiveWorkout
                  ? null
                  : () => _openProgramEditor(
                      context,
                      store,
                      store.createCustomWorkoutDraft(),
                    ),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.text('Νέο πρόγραμμα', 'New program')),
            ),
            OutlinedButton.icon(
              onPressed: store.hasActiveWorkout
                  ? null
                  : () => _openProgramEditor(
                      context,
                      store,
                      store.createRestDayDraft(),
                    ),
              icon: const Icon(Icons.spa_outlined),
              label: const Text('Rest-day template'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Αναζήτηση προγράμματος ή άσκησης',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                selected: _favoritesOnly,
                avatar: Icon(
                  _favoritesOnly ? Icons.star : Icons.star_border,
                  size: 17,
                ),
                label: const Text('Αγαπημένα'),
                onSelected: (value) => setState(() => _favoritesOnly = value),
              ),
              const SizedBox(width: 7),
              for (final tag in ['Όλα', ..._tags]) ...[
                ChoiceChip(
                  selected: _selectedTag == tag,
                  label: Text(tag),
                  onSelected: (_) => setState(() => _selectedTag = tag),
                ),
                const SizedBox(width: 7),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (templates.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(child: Text('Δεν βρέθηκαν προγράμματα.')),
          ),
        for (final template in templates) ...[
          _WorkoutCard(
            template: template,
            active: store.hasActiveWorkout,
            onStart: () => _openWorkout(context, store, template),
            onEdit: () => _openProgramEditor(context, store, template),
            onFavorite: () => store.toggleWorkoutFavorite(template.id),
            onDuplicate: () => _duplicate(template),
            onHistory: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) =>
                    ProgramHistoryPage(store: store, templateId: template.id),
              ),
            ),
            onDelete: template.id.startsWith('custom-')
                ? () => _delete(template)
                : null,
          ),
          const SizedBox(height: 12),
        ],
        if (store.hasActiveWorkout) _ActiveWorkoutCard(store: store),
      ],
    );
  }
}

class _WeeklyScheduleCard extends StatelessWidget {
  const _WeeklyScheduleCard({required this.store});

  final FitnessStore store;

  static const _shortDayNames = [
    'ΔΕΥ',
    'ΤΡΙ',
    'ΤΕΤ',
    'ΠΕΜ',
    'ΠΑΡ',
    'ΣΑΒ',
    'ΚΥΡ',
  ];

  static const _dayNames = [
    'Δευτέρα',
    'Τρίτη',
    'Τετάρτη',
    'Πέμπτη',
    'Παρασκευή',
    'Σάββατο',
    'Κυριακή',
  ];

  String _shortDate(DateTime date) => '${date.day}/${date.month}';

  String _weekRange(TrainingSchedule schedule) =>
      '${_shortDate(schedule.weekStart)} — ${_shortDate(schedule.weekEnd)}';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final schedule = store.weeklySchedule;
    final entriesByWeekday = {
      for (final entry in schedule.entries) entry.date.weekday: entry,
    };
    final next = schedule.nextEntry(now);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF21100C), Color(0xFF12100F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0x55FF3D00)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Color(0xFFFF6E40)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ΕΒΔΟΜΑΔΙΑΙΟ ΠΛΑΝΟ',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      _weekRange(schedule),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${schedule.completedCount}/${schedule.entries.length}',
                style: const TextStyle(
                  color: Color(0xFFFF9E80),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: schedule.progress,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: .08),
              color: const Color(0xFFFF3D00),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var weekday = 1; weekday <= 7; weekday++) ...[
                if (weekday > 1) const SizedBox(width: 5),
                Expanded(
                  child: _ScheduleDayTile(
                    label: _shortDayNames[weekday - 1],
                    date: schedule.weekStart.add(Duration(days: weekday - 1)),
                    entry: entriesByWeekday[weekday],
                    now: now,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          if (next == null)
            const _ScheduleCompleteBanner()
          else
            Text(
              next.isOverdue(now)
                  ? 'ΕΚΚΡΕΜΕΙ ΑΠΟ ${_dayNames[next.date.weekday - 1].toUpperCase()}'
                  : next.isToday(now)
                  ? 'ΣΗΜΕΡΙΝΗ ΠΡΟΠΟΝΗΣΗ'
                  : 'ΕΠΟΜΕΝΗ • ${_dayNames[next.date.weekday - 1].toUpperCase()}',
              style: const TextStyle(
                color: Color(0xFFFF9E80),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: .8,
              ),
            ),
          if (next != null) ...[
            const SizedBox(height: 6),
            Text(
              next.template.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
          const SizedBox(height: 14),
          for (final entry in schedule.entries) ...[
            _ScheduledWorkoutRow(
              entry: entry,
              now: now,
              active: store.hasActiveWorkout,
              onStart: () => _openWorkout(context, store, entry.template),
            ),
            if (entry != schedule.entries.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _ScheduleDayTile extends StatelessWidget {
  const _ScheduleDayTile({
    required this.label,
    required this.date,
    required this.entry,
    required this.now,
  });

  final String label;
  final DateTime date;
  final ScheduledWorkout? entry;
  final DateTime now;

  bool get _isToday =>
      date.year == now.year && date.month == now.month && date.day == now.day;

  @override
  Widget build(BuildContext context) {
    final completed = entry?.isCompleted ?? false;
    final overdue = entry?.isOverdue(now) ?? false;
    final accent = completed
        ? const Color(0xFF66BB6A)
        : _isToday
        ? const Color(0xFFFF6E40)
        : overdue
        ? const Color(0xFFEF5350)
        : Colors.white.withValues(alpha: .24);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: _isToday
            ? const Color(0x22FF3D00)
            : Colors.black.withValues(alpha: .18),
        border: Border.all(
          color: _isToday ? accent : Colors.white.withValues(alpha: .08),
        ),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: _isToday ? const Color(0xFFFFAB91) : Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${date.day}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Icon(
            completed
                ? Icons.check_circle
                : entry == null
                ? Icons.remove
                : Icons.fitness_center,
            size: 13,
            color: entry == null ? Colors.white24 : accent,
          ),
        ],
      ),
    );
  }
}

class _ScheduledWorkoutRow extends StatelessWidget {
  const _ScheduledWorkoutRow({
    required this.entry,
    required this.now,
    required this.active,
    required this.onStart,
  });

  final ScheduledWorkout entry;
  final DateTime now;
  final bool active;
  final VoidCallback onStart;

  static const _dayNames = ['ΔΕΥ', 'ΤΡΙ', 'ΤΕΤ', 'ΠΕΜ', 'ΠΑΡ', 'ΣΑΒ', 'ΚΥΡ'];

  @override
  Widget build(BuildContext context) {
    final completed = entry.isCompleted;
    final overdue = entry.isOverdue(now);
    final today = entry.isToday(now);
    final status = completed
        ? 'Ολοκληρώθηκε'
        : overdue
        ? 'Εκκρεμεί'
        : today
        ? 'Σήμερα'
        : 'Προγραμματισμένη';
    final statusColor = completed
        ? const Color(0xFF81C784)
        : overdue
        ? const Color(0xFFEF9A9A)
        : today
        ? const Color(0xFFFFAB91)
        : Colors.white54;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dayNames[entry.date.weekday - 1],
                  style: const TextStyle(
                    color: Color(0xFFFF8A65),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${entry.date.day}/${entry.date.month}',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.template.name.split(' — ').first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (completed)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.check, color: Color(0xFF81C784)),
            )
          else
            IconButton.filledTonal(
              onPressed: active ? null : onStart,
              tooltip: 'Έναρξη ${entry.template.name}',
              icon: const Icon(Icons.play_arrow, size: 20),
            ),
        ],
      ),
    );
  }
}

class _ScheduleCompleteBanner extends StatelessWidget {
  const _ScheduleCompleteBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x2232A852),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified, color: Color(0xFF81C784)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Η εβδομάδα ολοκληρώθηκε. Αποκατάσταση και επιστροφή δυνατότερος.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = double.tryParse(_controller.text.replaceAll(',', '.'));
    if (value == null) {
      _showMessage(
        context.l10n.text('Γράψε ένα έγκυρο βάρος.', 'Enter a valid weight.'),
      );
      return;
    }
    try {
      await widget.store.addWeight(value);
      _controller.clear();
      if (mounted) {
        _showMessage(
          context.l10n.text(
            'Το βάρος αποθηκεύτηκε τοπικά.',
            'Weight saved locally.',
          ),
        );
      }
    } on FormatException catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          context.l10n.text('Η πρόοδός σου', 'Your progress'),
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.text(
            'Τα δεδομένα μένουν μόνο στη συσκευή σου.',
            'Your data stays only on this device.',
          ),
          style: TextStyle(color: Colors.white.withValues(alpha: .6)),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.tonalIcon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) =>
                    AdvancedAnalyticsPage(store: widget.store),
              ),
            ),
            icon: const Icon(Icons.query_stats),
            label: const Text('Advanced Analytics'),
          ),
        ),
        const SizedBox(height: 24),
        WeeklyTrainingReportCard(report: widget.store.weeklyTrainingReport),
        const SizedBox(height: 12),
        TrainingLoadChart(logs: widget.store.data.logs),
        const SizedBox(height: 12),
        MuscleVolumeCard(volumes: widget.store.weeklyMuscleVolume),
        const SizedBox(height: 12),
        RecoveryTrendCard(checkIns: widget.store.data.recoveryChecks),
        const SizedBox(height: 12),
        WeightTrendChart(entries: widget.store.data.weights),
        const SizedBox(height: 20),
        PersonalRecordsSection(records: widget.store.exerciseRecords),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: context.l10n.text(
                        'Σημερινό βάρος',
                        'Today’s weight',
                      ),
                      suffixText: 'kg',
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _save(),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: _save,
                  icon: const Icon(Icons.add),
                  tooltip: context.l10n.text('Αποθήκευση', 'Save'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.text('Ιστορικό', 'History'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (widget.store.data.weights.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                context.l10n.text(
                  'Δεν υπάρχει ακόμη καταχώρηση βάρους.',
                  'No weight entries yet.',
                ),
              ),
            ),
          )
        else
          for (final entry in widget.store.data.weights)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                child: Icon(Icons.monitor_weight_outlined),
              ),
              title: Text('${entry.kilograms.toStringAsFixed(1)} kg'),
              subtitle: Text(_formatDate(entry.recordedAt)),
            ),
        const SizedBox(height: 24),
        TrainingHistorySection(logs: widget.store.data.logs),
      ],
    );
  }
}

class _DailyMissionCard extends StatelessWidget {
  const _DailyMissionCard({
    required this.store,
    required this.template,
    required this.active,
    required this.onStart,
  });

  final FitnessStore store;
  final WorkoutTemplate template;
  final bool active;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B120B), Color(0xFF15110F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0x66FF3D00)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.my_location, color: Color(0xFFFF6E40), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.text('ΣΗΜΕΡΙΝΗ ΑΠΟΣΤΟΛΗ', 'TODAY’S MISSION'),
                  style: const TextStyle(
                    color: Color(0xFFFF9E80),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .28),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${store.workoutsInCurrentWeek}/${store.weeklyWorkoutTarget} '
                  '${context.l10n.text('αυτή την εβδομάδα', 'this week')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            template.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            template.exercises.take(4).join('  •  '),
            style: TextStyle(
              color: Colors.white.withValues(alpha: .65),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.bolt, color: Color(0xFFFF6E40), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  template.prescription,
                  style: const TextStyle(
                    color: Color(0xFFFFAB91),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: store.weeklyWorkoutProgress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: .08),
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${context.l10n.text('Σειρά προγράμματος', 'Program rotation')}: '
            '${store.rotationSummary}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .45),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: active ? null : onStart,
              icon: Icon(active ? Icons.hourglass_top : Icons.play_arrow),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  active
                      ? context.l10n.text(
                          'ΥΠΑΡΧΕΙ ΕΝΕΡΓΗ ΠΡΟΠΟΝΗΣΗ',
                          'WORKOUT IN PROGRESS',
                        )
                      : context.l10n.text(
                          'ΞΕΚΙΝΑ ΤΗ ΣΗΜΕΡΙΝΗ',
                          'START TODAY’S SESSION',
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyExercisesCard extends StatelessWidget {
  const _DailyExercisesCard({required this.template});

  final WorkoutTemplate template;

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
                const Icon(
                  Icons.format_list_numbered,
                  color: Color(0xFFFF6E40),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.text(
                      'ΟΙ ΣΗΜΕΡΙΝΕΣ ΑΣΚΗΣΕΙΣ',
                      'TODAY’S EXERCISES',
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: .7,
                    ),
                  ),
                ),
                Text(
                  '${template.exercises.length}',
                  style: const TextStyle(
                    color: Color(0xFFFF9E80),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.text(
                'Πάτησε σε άσκηση για εικόνα και οδηγίες τεχνικής.',
                'Tap an exercise for a visual and technique guide.',
              ),
              style: TextStyle(
                color: Colors.white.withValues(alpha: .48),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < template.exercises.length; index++)
              _DailyExerciseRow(
                index: index + 1,
                exercise: template.exercises[index],
                prescription: template.prescriptionFor(
                  template.exercises[index],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DailyExerciseRow extends StatelessWidget {
  const _DailyExerciseRow({
    required this.index,
    required this.exercise,
    required this.prescription,
  });

  final int index;
  final String exercise;
  final ExercisePrescription prescription;

  @override
  Widget build(BuildContext context) {
    final guide = ExerciseGuideCatalog.forExercise(exercise);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: guide == null
          ? null
          : () => showExerciseGuide(context, exercise, guide),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFF3D00).withValues(alpha: .12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Color(0xFFFF6E40),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${prescription.summary}  •  Tempo ${prescription.tempo}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .48),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (guide != null)
              const Icon(
                Icons.photo_library_outlined,
                color: Color(0xFFFF9E80),
                size: 19,
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 18),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: .6)),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.template,
    required this.active,
    required this.onStart,
    required this.onEdit,
    required this.onFavorite,
    required this.onDuplicate,
    required this.onHistory,
    this.onDelete,
  });

  final WorkoutTemplate template;
  final bool active;
  final VoidCallback onStart;
  final VoidCallback onEdit;
  final VoidCallback onFavorite;
  final VoidCallback onDuplicate;
  final VoidCallback onHistory;
  final VoidCallback? onDelete;

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (template.isRecoveryDay)
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Text(
                            'REST-DAY SESSION',
                            style: TextStyle(
                              color: Color(0xFF81C784),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .8,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: template.isFavorite
                      ? 'Αφαίρεση από αγαπημένα'
                      : 'Προσθήκη στα αγαπημένα',
                  onPressed: onFavorite,
                  icon: Icon(
                    template.isFavorite ? Icons.star : Icons.star_border,
                    color: template.isFavorite ? const Color(0xFFFFB74D) : null,
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Ενέργειες προγράμματος',
                  onSelected: (action) {
                    switch (action) {
                      case 'duplicate':
                        onDuplicate();
                      case 'history':
                        onHistory();
                      case 'delete':
                        onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: ListTile(
                        leading: Icon(Icons.copy_all_outlined),
                        title: Text('Δημιουργία αντιγράφου'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'history',
                      child: ListTile(
                        leading: Icon(Icons.history),
                        title: Text('Ιστορικό εκδόσεων'),
                      ),
                    ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline),
                          title: Text('Διαγραφή'),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  tooltip: 'Επεξεργασία προγράμματος',
                  onPressed: active ? null : onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                FilledButton(
                  onPressed: active ? null : onStart,
                  child: Text(template.isRecoveryDay ? 'Άνοιγμα' : 'Έναρξη'),
                ),
              ],
            ),
            if (template.tags.isNotEmpty || template.blocks.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in template.tags)
                    _ProgramBadge(label: tag, icon: Icons.sell_outlined),
                  for (final block in template.blocks)
                    _ProgramBadge(
                      label: '${block.label} ${block.exercises.length}',
                      icon: block.isSuperset ? Icons.link : Icons.sync,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              template.exercises.join('  •  '),
              style: TextStyle(color: Colors.white.withValues(alpha: .65)),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.bolt, size: 18, color: Color(0xFFFF3D00)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    template.prescription,
                    style: const TextStyle(
                      color: Color(0xFFFF9E80),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              template.coachingCue,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .52),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramBadge extends StatelessWidget {
  const _ProgramBadge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x18FF6E40),
        border: Border.all(color: const Color(0x33FF6E40)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFFF9E80)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFFCCBC),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveWorkoutCard extends StatelessWidget {
  const _ActiveWorkoutCard({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ΕΝΕΡΓΗ ΠΡΟΠΟΝΗΣΗ',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Text(
              store.activeWorkout!.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () =>
                      _openWorkout(context, store, store.activeWorkout!),
                  icon: const Icon(Icons.bolt),
                  label: const Text('Συνέχεια'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: store.cancelWorkout,
                  child: const Text('Ακύρωση'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
