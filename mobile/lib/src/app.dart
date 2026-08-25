import 'dart:async';

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
import 'daily_companion_engine.dart';
import 'exercise_guide.dart';
import 'equipment_availability.dart';
import 'exercise_intelligence_page.dart';
import 'experience_settings_page.dart';
import 'fitness_charts.dart';
import 'form_check_page.dart';
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
import 'recommended_nutrition_page.dart';
import 'onboarding_page.dart';
import 'phoenix_copy.dart';
import 'phoenix_l10n.dart';
import 'phoenix_toolbox_page.dart';
import 'photo_meal_scan_page.dart';
import 'profile_editor_page.dart';
import 'program_architecture_page.dart';
import 'program_editor_page.dart';
import 'program_history_page.dart';
import 'private_health_page.dart';
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
          'today' => DashboardPage(store: store),
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
          'recommended-nutrition' => RecommendedNutritionPage(store: store),
          'meal-intelligence' => MealIntelligencePage(store: store),
          'body-composition' => BodyCompositionPage(store: store),
          'habit-builder' => HabitBuilderPage(store: store),
          'sleep-stress' => SleepStressPage(store: store),
          'analytics' => AdvancedAnalyticsPage(store: store),
          'analytics-studio' => AnalyticsStudioPage(store: store),
          'reports' => ReportsStudioPage(store: store),
          'settings' => ExperienceSettingsPage(store: store),
          'theme' => ExperienceSettingsPage(store: store, focusTheme: true),
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
  final palette = _phoenixPalette(preferences.themePreset);
  final themeSeed = palette.seed;
  final seed = switch (preferences.colorVisionMode) {
    'deuteranopia' => const Color(0xFF4D9DE0),
    'tritanopia' => const Color(0xFFE1559A),
    _ => themeSeed,
  };
  final highContrast = preferences.highContrast;
  final generated = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.dark,
  );
  final scheme = generated.copyWith(
    primary: seed,
    onPrimary: Colors.black,
    surface: highContrast ? Colors.black : palette.surface,
    surfaceContainerLowest: highContrast ? Colors.black : palette.background,
    surfaceContainerLow: highContrast
        ? const Color(0xFF050505)
        : palette.surfaceLow,
    surfaceContainer: highContrast ? const Color(0xFF080808) : palette.surface,
    surfaceContainerHigh: highContrast
        ? const Color(0xFF111111)
        : palette.surfaceHigh,
    onSurface: highContrast ? Colors.white : palette.onSurface,
    onSurfaceVariant: highContrast ? Colors.white : palette.onSurfaceVariant,
    secondaryContainer: highContrast ? Colors.black : palette.secondary,
    onSecondaryContainer: highContrast ? Colors.white : palette.onSurface,
    outline: highContrast ? Colors.white70 : palette.outline,
    outlineVariant: highContrast ? Colors.white38 : palette.outlineVariant,
  );
  final baseTextTheme = Typography.material2021().white;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    textTheme: baseTextTheme.copyWith(
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w800,
        letterSpacing: -.8,
        height: 1.08,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w800,
        letterSpacing: -.5,
        height: 1.12,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w800,
        letterSpacing: -.25,
        height: 1.18,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w800,
        letterSpacing: -.2,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: scheme.onSurface,
        height: 1.45,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: scheme.onSurface,
        height: 1.42,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: scheme.onSurfaceVariant,
        height: 1.35,
      ),
    ),
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
    scaffoldBackgroundColor: highContrast ? Colors.black : palette.background,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: highContrast ? Colors.black : palette.background,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: const TextStyle(
        color: Color(0xFFF3F6F5),
        fontSize: 20,
        fontWeight: FontWeight.w900,
        letterSpacing: -.2,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: highContrast
          ? const Color(0xFF050505)
          : palette.surface.withValues(alpha: .93),
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: highContrast ? Colors.white54 : scheme.outlineVariant,
          width: highContrast ? 1.4 : 1,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 0,
      backgroundColor: highContrast
          ? Colors.black
          : palette.surfaceLow.withValues(alpha: .95),
      indicatorColor: seed.withValues(alpha: highContrast ? .45 : .2),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? seed : scheme.onSurfaceVariant,
          size: selected ? 25 : 23,
        );
      }),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          color: highContrast ? Colors.white : null,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      elevation: 0,
      backgroundColor: highContrast ? Colors.black : palette.surfaceLow,
      indicatorColor: seed.withValues(alpha: highContrast ? .45 : .2),
      selectedIconTheme: IconThemeData(color: seed, size: 25),
      unselectedIconTheme: IconThemeData(
        color: scheme.onSurfaceVariant,
        size: 23,
      ),
      selectedLabelTextStyle: TextStyle(
        color: scheme.onSurface,
        fontWeight: FontWeight.w900,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: scheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: seed,
        foregroundColor: Colors.black,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: .15,
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(46, 46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      side: BorderSide(color: scheme.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: TextStyle(
        color: scheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: highContrast ? Colors.white38 : scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: highContrast ? Colors.black : palette.surfaceLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: highContrast ? Colors.white70 : scheme.outlineVariant,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: seed, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: highContrast ? Colors.black : palette.surfaceHigh,
      contentTextStyle: TextStyle(
        color: scheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: highContrast ? Colors.black : palette.surface,
      modalBackgroundColor: highContrast ? Colors.black : palette.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: highContrast ? Colors.black : palette.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}

class _PhoenixPalette {
  const _PhoenixPalette({
    required this.seed,
    required this.background,
    required this.surfaceLow,
    required this.surface,
    required this.surfaceHigh,
    required this.secondary,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
  });

  final Color seed;
  final Color background;
  final Color surfaceLow;
  final Color surface;
  final Color surfaceHigh;
  final Color secondary;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
}

_PhoenixPalette _phoenixPalette(String preset) => switch (preset) {
  'sage' => const _PhoenixPalette(
    seed: Color(0xFF9CB9A5),
    background: Color(0xFF0D1411),
    surfaceLow: Color(0xFF111A16),
    surface: Color(0xFF17221C),
    surfaceHigh: Color(0xFF213129),
    secondary: Color(0xFF293A31),
    onSurface: Color(0xFFF1F5F2),
    onSurfaceVariant: Color(0xFFB7C4BB),
    outline: Color(0xFF52665A),
    outlineVariant: Color(0xFF2B3B32),
  ),
  'sky' => const _PhoenixPalette(
    seed: Color(0xFF8DB7C8),
    background: Color(0xFF0B1216),
    surfaceLow: Color(0xFF10191E),
    surface: Color(0xFF162229),
    surfaceHigh: Color(0xFF20313A),
    secondary: Color(0xFF293B45),
    onSurface: Color(0xFFF0F5F7),
    onSurfaceVariant: Color(0xFFB4C4CA),
    outline: Color(0xFF506672),
    outlineVariant: Color(0xFF293A43),
  ),
  'sand' => const _PhoenixPalette(
    seed: Color(0xFFD2B08A),
    background: Color(0xFF15110D),
    surfaceLow: Color(0xFF1B1611),
    surface: Color(0xFF241C15),
    surfaceHigh: Color(0xFF30261D),
    secondary: Color(0xFF3A2D22),
    onSurface: Color(0xFFF7F2EB),
    onSurfaceVariant: Color(0xFFCBBEAF),
    outline: Color(0xFF705F4D),
    outlineVariant: Color(0xFF403329),
  ),
  'ocean' => _boldPalette(const Color(0xFF5CA9C9)),
  'forest' => _boldPalette(const Color(0xFF73A97A)),
  'violet' => _boldPalette(const Color(0xFFA995D2)),
  'rose' => _boldPalette(const Color(0xFFD98FAE)),
  'gold' => _boldPalette(const Color(0xFFC9A45C)),
  _ => const _PhoenixPalette(
    seed: Color(0xFFE4937F),
    background: Color(0xFF14100F),
    surfaceLow: Color(0xFF1A1513),
    surface: Color(0xFF221B19),
    surfaceHigh: Color(0xFF2E2522),
    secondary: Color(0xFF392C29),
    onSurface: Color(0xFFF7F2F0),
    onSurfaceVariant: Color(0xFFC8BBB7),
    outline: Color(0xFF6B5B56),
    outlineVariant: Color(0xFF3D302D),
  ),
};

_PhoenixPalette _boldPalette(Color seed) => _PhoenixPalette(
  seed: seed,
  background: const Color(0xFF090D0F),
  surfaceLow: const Color(0xFF101619),
  surface: const Color(0xFF171E22),
  surfaceHigh: const Color(0xFF20292E),
  secondary: const Color(0xFF263036),
  onSurface: const Color(0xFFF3F6F5),
  onSurfaceVariant: const Color(0xFFB4C0BE),
  outline: const Color(0xFF53615F),
  outlineVariant: const Color(0xFF293438),
);

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
          'Οι προπονήσεις έχουν τεθεί σε παύση. Άνοιξε την ενότητα αποκατάστασης.',
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

Future<void> _showGentleMovementPlan(
  BuildContext context,
  FitnessStore store,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _GentleMovementSheet(store: store),
);

class _GentleMovementSheet extends StatefulWidget {
  const _GentleMovementSheet({required this.store});

  final FitnessStore store;

  @override
  State<_GentleMovementSheet> createState() => _GentleMovementSheetState();
}

class _GentleMovementSheetState extends State<_GentleMovementSheet> {
  static const _totalSeconds = 600;
  Timer? _timer;
  int _remainingSeconds = _totalSeconds;

  bool get _running => _timer?.isActive ?? false;

  String get _timeLabel {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get _phaseLabel {
    final elapsed = _totalSeconds - _remainingSeconds;
    if (elapsed < 120) return 'Ήρεμο ξεκίνημα';
    if (elapsed < 480) return 'Άνετος, σταθερός ρυθμός';
    return 'Σταδιακή χαλάρωση';
  }

  void _toggleTimer() {
    if (_running) {
      _timer?.cancel();
      setState(() {});
      return;
    }
    if (_remainingSeconds == 0) _remainingSeconds = _totalSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
        await widget.store.feedback(success: true);
        return;
      }
      setState(() => _remainingSeconds--);
    });
    setState(() {});
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() => _remainingSeconds = _totalSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final hasTreadmill =
        widget.store.profile?.equipment.toLowerCase().contains('διάδρομ') ??
        false;
    final activity = hasTreadmill
        ? l.text('στον διάδρομο ή επιτόπου', 'on the treadmill or in place')
        : l.text('επιτόπου ή έξω', 'in place or outside');
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.text('Κίνηση για 10 λεπτά', '10 minutes of movement'),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              l.text(
                'Περπάτησε $activity. Δεν χρειάζεσαι συγκεκριμένη ταχύτητα ή εξοπλισμό.',
                'Walk $activity. No speed or equipment required.',
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Column(
                children: [
                  Text(
                    _timeLabel,
                    key: const ValueKey('gentle-movement-timer'),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _remainingSeconds == 0
                        ? l.text(
                            'Το έκανες. Αυτό μετράει.',
                            'You did it. It counts.',
                          )
                        : l.text(_phaseLabel, switch (_phaseLabel) {
                            'Ήρεμο ξεκίνημα' => 'Easy start',
                            'Άνετος, σταθερός ρυθμός' =>
                              'Comfortable steady pace',
                            _ => 'Ease down gradually',
                          }),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _GentleMovementStep(
              minutes: '2′',
              text: l.text('Ξεκίνα πολύ ήρεμα', 'Start very easy'),
            ),
            _GentleMovementStep(
              minutes: '6′',
              text: l.text('Κράτησε άνετο ρυθμό', 'Keep a comfortable pace'),
            ),
            _GentleMovementStep(
              minutes: '2′',
              text: l.text('Χαλάρωσε σταδιακά', 'Ease down gradually'),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    key: const ValueKey('gentle-movement-start'),
                    onPressed: _toggleTimer,
                    icon: Icon(
                      _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    ),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: Text(
                        _running
                            ? l.text('Παύση', 'Pause')
                            : l.text('Ξεκίνα τώρα', 'Start now'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  tooltip: l.text('Επαναφορά', 'Reset'),
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.replay_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GentleMovementStep extends StatelessWidget {
  const _GentleMovementStep({required this.minutes, required this.text});

  final String minutes;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 38,
          child: Text(
            minutes,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(child: Text(text)),
      ],
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
          _MorePage(store: widget.store),
        ];
        final labels = [
          context.l10n.text('Σήμερα', 'Today'),
          context.l10n.text('Κίνηση', 'Move'),
          context.l10n.text('Φαγητό', 'Food'),
          context.l10n.text('Εγώ', 'Me'),
        ];
        const icons = [
          Icons.today_outlined,
          Icons.fitness_center_outlined,
          Icons.restaurant_outlined,
          Icons.grid_view_rounded,
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
                  body: _PhoenixShellBackground(
                    highContrast: widget.store.preferences.highContrast,
                    child: SafeArea(
                      child: desktop
                          ? Row(
                              children: [
                                NavigationRail(
                                  leading: Padding(
                                    padding: const EdgeInsets.only(bottom: 18),
                                    child: _PhoenixMark(
                                      compact: constraints.maxWidth < 1200,
                                    ),
                                  ),
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
                  ),
                  bottomNavigationBar: desktop
                      ? null
                      : SafeArea(
                          minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .32),
                                  blurRadius: 26,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(23),
                              child: NavigationBar(
                                selectedIndex: _index,
                                onDestinationSelected: (value) =>
                                    setState(() => _index = value),
                                destinations: [
                                  for (
                                    var index = 0;
                                    index < labels.length;
                                    index++
                                  )
                                    NavigationDestination(
                                      icon: Icon(icons[index]),
                                      label: labels[index],
                                    ),
                                ],
                              ),
                            ),
                          ),
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

class _PhoenixShellBackground extends StatelessWidget {
  const _PhoenixShellBackground({
    required this.highContrast,
    required this.child,
  });

  final bool highContrast;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (highContrast) {
      return ColoredBox(color: Colors.black, child: child);
    }
    final theme = Theme.of(context);
    final base = theme.scaffoldBackgroundColor;
    final primaryGlow = Color.alphaBlend(
      theme.colorScheme.primary.withValues(alpha: .085),
      base,
    );
    final secondaryGlow = Color.alphaBlend(
      theme.colorScheme.secondary.withValues(alpha: .045),
      base,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryGlow, base, base, secondaryGlow],
          stops: const [0, .3, .72, 1],
        ),
      ),
      child: child,
    );
  }
}

class _PhoenixMark extends StatelessWidget {
  const _PhoenixMark({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: .24),
            colors.primary.withValues(alpha: .08),
          ],
        ),
        border: Border.all(color: colors.primary.withValues(alpha: .28)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: .1),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, color: colors.primary),
          if (!compact) ...[
            const SizedBox(width: 9),
            const Text(
              'PHOENIX',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l = context.l10n;
    final now = DateTime.now();
    final wide = MediaQuery.sizeOf(context).width >= 430;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: colors.primary.withValues(alpha: .2)),
              ),
              child: Icon(
                Icons.local_fire_department_rounded,
                color: colors.primary,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'PHOENIX',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  letterSpacing: 2.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (wide) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh.withValues(alpha: .72),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 13,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      context.l10n.text('ΜΟΝΟ ΣΤΗ ΣΥΣΚΕΥΗ', 'ON DEVICE'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
            Semantics(
              label: l.text('Αναζήτηση', 'Search'),
              button: true,
              child: ExcludeSemantics(
                child: IconButton.filledTonal(
                  tooltip: l.text('Αναζήτηση', 'Search'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => GlobalSearchPage(store: store),
                    ),
                  ),
                  icon: const Icon(Icons.search_rounded),
                ),
              ),
            ),
            const SizedBox(width: 7),
            Semantics(
              label: l.text(
                'Αλλαγή χρωμάτων και θέματος',
                'Change colors and theme',
              ),
              button: true,
              child: ExcludeSemantics(
                child: IconButton.filledTonal(
                  key: const ValueKey('quick-theme-settings'),
                  tooltip: l.text('Χρώματα & θέμα', 'Colors & theme'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => ExperienceSettingsPage(
                        store: store,
                        focusTheme: true,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.palette_outlined),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            l.text(
              'ΣΗΜΕΡΑ • ${now.day}/${now.month}',
              'TODAY • ${now.day}/${now.month}',
            ),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: .9,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l.text(
            'Τι θέλεις να κάνεις σήμερα;',
            'What do you want to do today?',
          ),
          style: theme.textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l.text(
            'Διάλεξε μόνο ένα πράγμα. Ακόμη και το μικρότερο βήμα μετράει.',
            'Choose just one thing. Even the smallest step counts.',
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MediaQuery.sizeOf(context).width >= 900
        ? 28.0
        : 20.0;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            20,
            horizontalPadding,
            28,
          ),
          children: [
            _DashboardHeader(store: store),
            const SizedBox(height: 20),
            _DailyCompanionCard(store: store),
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
            const SizedBox(height: 24),
            Text(
              context.l10n.text(
                'Πώς νιώθεις σήμερα;',
                'How do you feel today?',
              ),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.text(
                'Απάντησε ειλικρινά, για να προσαρμοστεί το πλάνο σου.',
                'Answer honestly so your plan can adapt.',
              ),
              style: TextStyle(color: Colors.white.withValues(alpha: .52)),
            ),
            const SizedBox(height: 12),
            RecoveryCheckInCard(store: store),
            const SizedBox(height: 20),
            _DailyExercisesCard(
              template: store.hasTodayCompanionCheckIn
                  ? store.dailyCompanionPlan.workout
                  : store.recommendedWorkout,
              profile: store.profile,
            ),
            const SizedBox(height: 20),
            _GentleProgressCard(store: store),
          ],
        ),
      ),
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
            l.text('Προστέθηκαν 250 ml νερού.', '250 ml of water added.'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.text('Ένα μικρό βήμα αρκεί', 'One small step is enough'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              l.text(
                'Δεν χρειάζεται να τα κάνεις όλα σήμερα.',
                'You do not need to do everything today.',
              ),
              style: TextStyle(color: Colors.white.withValues(alpha: .5)),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 620 ? 2 : 2;
                final width =
                    (constraints.maxWidth - (columns - 1) * 10) / columns;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _QuickAction(
                      width: width,
                      icon: Icons.photo_camera_outlined,
                      label: l.text(
                        'Φωτογράφισε το γεύμα',
                        'Photograph a meal',
                      ),
                      color: const Color(0xFF7EA9D4),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PhotoMealScanPage(store: store),
                        ),
                      ),
                    ),
                    _QuickAction(
                      width: width,
                      icon: Icons.water_drop_outlined,
                      label: l.text('Κατάγραψε νερό', 'Log water'),
                      color: const Color(0xFF65B9D8),
                      onTap: addWater,
                    ),
                  ],
                );
              },
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
    final l = context.l10n;
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
          l.text(
            'ΥΠΕΝΘΥΜΙΣΗ ΠΡΟΠΟΝΗΣΗΣ • ${reminder.timeLabel}',
            'WORKOUT REMINDER • ${reminder.timeLabel}',
          ),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(PhoenixCopy.workoutName(l, template)),
        trailing: FilledButton(
          onPressed: () => _openWorkout(context, store, template),
          child: Text(l.text('ΕΝΑΡΞΗ', 'START')),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.width,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 98,
      child: Material(
        color: color.withValues(alpha: .075),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: color.withValues(alpha: .24)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 25, color: color),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoenixBriefCard extends StatelessWidget {
  const _PhoenixBriefCard({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final now = DateTime.now();
    final next = store.weeklySchedule.nextEntry(now);
    final nextName = next == null
        ? ''
        : PhoenixCopy.workoutName(l, next.template, short: true);
    final recovery = store.todaysRecoveryPlan;
    final nutrition = store.nutritionCoach;
    final trainingText = next == null
        ? l.text(
            'Ο εβδομαδιαίος στόχος ολοκληρώθηκε.',
            'The weekly training target is complete.',
          )
        : next.isOverdue(now)
        ? l.text(
            'Το πρόγραμμα «$nextName» εκκρεμεί.',
            '$nextName is still pending.',
          )
        : next.isToday(now)
        ? l.text(
            'Σήμερα μπορείς να κάνεις το πρόγραμμα «$nextName».',
            '$nextName is today’s next step.',
          )
        : l.text(
            'Η επόμενη προπόνηση είναι στις ${next.date.day}/${next.date.month}.',
            'Next workout: ${next.date.day}/${next.date.month}.',
          );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFFF6E40),
                  size: 20,
                ),
                const SizedBox(width: 9),
                Text(
                  l.text('ΣΥΝΟΨΗ PHOENIX', 'PHOENIX BRIEF'),
                  style: const TextStyle(
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
                      'Έλεγξε πώς νιώθεις πριν από μια απαιτητική προπόνηση.',
                      'Check how you feel before a demanding workout.',
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
          'Το “${PhoenixCopy.workoutName(context.l10n, template)}” και το ιστορικό του θα αφαιρεθούν από τη '
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
            label: context.l10n.text('ΑΝΑΙΡΕΣΗ', 'UNDO'),
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
        _WeeklyScheduleCard(store: store),
        const SizedBox(height: 12),
        Card(
          child: ExpansionTile(
            key: const ValueKey('advanced-training-tools'),
            leading: const Icon(Icons.tune_rounded),
            title: Text(
              context.l10n.text('Ειδικά εργαλεία', 'Special tools'),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              context.l10n.text(
                'Για όταν θέλεις περισσότερη λεπτομέρεια',
                'For when you want more detail',
              ),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              ProgramArchitecturePage(store: store),
                        ),
                      ),
                      icon: const Icon(Icons.architecture_outlined),
                      label: Text(
                        context.l10n.text(
                          'Σχεδιασμός προγράμματος',
                          'Program architecture',
                        ),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => StrengthLabPage(store: store),
                        ),
                      ),
                      icon: const Icon(Icons.speed),
                      label: Text(context.l10n.text('Δύναμη', 'Strength lab')),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              HypertrophyLabPage(store: store),
                        ),
                      ),
                      icon: const Icon(Icons.equalizer),
                      label: Text(
                        context.l10n.text('Μυϊκή ανάπτυξη', 'Hypertrophy lab'),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              ConditioningLabPage(store: store),
                        ),
                      ),
                      icon: const Icon(Icons.favorite_outline),
                      label: Text(
                        context.l10n.text(
                          'Φυσική κατάσταση',
                          'Conditioning lab',
                        ),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => RunningLabPage(store: store),
                        ),
                      ),
                      icon: const Icon(Icons.directions_run),
                      label: Text(context.l10n.text('Τρέξιμο', 'Running lab')),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              CyclingRowingLabPage(store: store),
                        ),
                      ),
                      icon: const Icon(Icons.pedal_bike),
                      label: Text(
                        context.l10n.text(
                          'Ποδήλατο και κωπηλατική',
                          'Cycling and rowing lab',
                        ),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              ExerciseIntelligencePage(store: store),
                        ),
                      ),
                      icon: const Icon(Icons.hub_outlined),
                      label: Text(
                        context.l10n.text(
                          'Ανάλυση ασκήσεων',
                          'Exercise intelligence',
                        ),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => MobilityPage(store: store),
                        ),
                      ),
                      icon: const Icon(Icons.self_improvement),
                      label: Text(
                        context.l10n.text('Κινητικότητα', 'Mobility lab'),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              MobilityIntelligencePage(store: store),
                        ),
                      ),
                      icon: const Icon(Icons.accessibility_new),
                      label: Text(
                        context.l10n.text(
                          'Ανάλυση κινητικότητας',
                          'Mobility intelligence',
                        ),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => WeeklyPlannerPage(store: store),
                        ),
                      ),
                      icon: const Icon(Icons.edit_calendar_outlined),
                      label: Text(
                        context.l10n.text(
                          'Εβδομαδιαίος προγραμματισμός',
                          'Weekly planner',
                        ),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              CalisthenicsLabPage(store: store),
                        ),
                      ),
                      icon: const Icon(Icons.sports_gymnastics),
                      label: Text(
                        context.l10n.text(
                          'Ασκήσεις με το βάρος του σώματος',
                          'Bodyweight training lab',
                        ),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              AdvancedCalisthenicsPage(store: store),
                        ),
                      ),
                      icon: const Icon(Icons.sports_martial_arts),
                      label: Text(
                        context.l10n.text(
                          'Προχωρημένες ασκήσεις σώματος',
                          'Advanced bodyweight training',
                        ),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              MediaPortabilityPage(store: store),
                        ),
                      ),
                      icon: const Icon(Icons.ios_share),
                      label: Text(
                        context.l10n.text(
                          'Μουσική και αρχεία',
                          'Music and files',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
              label: Text(
                context.l10n.text(
                  'Πρόγραμμα ημέρας ξεκούρασης',
                  'Rest-day program',
                ),
              ),
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

  static const _fromDayNames = [
    'ΑΠΟ ΤΗ ΔΕΥΤΕΡΑ',
    'ΑΠΟ ΤΗΝ ΤΡΙΤΗ',
    'ΑΠΟ ΤΗΝ ΤΕΤΑΡΤΗ',
    'ΑΠΟ ΤΗΝ ΠΕΜΠΤΗ',
    'ΑΠΟ ΤΗΝ ΠΑΡΑΣΚΕΥΗ',
    'ΑΠΟ ΤΟ ΣΑΒΒΑΤΟ',
    'ΑΠΟ ΤΗΝ ΚΥΡΙΑΚΗ',
  ];

  String _shortDate(DateTime date) => '${date.day}/${date.month}';

  String _weekRange(TrainingSchedule schedule) =>
      '${_shortDate(schedule.weekStart)} — ${_shortDate(schedule.weekEnd)}';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final schedule = store.weeklySchedule;
    final entriesByWeekday = {
      for (final entry in schedule.entries) entry.date.weekday: entry,
    };
    final next = schedule.nextEntry(now);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.surfaceContainerHigh, colors.surfaceContainerLow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: colors.primary),
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
                style: TextStyle(
                  color: colors.primary,
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
              color: colors.primary,
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
                  ? 'ΕΚΚΡΕΜΕΙ ${_fromDayNames[next.date.weekday - 1]}'
                  : next.isToday(now)
                  ? 'ΣΗΜΕΡΙΝΗ ΠΡΟΠΟΝΗΣΗ'
                  : 'ΕΠΟΜΕΝΗ ΠΡΟΠΟΝΗΣΗ • ${_dayNames[next.date.weekday - 1].toUpperCase()}',
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
              PhoenixCopy.workoutName(context.l10n, next.template),
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
                  PhoenixCopy.workoutName(
                    context.l10n,
                    entry.template,
                    short: true,
                  ),
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
              tooltip: context.l10n.text(
                'Έναρξη ${PhoenixCopy.workoutName(context.l10n, entry.template)}',
                'Start ${PhoenixCopy.workoutName(context.l10n, entry.template)}',
              ),
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
              'Ολοκλήρωσες το εβδομαδιαίο πλάνο. Ξεκουράσου και συνέχισε με δύναμη.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _MorePage extends StatelessWidget {
  const _MorePage({required this.store});

  final FitnessStore store;

  void _open(BuildContext context, Widget page) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    final latestWeight = store.data.weights.isEmpty
        ? null
        : store.data.weights.first.kilograms;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Text(
              context.l10n.text('Εγώ', 'Me'),
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.text(
                'Όλα είναι εδώ όταν τα χρειαστείς. Δεν χρειάζεται να τα χρησιμοποιήσεις όλα.',
                'Everything is here when you need it. You do not have to use it all.',
              ),
              style: TextStyle(
                color: Colors.white.withValues(alpha: .58),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _MoreDestination(
                    icon: Icons.show_chart_rounded,
                    title: context.l10n.text('Η πρόοδός μου', 'My progress'),
                    subtitle: context.l10n.text(
                      'Προπονήσεις, βάρος και προσωπικά ρεκόρ',
                      'Workouts, weight and personal records',
                    ),
                    onTap: () => _open(context, ProgressPage(store: store)),
                  ),
                  const Divider(height: 1),
                  _MoreDestination(
                    icon: Icons.psychology_alt_outlined,
                    title: context.l10n.text(
                      'Βοήθεια & καθοδήγηση',
                      'Help & guidance',
                    ),
                    subtitle: context.l10n.text(
                      'Ο coach και οι προτάσεις του Phoenix',
                      'Your coach and Phoenix suggestions',
                    ),
                    onTap: () => _open(context, CoachHubPage(store: store)),
                  ),
                  const Divider(height: 1),
                  _MoreDestination(
                    icon: Icons.accessibility_new_rounded,
                    title: context.l10n.text(
                      'Τοπικός έλεγχος στάσης',
                      'Local form check',
                    ),
                    subtitle: context.l10n.text(
                      'Σύγκρινε μια φωτογραφία με τις οδηγίες — χωρίς αποθήκευση ή αποστολή',
                      'Compare a photo with guidance — no saving or upload',
                    ),
                    onTap: () => _open(context, FormCheckPage(store: store)),
                  ),
                  const Divider(height: 1),
                  _MoreDestination(
                    icon: Icons.watch_outlined,
                    title: context.l10n.text(
                      'Βήματα & Apple Health',
                      'Steps & Apple Health',
                    ),
                    subtitle: context.l10n.text(
                      'Προαιρετικά δεδομένα κίνησης που μένουν στη συσκευή',
                      'Optional movement data that stays on the device',
                    ),
                    onTap: () =>
                        _open(context, PrivateHealthPage(store: store)),
                  ),
                  const Divider(height: 1),
                  _MoreDestination(
                    icon: Icons.phonelink_outlined,
                    title: context.l10n.text(
                      'Μεταφορά σε άλλη συσκευή',
                      'Move to another device',
                    ),
                    subtitle: context.l10n.text(
                      'Κρυπτογραφημένο αρχείο — χωρίς λογαριασμό ή cloud',
                      'Encrypted file — no account or cloud required',
                    ),
                    onTap: () => _open(
                      context,
                      MediaPortabilityPage(store: store, initialTab: 3),
                    ),
                  ),
                  const Divider(height: 1),
                  _MoreDestination(
                    icon: Icons.headphones_outlined,
                    title: context.l10n.text(
                      'Μουσική & φωτογραφίες',
                      'Music & photos',
                    ),
                    subtitle: context.l10n.text(
                      'Spotify, Apple Music και τοπικά αρχεία',
                      'Spotify, Apple Music and local files',
                    ),
                    onTap: () =>
                        _open(context, MediaPortabilityPage(store: store)),
                  ),
                  const Divider(height: 1),
                  _MoreDestination(
                    icon: Icons.palette_outlined,
                    title: context.l10n.text(
                      'Χρώματα & εμφάνιση',
                      'Colors & appearance',
                    ),
                    subtitle: context.l10n.text(
                      'Διάλεξε το θέμα που σου ταιριάζει',
                      'Choose the theme that feels right',
                    ),
                    onTap: () => _open(
                      context,
                      ExperienceSettingsPage(store: store, focusTheme: true),
                    ),
                  ),
                  const Divider(height: 1),
                  _MoreDestination(
                    icon: Icons.grid_view_rounded,
                    title: context.l10n.text(
                      'Studio για προχωρημένους',
                      'Advanced Studio',
                    ),
                    subtitle: context.l10n.text(
                      'Όλα τα ειδικά εργαλεία, όταν τα χρειαστείς',
                      'All specialist tools, when you need them',
                    ),
                    onTap: () =>
                        _open(context, PhoenixToolboxPage(store: store)),
                  ),
                  const Divider(height: 1),
                  _MoreDestination(
                    icon: Icons.manage_accounts_outlined,
                    title: context.l10n.text(
                      'Προφίλ, δεδομένα & ρυθμίσεις',
                      'Profile, data & settings',
                    ),
                    subtitle: context.l10n.text(
                      'Όλα παραμένουν τοπικά στη συσκευή',
                      'Everything stays locally on your device',
                    ),
                    onTap: () =>
                        _open(context, ControlCenterPage(store: store)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.text(
                'Οι αριθμοί σου, όταν τους θέλεις',
                'Your numbers, when you want them',
              ),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    value: '${store.workoutsThisWeek}',
                    label: context.l10n.text(
                      'Προπονήσεις\n7 ημερών',
                      'Workouts\n7 days',
                    ),
                    icon: Icons.local_fire_department,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    value: latestWeight == null
                        ? '—'
                        : '${latestWeight.toStringAsFixed(1)} kg',
                    label: context.l10n.text(
                      'Τελευταίο\nβάρος',
                      'Latest\nweight',
                    ),
                    icon: Icons.monitor_weight_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
              leading: const Icon(Icons.insights_outlined),
              title: Text(
                context.l10n.text(
                  'Προχωρημένες πληροφορίες',
                  'Advanced insights',
                ),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                context.l10n.text(
                  'Άνοιξέ τες μόνο αν σε βοηθούν',
                  'Open them only if they help you',
                ),
              ),
              children: [
                _PhoenixBriefCard(store: store),
                const SizedBox(height: 12),
                PeriodizationCard(store: store),
              ],
            ),
            const SizedBox(height: 12),
            SpotifyCard(store: store),
          ],
        ),
      ),
    );
  }
}

class _MoreDestination extends StatelessWidget {
  const _MoreDestination({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return ListTile(
      minTileHeight: 76,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _GentleProgressCard extends StatelessWidget {
  const _GentleProgressCard({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final completed = store.workoutsInCurrentWeek;
    final target = store.weeklyWorkoutTarget;
    final message = completed == 0
        ? context.l10n.text(
            'Το ξεκίνημα μετράει περισσότερο από την τελειότητα.',
            'Starting matters more than being perfect.',
          )
        : completed >= target
        ? context.l10n.text(
            'Τα κατάφερες αυτή την εβδομάδα. Μπράβο σου.',
            'You made it this week. Well done.',
          )
        : context.l10n.text(
            'Έχεις ήδη κάνει κάτι καλό για τον εαυτό σου.',
            'You have already done something good for yourself.',
          );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            SizedBox(
              width: 66,
              height: 66,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: store.weeklyWorkoutProgress,
                    strokeWidth: 7,
                    backgroundColor: colors.primary.withValues(alpha: .1),
                  ),
                  Text(
                    '$completed/$target',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.text('Η εβδομάδα σου', 'Your week'),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .58),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProgressPage(store: store),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text(
                      context.l10n.text(
                        'Δες την πρόοδό σου',
                        'See my progress',
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => WeeklyPlannerPage(store: store),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text(
                      context.l10n.text(
                        'Άλλαξε τις ημέρες σου',
                        'Change my workout days',
                      ),
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
            label: Text(
              context.l10n.text('Αναλυτικά στοιχεία', 'Advanced analytics'),
            ),
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

class _DailyCompanionCard extends StatelessWidget {
  const _DailyCompanionCard({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l = context.l10n;
    if (!store.hasTodayCompanionCheckIn) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: colors.primary.withValues(alpha: .28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                l.text('30 ΔΕΥΤΕΡΟΛΕΠΤΑ', '30 SECONDS'),
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l.text('Πώς είναι η μέρα σου;', 'How is your day?'),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 7),
            Text(
              l.text(
                'Πες μόνο πόσο χρόνο και ενέργεια έχεις. Το Phoenix θα διαλέξει ένα ασφαλές επόμενο βήμα.',
                'Share only your available time and energy. Phoenix will choose one safe next step.',
              ),
              style: TextStyle(color: colors.onSurfaceVariant, height: 1.45),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              key: const ValueKey('daily-check-in-action'),
              onPressed: () => _showDailyCompanionCheckIn(context, store),
              icon: const Icon(Icons.waving_hand_outlined),
              label: Text(l.text('Πες μου πώς είσαι', 'Tell me how you are')),
            ),
          ],
        ),
      );
    }

    final checkIn = store.dailyCompanionCheckIn!;
    final plan = store.dailyCompanionPlan;
    final path = DailyCompanionEngine.pathFor(store.preferences.starterPath);
    final overdue = store.weeklySchedule.entries
        .where((entry) => entry.isOverdue(DateTime.now()))
        .length;
    final accent = switch (plan.kind) {
      DailyCompanionKind.recovery => const Color(0xFF9DA7C8),
      DailyCompanionKind.walk => const Color(0xFF79B9A1),
      DailyCompanionKind.shortWorkout => const Color(0xFFE0AD73),
      DailyCompanionKind.fullWorkout => colors.primary,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.alphaBlend(
              accent.withValues(alpha: .13),
              colors.surfaceContainer,
            ),
            colors.surfaceContainerLow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: accent.withValues(alpha: .35)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .08),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(_dailyPlanIcon(plan.kind), color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.text('ΕΝΑ ΒΗΜΑ ΓΙΑ ΣΗΜΕΡΑ', 'ONE STEP FOR TODAY'),
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .7,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l.text(plan.titleGreek, plan.titleEnglish),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            l.text(plan.reasonGreek, plan.reasonEnglish),
            style: TextStyle(color: colors.onSurfaceVariant, height: 1.45),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DailyFact(
                icon: Icons.schedule_outlined,
                label: l.text(
                  '${checkIn.minutes} λεπτά',
                  '${checkIn.minutes} min',
                ),
              ),
              _DailyFact(
                icon: Icons.battery_4_bar_outlined,
                label: l.text(
                  'Ενέργεια ${checkIn.energy}/5',
                  'Energy ${checkIn.energy}/5',
                ),
              ),
              _DailyFact(
                icon: Icons.route_outlined,
                label: l.text(path.titleGreek, path.titleEnglish),
              ),
              if (store.preferences.healthConnectionEnabled &&
                  store.todayWearableSummary != null)
                _DailyFact(
                  icon: Icons.directions_walk_outlined,
                  label: l.text(
                    '${store.todayWearableSummary!.steps} βήματα στη συσκευή',
                    '${store.todayWearableSummary!.steps} on-device steps',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              l.text(plan.encouragementGreek, plan.encouragementEnglish),
              style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const ValueKey('daily-plan-start-action'),
              onPressed: () => _openWorkout(context, store, plan.workout),
              icon: Icon(
                store.hasActiveWorkout
                    ? Icons.play_arrow_rounded
                    : Icons.arrow_forward_rounded,
              ),
              label: Text(
                store.hasActiveWorkout
                    ? l.text(
                        'Συνέχισε από εκεί που έμεινες',
                        'Continue where you left off',
                      )
                    : l.text('Κάνε αυτό το ένα βήμα', 'Take this one step'),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  key: const ValueKey('change-daily-check-in'),
                  onPressed: () => _showDailyCompanionCheckIn(context, store),
                  icon: const Icon(Icons.tune_outlined),
                  label: Text(l.text('Άλλαξε απαντήσεις', 'Change answers')),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  key: const ValueKey('starter-path-action'),
                  onPressed: () => _showStarterPathPicker(context, store),
                  icon: const Icon(Icons.route_outlined),
                  label: Text(l.text('Άλλαξε διαδρομή', 'Change path')),
                ),
              ),
            ],
          ),
          if (overdue > 0) ...[
            const Divider(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_repeat_outlined),
              title: Text(
                l.text(
                  'Χάθηκε μια μέρα; Δεν χάθηκε το πλάνο.',
                  'Missed a day? The plan is not lost.',
                ),
              ),
              subtitle: Text(
                l.text(
                  'Μετέφερε αυτόματα ${overdue == 1 ? 'την προπόνηση' : 'τις προπονήσεις'} στις επόμενες ελεύθερες ημέρες.',
                  'Move missed workouts to the next available days.',
                ),
              ),
              trailing: FilledButton.tonal(
                key: const ValueKey('auto-reschedule-action'),
                onPressed: () async {
                  final moved = await store.autoRescheduleMissedWorkouts();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l.text(
                          'Το πλάνο ηρέμησε: μεταφέρθηκαν $moved προπονήσεις.',
                          'Plan adjusted: $moved workouts moved.',
                        ),
                      ),
                    ),
                  );
                },
                child: Text(l.text('Διόρθωσέ το', 'Fix it')),
              ),
            ),
          ],
          const Divider(height: 24),
          Row(
            children: [
              Icon(Icons.restart_alt_rounded, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.text(
                    '${store.returnMoments} ξεκινήματα ή επιστροφές • κάθε επιστροφή μετράει',
                    '${store.returnMoments} starts or returns • every return counts',
                  ),
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyFact extends StatelessWidget {
  const _DailyFact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ),
  );
}

IconData _dailyPlanIcon(DailyCompanionKind kind) => switch (kind) {
  DailyCompanionKind.recovery => Icons.self_improvement_outlined,
  DailyCompanionKind.walk => Icons.directions_walk_rounded,
  DailyCompanionKind.shortWorkout => Icons.bolt_outlined,
  DailyCompanionKind.fullWorkout => Icons.fitness_center_rounded,
};

class _DailyCompanionInput {
  const _DailyCompanionInput({
    required this.minutes,
    required this.energy,
    required this.location,
    required this.painArea,
  });

  final int minutes;
  final int energy;
  final String location;
  final String painArea;
}

Future<void> _showDailyCompanionCheckIn(
  BuildContext context,
  FitnessStore store,
) async {
  final current = store.dailyCompanionCheckIn;
  var minutes = current?.minutes ?? 10;
  var energy = current?.energy ?? 3;
  var location =
      current?.location ??
      (EquipmentAvailability.isHome(store.profile) ? 'home' : 'gym');
  var painArea = current?.painArea ?? '';
  final input = await showModalBottomSheet<_DailyCompanionInput>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setState) {
        final l = context.l10n;
        String locationLabel(String value) => switch (value) {
          'gym' => l.text('Γυμναστήριο', 'Gym'),
          'outside' => l.text('Έξω', 'Outside'),
          _ => l.text('Σπίτι', 'Home'),
        };
        String painLabel(String value) => switch (value) {
          'shoulder' => l.text('Ώμος', 'Shoulder'),
          'back' => l.text('Μέση/πλάτη', 'Back'),
          'knee' => l.text('Γόνατο', 'Knee'),
          'other' => l.text('Κάπου αλλού', 'Somewhere else'),
          _ => l.text('Δεν πονάω', 'No pain'),
        };
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              24 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.text('Πώς είναι η μέρα σου;', 'How is your day?'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l.text(
                    'Δεν υπάρχει σωστή απάντηση. Το πλάνο μικραίνει όταν το χρειάζεσαι.',
                    'There is no right answer. The plan gets smaller when you need it.',
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  l.text('Πόσο χρόνο έχεις;', 'How much time do you have?'),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final value in const [5, 10, 20, 40])
                      ChoiceChip(
                        key: ValueKey('daily-minutes-$value'),
                        label: Text('$value′'),
                        selected: minutes == value,
                        onSelected: (_) => setState(() => minutes = value),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  l.text(
                    'Πόση ενέργεια έχεις;',
                    'How much energy do you have?',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final value in const [1, 2, 3, 4, 5])
                      ChoiceChip(
                        key: ValueKey('daily-energy-$value'),
                        label: Text('$value'),
                        selected: energy == value,
                        onSelected: (_) => setState(() => energy = value),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  l.text('Πού θα κινηθείς;', 'Where will you move?'),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final value in const ['home', 'gym', 'outside'])
                      ChoiceChip(
                        key: ValueKey('daily-location-$value'),
                        label: Text(locationLabel(value)),
                        selected: location == value,
                        onSelected: (_) => setState(() => location = value),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  l.text('Υπάρχει ενόχληση σήμερα;', 'Any discomfort today?'),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final value in const [
                      '',
                      'shoulder',
                      'back',
                      'knee',
                      'other',
                    ])
                      ChoiceChip(
                        key: ValueKey(
                          'daily-pain-${value.isEmpty ? 'none' : value}',
                        ),
                        label: Text(painLabel(value)),
                        selected: painArea == value,
                        onSelected: (_) => setState(() => painArea = value),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const ValueKey('save-daily-check-in'),
                    onPressed: () => Navigator.of(sheetContext).pop(
                      _DailyCompanionInput(
                        minutes: minutes,
                        energy: energy,
                        location: location,
                        painArea: painArea,
                      ),
                    ),
                    child: Text(
                      l.text('Βρες το ένα βήμα μου', 'Find my one step'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
  if (input == null) return;
  await store.saveDailyCompanionCheckIn(
    minutes: input.minutes,
    energy: input.energy,
    location: input.location,
    painArea: input.painArea,
  );
}

Future<void> _showStarterPathPicker(
  BuildContext context,
  FitnessStore store,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(
            context.l10n.text('Διάλεξε τη διαδρομή σου', 'Choose your path'),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.text(
              'Μπορείς να την αλλάξεις οποιαδήποτε στιγμή.',
              'You can change it at any time.',
            ),
          ),
          const SizedBox(height: 14),
          for (final path in DailyCompanionEngine.paths)
            Card(
              child: ListTile(
                leading: Icon(
                  store.preferences.starterPath == path.id
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                ),
                title: Text(
                  context.l10n.text(path.titleGreek, path.titleEnglish),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  context.l10n.text(path.subtitleGreek, path.subtitleEnglish),
                ),
                onTap: () async {
                  await store.selectStarterPath(path.id);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
            ),
        ],
      ),
    ),
  );
}

// Kept as an internal fallback while older deep links finish migrating.
// ignore: unused_element
class _TodayChoicePanel extends StatelessWidget {
  const _TodayChoicePanel({
    required this.store,
    required this.template,
    required this.active,
  });

  final FitnessStore store;
  final WorkoutTemplate template;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final missionSurface = Color.alphaBlend(
      colors.primary.withValues(alpha: .055),
      colors.surfaceContainer,
    );
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [missionSurface, colors.surfaceContainerLow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: .045),
            blurRadius: 34,
            spreadRadius: -12,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: .3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text(
              'Τι ταιριάζει στη μέρα σου;',
              'What fits your day?',
            ),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.text(
              'Διάλεξε αυτό που μπορείς να κάνεις σήμερα. Δεν υπάρχει λάθος επιλογή.',
              'Choose what you can do today. There is no wrong choice.',
            ),
            style: TextStyle(
              color: Colors.white.withValues(alpha: .65),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          _TodayChoice(
            actionKey: const ValueKey('gentle-movement-action'),
            icon: Icons.timer_outlined,
            title: context.l10n.text(
              'Έχω μόνο 10 λεπτά',
              'I only have 10 minutes',
            ),
            subtitle: context.l10n.text(
              'Ήπια κίνηση με χρονόμετρο και χωρίς εξοπλισμό',
              'Gentle timed movement with no equipment',
            ),
            color: const Color(0xFF8FC5A8),
            onTap: () => _showGentleMovementPlan(context, store),
          ),
          const SizedBox(height: 10),
          _TodayChoice(
            actionKey: const ValueKey('recommended-workout-action'),
            icon: active ? Icons.play_arrow_rounded : Icons.fitness_center,
            title: active
                ? context.l10n.text(
                    'Συνέχισε την προπόνησή σου',
                    'Continue your workout',
                  )
                : context.l10n.text(
                    'Θέλω κανονική προπόνηση',
                    'I want a full workout',
                  ),
            subtitle: context.l10n.text(
              '${PhoenixCopy.workoutName(context.l10n, template, short: true)} • ${PhoenixCopy.exerciseCount(context.l10n, template.exercises.length)} • περίπου ${PhoenixCopy.minuteCount(context.l10n, store.profile?.sessionMinutes ?? 45)}',
              '${template.name} • ${template.exercises.length} exercises • about ${store.profile?.sessionMinutes ?? 45} minutes',
            ),
            color: colors.primary,
            emphasized: true,
            onTap: () => _openWorkout(context, store, template),
          ),
          const SizedBox(height: 10),
          _TodayChoice(
            actionKey: const ValueKey('recovery-workout-action'),
            icon: Icons.self_improvement_outlined,
            title: context.l10n.text(
              'Σήμερα χρειάζομαι κάτι ήπιο',
              'I need something gentle today',
            ),
            subtitle: context.l10n.text(
              'Αναπνοές και απλές κινήσεις αποκατάστασης',
              'Breathing and simple recovery movements',
            ),
            color: const Color(0xFF9DA7C8),
            onTap: () =>
                _openWorkout(context, store, store.createRestDayDraft()),
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
            context.l10n.text(
              PhoenixCopy.weeklyWorkoutProgress(
                context.l10n,
                completed: store.workoutsInCurrentWeek,
                target: store.weeklyWorkoutTarget,
              ),
              '${store.workoutsInCurrentWeek} of ${store.weeklyWorkoutTarget} workouts this week',
            ),
            style: TextStyle(
              color: Colors.white.withValues(alpha: .55),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayChoice extends StatelessWidget {
  const _TodayChoice({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.actionKey,
    this.emphasized = false,
  });

  final Key? actionKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Material(
    color: color.withValues(alpha: emphasized ? .15 : .075),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(color: color.withValues(alpha: emphasized ? .5 : .24)),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: actionKey,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 27),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    ),
  );
}

class _DailyExercisesCard extends StatelessWidget {
  const _DailyExercisesCard({required this.template, required this.profile});

  final WorkoutTemplate template;
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.format_list_numbered, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    template.exercises.length == 1
                        ? context.l10n.text(
                            'Η σημερινή άσκηση',
                            'Today’s exercise',
                          )
                        : context.l10n.text(
                            'Οι σημερινές ασκήσεις',
                            'Today’s exercises',
                          ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
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
                'Πάτησε μια άσκηση, αν θέλεις να δεις οδηγίες εκτέλεσης.',
                'Tap an exercise to see instructions.',
              ),
              style: TextStyle(
                color: Colors.white.withValues(alpha: .48),
                fontSize: 12,
              ),
            ),
            if (profile != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(Icons.verified_outlined, size: 17),
                  label: Text(
                    context.l10n.text(
                      'Ταιριάζει στον εξοπλισμό σου',
                      'Matches your equipment',
                    ),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
            const SizedBox(height: 12),
            for (var index = 0; index < template.exercises.length; index++)
              _DailyExerciseRow(
                index: index + 1,
                exercise: template.exercises[index],
                atHome: EquipmentAvailability.isHome(profile),
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
    required this.atHome,
    required this.prescription,
  });

  final int index;
  final String exercise;
  final bool atHome;
  final ExercisePrescription prescription;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final guide = ExerciseGuideCatalog.forExercise(exercise, atHome: atHome);
    return InkWell(
      key: ValueKey('daily-exercise-row-$exercise'),
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
                color: colors.primary.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                '$index',
                style: TextStyle(
                  color: colors.primary,
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
                    PhoenixCopy.exerciseName(context.l10n, exercise),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    PhoenixCopy.compactExerciseTarget(
                      context.l10n,
                      prescription,
                    ),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .48),
                      fontSize: 12,
                    ),
                  ),
                  if (guide != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.text(
                        'Δες την εκτέλεση',
                        'See how to perform it',
                      ),
                      style: const TextStyle(
                        color: Color(0xFFFF9E80),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (guide != null)
              const Icon(Icons.chevron_right, color: Color(0xFFFF9E80)),
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
    final colors = Theme.of(context).colorScheme;
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
                        PhoenixCopy.workoutName(context.l10n, template),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (template.isRecoveryDay)
                        Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Text(
                            context.l10n.text(
                              'ΗΜΕΡΑ ΞΕΚΟΥΡΑΣΗΣ',
                              'REST-DAY SESSION',
                            ),
                            style: const TextStyle(
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
              template.exercises
                  .map(
                    (exercise) =>
                        PhoenixCopy.exerciseName(context.l10n, exercise),
                  )
                  .join('  •  '),
              style: TextStyle(color: Colors.white.withValues(alpha: .65)),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.bolt, size: 18, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    PhoenixCopy.trainingText(
                      context.l10n,
                      template.prescription,
                    ),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              PhoenixCopy.trainingText(context.l10n, template.coachingCue),
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
