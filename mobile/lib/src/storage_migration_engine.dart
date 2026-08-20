import 'dart:convert';

class StorageMigrationResult {
  const StorageMigrationResult({
    required this.json,
    required this.fromVersion,
    required this.toVersion,
    required this.appliedSteps,
  });

  final Map<String, dynamic> json;
  final int fromVersion;
  final int toVersion;
  final List<String> appliedSteps;
}

class StorageMigrationEngine {
  const StorageMigrationEngine._();

  static const currentVersion = 20;

  static StorageMigrationResult migrate(
    Map<String, dynamic> source, {
    required int fromVersion,
  }) {
    if (fromVersion < 1 || fromVersion > currentVersion) {
      throw FormatException(
        'Unsupported Phoenix storage version $fromVersion.',
      );
    }
    final json = jsonDecode(jsonEncode(source)) as Map<String, dynamic>;
    final steps = <String>[];
    if (fromVersion < 2) {
      json.putIfAbsent('preferences', () => <String, dynamic>{});
      json.putIfAbsent('dateAssignments', () => <String, dynamic>{});
      json.putIfAbsent('strengthTests', () => <dynamic>[]);
      steps.add('v1→v2 experience, security and coaching fields');
    }
    if (fromVersion < 3) {
      json.putIfAbsent('skillAssessments', () => <dynamic>[]);
      json.putIfAbsent('progressPhotos', () => <dynamic>[]);
      json.putIfAbsent('workoutPlaylists', () => <String, dynamic>{});
      json.putIfAbsent('exerciseVideoUrls', () => <String, dynamic>{});
      json.putIfAbsent('spotifyAuth', () => <String, dynamic>{});
      json.putIfAbsent('wearableSummaries', () => <dynamic>[]);
      json.putIfAbsent('workoutReminders', () => <dynamic>[]);
      steps.add('v2→v3 calisthenics, media and reliability fields');
    }
    if (fromVersion < 4) {
      json.putIfAbsent('customExercises', () => <dynamic>[]);
      steps.add('v3→v4 exercise intelligence fields');
    }
    if (fromVersion < 5) {
      json.putIfAbsent('strengthTrainingMaxes', () => <String, dynamic>{});
      steps.add('v4→v5 strength lab fields');
    }
    if (fromVersion < 6) {
      json.putIfAbsent('hypertrophyCheckIns', () => <dynamic>[]);
      json.putIfAbsent('hypertrophyTechniqueLogs', () => <dynamic>[]);
      steps.add('v5→v6 hypertrophy lab fields');
    }
    if (fromVersion < 7) {
      json.putIfAbsent('cardioSessions', () => <dynamic>[]);
      json.putIfAbsent('conditioningBenchmarks', () => <dynamic>[]);
      steps.add('v6→v7 conditioning lab fields');
    }
    if (fromVersion < 8) {
      json.putIfAbsent('runningSessions', () => <dynamic>[]);
      json.putIfAbsent('runningShoes', () => <dynamic>[]);
      steps.add('v7→v8 running lab fields');
    }
    if (fromVersion < 9) {
      json.putIfAbsent('cyclingSessions', () => <dynamic>[]);
      json.putIfAbsent('rowingSessions', () => <dynamic>[]);
      steps.add('v8→v9 cycling and rowing lab fields');
    }
    if (fromVersion < 10) {
      json.putIfAbsent('calisthenicsSkillLogs', () => <dynamic>[]);
      steps.add('v9→v10 advanced calisthenics fields');
    }
    if (fromVersion < 11) {
      json.putIfAbsent('mobilityScreenLogs', () => <dynamic>[]);
      steps.add('v10→v11 mobility intelligence fields');
    }
    if (fromVersion < 12) {
      json.putIfAbsent('recoveryInterventions', () => <dynamic>[]);
      steps.add('v11→v12 recovery intelligence fields');
    }
    if (fromVersion < 13) {
      json.putIfAbsent('nutritionPhaseLogs', () => <dynamic>[]);
      steps.add('v12→v13 nutrition planner fields');
    }
    if (fromVersion < 14) {
      json.putIfAbsent('pantryItems', () => <dynamic>[]);
      json.putIfAbsent('favoriteIngredientIds', () => <dynamic>[]);
      steps.add('v13→v14 meal intelligence fields');
    }
    if (fromVersion < 15) {
      json.putIfAbsent('bodyMeasurementLogs', () => <dynamic>[]);
      steps.add('v14→v15 body composition fields');
    }
    if (fromVersion < 16) {
      json.putIfAbsent('healthHabits', () => <dynamic>[]);
      json.putIfAbsent('habitCheckIns', () => <dynamic>[]);
      steps.add('v15→v16 habit builder fields');
    }
    if (fromVersion < 17) {
      json.putIfAbsent('sleepRoutineLogs', () => <dynamic>[]);
      json.putIfAbsent('stressCheckInLogs', () => <dynamic>[]);
      steps.add('v16→v17 sleep and stress fields');
    }
    if (fromVersion < 18) {
      json.putIfAbsent('coachRecommendationFeedback', () => <dynamic>[]);
      steps.add('v17→v18 advanced coach fields');
    }
    if (fromVersion < 19) {
      json.putIfAbsent(
        'analyticsDashboardMetrics',
        () => <String>['sessions', 'volume', 'readiness', 'bodyweight'],
      );
      json.putIfAbsent('analyticsAnnotations', () => <dynamic>[]);
      steps.add('v18→v19 analytics studio fields');
    }
    if (fromVersion < 20) {
      final preferences = Map<String, dynamic>.from(
        json['preferences'] as Map<String, dynamic>? ?? const {},
      );
      preferences.putIfAbsent('nutritionDietStyle', () => 'balanced');
      preferences.putIfAbsent('nutritionMealsPerDay', () => 4);
      preferences.putIfAbsent('nutritionBudgetMode', () => 'standard');
      preferences.putIfAbsent('nutritionQuickPrep', () => true);
      json['preferences'] = preferences;
      steps.add('v19→v20 recommended nutrition preferences');
    }
    return StorageMigrationResult(
      json: json,
      fromVersion: fromVersion,
      toVersion: currentVersion,
      appliedSteps: steps,
    );
  }
}
