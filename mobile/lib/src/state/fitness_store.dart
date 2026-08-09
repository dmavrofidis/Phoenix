import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/local_fitness_repository.dart';
import '../data/drift_fitness_repository.dart';
import '../data_validation_engine.dart';
import '../exercise_substitution_engine.dart';
import '../models/fitness_models.dart';
import '../nutrition_goal_engine.dart';
import '../nutrition_analytics_engine.dart';
import '../periodization_engine.dart';
import '../recovery_engine.dart';
import '../recovery_lab_engine.dart';
import '../training_analytics_engine.dart';
import '../training_insights.dart';
import '../training_program_engine.dart';
import '../training_schedule.dart';

class FitnessStore extends ChangeNotifier {
  FitnessStore(this._repository);

  final FitnessRepository _repository;
  FitnessData _data = FitnessData.initial();
  WorkoutTemplate? _activeWorkout;
  DateTime? _activeSince;
  final List<ExerciseSetLog> _activeSets = [];
  bool _previewWithoutProfile = false;
  int _idSequence = 0;
  FitnessData? _undoData;
  String _undoLabel = '';
  bool _vaultUnlocked = true;
  DataValidationReport _startupAudit = DataValidationEngine.audit(
    FitnessData.initial(),
  );
  List<LocalProfileInfo> _localProfiles = const [];
  List<DiagnosticEntry> _diagnostics = const [];

  String _nextId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_idSequence++}';

  FitnessData get data => _data;
  UserProfile? get profile => _data.profile;
  bool get needsOnboarding => _data.profile == null && !_previewWithoutProfile;
  WorkoutTemplate? get activeWorkout => _activeWorkout;
  bool get hasActiveWorkout => _activeWorkout != null;
  List<ExerciseSetLog> get activeSets => List.unmodifiable(_activeSets);
  String get spotifyUrl => _data.spotifyUrl;
  bool get hasSpotifyLink => _data.spotifyUrl.isNotEmpty;
  SpotifyAuthConfig get spotifyAuth => _data.spotifyAuth;
  List<ProgressPhoto> get progressPhotos =>
      List.unmodifiable(_data.progressPhotos);
  List<WearableDailySummary> get wearableSummaries =>
      List.unmodifiable(_data.wearableSummaries);
  AppPreferences get preferences => _data.preferences;
  bool get isEnglish => preferences.languageCode == 'en';
  bool get hasVaultPin => preferences.hasVaultPin;
  bool get vaultUnlocked => !hasVaultPin || _vaultUnlocked;
  bool get canUndo => _undoData != null;
  String get undoLabel => _undoLabel;
  DataValidationReport get startupAudit => _startupAudit;
  List<LocalProfileInfo> get localProfiles => List.unmodifiable(_localProfiles);
  List<DiagnosticEntry> get diagnostics => List.unmodifiable(_diagnostics);
  List<WorkoutReminder> get workoutReminders =>
      List.unmodifiable(_data.workoutReminders);
  List<CustomExerciseDefinition> get customExercises =>
      List.unmodifiable(_data.customExercises);
  Map<String, double> get strengthTrainingMaxes =>
      Map.unmodifiable(_data.strengthTrainingMaxes);
  List<HypertrophyCheckIn> get hypertrophyCheckIns =>
      List.unmodifiable(_data.hypertrophyCheckIns);
  List<HypertrophyTechniqueLog> get hypertrophyTechniqueLogs =>
      List.unmodifiable(_data.hypertrophyTechniqueLogs);
  List<CardioSessionLog> get cardioSessions =>
      List.unmodifiable(_data.cardioSessions);
  List<ConditioningBenchmarkResult> get conditioningBenchmarks =>
      List.unmodifiable(_data.conditioningBenchmarks);
  List<RunningSessionLog> get runningSessions =>
      List.unmodifiable(_data.runningSessions);
  List<RunningShoe> get runningShoes => List.unmodifiable(_data.runningShoes);
  List<CyclingSessionLog> get cyclingSessions =>
      List.unmodifiable(_data.cyclingSessions);
  List<RowingSessionLog> get rowingSessions =>
      List.unmodifiable(_data.rowingSessions);
  List<CalisthenicsSkillLog> get calisthenicsSkillLogs =>
      List.unmodifiable(_data.calisthenicsSkillLogs);
  List<MobilityScreenLog> get mobilityScreenLogs =>
      List.unmodifiable(_data.mobilityScreenLogs);
  List<RecoveryInterventionLog> get recoveryInterventions =>
      List.unmodifiable(_data.recoveryInterventions);
  List<NutritionPhaseLog> get nutritionPhaseLogs =>
      List.unmodifiable(_data.nutritionPhaseLogs);
  List<PantryItem> get pantryItems => List.unmodifiable(_data.pantryItems);
  List<String> get favoriteIngredientIds =>
      List.unmodifiable(_data.favoriteIngredientIds);
  List<BodyMeasurementLog> get bodyMeasurementLogs =>
      List.unmodifiable(_data.bodyMeasurementLogs);
  List<HealthHabit> get healthHabits => List.unmodifiable(_data.healthHabits);
  List<HabitCheckIn> get habitCheckIns =>
      List.unmodifiable(_data.habitCheckIns);
  List<SleepRoutineLog> get sleepRoutineLogs =>
      List.unmodifiable(_data.sleepRoutineLogs);
  List<StressCheckInLog> get stressCheckInLogs =>
      List.unmodifiable(_data.stressCheckInLogs);
  List<CoachRecommendationFeedback> get coachRecommendationFeedback =>
      List.unmodifiable(_data.coachRecommendationFeedback);
  List<String> get analyticsDashboardMetrics =>
      List.unmodifiable(_data.analyticsDashboardMetrics);
  List<AnalyticsAnnotation> get analyticsAnnotations =>
      List.unmodifiable(_data.analyticsAnnotations);
  DataValidationReport get validationReport =>
      DataValidationEngine.audit(_data);

  double get currentWeightKilograms => _data.weights.isNotEmpty
      ? _data.weights.first.kilograms
      : profile?.weightKilograms ?? 80;

  RecoveryCheckIn? get todaysRecoveryCheckIn {
    final now = DateTime.now();
    for (final checkIn in _data.recoveryChecks) {
      if (checkIn.recordedAt.year == now.year &&
          checkIn.recordedAt.month == now.month &&
          checkIn.recordedAt.day == now.day) {
        return checkIn;
      }
    }
    return null;
  }

  RecoveryPlan? get todaysRecoveryPlan {
    final checkIn = todaysRecoveryCheckIn;
    return checkIn == null ? null : RecoveryEngine.evaluate(checkIn);
  }

  ReadinessBaseline get readinessBaseline =>
      RecoveryLabEngine.baseline(_data.recoveryChecks);

  List<RecoveryRecommendation> get recoveryRecommendations =>
      RecoveryLabEngine.recommendations(
        latest: todaysRecoveryCheckIn,
        isRestDay: !isTrainingDayFor(DateTime.now()),
      );

  List<FatigueCell> get fatigueHeatmap => RecoveryLabEngine.fatigueHeatmap(
    checkIns: _data.recoveryChecks,
    now: DateTime.now(),
  );

  RecoveryCorrelation get recoveryPerformanceCorrelation =>
      RecoveryLabEngine.performanceCorrelation(
        checkIns: _data.recoveryChecks,
        logs: _data.logs,
      );

  ReturnRamp? get currentReturnRamp =>
      RecoveryLabEngine.returnRamp(_data.recoveryStatus, DateTime.now());

  bool get trainingPaused {
    final status = _data.recoveryStatus;
    return status.illnessMode ||
        (status.pausedUntil != null &&
            status.pausedUntil!.isAfter(DateTime.now()));
  }

  NutritionTargets get nutritionTargets => NutritionGoalEngine.calculate(
    profile: profile,
    currentWeightKilograms: currentWeightKilograms,
    isTrainingDay: isTrainingDayFor(DateTime.now()),
  );

  NutritionTargets nutritionTargetsForDate(DateTime date) =>
      NutritionGoalEngine.calculate(
        profile: profile,
        currentWeightKilograms: currentWeightKilograms,
        isTrainingDay: isTrainingDayFor(date),
      );

  NutritionCoachMessage get nutritionCoach => NutritionGoalEngine.coach(
    targets: nutritionTargets,
    calories: caloriesToday,
    protein: proteinToday,
  );

  List<String> get exerciseLibrary {
    final names = <String>{
      for (final template in _data.templates) ...template.exercises,
      for (final template in FitnessData.initial().templates)
        ...template.exercises,
    };
    return names.toList()..sort();
  }

  PeriodizationPlan get currentPeriodizationPlan =>
      PeriodizationEngine.currentPlan(now: DateTime.now(), logs: _data.logs);

  DeloadAdvice get deloadAdvice => PeriodizationEngine.deloadAdvice(
    plan: currentPeriodizationPlan,
    logs: _data.logs,
    recoveryChecks: _data.recoveryChecks,
    now: DateTime.now(),
  );

  List<MuscleVolume> get weeklyMuscleVolume =>
      TrainingAnalyticsEngine.weeklyMuscleVolume(
        _data.logs,
        now: DateTime.now(),
      );

  WeeklyTrainingReport get weeklyTrainingReport =>
      TrainingAnalyticsEngine.weeklyReport(
        logs: _data.logs,
        workoutTarget: weeklyWorkoutTarget,
        now: DateTime.now(),
      );

  int get workoutsThisWeek {
    final threshold = DateTime.now().subtract(const Duration(days: 7));
    return _data.logs.where((log) => log.completedAt.isAfter(threshold)).length;
  }

  int get weeklyWorkoutTarget => profile?.daysPerWeek ?? 3;

  int get workoutsInCurrentWeek {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
    return _data.logs
        .where((log) => !log.completedAt.isBefore(startOfWeek))
        .length;
  }

  double get weeklyWorkoutProgress =>
      (workoutsInCurrentWeek / weeklyWorkoutTarget).clamp(0, 1).toDouble();

  List<WorkoutTemplate> get workoutRotation {
    if (profile == null) return List.unmodifiable(_data.templates);

    WorkoutTemplate? byId(String id) {
      for (final template in _data.templates) {
        if (template.id == id) return template;
      }
      return null;
    }

    final days = weeklyWorkoutTarget;
    final preferredIds = days <= 2
        ? ['full-body-a', 'full-body-b']
        : days == 3
        ? ['iron-upper', 'iron-lower', 'iron-hybrid']
        : days == 4
        ? ['iron-upper', 'iron-lower', 'calisthenics-strength', 'iron-hybrid']
        : [
            'iron-upper',
            'iron-lower',
            'iron-hybrid',
            'calisthenics-strength',
            'iron-engine',
          ];
    final rotation = <WorkoutTemplate>[];
    for (final id in preferredIds) {
      final template = byId(id);
      if (template != null) rotation.add(template);
    }
    return rotation.isEmpty ? List.unmodifiable(_data.templates) : rotation;
  }

  TrainingSchedule get weeklySchedule => TrainingScheduleEngine.build(
    now: DateTime.now(),
    daysPerWeek: weeklyWorkoutTarget,
    rotation: workoutRotation,
    logs: _data.logs,
    assignments: _data.weeklyAssignments,
    dateAssignments: _data.dateAssignments,
    catalog: _data.templates,
  );

  WorkoutTemplate get recommendedWorkout {
    final rotation = workoutRotation;
    if (rotation.isEmpty) {
      throw StateError('Δεν υπάρχουν διαθέσιμα προγράμματα.');
    }
    final scheduled = weeklySchedule.nextEntry(DateTime.now());
    if (scheduled != null) return scheduled.template;
    for (final log in _data.logs) {
      final completedIndex = rotation.indexWhere(
        (template) => template.name == log.templateName,
      );
      if (completedIndex >= 0) {
        return rotation[(completedIndex + 1) % rotation.length];
      }
    }
    return rotation.first;
  }

  String get rotationSummary => workoutRotation
      .map((template) => template.name.split(' — ').first)
      .join(' → ');

  int get lifetimeSets =>
      _data.logs.fold(0, (total, workout) => total + workout.sets.length);

  double get lifetimeVolume => _data.logs.fold(
    0,
    (total, workout) =>
        total + workout.sets.fold(0, (sum, set) => sum + set.volume),
  );

  double get bestEstimatedOneRepMax {
    var best = 0.0;
    for (final workout in _data.logs) {
      for (final set in workout.sets) {
        if (set.weightKilograms <= 0 || set.reps <= 0) continue;
        final estimate = set.weightKilograms * (1 + set.reps / 30);
        if (estimate > best) best = estimate;
      }
    }
    return best;
  }

  List<ExerciseRecord> get exerciseRecords =>
      TrainingInsights.recordsFrom(_data.logs);

  ProgressionSuggestion progressionFor(String exerciseName) {
    final completedSets = [
      for (final workout in _data.logs) ...workout.sets,
      ..._activeSets,
    ];
    ExercisePrescription? prescription;
    final active = _activeWorkout;
    if (active != null && active.exercises.contains(exerciseName)) {
      prescription = active.prescriptionFor(exerciseName);
    } else {
      for (final template in _data.templates) {
        if (template.exercises.contains(exerciseName)) {
          prescription = template.prescriptionFor(exerciseName);
          break;
        }
      }
    }
    final suggestion = TrainingInsights.suggestionFor(
      exerciseName,
      completedSets,
      prescription: prescription,
    );
    final recovery = todaysRecoveryPlan;
    final cycleFactor = currentPeriodizationPlan.loadFactor;
    final recoveryFactor = recovery?.loadFactor ?? 1;
    final combinedFactor = cycleFactor * recoveryFactor;
    if (active != null &&
        active.exercises.contains(exerciseName) &&
        combinedFactor != 1 &&
        suggestion.targetWeightKilograms > 0) {
      final adjustedWeight =
          (suggestion.targetWeightKilograms * combinedFactor * 2).round() / 2;
      return ProgressionSuggestion(
        headline: 'Adaptive load ${(combinedFactor * 100).round()}%',
        detail:
            '${suggestion.headline}. Σήμερα προέχει η ποιότητα και το απόθεμα.',
        targetReps: suggestion.targetReps,
        targetWeightKilograms: adjustedWeight,
        targetHoldSeconds: suggestion.targetHoldSeconds,
      );
    }
    return suggestion;
  }

  List<MealEntry> get todaysMeals {
    final now = DateTime.now();
    return _data.meals
        .where(
          (meal) =>
              meal.loggedAt.year == now.year &&
              meal.loggedAt.month == now.month &&
              meal.loggedAt.day == now.day,
        )
        .toList();
  }

  List<MealEntry> get todaysMealsChronological =>
      [...todaysMeals]
        ..sort((left, right) => left.loggedAt.compareTo(right.loggedAt));

  int get caloriesToday =>
      todaysMeals.fold(0, (total, meal) => total + meal.calories);
  double get proteinToday =>
      todaysMeals.fold(0, (total, meal) => total + meal.proteinGrams);
  double get carbohydratesToday =>
      todaysMeals.fold(0, (total, meal) => total + meal.carbohydrateGrams);
  double get fatToday =>
      todaysMeals.fold(0, (total, meal) => total + meal.fatGrams);
  double get fiberToday =>
      todaysMeals.fold(0, (total, meal) => total + meal.fiberGrams);
  double get sodiumToday =>
      todaysMeals.fold(0, (total, meal) => total + meal.sodiumMilligrams);

  List<HydrationEntry> get todaysHydration {
    final now = DateTime.now();
    return _data.hydration
        .where(
          (entry) =>
              entry.loggedAt.year == now.year &&
              entry.loggedAt.month == now.month &&
              entry.loggedAt.day == now.day,
        )
        .toList();
  }

  int get waterTodayMilliliters =>
      todaysHydration.fold(0, (sum, entry) => sum + entry.milliliters);

  int get hydrationTargetMilliliters =>
      (currentWeightKilograms * 35).round().clamp(1800, 4500);

  bool isTrainingDayFor(DateTime date) {
    final dateKey =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final assignedId =
        _data.dateAssignments[dateKey] ??
        _data.weeklyAssignments['${date.weekday}'];
    if (assignedId != null) {
      final assigned = _data.templates
          .where((template) => template.id == assignedId)
          .firstOrNull;
      return assigned != null && !assigned.isRecoveryDay;
    }
    return TrainingScheduleEngine.distributedWeekdays(
      weeklyWorkoutTarget,
    ).contains(date.weekday);
  }

  List<DailyNutritionSummary> get weeklyNutritionSummaries =>
      NutritionAnalyticsEngine.weeklySummaries(
        meals: _data.meals,
        hydration: _data.hydration,
        now: DateTime.now(),
        targetsForDate: nutritionTargetsForDate,
      );

  double get weeklyMacroAdherence =>
      NutritionAnalyticsEngine.weeklyMacroAdherence(weeklyNutritionSummaries);

  int get nutritionConsistencyStreak =>
      NutritionAnalyticsEngine.consistencyStreak(
        meals: _data.meals,
        now: DateTime.now(),
        targetsForDate: nutritionTargetsForDate,
      );

  List<GroceryItem> get groceryList =>
      NutritionAnalyticsEngine.groceryList(_data.mealPresets);

  Future<void> load() async {
    _data = await _repository.load();
    _vaultUnlocked = !_data.preferences.hasVaultPin;
    final currentProfile = _data.profile;
    final goal = currentProfile?.goal ?? 'Δύναμη';
    final experienceLevel = currentProfile?.experienceLevel ?? 'Μέτριος';
    var changed = false;
    final enrichedTemplates = _data.templates.map((template) {
      final generated = TrainingProgramEngine.prescriptionsFor(
        template.exercises,
        goal: goal,
        experienceLevel: experienceLevel,
        templateId: template.id,
      );
      final missingPrescription = template.exercises.any(
        (exercise) => !template.exercisePrescriptions.containsKey(exercise),
      );
      if (!missingPrescription) return template;
      changed = true;
      return template.copyWith(
        exercisePrescriptions: {
          ...generated,
          ...template.exercisePrescriptions,
        },
      );
    }).toList();

    var templates = enrichedTemplates;
    if (currentProfile != null) {
      final existingIds = templates.map((item) => item.id).toSet();
      final missingTemplates = _recommendedTemplates(
        currentProfile,
      ).where((item) => !existingIds.contains(item.id)).toList();
      if (missingTemplates.isNotEmpty) {
        templates = [...templates, ...missingTemplates];
        changed = true;
      }
    }
    if (changed) {
      _data = _data.copyWith(templates: templates);
      await _repository.save(_data);
    }
    _startupAudit = DataValidationEngine.audit(_data);
    if (_startupAudit.criticalCount > 0 && _startupAudit.hasRepairableIssues) {
      _data = DataValidationEngine.repair(_data);
      await _repository.save(_data);
      _startupAudit = DataValidationEngine.audit(_data);
    }
    await _refreshReliabilityData();
    notifyListeners();
  }

  Future<void> updatePreferences({
    String? languageCode,
    bool? highContrast,
    String? themePreset,
    bool? hapticFeedback,
    bool? audioCues,
    String? audioCueStyle,
    int? countdownCueSeconds,
    int? lockTimeoutMinutes,
  }) async {
    final language = languageCode == null
        ? preferences.languageCode
        : const {'el', 'en'}.contains(languageCode)
        ? languageCode
        : 'el';
    final theme = themePreset == null
        ? preferences.themePreset
        : const {'iron', 'ocean', 'forest'}.contains(themePreset)
        ? themePreset
        : 'iron';
    final cueStyle = audioCueStyle == null
        ? preferences.audioCueStyle
        : const {'minimal', 'coach', 'silent'}.contains(audioCueStyle)
        ? audioCueStyle
        : 'minimal';
    final cueSeconds = countdownCueSeconds == null
        ? preferences.countdownCueSeconds
        : countdownCueSeconds.clamp(0, 10);
    final lockTimeout = lockTimeoutMinutes == null
        ? preferences.lockTimeoutMinutes
        : lockTimeoutMinutes.clamp(0, 60);
    _data = _data.copyWith(
      preferences: preferences.copyWith(
        languageCode: language,
        highContrast: highContrast,
        themePreset: theme,
        hapticFeedback: hapticFeedback,
        audioCues: audioCues,
        audioCueStyle: cueStyle,
        countdownCueSeconds: cueSeconds,
        lockTimeoutMinutes: lockTimeout,
      ),
    );
    await _repository.save(_data);
    await feedback();
    notifyListeners();
  }

  Future<void> feedback({bool success = false}) async {
    if (preferences.hapticFeedback) {
      if (success) {
        await HapticFeedback.mediumImpact();
      } else {
        await HapticFeedback.selectionClick();
      }
    }
    if (success &&
        preferences.audioCues &&
        preferences.audioCueStyle != 'silent') {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> playCountdownCue({bool finalCue = false}) async {
    if (!preferences.audioCues ||
        preferences.audioCueStyle == 'silent' ||
        preferences.countdownCueSeconds == 0) {
      return;
    }
    await SystemSound.play(
      finalCue && preferences.audioCueStyle == 'coach'
          ? SystemSoundType.alert
          : SystemSoundType.click,
    );
  }

  String _pinHash(String pin) =>
      sha256.convert(utf8.encode('phoenix-local-vault-v1:$pin')).toString();

  bool _isValidPin(String pin) => RegExp(r'^\d{4,8}$').hasMatch(pin);

  Future<void> setVaultPin(String pin) async {
    if (!_isValidPin(pin)) {
      throw const FormatException('Το PIN πρέπει να έχει 4–8 ψηφία.');
    }
    _data = _data.copyWith(
      preferences: preferences.copyWith(vaultPinHash: _pinHash(pin)),
    );
    _vaultUnlocked = true;
    await _repository.save(_data);
    await feedback(success: true);
    notifyListeners();
  }

  Future<bool> unlockVault(String pin) async {
    if (!hasVaultPin) {
      _vaultUnlocked = true;
      notifyListeners();
      return true;
    }
    final valid =
        _isValidPin(pin) &&
        _constantTimeEquals(_pinHash(pin), preferences.vaultPinHash);
    if (valid) {
      _vaultUnlocked = true;
      await feedback(success: true);
      notifyListeners();
    }
    return valid;
  }

  bool _constantTimeEquals(String left, String right) {
    if (left.length != right.length) return false;
    var difference = 0;
    for (var index = 0; index < left.length; index++) {
      difference |= left.codeUnitAt(index) ^ right.codeUnitAt(index);
    }
    return difference == 0;
  }

  void lockVault() {
    if (!hasVaultPin) return;
    _vaultUnlocked = false;
    notifyListeners();
  }

  Future<void> removeVaultPin(String currentPin) async {
    if (hasVaultPin &&
        !_constantTimeEquals(_pinHash(currentPin), preferences.vaultPinHash)) {
      throw const FormatException('Το τρέχον PIN δεν είναι σωστό.');
    }
    _data = _data.copyWith(preferences: preferences.copyWith(vaultPinHash: ''));
    _vaultUnlocked = true;
    await _repository.save(_data);
    notifyListeners();
  }

  void _captureUndo(String label) {
    _undoData = FitnessData.fromJson(
      jsonDecode(jsonEncode(_data.toJson())) as Map<String, dynamic>,
    );
    _undoLabel = label;
  }

  Future<bool> undoLastMutation() async {
    final snapshot = _undoData;
    if (snapshot == null) return false;
    _data = snapshot;
    _undoData = null;
    _undoLabel = '';
    await _repository.save(_data);
    await feedback(success: true);
    notifyListeners();
    return true;
  }

  void clearUndo() {
    _undoData = null;
    _undoLabel = '';
    notifyListeners();
  }

  Future<void> repairData() async {
    final report = validationReport;
    if (!report.hasRepairableIssues) return;
    _captureUndo('Αυτόματη επιδιόρθωση δεδομένων');
    _data = DataValidationEngine.repair(_data);
    await _repository.save(_data);
    await feedback(success: true);
    notifyListeners();
  }

  void previewWithoutProfile() {
    _previewWithoutProfile = true;
    notifyListeners();
  }

  void startWorkout(WorkoutTemplate template) {
    if (hasActiveWorkout || trainingPaused) return;
    final periodized = template.isRecoveryDay
        ? template
        : PeriodizationEngine.adaptWorkout(template, currentPeriodizationPlan);
    final ramped = RecoveryLabEngine.applyReturnRamp(
      periodized,
      currentReturnRamp,
    );
    final recovery = todaysRecoveryCheckIn;
    _activeWorkout = recovery == null
        ? ramped
        : RecoveryEngine.adaptWorkout(ramped, recovery);
    _activeSince = DateTime.now();
    _activeSets.clear();
    notifyListeners();
  }

  List<ExerciseAlternative> alternativesForActiveExercise(String exercise) {
    final workout = _activeWorkout;
    if (workout == null) return const [];
    return ExerciseSubstitutionEngine.alternativesFor(
      exercise: exercise,
      profile: profile,
      excludedExercises: workout.exercises,
      painAreas: recentPainAreas,
    );
  }

  Set<String> get recentPainAreas {
    final threshold = DateTime.now().subtract(const Duration(days: 30));
    return {
      for (final log in _data.logs)
        if (log.completedAt.isAfter(threshold) &&
            log.painSeverity >= 2 &&
            log.painArea.trim().isNotEmpty)
          log.painArea.trim(),
    };
  }

  void replaceActiveExercise({
    required String exercise,
    required String replacement,
  }) {
    final workout = _activeWorkout;
    if (workout == null) {
      throw StateError('Δεν υπάρχει ενεργή προπόνηση.');
    }
    if (_activeSets.any((set) => set.exerciseName == exercise)) {
      throw const FormatException(
        'Δεν μπορείς να αλλάξεις άσκηση αφού έχει καταγραφεί σετ.',
      );
    }
    final alternatives = alternativesForActiveExercise(exercise);
    if (!alternatives.any((item) => item.name == replacement)) {
      throw const FormatException('Η εναλλακτική άσκηση δεν είναι διαθέσιμη.');
    }

    final goal = profile?.goal ?? 'Δύναμη';
    final experience = profile?.experienceLevel ?? 'Μέτριος';
    final generated = TrainingProgramEngine.prescriptionsFor(
      [replacement],
      goal: goal,
      experienceLevel: experience,
      templateId: workout.id,
    );
    var adaptedTemplate = PeriodizationEngine.adaptWorkout(
      WorkoutTemplate(
        id: workout.id,
        name: workout.name,
        exercises: [replacement],
        exercisePrescriptions: generated,
      ),
      currentPeriodizationPlan,
    );
    final recovery = todaysRecoveryCheckIn;
    if (recovery != null) {
      adaptedTemplate = RecoveryEngine.adaptWorkout(adaptedTemplate, recovery);
    }
    final replacementPrescription = adaptedTemplate.prescriptionFor(
      replacement,
    );

    final exercises = workout.exercises
        .map((item) => item == exercise ? replacement : item)
        .toList();
    final prescriptions =
        Map<String, ExercisePrescription>.from(workout.exercisePrescriptions)
          ..remove(exercise)
          ..[replacement] = replacementPrescription;
    _activeWorkout = workout.copyWith(
      exercises: exercises,
      exercisePrescriptions: prescriptions,
      blocks: [
        for (final block in workout.blocks)
          WorkoutBlock(
            id: block.id,
            type: block.type,
            exercises: [
              for (final item in block.exercises)
                item == exercise ? replacement : item,
            ],
          ),
      ],
    );
    notifyListeners();
  }

  void logSet({
    required String exerciseName,
    required int reps,
    required double weightKilograms,
    required int rir,
    required int holdSeconds,
    int setRpe = 0,
    String velocityNote = '',
    List<String> techniqueChecks = const [],
    bool isAmrap = false,
  }) {
    if (!hasActiveWorkout) {
      throw StateError('Δεν υπάρχει ενεργή προπόνηση.');
    }
    if (reps < 0 || reps > 100) {
      throw const FormatException('Οι επαναλήψεις πρέπει να είναι 0–100.');
    }
    if (weightKilograms < 0 || weightKilograms > 600) {
      throw const FormatException('Τα κιλά πρέπει να είναι 0–600.');
    }
    if (rir < 0 || rir > 5) {
      throw const FormatException('Το RIR πρέπει να είναι 0–5.');
    }
    if (holdSeconds < 0 || holdSeconds > 600) {
      throw const FormatException('Το hold πρέπει να είναι 0–600 δευτ.');
    }
    if (setRpe < 0 || setRpe > 10) {
      throw const FormatException('Το set RPE πρέπει να είναι 0–10.');
    }
    if (!const {
      '',
      'explosive',
      'steady',
      'slow',
      'grinding',
    }.contains(velocityNote)) {
      throw const FormatException('Μη έγκυρη σημείωση ταχύτητας.');
    }
    if (reps == 0 && holdSeconds == 0) {
      throw const FormatException(
        'Κατάγραψε επαναλήψεις ή χρόνο στατικού hold.',
      );
    }
    _activeSets.add(
      ExerciseSetLog(
        exerciseName: exerciseName,
        reps: reps,
        weightKilograms: weightKilograms,
        rir: rir,
        holdSeconds: holdSeconds,
        loggedAt: DateTime.now(),
        setRpe: setRpe,
        velocityNote: velocityNote,
        techniqueChecks: techniqueChecks.toSet().take(6).toList(),
        isAmrap: isAmrap,
      ),
    );
    notifyListeners();
  }

  void removeSet(ExerciseSetLog set) {
    _activeSets.remove(set);
    notifyListeners();
  }

  Future<void> finishWorkout({
    int sessionRpe = 0,
    String notes = '',
    String painArea = '',
    int painSeverity = 0,
  }) async {
    final workout = _activeWorkout;
    final startedAt = _activeSince;
    if (workout == null || startedAt == null) return;
    if (sessionRpe < 0 || sessionRpe > 10) {
      throw const FormatException('Το session RPE πρέπει να είναι 1–10.');
    }
    if (painSeverity < 0 || painSeverity > 5) {
      throw const FormatException('Η ένταση ενόχλησης πρέπει να είναι 0–5.');
    }
    final elapsed = DateTime.now().difference(startedAt).inMinutes;
    _data = _data.copyWith(
      logs: [
        WorkoutLog(
          templateName: workout.name,
          completedAt: DateTime.now(),
          minutes: elapsed < 1 ? 1 : elapsed,
          sets: List.of(_activeSets),
          sessionRpe: sessionRpe,
          notes: notes.trim(),
          painArea: painSeverity == 0 ? '' : painArea.trim(),
          painSeverity: painSeverity,
        ),
        ..._data.logs,
      ],
    );
    _activeWorkout = null;
    _activeSince = null;
    _activeSets.clear();
    await _repository.save(_data);
    notifyListeners();
  }

  void cancelWorkout() {
    _activeWorkout = null;
    _activeSince = null;
    _activeSets.clear();
    notifyListeners();
  }

  Future<void> addWeight(double kilograms) async {
    if (kilograms < 20 || kilograms > 400) {
      throw const FormatException('Το βάρος πρέπει να είναι 20–400 kg.');
    }
    _data = _data.copyWith(
      weights: [
        WeightEntry(kilograms: kilograms, recordedAt: DateTime.now()),
        ..._data.weights,
      ],
    );
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> addMeal({
    required String name,
    required int calories,
    required double proteinGrams,
    required double carbohydrateGrams,
    required double fatGrams,
    double fiberGrams = 0,
    double sodiumMilligrams = 0,
    String presetId = '',
    String photoEncodedBytes = '',
    DateTime? loggedAt,
  }) async {
    if (name.trim().isEmpty) {
      throw const FormatException('Γράψε ένα όνομα γεύματος.');
    }
    if (calories < 0 || calories > 5000) {
      throw const FormatException(
        'Οι θερμίδες ανά γεύμα πρέπει να είναι 0–5000.',
      );
    }
    for (final macro in [
      proteinGrams,
      carbohydrateGrams,
      fatGrams,
      fiberGrams,
    ]) {
      if (macro < 0 || macro > 500) {
        throw const FormatException(
          'Κάθε μακροθρεπτικό πρέπει να είναι 0–500 g.',
        );
      }
    }
    if (sodiumMilligrams < 0 || sodiumMilligrams > 10000) {
      throw const FormatException(
        'Το νάτριο ανά γεύμα πρέπει να είναι 0–10000 mg.',
      );
    }
    _data = _data.copyWith(
      meals: [
        MealEntry(
          name: name.trim(),
          calories: calories,
          proteinGrams: proteinGrams,
          carbohydrateGrams: carbohydrateGrams,
          fatGrams: fatGrams,
          fiberGrams: fiberGrams,
          sodiumMilligrams: sodiumMilligrams,
          presetId: presetId,
          photoEncodedBytes: photoEncodedBytes,
          loggedAt: loggedAt ?? DateTime.now(),
        ),
        ..._data.meals,
      ],
    );
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> addMealFromPreset(MealPreset preset) => addMeal(
    name: preset.name,
    calories: preset.calories,
    proteinGrams: preset.proteinGrams,
    carbohydrateGrams: preset.carbohydrateGrams,
    fatGrams: preset.fatGrams,
    fiberGrams: preset.fiberGrams,
    sodiumMilligrams: preset.sodiumMilligrams,
    presetId: preset.id,
  );

  Future<MealPreset> createMealPreset({
    required String name,
    required int calories,
    required double proteinGrams,
    required double carbohydrateGrams,
    required double fatGrams,
    double fiberGrams = 0,
    double sodiumMilligrams = 0,
    List<String> ingredients = const [],
  }) async {
    if (_data.mealPresets.length >= 30) {
      throw const FormatException('Έφτασες το όριο των 30 meal presets.');
    }
    if (name.trim().isEmpty || calories < 0 || calories > 5000) {
      throw const FormatException('Έλεγξε το όνομα και τις θερμίδες preset.');
    }
    final preset = MealPreset(
      id: _nextId('custom-meal'),
      name: name.trim(),
      calories: calories,
      proteinGrams: proteinGrams.clamp(0, 500).toDouble(),
      carbohydrateGrams: carbohydrateGrams.clamp(0, 500).toDouble(),
      fatGrams: fatGrams.clamp(0, 500).toDouble(),
      fiberGrams: fiberGrams.clamp(0, 500).toDouble(),
      sodiumMilligrams: sodiumMilligrams.clamp(0, 10000).toDouble(),
      ingredients: ingredients
          .map((ingredient) => ingredient.trim())
          .where((ingredient) => ingredient.isNotEmpty)
          .toSet()
          .take(20)
          .toList(),
    );
    _data = _data.copyWith(mealPresets: [..._data.mealPresets, preset]);
    await _repository.save(_data);
    notifyListeners();
    return preset;
  }

  Future<void> deleteMealPreset(String presetId) async {
    if (!presetId.startsWith('custom-meal-')) {
      throw const FormatException(
        'Τα βασικά meal presets του Phoenix δεν διαγράφονται.',
      );
    }
    _captureUndo('Διαγραφή meal preset');
    _data = _data.copyWith(
      mealPresets: _data.mealPresets
          .where((preset) => preset.id != presetId)
          .toList(),
    );
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> addWater(int milliliters, {DateTime? loggedAt}) async {
    if (milliliters < 50 || milliliters > 2000) {
      throw const FormatException(
        'Η ποσότητα νερού πρέπει να είναι 50–2000 ml.',
      );
    }
    _data = _data.copyWith(
      hydration: [
        HydrationEntry(
          milliliters: milliliters,
          loggedAt: loggedAt ?? DateTime.now(),
        ),
        ..._data.hydration,
      ],
    );
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> removeHydration(HydrationEntry entry) async {
    _captureUndo('Διαγραφή καταγραφής νερού');
    _data = _data.copyWith(
      hydration: _data.hydration.where((item) => item != entry).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> removeMeal(MealEntry meal) async {
    _captureUndo('Διαγραφή γεύματος');
    _data = _data.copyWith(
      meals: _data.meals.where((item) => item != meal).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> setSpotifyUrl(String input) async {
    final normalized = _normalizeSpotifyUrl(input);
    _data = _data.copyWith(spotifyUrl: normalized);
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> clearSpotifyUrl() async {
    _data = _data.copyWith(spotifyUrl: '');
    await _repository.save(_data);
    notifyListeners();
  }

  String workoutPlaylistFor(String templateId) =>
      _data.workoutPlaylists[templateId] ?? spotifyUrl;

  Future<void> setWorkoutPlaylist(String templateId, String input) async {
    if (!_data.templates.any((item) => item.id == templateId)) {
      throw const FormatException('Το πρόγραμμα δεν υπάρχει.');
    }
    final normalized = _normalizeSpotifyUrl(input);
    final updated = Map<String, String>.from(_data.workoutPlaylists)
      ..[templateId] = normalized;
    _data = _data.copyWith(workoutPlaylists: updated);
    await _repository.save(_data);
    await feedback(success: true);
    notifyListeners();
  }

  Future<void> clearWorkoutPlaylist(String templateId) async {
    final updated = Map<String, String>.from(_data.workoutPlaylists)
      ..remove(templateId);
    _data = _data.copyWith(workoutPlaylists: updated);
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> configureSpotifyOAuth({
    required String clientId,
    required String redirectUri,
    required String pkceVerifier,
    required String pkceChallenge,
  }) async {
    final id = clientId.trim();
    final redirect = Uri.tryParse(redirectUri.trim());
    if (!RegExp(r'^[A-Za-z0-9]{16,64}$').hasMatch(id)) {
      throw const FormatException(
        'Το Spotify Client ID πρέπει να έχει 16–64 λατινικούς χαρακτήρες.',
      );
    }
    if (redirect == null ||
        !redirect.hasAbsolutePath ||
        !const {'http', 'https'}.contains(redirect.scheme)) {
      throw const FormatException(
        'Το redirect URI πρέπει να είναι πλήρες http/https URL.',
      );
    }
    if (pkceVerifier.length < 43 || pkceChallenge.length < 40) {
      throw const FormatException('Το PKCE challenge δεν είναι έγκυρο.');
    }
    _data = _data.copyWith(
      spotifyAuth: SpotifyAuthConfig(
        clientId: id,
        redirectUri: redirect.toString(),
        pkceVerifier: pkceVerifier,
        pkceChallenge: pkceChallenge,
        configuredAt: DateTime.now(),
      ),
    );
    await _repository.save(_data);
    await feedback(success: true);
    notifyListeners();
  }

  Future<void> clearSpotifyOAuth() async {
    _data = _data.copyWith(spotifyAuth: const SpotifyAuthConfig());
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> saveProgressPhoto({
    required String encodedBytes,
    required String mimeType,
    String note = '',
    double? weightKilograms,
  }) async {
    if (!vaultUnlocked) {
      throw const FormatException('Ξεκλείδωσε πρώτα το ιδιωτικό vault.');
    }
    if (!const {'image/jpeg', 'image/png', 'image/webp'}.contains(mimeType)) {
      throw const FormatException('Υποστηρίζονται JPG, PNG και WebP.');
    }
    if (encodedBytes.isEmpty || encodedBytes.length > 900000) {
      throw const FormatException(
        'Η φωτογραφία πρέπει να είναι μικρότερη από περίπου 650 KB.',
      );
    }
    final photo = ProgressPhoto(
      id: _nextId('photo'),
      encodedBytes: encodedBytes,
      mimeType: mimeType,
      recordedAt: DateTime.now(),
      note: note.trim(),
      weightKilograms: weightKilograms,
    );
    _data = _data.copyWith(
      progressPhotos: [photo, ..._data.progressPhotos].take(12).toList(),
    );
    await _repository.save(_data);
    await feedback(success: true);
    notifyListeners();
  }

  Future<void> removeProgressPhoto(String id) async {
    if (!vaultUnlocked) {
      throw const FormatException('Ξεκλείδωσε πρώτα το ιδιωτικό vault.');
    }
    _captureUndo('Διαγραφή ιδιωτικής φωτογραφίας προόδου');
    _data = _data.copyWith(
      progressPhotos: _data.progressPhotos
          .where((item) => item.id != id)
          .toList(),
    );
    await _repository.save(_data);
    notifyListeners();
  }

  String exerciseVideoFor(String exercise) =>
      _data.exerciseVideoUrls[exercise] ?? '';

  Future<void> saveCustomExercise(CustomExerciseDefinition definition) async {
    final name = definition.name.trim();
    final pattern = definition.movementPattern.trim();
    final primary = definition.primaryMuscles
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
    final equipment = definition.equipment
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
    if (name.length < 3 || name.length > 80) {
      throw const FormatException(
        'Το όνομα άσκησης πρέπει να έχει 3–80 χαρακτήρες.',
      );
    }
    if (pattern.isEmpty || primary.isEmpty || equipment.isEmpty) {
      throw const FormatException(
        'Χρειάζονται movement pattern, primary muscle και εξοπλισμός.',
      );
    }
    if (definition.difficulty < 1 ||
        definition.difficulty > 5 ||
        definition.skillDemand < 1 ||
        definition.skillDemand > 5) {
      throw const FormatException(
        'Difficulty και skill demand πρέπει να είναι 1–5.',
      );
    }
    final id = definition.id.trim().isEmpty
        ? _nextId('custom-exercise')
        : definition.id.trim();
    final normalizedName = name.toLowerCase();
    final duplicate = _data.customExercises.any(
      (item) =>
          item.id != id && item.name.trim().toLowerCase() == normalizedName,
    );
    if (duplicate) {
      throw const FormatException(
        'Υπάρχει ήδη προσωπική άσκηση με αυτό το όνομα.',
      );
    }
    final sanitized = CustomExerciseDefinition(
      id: id,
      name: name,
      primaryMuscles: primary,
      secondaryMuscles: definition.secondaryMuscles
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty && !primary.contains(item))
          .toSet()
          .toList(),
      movementPattern: pattern,
      difficulty: definition.difficulty,
      skillDemand: definition.skillDemand,
      equipment: equipment,
      cautionAreas: definition.cautionAreas
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList(),
      regression: definition.regression.trim(),
      progression: definition.progression.trim(),
      notes: definition.notes.trim(),
    );
    _data = _data.copyWith(
      customExercises: [
        for (final item in _data.customExercises)
          if (item.id != id) item,
        sanitized,
      ],
    );
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> removeCustomExercise(String id) async {
    if (!_data.customExercises.any((item) => item.id == id)) return;
    _captureUndo('Διαγραφή προσωπικής άσκησης');
    _data = _data.copyWith(
      customExercises: _data.customExercises
          .where((item) => item.id != id)
          .toList(),
    );
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> setExerciseVideo(String exercise, String input) async {
    final name = exercise.trim();
    final uri = Uri.tryParse(input.trim());
    if (name.isEmpty ||
        uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty) {
      throw const FormatException(
        'Χρειάζεται όνομα άσκησης και ασφαλές https video URL.',
      );
    }
    final updated = Map<String, String>.from(_data.exerciseVideoUrls)
      ..[name] = uri.toString();
    _data = _data.copyWith(exerciseVideoUrls: updated);
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> removeExerciseVideo(String exercise) async {
    final updated = Map<String, String>.from(_data.exerciseVideoUrls)
      ..remove(exercise);
    _data = _data.copyWith(exerciseVideoUrls: updated);
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> saveWearableSummaries(
    List<WearableDailySummary> summaries,
  ) async {
    if (summaries.isEmpty) {
      throw const FormatException('Δεν βρέθηκαν wearable εγγραφές.');
    }
    final merged = <String, WearableDailySummary>{};
    for (final item in [..._data.wearableSummaries, ...summaries]) {
      if (item.steps < 0 ||
          item.steps > 100000 ||
          (item.restingHeartRate != 0 &&
              (item.restingHeartRate < 30 || item.restingHeartRate > 220)) ||
          item.sleepMinutes < 0 ||
          item.sleepMinutes > 1440) {
        throw const FormatException(
          'Το wearable αρχείο περιέχει τιμές εκτός ασφαλών ορίων.',
        );
      }
      final dayKey =
          '${item.day.year.toString().padLeft(4, '0')}-'
          '${item.day.month.toString().padLeft(2, '0')}-'
          '${item.day.day.toString().padLeft(2, '0')}|${item.source}';
      merged[dayKey] = item;
    }
    final sorted = merged.values.toList()
      ..sort((a, b) => b.day.compareTo(a.day));
    _data = _data.copyWith(wearableSummaries: sorted.take(730).toList());
    await _repository.save(_data);
    await feedback(success: true);
    notifyListeners();
  }

  Future<void> saveWorkoutReminder({
    required int weekday,
    required int minutesSinceMidnight,
    String templateId = '',
  }) async {
    if (weekday < 1 || weekday > 7) {
      throw const FormatException('Η ημέρα reminder πρέπει να είναι 1–7.');
    }
    if (minutesSinceMidnight < 0 || minutesSinceMidnight >= 1440) {
      throw const FormatException('Η ώρα reminder δεν είναι έγκυρη.');
    }
    if (templateId.isNotEmpty &&
        !_data.templates.any((item) => item.id == templateId)) {
      throw const FormatException('Το reminder δείχνει σε άγνωστο πρόγραμμα.');
    }
    final reminder = WorkoutReminder(
      id: _nextId('reminder'),
      weekday: weekday,
      minutesSinceMidnight: minutesSinceMidnight,
      templateId: templateId,
    );
    _data = _data.copyWith(
      workoutReminders: [..._data.workoutReminders, reminder].take(20).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> toggleWorkoutReminder(String id, bool enabled) async {
    _data = _data.copyWith(
      workoutReminders: [
        for (final item in _data.workoutReminders)
          if (item.id == id)
            WorkoutReminder(
              id: item.id,
              weekday: item.weekday,
              minutesSinceMidnight: item.minutesSinceMidnight,
              templateId: item.templateId,
              enabled: enabled,
            )
          else
            item,
      ],
    );
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> removeWorkoutReminder(String id) async {
    _captureUndo('Διαγραφή local workout reminder');
    _data = _data.copyWith(
      workoutReminders: _data.workoutReminders
          .where((item) => item.id != id)
          .toList(),
    );
    await _repository.save(_data);
    notifyListeners();
  }

  List<WorkoutReminder> dueWorkoutReminders(
    DateTime now, {
    int windowMinutes = 15,
  }) {
    final currentMinute = now.hour * 60 + now.minute;
    return _data.workoutReminders
        .where(
          (item) =>
              item.enabled &&
              item.weekday == now.weekday &&
              (item.minutesSinceMidnight - currentMinute).abs() <=
                  windowMinutes,
        )
        .toList();
  }

  Future<void> _refreshReliabilityData() async {
    final repository = _reliabilityRepository;
    if (repository == null) return;
    try {
      await repository.recordDiagnostic(
        category: 'integrity',
        message:
            'Startup audit ${_startupAudit.integrityScore}/100 • '
            '${_startupAudit.checkedRecords} records • '
            '${_startupAudit.issues.length} issues.',
        level: _startupAudit.criticalCount > 0 ? 'warning' : 'info',
      );
      _localProfiles = await repository.listProfiles();
      _diagnostics = await repository.recentDiagnostics();
    } on Object {
      _localProfiles = const [];
      _diagnostics = const [];
    }
  }

  Future<void> refreshReliabilityData() async {
    await _refreshReliabilityData();
    notifyListeners();
  }

  Future<void> createLocalProfile(String name) async {
    final repository = _reliabilityRepository;
    if (repository == null) {
      throw UnsupportedError('Multiple profiles require Drift storage.');
    }
    await repository.createProfile(
      name,
      FitnessData.initial().copyWith(
        preferences: preferences.copyWith(vaultPinHash: ''),
      ),
    );
    await _refreshReliabilityData();
    notifyListeners();
  }

  Future<void> switchLocalProfile(String id) async {
    final repository = _reliabilityRepository;
    if (repository == null) {
      throw UnsupportedError('Multiple profiles require Drift storage.');
    }
    await repository.switchProfile(id);
    await load();
  }

  Future<void> deleteLocalProfile(String id) async {
    final repository = _reliabilityRepository;
    if (repository == null) {
      throw UnsupportedError('Multiple profiles require Drift storage.');
    }
    await repository.deleteProfile(id);
    await _refreshReliabilityData();
    notifyListeners();
  }

  ReliabilityRepository? get _reliabilityRepository =>
      _repository is ReliabilityRepository
      ? _repository as ReliabilityRepository
      : null;

  Future<void> saveRecoveryCheckIn({
    required double sleepHours,
    required int energy,
    required int soreness,
    required int stress,
    Map<String, int> sorenessAreas = const {},
    int steps = 0,
    int restingHeartRate = 0,
  }) async {
    if (sleepHours < 0 || sleepHours > 14) {
      throw const FormatException('Ο ύπνος πρέπει να είναι 0–14 ώρες.');
    }
    for (final value in [energy, soreness, stress]) {
      if (value < 1 || value > 5) {
        throw const FormatException('Οι δείκτες πρέπει να είναι από 1 έως 5.');
      }
    }
    if (steps < 0 || steps > 100000) {
      throw const FormatException('Τα βήματα πρέπει να είναι 0–100000.');
    }
    if (restingHeartRate != 0 &&
        (restingHeartRate < 30 || restingHeartRate > 220)) {
      throw const FormatException(
        'Οι παλμοί ηρεμίας πρέπει να είναι 30–220 bpm.',
      );
    }
    if (sorenessAreas.values.any((value) => value < 0 || value > 5)) {
      throw const FormatException('Η τοπική κόπωση πρέπει να είναι 0–5.');
    }
    final now = DateTime.now();
    final withoutToday = _data.recoveryChecks
        .where(
          (item) =>
              item.recordedAt.year != now.year ||
              item.recordedAt.month != now.month ||
              item.recordedAt.day != now.day,
        )
        .toList();
    _data = _data.copyWith(
      recoveryChecks: [
        RecoveryCheckIn(
          sleepHours: sleepHours,
          energy: energy,
          soreness: soreness,
          stress: stress,
          sorenessAreas: Map<String, int>.from(sorenessAreas),
          steps: steps,
          restingHeartRate: restingHeartRate,
          recordedAt: now,
        ),
        ...withoutToday,
      ],
    );
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> setIllnessMode(bool enabled) async {
    final now = DateTime.now();
    _data = _data.copyWith(
      recoveryStatus: enabled
          ? RecoveryStatus(
              illnessMode: true,
              pausedUntil: now.add(const Duration(days: 3)),
            )
          : RecoveryStatus(illnessMode: false, returnStartedAt: now),
    );
    if (enabled && hasActiveWorkout) {
      _activeWorkout = null;
      _activeSince = null;
      _activeSets.clear();
    }
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> pauseTrainingUntil(DateTime? date) async {
    _data = _data.copyWith(
      recoveryStatus: RecoveryStatus(
        pausedUntil: date,
        returnStartedAt: date == null ? DateTime.now() : null,
      ),
    );
    await _repository.save(_data);
    notifyListeners();
  }

  ExercisePrescription prescriptionForNewExercise({
    required String exercise,
    required String templateId,
  }) {
    final generated = TrainingProgramEngine.prescriptionsFor(
      [exercise],
      goal: profile?.goal ?? 'Δύναμη',
      experienceLevel: profile?.experienceLevel ?? 'Μέτριος',
      templateId: templateId,
    );
    return generated[exercise]!;
  }

  WorkoutTemplate createCustomWorkoutDraft() {
    final base = recommendedWorkout;
    final exercises = base.exercises.take(3).toList();
    return WorkoutTemplate(
      id: _nextId('custom'),
      name: 'CUSTOM IRON — Νέο πρόγραμμα',
      exercises: exercises,
      prescription: base.prescription,
      coachingCue:
          'Προσωπικό πρόγραμμα: τεχνική, σταθερότητα και ελεγχόμενη πρόοδος.',
      restSeconds: base.restSeconds,
      exercisePrescriptions: {
        for (final exercise in exercises)
          exercise: base.prescriptionFor(exercise),
      },
    );
  }

  WorkoutTemplate createRestDayDraft() {
    const exercises = [
      '90/90 breathing',
      'Cat-cow mobility',
      'Dead bug',
      'Wall shoulder slides',
    ];
    final prescriptions = {
      for (final exercise in exercises)
        exercise: const ExercisePrescription(
          workingSets: 2,
          minReps: 6,
          maxReps: 10,
          targetRir: 4,
          restSeconds: 30,
          tempo: 'Αργό',
          note: 'Ήπια, ανώδυνη κίνηση και ρινική αναπνοή.',
        ),
    };
    return WorkoutTemplate(
      id: _nextId('custom-recovery'),
      name: 'RECOVERY FLOW — Rest Day',
      exercises: exercises,
      prescription: '2 ήπιοι γύροι • χωρίς πόνο • 20–25′',
      coachingCue: 'Στόχος είναι να τελειώσεις πιο φρέσκος από όταν ξεκίνησες.',
      restSeconds: 30,
      exercisePrescriptions: prescriptions,
      tags: const ['Recovery', 'Mobility'],
      sessionType: 'recovery',
      equipmentPreset: 'recovery',
      blocks: const [
        WorkoutBlock(
          id: 'recovery-circuit',
          type: 'circuit',
          exercises: exercises,
        ),
      ],
    );
  }

  Future<WorkoutTemplate> duplicateWorkoutTemplate(
    WorkoutTemplate template,
  ) async {
    if (_data.templates.length >= 30) {
      throw const FormatException('Έφτασες το όριο των 30 προγραμμάτων.');
    }
    final copy = template.copyWith(
      id: _nextId('custom'),
      name: '${template.name} — Αντίγραφο',
      isFavorite: false,
    );
    _data = _data.copyWith(templates: [..._data.templates, copy]);
    await _repository.save(_data);
    notifyListeners();
    return copy;
  }

  Future<void> deleteCustomWorkout(String templateId) async {
    if (!templateId.startsWith('custom-')) {
      throw const FormatException(
        'Τα βασικά προγράμματα του Phoenix δεν διαγράφονται.',
      );
    }
    if (_activeWorkout?.id == templateId) {
      throw const FormatException(
        'Δεν διαγράφεται πρόγραμμα όσο είναι ενεργή η συνεδρία.',
      );
    }
    final templates = _data.templates
        .where((template) => template.id != templateId)
        .toList();
    if (templates.length == _data.templates.length) return;
    _captureUndo('Διαγραφή προγράμματος');
    final assignments = Map<String, String>.from(_data.weeklyAssignments)
      ..removeWhere((_, value) => value == templateId);
    final versions = _data.programVersions
        .where((version) => version.templateId != templateId)
        .toList();
    _data = _data.copyWith(
      templates: templates,
      weeklyAssignments: assignments,
      programVersions: versions,
    );
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> toggleWorkoutFavorite(String templateId) async {
    final templates = [
      for (final template in _data.templates)
        template.id == templateId
            ? template.copyWith(isFavorite: !template.isFavorite)
            : template,
    ];
    _data = _data.copyWith(templates: templates);
    await _repository.save(_data);
    notifyListeners();
  }

  List<ProgramVersion> historyForTemplate(String templateId) =>
      _data.programVersions
          .where((version) => version.templateId == templateId)
          .toList()
        ..sort((left, right) => right.savedAt.compareTo(left.savedAt));

  Future<void> restoreProgramVersion(ProgramVersion version) async {
    final index = _data.templates.indexWhere(
      (template) => template.id == version.templateId,
    );
    if (index < 0) {
      throw const FormatException('Το πρόγραμμα δεν υπάρχει πλέον.');
    }
    final templates = List<WorkoutTemplate>.from(_data.templates);
    final current = templates[index];
    templates[index] = version.snapshot.copyWith(id: current.id);
    final savedVersion = ProgramVersion(
      id: _nextId('version'),
      templateId: current.id,
      savedAt: DateTime.now(),
      snapshot: current,
    );
    _data = _data.copyWith(
      templates: templates,
      programVersions: [savedVersion, ..._data.programVersions],
    );
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> assignTemplateToWeekday(int weekday, String? templateId) async {
    if (weekday < 1 || weekday > 7) {
      throw const FormatException('Μη έγκυρη ημέρα εβδομάδας.');
    }
    if (templateId != null &&
        !_data.templates.any((template) => template.id == templateId)) {
      throw const FormatException('Το πρόγραμμα δεν υπάρχει.');
    }
    final assignments = Map<String, String>.from(_data.weeklyAssignments);
    if (templateId == null) {
      assignments.remove('$weekday');
    } else {
      assignments['$weekday'] = templateId;
    }
    _data = _data.copyWith(weeklyAssignments: assignments);
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> rescheduleWorkout({
    required WorkoutTemplate template,
    required DateTime targetDate,
  }) async {
    final date = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (date.isBefore(todayOnly) ||
        date.isAfter(todayOnly.add(const Duration(days: 14)))) {
      throw const FormatException(
        'Η νέα ημερομηνία πρέπει να είναι μέσα στις επόμενες 14 ημέρες.',
      );
    }
    if (!_data.templates.any((item) => item.id == template.id)) {
      throw const FormatException('Το πρόγραμμα δεν υπάρχει.');
    }
    final key =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    _captureUndo('Μεταφορά χαμένης προπόνησης');
    _data = _data.copyWith(
      dateAssignments: {..._data.dateAssignments, key: template.id},
    );
    await _repository.save(_data);
    await feedback(success: true);
    notifyListeners();
  }

  Future<StrengthTestResult> saveStrengthTest({
    required String exerciseName,
    required double weightKilograms,
    required int reps,
    String protocol = 'amrap',
  }) async {
    if (exerciseName.trim().isEmpty) {
      throw const FormatException('Διάλεξε άσκηση.');
    }
    if (weightKilograms <= 0 || weightKilograms > 600) {
      throw const FormatException('Το βάρος πρέπει να είναι 0–600 kg.');
    }
    if (reps < 1 || reps > 20) {
      throw const FormatException(
        'Για ασφαλή εκτίμηση χρησιμοποίησε 1–20 επαναλήψεις.',
      );
    }
    if (!const {'amrap', 'submax'}.contains(protocol)) {
      throw const FormatException('Μη έγκυρο test protocol.');
    }
    final result = StrengthTestResult(
      id: _nextId('strength-test'),
      exerciseName: exerciseName.trim(),
      weightKilograms: weightKilograms,
      reps: reps,
      estimatedOneRepMax: weightKilograms * (1 + reps / 30),
      protocol: protocol,
      recordedAt: DateTime.now(),
    );
    _data = _data.copyWith(
      strengthTests: [result, ..._data.strengthTests].take(200).toList(),
    );
    await _repository.save(_data);
    await feedback(success: true);
    notifyListeners();
    return result;
  }

  Future<void> saveStrengthTrainingMax(String lift, double kilograms) async {
    final normalizedLift = lift.trim();
    if (!const {
      'Back squat',
      'Bench press',
      'Deadlift',
      'Overhead press',
    }.contains(normalizedLift)) {
      throw const FormatException('Unsupported big lift.');
    }
    if (kilograms < 10 || kilograms > 500) {
      throw const FormatException(
        'Training max must be between 10 and 500 kg.',
      );
    }
    _data = _data.copyWith(
      strengthTrainingMaxes: {
        ..._data.strengthTrainingMaxes,
        normalizedLift: kilograms,
      },
    );
    await _repository.save(_data);
    notifyListeners();
  }

  Future<HypertrophyCheckIn> saveHypertrophyCheckIn({
    required String muscle,
    required int pump,
    required int disruption,
    required int soreness,
  }) async {
    const supportedMuscles = {
      'chest',
      'lats',
      'upper back',
      'shoulders',
      'biceps',
      'triceps',
      'quadriceps',
      'hamstrings',
      'glutes',
      'calves',
      'abs',
    };
    if (!supportedMuscles.contains(muscle)) {
      throw const FormatException('Unsupported muscle group.');
    }
    if ([pump, disruption, soreness].any((value) => value < 1 || value > 5)) {
      throw const FormatException('Pump, disruption and soreness must be 1–5.');
    }
    final result = HypertrophyCheckIn(
      id: _nextId('hypertrophy-check'),
      muscle: muscle,
      pump: pump,
      disruption: disruption,
      soreness: soreness,
      recordedAt: DateTime.now(),
    );
    _data = _data.copyWith(
      hypertrophyCheckIns: [
        result,
        ..._data.hypertrophyCheckIns,
      ].take(500).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<HypertrophyTechniqueLog> saveHypertrophyTechniqueLog({
    required String technique,
    required String exercise,
    required String muscle,
    required double weightKilograms,
    required int activationReps,
    required List<int> miniSetReps,
  }) async {
    const techniques = {'MYO-REPS', 'DROP SET', 'REST-PAUSE'};
    if (!techniques.contains(technique)) {
      throw const FormatException('Unsupported hypertrophy technique.');
    }
    if (exercise.trim().length < 3 || muscle.trim().isEmpty) {
      throw const FormatException('Exercise and muscle are required.');
    }
    if (weightKilograms < 0 || weightKilograms > 400) {
      throw const FormatException('Technique load must be 0–400 kg.');
    }
    if (activationReps < 1 ||
        activationReps > 50 ||
        miniSetReps.isEmpty ||
        miniSetReps.length > 8 ||
        miniSetReps.any((value) => value < 1 || value > 20)) {
      throw const FormatException(
        'Technique repetitions are outside safe bounds.',
      );
    }
    final result = HypertrophyTechniqueLog(
      id: _nextId('hypertrophy-technique'),
      technique: technique,
      exercise: exercise.trim(),
      muscle: muscle.trim(),
      weightKilograms: weightKilograms,
      activationReps: activationReps,
      miniSetReps: List<int>.from(miniSetReps),
      recordedAt: DateTime.now(),
    );
    _data = _data.copyWith(
      hypertrophyTechniqueLogs: [
        result,
        ..._data.hypertrophyTechniqueLogs,
      ].take(500).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<CardioSessionLog> saveCardioSession({
    required String modality,
    required int durationMinutes,
    required int rpe,
    required int averageHeartRate,
    required int targetZone,
    String notes = '',
  }) async {
    if (modality.trim().length < 3) {
      throw const FormatException('Choose a conditioning modality.');
    }
    if (durationMinutes < 5 || durationMinutes > 300) {
      throw const FormatException('Cardio duration must be 5–300 minutes.');
    }
    if (rpe < 1 || rpe > 10) {
      throw const FormatException('Cardio RPE must be 1–10.');
    }
    if (averageHeartRate != 0 &&
        (averageHeartRate < 40 || averageHeartRate > 230)) {
      throw const FormatException('Average heart rate is outside safe bounds.');
    }
    if (targetZone < 1 || targetZone > 5) {
      throw const FormatException('Target heart-rate zone must be 1–5.');
    }
    final result = CardioSessionLog(
      id: _nextId('cardio-session'),
      modality: modality.trim(),
      durationMinutes: durationMinutes,
      rpe: rpe,
      averageHeartRate: averageHeartRate,
      targetZone: targetZone,
      recordedAt: DateTime.now(),
      notes: notes.trim(),
    );
    _data = _data.copyWith(
      cardioSessions: [result, ..._data.cardioSessions].take(1000).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<ConditioningBenchmarkResult> saveConditioningBenchmark({
    required String test,
    required double value,
    required String unit,
    required double score,
    required String label,
  }) async {
    if (test.trim().isEmpty ||
        value <= 0 ||
        value > 10000 ||
        unit.trim().isEmpty ||
        score < 0 ||
        score > 10000 ||
        label.trim().isEmpty) {
      throw const FormatException('Conditioning benchmark is outside bounds.');
    }
    final result = ConditioningBenchmarkResult(
      id: _nextId('conditioning-benchmark'),
      test: test.trim(),
      value: value,
      unit: unit.trim(),
      score: score,
      label: label.trim(),
      recordedAt: DateTime.now(),
    );
    _data = _data.copyWith(
      conditioningBenchmarks: [
        result,
        ..._data.conditioningBenchmarks,
      ].take(500).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<RunningSessionLog> saveRunningSession({
    required double distanceKilometers,
    required int durationSeconds,
    required int rpe,
    required String surface,
    required int elevationGainMeters,
    required int cadenceStepsPerMinute,
    required String shoeId,
    String notes = '',
  }) async {
    if (distanceKilometers <= 0 || distanceKilometers > 200) {
      throw const FormatException('Run distance must be 0–200 km.');
    }
    if (durationSeconds < 60 || durationSeconds > 86400) {
      throw const FormatException('Run duration must be 1 minute to 24 hours.');
    }
    if (rpe < 1 || rpe > 10) {
      throw const FormatException('Run RPE must be 1–10.');
    }
    if (!const {
      'Road',
      'Track',
      'Trail',
      'Treadmill',
      'Mixed',
    }.contains(surface)) {
      throw const FormatException('Unsupported running surface.');
    }
    if (elevationGainMeters < 0 || elevationGainMeters > 10000) {
      throw const FormatException('Elevation gain is outside bounds.');
    }
    if (cadenceStepsPerMinute != 0 &&
        (cadenceStepsPerMinute < 80 || cadenceStepsPerMinute > 240)) {
      throw const FormatException('Cadence is outside 80–240 steps/min.');
    }
    if (shoeId.isNotEmpty &&
        !_data.runningShoes.any((item) => item.id == shoeId)) {
      throw const FormatException('Selected running shoe does not exist.');
    }
    final result = RunningSessionLog(
      id: _nextId('running-session'),
      distanceKilometers: distanceKilometers,
      durationSeconds: durationSeconds,
      rpe: rpe,
      surface: surface,
      elevationGainMeters: elevationGainMeters,
      cadenceStepsPerMinute: cadenceStepsPerMinute,
      shoeId: shoeId,
      recordedAt: DateTime.now(),
      notes: notes.trim(),
    );
    _data = _data.copyWith(
      runningSessions: [result, ..._data.runningSessions].take(2000).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<RunningShoe> saveRunningShoe({
    String id = '',
    required String name,
    double startingKilometers = 0,
    double retirementKilometers = 700,
  }) async {
    if (name.trim().length < 2) {
      throw const FormatException('Running shoe name is required.');
    }
    if (startingKilometers < 0 ||
        startingKilometers > 5000 ||
        retirementKilometers < 100 ||
        retirementKilometers > 5000 ||
        startingKilometers >= retirementKilometers) {
      throw const FormatException('Shoe mileage settings are outside bounds.');
    }
    final result = RunningShoe(
      id: id.isEmpty ? _nextId('running-shoe') : id,
      name: name.trim(),
      startingKilometers: startingKilometers,
      retirementKilometers: retirementKilometers,
      addedAt: DateTime.now(),
    );
    _data = _data.copyWith(
      runningShoes: [
        for (final shoe in _data.runningShoes)
          if (shoe.id != result.id) shoe,
        result,
      ].take(30).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<CyclingSessionLog> saveCyclingSession({
    required int durationMinutes,
    required int averagePowerWatts,
    required int normalizedPowerWatts,
    required int cadenceRpm,
    required int rpe,
    required String workoutType,
    String notes = '',
  }) async {
    if (durationMinutes < 5 || durationMinutes > 720) {
      throw const FormatException('Cycling duration must be 5–720 minutes.');
    }
    if (averagePowerWatts < 1 || averagePowerWatts > 1500) {
      throw const FormatException('Average power is outside 1–1500 W.');
    }
    if (normalizedPowerWatts != 0 &&
        (normalizedPowerWatts < 1 || normalizedPowerWatts > 1800)) {
      throw const FormatException('Normalized power is outside bounds.');
    }
    if (cadenceRpm != 0 && (cadenceRpm < 30 || cadenceRpm > 180)) {
      throw const FormatException('Cycling cadence is outside 30–180 rpm.');
    }
    if (rpe < 1 || rpe > 10) {
      throw const FormatException('Cycling RPE must be 1–10.');
    }
    if (!const {
      'Endurance',
      'Tempo',
      'Threshold',
      'VO2',
      'Recovery',
      'Race',
    }.contains(workoutType)) {
      throw const FormatException('Unsupported cycling workout type.');
    }
    final result = CyclingSessionLog(
      id: _nextId('cycling-session'),
      durationMinutes: durationMinutes,
      averagePowerWatts: averagePowerWatts,
      normalizedPowerWatts: normalizedPowerWatts,
      cadenceRpm: cadenceRpm,
      rpe: rpe,
      workoutType: workoutType,
      recordedAt: DateTime.now(),
      notes: notes.trim(),
    );
    _data = _data.copyWith(
      cyclingSessions: [result, ..._data.cyclingSessions].take(2000).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<RowingSessionLog> saveRowingSession({
    required int distanceMeters,
    required int durationSeconds,
    required int strokeRate,
    required int rpe,
    required String benchmarkType,
    String notes = '',
  }) async {
    if (distanceMeters < 100 || distanceMeters > 100000) {
      throw const FormatException('Rowing distance must be 100–100,000 m.');
    }
    if (durationSeconds < 30 || durationSeconds > 86400) {
      throw const FormatException(
        'Rowing duration must be 30 seconds to 24 hours.',
      );
    }
    if (strokeRate != 0 && (strokeRate < 10 || strokeRate > 60)) {
      throw const FormatException('Stroke rate is outside 10–60 spm.');
    }
    if (rpe < 1 || rpe > 10) {
      throw const FormatException('Rowing RPE must be 1–10.');
    }
    if (!const {
      'Training',
      '500m',
      '2k',
      '5k',
      '30min',
    }.contains(benchmarkType)) {
      throw const FormatException('Unsupported erg benchmark type.');
    }
    final result = RowingSessionLog(
      id: _nextId('rowing-session'),
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      strokeRate: strokeRate,
      rpe: rpe,
      benchmarkType: benchmarkType,
      recordedAt: DateTime.now(),
      notes: notes.trim(),
    );
    _data = _data.copyWith(
      rowingSessions: [result, ..._data.rowingSessions].take(2000).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<CalisthenicsSkillLog> saveCalisthenicsSkillLog({
    required String skillId,
    required String progression,
    required int holdSeconds,
    required int repetitions,
    required int quality,
    required int rpe,
    required int elbowPain,
    required bool straightArm,
    String notes = '',
  }) async {
    const skillIds = {
      'muscle-up',
      'front-lever',
      'back-lever',
      'planche',
      'handstand-push-up',
      'ring-support',
    };
    if (!skillIds.contains(skillId)) {
      throw const FormatException('Unsupported advanced calisthenics skill.');
    }
    if (progression.trim().length < 3) {
      throw const FormatException('A skill progression is required.');
    }
    if (holdSeconds < 0 || holdSeconds > 300) {
      throw const FormatException('Hold must be 0–300 seconds.');
    }
    if (repetitions < 0 || repetitions > 100) {
      throw const FormatException('Repetitions must be 0–100.');
    }
    if (holdSeconds == 0 && repetitions == 0) {
      throw const FormatException('Log a hold or repetitions.');
    }
    if (quality < 1 || quality > 5 || rpe < 1 || rpe > 10) {
      throw const FormatException('Quality or RPE is outside bounds.');
    }
    if (elbowPain < 0 || elbowPain > 5) {
      throw const FormatException('Joint pain must be 0–5.');
    }
    final result = CalisthenicsSkillLog(
      id: _nextId('advanced-skill'),
      skillId: skillId,
      progression: progression.trim(),
      holdSeconds: holdSeconds,
      repetitions: repetitions,
      quality: quality,
      rpe: rpe,
      elbowPain: elbowPain,
      straightArm: straightArm,
      recordedAt: DateTime.now(),
      notes: notes.trim(),
    );
    _data = _data.copyWith(
      calisthenicsSkillLogs: [
        result,
        ..._data.calisthenicsSkillLogs,
      ].take(2000).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<MobilityScreenLog> saveMobilityScreen({
    required String jointId,
    required double leftValue,
    required double rightValue,
    required int painLevel,
    String notes = '',
  }) async {
    const joints = {
      'ankle-dorsiflexion': (0.0, 30.0),
      'hip-internal-rotation': (0.0, 90.0),
      'shoulder-flexion': (0.0, 210.0),
      'thoracic-rotation': (0.0, 100.0),
    };
    final bounds = joints[jointId];
    if (bounds == null) {
      throw const FormatException('Unsupported mobility screen joint.');
    }
    if (leftValue < bounds.$1 ||
        leftValue > bounds.$2 ||
        rightValue < bounds.$1 ||
        rightValue > bounds.$2) {
      throw const FormatException('Mobility measurement is outside bounds.');
    }
    if (painLevel < 0 || painLevel > 5) {
      throw const FormatException('Mobility pain must be 0–5.');
    }
    final result = MobilityScreenLog(
      id: _nextId('mobility-screen'),
      jointId: jointId,
      leftValue: leftValue,
      rightValue: rightValue,
      painLevel: painLevel,
      recordedAt: DateTime.now(),
      notes: notes.trim(),
    );
    _data = _data.copyWith(
      mobilityScreenLogs: [
        result,
        ..._data.mobilityScreenLogs,
      ].take(2000).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<RecoveryInterventionLog> saveRecoveryIntervention({
    required String intervention,
    required int durationMinutes,
    required double temperatureCelsius,
    required int beforeScore,
    required int afterScore,
    String notes = '',
  }) async {
    const supported = {
      'Sauna',
      'Cold exposure',
      'Recovery walk',
      'Mobility',
      'Breathing',
      'Nap',
    };
    if (!supported.contains(intervention)) {
      throw const FormatException('Unsupported recovery intervention.');
    }
    if (durationMinutes < 1 || durationMinutes > 180) {
      throw const FormatException('Duration must be 1–180 minutes.');
    }
    if (beforeScore < 1 ||
        beforeScore > 10 ||
        afterScore < 1 ||
        afterScore > 10) {
      throw const FormatException('Before and after scores must be 1–10.');
    }
    if (intervention == 'Sauna' &&
        (temperatureCelsius < 40 || temperatureCelsius > 120)) {
      throw const FormatException('Sauna temperature must be 40–120°C.');
    }
    if (intervention == 'Cold exposure' &&
        (temperatureCelsius < 0 || temperatureCelsius > 25)) {
      throw const FormatException('Cold-exposure temperature must be 0–25°C.');
    }
    if (!const {'Sauna', 'Cold exposure'}.contains(intervention) &&
        temperatureCelsius != 0) {
      throw const FormatException(
        'Temperature applies only to sauna or cold exposure.',
      );
    }
    final result = RecoveryInterventionLog(
      id: _nextId('recovery-intervention'),
      intervention: intervention,
      durationMinutes: durationMinutes,
      temperatureCelsius: temperatureCelsius,
      beforeScore: beforeScore,
      afterScore: afterScore,
      recordedAt: DateTime.now(),
      notes: notes.trim(),
    );
    _data = _data.copyWith(
      recoveryInterventions: [
        result,
        ..._data.recoveryInterventions,
      ].take(2000).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<NutritionPhaseLog> saveNutritionPhase({
    required String phase,
    required int dailyCalories,
    required int durationWeeks,
    required double targetWeeklyChangePercent,
    DateTime? startedAt,
  }) async {
    const phases = {'Fat loss', 'Maintenance', 'Muscle gain', 'Performance'};
    if (!phases.contains(phase)) {
      throw const FormatException('Unsupported nutrition phase.');
    }
    if (dailyCalories < 1200 || dailyCalories > 5000) {
      throw const FormatException('Daily calories must be 1200–5000.');
    }
    if (durationWeeks < 1 || durationWeeks > 52) {
      throw const FormatException('Phase duration must be 1–52 weeks.');
    }
    if (targetWeeklyChangePercent < -1.5 || targetWeeklyChangePercent > 1.5) {
      throw const FormatException(
        'Weekly target change must stay between -1.5% and +1.5%.',
      );
    }
    final now = DateTime.now();
    final result = NutritionPhaseLog(
      id: _nextId('nutrition-phase'),
      phase: phase,
      dailyCalories: dailyCalories,
      durationWeeks: durationWeeks,
      targetWeeklyChangePercent: targetWeeklyChangePercent,
      startedAt: startedAt ?? now,
      recordedAt: now,
    );
    _data = _data.copyWith(
      nutritionPhaseLogs: [
        result,
        ..._data.nutritionPhaseLogs,
      ].take(200).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<void> duplicateMeal(MealEntry meal) => addMeal(
    name: '${meal.name} • copy',
    calories: meal.calories,
    proteinGrams: meal.proteinGrams,
    carbohydrateGrams: meal.carbohydrateGrams,
    fatGrams: meal.fatGrams,
    fiberGrams: meal.fiberGrams,
    sodiumMilligrams: meal.sodiumMilligrams,
    presetId: meal.presetId,
  );

  Future<PantryItem> savePantryItem({
    required String ingredientId,
    required String name,
    required double quantityGrams,
    required double costPer100Grams,
    DateTime? expiresAt,
  }) async {
    const supported = {
      'chicken-breast',
      'greek-yogurt',
      'eggs',
      'lentils',
      'rice',
      'oats',
      'potato',
      'wholegrain-bread',
      'mixed-vegetables',
      'berries',
      'banana',
      'olive-oil',
      'peanut-butter',
    };
    if (!supported.contains(ingredientId) || name.trim().isEmpty) {
      throw const FormatException('Unsupported pantry ingredient.');
    }
    if (quantityGrams < 0 || quantityGrams > 50000) {
      throw const FormatException('Pantry quantity must be 0–50000g.');
    }
    if (costPer100Grams < 0 || costPer100Grams > 100) {
      throw const FormatException('Ingredient cost is outside bounds.');
    }
    final existing = _data.pantryItems
        .where((item) => item.ingredientId == ingredientId)
        .firstOrNull;
    final result = PantryItem(
      id: existing?.id ?? _nextId('pantry'),
      ingredientId: ingredientId,
      name: name.trim(),
      quantityGrams: quantityGrams,
      costPer100Grams: costPer100Grams,
      updatedAt: DateTime.now(),
      expiresAt: expiresAt,
    );
    _data = _data.copyWith(
      pantryItems: [
        result,
        for (final item in _data.pantryItems)
          if (item.ingredientId != ingredientId) item,
      ].take(200).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<void> removePantryItem(String id) async {
    _data = _data.copyWith(
      pantryItems: _data.pantryItems.where((item) => item.id != id).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> toggleFavoriteIngredient(String ingredientId) async {
    const supported = {
      'chicken-breast',
      'greek-yogurt',
      'eggs',
      'lentils',
      'rice',
      'oats',
      'potato',
      'wholegrain-bread',
      'mixed-vegetables',
      'berries',
      'banana',
      'olive-oil',
      'peanut-butter',
    };
    if (!supported.contains(ingredientId)) {
      throw const FormatException('Unsupported favorite ingredient.');
    }
    final updated = [..._data.favoriteIngredientIds];
    if (updated.contains(ingredientId)) {
      updated.remove(ingredientId);
    } else {
      if (updated.length >= 30) {
        throw const FormatException('Favorite ingredient limit reached.');
      }
      updated.add(ingredientId);
    }
    _data = _data.copyWith(favoriteIngredientIds: updated);
    await _repository.save(_data);
    notifyListeners();
  }

  Future<BodyMeasurementLog> saveBodyMeasurement({
    required double weightKilograms,
    required double waistCentimeters,
    required double neckCentimeters,
    required double chestCentimeters,
    required double hipsCentimeters,
    required double upperArmCentimeters,
    required double thighCentimeters,
    String notes = '',
  }) async {
    if (weightKilograms < 20 || weightKilograms > 400) {
      throw const FormatException('Weight must be 20–400kg.');
    }
    for (final measurement in [
      waistCentimeters,
      neckCentimeters,
      chestCentimeters,
      hipsCentimeters,
      upperArmCentimeters,
      thighCentimeters,
    ]) {
      if (measurement != 0 && (measurement < 10 || measurement > 300)) {
        throw const FormatException(
          'Body measurements must be 10–300cm or zero when omitted.',
        );
      }
    }
    if (waistCentimeters == 0) {
      throw const FormatException('Waist measurement is required.');
    }
    final now = DateTime.now();
    final result = BodyMeasurementLog(
      id: _nextId('body-measurement'),
      weightKilograms: weightKilograms,
      waistCentimeters: waistCentimeters,
      neckCentimeters: neckCentimeters,
      chestCentimeters: chestCentimeters,
      hipsCentimeters: hipsCentimeters,
      upperArmCentimeters: upperArmCentimeters,
      thighCentimeters: thighCentimeters,
      recordedAt: now,
      notes: notes.trim(),
    );
    _data = _data.copyWith(
      bodyMeasurementLogs: [
        result,
        ..._data.bodyMeasurementLogs,
      ].take(1000).toList(),
      weights: [
        WeightEntry(kilograms: weightKilograms, recordedAt: now),
        ..._data.weights,
      ].take(5000).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<HealthHabit> saveHealthHabit({
    String? id,
    required String name,
    required String category,
    required int targetDaysPerWeek,
    required String minimumVersion,
    required String stackAfter,
    required int preferredMinutesSinceMidnight,
    bool active = true,
  }) async {
    const categories = {'Movement', 'Nutrition', 'Recovery', 'Mindset'};
    final trimmedName = name.trim();
    if (trimmedName.length < 3 || trimmedName.length > 60) {
      throw const FormatException('Habit name must be 3–60 characters.');
    }
    if (!categories.contains(category)) {
      throw const FormatException('Unsupported habit category.');
    }
    if (targetDaysPerWeek < 1 || targetDaysPerWeek > 7) {
      throw const FormatException('Weekly target must be 1–7 days.');
    }
    if (minimumVersion.trim().isEmpty || minimumVersion.trim().length > 100) {
      throw const FormatException(
        'Add a minimum version under 100 characters.',
      );
    }
    if (stackAfter.trim().length > 100) {
      throw const FormatException(
        'Habit anchor must stay under 100 characters.',
      );
    }
    if (preferredMinutesSinceMidnight < 0 ||
        preferredMinutesSinceMidnight >= 1440) {
      throw const FormatException('Habit time is outside the day.');
    }
    final habitId = id ?? _nextId('health-habit');
    final duplicate = _data.healthHabits.any(
      (item) =>
          item.id != habitId &&
          item.name.trim().toLowerCase() == trimmedName.toLowerCase(),
    );
    if (duplicate) {
      throw const FormatException('A habit with this name already exists.');
    }
    final existing = _data.healthHabits
        .where((item) => item.id == habitId)
        .firstOrNull;
    final result = HealthHabit(
      id: habitId,
      name: trimmedName,
      category: category,
      targetDaysPerWeek: targetDaysPerWeek,
      minimumVersion: minimumVersion.trim(),
      stackAfter: stackAfter.trim(),
      preferredMinutesSinceMidnight: preferredMinutesSinceMidnight,
      createdAt: existing?.createdAt ?? DateTime.now(),
      active: active,
    );
    _data = _data.copyWith(
      healthHabits: [
        result,
        for (final item in _data.healthHabits)
          if (item.id != habitId) item,
      ].take(50).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<void> removeHealthHabit(String id) async {
    if (!_data.healthHabits.any((item) => item.id == id)) return;
    _captureUndo('Delete health habit');
    _data = _data.copyWith(
      healthHabits: _data.healthHabits.where((item) => item.id != id).toList(),
      habitCheckIns: _data.habitCheckIns
          .where((item) => item.habitId != id)
          .toList(),
    );
    await _repository.save(_data);
    notifyListeners();
  }

  Future<HabitCheckIn> saveHabitCheckIn({
    required String habitId,
    required DateTime day,
    required bool completed,
    required bool usedMinimum,
    required int frictionLevel,
    String reflection = '',
  }) async {
    if (!_data.healthHabits.any((item) => item.id == habitId)) {
      throw const FormatException('Habit does not exist.');
    }
    if (completed && usedMinimum) {
      throw const FormatException(
        'Choose either a full repetition or a minimum day.',
      );
    }
    if (frictionLevel < 0 || frictionLevel > 5) {
      throw const FormatException('Friction must be 0–5.');
    }
    if (reflection.trim().length > 300) {
      throw const FormatException('Reflection must stay under 300 characters.');
    }
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final existing = _data.habitCheckIns
        .where(
          (item) =>
              item.habitId == habitId &&
              item.day.year == normalizedDay.year &&
              item.day.month == normalizedDay.month &&
              item.day.day == normalizedDay.day,
        )
        .firstOrNull;
    final result = HabitCheckIn(
      id: existing?.id ?? _nextId('habit-check-in'),
      habitId: habitId,
      day: normalizedDay,
      completed: completed,
      usedMinimum: usedMinimum,
      frictionLevel: frictionLevel,
      reflection: reflection.trim(),
      recordedAt: DateTime.now(),
    );
    _data = _data.copyWith(
      habitCheckIns: [
        result,
        for (final item in _data.habitCheckIns)
          if (item.id != existing?.id) item,
      ].take(10000).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<SleepRoutineLog> saveSleepRoutine({
    required DateTime day,
    required int bedtimeMinutes,
    required int wakeMinutes,
    required int lastCaffeineMinutes,
    required int screenFreeMinutes,
    required List<String> windDownSteps,
  }) async {
    for (final value in [bedtimeMinutes, wakeMinutes, lastCaffeineMinutes]) {
      if (value < 0 || value >= 1440) {
        throw const FormatException('Sleep schedule time is outside the day.');
      }
    }
    if (screenFreeMinutes < 0 || screenFreeMinutes > 240) {
      throw const FormatException('Screen-free time must be 0–240 minutes.');
    }
    final steps = windDownSteps
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .take(8)
        .toList();
    final normalized = DateTime(day.year, day.month, day.day);
    final existing = _data.sleepRoutineLogs
        .where(
          (item) =>
              item.day.year == normalized.year &&
              item.day.month == normalized.month &&
              item.day.day == normalized.day,
        )
        .firstOrNull;
    final result = SleepRoutineLog(
      id: existing?.id ?? _nextId('sleep-routine'),
      day: normalized,
      bedtimeMinutes: bedtimeMinutes,
      wakeMinutes: wakeMinutes,
      lastCaffeineMinutes: lastCaffeineMinutes,
      screenFreeMinutes: screenFreeMinutes,
      windDownSteps: steps,
      recordedAt: DateTime.now(),
    );
    _data = _data.copyWith(
      sleepRoutineLogs: [
        result,
        for (final item in _data.sleepRoutineLogs)
          if (item.id != existing?.id) item,
      ].take(2000).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<StressCheckInLog> saveStressCheckIn({
    required int level,
    String context = '',
    DateTime? recordedAt,
  }) async {
    if (level < 1 || level > 5) {
      throw const FormatException('Stress level must be 1–5.');
    }
    if (context.trim().length > 160) {
      throw const FormatException(
        'Stress context must stay under 160 characters.',
      );
    }
    final result = StressCheckInLog(
      id: _nextId('stress-check-in'),
      level: level,
      context: context.trim(),
      recordedAt: recordedAt ?? DateTime.now(),
    );
    _data = _data.copyWith(
      stressCheckInLogs: [
        result,
        ..._data.stressCheckInLogs,
      ].take(5000).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<CoachRecommendationFeedback> saveCoachRecommendationFeedback({
    required String recommendationId,
    required bool accepted,
    required bool helpful,
    String note = '',
  }) async {
    final recommendation = recommendationId.trim();
    if (recommendation.isEmpty || recommendation.length > 80) {
      throw const FormatException('Recommendation ID is invalid.');
    }
    if (note.trim().length > 240) {
      throw const FormatException(
        'Coach feedback must stay under 240 characters.',
      );
    }
    final result = CoachRecommendationFeedback(
      id: _nextId('coach-feedback'),
      recommendationId: recommendation,
      accepted: accepted,
      helpful: helpful,
      note: note.trim(),
      recordedAt: DateTime.now(),
    );
    _data = _data.copyWith(
      coachRecommendationFeedback: [
        result,
        ..._data.coachRecommendationFeedback,
      ].take(5000).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<void> setAnalyticsDashboardMetrics(List<String> metricIds) async {
    const supported = {
      'sessions',
      'volume',
      'readiness',
      'bodyweight',
      'duration',
      'set-count',
    };
    final metrics = metricIds
        .where(supported.contains)
        .toSet()
        .take(6)
        .toList();
    if (metrics.isEmpty) {
      throw const FormatException('Select at least one dashboard metric.');
    }
    _data = _data.copyWith(analyticsDashboardMetrics: metrics);
    await _repository.save(_data);
    notifyListeners();
  }

  Future<AnalyticsAnnotation> saveAnalyticsAnnotation({
    required DateTime date,
    required String category,
    required String label,
    String note = '',
  }) async {
    const categories = {'Training', 'Recovery', 'Nutrition', 'Life'};
    if (!categories.contains(category)) {
      throw const FormatException('Unsupported annotation category.');
    }
    if (label.trim().length < 2 || label.trim().length > 60) {
      throw const FormatException('Annotation label must be 2–60 characters.');
    }
    if (note.trim().length > 240) {
      throw const FormatException(
        'Annotation note must stay under 240 characters.',
      );
    }
    final result = AnalyticsAnnotation(
      id: _nextId('analytics-annotation'),
      date: DateTime(date.year, date.month, date.day),
      category: category,
      label: label.trim(),
      note: note.trim(),
      recordedAt: DateTime.now(),
    );
    _data = _data.copyWith(
      analyticsAnnotations: [
        result,
        ..._data.analyticsAnnotations,
      ].take(2000).toList(),
    );
    await _repository.save(_data);
    notifyListeners();
    return result;
  }

  Future<void> removeAnalyticsAnnotation(String id) async {
    _data = _data.copyWith(
      analyticsAnnotations: _data.analyticsAnnotations
          .where((item) => item.id != id)
          .toList(),
    );
    await _repository.save(_data);
    notifyListeners();
  }

  Future<SkillAssessmentResult> saveSkillAssessment({
    required String skillId,
    required double value,
    required String unit,
    required int level,
  }) async {
    const skillIds = {
      'pull-up',
      'push-up',
      'handstand',
      'l-sit',
      'hollow-hold',
      'mobility-overhead',
      'mobility-squat',
      'false-grip',
      'ring-support',
    };
    if (!skillIds.contains(skillId)) {
      throw const FormatException('Μη έγκυρο calisthenics assessment.');
    }
    if (value < 0 || value > 1000) {
      throw const FormatException('Η τιμή assessment είναι εκτός ορίων.');
    }
    if (!const {'reps', 'seconds', 'score'}.contains(unit)) {
      throw const FormatException('Μη έγκυρη μονάδα assessment.');
    }
    if (level < 0 || level > 5) {
      throw const FormatException('Το επίπεδο πρέπει να είναι 0–5.');
    }
    final result = SkillAssessmentResult(
      id: _nextId('skill-assessment'),
      skillId: skillId,
      value: value,
      unit: unit,
      level: level,
      recordedAt: DateTime.now(),
    );
    _data = _data.copyWith(
      skillAssessments: [result, ..._data.skillAssessments].take(500).toList(),
    );
    await _repository.save(_data);
    await feedback(success: true);
    notifyListeners();
    return result;
  }

  Future<void> updateWorkoutTemplate(WorkoutTemplate template) async {
    final name = template.name.trim();
    if (name.isEmpty) {
      throw const FormatException('Το πρόγραμμα χρειάζεται όνομα.');
    }
    if (template.exercises.isEmpty || template.exercises.length > 12) {
      throw const FormatException('Το πρόγραμμα πρέπει να έχει 1–12 ασκήσεις.');
    }
    if (template.exercises.toSet().length != template.exercises.length) {
      throw const FormatException(
        'Η ίδια άσκηση δεν μπορεί να εμφανίζεται δύο φορές.',
      );
    }
    for (final block in template.blocks) {
      if (block.exercises.length < 2 ||
          block.exercises.any(
            (exercise) => !template.exercises.contains(exercise),
          )) {
        throw const FormatException(
          'Κάθε superset ή circuit χρειάζεται τουλάχιστον 2 έγκυρες ασκήσεις.',
        );
      }
    }
    final index = _data.templates.indexWhere((item) => item.id == template.id);
    final templates = List<WorkoutTemplate>.from(_data.templates);
    var versions = _data.programVersions;
    if (index < 0) {
      if (!template.id.startsWith('custom-') || templates.length >= 30) {
        throw const FormatException(
          'Δεν μπορεί να προστεθεί αυτό το πρόγραμμα.',
        );
      }
      templates.add(template.copyWith(name: name));
    } else {
      final previous = templates[index];
      if (jsonEncode(previous.toJson()) != jsonEncode(template.toJson())) {
        final version = ProgramVersion(
          id: _nextId('version'),
          templateId: previous.id,
          savedAt: DateTime.now(),
          snapshot: previous,
        );
        final sameTemplateVersions = <ProgramVersion>[
          version,
          ..._data.programVersions.where(
            (item) => item.templateId == previous.id,
          ),
        ].take(20).toList();
        versions = [
          ...sameTemplateVersions,
          ..._data.programVersions.where(
            (item) => item.templateId != previous.id,
          ),
        ].take(200).toList();
      }
      templates[index] = template.copyWith(name: name);
    }
    _data = _data.copyWith(templates: templates, programVersions: versions);
    await _repository.save(_data);
    notifyListeners();
  }

  String exportBackup() {
    return const JsonEncoder.withIndent('  ').convert({
      'app': 'Phoenix',
      'schemaVersion': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'data': _data.toJson(),
    });
  }

  Future<void> restoreBackup(String encoded) async {
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Το backup δεν είναι έγκυρο JSON αντικείμενο.',
        );
      }
      final dataJson = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;
      final restored = FitnessData.fromJson(dataJson);
      if (restored.templates.isEmpty) {
        throw const FormatException('Το backup δεν περιέχει προγράμματα.');
      }
      _data = restored;
      _activeWorkout = null;
      _activeSince = null;
      _activeSets.clear();
      _undoData = null;
      _undoLabel = '';
      _vaultUnlocked = !restored.preferences.hasVaultPin;
      await _repository.save(_data);
      notifyListeners();
    } on FormatException {
      rethrow;
    } on Object {
      throw const FormatException('Το backup είναι κατεστραμμένο ή ασύμβατο.');
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    _validateProfile(profile);

    _data = _data.copyWith(
      profile: profile,
      templates: _recommendedTemplates(profile),
      weights: [
        WeightEntry(
          kilograms: profile.weightKilograms,
          recordedAt: DateTime.now(),
        ),
        ..._data.weights,
      ],
    );
    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> updateProfile(
    UserProfile profile, {
    bool refreshCorePrograms = false,
  }) async {
    _validateProfile(profile);
    var templates = _data.templates;
    if (refreshCorePrograms) {
      final customTemplates = templates
          .where((template) => template.id.startsWith('custom-'))
          .toList();
      templates = [..._recommendedTemplates(profile), ...customTemplates];
    }
    _data = _data.copyWith(profile: profile, templates: templates);
    await _repository.save(_data);
    await feedback(success: true);
    notifyListeners();
  }

  void _validateProfile(UserProfile profile) {
    if (profile.daysPerWeek < 1 || profile.daysPerWeek > 7) {
      throw const FormatException('Οι ημέρες πρέπει να είναι από 1 έως 7.');
    }
    if (profile.heightCentimeters < 100 || profile.heightCentimeters > 250) {
      throw const FormatException('Το ύψος πρέπει να είναι 100–250 cm.');
    }
    if (profile.weightKilograms < 20 || profile.weightKilograms > 400) {
      throw const FormatException('Το βάρος πρέπει να είναι 20–400 kg.');
    }
    if (profile.age != null && (profile.age! < 13 || profile.age! > 100)) {
      throw const FormatException('Η ηλικία πρέπει να είναι 13–100.');
    }
    if (profile.sessionMinutes < 20 || profile.sessionMinutes > 120) {
      throw const FormatException(
        'Η διάρκεια προπόνησης πρέπει να είναι 20–120 λεπτά.',
      );
    }
  }

  List<WorkoutTemplate> _recommendedTemplates(UserProfile profile) {
    final isHome = profile.trainingPlace == 'Σπίτι';
    final isBeginner = profile.experienceLevel == 'Αρχάριος';
    final isStrengthGoal = profile.goal == 'Δύναμη';
    final equipment = profile.equipment.toLowerCase();
    final hasPullUpBar =
        !isHome ||
        equipment.contains('μονόζυγ') ||
        equipment.contains('pull-up') ||
        equipment.contains('μπάρα');
    final hasExternalLoad =
        !isHome ||
        equipment.contains('αλτήρ') ||
        equipment.contains('βάρη') ||
        equipment.contains('kettlebell');
    final workPrescription = isStrengthGoal
        ? '3 σετ × 5–8 • RIR 1–2 • 2′–3′ διάλειμμα'
        : '3–4 σετ × 6–12 • RIR 1–2 • 90″–2′ διάλειμμα';
    final workRest = isStrengthGoal ? 150 : 120;
    const technicalStop =
        'Τεχνικό stop: σταμάτα μόλις χαθεί η σταθερότητα ή το πλήρες εύρος.';

    List<String> fitToDuration(List<String> exercises) {
      final count = profile.sessionMinutes <= 30
          ? 4
          : profile.sessionMinutes < 60
          ? 5
          : 6;
      return exercises.take(count).toList();
    }

    WorkoutTemplate program({
      required String id,
      required String name,
      required List<String> exercises,
      String? prescription,
      String coachingCue = technicalStop,
      int? restSeconds,
    }) {
      final fittedExercises = fitToDuration(exercises);
      return WorkoutTemplate(
        id: id,
        name: name,
        exercises: fittedExercises,
        prescription: prescription ?? workPrescription,
        coachingCue: coachingCue,
        restSeconds: restSeconds ?? workRest,
        exercisePrescriptions: TrainingProgramEngine.prescriptionsFor(
          fittedExercises,
          goal: profile.goal,
          experienceLevel: profile.experienceLevel,
          templateId: id,
        ),
      );
    }

    final upperExercises = isHome
        ? [
            isBeginner
                ? 'Κάμψεις σε υπερυψωμένη επιφάνεια'
                : 'Κάμψεις με παύση 1″',
            hasPullUpBar
                ? (isBeginner ? 'Υποβοηθούμενες έλξεις' : 'Αυστηρές έλξεις')
                : 'Κωπηλατική με λάστιχο — αργό tempo',
            isBeginner ? 'Πιέσεις ώμων με λάστιχο' : 'Pike push-ups',
            hasExternalLoad
                ? 'Μονόχειρη κωπηλατική με αλτήρα'
                : 'Μονόχειρη κωπηλατική με σακίδιο',
            'Band face pulls',
            hasExternalLoad
                ? 'Suitcase carry με αλτήρα'
                : 'Suitcase carry με σακίδιο',
          ]
        : [
            'Πιέσεις στήθους με αλτήρες',
            isBeginner ? 'Έλξεις τροχαλίας ουδέτερη λαβή' : 'Αυστηρές έλξεις',
            'Κωπηλατική με στήριξη στήθους',
            'Landmine press',
            'Face pulls',
            'Farmer carry',
          ];
    final lowerExercises = isHome
        ? [
            isBeginner
                ? 'Καθίσματα σε πάγκο με σακίδιο'
                : 'Goblet squat με tempo 3″',
            hasExternalLoad
                ? 'Ρουμανικές άρσεις με αλτήρες'
                : 'Ρουμανικές άρσεις με σακίδιο',
            isBeginner
                ? 'Ανάστροφες προβολές με στήριξη'
                : 'Bulgarian split squat',
            'Hip thrust με παύση',
            'Μονόποδες άρσεις γάμπας',
            'Dead bug',
          ]
        : [
            isBeginner ? 'Goblet squat σε πάγκο' : 'Front squat με safety bars',
            'Ρουμανικές άρσεις με αλτήρες',
            isBeginner
                ? 'Ανάστροφες προβολές με στήριξη'
                : 'Bulgarian split squat',
            'Hip thrust με παύση',
            'Άρσεις γάμπας',
            'Pallof press',
          ];
    final hybridExercises = isHome
        ? [
            lowerExercises.first,
            upperExercises.first,
            upperExercises[1],
            lowerExercises[1],
            upperExercises.last,
            'Hollow body hold',
          ]
        : [
            isBeginner
                ? 'Trap-bar deadlift από υπερύψωση'
                : 'Trap-bar deadlift',
            'Πιέσεις στήθους με αλτήρες',
            'Κωπηλατική με στήριξη στήθους',
            'Bulgarian split squat',
            'Farmer carry',
            'Hollow body hold',
          ];
    final calisthenicsExercises = isBeginner
        ? [
            'Κάμψεις σε υπερυψωμένη επιφάνεια',
            hasPullUpBar ? 'Υποβοηθούμενες έλξεις' : 'Κωπηλατική με λάστιχο',
            'Κάμψεις κλειστής λαβής',
            'Bulgarian split squat με στήριξη',
            'Dead bug',
            'Hollow body hold',
          ]
        : [
            'Κάμψεις με παύση 1″',
            hasPullUpBar
                ? 'Αυστηρές έλξεις'
                : 'Κωπηλατική με λάστιχο — tempo 3″',
            'Pike push-ups',
            'Pistol squat σε κουτί',
            'Hanging knee raises',
            'Hollow body hold',
          ];
    final engineExercises = isHome
        ? [
            'Step-ups σε σταθερό πάγκο',
            hasExternalLoad
                ? 'Farmer carry με αλτήρες'
                : 'March με φορτωμένο σακίδιο',
            'Bear crawl αργού ρυθμού',
            'Mountain climbers ελεγχόμενα',
            'Pallof press με λάστιχο',
          ]
        : [
            'Sled push',
            'Κωπηλατικό εργόμετρο',
            'Farmer carry',
            'Step-ups',
            'Air bike',
          ];

    final upper = program(
      id: 'iron-upper',
      name: 'IRON UPPER — Strength',
      exercises: upperExercises,
    );
    final lower = program(
      id: 'iron-lower',
      name: 'IRON LOWER — Strength',
      exercises: lowerExercises,
    );
    final hybrid = program(
      id: 'iron-hybrid',
      name: 'IRON HYBRID — Full Body',
      exercises: hybridExercises,
    );
    final calisthenicsStrength = program(
      id: 'calisthenics-strength',
      name: 'CALISTHENICS — Strict Strength',
      exercises: calisthenicsExercises,
      prescription: isBeginner
          ? '3 σετ × 6–10 • RIR 2 • 90″ διάλειμμα'
          : '3–4 σετ × 5–10 • RIR 1–2 • 2′ διάλειμμα',
      restSeconds: isBeginner ? 90 : 120,
      coachingCue: 'Μηδέν κλέψιμο: πλήρης έλεγχος και τεχνικό stop.',
    );
    final calisthenicsSkill = program(
      id: 'calisthenics-skills',
      name: 'CALISTHENICS — Skill Lab',
      exercises: [
        'Handstand στον τοίχο',
        'Scapular pull-ups',
        'Tuck L-sit',
        'Arch body hold',
      ],
      prescription: '4–6 ποιοτικές προσπάθειες • ποτέ μέχρι αποτυχία',
      coachingCue: 'Σταμάτα πριν τρέμει η τεχνική· ποιότητα πάνω από χρόνο.',
      restSeconds: 90,
    );
    final ironEngine = program(
      id: 'iron-engine',
      name: 'IRON ENGINE — Conditioning',
      exercises: engineExercises,
      prescription: '4 γύροι • 40″ δουλειά / 20″ αλλαγή • RPE 7–8',
      coachingCue: 'Σταθερός ρυθμός και καθαρές κινήσεις· κανένα άλμα.',
      restSeconds: 60,
    );
    final weightedCalisthenics = program(
      id: 'weighted-calisthenics',
      name: 'WEIGHTED CALISTHENICS',
      exercises: [
        'Έλξεις με βάρος',
        'Βυθίσεις με βάρος — ελεγχόμενο βάθος',
        'Κάμψεις με βάρος',
        'Bulgarian split squat με αλτήρες',
        'Hanging leg raises',
      ],
      prescription: '3–4 σετ × 4–8 • RIR 1–2 • 2′–3′ διάλειμμα',
      coachingCue:
          'Πρόσθεσε βάρος μόνο όταν όλες οι επαναλήψεις είναι αυστηρές.',
      restSeconds: 150,
    );

    if (profile.daysPerWeek <= 2) {
      return [
        program(
          id: 'full-body-a',
          name: 'IRON FULL BODY — A',
          exercises: [
            lowerExercises.first,
            upperExercises.first,
            upperExercises[1],
            lowerExercises[1],
            upperExercises.last,
            'Dead bug',
          ],
        ),
        program(
          id: 'full-body-b',
          name: 'IRON FULL BODY — B',
          exercises: [
            lowerExercises[2],
            upperExercises[2],
            upperExercises[3],
            lowerExercises[3],
            'Pallof press',
            'Hollow body hold',
          ],
        ),
        calisthenicsSkill,
      ];
    }
    return [
      upper,
      lower,
      hybrid,
      calisthenicsStrength,
      calisthenicsSkill,
      ironEngine,
      if (!isBeginner && hasPullUpBar) weightedCalisthenics,
    ];
  }

  String _normalizeSpotifyUrl(String input) {
    final value = input.trim();
    if (value.startsWith('spotify:')) {
      final parts = value.split(':');
      if (parts.length == 3 &&
          const {'playlist', 'album', 'track'}.contains(parts[1]) &&
          parts[2].isNotEmpty) {
        return 'https://open.spotify.com/${parts[1]}/${parts[2]}';
      }
    }
    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host != 'open.spotify.com' ||
        uri.pathSegments.length < 2 ||
        !const {
          'playlist',
          'album',
          'track',
        }.contains(uri.pathSegments.first)) {
      throw const FormatException(
        'Χρησιμοποίησε σύνδεσμο Spotify playlist, album ή track.',
      );
    }
    return Uri(
      scheme: 'https',
      host: 'open.spotify.com',
      pathSegments: uri.pathSegments.take(2),
    ).toString();
  }
}
