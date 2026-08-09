import 'models/fitness_models.dart';

enum ValidationSeverity { info, warning, critical }

class ValidationIssue {
  const ValidationIssue({
    required this.code,
    required this.title,
    required this.detail,
    required this.severity,
    required this.repairable,
  });

  final String code;
  final String title;
  final String detail;
  final ValidationSeverity severity;
  final bool repairable;
}

class DataValidationReport {
  const DataValidationReport({
    required this.issues,
    required this.checkedRecords,
  });

  final List<ValidationIssue> issues;
  final int checkedRecords;

  int get criticalCount => issues
      .where((issue) => issue.severity == ValidationSeverity.critical)
      .length;
  int get warningCount => issues
      .where((issue) => issue.severity == ValidationSeverity.warning)
      .length;
  int get integrityScore =>
      (100 - criticalCount * 20 - warningCount * 7).clamp(0, 100);
  bool get isHealthy => criticalCount == 0 && warningCount == 0;
  bool get hasRepairableIssues => issues.any((issue) => issue.repairable);
}

class DataValidationEngine {
  const DataValidationEngine._();

  static const _supportedIngredientIds = {
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
  static const _analyticsMetrics = {
    'sessions',
    'volume',
    'readiness',
    'bodyweight',
    'duration',
    'set-count',
  };

  static DataValidationReport audit(FitnessData data) {
    final issues = <ValidationIssue>[];
    final templateIds = <String>{};
    for (final template in data.templates) {
      if (!templateIds.add(template.id)) {
        issues.add(
          const ValidationIssue(
            code: 'duplicate-template',
            title: 'Διπλό αναγνωριστικό προγράμματος',
            detail: 'Δύο προγράμματα μοιράζονται το ίδιο εσωτερικό ID.',
            severity: ValidationSeverity.critical,
            repairable: true,
          ),
        );
      }
      if (template.name.trim().isEmpty || template.exercises.isEmpty) {
        issues.add(
          ValidationIssue(
            code: 'empty-template',
            title: 'Μη ολοκληρωμένο πρόγραμμα',
            detail: 'Το ${template.id} δεν έχει όνομα ή ασκήσεις.',
            severity: ValidationSeverity.critical,
            repairable: true,
          ),
        );
      }
      if (template.exercises.toSet().length != template.exercises.length) {
        issues.add(
          ValidationIssue(
            code: 'duplicate-exercise',
            title: 'Διπλή άσκηση',
            detail: 'Το ${template.name} περιέχει επαναλαμβανόμενες ασκήσεις.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
      if (template.restSeconds < 10 || template.restSeconds > 900) {
        issues.add(
          ValidationIssue(
            code: 'invalid-rest',
            title: 'Μη έγκυρο διάλειμμα',
            detail: 'Το ${template.name} έχει διάλειμμα εκτός ασφαλών ορίων.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
      for (final block in template.blocks) {
        if (block.exercises.length < 2 ||
            block.exercises.any(
              (exercise) => !template.exercises.contains(exercise),
            )) {
          issues.add(
            ValidationIssue(
              code: 'invalid-block',
              title: 'Κατεστραμμένο training block',
              detail:
                  'Superset/circuit στο ${template.name} δείχνει σε άγνωστη άσκηση.',
              severity: ValidationSeverity.critical,
              repairable: true,
            ),
          );
        }
      }
    }

    for (final assignment in data.weeklyAssignments.entries) {
      final weekday = int.tryParse(assignment.key);
      if (weekday == null ||
          weekday < 1 ||
          weekday > 7 ||
          !templateIds.contains(assignment.value)) {
        issues.add(
          const ValidationIssue(
            code: 'orphan-assignment',
            title: 'Ορφανή ανάθεση εβδομάδας',
            detail: 'Μία ημέρα δείχνει σε πρόγραμμα που δεν υπάρχει.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final assignment in data.dateAssignments.entries) {
      if (DateTime.tryParse(assignment.key) == null ||
          !templateIds.contains(assignment.value)) {
        issues.add(
          const ValidationIssue(
            code: 'orphan-date-assignment',
            title: 'Μη έγκυρη μεταφορά προπόνησης',
            detail: 'Μία ημερομηνία δείχνει σε πρόγραμμα που δεν υπάρχει.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final test in data.strengthTests) {
      if (test.exerciseName.trim().isEmpty ||
          test.weightKilograms <= 0 ||
          test.reps < 1 ||
          test.reps > 20 ||
          test.estimatedOneRepMax <= 0) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-strength-test',
            title: 'Μη έγκυρο strength test',
            detail: 'Βρέθηκε test αποτέλεσμα εκτός ασφαλών ορίων.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final assessment in data.skillAssessments) {
      if (assessment.skillId.trim().isEmpty ||
          assessment.value < 0 ||
          assessment.value > 1000 ||
          assessment.level < 0 ||
          assessment.level > 5 ||
          !const {'reps', 'seconds', 'score'}.contains(assessment.unit)) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-skill-assessment',
            title: 'Μη έγκυρο skill assessment',
            detail: 'Βρέθηκε calisthenics assessment εκτός ορίων.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final photo in data.progressPhotos) {
      if (photo.encodedBytes.isEmpty ||
          photo.encodedBytes.length > 900000 ||
          !const {
            'image/jpeg',
            'image/png',
            'image/webp',
          }.contains(photo.mimeType)) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-progress-photo',
            title: 'Μη έγκυρη ιδιωτική φωτογραφία',
            detail: 'Βρέθηκε photo-vault εγγραφή εκτός ασφαλών ορίων.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final entry in data.workoutPlaylists.entries) {
      final uri = Uri.tryParse(entry.value);
      if (!templateIds.contains(entry.key) ||
          uri == null ||
          uri.scheme != 'https' ||
          uri.host != 'open.spotify.com') {
        issues.add(
          const ValidationIssue(
            code: 'invalid-workout-playlist',
            title: 'Ορφανή ή μη έγκυρη workout playlist',
            detail:
                'Μία playlist δεν συνδέεται με έγκυρο πρόγραμμα ή Spotify URL.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final entry in data.exerciseVideoUrls.entries) {
      final uri = Uri.tryParse(entry.value);
      if (entry.key.trim().isEmpty ||
          uri == null ||
          uri.scheme != 'https' ||
          uri.host.isEmpty) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-exercise-video',
            title: 'Μη έγκυρο exercise video',
            detail: 'Βρέθηκε video link χωρίς άσκηση ή ασφαλές HTTPS URL.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final item in data.wearableSummaries) {
      if (item.steps < 0 ||
          item.steps > 100000 ||
          (item.restingHeartRate != 0 &&
              (item.restingHeartRate < 30 || item.restingHeartRate > 220)) ||
          item.sleepMinutes < 0 ||
          item.sleepMinutes > 1440) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-wearable-summary',
            title: 'Μη έγκυρη wearable ημέρα',
            detail: 'Βρέθηκε wearable τιμή εκτός ασφαλών ορίων.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    if (data.preferences.lockTimeoutMinutes < 0 ||
        data.preferences.lockTimeoutMinutes > 60 ||
        data.preferences.countdownCueSeconds < 0 ||
        data.preferences.countdownCueSeconds > 10 ||
        !const {
          'minimal',
          'coach',
          'silent',
        }.contains(data.preferences.audioCueStyle)) {
      issues.add(
        const ValidationIssue(
          code: 'invalid-reliability-preferences',
          title: 'Μη έγκυρη ρύθμιση ασφάλειας ή ήχου',
          detail: 'Το lock timeout ή audio cue βρέθηκε εκτός ορίων.',
          severity: ValidationSeverity.warning,
          repairable: true,
        ),
      );
    }
    for (final reminder in data.workoutReminders) {
      if (reminder.weekday < 1 ||
          reminder.weekday > 7 ||
          reminder.minutesSinceMidnight < 0 ||
          reminder.minutesSinceMidnight >= 1440 ||
          (reminder.templateId.isNotEmpty &&
              !templateIds.contains(reminder.templateId))) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-workout-reminder',
            title: 'Μη έγκυρο workout reminder',
            detail: 'Βρέθηκε reminder με άγνωστη ημέρα, ώρα ή πρόγραμμα.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    final customExerciseIds = <String>{};
    final customExerciseNames = <String>{};
    for (final exercise in data.customExercises) {
      final normalizedName = exercise.name.trim().toLowerCase();
      if (exercise.id.trim().isEmpty ||
          exercise.name.trim().length < 3 ||
          exercise.primaryMuscles.isEmpty ||
          exercise.movementPattern.trim().isEmpty ||
          exercise.equipment.isEmpty ||
          exercise.difficulty < 1 ||
          exercise.difficulty > 5 ||
          exercise.skillDemand < 1 ||
          exercise.skillDemand > 5 ||
          !customExerciseIds.add(exercise.id) ||
          !customExerciseNames.add(normalizedName)) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-custom-exercise',
            title: 'Μη έγκυρη προσωπική άσκηση',
            detail:
                'Βρέθηκε ελλιπής ή διπλότυπη εγγραφή στο Exercise Intelligence Lab.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final entry in data.strengthTrainingMaxes.entries) {
      if (!const {
            'Back squat',
            'Bench press',
            'Deadlift',
            'Overhead press',
          }.contains(entry.key) ||
          entry.value < 10 ||
          entry.value > 500) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-strength-training-max',
            title: 'Invalid strength training max',
            detail:
                'A saved big-lift training max is outside the supported range.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final checkIn in data.hypertrophyCheckIns) {
      if (checkIn.muscle.trim().isEmpty ||
          [
            checkIn.pump,
            checkIn.disruption,
            checkIn.soreness,
          ].any((value) => value < 1 || value > 5)) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-hypertrophy-check-in',
            title: 'Invalid hypertrophy check-in',
            detail: 'Pump, disruption or soreness is outside the 1–5 range.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final log in data.hypertrophyTechniqueLogs) {
      if (!const {
            'MYO-REPS',
            'DROP SET',
            'REST-PAUSE',
          }.contains(log.technique) ||
          log.exercise.trim().isEmpty ||
          log.muscle.trim().isEmpty ||
          log.weightKilograms < 0 ||
          log.weightKilograms > 400 ||
          log.activationReps < 1 ||
          log.activationReps > 50 ||
          log.miniSetReps.isEmpty ||
          log.miniSetReps.length > 8 ||
          log.miniSetReps.any((value) => value < 1 || value > 20)) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-hypertrophy-technique',
            title: 'Invalid hypertrophy technique log',
            detail: 'A myo-rep, drop-set or rest-pause log is outside bounds.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final session in data.cardioSessions) {
      if (session.modality.trim().isEmpty ||
          session.durationMinutes < 5 ||
          session.durationMinutes > 300 ||
          session.rpe < 1 ||
          session.rpe > 10 ||
          (session.averageHeartRate != 0 &&
              (session.averageHeartRate < 40 ||
                  session.averageHeartRate > 230)) ||
          session.targetZone < 1 ||
          session.targetZone > 5) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-cardio-session',
            title: 'Invalid cardio session',
            detail:
                'Duration, RPE, heart rate or target zone is outside bounds.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final benchmark in data.conditioningBenchmarks) {
      if (benchmark.test.trim().isEmpty ||
          benchmark.value <= 0 ||
          benchmark.value > 10000 ||
          benchmark.unit.trim().isEmpty ||
          benchmark.score < 0 ||
          benchmark.score > 10000 ||
          benchmark.label.trim().isEmpty) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-conditioning-benchmark',
            title: 'Invalid conditioning benchmark',
            detail: 'A saved benchmark value is outside supported bounds.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    final runningShoeIds = <String>{};
    for (final shoe in data.runningShoes) {
      if (shoe.id.trim().isEmpty ||
          shoe.name.trim().length < 2 ||
          shoe.startingKilometers < 0 ||
          shoe.retirementKilometers < 100 ||
          shoe.startingKilometers >= shoe.retirementKilometers ||
          !runningShoeIds.add(shoe.id)) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-running-shoe',
            title: 'Invalid running shoe',
            detail: 'A shoe has invalid mileage settings or a duplicate ID.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final run in data.runningSessions) {
      if (run.distanceKilometers <= 0 ||
          run.distanceKilometers > 200 ||
          run.durationSeconds < 60 ||
          run.durationSeconds > 86400 ||
          run.rpe < 1 ||
          run.rpe > 10 ||
          !const {
            'Road',
            'Track',
            'Trail',
            'Treadmill',
            'Mixed',
          }.contains(run.surface) ||
          run.elevationGainMeters < 0 ||
          run.elevationGainMeters > 10000 ||
          (run.cadenceStepsPerMinute != 0 &&
              (run.cadenceStepsPerMinute < 80 ||
                  run.cadenceStepsPerMinute > 240)) ||
          (run.shoeId.isNotEmpty && !runningShoeIds.contains(run.shoeId))) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-running-session',
            title: 'Invalid running session',
            detail: 'Distance, time, RPE, surface, cadence or shoe is invalid.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final ride in data.cyclingSessions) {
      if (ride.durationMinutes < 5 ||
          ride.durationMinutes > 720 ||
          ride.averagePowerWatts < 1 ||
          ride.averagePowerWatts > 1500 ||
          (ride.normalizedPowerWatts != 0 &&
              (ride.normalizedPowerWatts < 1 ||
                  ride.normalizedPowerWatts > 1800)) ||
          (ride.cadenceRpm != 0 &&
              (ride.cadenceRpm < 30 || ride.cadenceRpm > 180)) ||
          ride.rpe < 1 ||
          ride.rpe > 10 ||
          !const {
            'Endurance',
            'Tempo',
            'Threshold',
            'VO2',
            'Recovery',
            'Race',
          }.contains(ride.workoutType)) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-cycling-session',
            title: 'Invalid cycling session',
            detail: 'Duration, power, cadence, RPE or workout type is invalid.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final row in data.rowingSessions) {
      if (row.distanceMeters < 100 ||
          row.distanceMeters > 100000 ||
          row.durationSeconds < 30 ||
          row.durationSeconds > 86400 ||
          (row.strokeRate != 0 &&
              (row.strokeRate < 10 || row.strokeRate > 60)) ||
          row.rpe < 1 ||
          row.rpe > 10 ||
          !const {
            'Training',
            '500m',
            '2k',
            '5k',
            '30min',
          }.contains(row.benchmarkType)) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-rowing-session',
            title: 'Invalid rowing session',
            detail:
                'Distance, time, stroke rate, RPE or benchmark type is invalid.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final log in data.calisthenicsSkillLogs) {
      if (!const {
            'muscle-up',
            'front-lever',
            'back-lever',
            'planche',
            'handstand-push-up',
            'ring-support',
          }.contains(log.skillId) ||
          log.progression.trim().length < 3 ||
          log.holdSeconds < 0 ||
          log.holdSeconds > 300 ||
          log.repetitions < 0 ||
          log.repetitions > 100 ||
          (log.holdSeconds == 0 && log.repetitions == 0) ||
          log.quality < 1 ||
          log.quality > 5 ||
          log.rpe < 1 ||
          log.rpe > 10 ||
          log.elbowPain < 0 ||
          log.elbowPain > 5) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-calisthenics-skill-log',
            title: 'Invalid advanced calisthenics log',
            detail:
                'Skill, progression, duration, repetitions, quality or pain is invalid.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final log in data.mobilityScreenLogs) {
      final validRange = switch (log.jointId) {
        'ankle-dorsiflexion' =>
          log.leftValue >= 0 &&
              log.leftValue <= 30 &&
              log.rightValue >= 0 &&
              log.rightValue <= 30,
        'hip-internal-rotation' =>
          log.leftValue >= 0 &&
              log.leftValue <= 90 &&
              log.rightValue >= 0 &&
              log.rightValue <= 90,
        'shoulder-flexion' =>
          log.leftValue >= 0 &&
              log.leftValue <= 210 &&
              log.rightValue >= 0 &&
              log.rightValue <= 210,
        'thoracic-rotation' =>
          log.leftValue >= 0 &&
              log.leftValue <= 100 &&
              log.rightValue >= 0 &&
              log.rightValue <= 100,
        _ => false,
      };
      if (!validRange || log.painLevel < 0 || log.painLevel > 5) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-mobility-screen-log',
            title: 'Invalid mobility screen log',
            detail: 'Joint, side measurement or pain value is outside bounds.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final log in data.recoveryInterventions) {
      final temperatureValid = switch (log.intervention) {
        'Sauna' =>
          log.temperatureCelsius >= 40 && log.temperatureCelsius <= 120,
        'Cold exposure' =>
          log.temperatureCelsius >= 0 && log.temperatureCelsius <= 25,
        'Recovery walk' ||
        'Mobility' ||
        'Breathing' ||
        'Nap' => log.temperatureCelsius == 0,
        _ => false,
      };
      if (!temperatureValid ||
          log.durationMinutes < 1 ||
          log.durationMinutes > 180 ||
          log.beforeScore < 1 ||
          log.beforeScore > 10 ||
          log.afterScore < 1 ||
          log.afterScore > 10) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-recovery-intervention',
            title: 'Invalid recovery intervention',
            detail:
                'Intervention, duration, temperature or response is outside bounds.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final log in data.nutritionPhaseLogs) {
      if (!const {
            'Fat loss',
            'Maintenance',
            'Muscle gain',
            'Performance',
          }.contains(log.phase) ||
          log.dailyCalories < 1200 ||
          log.dailyCalories > 5000 ||
          log.durationWeeks < 1 ||
          log.durationWeeks > 52 ||
          log.targetWeeklyChangePercent < -1.5 ||
          log.targetWeeklyChangePercent > 1.5) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-nutrition-phase',
            title: 'Invalid nutrition phase',
            detail:
                'Phase, calories, duration or weekly rate is outside bounds.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    final pantryIngredientIds = <String>{};
    for (final item in data.pantryItems) {
      if (!_supportedIngredientIds.contains(item.ingredientId) ||
          !pantryIngredientIds.add(item.ingredientId) ||
          item.name.trim().isEmpty ||
          item.quantityGrams < 0 ||
          item.quantityGrams > 50000 ||
          item.costPer100Grams < 0 ||
          item.costPer100Grams > 100) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-pantry-item',
            title: 'Invalid pantry item',
            detail:
                'Ingredient, quantity, price or duplicate inventory row is invalid.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    if (data.favoriteIngredientIds.toSet().length !=
            data.favoriteIngredientIds.length ||
        data.favoriteIngredientIds.any(
          (item) => !_supportedIngredientIds.contains(item),
        )) {
      issues.add(
        const ValidationIssue(
          code: 'invalid-favorite-ingredients',
          title: 'Invalid favorite ingredient library',
          detail: 'Favorite IDs contain duplicates or unknown ingredients.',
          severity: ValidationSeverity.warning,
          repairable: true,
        ),
      );
    }
    for (final item in data.bodyMeasurementLogs) {
      final measurements = [
        item.waistCentimeters,
        item.neckCentimeters,
        item.chestCentimeters,
        item.hipsCentimeters,
        item.upperArmCentimeters,
        item.thighCentimeters,
      ];
      if (item.weightKilograms < 20 ||
          item.weightKilograms > 400 ||
          item.waistCentimeters == 0 ||
          measurements.any(
            (value) => value != 0 && (value < 10 || value > 300),
          )) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-body-measurement',
            title: 'Invalid body measurement',
            detail:
                'Weight, waist or another measurement is outside realistic bounds.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    final habitIds = <String>{};
    for (final habit in data.healthHabits) {
      if (habit.id.trim().isEmpty ||
          !habitIds.add(habit.id) ||
          habit.name.trim().length < 3 ||
          !const {
            'Movement',
            'Nutrition',
            'Recovery',
            'Mindset',
          }.contains(habit.category) ||
          habit.targetDaysPerWeek < 1 ||
          habit.targetDaysPerWeek > 7 ||
          habit.minimumVersion.trim().isEmpty ||
          habit.preferredMinutesSinceMidnight < 0 ||
          habit.preferredMinutesSinceMidnight >= 1440) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-health-habit',
            title: 'Invalid health habit',
            detail:
                'A habit has duplicate identity or settings outside bounds.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    final checkInKeys = <String>{};
    for (final item in data.habitCheckIns) {
      final key =
          '${item.habitId}:${item.day.year}-${item.day.month}-${item.day.day}';
      if (!habitIds.contains(item.habitId) ||
          !checkInKeys.add(key) ||
          (item.completed && item.usedMinimum) ||
          item.frictionLevel < 0 ||
          item.frictionLevel > 5 ||
          item.reflection.length > 300) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-habit-check-in',
            title: 'Invalid habit check-in',
            detail:
                'A check-in is orphaned, duplicated or contains invalid values.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    final sleepDays = <String>{};
    for (final item in data.sleepRoutineLogs) {
      final key = '${item.day.year}-${item.day.month}-${item.day.day}';
      if (!sleepDays.add(key) ||
          item.bedtimeMinutes < 0 ||
          item.bedtimeMinutes >= 1440 ||
          item.wakeMinutes < 0 ||
          item.wakeMinutes >= 1440 ||
          item.lastCaffeineMinutes < 0 ||
          item.lastCaffeineMinutes >= 1440 ||
          item.screenFreeMinutes < 0 ||
          item.screenFreeMinutes > 240 ||
          item.windDownSteps.length > 8) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-sleep-routine',
            title: 'Invalid sleep routine',
            detail:
                'A sleep day is duplicated or contains values outside bounds.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final item in data.stressCheckInLogs) {
      if (item.level < 1 ||
          item.level > 5 ||
          item.context.trim().length > 160) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-stress-check-in',
            title: 'Invalid stress check-in',
            detail: 'A stress value or context is outside supported bounds.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final item in data.coachRecommendationFeedback) {
      if (item.recommendationId.trim().isEmpty ||
          item.recommendationId.length > 80 ||
          item.note.length > 240) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-coach-feedback',
            title: 'Invalid coach feedback',
            detail: 'Recommendation identity or feedback note is invalid.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    if (data.analyticsDashboardMetrics.isEmpty ||
        data.analyticsDashboardMetrics.length > 6 ||
        data.analyticsDashboardMetrics.toSet().length !=
            data.analyticsDashboardMetrics.length ||
        data.analyticsDashboardMetrics.any(
          (item) => !_analyticsMetrics.contains(item),
        )) {
      issues.add(
        const ValidationIssue(
          code: 'invalid-analytics-dashboard',
          title: 'Invalid analytics dashboard',
          detail:
              'Selected dashboard metrics are empty, duplicated or unknown.',
          severity: ValidationSeverity.warning,
          repairable: true,
        ),
      );
    }
    for (final item in data.analyticsAnnotations) {
      if (!const {
            'Training',
            'Recovery',
            'Nutrition',
            'Life',
          }.contains(item.category) ||
          item.label.trim().length < 2 ||
          item.label.length > 60 ||
          item.note.length > 240) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-analytics-annotation',
            title: 'Invalid analytics annotation',
            detail: 'Category, label or note is outside supported bounds.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final meal in data.meals) {
      if (meal.name.trim().isEmpty ||
          meal.calories < 0 ||
          meal.calories > 5000 ||
          meal.proteinGrams < 0 ||
          meal.carbohydrateGrams < 0 ||
          meal.fatGrams < 0) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-meal',
            title: 'Μη έγκυρη καταγραφή γεύματος',
            detail: 'Βρέθηκε γεύμα με κενό όνομα ή αδύνατες τιμές.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final water in data.hydration) {
      if (water.milliliters < 50 || water.milliliters > 2000) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-water',
            title: 'Μη έγκυρη καταγραφή νερού',
            detail: 'Βρέθηκε ποσότητα ενυδάτωσης εκτός ορίων.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }
    for (final weight in data.weights) {
      if (weight.kilograms < 20 || weight.kilograms > 400) {
        issues.add(
          const ValidationIssue(
            code: 'invalid-weight',
            title: 'Μη έγκυρη μέτρηση βάρους',
            detail: 'Βρέθηκε μέτρηση βάρους εκτός 20–400 kg.',
            severity: ValidationSeverity.warning,
            repairable: true,
          ),
        );
      }
    }

    final checked =
        data.templates.length +
        data.logs.length +
        data.weights.length +
        data.meals.length +
        data.hydration.length +
        data.recoveryChecks.length +
        data.programVersions.length +
        data.weeklyAssignments.length +
        data.dateAssignments.length +
        data.strengthTests.length +
        data.skillAssessments.length +
        data.progressPhotos.length +
        data.workoutPlaylists.length +
        data.exerciseVideoUrls.length +
        data.wearableSummaries.length +
        data.workoutReminders.length +
        data.customExercises.length +
        data.strengthTrainingMaxes.length +
        data.hypertrophyCheckIns.length +
        data.hypertrophyTechniqueLogs.length +
        data.cardioSessions.length +
        data.conditioningBenchmarks.length +
        data.runningSessions.length +
        data.runningShoes.length +
        data.cyclingSessions.length +
        data.rowingSessions.length +
        data.calisthenicsSkillLogs.length +
        data.mobilityScreenLogs.length +
        data.recoveryInterventions.length +
        data.nutritionPhaseLogs.length +
        data.pantryItems.length +
        data.favoriteIngredientIds.length +
        data.bodyMeasurementLogs.length +
        data.healthHabits.length +
        data.habitCheckIns.length +
        data.sleepRoutineLogs.length +
        data.stressCheckInLogs.length +
        data.coachRecommendationFeedback.length +
        data.analyticsDashboardMetrics.length +
        data.analyticsAnnotations.length;
    return DataValidationReport(issues: issues, checkedRecords: checked);
  }

  static FitnessData repair(FitnessData data) {
    final usedIds = <String>{};
    final templates = <WorkoutTemplate>[];
    for (final template in data.templates) {
      if (template.name.trim().isEmpty || template.exercises.isEmpty) continue;
      var id = template.id.trim().isEmpty
          ? 'repaired-${templates.length + 1}'
          : template.id;
      if (usedIds.contains(id)) id = '$id-repaired-${templates.length + 1}';
      usedIds.add(id);
      final exercises = template.exercises
          .map((exercise) => exercise.trim())
          .where((exercise) => exercise.isNotEmpty)
          .toSet()
          .take(12)
          .toList();
      if (exercises.isEmpty) continue;
      templates.add(
        template.copyWith(
          id: id,
          exercises: exercises,
          restSeconds: template.restSeconds.clamp(10, 900),
          exercisePrescriptions: {
            for (final entry in template.exercisePrescriptions.entries)
              if (exercises.contains(entry.key)) entry.key: entry.value,
          },
          blocks: template.blocks
              .where(
                (block) =>
                    block.exercises.length >= 2 &&
                    block.exercises.every(exercises.contains),
              )
              .toList(),
        ),
      );
    }
    final safeTemplates = templates.isEmpty
        ? FitnessData.initial().templates
        : templates;
    final safeIds = safeTemplates.map((item) => item.id).toSet();
    final customExerciseIds = <String>{};
    final customExerciseNames = <String>{};
    final runningShoeIds = <String>{};
    final safeRunningShoes = data.runningShoes
        .where(
          (item) =>
              item.id.trim().isNotEmpty &&
              item.name.trim().length >= 2 &&
              item.startingKilometers >= 0 &&
              item.retirementKilometers >= 100 &&
              item.startingKilometers < item.retirementKilometers &&
              runningShoeIds.add(item.id),
        )
        .take(30)
        .toList();
    final safeRunningShoeIds = safeRunningShoes.map((item) => item.id).toSet();
    return data.copyWith(
      templates: safeTemplates,
      weeklyAssignments: {
        for (final entry in data.weeklyAssignments.entries)
          if ((int.tryParse(entry.key) ?? 0) >= 1 &&
              (int.tryParse(entry.key) ?? 8) <= 7 &&
              safeIds.contains(entry.value))
            entry.key: entry.value,
      },
      meals: data.meals
          .where(
            (meal) =>
                meal.name.trim().isNotEmpty &&
                meal.calories >= 0 &&
                meal.calories <= 5000 &&
                meal.proteinGrams >= 0 &&
                meal.carbohydrateGrams >= 0 &&
                meal.fatGrams >= 0,
          )
          .toList(),
      hydration: data.hydration
          .where(
            (entry) => entry.milliliters >= 50 && entry.milliliters <= 2000,
          )
          .toList(),
      weights: data.weights
          .where((entry) => entry.kilograms >= 20 && entry.kilograms <= 400)
          .toList(),
      programVersions: data.programVersions
          .where((version) => safeIds.contains(version.templateId))
          .toList(),
      dateAssignments: {
        for (final entry in data.dateAssignments.entries)
          if (DateTime.tryParse(entry.key) != null &&
              safeIds.contains(entry.value))
            entry.key: entry.value,
      },
      strengthTests: data.strengthTests
          .where(
            (test) =>
                test.exerciseName.trim().isNotEmpty &&
                test.weightKilograms > 0 &&
                test.reps >= 1 &&
                test.reps <= 20 &&
                test.estimatedOneRepMax > 0,
          )
          .toList(),
      skillAssessments: data.skillAssessments
          .where(
            (assessment) =>
                assessment.skillId.trim().isNotEmpty &&
                assessment.value >= 0 &&
                assessment.value <= 1000 &&
                assessment.level >= 0 &&
                assessment.level <= 5 &&
                const {'reps', 'seconds', 'score'}.contains(assessment.unit),
          )
          .toList(),
      progressPhotos: data.progressPhotos
          .where(
            (photo) =>
                photo.encodedBytes.isNotEmpty &&
                photo.encodedBytes.length <= 900000 &&
                const {
                  'image/jpeg',
                  'image/png',
                  'image/webp',
                }.contains(photo.mimeType),
          )
          .take(12)
          .toList(),
      workoutPlaylists: {
        for (final entry in data.workoutPlaylists.entries)
          if (safeIds.contains(entry.key) &&
              Uri.tryParse(entry.value)?.scheme == 'https' &&
              Uri.tryParse(entry.value)?.host == 'open.spotify.com')
            entry.key: entry.value,
      },
      exerciseVideoUrls: {
        for (final entry in data.exerciseVideoUrls.entries)
          if (entry.key.trim().isNotEmpty &&
              Uri.tryParse(entry.value)?.scheme == 'https' &&
              (Uri.tryParse(entry.value)?.host.isNotEmpty ?? false))
            entry.key: entry.value,
      },
      wearableSummaries: data.wearableSummaries
          .where(
            (item) =>
                item.steps >= 0 &&
                item.steps <= 100000 &&
                (item.restingHeartRate == 0 ||
                    (item.restingHeartRate >= 30 &&
                        item.restingHeartRate <= 220)) &&
                item.sleepMinutes >= 0 &&
                item.sleepMinutes <= 1440,
          )
          .toList(),
      preferences: data.preferences.copyWith(
        lockTimeoutMinutes: data.preferences.lockTimeoutMinutes.clamp(0, 60),
        countdownCueSeconds: data.preferences.countdownCueSeconds.clamp(0, 10),
        audioCueStyle:
            const {
              'minimal',
              'coach',
              'silent',
            }.contains(data.preferences.audioCueStyle)
            ? data.preferences.audioCueStyle
            : 'minimal',
      ),
      workoutReminders: data.workoutReminders
          .where(
            (item) =>
                item.weekday >= 1 &&
                item.weekday <= 7 &&
                item.minutesSinceMidnight >= 0 &&
                item.minutesSinceMidnight < 1440 &&
                (item.templateId.isEmpty || safeIds.contains(item.templateId)),
          )
          .take(20)
          .toList(),
      customExercises: data.customExercises
          .where(
            (item) =>
                item.id.trim().isNotEmpty &&
                item.name.trim().length >= 3 &&
                item.primaryMuscles.isNotEmpty &&
                item.movementPattern.trim().isNotEmpty &&
                item.equipment.isNotEmpty &&
                item.difficulty >= 1 &&
                item.difficulty <= 5 &&
                item.skillDemand >= 1 &&
                item.skillDemand <= 5 &&
                customExerciseIds.add(item.id) &&
                customExerciseNames.add(item.name.trim().toLowerCase()),
          )
          .take(200)
          .toList(),
      strengthTrainingMaxes: {
        for (final entry in data.strengthTrainingMaxes.entries)
          if (const {
                'Back squat',
                'Bench press',
                'Deadlift',
                'Overhead press',
              }.contains(entry.key) &&
              entry.value >= 10 &&
              entry.value <= 500)
            entry.key: entry.value,
      },
      hypertrophyCheckIns: data.hypertrophyCheckIns
          .where(
            (item) =>
                item.muscle.trim().isNotEmpty &&
                item.pump >= 1 &&
                item.pump <= 5 &&
                item.disruption >= 1 &&
                item.disruption <= 5 &&
                item.soreness >= 1 &&
                item.soreness <= 5,
          )
          .take(500)
          .toList(),
      hypertrophyTechniqueLogs: data.hypertrophyTechniqueLogs
          .where(
            (item) =>
                const {
                  'MYO-REPS',
                  'DROP SET',
                  'REST-PAUSE',
                }.contains(item.technique) &&
                item.exercise.trim().isNotEmpty &&
                item.muscle.trim().isNotEmpty &&
                item.weightKilograms >= 0 &&
                item.weightKilograms <= 400 &&
                item.activationReps >= 1 &&
                item.activationReps <= 50 &&
                item.miniSetReps.isNotEmpty &&
                item.miniSetReps.length <= 8 &&
                item.miniSetReps.every((value) => value >= 1 && value <= 20),
          )
          .take(500)
          .toList(),
      cardioSessions: data.cardioSessions
          .where(
            (item) =>
                item.modality.trim().isNotEmpty &&
                item.durationMinutes >= 5 &&
                item.durationMinutes <= 300 &&
                item.rpe >= 1 &&
                item.rpe <= 10 &&
                (item.averageHeartRate == 0 ||
                    (item.averageHeartRate >= 40 &&
                        item.averageHeartRate <= 230)) &&
                item.targetZone >= 1 &&
                item.targetZone <= 5,
          )
          .take(1000)
          .toList(),
      conditioningBenchmarks: data.conditioningBenchmarks
          .where(
            (item) =>
                item.test.trim().isNotEmpty &&
                item.value > 0 &&
                item.value <= 10000 &&
                item.unit.trim().isNotEmpty &&
                item.score >= 0 &&
                item.score <= 10000 &&
                item.label.trim().isNotEmpty,
          )
          .take(500)
          .toList(),
      runningShoes: safeRunningShoes,
      runningSessions: data.runningSessions
          .where(
            (item) =>
                item.distanceKilometers > 0 &&
                item.distanceKilometers <= 200 &&
                item.durationSeconds >= 60 &&
                item.durationSeconds <= 86400 &&
                item.rpe >= 1 &&
                item.rpe <= 10 &&
                const {
                  'Road',
                  'Track',
                  'Trail',
                  'Treadmill',
                  'Mixed',
                }.contains(item.surface) &&
                item.elevationGainMeters >= 0 &&
                item.elevationGainMeters <= 10000 &&
                (item.cadenceStepsPerMinute == 0 ||
                    (item.cadenceStepsPerMinute >= 80 &&
                        item.cadenceStepsPerMinute <= 240)) &&
                (item.shoeId.isEmpty ||
                    safeRunningShoeIds.contains(item.shoeId)),
          )
          .take(2000)
          .toList(),
      cyclingSessions: data.cyclingSessions
          .where(
            (item) =>
                item.durationMinutes >= 5 &&
                item.durationMinutes <= 720 &&
                item.averagePowerWatts >= 1 &&
                item.averagePowerWatts <= 1500 &&
                (item.normalizedPowerWatts == 0 ||
                    (item.normalizedPowerWatts >= 1 &&
                        item.normalizedPowerWatts <= 1800)) &&
                (item.cadenceRpm == 0 ||
                    (item.cadenceRpm >= 30 && item.cadenceRpm <= 180)) &&
                item.rpe >= 1 &&
                item.rpe <= 10 &&
                const {
                  'Endurance',
                  'Tempo',
                  'Threshold',
                  'VO2',
                  'Recovery',
                  'Race',
                }.contains(item.workoutType),
          )
          .take(2000)
          .toList(),
      rowingSessions: data.rowingSessions
          .where(
            (item) =>
                item.distanceMeters >= 100 &&
                item.distanceMeters <= 100000 &&
                item.durationSeconds >= 30 &&
                item.durationSeconds <= 86400 &&
                (item.strokeRate == 0 ||
                    (item.strokeRate >= 10 && item.strokeRate <= 60)) &&
                item.rpe >= 1 &&
                item.rpe <= 10 &&
                const {
                  'Training',
                  '500m',
                  '2k',
                  '5k',
                  '30min',
                }.contains(item.benchmarkType),
          )
          .take(2000)
          .toList(),
      calisthenicsSkillLogs: data.calisthenicsSkillLogs
          .where(
            (item) =>
                const {
                  'muscle-up',
                  'front-lever',
                  'back-lever',
                  'planche',
                  'handstand-push-up',
                  'ring-support',
                }.contains(item.skillId) &&
                item.progression.trim().length >= 3 &&
                item.holdSeconds >= 0 &&
                item.holdSeconds <= 300 &&
                item.repetitions >= 0 &&
                item.repetitions <= 100 &&
                (item.holdSeconds > 0 || item.repetitions > 0) &&
                item.quality >= 1 &&
                item.quality <= 5 &&
                item.rpe >= 1 &&
                item.rpe <= 10 &&
                item.elbowPain >= 0 &&
                item.elbowPain <= 5,
          )
          .take(2000)
          .toList(),
      mobilityScreenLogs: data.mobilityScreenLogs
          .where((item) {
            final validRange = switch (item.jointId) {
              'ankle-dorsiflexion' =>
                item.leftValue >= 0 &&
                    item.leftValue <= 30 &&
                    item.rightValue >= 0 &&
                    item.rightValue <= 30,
              'hip-internal-rotation' =>
                item.leftValue >= 0 &&
                    item.leftValue <= 90 &&
                    item.rightValue >= 0 &&
                    item.rightValue <= 90,
              'shoulder-flexion' =>
                item.leftValue >= 0 &&
                    item.leftValue <= 210 &&
                    item.rightValue >= 0 &&
                    item.rightValue <= 210,
              'thoracic-rotation' =>
                item.leftValue >= 0 &&
                    item.leftValue <= 100 &&
                    item.rightValue >= 0 &&
                    item.rightValue <= 100,
              _ => false,
            };
            return validRange && item.painLevel >= 0 && item.painLevel <= 5;
          })
          .take(2000)
          .toList(),
      recoveryInterventions: data.recoveryInterventions
          .where((item) {
            final temperatureValid = switch (item.intervention) {
              'Sauna' =>
                item.temperatureCelsius >= 40 && item.temperatureCelsius <= 120,
              'Cold exposure' =>
                item.temperatureCelsius >= 0 && item.temperatureCelsius <= 25,
              'Recovery walk' ||
              'Mobility' ||
              'Breathing' ||
              'Nap' => item.temperatureCelsius == 0,
              _ => false,
            };
            return temperatureValid &&
                item.durationMinutes >= 1 &&
                item.durationMinutes <= 180 &&
                item.beforeScore >= 1 &&
                item.beforeScore <= 10 &&
                item.afterScore >= 1 &&
                item.afterScore <= 10;
          })
          .take(2000)
          .toList(),
      nutritionPhaseLogs: data.nutritionPhaseLogs
          .where(
            (item) =>
                const {
                  'Fat loss',
                  'Maintenance',
                  'Muscle gain',
                  'Performance',
                }.contains(item.phase) &&
                item.dailyCalories >= 1200 &&
                item.dailyCalories <= 5000 &&
                item.durationWeeks >= 1 &&
                item.durationWeeks <= 52 &&
                item.targetWeeklyChangePercent >= -1.5 &&
                item.targetWeeklyChangePercent <= 1.5,
          )
          .take(200)
          .toList(),
      pantryItems: _validPantry(data.pantryItems),
      favoriteIngredientIds: data.favoriteIngredientIds
          .where(_supportedIngredientIds.contains)
          .toSet()
          .take(30)
          .toList(),
      bodyMeasurementLogs: data.bodyMeasurementLogs
          .where((item) {
            final measurements = [
              item.waistCentimeters,
              item.neckCentimeters,
              item.chestCentimeters,
              item.hipsCentimeters,
              item.upperArmCentimeters,
              item.thighCentimeters,
            ];
            return item.weightKilograms >= 20 &&
                item.weightKilograms <= 400 &&
                item.waistCentimeters != 0 &&
                measurements.every(
                  (value) => value == 0 || (value >= 10 && value <= 300),
                );
          })
          .take(1000)
          .toList(),
      healthHabits: _validHealthHabits(data.healthHabits),
      habitCheckIns: _validHabitCheckIns(
        data.habitCheckIns,
        _validHealthHabits(data.healthHabits).map((item) => item.id).toSet(),
      ),
      sleepRoutineLogs: _validSleepRoutines(data.sleepRoutineLogs),
      stressCheckInLogs: data.stressCheckInLogs
          .where(
            (item) =>
                item.level >= 1 &&
                item.level <= 5 &&
                item.context.trim().length <= 160,
          )
          .take(5000)
          .toList(),
      coachRecommendationFeedback: data.coachRecommendationFeedback
          .where(
            (item) =>
                item.recommendationId.trim().isNotEmpty &&
                item.recommendationId.length <= 80 &&
                item.note.length <= 240,
          )
          .take(5000)
          .toList(),
      analyticsDashboardMetrics:
          data.analyticsDashboardMetrics
              .where(_analyticsMetrics.contains)
              .toSet()
              .take(6)
              .toList()
              .isEmpty
          ? const ['sessions', 'volume', 'readiness', 'bodyweight']
          : data.analyticsDashboardMetrics
                .where(_analyticsMetrics.contains)
                .toSet()
                .take(6)
                .toList(),
      analyticsAnnotations: data.analyticsAnnotations
          .where(
            (item) =>
                const {
                  'Training',
                  'Recovery',
                  'Nutrition',
                  'Life',
                }.contains(item.category) &&
                item.label.trim().length >= 2 &&
                item.label.length <= 60 &&
                item.note.length <= 240,
          )
          .take(2000)
          .toList(),
    );
  }

  static List<SleepRoutineLog> _validSleepRoutines(
    List<SleepRoutineLog> items,
  ) {
    final seen = <String>{};
    return items
        .where((item) {
          final key = '${item.day.year}-${item.day.month}-${item.day.day}';
          return seen.add(key) &&
              item.bedtimeMinutes >= 0 &&
              item.bedtimeMinutes < 1440 &&
              item.wakeMinutes >= 0 &&
              item.wakeMinutes < 1440 &&
              item.lastCaffeineMinutes >= 0 &&
              item.lastCaffeineMinutes < 1440 &&
              item.screenFreeMinutes >= 0 &&
              item.screenFreeMinutes <= 240 &&
              item.windDownSteps.length <= 8;
        })
        .take(2000)
        .toList();
  }

  static List<HealthHabit> _validHealthHabits(List<HealthHabit> items) {
    final seen = <String>{};
    return items
        .where(
          (item) =>
              item.id.trim().isNotEmpty &&
              seen.add(item.id) &&
              item.name.trim().length >= 3 &&
              const {
                'Movement',
                'Nutrition',
                'Recovery',
                'Mindset',
              }.contains(item.category) &&
              item.targetDaysPerWeek >= 1 &&
              item.targetDaysPerWeek <= 7 &&
              item.minimumVersion.trim().isNotEmpty &&
              item.preferredMinutesSinceMidnight >= 0 &&
              item.preferredMinutesSinceMidnight < 1440,
        )
        .take(50)
        .toList();
  }

  static List<HabitCheckIn> _validHabitCheckIns(
    List<HabitCheckIn> items,
    Set<String> habitIds,
  ) {
    final seen = <String>{};
    return items
        .where((item) {
          final key =
              '${item.habitId}:${item.day.year}-${item.day.month}-${item.day.day}';
          return habitIds.contains(item.habitId) &&
              seen.add(key) &&
              !(item.completed && item.usedMinimum) &&
              item.frictionLevel >= 0 &&
              item.frictionLevel <= 5 &&
              item.reflection.length <= 300;
        })
        .take(10000)
        .toList();
  }

  static List<PantryItem> _validPantry(List<PantryItem> items) {
    final seen = <String>{};
    return items
        .where(
          (item) =>
              _supportedIngredientIds.contains(item.ingredientId) &&
              seen.add(item.ingredientId) &&
              item.name.trim().isNotEmpty &&
              item.quantityGrams >= 0 &&
              item.quantityGrams <= 50000 &&
              item.costPer100Grams >= 0 &&
              item.costPer100Grams <= 100,
        )
        .take(200)
        .toList();
  }
}
