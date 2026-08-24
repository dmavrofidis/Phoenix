import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix/src/active_workout_page.dart';
import 'package:phoenix/src/advanced_calisthenics_engine.dart';
import 'package:phoenix/src/advanced_calisthenics_page.dart';
import 'package:phoenix/src/advanced_feature_pack_engine.dart';
import 'package:phoenix/src/advanced_feature_pack_page.dart';
import 'package:phoenix/src/advanced_analytics_engine.dart';
import 'package:phoenix/src/advanced_analytics_page.dart';
import 'package:phoenix/src/advanced_coach_engine.dart';
import 'package:phoenix/src/advanced_coach_page.dart';
import 'package:phoenix/src/analytics_studio_engine.dart';
import 'package:phoenix/src/analytics_studio_page.dart';
import 'package:phoenix/src/achievement_engine.dart';
import 'package:phoenix/src/app.dart';
import 'package:phoenix/src/body_composition_engine.dart';
import 'package:phoenix/src/body_composition_page.dart';
import 'package:phoenix/src/control_center_page.dart';
import 'package:phoenix/src/coach_hub_page.dart';
import 'package:phoenix/src/calisthenics_engine.dart';
import 'package:phoenix/src/calisthenics_lab_page.dart';
import 'package:phoenix/src/capability_studio_engine.dart';
import 'package:phoenix/src/capability_studio_page.dart';
import 'package:phoenix/src/coaching_report_engine.dart';
import 'package:phoenix/src/conditioning_engine.dart';
import 'package:phoenix/src/conditioning_lab_page.dart';
import 'package:phoenix/src/cycling_rowing_engine.dart';
import 'package:phoenix/src/cycling_rowing_lab_page.dart';
import 'package:phoenix/src/data/drift_fitness_repository.dart';
import 'package:phoenix/src/data/local_fitness_repository.dart';
import 'package:phoenix/src/data/phoenix_database.dart';
import 'package:phoenix/src/data_validation_engine.dart';
import 'package:phoenix/src/data_validation_page.dart';
import 'package:phoenix/src/deterministic_coach_engine.dart';
import 'package:phoenix/src/equipment_presets.dart';
import 'package:phoenix/src/equipment_availability.dart';
import 'package:phoenix/src/education_library.dart';
import 'package:phoenix/src/encrypted_sync_engine.dart';
import 'package:phoenix/src/exercise_guide.dart';
import 'package:phoenix/src/exercise_intelligence_engine.dart';
import 'package:phoenix/src/exercise_intelligence_page.dart';
import 'package:phoenix/src/exercise_substitution_engine.dart';
import 'package:phoenix/src/experience_settings_page.dart';
import 'package:phoenix/src/global_search_engine.dart';
import 'package:phoenix/src/global_search_page.dart';
import 'package:phoenix/src/habit_builder_engine.dart';
import 'package:phoenix/src/habit_builder_page.dart';
import 'package:phoenix/src/hypertrophy_engine.dart';
import 'package:phoenix/src/hypertrophy_lab_page.dart';
import 'package:phoenix/src/interval_timer_engine.dart';
import 'package:phoenix/src/interval_timer_page.dart';
import 'package:phoenix/src/local_notification_schedule.dart';
import 'package:phoenix/src/local_collaboration_engine.dart';
import 'package:phoenix/src/local_performance_profiler.dart';
import 'package:phoenix/src/media_portability_engine.dart';
import 'package:phoenix/src/media_portability_page.dart';
import 'package:phoenix/src/meal_intelligence_engine.dart';
import 'package:phoenix/src/meal_intelligence_page.dart';
import 'package:phoenix/src/mobility_intelligence_engine.dart';
import 'package:phoenix/src/mobility_intelligence_page.dart';
import 'package:phoenix/src/models/fitness_models.dart';
import 'package:phoenix/src/mobility_page.dart';
import 'package:phoenix/src/music_link.dart';
import 'package:phoenix/src/nutrition_analytics_engine.dart';
import 'package:phoenix/src/nutrition_goal_engine.dart';
import 'package:phoenix/src/nutrition_page.dart';
import 'package:phoenix/src/nutrition_planner_engine.dart';
import 'package:phoenix/src/nutrition_planner_page.dart';
import 'package:phoenix/src/recommended_nutrition_engine.dart';
import 'package:phoenix/src/recommended_nutrition_page.dart';
import 'package:phoenix/src/onboarding_page.dart';
import 'package:phoenix/src/operational_readiness_engine.dart';
import 'package:phoenix/src/operations_studio_page.dart';
import 'package:phoenix/src/periodization_engine.dart';
import 'package:phoenix/src/phoenix_l10n.dart';
import 'package:phoenix/src/phoenix_translations.dart';
import 'package:phoenix/src/phoenix_toolbox_page.dart';
import 'package:phoenix/src/program_editor_page.dart';
import 'package:phoenix/src/program_architecture_engine.dart';
import 'package:phoenix/src/program_architecture_page.dart';
import 'package:phoenix/src/program_history_page.dart';
import 'package:phoenix/src/profile_editor_page.dart';
import 'package:phoenix/src/recovery_engine.dart';
import 'package:phoenix/src/recovery_intelligence_engine.dart';
import 'package:phoenix/src/recovery_intelligence_page.dart';
import 'package:phoenix/src/recovery_lab_engine.dart';
import 'package:phoenix/src/recovery_lab_page.dart';
import 'package:phoenix/src/reports_studio_engine.dart';
import 'package:phoenix/src/reports_studio_page.dart';
import 'package:phoenix/src/release_audit_engine.dart';
import 'package:phoenix/src/reliability_center_page.dart';
import 'package:phoenix/src/running_engine.dart';
import 'package:phoenix/src/running_lab_page.dart';
import 'package:phoenix/src/safety_adaptation_engine.dart';
import 'package:phoenix/src/safety_adaptation_page.dart';
import 'package:phoenix/src/secure_backup_engine.dart';
import 'package:phoenix/src/sleep_stress_engine.dart';
import 'package:phoenix/src/sleep_stress_page.dart';
import 'package:phoenix/src/session_preparation_engine.dart';
import 'package:phoenix/src/state/fitness_store.dart';
import 'package:phoenix/src/spotify_card.dart';
import 'package:phoenix/src/strength_test_page.dart';
import 'package:phoenix/src/strength_lab_engine.dart';
import 'package:phoenix/src/strength_lab_page.dart';
import 'package:phoenix/src/storage_migration_engine.dart';
import 'package:phoenix/src/structured_import_export_engine.dart';
import 'package:phoenix/src/training_analytics_engine.dart';
import 'package:phoenix/src/training_schedule.dart';
import 'package:phoenix/src/weekly_planner_page.dart';
import 'package:phoenix/src/vault_security_page.dart';

class MemoryRepository implements FitnessRepository {
  FitnessData value = FitnessData.initial();

  @override
  Future<FitnessData> load() async => value;

  @override
  Future<void> save(FitnessData data) async => value = data;
}

const _coreWorkoutIds = {
  'full-body-a',
  'full-body-b',
  'iron-upper',
  'iron-lower',
  'iron-hybrid',
  'calisthenics-strength',
  'calisthenics-skills',
  'iron-engine',
  'weighted-calisthenics',
};

void main() {
  test('ολοκλήρωση προπόνησης δημιουργεί μία καταχώρηση', () async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    store.startWorkout(store.data.templates.first);
    store.logSet(
      exerciseName: store.data.templates.first.exercises.first,
      reps: 5,
      weightKilograms: 100,
      rir: 1,
      holdSeconds: 0,
    );
    await store.finishWorkout();

    expect(store.hasActiveWorkout, isFalse);
    expect(store.data.logs, hasLength(1));
    expect(store.data.logs.first.sets, hasLength(1));
    expect(store.workoutsThisWeek, 1);
    expect(store.lifetimeSets, 1);
    expect(store.lifetimeVolume, 500);
    expect(store.bestEstimatedOneRepMax, closeTo(116.67, .01));
  });

  test('στατικό hold καταγράφεται χωρίς επαναλήψεις', () async {
    final store = FitnessStore(MemoryRepository());
    store.startWorkout(store.data.templates.first);

    store.logSet(
      exerciseName: 'Hollow body hold',
      reps: 0,
      weightKilograms: 0,
      rir: 2,
      holdSeconds: 30,
    );

    expect(store.activeSets.single.holdSeconds, 30);
  });

  test('progressive overload αυξάνει φορτίο μόνο με επαρκές απόθεμα', () async {
    final store = FitnessStore(MemoryRepository());
    final exercise = store.data.templates.first.exercises.first;
    await store.load();
    final prescription = store.data.templates.first.prescriptionFor(exercise);
    expect(prescription.maxReps, 8);
    expect(
      store.data.templates.first.exercisePrescriptions,
      contains(exercise),
    );
    store.startWorkout(store.data.templates.first);
    store.logSet(
      exerciseName: exercise,
      reps: 8,
      weightKilograms: 100,
      rir: 2,
      holdSeconds: 0,
    );
    await store.finishWorkout();

    final suggestion = store.progressionFor(exercise);

    expect(suggestion.targetWeightKilograms, 102.5);
    expect(suggestion.targetReps, 5);
    expect(store.exerciseRecords.single.exerciseName, exercise);
  });

  test('παλιό προφίλ αποκτά καλλισθενική χωρίς απώλεια δεδομένων', () async {
    final repository = MemoryRepository()
      ..value = FitnessData(
        profile: const UserProfile(
          goal: 'Δύναμη',
          trainingPlace: 'Γυμναστήριο',
          equipment: 'Πλήρες',
          daysPerWeek: 3,
          heightCentimeters: 180,
          weightKilograms: 80,
        ),
        templates: const [
          WorkoutTemplate(
            id: 'legacy',
            name: 'Παλιό πρόγραμμα',
            exercises: ['Καθίσματα'],
          ),
        ],
        logs: const [],
        weights: const [],
        meals: const [],
        spotifyUrl: '',
      );
    final store = FitnessStore(repository);

    await store.load();

    expect(store.data.templates.first.id, 'legacy');
    expect(
      store.data.templates.first.exercisePrescriptions,
      contains('Καθίσματα'),
    );
    expect(
      repository.value.templates.first.exercisePrescriptions,
      contains('Καθίσματα'),
    );
    expect(
      store.data.templates.map((item) => item.id),
      contains('calisthenics-strength'),
    );
  });

  test('γεύμα ενημερώνει τα ημερήσια macros και αποθηκεύεται', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);

    await store.addMeal(
      name: 'Μεσημεριανό',
      calories: 650,
      proteinGrams: 45,
      carbohydrateGrams: 70,
      fatGrams: 20,
    );

    expect(store.todaysMeals, hasLength(1));
    expect(store.caloriesToday, 650);
    expect(store.proteinToday, 45);
    expect(store.carbohydratesToday, 70);
    expect(store.fatToday, 20);
    expect(repository.value.meals.single.name, 'Μεσημεριανό');
  });

  test('η λειτουργία preview παρακάμπτει προσωρινά το onboarding', () {
    final store = FitnessStore(MemoryRepository());
    expect(store.needsOnboarding, isTrue);

    store.previewWithoutProfile();

    expect(store.needsOnboarding, isFalse);
    expect(store.profile, isNull);
  });

  test(
    'Spotify URI κανονικοποιείται και μη έγκυρος σύνδεσμος απορρίπτεται',
    () async {
      final store = FitnessStore(MemoryRepository());

      await store.setSpotifyUrl('spotify:playlist:abc123');

      expect(store.spotifyUrl, 'https://open.spotify.com/playlist/abc123');
      expect(store.hasSpotifyLink, isTrue);
      await expectLater(
        store.setSpotifyUrl('https://example.com/not-spotify'),
        throwsFormatException,
      );
    },
  );

  test(
    'Apple Music σύνδεσμος αποθηκεύεται τοπικά και χωρίς tracking',
    () async {
      final store = FitnessStore(MemoryRepository());

      await store.setMusicUrl(
        'https://music.apple.com/gr/playlist/phoenix/pl.u-abc123?ls=1',
      );

      expect(
        store.musicUrl,
        'https://music.apple.com/gr/playlist/phoenix/pl.u-abc123',
      );
      expect(MusicLink.serviceFor(store.musicUrl), MusicService.appleMusic);
      await expectLater(
        store.setMusicUrl('https://example.com/not-music'),
        throwsFormatException,
      );
    },
  );

  testWidgets('η μουσική συνδέεται στο κινητό με επικόλληση Apple Music', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.getData') {
        return <String, dynamic>{
          'text':
              'https://music.apple.com/gr/playlist/phoenix/pl.u-mobile123?ls=1',
        };
      }
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SpotifyCard(store: store)),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('connect-apple-music')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('paste-music-link')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-music-link')));
    await tester.pumpAndSettle();

    expect(store.musicUrl, contains('music.apple.com'));
    expect(store.musicUrl, isNot(contains('ls=1')));
    expect(find.textContaining('Apple Music CONNECTED'), findsOneWidget);
  });

  test('μη έγκυρο βάρος απορρίπτεται πριν την αποθήκευση', () async {
    final store = FitnessStore(MemoryRepository());
    expect(() => store.addWeight(10), throwsFormatException);
    expect(store.data.weights, isEmpty);
  });

  test('το προφίλ δημιουργεί deterministic αρχικό πρόγραμμα', () async {
    final store = FitnessStore(MemoryRepository());
    await store.saveProfile(
      const UserProfile(
        goal: 'Μυϊκή ανάπτυξη',
        trainingPlace: 'Σπίτι',
        equipment: 'Λάστιχα',
        daysPerWeek: 3,
        heightCentimeters: 180,
        weightKilograms: 80,
        experienceLevel: 'Προχωρημένος',
        sessionMinutes: 60,
        limitations: 'Αποφυγή αλμάτων',
      ),
    );

    expect(store.needsOnboarding, isFalse);
    expect(
      store.data.templates.map((item) => item.id),
      containsAll([
        'iron-upper',
        'iron-lower',
        'iron-hybrid',
        'calisthenics-strength',
        'calisthenics-skills',
        'iron-engine',
      ]),
    );
    expect(
      store.data.templates.map((item) => item.id),
      isNot(contains('weighted-calisthenics')),
    );
    expect(store.data.weights.first.kilograms, 80);
    expect(store.profile!.experienceLevel, 'Προχωρημένος');
    expect(store.profile!.sessionMinutes, 60);
    expect(store.profile!.limitations, 'Αποφυγή αλμάτων');
    expect(store.data.templates.first.exercises, hasLength(6));
    expect(store.data.templates.first.prescription, contains('RIR 1–2'));
    expect(store.data.templates.first.coachingCue, contains('Τεχνικό stop'));
    expect(
      store.data.templates.every(
        (template) =>
            template.exercisePrescriptions.length == template.exercises.length,
      ),
      isTrue,
    );
  });

  test('προχωρημένο γυμναστήριο ενεργοποιεί weighted calisthenics', () async {
    final store = FitnessStore(MemoryRepository());
    await store.saveProfile(
      const UserProfile(
        goal: 'Δύναμη',
        trainingPlace: 'Γυμναστήριο',
        equipment: 'Πλήρες γυμναστήριο',
        daysPerWeek: 4,
        heightCentimeters: 182,
        weightKilograms: 84,
        experienceLevel: 'Προχωρημένος',
        sessionMinutes: 45,
      ),
    );

    final weighted = store.data.templates.singleWhere(
      (item) => item.id == 'weighted-calisthenics',
    );
    expect(weighted.exercises, contains('Έλξεις με βάρος'));
    expect(weighted.restSeconds, 150);
    expect(weighted.prescription, contains('4–8'));
  });

  test('ο program engine δίνει διαφορετική συνταγή ανά τύπο άσκησης', () async {
    final store = FitnessStore(MemoryRepository());
    await store.saveProfile(
      const UserProfile(
        goal: 'Δύναμη',
        trainingPlace: 'Γυμναστήριο',
        equipment: 'Πλήρες γυμναστήριο',
        daysPerWeek: 5,
        heightCentimeters: 182,
        weightKilograms: 84,
        experienceLevel: 'Προχωρημένος',
        sessionMinutes: 60,
      ),
    );

    final upper = store.data.templates.singleWhere(
      (template) => template.id == 'iron-upper',
    );
    final lower = store.data.templates.singleWhere(
      (template) => template.id == 'iron-lower',
    );
    final engine = store.data.templates.singleWhere(
      (template) => template.id == 'iron-engine',
    );
    final skills = store.data.templates.singleWhere(
      (template) => template.id == 'calisthenics-skills',
    );

    final press = upper.prescriptionFor('Πιέσεις στήθους με αλτήρες');
    final splitSquat = lower.prescriptionFor('Bulgarian split squat');
    final sled = engine.prescriptionFor('Sled push');
    final handstand = skills.prescriptionFor('Handstand στον τοίχο');

    expect(press.workingSets, 3);
    expect(press.minReps, 5);
    expect(press.maxReps, 8);
    expect(press.restSeconds, 150);
    expect(splitSquat.note, contains('ανά πλευρά'));
    expect(sled.isTimed, isTrue);
    expect(sled.minHoldSeconds, 40);
    expect(sled.restSeconds, 20);
    expect(handstand.targetRir, 3);
  });

  test('οι exercise prescriptions αποθηκεύονται και φορτώνονται από JSON', () {
    const prescription = ExercisePrescription(
      workingSets: 4,
      minReps: 6,
      maxReps: 10,
      targetRir: 2,
      restSeconds: 120,
      tempo: '3–1–1',
      note: 'Δοκιμή',
    );
    const template = WorkoutTemplate(
      id: 'test',
      name: 'Test',
      exercises: ['Άσκηση'],
      exercisePrescriptions: {'Άσκηση': prescription},
    );

    final decoded = WorkoutTemplate.fromJson(
      jsonDecode(jsonEncode(template.toJson())) as Map<String, dynamic>,
    );
    final restored = decoded.prescriptionFor('Άσκηση');

    expect(restored.workingSets, 4);
    expect(restored.tempo, '3–1–1');
    expect(restored.note, 'Δοκιμή');
  });

  test(
    'αρχάριος παίρνει regressions και όχι advanced weighted πρόγραμμα',
    () async {
      final store = FitnessStore(MemoryRepository());
      await store.saveProfile(
        const UserProfile(
          goal: 'Γενική φυσική κατάσταση',
          trainingPlace: 'Σπίτι',
          equipment: 'Λάστιχα',
          daysPerWeek: 3,
          heightCentimeters: 170,
          weightKilograms: 70,
          experienceLevel: 'Αρχάριος',
          sessionMinutes: 30,
        ),
      );

      final upper = store.data.templates.singleWhere(
        (item) => item.id == 'iron-upper',
      );
      expect(upper.exercises, hasLength(4));
      expect(upper.exercises.first, 'Κάμψεις σε υπερυψωμένη επιφάνεια');
      expect(upper.exercises, contains('Κωπηλατική με λάστιχο — αργό tempo'));
      expect(
        store.data.templates.map((item) => item.id),
        isNot(contains('weighted-calisthenics')),
      );
    },
  );

  test('κάθε προτεινόμενη άσκηση διαθέτει οπτικό οδηγό', () async {
    final gymStore = FitnessStore(MemoryRepository());
    final homeStore = FitnessStore(MemoryRepository());
    await gymStore.saveProfile(
      const UserProfile(
        goal: 'Δύναμη',
        trainingPlace: 'Γυμναστήριο',
        equipment: 'Πλήρες γυμναστήριο',
        daysPerWeek: 5,
        heightCentimeters: 180,
        weightKilograms: 80,
        experienceLevel: 'Προχωρημένος',
        sessionMinutes: 60,
      ),
    );
    await homeStore.saveProfile(
      const UserProfile(
        goal: 'Γενική φυσική κατάσταση',
        trainingPlace: 'Σπίτι',
        equipment: 'Λάστιχα',
        daysPerWeek: 4,
        heightCentimeters: 170,
        weightKilograms: 70,
        experienceLevel: 'Αρχάριος',
        sessionMinutes: 60,
      ),
    );

    final gymExercises = [
      for (final template in gymStore.data.templates) ...template.exercises,
    ];
    final homeExercises = [
      for (final template in homeStore.data.templates) ...template.exercises,
    ];
    final missingGym = gymExercises
        .where((exercise) => ExerciseGuideCatalog.forExercise(exercise) == null)
        .toSet();
    final missingHome = homeExercises
        .where(
          (exercise) =>
              ExerciseGuideCatalog.forExercise(exercise, atHome: true) == null,
        )
        .toSet();

    expect(missingGym, isEmpty);
    expect(missingHome, isEmpty);
  });

  test(
    'το σπίτι χωρίς εξοπλισμό δίνει μόνο οικιακό πρόγραμμα και εικόνες',
    () async {
      final store = FitnessStore(MemoryRepository());
      await store.saveProfile(
        const UserProfile(
          goal: 'Γενική φυσική κατάσταση',
          trainingPlace: 'Σπίτι',
          equipment: 'Χωρίς εξοπλισμό',
          daysPerWeek: 2,
          heightCentimeters: 170,
          weightKilograms: 70,
          experienceLevel: 'Αρχάριος',
          sessionMinutes: 20,
        ),
      );

      final templates = store.data.templates;
      final exercises = [
        for (final template in templates) ...template.exercises,
      ];
      final text =
          '${templates.map((item) => item.name).join(' ')} '
                  '${exercises.join(' ')}'
              .toLowerCase();

      expect(text, isNot(contains('iron')));
      expect(text, isNot(contains('λάστιχ')));
      expect(text, isNot(contains('αλτήρ')));
      expect(text, isNot(contains('σακίδ')));
      expect(templates.first.name, 'ΗΠΙΑ ΑΡΧΗ ΣΤΟ ΣΠΙΤΙ — A');
      expect(
        templates.first.exercises,
        containsAll([
          'Κάθισμα και σήκωμα από καρέκλα',
          'Κάμψεις στον τοίχο',
          'Γέφυρα γλουτών στο πάτωμα',
        ]),
      );

      final guides = exercises
          .map(
            (exercise) =>
                ExerciseGuideCatalog.forExercise(exercise, atHome: true),
          )
          .toList();
      expect(guides, everyElement(isNotNull));
      expect(
        guides.map((guide) => guide!.assetPath),
        everyElement(contains('assets/exercise_guides/home-')),
      );
    },
  );

  test(
    'κάθε επιλογή εξοπλισμού στο σπίτι κρατά αποκλειστικά home assets',
    () async {
      for (final equipment in const [
        'Αλτήρες / βαράκια',
        'Λάστιχα',
        'Μονόζυγο',
        'Απλός διάδρομος',
      ]) {
        final store = FitnessStore(MemoryRepository());
        final profile = UserProfile(
          goal: 'Γενική φυσική κατάσταση',
          trainingPlace: 'Σπίτι',
          equipment: equipment,
          daysPerWeek: 4,
          heightCentimeters: 170,
          weightKilograms: 70,
          experienceLevel: 'Αρχάριος',
          sessionMinutes: 45,
        );
        await store.saveProfile(profile);

        final exercises = [
          for (final template in store.data.templates) ...template.exercises,
        ];
        final guides = exercises
            .map(
              (exercise) =>
                  ExerciseGuideCatalog.forExercise(exercise, atHome: true),
            )
            .toList();

        expect(guides, everyElement(isNotNull), reason: equipment);
        expect(
          guides.map((guide) => guide!.assetPath),
          everyElement(contains('assets/exercise_guides/home-')),
          reason: equipment,
        );
        expect(
          exercises.every(
            (exercise) =>
                EquipmentAvailability.supportsExercise(exercise, profile),
          ),
          isTrue,
          reason: equipment,
        );
      }
    },
  );

  test('ο κοινός κανόνας εξοπλισμού εφαρμόζεται σε κάθε οικιακή άσκηση', () {
    const profile = UserProfile(
      goal: 'Γενική φυσική κατάσταση',
      trainingPlace: 'Σπίτι',
      equipment: 'Χωρίς εξοπλισμό',
      daysPerWeek: 3,
      heightCentimeters: 170,
      weightKilograms: 70,
    );

    expect(EquipmentAvailability.supportsExercise('Bird dog', profile), isTrue);
    expect(
      EquipmentAvailability.supportsExercise(
        'Πιέσεις ώμων με λάστιχο',
        profile,
      ),
      isFalse,
    );
    expect(
      EquipmentAvailability.supportsExercise('Goblet squat με αλτήρα', profile),
      isFalse,
    );
    expect(
      EquipmentAvailability.supportsExercise('Περπάτημα σε διάδρομο', profile),
      isFalse,
    );
    expect(
      EquipmentAvailability.supportsExercise('Αυστηρές έλξεις', profile),
      isFalse,
    );
  });

  test('οι εναλλακτικές χωρίς εξοπλισμό δεν προτείνουν λάστιχο ή μηχάνημα', () {
    const profile = UserProfile(
      goal: 'Γενική φυσική κατάσταση',
      trainingPlace: 'Σπίτι',
      equipment: 'Χωρίς εξοπλισμό',
      daysPerWeek: 3,
      heightCentimeters: 170,
      weightKilograms: 70,
    );
    final alternatives = ExerciseSubstitutionEngine.alternativesFor(
      exercise: 'Πιέσεις ώμων με λάστιχο',
      profile: profile,
      excludedExercises: const [],
    );

    expect(alternatives.map((item) => item.name), contains('Pike push-ups'));
    expect(
      alternatives.every(
        (item) => EquipmentAvailability.supportsExercise(item.name, profile),
      ),
      isTrue,
    );
  });

  test('η αναζήτηση κρύβει ασκήσεις που απαιτούν εξοπλισμό που λείπει', () {
    const profile = UserProfile(
      goal: 'Γενική φυσική κατάσταση',
      trainingPlace: 'Σπίτι',
      equipment: 'Χωρίς εξοπλισμό',
      daysPerWeek: 3,
      heightCentimeters: 170,
      weightKilograms: 70,
    );
    final data = FitnessData.initial().copyWith(profile: profile);
    final exercises = GlobalSearchEngine.search(
      data,
      'exercise',
    ).where((item) => item.type == SearchResultType.exercise).toList();

    expect(exercises, isNotEmpty);
    expect(
      exercises.every(
        (item) => EquipmentAvailability.supportsExercise(item.title, profile),
      ),
      isTrue,
    );
  });

  test('το μονόζυγο στο σπίτι έχει δικό του οδηγό χωρίς λάστιχο', () {
    final guide = ExerciseGuideCatalog.forExercise(
      'Αρνητικές έλξεις με στήριξη ποδιών',
      atHome: true,
    );

    expect(guide, isNotNull);
    expect(guide!.assetPath, contains('home-pullup-guide-v1.png'));
    expect(guide.equipmentLabel, contains('ΧΩΡΙΣ ΛΑΣΤΙΧΟ'));
  });

  test('η προθέρμανση στο σπίτι σέβεται τον πραγματικό εξοπλισμό', () {
    const profile = UserProfile(
      goal: 'Γενική φυσική κατάσταση',
      trainingPlace: 'Σπίτι',
      equipment: 'Χωρίς εξοπλισμό',
      daysPerWeek: 2,
      heightCentimeters: 170,
      weightKilograms: 70,
    );
    const workout = WorkoutTemplate(
      id: 'home-test',
      name: 'Σπίτι',
      exercises: ['Κάθισμα και σήκωμα από καρέκλα', 'Κάμψεις στον τοίχο'],
    );

    final plan = SessionPreparationEngine.forWorkout(workout, profile: profile);
    final cues = plan.warmup.map((step) => step.cue).join(' ').toLowerCase();

    expect(cues, contains('σταθερή καρέκλα'));
    expect(cues, contains('χωρίς εξοπλισμό'));
    expect(cues, isNot(contains('band pull-apart')));
    expect(cues, isNot(contains('rowing')));
  });

  test(
    'παλιό αυτόματο home πρόγραμμα ανανεώνεται χωρίς απώλεια custom',
    () async {
      final repository = MemoryRepository();
      repository.value = FitnessData.initial().copyWith(
        profile: const UserProfile(
          goal: 'Γενική φυσική κατάσταση',
          trainingPlace: 'Σπίτι',
          equipment: 'Χωρίς εξοπλισμό',
          daysPerWeek: 2,
          heightCentimeters: 170,
          weightKilograms: 70,
          experienceLevel: 'Αρχάριος',
          sessionMinutes: 20,
        ),
        templates: const [
          WorkoutTemplate(
            id: 'full-body-a',
            name: 'IRON FULL BODY — A',
            exercises: ['Καθίσματα σε πάγκο με σακίδιο'],
          ),
          WorkoutTemplate(
            id: 'custom-home-favorite',
            name: 'Το δικό μου πρόγραμμα',
            exercises: ['Η δική μου άσκηση'],
          ),
        ],
      );

      final store = FitnessStore(repository);
      await store.load();

      expect(
        store.data.templates
            .singleWhere((item) => item.id == 'full-body-a')
            .name,
        'ΗΠΙΑ ΑΡΧΗ ΣΤΟ ΣΠΙΤΙ — A',
      );
      expect(
        store.data.templates
            .singleWhere((item) => item.id == 'custom-home-favorite')
            .exercises,
        ['Η δική μου άσκηση'],
      );
    },
  );

  test(
    'η αφαίρεση λάστιχου ανανεώνει αυτόματα μόνο τα βασικά προγράμματα',
    () async {
      final repository = MemoryRepository();
      final store = FitnessStore(repository);
      await store.saveProfile(
        const UserProfile(
          goal: 'Γενική φυσική κατάσταση',
          trainingPlace: 'Σπίτι',
          equipment: 'Λάστιχα',
          daysPerWeek: 4,
          heightCentimeters: 170,
          weightKilograms: 70,
          experienceLevel: 'Αρχάριος',
          sessionMinutes: 45,
        ),
      );
      final personal = store.createCustomWorkoutDraft().copyWith(
        name: 'Το δικό μου πρόγραμμα',
        exercises: const ['Η δική μου άσκηση'],
      );
      await store.updateWorkoutTemplate(personal);
      expect(
        store.data.templates
            .where((item) => _coreWorkoutIds.contains(item.id))
            .expand((item) => item.exercises)
            .join(' ')
            .toLowerCase(),
        contains('λάστιχ'),
      );

      await store.updateProfile(
        const UserProfile(
          goal: 'Γενική φυσική κατάσταση',
          trainingPlace: 'Σπίτι',
          equipment: 'Χωρίς εξοπλισμό',
          daysPerWeek: 4,
          heightCentimeters: 170,
          weightKilograms: 70,
          experienceLevel: 'Αρχάριος',
          sessionMinutes: 45,
        ),
      );

      final coreText = store.data.templates
          .where((item) => _coreWorkoutIds.contains(item.id))
          .expand((item) => item.exercises)
          .join(' ')
          .toLowerCase();
      expect(coreText, isNot(contains('λάστιχ')));
      expect(coreText, isNot(contains('band')));
      expect(
        store.data.templates.singleWhere((item) => item.id == personal.id),
        isNotNull,
      );
    },
  );

  test(
    'η φόρτωση επισκευάζει αποθηκευμένο πρόγραμμα με λάστιχο που λείπει',
    () async {
      final repository = MemoryRepository();
      repository.value = FitnessData.initial().copyWith(
        profile: const UserProfile(
          goal: 'Γενική φυσική κατάσταση',
          trainingPlace: 'Σπίτι',
          equipment: 'Χωρίς εξοπλισμό',
          daysPerWeek: 4,
          heightCentimeters: 170,
          weightKilograms: 70,
          experienceLevel: 'Αρχάριος',
          sessionMinutes: 45,
        ),
        templates: const [
          WorkoutTemplate(
            id: 'iron-upper',
            name: 'ΣΠΙΤΙ — Άνω σώμα',
            exercises: ['Πιέσεις ώμων με λάστιχο'],
          ),
          WorkoutTemplate(
            id: 'custom-home-favorite',
            name: 'Το δικό μου πρόγραμμα',
            exercises: ['Η δική μου άσκηση'],
          ),
        ],
      );

      final store = FitnessStore(repository);
      await store.load();

      final coreText = store.data.templates
          .where((item) => _coreWorkoutIds.contains(item.id))
          .expand((item) => item.exercises)
          .join(' ')
          .toLowerCase();
      expect(coreText, isNot(contains('λάστιχ')));
      expect(coreText, isNot(contains('band')));
      expect(
        store.data.templates
            .singleWhere((item) => item.id == 'custom-home-favorite')
            .exercises,
        ['Η δική μου άσκηση'],
      );
    },
  );

  test('η σημερινή αποστολή συνεχίζει στην επόμενη προπόνηση', () async {
    final store = FitnessStore(MemoryRepository());
    await store.saveProfile(
      const UserProfile(
        goal: 'Δύναμη',
        trainingPlace: 'Γυμναστήριο',
        equipment: 'Πλήρες γυμναστήριο',
        daysPerWeek: 3,
        heightCentimeters: 180,
        weightKilograms: 80,
        experienceLevel: 'Μέτριος',
        sessionMinutes: 45,
      ),
    );

    expect(store.recommendedWorkout.id, 'iron-upper');
    expect(store.weeklyWorkoutTarget, 3);

    final completed = store.recommendedWorkout;
    store.startWorkout(completed);
    store.logSet(
      exerciseName: completed.exercises.first,
      reps: 8,
      weightKilograms: 20,
      rir: 2,
      holdSeconds: 0,
    );
    await store.finishWorkout();

    expect(store.recommendedWorkout.id, 'iron-lower');
    expect(store.workoutsInCurrentWeek, 1);
    expect(store.weeklyWorkoutProgress, closeTo(1 / 3, .001));
    expect(store.rotationSummary, contains('IRON UPPER'));
  });

  test('το εβδομαδιαίο πλάνο μοιράζει σωστά τις ημέρες αποκατάστασης', () {
    expect(TrainingScheduleEngine.distributedWeekdays(2), [1, 4]);
    expect(TrainingScheduleEngine.distributedWeekdays(3), [1, 3, 5]);
    expect(TrainingScheduleEngine.distributedWeekdays(4), [1, 2, 4, 6]);
    expect(TrainingScheduleEngine.distributedWeekdays(5), [1, 2, 3, 5, 6]);
    expect(TrainingScheduleEngine.distributedWeekdays(7), [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
    ]);
  });

  test(
    'το εβδομαδιαίο πλάνο συνεχίζει τη σειρά και αναγνωρίζει ολοκλήρωση',
    () {
      final templates = FitnessData.initial().templates;
      final previousWorkout = WorkoutLog(
        templateName: templates.first.name,
        completedAt: DateTime(2026, 7, 26, 12),
        minutes: 45,
      );
      final completedThisWeek = WorkoutLog(
        templateName: templates[1].name,
        completedAt: DateTime(2026, 7, 28, 18),
        minutes: 45,
      );

      final schedule = TrainingScheduleEngine.build(
        now: DateTime(2026, 7, 29),
        daysPerWeek: 3,
        rotation: templates,
        logs: [completedThisWeek, previousWorkout],
      );

      expect(schedule.weekStart, DateTime(2026, 7, 27));
      expect(schedule.entries.map((entry) => entry.date.weekday), [1, 3, 5]);
      expect(schedule.entries.first.template.id, 'calisthenics-strength');
      expect(schedule.entries.first.isCompleted, isTrue);
      expect(schedule.completedCount, 1);
      expect(
        schedule.nextEntry(DateTime(2026, 7, 29))!.template.id,
        'iron-engine',
      );
    },
  );

  test('χαμηλό readiness μειώνει με ασφάλεια τον σημερινό όγκο', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();
    await store.saveRecoveryCheckIn(
      sleepHours: 4.5,
      energy: 1,
      soreness: 5,
      stress: 5,
    );
    final original = store.recommendedWorkout;
    final originalPrescription = original.prescriptionFor(
      original.exercises.first,
    );

    store.startWorkout(original);

    final adapted = store.activeWorkout!.prescriptionFor(
      store.activeWorkout!.exercises.first,
    );
    expect(store.todaysRecoveryPlan!.mode, RecoveryMode.recovery);
    expect(adapted.workingSets, lessThan(originalPrescription.workingSets));
    expect(adapted.targetRir, greaterThan(originalPrescription.targetRir));
    expect(adapted.note, contains('Recovery RED'));
    expect(repository.value.recoveryChecks, hasLength(1));
  });

  test('υψηλό readiness διατηρεί το πλήρες πρόγραμμα', () {
    final plan = RecoveryEngine.evaluate(
      RecoveryCheckIn(
        sleepHours: 8,
        energy: 5,
        soreness: 1,
        stress: 1,
        recordedAt: DateTime(2026, 7, 29),
      ),
    );

    expect(plan.mode, RecoveryMode.ready);
    expect(plan.score, greaterThanOrEqualTo(76));
    expect(plan.setReduction, 0);
    expect(plan.loadFactor, 1);
  });

  test('η αντικατάσταση άσκησης κρατά prescription και προστατεύει τα σετ', () {
    final store = FitnessStore(MemoryRepository());
    final workout = store.data.templates.first;
    final original = workout.exercises.first;
    store.startWorkout(workout);
    final alternative = store.alternativesForActiveExercise(original).first;

    store.replaceActiveExercise(
      exercise: original,
      replacement: alternative.name,
    );

    expect(store.activeWorkout!.exercises, contains(alternative.name));
    expect(store.activeWorkout!.exercises, isNot(contains(original)));
    expect(
      store.activeWorkout!.exercisePrescriptions,
      contains(alternative.name),
    );

    store.logSet(
      exerciseName: alternative.name,
      reps: 8,
      weightKilograms: 10,
      rir: 2,
      holdSeconds: 0,
    );
    expect(
      () => store.replaceActiveExercise(
        exercise: alternative.name,
        replacement: original,
      ),
      throwsFormatException,
    );
  });

  test('οι εναλλακτικές στο σπίτι σέβονται τον διαθέσιμο εξοπλισμό', () {
    const profile = UserProfile(
      goal: 'Δύναμη',
      trainingPlace: 'Σπίτι',
      equipment: 'Λάστιχα',
      daysPerWeek: 3,
      heightCentimeters: 180,
      weightKilograms: 80,
    );
    final alternatives = ExerciseSubstitutionEngine.alternativesFor(
      exercise: 'Αυστηρές έλξεις',
      profile: profile,
      excludedExercises: const [],
    );

    expect(
      alternatives.map((item) => item.name),
      contains('Κωπηλατική με λάστιχο — αργό tempo'),
    );
    expect(
      alternatives.map((item) => item.name),
      isNot(contains('Έλξεις τροχαλίας ουδέτερη λαβή')),
    );
  });

  test('οι nutrition στόχοι προκύπτουν deterministic από το προφίλ', () {
    const profile = UserProfile(
      goal: 'Δύναμη',
      trainingPlace: 'Γυμναστήριο',
      equipment: 'Πλήρες γυμναστήριο',
      daysPerWeek: 4,
      heightCentimeters: 180,
      weightKilograms: 80,
    );

    final targets = NutritionGoalEngine.calculate(
      profile: profile,
      currentWeightKilograms: 80,
    );

    expect(targets.calories, 2560);
    expect(targets.proteinGrams, 144);
    expect(targets.fatGrams, 64);
    expect(targets.carbohydrateGrams, 352);
    expect(targets.goalLabel, contains('Δύναμη'));
  });

  test('το recovery check-in αποθηκεύεται και επανέρχεται από JSON', () {
    final original = RecoveryCheckIn(
      sleepHours: 7.5,
      energy: 4,
      soreness: 2,
      stress: 3,
      recordedAt: DateTime(2026, 7, 29, 9),
    );

    final restored = RecoveryCheckIn.fromJson(
      jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
    );

    expect(restored.sleepHours, 7.5);
    expect(restored.energy, 4);
    expect(restored.soreness, 2);
    expect(restored.stress, 3);
  });

  test(
    'το πλήρες backup κάνει ασφαλές round-trip όλων των δεδομένων',
    () async {
      final source = FitnessStore(MemoryRepository());
      await source.load();
      await source.addMeal(
        name: 'Backup meal',
        calories: 500,
        proteinGrams: 35,
        carbohydrateGrams: 50,
        fatGrams: 15,
      );
      await source.saveRecoveryCheckIn(
        sleepHours: 7.5,
        energy: 4,
        soreness: 2,
        stress: 2,
      );
      final workout = source.data.templates.first;
      source.startWorkout(workout);
      source.logSet(
        exerciseName: workout.exercises.first,
        reps: 8,
        weightKilograms: 20,
        rir: 2,
        holdSeconds: 0,
      );
      await source.finishWorkout();
      final backup = source.exportBackup();
      final targetRepository = MemoryRepository();
      final restored = FitnessStore(targetRepository);

      await restored.restoreBackup(backup);

      expect(jsonDecode(backup)['schemaVersion'], 2);
      expect(restored.data.logs, hasLength(1));
      expect(restored.data.meals.single.name, 'Backup meal');
      expect(restored.data.recoveryChecks, hasLength(1));
      expect(restored.data.templates.length, source.data.templates.length);
      expect(targetRepository.value.logs, hasLength(1));
    },
  );

  test('κατεστραμμένο backup απορρίπτεται χωρίς αλλαγή δεδομένων', () async {
    final store = FitnessStore(MemoryRepository());
    final originalTemplates = store.data.templates.length;

    await expectLater(
      store.restoreBackup('{"schemaVersion":2,"data":{"logs":[]}}'),
      throwsFormatException,
    );

    expect(store.data.templates, hasLength(originalTemplates));
  });

  test('ο Program Builder αποθηκεύει σειρά, όνομα και prescription', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();
    final original = store.data.templates.first;
    final exercises = original.exercises.reversed.toList();
    final firstExercise = exercises.first;
    final originalPrescription = original.prescriptionFor(firstExercise);
    final editedPrescription = ExercisePrescription(
      workingSets: 5,
      minReps: originalPrescription.minReps,
      maxReps: originalPrescription.maxReps,
      targetRir: originalPrescription.targetRir,
      restSeconds: originalPrescription.restSeconds,
      tempo: originalPrescription.tempo,
      minHoldSeconds: originalPrescription.minHoldSeconds,
      maxHoldSeconds: originalPrescription.maxHoldSeconds,
      note: originalPrescription.note,
    );

    await store.updateWorkoutTemplate(
      original.copyWith(
        name: 'MY IRON PLAN',
        exercises: exercises,
        exercisePrescriptions: {
          ...original.exercisePrescriptions,
          firstExercise: editedPrescription,
        },
      ),
    );

    final saved = store.data.templates.first;
    expect(saved.name, 'MY IRON PLAN');
    expect(saved.exercises.first, firstExercise);
    expect(saved.prescriptionFor(firstExercise).workingSets, 5);
    expect(repository.value.templates.first.name, 'MY IRON PLAN');
  });

  test(
    'νέο προσωπικό πρόγραμμα προστίθεται χωρίς να αλλάζει τα υπάρχοντα',
    () async {
      final store = FitnessStore(MemoryRepository());
      await store.load();
      final originalCount = store.data.templates.length;
      final draft = store.createCustomWorkoutDraft().copyWith(
        name: 'CUSTOM PHOENIX',
      );

      await store.updateWorkoutTemplate(draft);

      expect(store.data.templates, hasLength(originalCount + 1));
      expect(
        store.data.templates.singleWhere((item) => item.id == draft.id).name,
        'CUSTOM PHOENIX',
      );
    },
  );

  test('τα achievements ξεκλειδώνουν deterministic', () {
    final workout = WorkoutLog(
      templateName: 'IRON',
      completedAt: DateTime.now(),
      minutes: 45,
      sets: [
        ExerciseSetLog(
          exerciseName: 'Goblet squat',
          reps: 8,
          weightKilograms: 20,
          rir: 2,
          holdSeconds: 0,
          loggedAt: DateTime.now(),
        ),
      ],
    );
    final data = FitnessData.initial().copyWith(logs: [workout]);

    final achievements = AchievementEngine.calculate(
      data,
      workoutsThisWeek: 1,
      weeklyTarget: 3,
    );

    expect(
      achievements
          .singleWhere((item) => item.kind == AchievementKind.firstSession)
          .unlocked,
      isTrue,
    );
    expect(
      achievements
          .singleWhere((item) => item.kind == AchievementKind.ironWeek)
          .progress,
      closeTo(1 / 3, .001),
    );
  });

  test('το periodization cycle περνά σε deload την τέταρτη εβδομάδα', () {
    final anchorLog = WorkoutLog(
      templateName: 'IRON',
      completedAt: DateTime(2026, 7, 6),
      minutes: 45,
    );
    final plan = PeriodizationEngine.currentPlan(
      now: DateTime(2026, 7, 27),
      logs: [anchorLog],
    );
    final template = FitnessData.initial().templates.first;
    final adapted = PeriodizationEngine.adaptWorkout(template, plan);

    expect(plan.week, 4);
    expect(plan.isDeload, isTrue);
    expect(
      adapted.prescriptionFor(template.exercises.first).workingSets,
      lessThan(template.prescriptionFor(template.exercises.first).workingSets),
    );
    expect(
      adapted.prescriptionFor(template.exercises.first).note,
      contains('DELOAD'),
    );
  });

  test('δύο πολύ δύσκολες συνεδρίες ενεργοποιούν πρόωρο deload advisor', () {
    final now = DateTime(2026, 7, 29);
    final logs = [
      WorkoutLog(
        templateName: 'A',
        completedAt: now.subtract(const Duration(days: 1)),
        minutes: 45,
        sessionRpe: 9,
      ),
      WorkoutLog(
        templateName: 'B',
        completedAt: now.subtract(const Duration(days: 3)),
        minutes: 50,
        sessionRpe: 10,
      ),
    ];
    const buildPlan = PeriodizationPlan(
      week: 2,
      label: 'BUILD',
      headline: 'Build',
      detail: 'Build',
      volumeFactor: 1,
      rirAdjustment: 0,
      loadFactor: 1,
    );

    final advice = PeriodizationEngine.deloadAdvice(
      plan: buildPlan,
      logs: logs,
      recoveryChecks: const [],
      now: now,
    );

    expect(advice.recommended, isTrue);
    expect(advice.reason, contains('RPE 9–10'));
  });

  test(
    'το preparation engine δημιουργεί warm-up και cooldown ανά πρόγραμμα',
    () {
      final workout = FitnessData.initial().templates.first;
      final preparation = SessionPreparationEngine.forWorkout(workout);

      expect(preparation.warmupMinutes, greaterThanOrEqualTo(6));
      expect(preparation.cooldownMinutes, greaterThanOrEqualTo(5));
      expect(
        preparation.warmup.map((step) => step.title),
        contains('Ισχία και αστράγαλοι'),
      );
      expect(
        preparation.warmup.map((step) => step.title),
        contains('Ώμοι και ωμοπλάτες'),
      );
    },
  );

  test('το Mobility Lab σέβεται limitation γονάτου', () {
    const profile = UserProfile(
      goal: 'Δύναμη',
      trainingPlace: 'Σπίτι',
      equipment: 'Λάστιχα',
      daysPerWeek: 3,
      heightCentimeters: 180,
      weightKilograms: 80,
      limitations: 'Ενόχληση στο γόνατο',
    );

    final routines = SessionPreparationEngine.mobilityRoutines(profile);

    expect(
      routines.map((routine) => routine.id),
      isNot(contains('squat-primer')),
    );
    expect(routines.map((routine) => routine.id), contains('full-reset'));
  });

  test('το session review αποθηκεύει RPE, σημείωση και pain flag', () async {
    final store = FitnessStore(MemoryRepository());
    final workout = store.data.templates.first;
    store.startWorkout(workout);
    store.logSet(
      exerciseName: workout.exercises.first,
      reps: 8,
      weightKilograms: 20,
      rir: 2,
      holdSeconds: 0,
    );

    await store.finishWorkout(
      sessionRpe: 8,
      notes: 'Καλή τεχνική, δύσκολο τέλος.',
      painArea: 'Γόνατο',
      painSeverity: 3,
    );

    final log = store.data.logs.first;
    expect(log.sessionRpe, 8);
    expect(log.notes, contains('Καλή τεχνική'));
    expect(log.painArea, 'Γόνατο');
    expect(log.painSeverity, 3);
  });

  test('τα weekly analytics υπολογίζουν μυϊκό όγκο και pain-aware report', () {
    final now = DateTime(2026, 7, 29);
    final log = WorkoutLog(
      templateName: 'IRON',
      completedAt: now,
      minutes: 50,
      sessionRpe: 8,
      painArea: 'Ώμος',
      painSeverity: 3,
      sets: [
        ExerciseSetLog(
          exerciseName: 'Πιέσεις στήθους με αλτήρες',
          reps: 8,
          weightKilograms: 20,
          rir: 2,
          holdSeconds: 0,
          loggedAt: now,
        ),
      ],
    );

    final volumes = TrainingAnalyticsEngine.weeklyMuscleVolume([log], now: now);
    final report = TrainingAnalyticsEngine.weeklyReport(
      logs: [log],
      workoutTarget: 3,
      now: now,
    );

    expect(volumes.singleWhere((volume) => volume.muscle == 'Στήθος').sets, 1);
    expect(volumes.singleWhere((volume) => volume.muscle == 'Ώμοι').sets, 1);
    expect(report.painFlags, 1);
    expect(report.headline, contains('pain flag'));
  });

  test(
    'duplicate, favorite και delete custom template είναι persistent',
    () async {
      final repository = MemoryRepository();
      final store = FitnessStore(repository);
      final draft = store.createCustomWorkoutDraft();
      await store.updateWorkoutTemplate(draft);
      await store.assignTemplateToWeekday(2, draft.id);

      final duplicate = await store.duplicateWorkoutTemplate(draft);
      await store.toggleWorkoutFavorite(duplicate.id);
      await store.deleteCustomWorkout(draft.id);

      expect(store.data.templates.any((item) => item.id == draft.id), isFalse);
      expect(
        store.data.templates
            .singleWhere((item) => item.id == duplicate.id)
            .isFavorite,
        isTrue,
      );
      expect(store.data.weeklyAssignments.containsValue(draft.id), isFalse);
      expect(repository.value.templates.length, store.data.templates.length);
    },
  );

  test(
    'tags, superset και circuit κάνουν backward-compatible JSON round-trip',
    () {
      final base = FitnessData.initial().templates.first;
      final enhanced = base.copyWith(
        tags: const ['Strength', 'Full body'],
        equipmentPreset: 'home-basic',
        blocks: [
          WorkoutBlock(
            id: 'super-a',
            type: 'superset',
            exercises: base.exercises.take(2).toList(),
          ),
          WorkoutBlock(
            id: 'circuit-a',
            type: 'circuit',
            exercises: base.exercises.skip(2).take(3).toList(),
          ),
        ],
      );

      final restored = WorkoutTemplate.fromJson(
        jsonDecode(jsonEncode(enhanced.toJson())) as Map<String, dynamic>,
      );

      expect(restored.tags, ['Strength', 'Full body']);
      expect(restored.blocks.length, 2);
      expect(restored.blocks.first.isSuperset, isTrue);
      expect(restored.blocks.last.isCircuit, isTrue);
      expect(restored.equipmentPreset, 'home-basic');
    },
  );

  test('equipment presets περιορίζουν ουσιαστικά τη βιβλιοθήκη', () {
    final filtered = EquipmentPresetCatalog.filterExercises(const [
      'Αυστηρές έλξεις',
      'Sled push',
      'Κάμψεις με παύση 1″',
      'Κωπηλατικό εργόμετρο',
    ], 'calisthenics');

    expect(filtered, contains('Αυστηρές έλξεις'));
    expect(filtered, contains('Κάμψεις με παύση 1″'));
    expect(filtered, isNot(contains('Sled push')));
  });

  test('το preset απλού διαδρόμου κρατά μόνο σχετικές κινήσεις', () {
    final filtered = EquipmentPresetCatalog.filterExercises(const [
      'Περπάτημα σε διάδρομο',
      'Brisk walk',
      'Sled push',
      'Πιέσεις στήθους με αλτήρες',
    ], 'treadmill-basic');

    expect(filtered, containsAll(['Περπάτημα σε διάδρομο', 'Brisk walk']));
    expect(filtered, isNot(contains('Sled push')));
    expect(filtered, isNot(contains('Πιέσεις στήθους με αλτήρες')));
  });

  test('rest-day builder δημιουργεί recovery circuit με ήπια ένταση', () {
    final store = FitnessStore(MemoryRepository());

    final restDay = store.createRestDayDraft();

    expect(restDay.isRecoveryDay, isTrue);
    expect(restDay.tags, contains('Recovery'));
    expect(restDay.blocks.single.isCircuit, isTrue);
    expect(
      restDay.exercisePrescriptions.values.every((item) => item.targetRir == 4),
      isTrue,
    );
  });

  test('χειροκίνητη ανάθεση template υπερισχύει στο weekly schedule', () {
    final templates = FitnessData.initial().templates;
    final schedule = TrainingScheduleEngine.build(
      now: DateTime(2026, 7, 29),
      daysPerWeek: 2,
      rotation: templates.take(2).toList(),
      catalog: templates,
      logs: const [],
      assignments: {'2': templates.last.id},
    );

    expect(
      schedule.entries
          .singleWhere((entry) => entry.date.weekday == 2)
          .template
          .id,
      templates.last.id,
    );
  });

  test(
    'version history κρατά snapshot και επιτρέπει ασφαλές restore',
    () async {
      final store = FitnessStore(MemoryRepository());
      final original = store.data.templates.first;
      await store.updateWorkoutTemplate(original.copyWith(name: 'IRON V2'));

      final version = store.historyForTemplate(original.id).single;
      expect(version.snapshot.name, original.name);

      await store.restoreProgramVersion(version);

      expect(
        store.data.templates.singleWhere((item) => item.id == original.id).name,
        original.name,
      );
      expect(store.historyForTemplate(original.id).length, 2);
    },
  );

  test(
    'hydration tracker αποθηκεύει, αθροίζει και αναιρεί ποσότητες',
    () async {
      final repository = MemoryRepository();
      final store = FitnessStore(repository);
      await store.addWater(250);
      await store.addWater(500);

      expect(store.waterTodayMilliliters, 750);
      expect(store.hydrationTargetMilliliters, 2800);

      await store.removeHydration(store.todaysHydration.first);

      expect(store.waterTodayMilliliters, 250);
      expect(repository.value.hydration.length, 1);
    },
  );

  test(
    'meal preset καταγράφει fiber, sodium και τροφοδοτεί grocery list',
    () async {
      final store = FitnessStore(MemoryRepository());
      final preset = await store.createMealPreset(
        name: 'Meal prep bowl',
        calories: 700,
        proteinGrams: 50,
        carbohydrateGrams: 80,
        fatGrams: 18,
        fiberGrams: 11,
        sodiumMilligrams: 650,
        ingredients: const ['Ρύζι', 'Μοσχάρι', 'Μπρόκολο'],
      );
      await store.addMealFromPreset(preset);

      expect(store.fiberToday, 11);
      expect(store.sodiumToday, 650);
      expect(store.todaysMeals.single.presetId, preset.id);
      expect(
        store.groceryList
            .singleWhere((item) => item.name == 'Ρύζι')
            .presetCount,
        greaterThanOrEqualTo(2),
      );
    },
  );

  test('training και rest day έχουν διαφορετικό calorie/carb target', () {
    final store = FitnessStore(MemoryRepository());
    final training = store.nutritionTargetsForDate(DateTime(2026, 7, 29));
    final rest = store.nutritionTargetsForDate(DateTime(2026, 7, 30));

    expect(training.isTrainingDay, isTrue);
    expect(rest.isTrainingDay, isFalse);
    expect(rest.calories, lessThan(training.calories));
    expect(rest.carbohydrateGrams, lessThan(training.carbohydrateGrams));
    expect(rest.proteinGrams, training.proteinGrams);
  });

  test(
    'weekly nutrition analytics μετρούν adherence και consistency streak',
    () async {
      final store = FitnessStore(MemoryRepository());
      final now = DateTime.now();
      for (var offset = 1; offset <= 2; offset++) {
        final date = now.subtract(Duration(days: offset));
        final target = store.nutritionTargetsForDate(date);
        await store.addMeal(
          name: 'Complete day $offset',
          calories: target.calories,
          proteinGrams: target.proteinGrams,
          carbohydrateGrams: target.carbohydrateGrams,
          fatGrams: target.fatGrams,
          fiberGrams: target.fiberGrams,
          sodiumMilligrams: 1800,
          loggedAt: date,
        );
      }

      final summaries = NutritionAnalyticsEngine.weeklySummaries(
        meals: store.data.meals,
        hydration: store.data.hydration,
        now: now,
        targetsForDate: store.nutritionTargetsForDate,
      );

      expect(summaries.length, 7);
      expect(store.weeklyMacroAdherence, closeTo(1, .001));
      expect(store.nutritionConsistencyStreak, 2);
    },
  );

  test('παλιό meal JSON αποκτά ασφαλή fiber και sodium defaults', () {
    final meal = MealEntry.fromJson({
      'name': 'Legacy',
      'calories': 400,
      'proteinGrams': 30,
      'carbohydrateGrams': 40,
      'fatGrams': 12,
      'loggedAt': DateTime(2026, 7, 29).toIso8601String(),
    });

    expect(meal.fiberGrams, 0);
    expect(meal.sodiumMilligrams, 0);
    expect(meal.presetId, isEmpty);
  });

  test('recovery check-in αποθηκεύει body map, steps και resting HR', () async {
    final store = FitnessStore(MemoryRepository());
    await store.saveRecoveryCheckIn(
      sleepHours: 7.5,
      energy: 4,
      soreness: 3,
      stress: 2,
      sorenessAreas: const {'Ώμοι': 4, 'Πόδια': 2},
      steps: 8200,
      restingHeartRate: 58,
    );

    final checkIn = store.todaysRecoveryCheckIn!;
    expect(checkIn.sorenessAreas['Ώμοι'], 4);
    expect(checkIn.steps, 8200);
    expect(checkIn.restingHeartRate, 58);

    final restored = RecoveryCheckIn.fromJson(
      jsonDecode(jsonEncode(checkIn.toJson())) as Map<String, dynamic>,
    );
    expect(restored.sorenessAreas, checkIn.sorenessAreas);
  });

  test('personal readiness baseline συγκρίνει το τελευταίο 14ήμερο', () {
    final now = DateTime(2026, 7, 29);
    final checks = [
      for (var index = 0; index < 4; index++)
        RecoveryCheckIn(
          sleepHours: 6.5 + index * .5,
          energy: 2 + index.clamp(0, 2),
          soreness: 4 - index.clamp(0, 2),
          stress: 3,
          recordedAt: now.subtract(Duration(days: 3 - index)),
        ),
    ];

    final baseline = RecoveryLabEngine.baseline(checks);

    expect(baseline.sampleDays, 4);
    expect(baseline.latestScore, greaterThan(baseline.averageScore));
    expect(baseline.label, contains('baseline'));
  });

  test('recovery recommendations και fatigue heatmap είναι deterministic', () {
    final now = DateTime(2026, 7, 29);
    final check = RecoveryCheckIn(
      sleepHours: 5.5,
      energy: 2,
      soreness: 4,
      stress: 5,
      steps: 3000,
      recordedAt: now,
    );

    final recommendations = RecoveryLabEngine.recommendations(
      latest: check,
      isRestDay: true,
    );
    final heatmap = RecoveryLabEngine.fatigueHeatmap(
      checkIns: [check],
      now: now,
    );

    expect(
      recommendations.map((item) => item.title),
      contains('Sleep extension'),
    );
    expect(
      recommendations.map((item) => item.title),
      contains('Downshift breathing'),
    );
    expect(heatmap.length, 28);
    expect(heatmap.last.score, isNotNull);
  });

  test('recovery/performance correlation εντοπίζει θετική σχέση', () {
    final start = DateTime(2026, 7, 20);
    final checks = <RecoveryCheckIn>[];
    final logs = <WorkoutLog>[];
    for (var index = 0; index < 4; index++) {
      final date = start.add(Duration(days: index));
      checks.add(
        RecoveryCheckIn(
          sleepHours: 5.0 + index,
          energy: 2 + index,
          soreness: 5 - index,
          stress: 4 - index.clamp(0, 2),
          recordedAt: date,
        ),
      );
      logs.add(
        WorkoutLog(
          templateName: 'IRON',
          completedAt: date,
          minutes: 40,
          sets: [
            ExerciseSetLog(
              exerciseName: 'Goblet squat',
              reps: 8,
              weightKilograms: 10.0 + index * 10,
              rir: 2,
              holdSeconds: 0,
              loggedAt: date,
            ),
          ],
        ),
      );
    }

    final correlation = RecoveryLabEngine.performanceCorrelation(
      checkIns: checks,
      logs: logs,
    );

    expect(correlation.sampleSize, 4);
    expect(correlation.value, greaterThan(.8));
  });

  test('illness mode παγώνει training και ξεκινά 7-day return ramp', () async {
    final store = FitnessStore(MemoryRepository());
    final workout = store.data.templates.first;
    await store.setIllnessMode(true);

    store.startWorkout(workout);
    expect(store.trainingPaused, isTrue);
    expect(store.hasActiveWorkout, isFalse);

    await store.setIllnessMode(false);
    store.startWorkout(workout);

    expect(store.trainingPaused, isFalse);
    expect(store.currentReturnRamp?.day, 1);
    expect(store.hasActiveWorkout, isTrue);
    expect(
      store.activeWorkout!.prescriptionFor(workout.exercises.first).workingSets,
      lessThanOrEqualTo(
        workout.prescriptionFor(workout.exercises.first).workingSets,
      ),
    );
  });

  test('muscle-volume history και exercise performance είναι χρονικά', () {
    final now = DateTime(2026, 7, 29);
    final logs = [
      for (var week = 0; week < 3; week++)
        WorkoutLog(
          templateName: 'IRON',
          completedAt: now.subtract(Duration(days: week * 7)),
          minutes: 45,
          sets: [
            ExerciseSetLog(
              exerciseName: 'Goblet squat',
              reps: 8,
              weightKilograms: 20.0 + week * 5,
              rir: 2,
              holdSeconds: 0,
              loggedAt: now.subtract(Duration(days: week * 7)),
            ),
          ],
        ),
    ];

    final volume = AdvancedAnalyticsEngine.muscleVolumeHistory(
      logs: logs,
      now: now,
    );
    final performance = AdvancedAnalyticsEngine.performanceTimeline(
      'Goblet squat',
      logs,
    );

    expect(volume.length, 8);
    expect(volume.last.setsByMuscle['Πόδια'], 1);
    expect(performance.length, 3);
    expect(performance.last.date.isAfter(performance.first.date), isTrue);
  });

  test(
    'strength standard, e1RM και PR timeline χρησιμοποιούν πραγματικά sets',
    () {
      final date = DateTime(2026, 7, 29);
      final logs = [
        WorkoutLog(
          templateName: 'IRON',
          completedAt: date,
          minutes: 50,
          sets: [
            ExerciseSetLog(
              exerciseName: 'Goblet squat',
              reps: 10,
              weightKilograms: 80,
              rir: 1,
              holdSeconds: 0,
              loggedAt: date,
            ),
            ExerciseSetLog(
              exerciseName: 'Hollow body hold',
              reps: 0,
              weightKilograms: 0,
              rir: 2,
              holdSeconds: 45,
              loggedAt: date,
            ),
          ],
        ),
      ];

      final standard = AdvancedAnalyticsEngine.strengthStandard(
        exercise: 'Goblet squat',
        logs: logs,
        bodyweightKilograms: 80,
      );
      final prs = AdvancedAnalyticsEngine.personalRecordTimeline(logs);

      expect(standard.ratio, greaterThan(1));
      expect(standard.level, isNot('Starter'));
      expect(prs.any((event) => event.kind == 'STRENGTH PR'), isTrue);
      expect(prs.any((event) => event.kind == 'HOLD PR'), isTrue);
    },
  );

  test(
    'consistency calendar και multi-level streaks ξεχωρίζουν ημέρες/εβδομάδες',
    () {
      final now = DateTime(2026, 7, 29);
      final logs = [
        for (final offset in [0, 1, 7, 14])
          WorkoutLog(
            templateName: 'IRON',
            completedAt: now.subtract(Duration(days: offset)),
            minutes: 40,
          ),
      ];

      final calendar = AdvancedAnalyticsEngine.consistencyCalendar(logs);
      final streaks = AdvancedAnalyticsEngine.streaks(logs: logs, now: now);

      expect(calendar.length, 4);
      expect(streaks.currentDaily, 2);
      expect(streaks.currentWeekly, 3);
      expect(streaks.bestWeekly, 3);
    },
  );

  test('session duration, acute/chronic ratio και exports είναι έγκυρα', () {
    final now = DateTime.now();
    final logs = [
      for (var index = 0; index < 8; index++)
        WorkoutLog(
          templateName: 'IRON,$index',
          completedAt: now.subtract(Duration(days: index * 3)),
          minutes: 35 + index,
          sessionRpe: 7,
          sets: [
            ExerciseSetLog(
              exerciseName: 'Goblet squat',
              reps: 8,
              weightKilograms: 20,
              rir: 2,
              holdSeconds: 0,
              loggedAt: now.subtract(Duration(days: index * 3)),
            ),
          ],
        ),
    ];

    final durations = AdvancedAnalyticsEngine.sessionDurationTrend(logs);
    final workload = AdvancedAnalyticsEngine.workloadRatio(
      logs: logs,
      now: now,
    );
    final csv = AdvancedAnalyticsEngine.exportCsv(
      logs: logs,
      weights: const [],
    );
    final json = AdvancedAnalyticsEngine.exportJson(
      logs: logs,
      weights: const [],
      generatedAt: now,
    );

    expect(durations.length, 8);
    expect(workload.ratio, greaterThan(0));
    expect(csv, contains('"IRON,0"'));
    expect(jsonDecode(json)['report'], 'Phoenix Advanced Analytics');
  });

  testWidgets('η απλή αρχική δείχνει το επόμενο μικρό βήμα', (tester) async {
    final store = FitnessStore(MemoryRepository());
    store.previewWithoutProfile();
    await tester.pumpWidget(PhoenixApp(store: store));

    expect(find.text('Τι μπορείς να κάνεις σήμερα;'), findsOneWidget);
    expect(find.text('ΤΟ ΕΠΟΜΕΝΟ ΜΙΚΡΟ ΒΗΜΑ'), findsOneWidget);
    expect(find.text('Ξεκίνα όταν είσαι έτοιμος'), findsOneWidget);
    expect(
      find.textContaining('0 από 3 προπονήσεις αυτή την εβδομάδα'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Οι σημερινές ασκήσεις'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Οι σημερινές ασκήσεις'), findsOneWidget);
    expect(find.text('Περπάτημα με βάρη'), findsOneWidget);
    expect(find.text('Δες πώς γίνεται'), findsWidgets);
    expect(
      find.byKey(const ValueKey('daily-exercise-guide-Farmer carry')),
      findsNothing,
    );
  });

  testWidgets('η αρχική ανοίγει απλό δεκάλεπτο χωρίς επαγγελματικό lab', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    store.previewWithoutProfile();
    await tester.pumpWidget(PhoenixApp(store: store));

    final movement = find.byKey(const ValueKey('gentle-movement-action'));
    await tester.scrollUntilVisible(
      movement,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(movement);
    await tester.pumpAndSettle();
    await tester.tap(movement);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('gentle-movement-timer')), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('INTERVAL TIMER LAB'), findsNothing);
    expect(find.byKey(const ValueKey('gentle-movement-start')), findsOneWidget);
  });

  testWidgets('η εικόνα τεχνικής ανοίγει από τη σημερινή άσκηση', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    store.previewWithoutProfile();
    final exercise = store.recommendedWorkout.exercises.first;
    final exerciseRow = find.byKey(ValueKey('daily-exercise-row-$exercise'));
    await tester.pumpWidget(PhoenixApp(store: store));

    await tester.scrollUntilVisible(
      exerciseRow,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(exerciseRow);
    await tester.pumpAndSettle();
    await tester.tap(exerciseRow);
    await tester.pumpAndSettle();

    expect(find.text('ΑΡΧΙΚΗ ΘΕΣΗ  →  ΤΕΛΙΚΗ ΘΕΣΗ'), findsOneWidget);
    expect(find.text('ΕΚΤΕΛΕΣΗ'), findsOneWidget);
    expect(find.text('ΑΠΟΦΥΓΕ'), findsOneWidget);
  });

  testWidgets('το Περισσότερα ανοίγει οργανωμένη εργαλειοθήκη', (tester) async {
    final store = FitnessStore(MemoryRepository());
    store.previewWithoutProfile();
    await tester.pumpWidget(PhoenixApp(store: store));

    await tester.tap(find.text('Περισσότερα'));
    await tester.pumpAndSettle();

    expect(find.text('Όλα τα εργαλεία'), findsOneWidget);
    expect(find.text('Cali Lab'), findsNothing);

    await tester.tap(find.text('Όλα τα εργαλεία'));
    await tester.pumpAndSettle();

    expect(find.byType(PhoenixToolboxPage), findsOneWidget);
    expect(find.text('ΕΡΓΑΛΕΙΟΘΗΚΗ PHOENIX'), findsOneWidget);
    expect(find.text('ΠΡΟΠΟΝΗΣΗ'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('phoenix-toolbox-search')),
      'backup',
    );
    await tester.pump();

    expect(find.text('Media & Portability'), findsOneWidget);
    expect(find.text('Εβδομαδιαίο πλάνο'), findsNothing);
  });

  testWidgets('η οθόνη προπόνησης εμφανίζει εβδομαδιαίο ημερολόγιο', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    store.previewWithoutProfile();
    await tester.pumpWidget(PhoenixApp(store: store));

    await tester.tap(find.byIcon(Icons.fitness_center_outlined));
    await tester.pumpAndSettle();

    expect(find.text('ΕΒΔΟΜΑΔΙΑΙΟ ΠΛΑΝΟ'), findsOneWidget);
    expect(find.textContaining('0/3'), findsWidgets);
    expect(find.byIcon(Icons.play_arrow), findsWidgets);
    final playButton = find.byTooltip('Έναρξη Δύναμη με βάρη — Όλο το σώμα');
    final startControl = find.ancestor(
      of: playButton,
      matching: find.byType(IconButton),
    );
    tester.widget<IconButton>(startControl).onPressed!();
    await tester.pumpAndSettle();
    expect(find.text('ΠΡΟΠΟΝΗΣΗ ΜΕ ΒΑΡΗ'), findsOneWidget);
    expect(store.hasActiveWorkout, isTrue);
    Navigator.of(tester.element(find.text('ΠΡΟΠΟΝΗΣΗ ΜΕ ΒΑΡΗ'))).pop();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Ειδικά εργαλεία'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Ειδικά εργαλεία'), findsOneWidget);
    expect(find.text('Σχεδιασμός προγράμματος'), findsNothing);
    await tester.tap(find.text('Ειδικά εργαλεία'));
    await tester.pumpAndSettle();
    expect(find.text('Σχεδιασμός προγράμματος'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('ΟΛΑ ΤΑ ΠΡΟΓΡΑΜΜΑΤΑ'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('ΟΛΑ ΤΑ ΠΡΟΓΡΑΜΜΑΤΑ'), findsOneWidget);
  });

  testWidgets('η ενεργή συνεδρία επιτρέπει ασφαλή αλλαγή άσκησης', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    store.startWorkout(store.data.templates.first);
    await tester.pumpWidget(MaterialApp(home: ActiveWorkoutPage(store: store)));
    for (
      var attempt = 0;
      attempt < 6 && find.byIcon(Icons.swap_horiz).evaluate().isEmpty;
      attempt++
    ) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -260));
      await tester.pumpAndSettle();
    }
    expect(find.byIcon(Icons.swap_horiz), findsWidgets);
    expect(find.textContaining('Δες πώς γίνεται'), findsWidgets);
    await tester.ensureVisible(find.byIcon(Icons.swap_horiz).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.swap_horiz).first);
    await tester.pumpAndSettle();

    expect(find.text('Αλλαγή άσκησης'), findsOneWidget);
    expect(find.text('Goblet squat to bench'), findsOneWidget);
    await tester.tap(find.text('Goblet squat to bench'));
    await tester.pumpAndSettle();

    expect(store.activeWorkout!.exercises, contains('Goblet squat σε πάγκο'));
    expect(find.text('Goblet squat to bench'), findsOneWidget);
  });

  testWidgets('η ενεργή προπόνηση στο σπίτι δεν εμφανίζει gym εμπειρία', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.saveProfile(
      const UserProfile(
        goal: 'Γενική φυσική κατάσταση',
        trainingPlace: 'Σπίτι',
        equipment: 'Χωρίς εξοπλισμό',
        daysPerWeek: 2,
        heightCentimeters: 170,
        weightKilograms: 70,
        experienceLevel: 'Αρχάριος',
        sessionMinutes: 20,
      ),
    );
    store.startWorkout(store.data.templates.first);

    await tester.pumpWidget(MaterialApp(home: ActiveWorkoutPage(store: store)));

    expect(find.text('HOME WORKOUT'), findsOneWidget);
    expect(find.text('SIMPLE WARM-UP'), findsOneWidget);
    expect(find.text('ΠΡΟΠΟΝΗΣΗ ΜΕ ΒΑΡΗ'), findsNothing);
    expect(find.text('WARM-UP PROTOCOL'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Κάθισμα και σήκωμα από καρέκλα'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName.contains(
              'home-no-equipment-guide-v1.jpg',
            ),
      ),
      findsWidgets,
    );
  });

  testWidgets('η διατροφή εμφανίζει εξατομικευμένο ημερήσιο στόχο', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    store.previewWithoutProfile();
    await tester.pumpWidget(PhoenixApp(store: store));

    await tester.tap(find.byIcon(Icons.restaurant_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Σημερινός στόχος'), findsOneWidget);
    expect(
      find.textContaining('/ ${store.nutritionTargets.calories} kcal'),
      findsOneWidget,
    );
    expect(find.text('Ξεκίνα με την πρωτεΐνη'), findsOneWidget);
  });

  testWidgets('το απλό διατροφικό πλάνο είναι άμεσα ορατό', (tester) async {
    final store = FitnessStore(MemoryRepository());
    store.previewWithoutProfile();
    await tester.pumpWidget(PhoenixApp(store: store));

    await tester.tap(find.byIcon(Icons.restaurant_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Το δικό σου πρόγραμμα διατροφής'), findsOneWidget);

    await tester.tap(find.text('Το δικό σου πρόγραμμα διατροφής'));
    await tester.pumpAndSettle();
    expect(find.byType(RecommendedNutritionPage), findsOneWidget);
    expect(find.text('Έτοιμο για εσένα'), findsOneWidget);
    expect(find.text('Οι επιλογές μου'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Η εβδομάδα μου'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Η εβδομάδα μου'), findsOneWidget);
  });

  testWidgets('το Nutrition Pro καταγράφει νερό και meal preset', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    store.previewWithoutProfile();
    await tester.pumpWidget(PhoenixApp(store: store));
    await tester.tap(find.byIcon(Icons.restaurant_outlined));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('250 ml'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('250 ml'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('250 ml'));
    await tester.pumpAndSettle();
    expect(find.text('250 / 2800 ml'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Έτοιμα γεύματα'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Καταγραφή').first);
    await tester.pumpAndSettle();

    expect(store.todaysMeals, isNotEmpty);
    expect(store.fiberToday, greaterThan(0));
  });

  testWidgets('η grocery list παράγεται από τα meal presets', (tester) async {
    final store = FitnessStore(MemoryRepository());
    await tester.pumpWidget(MaterialApp(home: NutritionPage(store: store)));

    await tester.scrollUntilVisible(
      find.text('Meal presets'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Λίστα αγορών'));
    await tester.pumpAndSettle();

    expect(find.text('Αυτόματη λίστα αγορών'), findsOneWidget);
    expect(find.text('Βρώμη'), findsOneWidget);
    expect(
      store.groceryList.any((item) => item.name == 'Στήθος κοτόπουλου'),
      isTrue,
    );
  });

  testWidgets('το Recovery Lab εμφανίζει baseline, heatmap και correlation', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await tester.pumpWidget(MaterialApp(home: RecoveryLabPage(store: store)));

    expect(find.text('RECOVERY LAB'), findsOneWidget);
    expect(find.text('ΠΡΟΣΩΠΙΚΟ READINESS BASELINE'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('FATIGUE HEATMAP • 28 ΗΜΕΡΕΣ'),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('FATIGUE HEATMAP • 28 ΗΜΕΡΕΣ'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('RECOVERY × PERFORMANCE'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('RECOVERY × PERFORMANCE'), findsOneWidget);
  });

  testWidgets('το guided breathing timer εκτελεί κύκλο 4/6', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BreathingTimerPage()));

    expect(find.text('DOWNSHIFT BREATHING'), findsOneWidget);
    expect(find.text('5:00'), findsOneWidget);
    await tester.tap(find.text('Έναρξη'));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('4:59'), findsOneWidget);
    expect(find.text('ΕΙΣΠΝΟΗ'), findsOneWidget);
  });

  testWidgets('το Advanced Analytics dashboard και export φορτώνουν', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await tester.pumpWidget(
      MaterialApp(home: AdvancedAnalyticsPage(store: store)),
    );

    expect(find.text('ADVANCED ANALYTICS'), findsOneWidget);
    expect(find.text('MUSCLE VOLUME • 8 ΕΒΔΟΜΑΔΕΣ'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Αντιγραφή CSV'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('EXPORT ANALYTICS REPORT'), findsOneWidget);
    await tester.ensureVisible(find.text('Αντιγραφή CSV'));
    await tester.pumpAndSettle();
    expect(find.text('Αντιγραφή CSV'), findsOneWidget);
    expect(find.text('Αντιγραφή JSON'), findsOneWidget);
  });

  testWidgets('το readiness check-in προσαρμόζει το σημερινό mode', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    store.previewWithoutProfile();
    await tester.pumpWidget(PhoenixApp(store: store));

    await tester.scrollUntilVisible(
      find.text('READINESS CHECK-IN'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('READINESS CHECK-IN'));
    await tester.pumpAndSettle();
    expect(find.text('Readiness check-in'), findsOneWidget);
    expect(find.text('Προσαρμογή σημερινού πλάνου'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Προσαρμογή σημερινού πλάνου'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Προσαρμογή σημερινού πλάνου'));
    await tester.pumpAndSettle();

    expect(store.todaysRecoveryCheckIn, isNotNull);
    expect(find.text('GREEN MODE'), findsOneWidget);
  });

  testWidgets('ο Program Builder επεξεργάζεται και αποθηκεύει πρόγραμμα', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    final template = store.data.templates.first;
    await tester.pumpWidget(
      MaterialApp(
        home: ProgramEditorPage(store: store, template: template),
      ),
    );

    expect(find.text('PROGRAM BUILDER'), findsOneWidget);
    expect(find.text(template.exercises.first), findsOneWidget);
    expect(find.byIcon(Icons.drag_indicator), findsWidgets);
    await tester.enterText(find.byType(TextField).first, 'CUSTOM IRON');
    await tester.tap(find.text('Αποθήκευση προγράμματος'));
    await tester.pumpAndSettle();

    expect(store.data.templates.first.name, 'CUSTOM IRON');
  });

  testWidgets('ο Program Builder δημιουργεί πραγματικό superset', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    final draft = store.createCustomWorkoutDraft();
    await tester.pumpWidget(
      MaterialApp(
        home: ProgramEditorPage(store: store, template: draft),
      ),
    );

    await tester.tap(find.text('ΡΥΘΜΙΣΕΙΣ ΠΡΟΓΡΑΜΜΑΤΟΣ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Superset'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, draft.exercises[0]));
    await tester.tap(find.widgetWithText(CheckboxListTile, draft.exercises[1]));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Δημιουργία superset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Αποθήκευση προγράμματος'));
    await tester.pumpAndSettle();

    final saved = store.data.templates.singleWhere(
      (item) => item.id == draft.id,
    );
    expect(saved.blocks.single.isSuperset, isTrue);
    expect(saved.blocks.single.exercises.length, 2);
  });

  testWidgets('το Weekly Planner αποθηκεύει χειροκίνητη ημέρα', (tester) async {
    final store = FitnessStore(MemoryRepository());
    await tester.pumpWidget(MaterialApp(home: WeeklyPlannerPage(store: store)));

    expect(find.text('Weekly planner'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dumbbell strength — Full body').last);
    await tester.pumpAndSettle();

    expect(store.data.weeklyAssignments['1'], store.data.templates.first.id);
  });

  testWidgets('το version history εμφανίζει και επαναφέρει snapshot', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    final template = store.data.templates.first;
    await store.updateWorkoutTemplate(template.copyWith(name: 'IRON HISTORY'));
    await tester.pumpWidget(
      MaterialApp(
        home: ProgramHistoryPage(store: store, templateId: template.id),
      ),
    );

    expect(find.text('VERSION HISTORY'), findsOneWidget);
    expect(find.text(template.name), findsOneWidget);
    expect(find.text('Επαναφορά'), findsOneWidget);
  });

  testWidgets('το Control Center εμφανίζει Data Vault και achievements', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await tester.pumpWidget(MaterialApp(home: ControlCenterPage(store: store)));

    expect(find.text('CONTROL CENTER'), findsOneWidget);
    expect(find.text('DATA VAULT'), findsOneWidget);
    expect(find.text('ACHIEVEMENTS'), findsOneWidget);
    expect(find.text('FIRST FIRE'), findsOneWidget);
    expect(find.text('IRON WEEK'), findsOneWidget);
  });

  testWidgets('το Mobility Lab εμφανίζει ρουτίνες και timer', (tester) async {
    final store = FitnessStore(MemoryRepository());
    await tester.pumpWidget(MaterialApp(home: MobilityPage(store: store)));

    expect(find.text('MOBILITY LAB'), findsOneWidget);
    expect(find.text('FULL BODY RESET'), findsOneWidget);
    await tester.tap(find.text('FULL BODY RESET'));
    await tester.pumpAndSettle();
    expect(find.text('Έναρξη ρουτίνας'), findsOneWidget);
    await tester.tap(find.text('Έναρξη ρουτίνας'));
    await tester.pumpAndSettle();
    expect(find.text('ΒΗΜΑ 1/4'), findsOneWidget);
    expect(find.text('90/90 breathing'), findsOneWidget);
  });

  testWidgets('η πρώτη εκκίνηση εμφανίζει το onboarding', (tester) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(PhoenixApp(store: store));

    expect(find.text('PHOENIX'), findsOneWidget);
    expect(
      find.textContaining('Δεν χρειάζεται να τα έχεις όλα'),
      findsOneWidget,
    );
    expect(find.textContaining('ΝΕΑ ΑΠΛΗ ΕΜΠΕΙΡΙΑ'), findsOneWidget);
    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    expect(
      find.byKey(const ValueKey('gentle-start-illustration')),
      findsOneWidget,
    );
    expect(find.text('Συνέχεια'), findsOneWidget);
  });

  testWidgets('το onboarding προσφέρει απλό διάδρομο μαζί με αλτήρες', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(PhoenixApp(store: store));

    await tester.tap(find.text('Συνέχεια'));
    await tester.pumpAndSettle();
    final treadmill = find.byKey(const ValueKey('equipment-treadmill'));
    await tester.ensureVisible(treadmill);
    await tester.pumpAndSettle();
    await tester.tap(treadmill);
    await tester.pumpAndSettle();
    final dumbbells = find.byKey(const ValueKey('equipment-dumbbells'));
    await tester.ensureVisible(dumbbells);
    await tester.pumpAndSettle();
    await tester.tap(dumbbells);
    await tester.pumpAndSettle();

    final field = tester.widget<TextFormField>(
      find.byKey(const ValueKey('equipment-input')),
    );
    expect(field.controller?.text, contains('Απλός διάδρομος'));
    expect(field.controller?.text, contains('Αλτήρες'));
  });

  testWidgets('το απλό onboarding ολοκληρώνεται σε τρία καθαρά βήματα', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(PhoenixApp(store: store));

    expect(find.textContaining('ΒΗΜΑ 1 ΑΠΟ 3'), findsOneWidget);
    await tester.tap(find.text('Συνέχεια'));
    await tester.pumpAndSettle();

    expect(find.textContaining('ΒΗΜΑ 2 ΑΠΟ 3'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('equipment-none')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('equipment-none')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Συνέχεια'));
    await tester.pumpAndSettle();

    expect(find.textContaining('ΒΗΜΑ 3 ΑΠΟ 3'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('height-input')),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(find.byKey(const ValueKey('height-input')), '180');
    await tester.enterText(find.byKey(const ValueKey('weight-input')), '80');
    await tester.scrollUntilVisible(
      find.text('Φτιάξε το πρώτο μου πρόγραμμα'),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Φτιάξε το πρώτο μου πρόγραμμα'));
    await tester.pumpAndSettle();

    expect(store.profile, isNotNull);
    expect(find.byType(PhoenixShell), findsOneWidget);
  });

  testWidgets('η επιλογή βοήθειας ετοιμάζει πραγματικό ήπιο ξεκίνημα', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(PhoenixApp(store: store));

    final guided = find.byKey(const ValueKey('guided-start-choice'));
    await tester.scrollUntilVisible(
      guided,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(guided);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Συνέχεια'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('equipment-none')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('equipment-none')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Συνέχεια'));
    await tester.pumpAndSettle();

    final preview = find.byKey(const ValueKey('starter-plan-preview'));
    await tester.scrollUntilVisible(
      preview,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Το ήπιο ξεκίνημά σου'), findsOneWidget);
    expect(find.text('2 ημέρες'), findsWidgets);
    expect(find.text('20 λεπτά'), findsWidgets);
    expect(find.textContaining('4 απλές ασκήσεις'), findsOneWidget);
    expect(find.textContaining('Χωρίς εξοπλισμό'), findsWidgets);
  });

  test(
    'οι experience preferences αποθηκεύονται και επαναφορτώνονται',
    () async {
      final repository = MemoryRepository();
      final store = FitnessStore(repository);
      await store.load();

      await store.updatePreferences(
        languageCode: 'en',
        highContrast: true,
        themePreset: 'ocean',
        hapticFeedback: false,
        audioCues: true,
      );
      final reloaded = FitnessStore(repository);
      await reloaded.load();

      expect(reloaded.preferences.languageCode, 'en');
      expect(reloaded.preferences.highContrast, isTrue);
      expect(reloaded.preferences.themePreset, 'ocean');
      expect(reloaded.preferences.hapticFeedback, isFalse);
      expect(reloaded.preferences.audioCues, isTrue);
    },
  );

  test('το local vault δέχεται PIN, κλειδώνει και ελέγχει hash', () async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await store.updatePreferences(hapticFeedback: false);
    await store.setVaultPin('2580');

    expect(store.hasVaultPin, isTrue);
    expect(store.preferences.vaultPinHash, isNot(contains('2580')));
    store.lockVault();
    expect(store.vaultUnlocked, isFalse);
    expect(await store.unlockVault('1111'), isFalse);
    expect(await store.unlockVault('2580'), isTrue);

    await store.removeVaultPin('2580');
    expect(store.hasVaultPin, isFalse);
  });

  test('undo επαναφέρει πλήρως διαγραμμένο custom workout', () async {
    final store = FitnessStore(MemoryRepository());
    final draft = store.createCustomWorkoutDraft();
    await store.updateWorkoutTemplate(draft);
    await store.deleteCustomWorkout(draft.id);

    expect(store.data.templates.any((item) => item.id == draft.id), isFalse);
    expect(store.canUndo, isTrue);
    expect(await store.undoLastMutation(), isTrue);
    expect(store.data.templates.any((item) => item.id == draft.id), isTrue);
  });

  test('undo επαναφέρει γεύμα και hydration entry', () async {
    final store = FitnessStore(MemoryRepository());
    await store.addMeal(
      name: 'Undo meal',
      calories: 500,
      proteinGrams: 40,
      carbohydrateGrams: 50,
      fatGrams: 15,
    );
    final meal = store.data.meals.first;
    await store.removeMeal(meal);
    await store.undoLastMutation();
    expect(store.data.meals.any((item) => item.name == meal.name), isTrue);

    await store.addWater(300);
    final water = store.data.hydration.first;
    await store.removeHydration(water);
    await store.undoLastMutation();
    expect(
      store.data.hydration.any(
        (item) =>
            item.milliliters == water.milliliters &&
            item.loggedAt == water.loggedAt,
      ),
      isTrue,
    );
  });

  test('validation center εντοπίζει και επιδιορθώνει ορφανά δεδομένα', () {
    final base = FitnessData.initial();
    final broken = base.copyWith(
      templates: [base.templates.first, base.templates.first],
      weeklyAssignments: const {'1': 'missing-template'},
      hydration: [HydrationEntry(milliliters: 9000, loggedAt: DateTime(2026))],
    );

    final report = DataValidationEngine.audit(broken);
    expect(report.criticalCount, greaterThan(0));
    expect(report.warningCount, greaterThan(0));
    expect(report.integrityScore, lessThan(100));

    final repaired = DataValidationEngine.repair(broken);
    final after = DataValidationEngine.audit(repaired);
    expect(after.isHealthy, isTrue);
  });

  test('global search βρίσκει workout, exercise, meal και tool', () {
    final base = FitnessData.initial().copyWith(
      meals: [
        MealEntry(
          name: 'Power bowl',
          calories: 650,
          proteinGrams: 45,
          carbohydrateGrams: 70,
          fatGrams: 18,
          loggedAt: DateTime(2026),
        ),
      ],
    );

    expect(
      GlobalSearchEngine.search(base, 'IRON HYBRID').first.type,
      SearchResultType.workout,
    );
    expect(
      GlobalSearchEngine.search(
        base,
        'Goblet squat',
      ).any((item) => item.type == SearchResultType.exercise),
      isTrue,
    );
    expect(
      GlobalSearchEngine.search(base, 'Power bowl').single.type,
      SearchResultType.meal,
    );
    expect(
      GlobalSearchEngine.search(
        base,
        'readiness',
      ).any((item) => item.route == 'recovery'),
      isTrue,
    );
  });

  test('η επεξεργασία προφίλ διατηρεί τα custom προγράμματα', () async {
    final store = FitnessStore(MemoryRepository());
    final draft = store.createCustomWorkoutDraft();
    await store.updateWorkoutTemplate(draft);
    await store.updateProfile(
      const UserProfile(
        goal: 'Δύναμη',
        trainingPlace: 'Σπίτι',
        equipment: 'Μονόζυγο',
        daysPerWeek: 4,
        heightCentimeters: 180,
        weightKilograms: 82,
        experienceLevel: 'Μέτριος',
        sessionMinutes: 60,
      ),
      refreshCorePrograms: true,
    );

    expect(store.profile?.daysPerWeek, 4);
    expect(store.data.templates.any((item) => item.id == draft.id), isTrue);
  });

  testWidgets('οι νέες σελίδες Experience και Search αποδίδονται στα αγγλικά', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await store.updatePreferences(languageCode: 'en', hapticFeedback: false);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        home: ExperienceSettingsPage(store: store),
      ),
    );

    expect(find.text('PHOENIX EXPERIENCE'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('High contrast'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('High contrast'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Global search'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Global search'), findsOneWidget);
    await tester.tap(find.text('Global search'));
    await tester.pumpAndSettle();
    expect(find.byType(GlobalSearchPage), findsOneWidget);
    expect(find.text('Global search'), findsOneWidget);
  });

  testWidgets('profile, validation και vault pages είναι λειτουργικές', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(MaterialApp(home: ProfileEditorPage(store: store)));
    expect(find.text('EDIT PROFILE'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Save profile'),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Save profile'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(home: DataValidationPage(store: store)),
    );
    expect(find.text('DATA VALIDATION'), findsOneWidget);
    expect(find.text('No issues found'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(home: VaultSecurityPage(store: store)));
    expect(find.text('VAULT SECURITY'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Enable / change PIN'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Enable / change PIN'), findsOneWidget);
  });

  testWidgets('το PhoenixApp εφαρμόζει ocean high-contrast theme', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await store.updatePreferences(
      themePreset: 'ocean',
      highContrast: true,
      hapticFeedback: false,
    );
    await tester.pumpWidget(PhoenixApp(store: store));
    final context = tester.element(find.byType(OnboardingPage));
    final theme = Theme.of(context);

    expect(theme.scaffoldBackgroundColor, Colors.black);
    expect(
      theme.colorScheme.primary.b,
      greaterThan(theme.colorScheme.primary.r),
    );
  });

  testWidgets('η αρχική ανοίγει άμεσα τις επιλογές χρώματος', (tester) async {
    final store = FitnessStore(MemoryRepository());
    store.previewWithoutProfile();
    await tester.pumpWidget(PhoenixApp(store: store));

    await tester.tap(find.byKey(const ValueKey('quick-theme-settings')));
    await tester.pumpAndSettle();

    expect(find.text('ΧΡΩΜΑΤΑ & ΘΕΜΑ'), findsWidgets);
    expect(find.text('Sage'), findsOneWidget);
    expect(find.text('Sky'), findsOneWidget);
    expect(find.text('Sand'), findsOneWidget);
    expect(find.text('Phoenix'), findsOneWidget);
    expect(find.text('Violet'), findsOneWidget);
    expect(find.text('Gold'), findsOneWidget);
  });

  testWidgets('το Sage θέμα είναι ήρεμο, εφαρμόζεται και μένει στη συσκευή', (
    tester,
  ) async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();
    await tester.pumpWidget(PhoenixApp(store: store));

    await store.updatePreferences(themePreset: 'sage', hapticFeedback: false);
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(OnboardingPage));
    final theme = Theme.of(context);
    final reloaded = FitnessStore(repository);
    await reloaded.load();

    expect(theme.colorScheme.primary, const Color(0xFF9CB9A5));
    expect(theme.scaffoldBackgroundColor, const Color(0xFF0D1411));
    expect(reloaded.preferences.themePreset, 'sage');
  });

  testWidgets('το Violet θέμα εφαρμόζεται και αποθηκεύεται τοπικά', (
    tester,
  ) async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();
    await tester.pumpWidget(PhoenixApp(store: store));

    await store.updatePreferences(themePreset: 'violet', hapticFeedback: false);
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(OnboardingPage));
    final primary = Theme.of(context).colorScheme.primary;
    final reloaded = FitnessStore(repository);
    await reloaded.load();

    expect(primary.b, greaterThan(primary.r));
    expect(reloaded.preferences.themePreset, 'violet');
  });

  testWidgets('η πρώτη εκκίνηση αλλάζει άμεσα σε πλήρες English locale', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await store.updatePreferences(hapticFeedback: false);
    await tester.pumpWidget(PhoenixApp(store: store));

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    expect(store.preferences.languageCode, 'en');
    expect(
      find.textContaining('You do not need to have everything'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('I am not sure — help me get started'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('I am not sure — help me get started'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('What can you start with?'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('equipment-none')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('equipment-none')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('What fits into your life?'), findsOneWidget);
    expect(find.text('Create my first program'), findsOneWidget);
  });

  test('ο daily coach παράγει ιεραρχημένο action plan', () {
    final now = DateTime(2026, 7, 27);
    final data = FitnessData.initial();
    final schedule = TrainingScheduleEngine.build(
      now: now,
      daysPerWeek: 3,
      rotation: data.templates,
      logs: const [],
    );
    final plan = DeterministicCoachEngine.dailyPlan(
      data: data,
      schedule: schedule,
      recoveryScore: 0,
      caloriesToday: 0,
      calorieTarget: 2400,
      proteinToday: 0,
      proteinTarget: 160,
      hydrationToday: 0,
      hydrationTarget: 2800,
      now: now,
    );

    expect(plan.actions.any((item) => item.id == 'workout'), isTrue);
    expect(plan.actions.any((item) => item.id == 'check-in'), isTrue);
    expect(plan.actions.any((item) => item.id == 'water'), isTrue);
    expect(plan.actions.length, lessThanOrEqualTo(5));
    expect(plan.score, inInclusiveRange(0, 100));
  });

  test('ο plateau detector βρίσκει τέσσερις στάσιμες συνεδρίες', () {
    final logs = List.generate(
      4,
      (index) => WorkoutLog(
        templateName: 'PLATEAU',
        completedAt: DateTime(2026, 7, 1 + index * 4),
        minutes: 45,
        sets: [
          ExerciseSetLog(
            exerciseName: 'Bench press',
            reps: 5,
            weightKilograms: 100,
            rir: 2,
            holdSeconds: 0,
            loggedAt: DateTime(2026, 7, 1 + index * 4),
          ),
        ],
      ),
    );

    final plateaus = DeterministicCoachEngine.plateaus(logs);
    expect(plateaus, hasLength(1));
    expect(plateaus.single.exerciseName, 'Bench press');
    expect(plateaus.single.changePercent, 0);
  });

  test('ο missed-workout rescheduler βρίσκει την πρώτη κενή ημέρα', () {
    final now = DateTime(2026, 7, 29);
    final data = FitnessData.initial();
    final schedule = TrainingScheduleEngine.build(
      now: now,
      daysPerWeek: 3,
      rotation: data.templates,
      logs: const [],
    );

    final suggestion = DeterministicCoachEngine.missedWorkout(schedule, now);
    expect(suggestion, isNotNull);
    expect(suggestion!.workout.isOverdue(now), isTrue);
    expect(suggestion.suggestedDate.isAfter(now), isTrue);
  });

  test(
    'date assignment μεταφέρει πραγματικά template σε συγκεκριμένη ημέρα',
    () {
      final data = FitnessData.initial();
      final target = DateTime(2026, 7, 30);
      final schedule = TrainingScheduleEngine.build(
        now: DateTime(2026, 7, 29),
        daysPerWeek: 3,
        rotation: data.templates,
        logs: const [],
        catalog: data.templates,
        dateAssignments: {'2026-07-30': data.templates.last.id},
      );
      final entry = schedule.entries.singleWhere(
        (item) =>
            item.date.year == target.year &&
            item.date.month == target.month &&
            item.date.day == target.day,
      );
      expect(entry.template.id, data.templates.last.id);
    },
  );

  test('injury-aware substitutions αποκλείουν συγκρουόμενες ασκήσεις', () {
    final alternatives = ExerciseSubstitutionEngine.alternativesFor(
      exercise: 'Goblet squat',
      profile: null,
      excludedExercises: const [],
      painAreas: const ['Γόνατο'],
    );

    expect(
      alternatives.any(
        (item) =>
            item.name.toLowerCase().contains('front squat') ||
            item.name.toLowerCase().contains('bulgarian'),
      ),
      isFalse,
    );
    expect(alternatives.every((item) => item.tag == 'PAIN-AWARE'), isTrue);
  });

  test('technique checklist αλλάζει ανά κινητικό μοτίβο', () {
    final squat = DeterministicCoachEngine.techniqueFor('Goblet squat');
    final press = DeterministicCoachEngine.techniqueFor('Shoulder press');

    expect(squat.items, hasLength(3));
    expect(squat.items.join(' '), contains('Γόνατο'));
    expect(press.items.join(' '), contains('Ωμοπλάτες'));
    expect(squat.stopRule, isNotEmpty);
  });

  test('set-quality score χρησιμοποιεί RIR, RPE, velocity και technique', () {
    final prescription = const ExercisePrescription(
      workingSets: 3,
      minReps: 5,
      maxReps: 8,
      targetRir: 2,
      restSeconds: 120,
      tempo: '2–1–2',
    );
    final technique = DeterministicCoachEngine.techniqueFor('Goblet squat');
    final strong = ExerciseSetLog(
      exerciseName: 'Goblet squat',
      reps: 6,
      weightKilograms: 40,
      rir: 2,
      holdSeconds: 0,
      loggedAt: DateTime(2026),
      setRpe: 8,
      velocityNote: 'steady',
      techniqueChecks: technique.items,
    );
    final poor = ExerciseSetLog(
      exerciseName: 'Goblet squat',
      reps: 12,
      weightKilograms: 40,
      rir: 0,
      holdSeconds: 0,
      loggedAt: DateTime(2026),
      setRpe: 10,
      velocityNote: 'grinding',
    );

    final strongScore = DeterministicCoachEngine.setQuality(
      set: strong,
      prescription: prescription,
    );
    final poorScore = DeterministicCoachEngine.setQuality(
      set: poor,
      prescription: prescription,
    );
    expect(strongScore.score, greaterThanOrEqualTo(90));
    expect(poorScore.score, lessThan(60));
  });

  test('manual velocity/RPE και AMRAP metadata κάνουν JSON round-trip', () {
    final set = ExerciseSetLog(
      exerciseName: 'Pull-up',
      reps: 12,
      weightKilograms: 10,
      rir: 0,
      holdSeconds: 0,
      loggedAt: DateTime(2026),
      setRpe: 9,
      velocityNote: 'slow',
      techniqueChecks: const ['Scapula', 'Control'],
      isAmrap: true,
    );
    final decoded = ExerciseSetLog.fromJson(
      jsonDecode(jsonEncode(set.toJson())) as Map<String, dynamic>,
    );

    expect(decoded.setRpe, 9);
    expect(decoded.velocityNote, 'slow');
    expect(decoded.techniqueChecks, hasLength(2));
    expect(decoded.isAmrap, isTrue);
  });

  test(
    'safe strength test αποθηκεύει e1RM χωρίς πραγματικό max single',
    () async {
      final repository = MemoryRepository();
      final store = FitnessStore(repository);
      await store.load();
      await store.updatePreferences(hapticFeedback: false);

      final result = await store.saveStrengthTest(
        exerciseName: 'Bench press',
        weightKilograms: 100,
        reps: 8,
        protocol: 'submax',
      );
      final reloaded = FitnessStore(repository);
      await reloaded.load();

      expect(result.estimatedOneRepMax, closeTo(126.67, .01));
      expect(reloaded.data.strengthTests, hasLength(1));
      expect(reloaded.data.strengthTests.single.protocol, 'submax');
    },
  );

  test('long-term roadmap δίνει τέσσερις διαδοχικές φάσεις', () {
    final phases = DeterministicCoachEngine.phaseRoadmap(
      profile: const UserProfile(
        goal: 'Δύναμη',
        trainingPlace: 'Γυμναστήριο',
        equipment: 'Πλήρες',
        daysPerWeek: 4,
        heightCentimeters: 180,
        weightKilograms: 80,
      ),
      logs: const [],
      now: DateTime(2026),
    );

    expect(phases, hasLength(4));
    expect(phases.first.weekStart, 1);
    expect(phases.last.weekEnd, 16);
    expect(phases.where((phase) => phase.isCurrent), hasLength(1));
  });

  testWidgets('Coach Hub και Strength Test Lab αποδίδουν τα νέα εργαλεία', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(MaterialApp(home: CoachHubPage(store: store)));

    expect(find.text('PHOENIX COACH'), findsOneWidget);
    expect(find.text('DAILY CONTROL SCORE'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('PLATEAU RADAR'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('PLATEAU RADAR'), findsOneWidget);
    await tester.pumpWidget(MaterialApp(home: StrengthTestPage(store: store)));

    expect(find.byType(StrengthTestPage), findsOneWidget);
    expect(find.text('STRENGTH TEST LAB'), findsOneWidget);
    expect(find.text('AMRAP 6–20'), findsOneWidget);
    expect(find.text('SAFETY PROTOCOL'), findsOneWidget);
  });

  test('τα calisthenics assessments χαρτογραφούν deterministic επίπεδα', () {
    expect(CalisthenicsEngine.levelFor('pull-up', 0), 0);
    expect(CalisthenicsEngine.levelFor('pull-up', 5), 3);
    expect(CalisthenicsEngine.levelFor('pull-up', 15), 5);
    expect(CalisthenicsEngine.levelFor('push-up', 25), 4);
    expect(CalisthenicsEngine.levelFor('handstand', 20), 4);
    expect(CalisthenicsEngine.levelFor('l-sit', 30), 5);
  });

  test('το skill tree κλειδώνει nodes μέχρι να περάσουν prerequisites', () {
    final locked = CalisthenicsEngine.skillTree(FitnessData.initial());
    expect(
      locked.singleWhere((node) => node.id == 'handstand').unlocked,
      isFalse,
    );
    final assessed = FitnessData.initial().copyWith(
      skillAssessments: [
        SkillAssessmentResult(
          id: '1',
          skillId: 'hollow-hold',
          value: 30,
          unit: 'seconds',
          level: 3,
          recordedAt: DateTime(2026),
        ),
        SkillAssessmentResult(
          id: '2',
          skillId: 'push-up',
          value: 10,
          unit: 'reps',
          level: 2,
          recordedAt: DateTime(2026),
        ),
        SkillAssessmentResult(
          id: '3',
          skillId: 'mobility-overhead',
          value: 60,
          unit: 'score',
          level: 3,
          recordedAt: DateTime(2026),
        ),
      ],
    );
    final unlocked = CalisthenicsEngine.skillTree(assessed);
    expect(
      unlocked.singleWhere((node) => node.id == 'handstand').unlocked,
      isTrue,
    );
  });

  test('το prerequisite assessment ελέγχει δύναμη, core και mobility', () {
    final data = FitnessData.initial().copyWith(
      skillAssessments: [
        SkillAssessmentResult(
          id: '1',
          skillId: 'hollow-hold',
          value: 25,
          unit: 'seconds',
          level: 3,
          recordedAt: DateTime(2026),
        ),
        SkillAssessmentResult(
          id: '2',
          skillId: 'push-up',
          value: 12,
          unit: 'reps',
          level: 2,
          recordedAt: DateTime(2026),
        ),
      ],
    );
    final checks = CalisthenicsEngine.prerequisites(data);

    expect(checks, hasLength(5));
    expect(
      checks.singleWhere((item) => item.route == 'hollow-hold').passed,
      isTrue,
    );
    expect(
      checks.singleWhere((item) => item.route == 'push-up').passed,
      isTrue,
    );
    expect(
      checks.singleWhere((item) => item.route == 'pull-up').passed,
      isFalse,
    );
  });

  test(
    'pull-up και push-up assessments αποθηκεύονται και επανέρχονται',
    () async {
      final repository = MemoryRepository();
      final store = FitnessStore(repository);
      await store.load();
      await store.updatePreferences(hapticFeedback: false);
      await store.saveSkillAssessment(
        skillId: 'pull-up',
        value: 10,
        unit: 'reps',
        level: CalisthenicsEngine.levelFor('pull-up', 10),
      );
      await store.saveSkillAssessment(
        skillId: 'push-up',
        value: 30,
        unit: 'reps',
        level: CalisthenicsEngine.levelFor('push-up', 30),
      );
      final reloaded = FitnessStore(repository);
      await reloaded.load();

      expect(reloaded.data.skillAssessments, hasLength(2));
      expect(
        CalisthenicsEngine.latest(
          reloaded.data.skillAssessments,
          'pull-up',
        )?.level,
        4,
      );
    },
  );

  test('mobility prerequisite σέβεται και καταγεγραμμένο limitation', () {
    final data = FitnessData.initial().copyWith(
      skillAssessments: [
        SkillAssessmentResult(
          id: 'mobility',
          skillId: 'mobility-overhead',
          value: 90,
          unit: 'score',
          level: 4,
          recordedAt: DateTime(2026),
        ),
      ],
    );
    final checks = CalisthenicsEngine.prerequisites(
      data,
      profile: const UserProfile(
        goal: 'Δύναμη',
        trainingPlace: 'Σπίτι',
        equipment: 'Μονόζυγο',
        daysPerWeek: 3,
        heightCentimeters: 180,
        weightKilograms: 80,
        limitations: 'Ενόχληση στον ώμο',
      ),
    );

    expect(
      checks.singleWhere((item) => item.route == 'mobility-overhead').passed,
      isFalse,
    );
  });

  test('weighted calisthenics progression ανοίγει μετά από 10 strict reps', () {
    final base = FitnessData.initial();
    final locked = CalisthenicsEngine.weightedPullUpPlan(base);
    expect(locked.ready, isFalse);

    final ready = base.copyWith(
      skillAssessments: [
        SkillAssessmentResult(
          id: 'pull',
          skillId: 'pull-up',
          value: 12,
          unit: 'reps',
          level: 4,
          recordedAt: DateTime(2026),
        ),
      ],
      logs: [
        WorkoutLog(
          templateName: 'WEIGHTED',
          completedAt: DateTime(2026),
          minutes: 40,
          sets: [
            ExerciseSetLog(
              exerciseName: 'Weighted pull-up',
              reps: 8,
              weightKilograms: 10,
              rir: 1,
              holdSeconds: 0,
              loggedAt: DateTime(2026),
            ),
          ],
        ),
      ],
    );
    final plan = CalisthenicsEngine.weightedPullUpPlan(ready);
    expect(plan.ready, isTrue);
    expect(plan.currentLoad, 10);
    expect(plan.nextLoad, 12.5);
  });

  test('hold analytics ενώνει timed sets και handstand attempts', () {
    final data = FitnessData.initial().copyWith(
      skillAssessments: [
        SkillAssessmentResult(
          id: 'h1',
          skillId: 'handstand',
          value: 10,
          unit: 'seconds',
          level: 3,
          recordedAt: DateTime(2026, 1),
        ),
        SkillAssessmentResult(
          id: 'h2',
          skillId: 'handstand',
          value: 20,
          unit: 'seconds',
          level: 4,
          recordedAt: DateTime(2026, 2),
        ),
      ],
      logs: [
        WorkoutLog(
          templateName: 'SKILL',
          completedAt: DateTime(2026, 3),
          minutes: 30,
          sets: [
            ExerciseSetLog(
              exerciseName: 'L-sit',
              reps: 0,
              weightKilograms: 0,
              rir: 2,
              holdSeconds: 15,
              loggedAt: DateTime(2026, 3),
            ),
          ],
        ),
      ],
    );
    final analytics = CalisthenicsEngine.holdAnalytics(data);

    expect(analytics.any((item) => item.skill == 'Handstand'), isTrue);
    expect(
      analytics.singleWhere((item) => item.skill == 'Handstand').bestSeconds,
      20,
    );
    expect(analytics.any((item) => item.skill == 'L-sit'), isTrue);
  });

  test('skill-session builder παράγει ασφαλές editable πρόγραμμα', () {
    final template = CalisthenicsEngine.buildSkillSession(
      skillIds: const {'handstand', 'l-sit'},
      id: 'custom-skill-test',
      minutes: 30,
    );

    expect(template.id, startsWith('custom-skill-'));
    expect(template.tags, contains('Skill'));
    expect(template.exercises, contains('Handstand στον τοίχο'));
    expect(template.exercises, contains('Tuck L-sit'));
    expect(template.exercises.length, lessThanOrEqualTo(8));
    expect(
      template.exercisePrescriptions.values.every(
        (item) => item.targetRir >= 3,
      ),
      isTrue,
    );
  });

  testWidgets(
    'το Calisthenics Lab εμφανίζει tree, tests, timer και analytics',
    (tester) async {
      final store = FitnessStore(MemoryRepository());
      await store.load();
      await tester.pumpWidget(
        MaterialApp(home: CalisthenicsLabPage(store: store)),
      );

      expect(find.text('CALISTHENICS LAB'), findsOneWidget);
      expect(find.text('Hollow Body'), findsOneWidget);

      await tester.tap(find.text('ASSESS'));
      await tester.pumpAndSettle();
      expect(find.text('PREREQUISITE ASSESSMENT'), findsOneWidget);

      await tester.tap(find.text('PRACTICE'));
      await tester.pumpAndSettle();
      expect(find.text('HANDSTAND PRACTICE TIMER'), findsOneWidget);
      expect(find.text('Skill Session Builder'), findsOneWidget);

      await tester.tap(find.text('ANALYTICS'));
      await tester.pumpAndSettle();
      expect(find.text('HOLD-SPECIFIC ANALYTICS'), findsOneWidget);
    },
  );

  test(
    'skill assessment JSON παραμένει backward-compatible στο FitnessData',
    () {
      final data = FitnessData.initial().copyWith(
        skillAssessments: [
          SkillAssessmentResult(
            id: 'assessment',
            skillId: 'handstand',
            value: 12,
            unit: 'seconds',
            level: 3,
            recordedAt: DateTime(2026),
          ),
        ],
      );
      final decoded = FitnessData.fromJson(
        jsonDecode(jsonEncode(data.toJson())) as Map<String, dynamic>,
      );

      expect(decoded.skillAssessments.single.skillId, 'handstand');
      expect(decoded.skillAssessments.single.value, 12);
      expect(
        FitnessData.fromJson(FitnessData.initial().toJson()).skillAssessments,
        isEmpty,
      );
    },
  );

  test(
    'local workout share card χρησιμοποιεί πραγματική τελευταία συνεδρία',
    () {
      final template = FitnessData.initial().templates.first;
      final data = FitnessData.initial().copyWith(
        logs: [
          WorkoutLog(
            templateName: template.name,
            completedAt: DateTime(2026, 7, 29),
            minutes: 48,
            sessionRpe: 8,
            sets: [
              ExerciseSetLog(
                exerciseName: template.exercises.first,
                reps: 10,
                weightKilograms: 24,
                rir: 2,
                holdSeconds: 0,
                loggedAt: DateTime(2026, 7, 29),
              ),
            ],
          ),
        ],
      );

      final card = MediaPortabilityEngine.shareSummary(data, template);

      expect(card.subtitle, contains('COMPLETED'));
      expect(card.stats, contains('48 min'));
      expect(card.shareText, contains('10 × 24.0 kg'));
    },
  );

  test(
    'private progress-photo vault αποθηκεύει και διαγράφει τοπικά',
    () async {
      final store = FitnessStore(MemoryRepository());
      await store.load();

      await store.saveProgressPhoto(
        encodedBytes: base64Encode([1, 2, 3, 4]),
        mimeType: 'image/jpeg',
        note: 'Front',
        weightKilograms: 81.2,
      );
      expect(store.progressPhotos.single.note, 'Front');
      expect(store.data.toJson()['progressPhotos'], isNotEmpty);

      await store.removeProgressPhoto(store.progressPhotos.single.id);
      expect(store.progressPhotos, isEmpty);
    },
  );

  test('configurable audio cues αποθηκεύουν style και countdown', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();

    await store.updatePreferences(
      audioCues: true,
      audioCueStyle: 'coach',
      countdownCueSeconds: 5,
    );
    final reloaded = FitnessStore(repository);
    await reloaded.load();

    expect(reloaded.preferences.audioCues, isTrue);
    expect(reloaded.preferences.audioCueStyle, 'coach');
    expect(reloaded.preferences.countdownCueSeconds, 5);
  });

  test(
    'Spotify OAuth configuration δημιουργεί ασφαλές PKCE authorize URL',
    () async {
      final pkce = MediaPortabilityEngine.createSpotifyPkce(random: Random(7));
      final store = FitnessStore(MemoryRepository());
      await store.load();
      await store.configureSpotifyOAuth(
        clientId: '1234567890abcdef',
        redirectUri: 'http://127.0.0.1:8769/callback',
        pkceVerifier: pkce.verifier,
        pkceChallenge: pkce.challenge,
      );

      final uri = MediaPortabilityEngine.spotifyAuthorizeUri(store.spotifyAuth);

      expect(pkce.verifier.length, greaterThanOrEqualTo(43));
      expect(uri.host, 'accounts.spotify.com');
      expect(uri.queryParameters['code_challenge_method'], 'S256');
      expect(uri.queryParameters['client_secret'], isNull);
    },
  );

  test('κάθε workout κρατά ανεξάρτητη Spotify playlist', () async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    final first = store.data.templates.first;
    final second = store.data.templates[1];

    await store.setWorkoutPlaylist(first.id, 'spotify:playlist:phoenix-one');
    await store.setWorkoutPlaylist(
      second.id,
      'https://open.spotify.com/album/phoenix-two',
    );

    expect(
      store.workoutPlaylistFor(first.id),
      contains('/playlist/phoenix-one'),
    );
    expect(store.workoutPlaylistFor(second.id), contains('/album/phoenix-two'));
  });

  test(
    'workout playlist δέχεται Apple Music και περνά integrity audit',
    () async {
      final store = FitnessStore(MemoryRepository());
      await store.load();
      final template = store.data.templates.first;

      await store.setWorkoutPlaylist(
        template.id,
        'https://music.apple.com/gr/playlist/workout/pl.u-workout123',
      );
      final report = DataValidationEngine.audit(store.data);

      expect(
        store.workoutPlaylistFor(template.id),
        contains('music.apple.com'),
      );
      expect(
        report.issues.where((item) => item.code == 'invalid-workout-playlist'),
        isEmpty,
      );
    },
  );

  test('exercise video-link library δέχεται μόνο ασφαλές HTTPS URL', () async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    final exercise = store.data.templates.first.exercises.first;

    await store.setExerciseVideo(
      exercise,
      'https://www.youtube.com/watch?v=phoenix',
    );

    expect(store.exerciseVideoFor(exercise), contains('youtube.com'));
    expect(
      () => store.setExerciseVideo(exercise, 'http://unsafe.example/video'),
      throwsA(isA<FormatException>()),
    );
  });

  test('QR backup frames κάνουν ordered και reversed round-trip', () {
    final backup = jsonEncode({
      'app': 'Phoenix',
      'data': List.generate(500, (index) => 'record-$index'),
    });
    final frames = MediaPortabilityEngine.qrFrames(backup, payloadSize: 300);

    expect(frames.length, greaterThan(1));
    expect(MediaPortabilityEngine.assembleQrFrames(frames.reversed), backup);
    expect(
      () => MediaPortabilityEngine.assembleQrFrames(frames.skip(1)),
      throwsA(isA<FormatException>()),
    );
  });

  test('weekly reminder βρίσκει πάντα την επόμενη σωστή εμφάνιση', () {
    final mondayMorning = DateTime(2026, 8, 3, 9, 15);

    expect(
      nextWeeklyReminderOccurrence(
        now: mondayMorning,
        weekday: DateTime.monday,
        minutesSinceMidnight: 18 * 60,
      ),
      DateTime(2026, 8, 3, 18),
    );
    expect(
      nextWeeklyReminderOccurrence(
        now: mondayMorning,
        weekday: DateTime.monday,
        minutesSinceMidnight: 8 * 60,
      ),
      DateTime(2026, 8, 10, 8),
    );
    expect(
      nextWeeklyReminderOccurrence(
        now: mondayMorning,
        weekday: DateTime.wednesday,
        minutesSinceMidnight: 7 * 60 + 30,
      ),
      DateTime(2026, 8, 5, 7, 30),
    );
  });

  test('workout notification IDs και payloads είναι σταθερά', () {
    const reminder = LocalWorkoutNotificationSchedule(
      id: 'reminder-42',
      weekday: DateTime.friday,
      minutesSinceMidnight: 1080,
      title: 'Phoenix workout reminder',
      body: 'Upper body',
      enabled: true,
    );

    expect(reminder.notificationId, stableWorkoutNotificationId('reminder-42'));
    expect(reminder.notificationId, inInclusiveRange(0, 0x7fffffff));
    expect(reminder.payload, 'phoenix-workout:reminder-42');
  });

  test('Capability Studio καλύπτει ακριβώς τις 289 αναβαθμίσεις', () {
    final catalog = CapabilityStudioEngine.catalog;

    expect(catalog, hasLength(289));
    expect(catalog.first.id, 279);
    expect(catalog.last.id, 567);
    expect(catalog.map((item) => item.id).toSet(), hasLength(289));
    expect(catalog.map((item) => item.title).toSet(), hasLength(289));
    expect(catalog.map((item) => item.batch).toSet(), hasLength(30));
    expect(
      catalog.map((item) => item.kind).toSet(),
      containsAll(CapabilityKind.values),
    );
  });

  test(
    'capability state αποθηκεύεται, εκτελείται και κάνει JSON round-trip',
    () async {
      final store = FitnessStore(MemoryRepository());
      await store.load();
      const configured = CapabilityState(
        capabilityId: 314,
        guardLevel: 85,
        mode: 'conservative',
        note: 'Keep recovery key offline.',
      );

      await store.saveCapabilityState(configured);
      final spec = CapabilityStudioEngine.catalog.singleWhere(
        (item) => item.id == 314,
      );
      final outcome = CapabilityStudioEngine.evaluate(
        spec: spec,
        data: store.data,
        state: store.capabilityStateFor(314),
      );
      await store.recordCapabilityRun(
        capabilityId: 314,
        result: outcome.exportText,
      );
      final restored = FitnessData.fromJson(store.data.toJson());

      expect(spec.title, 'Backup encryption');
      expect(spec.kind, CapabilityKind.security);
      expect(store.capabilityStateFor(314).runCount, 1);
      expect(restored.capabilityStates.single.capabilityId, 314);
      expect(
        restored.capabilityStates.single.note,
        'Keep recovery key offline.',
      );
    },
  );

  testWidgets('Capability Studio αναζητά και ανοίγει numbered control', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(
      MaterialApp(home: CapabilityStudioPage(store: store)),
    );

    expect(find.text('289 LOCAL-FIRST CONTROLS'), findsOneWidget);
    expect(find.text('Print-friendly chart themes'), findsOneWidget);
    await tester.enterText(find.byType(SearchBar), 'Backup encryption');
    await tester.pump();
    final result = find.descendant(
      of: find.byType(ListTile),
      matching: find.text('Backup encryption'),
    );
    expect(result, findsOneWidget);
    await tester.tap(result);
    await tester.pumpAndSettle();
    expect(find.text('#314 • BATCH 32'), findsOneWidget);
    expect(find.text('RUN LOCAL CHECK'), findsOneWidget);
  });

  test('education library καλύπτει εννέα θεματικές και contextual search', () {
    expect(PhoenixEducationLibrary.lessons, hasLength(9));
    expect(
      PhoenixEducationLibrary.lessons.map((item) => item.topic).toSet(),
      hasLength(9),
    );
    final pain = PhoenixEducationLibrary.search('sharp');
    expect(pain.single.title, 'Pain versus effort education');
    expect(pain.single.stopRule, contains('professional guidance'));
  });

  test('local collaboration codes είναι redacted, signed και expiring', () {
    final now = DateTime(2026, 8, 7, 19);
    final data = FitnessData.initial();
    final package = LocalCollaborationEngine.coachView(
      data: data,
      now: now,
      expiresInDays: 7,
    );
    final code = LocalCollaborationEngine.encode(package);
    final decoded = LocalCollaborationEngine.decode(
      code,
      now: now.add(const Duration(days: 1)),
    );

    expect(code, startsWith('PHXC1:'));
    expect(decoded.readOnly, isTrue);
    expect(decoded.redacted, isTrue);
    expect(decoded.payload, isNot(contains('nutrition')));
    expect(decoded.payload, isNot(contains('progressPhotos')));
    expect(
      () => LocalCollaborationEngine.decode(
        code,
        now: now.add(const Duration(days: 8)),
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('session-plan import εμφανίζει conflict πριν από approval', () {
    final now = DateTime(2026, 8, 7, 19);
    final data = FitnessData.initial();
    final package = LocalCollaborationEngine.sessionPlan(
      template: data.templates.first,
      now: now,
    );
    final preview = LocalCollaborationEngine.previewImport(
      code: LocalCollaborationEngine.encode(package),
      current: data,
      now: now,
    );

    expect(preview.safeToApprove, isFalse);
    expect(preview.conflicts.single, contains(data.templates.first.id));
  });

  test(
    'structured workout imports καλύπτουν generic Strong και Hevy mappings',
    () {
      final generic = StructuredImportExportEngine.parseWorkoutCsv(
        'date,workout,exercise,reps,weight,rir\n'
        '2026-08-07T18:00:00,Upper,Bench press,8,80,2',
      );
      final strong = StructuredImportExportEngine.parseWorkoutCsv(
        'Date,Workout Name,Exercise Name,Reps,Weight (kg),RIR\n'
        '2026-08-07T18:00:00,Upper,Bench press,8,80,2',
        mapping: 'strong',
      );
      final hevy = StructuredImportExportEngine.parseWorkoutCsv(
        'start_time,title,exercise_title,reps,weight_kg,rpe\n'
        '2026-08-07T18:00:00,Upper,Bench press,8,80,8',
        mapping: 'hevy',
      );

      expect(generic.single.sets.single.weightKilograms, 80);
      expect(strong.single.templateName, 'Upper');
      expect(hevy.single.sets.single.rir, 2);
    },
  );

  test('nutrition CSV, GPX και ICS exports είναι bounded και πραγματικά', () {
    final meals = StructuredImportExportEngine.parseNutritionCsv(
      'date,name,calories,protein,carbs,fat\n'
      '2026-08-07T12:00:00,Lunch,650,45,70,20',
    );
    final route = StructuredImportExportEngine.parseGpx(
      '<gpx><trk><trkseg>'
      '<trkpt lat="37.9800" lon="23.7200"><ele>10</ele></trkpt>'
      '<trkpt lat="37.9810" lon="23.7220"><ele>18</ele></trkpt>'
      '</trkseg></trk></gpx>',
    );
    const reminder = WorkoutReminder(
      id: 'ics-one',
      weekday: DateTime.friday,
      minutesSinceMidnight: 18 * 60,
    );
    final ics = StructuredImportExportEngine.calendarIcs(
      reminders: const [reminder],
      from: DateTime(2026, 8, 7),
    );

    expect(meals.single.proteinGrams, 45);
    expect(route.distanceKilometers, greaterThan(.1));
    expect(route.elevationGainMeters, 8);
    expect(ics, contains('BEGIN:VEVENT'));
    expect(ics, contains('UID:phoenix-ics-one-0@local'));
  });

  test(
    'incremental backup και selective restore δείχνουν ακριβείς αλλαγές',
    () {
      final baseline = FitnessData.initial();
      final current = baseline.copyWith(
        spotifyUrl: 'https://open.spotify.com/track/local',
      );
      final incremental = StructuredImportExportEngine.incremental(
        baseline: baseline,
        current: current,
      );
      final preview = StructuredImportExportEngine.previewSelectiveRestore(
        backup: jsonEncode({'data': current.toJson()}),
        current: baseline,
      );

      expect(incremental.changedKeys, ['spotifyUrl']);
      expect(incremental.encode(), contains('PHX-INCREMENTAL'));
      expect(preview.valid, isTrue);
      expect(preview.availableSections, contains('templates'));
      expect(preview.conflicts, isNotEmpty);
    },
  );

  test(
    'encrypted backup κάνει authenticated round-trip και απορρίπτει password',
    () async {
      const clear = '{"private":"phoenix"}';
      final encrypted = await SecureBackupEngine.encrypt(
        clearText: clear,
        password: 'correct horse battery staple',
      );
      final restored = await SecureBackupEngine.decrypt(
        envelope: encrypted,
        password: 'correct horse battery staple',
      );

      expect(restored, clear);
      expect(encrypted, isNot(contains('phoenix')));
      expect(
        () => SecureBackupEngine.decrypt(
          envelope: encrypted,
          password: 'wrong password value',
        ),
        throwsA(isA<FormatException>()),
      );
    },
  );

  test(
    'provider-neutral sync encrypts metadata and previews divergent devices',
    () async {
      final local = FitnessData.initial().copyWith(
        spotifyUrl: 'https://example.com/local',
        hydration: [
          HydrationEntry(milliliters: 500, loggedAt: DateTime(2026, 8, 7, 9)),
        ],
      );
      final incomingData = FitnessData.initial().copyWith(
        spotifyUrl: 'https://example.com/incoming',
        preferences: const AppPreferences(languageCode: 'de'),
        hydration: [
          HydrationEntry(milliliters: 750, loggedAt: DateTime(2026, 8, 7, 11)),
        ],
      );
      final envelope = await EncryptedSyncEngine.create(
        data: incomingData,
        password: 'correct horse battery staple',
        deviceId: 'test-laptop',
        revision: 42,
        baseChecksum: EncryptedSyncEngine.checksum(local),
        createdAt: DateTime.utc(2026, 8, 7, 12),
      );
      final incoming = await EncryptedSyncEngine.open(
        envelope: envelope,
        password: 'correct horse battery staple',
      );
      final preview = EncryptedSyncEngine.preview(
        local: local,
        incoming: incoming,
      );

      expect(envelope, isNot(contains('example.com/incoming')));
      expect(incoming.revision, 42);
      expect(preview.baseMatchesLocal, isTrue);
      expect(
        preview.changedSections,
        containsAll(['hydration', 'preferences']),
      );
      expect(preview.conflicts, isNotEmpty);
      await expectLater(
        EncryptedSyncEngine.open(
          envelope: envelope,
          password: 'wrong password value',
        ),
        throwsFormatException,
      );
    },
  );

  test(
    'safe sync merge is deterministic and never mutates its inputs',
    () async {
      final local = FitnessData.initial().copyWith(
        spotifyUrl: 'https://example.com/local',
        hydration: [
          HydrationEntry(milliliters: 500, loggedAt: DateTime(2026, 8, 7, 9)),
        ],
      );
      final remote = FitnessData.initial().copyWith(
        spotifyUrl: 'https://example.com/remote',
        hydration: [
          HydrationEntry(milliliters: 750, loggedAt: DateTime(2026, 8, 7, 11)),
        ],
      );
      final before = jsonEncode(local.toJson());
      final envelope = await EncryptedSyncEngine.create(
        data: remote,
        password: 'correct horse battery staple',
        deviceId: 'other-laptop',
        revision: 1,
      );
      final incoming = await EncryptedSyncEngine.open(
        envelope: envelope,
        password: 'correct horse battery staple',
      );
      final first = EncryptedSyncEngine.resolve(
        local: local,
        incoming: incoming,
        resolution: SyncResolution.mergeSafely,
      );
      final second = EncryptedSyncEngine.resolve(
        local: local,
        incoming: incoming,
        resolution: SyncResolution.mergeSafely,
      );

      expect(jsonEncode(local.toJson()), before);
      expect(first.spotifyUrl, 'https://example.com/local');
      expect(first.hydration, hasLength(2));
      expect(first.toJson(), second.toJson());
    },
  );

  test('approved sync application is local, persisted and undoable', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();
    final incoming = store.data.copyWith(
      spotifyUrl: 'https://example.com/approved',
    );

    await store.applyApprovedSyncData(incoming);

    expect(repository.value.spotifyUrl, 'https://example.com/approved');
    expect(store.canUndo, isTrue);
    expect(await store.undoLastMutation(), isTrue);
    expect(repository.value.spotifyUrl, isEmpty);
  });

  test('failed sync integrity audit leaves local data untouched', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();
    final before = jsonEncode(store.data.toJson());
    final invalid = store.data.copyWith(
      templates: [...store.data.templates, store.data.templates.first],
    );

    await expectLater(
      store.applyApprovedSyncData(invalid),
      throwsFormatException,
    );

    expect(jsonEncode(store.data.toJson()), before);
    expect(jsonEncode(repository.value.toJson()), before);
    expect(store.canUndo, isFalse);
  });

  test('local performance profile reports bounded finite measurements', () {
    final measurements = LocalPerformanceProfiler.measure(
      FitnessData.initial(),
    );
    final report = OperationalReadinessEngine.performanceBudget(measurements);

    expect(
      measurements.keys,
      containsAll([
        'json-serialization-ms',
        'json-deserialization-ms',
        'integrity-audit-ms',
        'reconciliation-ms',
        'profile-payload-kb',
      ]),
    );
    expect(measurements.values.every((value) => value.isFinite), isTrue);
    expect(report.passes, isTrue);
  });

  test(
    'accessibility preferences είναι bounded και backward compatible',
    () async {
      final store = FitnessStore(MemoryRepository());
      await store.load();
      await store.updatePreferences(
        textScale: 4,
        reducedMotion: true,
        colorVisionMode: 'deuteranopia',
        readabilityFont: true,
        oneHandMode: true,
        touchTargetScale: 3,
      );
      final restored = FitnessData.fromJson(store.data.toJson()).preferences;

      expect(restored.textScale, 1.6);
      expect(restored.touchTargetScale, 1.5);
      expect(restored.reducedMotion, isTrue);
      expect(restored.colorVisionMode, 'deuteranopia');
      expect(restored.oneHandMode, isTrue);
    },
  );

  test(
    'vault εφαρμόζει cooldown μετά από επαναλαμβανόμενα λάθος PIN',
    () async {
      final store = FitnessStore(MemoryRepository());
      await store.load();
      await store.setVaultPin('2468');
      store.lockVault();

      for (var attempt = 0; attempt < 5; attempt++) {
        expect(await store.unlockVault('1357'), isFalse);
      }

      expect(store.failedUnlockAttempts, 5);
      expect(store.unlockCooldownRemaining, greaterThan(Duration.zero));
      expect(await store.unlockVault('2468'), isFalse);
      expect(store.vaultUnlocked, isFalse);
    },
  );

  test('data retention αφαιρεί μόνο παλιά entries και διατηρεί Undo', () async {
    final repository = MemoryRepository();
    repository.value = repository.value.copyWith(
      weights: [
        WeightEntry(kilograms: 80, recordedAt: DateTime(2024, 1, 1)),
        WeightEntry(kilograms: 78, recordedAt: DateTime.now()),
      ],
    );
    final store = FitnessStore(repository);
    await store.load();

    final removed = await store.pruneHistoryBefore(
      DateTime.now().subtract(const Duration(days: 365)),
    );

    expect(removed, 1);
    expect(store.data.weights.single.kilograms, 78);
    expect(store.canUndo, isTrue);
    await store.undoLastMutation();
    expect(store.data.weights, hasLength(2));
  });

  test('coaching report engine δημιουργεί πραγματικό PDF', () async {
    final bytes = await CoachingReportEngine.buildCoachingReport(
      FitnessData.initial(),
      generatedAt: DateTime(2026, 7, 29),
    );

    expect(utf8.decode(bytes.take(4).toList()), '%PDF');
    expect(bytes.length, greaterThan(1000));
  });

  test('printable workout sheet δημιουργεί πραγματικό PDF', () async {
    final bytes = await CoachingReportEngine.buildWorkoutSheet(
      FitnessData.initial().templates.first,
    );

    expect(utf8.decode(bytes.take(4).toList()), '%PDF');
    expect(bytes.length, greaterThan(1000));
  });

  test('standard wearable import διαβάζει CSV και JSON aliases', () async {
    const csv =
        'date,steps,restingHeartRate,sleepHours\n'
        '2026-07-28,10420,58,7.5\n'
        '2026-07-29,8200,61,6.75';
    final csvRows = MediaPortabilityEngine.parseWearable(
      csv,
      source: 'watch.csv',
    );
    final jsonRows = MediaPortabilityEngine.parseWearable(
      jsonEncode({
        'samples': [
          {
            'day': '2026-07-30',
            'step_count': 9000,
            'rhr': 60,
            'sleep_minutes': 420,
          },
        ],
      }),
      source: 'health.json',
    );
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await store.saveWearableSummaries([...csvRows, ...jsonRows]);

    expect(csvRows.first.sleepMinutes, 405);
    expect(jsonRows.single.steps, 9000);
    expect(store.wearableSummaries.length, 3);
  });

  testWidgets(
    'Media & Portability εμφανίζει και τις τέσσερις λειτουργικές ζώνες',
    (tester) async {
      final store = FitnessStore(MemoryRepository());
      await store.load();
      await tester.pumpWidget(
        MaterialApp(home: MediaPortabilityPage(store: store)),
      );

      expect(find.text('MEDIA & PORTABILITY'), findsOneWidget);
      expect(find.text('LOCAL WORKOUT SHARE CARD'), findsOneWidget);

      await tester.tap(find.text('VAULT'));
      await tester.pumpAndSettle();
      expect(find.text('PRIVATE PROGRESS-PHOTO VAULT'), findsOneWidget);

      await tester.tap(find.text('MEDIA'));
      await tester.pumpAndSettle();
      expect(find.text('CONFIGURABLE AUDIO CUES'), findsOneWidget);

      await tester.tap(find.text('TRANSFER'));
      await tester.pumpAndSettle();
      expect(find.text('BACKUP FILE TRANSFER'), findsOneWidget);
      expect(find.text('EXPORT BACKUP FILE'), findsOneWidget);
      expect(find.text('IMPORT BACKUP FILE'), findsOneWidget);
      expect(find.text('QR BACKUP TRANSFER'), findsOneWidget);
      await tester.drag(
        find.byKey(const ValueKey('media-transfer-scroll')),
        const Offset(0, -900),
      );
      await tester.pumpAndSettle();
      expect(find.text('EXPORT ENCRYPTED SYNC'), findsOneWidget);
      expect(find.text('IMPORT & REVIEW SYNC'), findsOneWidget);
    },
  );

  test(
    'Drift SQLite repository persists a complete profile round-trip',
    () async {
      final database = PhoenixDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftFitnessRepository(database: database);
      final original = await repository.load();
      final updated = original.copyWith(
        preferences: original.preferences.copyWith(
          languageCode: 'en',
          lockTimeoutMinutes: 15,
        ),
        workoutReminders: const [
          WorkoutReminder(
            id: 'sqlite-reminder',
            weekday: 2,
            minutesSinceMidnight: 1110,
          ),
        ],
      );

      await repository.save(updated);
      final restored = await repository.load();

      expect(restored.preferences.languageCode, 'en');
      expect(restored.preferences.lockTimeoutMinutes, 15);
      expect(restored.workoutReminders.single.id, 'sqlite-reminder');
    },
  );

  test('versioned storage migration upgrades v1 data through schema v20', () {
    final source = FitnessData.initial().toJson()
      ..remove('preferences')
      ..remove('workoutReminders')
      ..remove('progressPhotos');

    final result = StorageMigrationEngine.migrate(source, fromVersion: 1);

    expect(result.toVersion, StorageMigrationEngine.currentVersion);
    expect(result.appliedSteps, hasLength(19));
    expect(result.json['preferences'], isA<Map<String, dynamic>>());
    expect(result.json['workoutReminders'], isEmpty);
    expect(result.json['progressPhotos'], isEmpty);
    expect(result.json['strengthTrainingMaxes'], isEmpty);
    expect(result.json['hypertrophyCheckIns'], isEmpty);
    expect(result.json['hypertrophyTechniqueLogs'], isEmpty);
    expect(result.json['cardioSessions'], isEmpty);
    expect(result.json['conditioningBenchmarks'], isEmpty);
    expect(result.json['runningSessions'], isEmpty);
    expect(result.json['runningShoes'], isEmpty);
    expect(result.json['cyclingSessions'], isEmpty);
    expect(result.json['rowingSessions'], isEmpty);
    expect(result.json['calisthenicsSkillLogs'], isEmpty);
    expect(result.json['mobilityScreenLogs'], isEmpty);
    expect(result.json['recoveryInterventions'], isEmpty);
    expect(result.json['nutritionPhaseLogs'], isEmpty);
    expect(result.json['pantryItems'], isEmpty);
    expect(result.json['favoriteIngredientIds'], isEmpty);
    expect(result.json['bodyMeasurementLogs'], isEmpty);
    expect(result.json['healthHabits'], isEmpty);
    expect(result.json['habitCheckIns'], isEmpty);
    expect(result.json['sleepRoutineLogs'], isEmpty);
    expect(result.json['stressCheckInLogs'], isEmpty);
    expect(result.json['coachRecommendationFeedback'], isEmpty);
    expect(result.json['analyticsDashboardMetrics'], isNotEmpty);
    expect(result.json['analyticsAnnotations'], isEmpty);
    expect(
      (result.json['preferences']
          as Map<String, dynamic>)['nutritionDietStyle'],
      'balanced',
    );
    expect(
      (result.json['preferences']
          as Map<String, dynamic>)['nutritionMealsPerDay'],
      4,
    );
    expect(FitnessData.fromJson(result.json), isA<FitnessData>());
  });

  test(
    'local diagnostic trail is persisted and ordered newest-first',
    () async {
      final database = PhoenixDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftFitnessRepository(database: database);
      await repository.load();
      await repository.recordDiagnostic(
        category: 'test',
        message: 'First diagnostic',
      );
      await repository.recordDiagnostic(
        category: 'test',
        message: 'Newest diagnostic',
        level: 'warning',
      );

      final diagnostics = await repository.recentDiagnostics(limit: 10);

      expect(diagnostics.first.message, 'Newest diagnostic');
      expect(diagnostics.first.level, 'warning');
      expect(diagnostics.any((item) => item.category == 'migration'), isTrue);
    },
  );

  test(
    'automatic startup audit repairs critical duplicate template IDs',
    () async {
      final repository = MemoryRepository();
      final initial = FitnessData.initial();
      repository.value = initial.copyWith(
        templates: [...initial.templates, initial.templates.first],
      );
      final store = FitnessStore(repository);

      await store.load();

      final ids = store.data.templates.map((item) => item.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(store.startupAudit.criticalCount, 0);
    },
  );

  test('multiple local profiles keep isolated settings and data', () async {
    final database = PhoenixDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftFitnessRepository(database: database);
    final main = await repository.load();
    final secondId = await repository.createProfile(
      'Second Athlete',
      FitnessData.initial().copyWith(
        preferences: const AppPreferences(
          languageCode: 'en',
          themePreset: 'ocean',
        ),
      ),
    );

    final second = await repository.switchProfile(secondId);
    expect(second.preferences.themePreset, 'ocean');
    await repository.save(
      second.copyWith(
        workoutReminders: const [
          WorkoutReminder(
            id: 'second-only',
            weekday: 4,
            minutesSinceMidnight: 1080,
          ),
        ],
      ),
    );
    final restoredMain = await repository.switchProfile('default');

    expect(restoredMain.workoutReminders, main.workoutReminders);
    expect(restoredMain.workoutReminders, isEmpty);
    expect(await repository.listProfiles(), hasLength(2));
  });

  test(
    'profile persistence stores checksums and rotates verified snapshots',
    () async {
      final database = PhoenixDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftFitnessRepository(database: database);
      var data = await repository.load();
      for (var index = 0; index < 7; index++) {
        data = data.copyWith(spotifyUrl: 'https://example.com/$index');
        await repository.save(data);
      }

      final state = await database.select(database.profileStates).getSingle();
      final snapshots = await database.select(database.profileSnapshots).get();

      expect(state.checksum, hasLength(64));
      expect(snapshots.where((item) => !item.quarantined).length, 5);
      expect(snapshots.every((item) => item.checksum.length == 64), isTrue);
    },
  );

  test(
    'Recovery Vault lists metadata and restores without losing current state',
    () async {
      final database = PhoenixDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftFitnessRepository(database: database);
      final initial = await repository.load();
      await repository.save(
        initial.copyWith(spotifyUrl: 'https://example.com/first'),
      );
      await repository.save(
        initial.copyWith(spotifyUrl: 'https://example.com/current'),
      );

      final beforeRestore = await repository.listProfileSnapshots();
      expect(beforeRestore, isNotEmpty);
      expect(beforeRestore.first.verified, isTrue);
      expect(beforeRestore.first.sizeBytes, greaterThan(0));
      expect(beforeRestore.first.checksum, hasLength(64));

      final restored = await repository.restoreProfileSnapshot(
        beforeRestore.first.id,
      );
      final afterRestore = await repository.listProfileSnapshots();

      expect(restored.spotifyUrl, 'https://example.com/first');
      expect((await repository.load()).spotifyUrl, restored.spotifyUrl);
      expect(afterRestore.length, greaterThanOrEqualTo(beforeRestore.length));
      expect((await repository.recentDiagnostics()).first.category, 'recovery');
    },
  );

  test('Recovery Vault refuses quarantined or altered snapshots', () async {
    final database = PhoenixDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftFitnessRepository(database: database);
    final current = await repository.load();
    final id = await database
        .into(database.profileSnapshots)
        .insert(
          ProfileSnapshotsCompanion.insert(
            profileId: 'default',
            payload: jsonEncode(current.toJson()),
            checksum: 'invalid',
            storageVersion: StorageMigrationEngine.currentVersion,
            reason: 'test-quarantine',
            quarantined: const Value(true),
            createdAt: DateTime(2026, 8, 7),
          ),
        );

    final snapshots = await repository.listProfileSnapshots();
    expect(snapshots.singleWhere((item) => item.id == id).verified, isFalse);
    await expectLater(
      repository.restoreProfileSnapshot(id),
      throwsFormatException,
    );
    expect((await repository.load()).toJson(), current.toJson());
  });

  test(
    'checksum mismatch is quarantined and recovered from verified snapshot',
    () async {
      final database = PhoenixDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftFitnessRepository(database: database);
      final original = await repository.load();
      await repository.save(
        original.copyWith(spotifyUrl: 'https://example.com/new'),
      );
      await (database.update(
        database.profileStates,
      )..where((row) => row.profileId.equals('default'))).write(
        const ProfileStatesCompanion(
          payload: Value('{damaged'),
          checksum: Value('invalid-checksum'),
        ),
      );

      final recovered = await repository.load();
      final snapshots = await database.select(database.profileSnapshots).get();

      expect(recovered.spotifyUrl, original.spotifyUrl);
      expect(snapshots.any((item) => item.quarantined), isTrue);
      expect(
        (await repository.recentDiagnostics()).first.message,
        contains('verified snapshot'),
      );
    },
  );

  test('failed profile checksum leaves active profile unchanged', () async {
    final database = PhoenixDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftFitnessRepository(database: database);
    await repository.load();
    final secondId = await repository.createProfile(
      'Damaged Athlete',
      FitnessData.initial(),
    );
    await (database.update(database.profileStates)
          ..where((row) => row.profileId.equals(secondId)))
        .write(const ProfileStatesCompanion(checksum: Value('bad')));

    await expectLater(
      repository.switchProfile(secondId),
      throwsFormatException,
    );

    expect(repository.activeProfileId, 'default');
    final active = await (database.select(
      database.appMeta,
    )..where((row) => row.key.equals('activeProfileId'))).getSingle();
    expect(active.value, 'default');
  });

  test(
    'app lock timeout is bounded and the PIN vault relocks locally',
    () async {
      final store = FitnessStore(MemoryRepository());
      await store.load();
      await store.updatePreferences(lockTimeoutMinutes: 120);
      await store.setVaultPin('2468');

      expect(store.preferences.lockTimeoutMinutes, 60);
      expect(store.vaultUnlocked, isTrue);
      store.lockVault();
      expect(store.vaultUnlocked, isFalse);
      expect(await store.unlockVault('2468'), isTrue);
    },
  );

  test('local workout reminders are validated, due and removable', () async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    final now = DateTime(2026, 7, 29, 18, 30);
    await store.saveWorkoutReminder(
      weekday: now.weekday,
      minutesSinceMidnight: 18 * 60 + 35,
      templateId: store.data.templates.first.id,
    );

    expect(store.dueWorkoutReminders(now), hasLength(1));
    final reminderId = store.data.workoutReminders.single.id;
    await store.toggleWorkoutReminder(reminderId, false);
    expect(store.dueWorkoutReminders(now), isEmpty);
    await store.removeWorkoutReminder(reminderId);
    expect(store.data.workoutReminders, isEmpty);
  });

  test('final security accessibility and PWA release audit is ready', () {
    final data = FitnessData.initial();
    final report = ReleaseAuditEngine.audit(
      data: data,
      integrity: DataValidationEngine.audit(data),
      profiles: [
        LocalProfileInfo(
          id: 'default',
          name: 'Main Athlete',
          updatedAt: DateTime(2026, 7, 29),
          isActive: true,
        ),
      ],
      diagnostics: [
        DiagnosticEntry(
          level: 'info',
          category: 'integrity',
          message: 'Healthy',
          createdAt: DateTime(2026, 7, 29),
        ),
      ],
      pwaReady: true,
    );

    expect(report.releaseReady, isTrue);
    expect(report.checks, hasLength(10));
    expect(report.score, greaterThanOrEqualTo(90));
    expect(
      report.checks.where((item) => item.status == ReleaseAuditStatus.fail),
      isEmpty,
    );
  });

  testWidgets(
    'Reliability Center exposes status profiles recovery reminders and audit',
    (tester) async {
      final store = FitnessStore(MemoryRepository());
      await store.load();
      await tester.pumpWidget(
        MaterialApp(home: ReliabilityCenterPage(store: store)),
      );
      await tester.pumpAndSettle();

      expect(find.text('RELIABILITY CENTER'), findsOneWidget);
      expect(find.text('DRIFT / SQLITE ACTIVE'), findsOneWidget);
      expect(find.text('STATUS'), findsOneWidget);
      expect(find.text('PROFILES'), findsOneWidget);
      expect(find.text('RECOVERY'), findsOneWidget);
      expect(find.text('REMINDERS'), findsOneWidget);
      expect(find.text('AUDIT'), findsOneWidget);

      await tester.tap(find.text('REMINDERS'));
      await tester.pumpAndSettle();
      expect(find.text('ADD REMINDER'), findsOneWidget);

      await tester.tap(find.text('AUDIT'));
      await tester.pumpAndSettle();
      expect(find.textContaining('RELEASE AUDIT'), findsOneWidget);
    },
  );

  testWidgets('Recovery Vault asks before restoring verified data', (
    tester,
  ) async {
    final database = PhoenixDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftFitnessRepository(database: database);
    final store = FitnessStore(repository);
    await store.load();
    await repository.save(
      store.data.copyWith(spotifyUrl: 'https://example.com/change'),
    );
    await store.refreshReliabilityData();
    await tester.pumpWidget(
      MaterialApp(home: ReliabilityCenterPage(store: store)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('RECOVERY'));
    await tester.pumpAndSettle();
    expect(find.text('LOCAL RECOVERY VAULT'), findsOneWidget);
    expect(find.text('VERIFIED SNAPSHOT'), findsWidgets);

    await tester.tap(find.byTooltip('Restore verified snapshot').first);
    await tester.pumpAndSettle();
    expect(find.text('RESTORE VERIFIED SNAPSHOT?'), findsOneWidget);
    expect(find.text('CANCEL'), findsOneWidget);
    expect(find.text('RESTORE'), findsOneWidget);
  });

  test('exercise taxonomy identifies category and movement pattern', () {
    final squat = ExerciseIntelligenceEngine.profileFor('Goblet squat');
    final carry = ExerciseIntelligenceEngine.profileFor('Farmer carry');

    expect(squat.category, 'STRENGTH');
    expect(squat.movementPattern, 'squat');
    expect(carry.category, 'CONDITIONING');
    expect(carry.movementPattern, 'loaded carry');
  });

  test('exercise intelligence maps primary and secondary muscles', () {
    final pullUp = ExerciseIntelligenceEngine.profileFor('Αυστηρές έλξεις');
    final calfRaise = ExerciseIntelligenceEngine.profileFor('Άρσεις γάμπας');

    expect(pullUp.primaryMuscles, containsAll(['lats', 'biceps']));
    expect(pullUp.secondaryMuscles, contains('forearms'));
    expect(calfRaise.primaryMuscles, ['calves']);
  });

  test('difficulty and skill-demand levels distinguish advanced skills', () {
    final handstand = ExerciseIntelligenceEngine.profileFor(
      'Handstand wall hold',
    );
    final deadBug = ExerciseIntelligenceEngine.profileFor('Dead bug');

    expect(handstand.difficulty, 5);
    expect(handstand.skillDemand, 5);
    expect(deadBug.difficulty, lessThan(handstand.difficulty));
  });

  test('equipment matrix respects the athlete available equipment', () {
    const homeProfile = UserProfile(
      goal: 'Δύναμη',
      trainingPlace: 'Σπίτι',
      equipment: 'Σωματικό βάρος, λάστιχο',
      daysPerWeek: 3,
      heightCentimeters: 180,
      weightKilograms: 80,
    );
    const gymProfile = UserProfile(
      goal: 'Δύναμη',
      trainingPlace: 'Πλήρες γυμναστήριο',
      equipment: 'Πλήρες γυμναστήριο',
      daysPerWeek: 4,
      heightCentimeters: 180,
      weightKilograms: 80,
    );
    final dumbbellSquat = ExerciseIntelligenceEngine.profileFor('Goblet squat');

    expect(
      ExerciseIntelligenceEngine.isEquipmentCompatible(
        dumbbellSquat,
        homeProfile,
      ),
      isFalse,
    );
    expect(
      ExerciseIntelligenceEngine.isEquipmentCompatible(
        dumbbellSquat,
        gymProfile,
      ),
      isTrue,
    );
  });

  test('caution flags remove conflicting exercises from safe explorer', () {
    final results = ExerciseIntelligenceEngine.explore(
      data: FitnessData.initial(),
      filter: const ExerciseExplorerFilter(
        movementPattern: 'vertical push',
        avoidAreas: ['shoulder'],
      ),
    );

    expect(results, isEmpty);
    expect(
      ExerciseIntelligenceEngine.profileFor('Pike push-ups').cautionAreas,
      contains('shoulder'),
    );
  });

  test('regression and progression graph returns an ordered path', () {
    final path = ExerciseIntelligenceEngine.progressionPath(
      'Κάμψεις σε υπερυψωμένη επιφάνεια',
      FitnessData.initial(),
    );

    expect(path.first.name, 'Κάμψεις σε υπερυψωμένη επιφάνεια');
    expect(path.map((item) => item.name), contains('Κάμψεις με παύση 1″'));
    expect(
      path.map((item) => item.difficulty),
      everyElement(inInclusiveRange(1, 5)),
    );
  });

  test('substitution ranking scores pattern muscles and equipment', () {
    final ranked = ExerciseIntelligenceEngine.rankedSubstitutions(
      exercise: 'Κάμψεις',
      data: FitnessData.initial(),
      avoidAreas: const ['knee'],
    );

    expect(ranked, isNotEmpty);
    expect(ranked.first.score, greaterThanOrEqualTo(60));
    expect(ranked.first.profile.movementPattern, 'horizontal push');
    expect(ranked.first.reasons, contains('same movement pattern'));
  });

  test('multi-filter explorer combines query muscle equipment and level', () {
    final results = ExerciseIntelligenceEngine.explore(
      data: FitnessData.initial(),
      filter: const ExerciseExplorerFilter(
        query: 'squat',
        movementPattern: 'squat',
        muscle: 'quadriceps',
        equipment: 'dumbbells',
        maxDifficulty: 3,
      ),
    );

    expect(results.map((item) => item.name), contains('Goblet squat'));
    expect(
      results,
      everyElement(
        isA<ExerciseIntelligenceProfile>().having(
          (item) => item.difficulty,
          'difficulty',
          lessThanOrEqualTo(3),
        ),
      ),
    );
  });

  test(
    'custom exercise builder data persists through store and JSON',
    () async {
      final repository = MemoryRepository();
      final store = FitnessStore(repository);
      await store.load();

      await store.saveCustomExercise(
        const CustomExerciseDefinition(
          id: '',
          name: 'Phoenix band press',
          primaryMuscles: ['chest'],
          secondaryMuscles: ['triceps'],
          movementPattern: 'horizontal push',
          difficulty: 2,
          skillDemand: 1,
          equipment: ['resistance band'],
          cautionAreas: ['shoulder'],
          regression: 'Κάμψεις σε υπερυψωμένη επιφάνεια',
          progression: 'Κάμψεις',
          notes: 'Keep ribs down.',
        ),
      );
      final restored = FitnessData.fromJson(
        jsonDecode(jsonEncode(repository.value.toJson()))
            as Map<String, dynamic>,
      );

      expect(restored.customExercises, hasLength(1));
      expect(restored.customExercises.single.name, 'Phoenix band press');
      expect(
        ExerciseIntelligenceEngine.allProfiles(
          restored,
        ).where((item) => item.name == 'Phoenix band press').single.isCustom,
        isTrue,
      );
    },
  );

  test('integrity audit repairs duplicate custom exercise definitions', () {
    const exercise = CustomExerciseDefinition(
      id: 'same',
      name: 'Same exercise',
      primaryMuscles: ['chest'],
      movementPattern: 'horizontal push',
    );
    final data = FitnessData.initial().copyWith(
      customExercises: const [exercise, exercise],
    );

    expect(
      DataValidationEngine.audit(
        data,
      ).issues.any((item) => item.code == 'invalid-custom-exercise'),
      isTrue,
    );
    expect(DataValidationEngine.repair(data).customExercises, hasLength(1));
  });

  testWidgets(
    'Exercise Intelligence Lab exposes explorer paths and personal builder',
    (tester) async {
      final store = FitnessStore(MemoryRepository());
      await store.load();
      await tester.pumpWidget(
        MaterialApp(home: ExerciseIntelligencePage(store: store)),
      );
      await tester.pumpAndSettle();

      expect(find.text('EXERCISE INTELLIGENCE'), findsOneWidget);
      expect(find.text('EXPLORE'), findsOneWidget);
      expect(find.text('PATHS'), findsOneWidget);
      expect(find.text('BUILDER'), findsOneWidget);
      expect(find.textContaining('MATCHES'), findsOneWidget);

      await tester.tap(find.text('PATHS'));
      await tester.pumpAndSettle();
      expect(find.text('REGRESSION → PROGRESSION GRAPH'), findsOneWidget);
      expect(find.text('SCORED SUBSTITUTIONS'), findsOneWidget);

      await tester.tap(find.text('BUILDER'));
      await tester.pumpAndSettle();
      expect(find.text('CUSTOM EXERCISE BUILDER'), findsOneWidget);
      expect(find.text('MUSCLE MAP COVERAGE'), findsOneWidget);
      expect(find.text('NEW EXERCISE'), findsOneWidget);
    },
  );

  test('mesocycle wizard builds one safe session per training day', () {
    const input = ProgramArchitectureInput(
      goal: 'Strength',
      daysPerWeek: 3,
      sessionMinutes: 50,
      experienceLevel: 'Beginner',
      mesocycleWeeks: 5,
    );
    final result = ProgramArchitectureEngine.build(
      data: FitnessData.initial(),
      input: input,
      generatedAt: DateTime(2026, 7, 29),
    );

    expect(result.mesocycleWeeks, 5);
    expect(result.templates, hasLength(3));
    expect(
      result.templates,
      everyElement(
        isA<WorkoutTemplate>().having(
          (item) => item.id,
          'id',
          startsWith('custom-architecture-'),
        ),
      ),
    );
  });

  test('goal-specific split selector prefers upper lower for four days', () {
    const input = ProgramArchitectureInput(
      goal: 'Strength',
      daysPerWeek: 4,
      sessionMinutes: 60,
      experienceLevel: 'Intermediate',
    );
    final options = ProgramArchitectureEngine.splitOptions(input);

    expect(options.first.id, 'upper-lower');
    expect(options.first.score, greaterThan(options.last.score));
  });

  test('session-duration budgeting returns plans inside a realistic cap', () {
    const input = ProgramArchitectureInput(
      goal: 'General fitness',
      daysPerWeek: 3,
      sessionMinutes: 45,
      experienceLevel: 'Beginner',
    );
    final result = ProgramArchitectureEngine.build(
      data: FitnessData.initial(),
      input: input,
      generatedAt: DateTime(2026, 7, 29),
    );

    expect(
      result.estimatedMinutes.values,
      everyElement(lessThanOrEqualTo(input.sessionMinutes)),
    );
    expect(
      ProgramArchitectureEngine.estimateSessionMinutes(
        exerciseCount: 5,
        setsPerExercise: 3,
        restSeconds: 90,
      ),
      greaterThan(0),
    );
  });

  test('weekly set-budget planner counts real primary-muscle work', () {
    final result = ProgramArchitectureEngine.build(
      data: FitnessData.initial(),
      input: const ProgramArchitectureInput(
        goal: 'Muscle hypertrophy',
        daysPerWeek: 4,
        sessionMinutes: 60,
        experienceLevel: 'Intermediate',
      ),
      generatedAt: DateTime(2026, 7, 29),
    );

    expect(result.weeklySetBudget, isNotEmpty);
    expect(result.weeklySetBudget['quadriceps'], greaterThan(0));
    expect(result.weeklySetBudget.values.every((value) => value > 0), isTrue);
  });

  test('movement balance audit covers squat hinge push and pull patterns', () {
    final result = ProgramArchitectureEngine.build(
      data: FitnessData.initial(),
      input: const ProgramArchitectureInput(
        goal: 'General fitness',
        daysPerWeek: 3,
        sessionMinutes: 60,
        experienceLevel: 'Intermediate',
      ),
      generatedAt: DateTime(2026, 7, 29),
    );

    expect(result.movementCoverage['squat'], greaterThan(0));
    expect(result.movementCoverage['hinge'], greaterThan(0));
    expect(result.movementCoverage['horizontal push'], greaterThan(0));
    expect(result.movementCoverage['horizontal pull'], greaterThan(0));
  });

  test(
    'exercise-order optimizer places high-skill work before conditioning',
    () {
      final ordered = ProgramArchitectureEngine.optimizeOrder([
        ExerciseIntelligenceEngine.profileFor('Air bike intervals'),
        ExerciseIntelligenceEngine.profileFor('Handstand wall hold'),
        ExerciseIntelligenceEngine.profileFor('Goblet squat'),
      ]);

      expect(ordered.first.name, 'Handstand wall hold');
      expect(ordered.last.name, 'Air bike intervals');
    },
  );

  test('frequency engine adapts skills and conditioning to the schedule', () {
    final frequency = ProgramArchitectureEngine.recommendedFrequency(
      const ProgramArchitectureInput(
        goal: 'Calisthenics',
        daysPerWeek: 5,
        sessionMinutes: 50,
        experienceLevel: 'Intermediate',
        includeConditioning: true,
      ),
    );

    expect(frequency['skills'], 3);
    expect(frequency['conditioning'], 2);
    expect(frequency['major muscles'], 2);
  });

  test('minimum-effective-dose mode creates two working sets', () {
    final result = ProgramArchitectureEngine.build(
      data: FitnessData.initial(),
      input: const ProgramArchitectureInput(
        goal: 'Strength',
        daysPerWeek: 3,
        sessionMinutes: 45,
        experienceLevel: 'Beginner',
        volumeMode: ProgramVolumeMode.minimumEffective,
      ),
      generatedAt: DateTime(2026, 7, 29),
    );

    expect(
      result.templates
          .expand((item) => item.exercisePrescriptions.values)
          .map((item) => item.workingSets),
      everyElement(2),
    );
    expect(result.minimumEffectiveDose, 4);
  });

  test('maximum-recoverable-volume guard detects unsafe high volume', () {
    final result = ProgramArchitectureEngine.build(
      data: FitnessData.initial(),
      input: const ProgramArchitectureInput(
        goal: 'Muscle hypertrophy',
        daysPerWeek: 6,
        sessionMinutes: 90,
        experienceLevel: 'Beginner',
        volumeMode: ProgramVolumeMode.high,
        preferredSplit: 'push-pull-legs',
      ),
      generatedAt: DateTime(2026, 7, 29),
    );

    expect(
      result.weeklySetBudget.values.any(
        (value) => value > result.maximumRecoverableSets,
      ),
      isTrue,
    );
    expect(result.issues.any((item) => item.code.startsWith('mrv-')), isTrue);
  });

  test('program conflict resolver returns concrete corrective actions', () {
    const issues = [
      ProgramArchitectureIssue(
        code: 'movement-gap',
        title: 'Gap',
        detail: 'Missing hinge',
        severity: 'warning',
      ),
      ProgramArchitectureIssue(
        code: 'time-day',
        title: 'Time',
        detail: 'Too long',
        severity: 'critical',
      ),
    ];
    final actions = ProgramArchitectureEngine.resolveConflicts(issues);

    expect(actions, hasLength(2));
    expect(actions.join(' '), contains('missing movement'));
    expect(actions.join(' '), contains('superset'));
  });

  test(
    'architecture sessions save into the persistent workout library',
    () async {
      final repository = MemoryRepository();
      final store = FitnessStore(repository);
      await store.load();
      final initialCount = store.data.templates.length;
      final result = ProgramArchitectureEngine.build(
        data: store.data,
        input: const ProgramArchitectureInput(
          goal: 'Strength',
          daysPerWeek: 2,
          sessionMinutes: 45,
          experienceLevel: 'Beginner',
        ),
        generatedAt: DateTime(2026, 7, 29),
      );

      for (final template in result.templates) {
        await store.updateWorkoutTemplate(template);
      }

      expect(store.data.templates.length, initialCount + 2);
      expect(
        repository.value.templates.where(
          (item) => item.id.startsWith('custom-architecture-'),
        ),
        hasLength(2),
      );
    },
  );

  testWidgets('Program Architecture exposes design program and audit', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(
      MaterialApp(home: ProgramArchitecturePage(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('PROGRAM ARCHITECTURE'), findsOneWidget);
    expect(find.text('MESOCYCLE PROGRAM WIZARD'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('GOAL-SPECIFIC SPLIT SELECTOR'),
      find.byType(ListView).hitTestable(),
      const Offset(0, -300),
    );
    expect(find.text('GOAL-SPECIFIC SPLIT SELECTOR'), findsOneWidget);

    await tester.tap(find.text('PROGRAM'));
    await tester.pumpAndSettle();
    expect(find.text('SAVE ALL TO LIBRARY'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'SAVE ALL TO LIBRARY'),
          )
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.text('AUDIT'));
    await tester.pumpAndSettle();
    expect(find.text('WEEKLY SET BUDGET'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('MOVEMENT BALANCE AUDIT'),
      find.byType(ListView).hitTestable(),
      const Offset(0, -300),
    );
    expect(find.text('MOVEMENT BALANCE AUDIT'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('CONFLICT RESOLVER'),
      find.byType(ListView).hitTestable(),
      const Offset(0, -300),
    );
    expect(find.text('CONFLICT RESOLVER'), findsOneWidget);
  });

  test('big-lift dashboard uses the strongest real submax result', () {
    final data = FitnessData.initial().copyWith(
      strengthTests: [
        StrengthTestResult(
          id: 'squat-1',
          exerciseName: 'Back squat',
          weightKilograms: 120,
          reps: 5,
          estimatedOneRepMax: 140,
          protocol: 'submax',
          recordedAt: DateTime(2026, 7, 29),
        ),
        StrengthTestResult(
          id: 'squat-2',
          exerciseName: 'Back squat',
          weightKilograms: 125,
          reps: 3,
          estimatedOneRepMax: 137.5,
          protocol: 'submax',
          recordedAt: DateTime(2026, 7, 30),
        ),
      ],
    );
    final squat = StrengthLabEngine.dashboard(
      data,
    ).firstWhere((item) => item.lift == 'Back squat');

    expect(squat.estimatedOneRepMax, 140);
    expect(squat.bestWeight, 120);
    expect(squat.trainingMax, 125);
  });

  test('rep-max conversion table is ordered and load decreases with reps', () {
    final rows = StrengthLabEngine.repMaxTable(150);

    expect(rows, hasLength(12));
    expect(rows.first.reps, 1);
    expect(rows.last.reps, 12);
    expect(rows.first.weight, greaterThan(rows.last.weight));
    expect(rows.first.percentage, greaterThan(rows.last.percentage));
  });

  test(
    'training-max management persists and survives JSON round-trip',
    () async {
      final repository = MemoryRepository();
      final store = FitnessStore(repository);
      await store.load();

      await store.saveStrengthTrainingMax('Deadlift', 180);
      final restored = FitnessData.fromJson(repository.value.toJson());

      expect(store.strengthTrainingMaxes['Deadlift'], 180);
      expect(restored.strengthTrainingMaxes['Deadlift'], 180);
    },
  );

  test('warm-up plate calculator builds an ascending low-fatigue ramp', () {
    final plan = StrengthLabEngine.warmupPlan(workWeight: 150, barWeight: 20);

    expect(plan.first.weight, 20);
    expect(plan.last.weight, lessThanOrEqualTo(150));
    expect([
      for (var index = 1; index < plan.length; index++)
        plan[index].weight > plan[index - 1].weight,
    ], everyElement(isTrue));
    expect(plan.last.reps, 1);
  });

  test('barbell plate loader returns an exact per-side solution', () {
    final result = StrengthLabEngine.loadBar(
      targetWeight: 142.5,
      barWeight: 20,
    );

    expect(result.exact, isTrue);
    expect(result.loadedWeight, 142.5);
    expect(result.platesPerSide, [25, 25, 10, 1.25]);
  });

  test('top-set plus back-off protocol reduces load and adds reps', () {
    final protocol = StrengthLabEngine.topSetPlusBackoff(
      trainingMax: 150,
      topReps: 3,
      topRpe: 8,
    );

    expect(protocol.topWeight, greaterThan(protocol.backoffWeight));
    expect(protocol.backoffReps, greaterThan(protocol.topReps));
    expect(protocol.backoffSets, 3);
  });

  test('heavy-single readiness gate blocks pain and controls amber days', () {
    final pain = StrengthLabEngine.heavySingleGate(
      readinessScore: 90,
      painSeverity: 3,
    );
    final amber = StrengthLabEngine.heavySingleGate(readinessScore: 70);
    final green = StrengthLabEngine.heavySingleGate(readinessScore: 85);

    expect(pain.status, HeavySingleStatus.blocked);
    expect(amber.status, HeavySingleStatus.controlled);
    expect(green.status, HeavySingleStatus.allowed);
  });

  test('velocity-loss rule stops a set at the configured quality limit', () {
    final continueDecision = StrengthLabEngine.velocityLoss(
      fastestVelocity: .6,
      currentVelocity: .52,
      thresholdPercentage: 20,
    );
    final stopDecision = StrengthLabEngine.velocityLoss(
      fastestVelocity: .6,
      currentVelocity: .45,
      thresholdPercentage: 20,
    );

    expect(continueDecision.stopSet, isFalse);
    expect(stopDecision.stopSet, isTrue);
    expect(stopDecision.lossPercentage, closeTo(25, .01));
  });

  test(
    'strength block templates include progression and a taper or deload',
    () {
      final base = StrengthLabEngine.strengthBlock();
      final peak = StrengthLabEngine.strengthBlock(block: 'peak');

      expect(base, hasLength(4));
      expect(base.last.phase, 'DELOAD');
      expect(peak.last.phase, 'TAPER');
      expect(
        peak[2].intensityPercentage,
        greaterThan(peak.first.intensityPercentage),
      );
    },
  );

  test(
    'meet-day attempt planner returns ascending readiness-aware attempts',
    () {
      final green = StrengthLabEngine.meetDayAttempts(
        estimatedOneRepMax: 200,
        readinessScore: 85,
        experienceLevel: 'Advanced',
      );
      final red = StrengthLabEngine.meetDayAttempts(
        estimatedOneRepMax: 200,
        readinessScore: 55,
      );

      expect(green.opener, lessThan(green.second));
      expect(green.second, lessThan(green.third));
      expect(red.third, lessThan(green.third));
      expect(green.opener % 2.5, 0);
    },
  );

  test('integrity repair removes unsupported strength training maxes', () {
    final damaged = FitnessData.initial().copyWith(
      strengthTrainingMaxes: {'Back squat': 140, 'Unsafe lift': 999},
    );
    final report = DataValidationEngine.audit(damaged);
    final repaired = DataValidationEngine.repair(damaged);

    expect(
      report.issues.any((item) => item.code == 'invalid-strength-training-max'),
      isTrue,
    );
    expect(repaired.strengthTrainingMaxes, {'Back squat': 140});
  });

  testWidgets('Strength Lab exposes dashboard loading protocols and meet day', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(MaterialApp(home: StrengthLabPage(store: store)));
    await tester.pumpAndSettle();

    expect(find.text('STRENGTH LAB'), findsOneWidget);
    expect(find.text('BIG-LIFT STRENGTH DASHBOARD'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('REP-MAX CONVERSION TABLE'),
      find.byType(ListView).hitTestable(),
      const Offset(0, -350),
    );
    expect(find.text('REP-MAX CONVERSION TABLE'), findsOneWidget);

    await tester.tap(find.text('LOADING'));
    await tester.pumpAndSettle();
    expect(find.text('BARBELL LOADING ASSISTANT'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('WARM-UP PLATE CALCULATOR'),
      find.byType(ListView).hitTestable(),
      const Offset(0, -250),
    );
    expect(find.text('WARM-UP PLATE CALCULATOR'), findsOneWidget);

    await tester.tap(find.text('PROTOCOLS'));
    await tester.pumpAndSettle();
    expect(find.text('TOP SET + BACK-OFF PROTOCOL'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('VELOCITY-LOSS STOP RULE'),
      find.byType(ListView).hitTestable(),
      const Offset(0, -300),
    );
    expect(find.text('VELOCITY-LOSS STOP RULE'), findsOneWidget);

    await tester.tap(find.text('MEET DAY'));
    await tester.pumpAndSettle();
    expect(find.text('MEET-DAY ATTEMPT PLANNER'), findsOneWidget);
  });

  test('muscle volume landmarks expose MEV MAV MRV in safe order', () {
    final landmarks = HypertrophyEngine.volumeLandmarks(FitnessData.initial());

    expect(landmarks, hasLength(HypertrophyEngine.muscles.length));
    for (final landmark in landmarks) {
      expect(landmark.minimumEffective, lessThan(landmark.maximumAdaptive));
      expect(landmark.maximumAdaptive, lessThan(landmark.maximumRecoverable));
    }
  });

  test('weekly muscle volume counts real primary-muscle work sets', () {
    final now = DateTime(2026, 7, 29);
    final data = FitnessData.initial().copyWith(
      logs: [
        WorkoutLog(
          templateName: 'Lower',
          completedAt: now,
          minutes: 45,
          sets: [
            for (var index = 0; index < 4; index++)
              ExerciseSetLog(
                exerciseName: 'Back squat',
                reps: 8,
                weightKilograms: 80,
                rir: 2,
                holdSeconds: 0,
                loggedAt: now,
              ),
          ],
        ),
      ],
    );

    final sets = HypertrophyEngine.weeklyPrimarySets(data, now: now);

    expect(sets['quadriceps'], 4);
    expect(sets['glutes'], 4);
  });

  test('stimulus-fatigue scoring rewards a lengthened-position bias', () {
    final data = FitnessData.initial();
    final scores = HypertrophyEngine.stimulusFatigue(data);
    final romanian = scores.firstWhere((item) => item.lengthenedBias);

    expect(romanian.lengthenedBias, isTrue);
    expect(romanian.stimulus, greaterThan(romanian.fatigue));
  });

  test('pump and disruption check-in changes the next volume action', () {
    const landmark = MuscleVolumeLandmark(
      muscle: 'chest',
      minimumEffective: 6,
      maximumAdaptive: 14,
      maximumRecoverable: 20,
      currentWeeklySets: 8,
    );
    final lowStimulus = HypertrophyEngine.checkInAdjustment(
      pump: 1,
      disruption: 1,
      soreness: 1,
      currentWeeklySets: 8,
      landmark: landmark,
    );
    final highFatigue = HypertrophyEngine.checkInAdjustment(
      pump: 4,
      disruption: 5,
      soreness: 5,
      currentWeeklySets: 18,
      landmark: landmark,
    );

    expect(lowStimulus.setChange, 1);
    expect(highFatigue.setChange, -2);
  });

  test('per-muscle frequency planner distributes large set budgets', () {
    expect(
      HypertrophyEngine.recommendedFrequency(
        weeklySets: 15,
        muscle: 'quadriceps',
      ),
      3,
    );
    expect(
      HypertrophyEngine.recommendedFrequency(weeklySets: 20, muscle: 'calves'),
      4,
    );
  });

  test(
    'myo-rep drop-set and rest-pause protocols have explicit stop rules',
    () {
      final myo = HypertrophyEngine.technique('myo-reps');
      final drop = HypertrophyEngine.technique('drop set');
      final restPause = HypertrophyEngine.technique('rest-pause');

      expect(myo.technique, 'MYO-REPS');
      expect(drop.loadDropPercentage, 20);
      expect(restPause.rounds, 3);
      expect([
        myo.stopRule,
        drop.stopRule,
        restPause.stopRule,
      ], everyElement(isNotEmpty));
    },
  );

  test(
    'advanced hypertrophy techniques persist as structured clusters',
    () async {
      final repository = MemoryRepository();
      final store = FitnessStore(repository);
      await store.load();

      await store.saveHypertrophyTechniqueLog(
        technique: 'MYO-REPS',
        exercise: 'Cable lateral raise',
        muscle: 'shoulders',
        weightKilograms: 10,
        activationReps: 15,
        miniSetReps: const [4, 4, 4, 3],
      );
      final restored = FitnessData.fromJson(repository.value.toJson());

      expect(restored.hypertrophyTechniqueLogs, hasLength(1));
      expect(restored.hypertrophyTechniqueLogs.single.totalReps, 30);
    },
  );

  test('pump disruption and soreness check-ins persist locally', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();

    await store.saveHypertrophyCheckIn(
      muscle: 'chest',
      pump: 4,
      disruption: 3,
      soreness: 2,
    );
    final restored = FitnessData.fromJson(repository.value.toJson());

    expect(restored.hypertrophyCheckIns.single.muscle, 'chest');
    expect(restored.hypertrophyCheckIns.single.pump, 4);
  });

  test('specialization block progresses volume and deloads in week four', () {
    const landmark = MuscleVolumeLandmark(
      muscle: 'lats',
      minimumEffective: 6,
      maximumAdaptive: 14,
      maximumRecoverable: 22,
      currentWeeklySets: 10,
    );
    final block = HypertrophyEngine.specializationBlock(
      landmark: landmark,
      baselineSets: 10,
    );

    expect(block, hasLength(4));
    expect(block[2].targetSets, greaterThanOrEqualTo(block.first.targetSets));
    expect(block.last.intensityTechnique, 'DELOAD');
    expect(block.last.targetSets, lessThan(block[2].targetSets));
  });

  test('volume progression never adds sets above MRV', () {
    const landmark = MuscleVolumeLandmark(
      muscle: 'quadriceps',
      minimumEffective: 6,
      maximumAdaptive: 14,
      maximumRecoverable: 20,
      currentWeeklySets: 22,
    );

    final adjustment = HypertrophyEngine.volumeProgression(landmark: landmark);

    expect(adjustment.action, 'DELOAD NOW');
    expect(adjustment.setChange, lessThan(0));
  });

  test('hypertrophy integrity audit repairs invalid advanced logs', () {
    final damaged = FitnessData.initial().copyWith(
      hypertrophyCheckIns: [
        HypertrophyCheckIn(
          id: 'bad-check',
          muscle: 'chest',
          pump: 9,
          disruption: 1,
          soreness: 1,
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
      hypertrophyTechniqueLogs: [
        HypertrophyTechniqueLog(
          id: 'bad-log',
          technique: 'DANGEROUS',
          exercise: 'Curl',
          muscle: 'biceps',
          weightKilograms: 900,
          activationReps: 100,
          miniSetReps: const [],
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );
    final report = DataValidationEngine.audit(damaged);
    final repaired = DataValidationEngine.repair(damaged);

    expect(
      report.issues.any((item) => item.code == 'invalid-hypertrophy-check-in'),
      isTrue,
    );
    expect(
      report.issues.any((item) => item.code == 'invalid-hypertrophy-technique'),
      isTrue,
    );
    expect(repaired.hypertrophyCheckIns, isEmpty);
    expect(repaired.hypertrophyTechniqueLogs, isEmpty);
  });

  testWidgets('Hypertrophy Lab exposes all four functional zones', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(
      MaterialApp(home: HypertrophyLabPage(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('HYPERTROPHY LAB'), findsOneWidget);
    expect(find.text('MUSCLE-GROUP VOLUME LANDMARKS'), findsOneWidget);

    await tester.tap(find.text('STIMULUS'));
    await tester.pumpAndSettle();
    expect(find.text('STIMULUS-TO-FATIGUE SCORING'), findsOneWidget);

    await tester.tap(find.text('TECHNIQUES'));
    await tester.pumpAndSettle();
    expect(find.text('ADVANCED SET TECHNIQUE LOGGING'), findsOneWidget);

    await tester.tap(find.text('SPECIALIZE'));
    await tester.pumpAndSettle();
    expect(find.text('HYPERTROPHY SPECIALIZATION BLOCK'), findsOneWidget);
    expect(find.text('PER-MUSCLE FREQUENCY PLANNER'), findsOneWidget);
  });

  test('heart-rate zones use reserve and remain ordered', () {
    final zones = ConditioningEngine.heartRateZones(
      age: 35,
      restingHeartRate: 58,
    );

    expect(zones, hasLength(5));
    expect(zones.first.minimumBpm, lessThan(zones.first.maximumBpm));
    expect(zones.first.maximumBpm, lessThanOrEqualTo(zones[1].minimumBpm + 1));
    expect(zones.last.maximumBpm, greaterThan(zones.first.maximumBpm));
  });

  test('Zone 2 builder preserves warm-up cooldown and talk-test stop rule', () {
    final plan = ConditioningEngine.zone2Session(
      modality: 'Stationary bike',
      minutes: 40,
    );

    expect(plan.targetZone, 2);
    expect(plan.totalMinutes, 40);
    expect(plan.warmupMinutes + plan.cooldownMinutes, lessThan(40));
    expect(plan.stopRule, contains('talk test'));
  });

  test('interval builder applies exact work-to-rest presets', () {
    final plan = ConditioningEngine.intervalSession(
      modality: 'Row ergometer',
      goal: 'threshold',
    );
    final preset = ConditioningEngine.workRestPresets().firstWhere(
      (item) => item.id == 'threshold',
    );

    expect(plan.workSeconds, preset.workSeconds);
    expect(plan.restSeconds, preset.restSeconds);
    expect(plan.rounds, preset.rounds);
    expect(plan.targetZone, 4);
  });

  test('conditioning modality selector respects knee limitations', () {
    const profile = UserProfile(
      goal: 'General fitness',
      trainingPlace: 'Gym',
      equipment: 'Bike, rower',
      daysPerWeek: 3,
      heightCentimeters: 180,
      weightKilograms: 80,
      experienceLevel: 'Beginner',
      limitations: 'Knee pain',
    );
    final modalities = ConditioningEngine.modalitySelector(profile: profile);

    expect(modalities, isNot(contains('Brisk walk')));
    expect(modalities, contains('Stationary bike'));
    expect(modalities, contains('Row ergometer'));
  });

  test('ο κεκλιμένος διάδρομος προτείνεται μόνο όταν είναι διαθέσιμος', () {
    const dumbbellsOnly = UserProfile(
      goal: 'General fitness',
      trainingPlace: 'Home',
      equipment: 'Dumbbells',
      daysPerWeek: 3,
      heightCentimeters: 180,
      weightKilograms: 80,
    );
    const withTreadmill = UserProfile(
      goal: 'General fitness',
      trainingPlace: 'Home',
      equipment: 'Αλτήρες, Απλός διάδρομος',
      daysPerWeek: 3,
      heightCentimeters: 180,
      weightKilograms: 80,
    );

    expect(
      ConditioningEngine.modalitySelector(profile: dumbbellsOnly),
      isNot(contains('Incline treadmill')),
    );
    expect(
      ConditioningEngine.modalitySelector(profile: withTreadmill),
      contains('Incline treadmill'),
    );
  });

  test('RPE-based cardio logging persists session load', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();

    await store.saveCardioSession(
      modality: 'Stationary bike',
      durationMinutes: 35,
      rpe: 5,
      averageHeartRate: 132,
      targetZone: 2,
    );
    final restored = FitnessData.fromJson(repository.value.toJson());

    expect(restored.cardioSessions.single.sessionLoad, 175);
  });

  test('weekly cardio load tracks minutes load and hard sessions', () {
    final now = DateTime(2026, 7, 29);
    final logs = [
      CardioSessionLog(
        id: 'z2',
        modality: 'Bike',
        durationMinutes: 40,
        rpe: 4,
        averageHeartRate: 130,
        targetZone: 2,
        recordedAt: now,
      ),
      CardioSessionLog(
        id: 'hard',
        modality: 'Row',
        durationMinutes: 20,
        rpe: 9,
        averageHeartRate: 170,
        targetZone: 5,
        recordedAt: now,
      ),
    ];
    final summary = ConditioningEngine.weeklyLoad(logs, now: now);

    expect(summary.totalMinutes, 60);
    expect(summary.totalLoad, 340);
    expect(summary.highIntensitySessions, 1);
  });

  test('interference advisor escalates dense hard cardio near leg work', () {
    const cardio = ConditioningLoadSummary(
      totalMinutes: 220,
      totalLoad: 1500,
      sessions: 4,
      highIntensitySessions: 3,
      monotony: 2.5,
    );
    final risk = ConditioningEngine.interferenceRisk(
      strengthDays: 5,
      cardio: cardio,
      hoursBetweenHardCardioAndLegs: 8,
    );

    expect(risk.level, 'HIGH');
    expect(risk.score, greaterThanOrEqualTo(60));
    expect(risk.actions, isNotEmpty);
  });

  test('aerobic base progression advances conservatively and deloads', () {
    final block = ConditioningEngine.aerobicBaseProgression(
      baselineMinutes: 30,
      sessions: 2,
    );

    expect(block, hasLength(4));
    expect(block[2].minutesPerSession, lessThanOrEqualTo(35));
    expect(block.last.deload, isTrue);
    expect(block.last.minutesPerSession, lessThan(block[2].minutesPerSession));
  });

  test('conditioning benchmark calculates a plausible Cooper estimate', () {
    final result = ConditioningEngine.benchmark(
      test: 'cooper-12',
      value: 2400,
      age: 30,
    );

    expect(result.estimatedVo2Max, inInclusiveRange(40, 45));
    expect(result.label, isNotEmpty);
  });

  test('conditioning benchmark history survives JSON round-trip', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();

    await store.saveConditioningBenchmark(
      test: '12-MINUTE COOPER',
      value: 2500,
      unit: 'meters',
      score: 44.6,
      label: 'SOLID',
    );
    final restored = FitnessData.fromJson(repository.value.toJson());

    expect(restored.conditioningBenchmarks.single.value, 2500);
    expect(restored.conditioningBenchmarks.single.label, 'SOLID');
  });

  test('conditioning validation repairs impossible cardio data', () {
    final damaged = FitnessData.initial().copyWith(
      cardioSessions: [
        CardioSessionLog(
          id: 'bad',
          modality: '',
          durationMinutes: 999,
          rpe: 20,
          averageHeartRate: 400,
          targetZone: 9,
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );
    final report = DataValidationEngine.audit(damaged);
    final repaired = DataValidationEngine.repair(damaged);

    expect(
      report.issues.any((item) => item.code == 'invalid-cardio-session'),
      isTrue,
    );
    expect(repaired.cardioSessions, isEmpty);
  });

  testWidgets('Conditioning Lab exposes zones builder load and benchmarks', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(
      MaterialApp(home: ConditioningLabPage(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('CONDITIONING LAB'), findsOneWidget);
    expect(find.text('HEART-RATE ZONE CALCULATOR'), findsOneWidget);

    await tester.tap(find.text('BUILDER'));
    await tester.pumpAndSettle();
    expect(find.text('CONDITIONING SESSION BUILDER'), findsOneWidget);

    await tester.tap(find.text('LOAD'));
    await tester.pumpAndSettle();
    expect(find.text('WEEKLY CARDIO LOAD'), findsOneWidget);
    expect(find.text('AEROBIC BASE PROGRESSION'), findsOneWidget);

    await tester.tap(find.text('BENCHMARKS'));
    await tester.pumpAndSettle();
    expect(find.text('CONDITIONING BENCHMARK TESTS'), findsOneWidget);
  });

  test('running pace calculator converts 5K time exactly', () {
    final pace = RunningEngine.pace(
      distanceKilometers: 5,
      durationSeconds: 25 * 60,
    );

    expect(pace.formattedPace, '5:00 /km');
    expect(pace.kilometersPerHour, 12);
  });

  test('run walk progression advances ratios and includes recovery weeks', () {
    final progression = RunningEngine.runWalkProgression();

    expect(progression, hasLength(8));
    expect(
      progression.last.runSeconds,
      greaterThan(progression.first.runSeconds),
    );
    expect(progression.where((item) => item.deload), hasLength(2));
  });

  test('5K plan builder caps progression and keeps recovery weeks', () {
    final plan = RunningEngine.fiveKPlan(
      currentWeeklyKilometers: 20,
      daysPerWeek: 3,
    );

    expect(plan, hasLength(8));
    expect(plan[3].recoveryFocus, isTrue);
    expect(plan.last.recoveryFocus, isTrue);
    expect(plan[2].weeklyKilometers, lessThanOrEqualTo(23));
  });

  test('long-run guard caps unsafe distance jumps', () {
    final guard = RunningEngine.longRunGuard(
      previousLongestKilometers: 8,
      requestedKilometers: 12,
      plannedWeeklyKilometers: 25,
    );

    expect(guard.status, 'CAPPED');
    expect(guard.allowedKilometers, 8.8);
  });

  test('weekly mileage aggregates surface elevation cadence and hard days', () {
    final now = DateTime(2026, 7, 29);
    final runs = [
      RunningSessionLog(
        id: 'r1',
        distanceKilometers: 5,
        durationSeconds: 1500,
        rpe: 5,
        surface: 'Road',
        elevationGainMeters: 40,
        cadenceStepsPerMinute: 164,
        shoeId: '',
        recordedAt: now,
      ),
      RunningSessionLog(
        id: 'r2',
        distanceKilometers: 8,
        durationSeconds: 2400,
        rpe: 8,
        surface: 'Trail',
        elevationGainMeters: 160,
        cadenceStepsPerMinute: 168,
        shoeId: '',
        recordedAt: now,
      ),
    ];
    final summary = RunningEngine.weeklyMileage(runs, now: now);

    expect(summary.kilometers, 13);
    expect(summary.elevationMeters, 200);
    expect(summary.averageCadence, 166);
    expect(summary.hardSessions, 1);
  });

  test('shoe mileage includes starting and logged kilometers', () {
    final now = DateTime(2026, 7, 29);
    final shoe = RunningShoe(
      id: 'shoe',
      name: 'Daily',
      startingKilometers: 100,
      retirementKilometers: 700,
      addedAt: now,
    );
    final runs = [
      RunningSessionLog(
        id: 'r1',
        distanceKilometers: 7.5,
        durationSeconds: 2500,
        rpe: 5,
        surface: 'Road',
        elevationGainMeters: 0,
        cadenceStepsPerMinute: 165,
        shoeId: 'shoe',
        recordedAt: now,
      ),
    ];

    expect(RunningEngine.shoeMileage(shoe, runs), 107.5);
  });

  test('running load guard escalates pain and mileage spikes', () {
    const previous = WeeklyMileageSummary(
      kilometers: 20,
      durationMinutes: 120,
      sessions: 3,
      longestRunKilometers: 8,
      elevationMeters: 100,
      averageCadence: 165,
      hardSessions: 1,
    );
    const current = WeeklyMileageSummary(
      kilometers: 32,
      durationMinutes: 180,
      sessions: 5,
      longestRunKilometers: 15,
      elevationMeters: 300,
      averageCadence: 164,
      hardSessions: 2,
    );
    final risk = RunningEngine.injuryRisk(
      currentWeek: current,
      previousWeek: previous,
      painSeverity: 3,
      consecutiveRunDays: 5,
    );

    expect(risk.level, 'HIGH');
    expect(risk.actions, isNotEmpty);
  });

  test('race predictor scales 5K performance to 10K conservatively', () {
    final prediction = RunningEngine.predictRace(
      sourceDistanceKilometers: 5,
      sourceSeconds: 25 * 60,
      targetDistanceKilometers: 10,
    );

    expect(prediction.predictedSeconds, greaterThan(50 * 60));
    expect(prediction.predictedSeconds, lessThan(55 * 60));
    expect(prediction.pace.secondsPerKilometer, greaterThan(300));
  });

  test('running sessions and shoes persist together', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();
    final shoe = await store.saveRunningShoe(name: 'Daily Trainer');
    await store.saveRunningSession(
      distanceKilometers: 5,
      durationSeconds: 1500,
      rpe: 5,
      surface: 'Road',
      elevationGainMeters: 20,
      cadenceStepsPerMinute: 166,
      shoeId: shoe.id,
    );
    final restored = FitnessData.fromJson(repository.value.toJson());

    expect(restored.runningShoes, hasLength(1));
    expect(restored.runningSessions.single.shoeId, shoe.id);
  });

  test('running integrity repair removes orphan shoe references', () {
    final damaged = FitnessData.initial().copyWith(
      runningSessions: [
        RunningSessionLog(
          id: 'bad',
          distanceKilometers: 5,
          durationSeconds: 1500,
          rpe: 5,
          surface: 'Road',
          elevationGainMeters: 0,
          cadenceStepsPerMinute: 165,
          shoeId: 'missing',
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );
    final report = DataValidationEngine.audit(damaged);
    final repaired = DataValidationEngine.repair(damaged);

    expect(
      report.issues.any((item) => item.code == 'invalid-running-session'),
      isTrue,
    );
    expect(repaired.runningSessions, isEmpty);
  });

  testWidgets('Running Lab exposes pace plans log and load guard', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(MaterialApp(home: RunningLabPage(store: store)));
    await tester.pumpAndSettle();

    expect(find.text('RUNNING LAB'), findsOneWidget);
    expect(find.text('RUNNING PACE CALCULATOR'), findsOneWidget);

    await tester.tap(find.text('PLANS'));
    await tester.pumpAndSettle();
    expect(find.text('RUN/WALK + 5K PLAN BUILDER'), findsOneWidget);

    await tester.tap(find.text('LOG RUN'));
    await tester.pumpAndSettle();
    expect(find.text('RUN LOG'), findsOneWidget);

    await tester.tap(find.text('LOAD'));
    await tester.pumpAndSettle();
    expect(find.text('WEEKLY MILEAGE & INJURY GUARD'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('SHOE MILEAGE'),
      find.byType(ListView).hitTestable(),
      const Offset(0, -300),
    );
    expect(find.text('SHOE MILEAGE'), findsOneWidget);
  });

  test('cycling power zones map FTP to seven bounded zones', () {
    final zones = CyclingRowingEngine.powerZones(200);

    expect(zones, hasLength(7));
    expect(zones[1].minimumWatts, 112);
    expect(zones[1].maximumWatts, 150);
    expect(zones.last.maximumWatts, isNull);
    expect(zones.last.minimumWatts, 302);
  });

  test('FTP protocols apply distinct deterministic multipliers', () {
    final twenty = CyclingRowingEngine.estimateFtp(
      protocol: '20-minute',
      testPowerWatts: 300,
    );
    final eight = CyclingRowingEngine.estimateFtp(
      protocol: '8-minute',
      testPowerWatts: 300,
    );
    final ramp = CyclingRowingEngine.estimateFtp(
      protocol: 'Ramp',
      testPowerWatts: 300,
    );

    expect(twenty.estimatedFtpWatts, 285);
    expect(eight.estimatedFtpWatts, 270);
    expect(ramp.estimatedFtpWatts, 225);
  });

  test('cycling cadence tracker adapts target to session goal', () {
    final climb = CyclingRowingEngine.cyclingCadence(rpm: 78, goal: 'Climb');
    final speed = CyclingRowingEngine.cyclingCadence(rpm: 90, goal: 'Speed');

    expect(climb.status, 'ON TARGET');
    expect(speed.status, 'LOW');
    expect(speed.targetMinimum, 95);
  });

  test('indoor cycling library includes recovery in structured totals', () {
    final sweetSpot = CyclingRowingEngine.indoorWorkouts.firstWhere(
      (item) => item.id == 'sweet-spot',
    );

    expect(CyclingRowingEngine.indoorWorkouts, hasLength(4));
    expect(sweetSpot.totalMinutes, 48);
    expect(
      sweetSpot.segments.any((segment) => segment.label == 'Easy recovery'),
      isTrue,
    );
  });

  test('rowing split converts a 2K in eight minutes to 2:00 and watts', () {
    final split = CyclingRowingEngine.rowingSplit(
      distanceMeters: 2000,
      durationSeconds: 480,
    );

    expect(split.formattedSplit, '2:00 /500m');
    expect(split.watts, closeTo(202.5, .1));
    expect(split.metersPerSecond, closeTo(4.167, .01));
  });

  test('stroke-rate tracker reports power efficiency and pacing cue', () {
    final result = CyclingRowingEngine.rowingStrokeRate(
      strokesPerMinute: 28,
      watts: 210,
      goal: 'Race',
    );

    expect(result.status, 'ON TARGET');
    expect(result.efficiencyWattsPerStroke, 7.5);
    expect(result.cue, contains('legs'));
  });

  test('erg library and distance-time converter cover standard formats', () {
    final ids = CyclingRowingEngine.ergBenchmarks.map((item) => item.id);
    final cycling = CyclingRowingEngine.convertDistanceTime(
      modality: 'Cycling',
      distance: 20,
      durationSeconds: 3600,
    );
    final rowing = CyclingRowingEngine.convertDistanceTime(
      modality: 'Rowing',
      distance: 2000,
      durationSeconds: 480,
    );

    expect(ids, containsAll(['500m', '2k', '5k', '30min']));
    expect(cycling.speed, 20);
    expect(rowing.paceLabel, '2:00 /500m');
  });

  test('endurance modality comparison exposes impact and interference', () {
    final profiles = CyclingRowingEngine.modalityProfiles;
    final rowing = profiles.firstWhere((item) => item.modality == 'ROWING');

    expect(profiles, hasLength(3));
    expect(rowing.impact, 'Low');
    expect(rowing.strengthInterference, contains('whole-body'));
  });

  test('multi-sport load combines four modalities with session RPE', () {
    final now = DateTime(2026, 7, 29);
    final summary = CyclingRowingEngine.weeklyLoad(
      now: now,
      cardio: [
        CardioSessionLog(
          id: 'cardio',
          modality: 'Elliptical',
          durationMinutes: 30,
          rpe: 5,
          averageHeartRate: 130,
          targetZone: 2,
          recordedAt: now,
        ),
      ],
      running: [
        RunningSessionLog(
          id: 'run',
          distanceKilometers: 5,
          durationSeconds: 1500,
          rpe: 6,
          surface: 'Road',
          elevationGainMeters: 20,
          cadenceStepsPerMinute: 166,
          shoeId: '',
          recordedAt: now,
        ),
      ],
      cycling: [
        CyclingSessionLog(
          id: 'ride',
          durationMinutes: 40,
          averagePowerWatts: 180,
          normalizedPowerWatts: 190,
          cadenceRpm: 90,
          rpe: 7,
          workoutType: 'Tempo',
          recordedAt: now,
        ),
      ],
      rowing: [
        RowingSessionLog(
          id: 'row',
          distanceMeters: 2000,
          durationSeconds: 480,
          strokeRate: 28,
          rpe: 8,
          benchmarkType: '2k',
          recordedAt: now,
        ),
      ],
    );

    expect(summary.totalLoad, 644);
    expect(summary.durationMinutes, 103);
    expect(summary.sessions, 4);
    expect(summary.hardSessions, 1);
    expect(summary.byModality['CYCLING'], 280);
  });

  test('cycling and rowing logs persist through store JSON', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();
    await store.saveCyclingSession(
      durationMinutes: 45,
      averagePowerWatts: 180,
      normalizedPowerWatts: 190,
      cadenceRpm: 90,
      rpe: 6,
      workoutType: 'Endurance',
    );
    await store.saveRowingSession(
      distanceMeters: 2000,
      durationSeconds: 480,
      strokeRate: 28,
      rpe: 8,
      benchmarkType: '2k',
    );
    final restored = FitnessData.fromJson(repository.value.toJson());

    expect(restored.cyclingSessions.single.averagePowerWatts, 180);
    expect(restored.rowingSessions.single.distanceMeters, 2000);
  });

  test('endurance integrity audit repairs invalid ride and rowing logs', () {
    final damaged = FitnessData.initial().copyWith(
      cyclingSessions: [
        CyclingSessionLog(
          id: 'bad-ride',
          durationMinutes: 1,
          averagePowerWatts: 0,
          normalizedPowerWatts: 0,
          cadenceRpm: 250,
          rpe: 20,
          workoutType: 'Unsafe',
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
      rowingSessions: [
        RowingSessionLog(
          id: 'bad-row',
          distanceMeters: 50,
          durationSeconds: 10,
          strokeRate: 80,
          rpe: 0,
          benchmarkType: 'Unsafe',
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );
    final report = DataValidationEngine.audit(damaged);
    final repaired = DataValidationEngine.repair(damaged);

    expect(
      report.issues.any((item) => item.code == 'invalid-cycling-session'),
      isTrue,
    );
    expect(
      report.issues.any((item) => item.code == 'invalid-rowing-session'),
      isTrue,
    );
    expect(repaired.cyclingSessions, isEmpty);
    expect(repaired.rowingSessions, isEmpty);
  });

  test('global search discovers Cycling and Rowing Lab', () {
    final results = GlobalSearchEngine.search(FitnessData.initial(), 'ftp erg');

    expect(results.single.route, 'endurance');
  });

  testWidgets('Cycling and Rowing Lab exposes all four work areas', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(
      MaterialApp(home: CyclingRowingLabPage(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('CYCLING & ROWING LAB'), findsOneWidget);
    expect(find.text('CYCLING POWER & FTP'), findsOneWidget);

    await tester.tap(find.text('ROWING'));
    await tester.pumpAndSettle();
    expect(find.text('ROWING SPLIT & STROKE LAB'), findsOneWidget);

    await tester.tap(find.text('WORKOUTS'));
    await tester.pumpAndSettle();
    expect(find.text('INDOOR CYCLING WORKOUTS'), findsOneWidget);

    await tester.tap(find.text('MULTI-SPORT LOAD'));
    await tester.pumpAndSettle();
    expect(find.text('MULTI-SPORT WEEKLY LOAD'), findsOneWidget);
    expect(find.text('LOAD BY MODALITY'), findsOneWidget);
  });

  test('advanced calisthenics exposes six complete progression trees', () {
    final trees = AdvancedCalisthenicsEngine.trees;

    expect(trees, hasLength(6));
    expect(
      trees.map((tree) => tree.id),
      containsAll([
        'muscle-up',
        'front-lever',
        'back-lever',
        'planche',
        'handstand-push-up',
        'ring-support',
      ]),
    );
    expect(trees.every((tree) => tree.stages.length == 5), isTrue);
    expect(
      trees
          .expand((tree) => tree.stages)
          .every((stage) => stage.riskNote.isNotEmpty),
      isTrue,
    );
  });

  test('advanced stage requires quality and pain-free execution', () {
    final now = DateTime(2026, 7, 29);
    final logs = [
      CalisthenicsSkillLog(
        id: 'clean',
        skillId: 'front-lever',
        progression: 'Stage 2 • Tuck front lever',
        holdSeconds: 12,
        repetitions: 0,
        quality: 4,
        rpe: 7,
        elbowPain: 0,
        straightArm: true,
        recordedAt: now,
      ),
      CalisthenicsSkillLog(
        id: 'painful',
        skillId: 'front-lever',
        progression: 'Stage 4 • One-leg front lever',
        holdSeconds: 20,
        repetitions: 0,
        quality: 5,
        rpe: 9,
        elbowPain: 3,
        straightArm: true,
        recordedAt: now,
      ),
    ];

    expect(AdvancedCalisthenicsEngine.currentStage('front-lever', logs), 2);
  });

  test('false-grip readiness requires all four safety gates', () {
    final ready = AdvancedCalisthenicsEngine.falseGripReadiness(
      hangSeconds: 20,
      ringSupportSeconds: 15,
      wristPain: 1,
      secureContact: true,
    );
    final blocked = AdvancedCalisthenicsEngine.falseGripReadiness(
      hangSeconds: 30,
      ringSupportSeconds: 30,
      wristPain: 3,
      secureContact: true,
    );

    expect(ready.ready, isTrue);
    expect(ready.score, 100);
    expect(blocked.ready, isFalse);
    expect(blocked.nextAction, contains('pain-free'));
  });

  test('muscle-up readiness combines pull push grip and limitation gates', () {
    final now = DateTime(2026, 7, 29);
    final data = FitnessData.initial().copyWith(
      skillAssessments: [
        SkillAssessmentResult(
          id: 'pull',
          skillId: 'pull-up',
          value: 10,
          unit: 'reps',
          level: 4,
          recordedAt: now,
        ),
        SkillAssessmentResult(
          id: 'push',
          skillId: 'push-up',
          value: 20,
          unit: 'reps',
          level: 3,
          recordedAt: now,
        ),
        SkillAssessmentResult(
          id: 'grip',
          skillId: 'false-grip',
          value: 25,
          unit: 'seconds',
          level: 3,
          recordedAt: now,
        ),
      ],
    );
    final gate = AdvancedCalisthenicsEngine.readiness('muscle-up', data);

    expect(gate.status, 'READY');
    expect(gate.passedChecks, gate.totalChecks);
  });

  test('straight-arm tracker reports trend quality exposures and pain', () {
    final now = DateTime(2026, 7, 29);
    final logs = [
      CalisthenicsSkillLog(
        id: 'old',
        skillId: 'planche',
        progression: 'Stage 1',
        holdSeconds: 10,
        repetitions: 0,
        quality: 4,
        rpe: 7,
        elbowPain: 0,
        straightArm: true,
        recordedAt: now.subtract(const Duration(days: 8)),
      ),
      CalisthenicsSkillLog(
        id: 'new',
        skillId: 'planche',
        progression: 'Stage 1',
        holdSeconds: 15,
        repetitions: 0,
        quality: 5,
        rpe: 7,
        elbowPain: 0,
        straightArm: true,
        recordedAt: now,
      ),
    ];
    final trend = AdvancedCalisthenicsEngine.straightArmTrend('planche', logs);

    expect(trend.bestHoldSeconds, 15);
    expect(trend.exposures, 2);
    expect(trend.changeSeconds, 5);
    expect(trend.status, 'PROGRESSING');
  });

  test('skill exposure scheduler limits focus and preserves spacing', () {
    final schedule = AdvancedCalisthenicsEngine.exposureSchedule(
      selectedSkills: {'muscle-up', 'front-lever', 'planche'},
      daysPerWeek: 3,
      data: FitnessData.initial(),
    );

    expect(schedule, hasLength(3));
    expect(schedule.every((day) => day.focusSkills.length <= 2), isTrue);
    expect(schedule.every((day) => day.minimumHoursBeforeNext == 48), isTrue);
    expect(schedule.map((day) => day.weekday).toSet().length, 3);
  });

  test('calisthenics deload triggers on pain and repeated maximal work', () {
    final now = DateTime(2026, 7, 29);
    final logs = [
      for (var index = 0; index < 4; index++)
        CalisthenicsSkillLog(
          id: 'log-$index',
          skillId: 'front-lever',
          progression: 'Stage 2',
          holdSeconds: 10,
          repetitions: 0,
          quality: index == 0 ? 4 : 2,
          rpe: 9,
          elbowPain: index < 2 ? 3 : 0,
          straightArm: true,
          recordedAt: now.subtract(Duration(days: index)),
        ),
    ];
    final decision = AdvancedCalisthenicsEngine.deloadDecision(logs, now: now);

    expect(decision.required, isTrue);
    expect(decision.level, 'FULL DELOAD');
    expect(decision.volumeMultiplier, .4);
    expect(decision.rules, isNotEmpty);
  });

  test('calisthenics deload keeps normal quality work at full volume', () {
    final now = DateTime(2026, 7, 29);
    final decision = AdvancedCalisthenicsEngine.deloadDecision([
      CalisthenicsSkillLog(
        id: 'clean',
        skillId: 'ring-support',
        progression: 'Stage 2',
        holdSeconds: 20,
        repetitions: 0,
        quality: 5,
        rpe: 6,
        elbowPain: 0,
        straightArm: true,
        recordedAt: now,
      ),
    ], now: now);

    expect(decision.required, isFalse);
    expect(decision.level, 'NORMAL');
    expect(decision.volumeMultiplier, 1);
  });

  test('advanced calisthenics logs persist through store JSON', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();
    await store.saveCalisthenicsSkillLog(
      skillId: 'front-lever',
      progression: 'Stage 2 • Tuck front lever',
      holdSeconds: 12,
      repetitions: 0,
      quality: 4,
      rpe: 7,
      elbowPain: 0,
      straightArm: true,
    );
    final restored = FitnessData.fromJson(repository.value.toJson());

    expect(restored.calisthenicsSkillLogs, hasLength(1));
    expect(restored.calisthenicsSkillLogs.single.skillId, 'front-lever');
    expect(restored.calisthenicsSkillLogs.single.straightArm, isTrue);
  });

  test('advanced calisthenics store rejects empty exposure data', () async {
    final store = FitnessStore(MemoryRepository());
    await store.load();

    expect(
      () => store.saveCalisthenicsSkillLog(
        skillId: 'planche',
        progression: 'Stage 1',
        holdSeconds: 0,
        repetitions: 0,
        quality: 4,
        rpe: 7,
        elbowPain: 0,
        straightArm: true,
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('advanced calisthenics integrity repair removes invalid logs', () {
    final damaged = FitnessData.initial().copyWith(
      calisthenicsSkillLogs: [
        CalisthenicsSkillLog(
          id: 'bad',
          skillId: 'dangerous',
          progression: '',
          holdSeconds: 500,
          repetitions: 0,
          quality: 9,
          rpe: 20,
          elbowPain: 8,
          straightArm: true,
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );
    final report = DataValidationEngine.audit(damaged);
    final repaired = DataValidationEngine.repair(damaged);

    expect(
      report.issues.any(
        (item) => item.code == 'invalid-calisthenics-skill-log',
      ),
      isTrue,
    );
    expect(repaired.calisthenicsSkillLogs, isEmpty);
  });

  test('global search discovers Advanced Calisthenics', () {
    final results = GlobalSearchEngine.search(
      FitnessData.initial(),
      'planche false grip',
    );

    expect(results.single.route, 'advanced-cali');
  });

  testWidgets('Advanced Calisthenics exposes four functional zones', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(
      MaterialApp(home: AdvancedCalisthenicsPage(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('ADVANCED CALISTHENICS'), findsOneWidget);
    expect(find.text('SIX ADVANCED SKILL TREES'), findsOneWidget);

    await tester.tap(find.text('READINESS'));
    await tester.pumpAndSettle();
    expect(find.text('FALSE-GRIP READINESS TEST'), findsOneWidget);

    await tester.tap(find.text('TRACK'));
    await tester.pumpAndSettle();
    expect(find.text('STRAIGHT-ARM STRENGTH TRACKING'), findsOneWidget);

    await tester.tap(find.text('SCHEDULE'));
    await tester.pumpAndSettle();
    expect(find.text('SKILL EXPOSURE SCHEDULER'), findsOneWidget);
    await tester.dragUntilVisible(
      find.textContaining('CALISTHENICS DELOAD'),
      find.byType(ListView).hitTestable(),
      const Offset(0, -300),
    );
    expect(find.textContaining('CALISTHENICS DELOAD'), findsOneWidget);
  });

  test('mobility screen defines four joint-specific repeatable tests', () {
    final joints = MobilityIntelligenceEngine.joints;

    expect(joints, hasLength(4));
    expect(
      joints.map((joint) => joint.id),
      containsAll([
        'ankle-dorsiflexion',
        'hip-internal-rotation',
        'shoulder-flexion',
        'thoracic-rotation',
      ]),
    );
    expect(joints.every((joint) => joint.stopRule.isNotEmpty), isTrue);
  });

  test('ankle screen detects limited range and side asymmetry', () {
    final result = MobilityIntelligenceEngine.evaluate(
      jointId: 'ankle-dorsiflexion',
      leftValue: 6,
      rightValue: 10,
    );

    expect(result.status, 'LIMITED');
    expect(result.lowerValue, 6);
    expect(result.asymmetry, 4);
    expect(result.score, lessThan(70));
  });

  test('mobility screen elevates joint pain above available range', () {
    final result = MobilityIntelligenceEngine.evaluate(
      jointId: 'shoulder-flexion',
      leftValue: 175,
      rightValue: 175,
      painLevel: 3,
    );

    expect(result.status, 'PAIN FLAG');
    expect(result.action, contains('qualified'));
    expect(result.score, lessThan(100));
  });

  test('latest mobility screen is selected independently per joint', () {
    final now = DateTime(2026, 7, 29);
    final latest = MobilityIntelligenceEngine.latestByJoint([
      MobilityScreenLog(
        id: 'old',
        jointId: 'ankle-dorsiflexion',
        leftValue: 6,
        rightValue: 7,
        painLevel: 0,
        recordedAt: now.subtract(const Duration(days: 10)),
      ),
      MobilityScreenLog(
        id: 'new',
        jointId: 'ankle-dorsiflexion',
        leftValue: 9,
        rightValue: 10,
        painLevel: 0,
        recordedAt: now,
      ),
    ]);

    expect(latest['ankle-dorsiflexion']?.id, 'new');
  });

  test('mobility asymmetry report identifies lower side and severity', () {
    final report = MobilityIntelligenceEngine.asymmetryReport([
      MobilityScreenLog(
        id: 'hip',
        jointId: 'hip-internal-rotation',
        leftValue: 18,
        rightValue: 40,
        painLevel: 0,
        recordedAt: DateTime(2026, 7, 29),
      ),
    ]);

    expect(report.single.weakerSide, 'LEFT');
    expect(report.single.severity, 'HIGH');
    expect(report.single.difference, 22);
  });

  test('five-minute snacks cover every tracked joint with stop rules', () {
    final snacks = MobilityIntelligenceEngine.snacks;

    expect(snacks, hasLength(4));
    expect(snacks.every((snack) => snack.minutes == 5), isTrue);
    expect(snacks.every((snack) => snack.drills.length == 3), isTrue);
    expect(snacks.every((snack) => snack.stopRule.isNotEmpty), isTrue);
  });

  test('pre-lift matcher uses squat-specific measured deficits', () {
    final plan = MobilityIntelligenceEngine.preLiftPlan(
      lift: 'Back squat',
      logs: [
        MobilityScreenLog(
          id: 'ankle',
          jointId: 'ankle-dorsiflexion',
          leftValue: 5,
          rightValue: 6,
          painLevel: 0,
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );

    expect(plan.focusJoints, contains('ankle-dorsiflexion'));
    expect(plan.focusJoints, contains('hip-internal-rotation'));
    expect(plan.minutes, inInclusiveRange(5, 10));
    expect(plan.drills.last, contains('warm-up sets'));
  });

  test('posture break planner spaces a workday without endpoint alarm', () {
    final breaks = MobilityIntelligenceEngine.postureBreaks(
      startMinutes: 9 * 60,
      endMinutes: 17 * 60,
      intervalMinutes: 60,
    );

    expect(breaks, hasLength(7));
    expect(breaks.first.label, '10:00');
    expect(breaks.last.label, '16:00');
    expect(breaks.every((item) => item.actions.length == 3), isTrue);
  });

  test('mobility retest is due immediately without a baseline', () {
    final now = DateTime(2026, 7, 29);
    final schedule = MobilityIntelligenceEngine.retestSchedule(
      const [],
      now: now,
    );

    expect(schedule, hasLength(4));
    expect(schedule.every((item) => item.status == 'DUE'), isTrue);
    expect(schedule.every((item) => item.lastTestedAt == null), isTrue);
  });

  test('limited mobility receives a fourteen-day retest cadence', () {
    final now = DateTime(2026, 7, 29);
    final schedule = MobilityIntelligenceEngine.retestSchedule([
      MobilityScreenLog(
        id: 'ankle',
        jointId: 'ankle-dorsiflexion',
        leftValue: 5,
        rightValue: 6,
        painLevel: 0,
        recordedAt: now,
      ),
    ], now: now);
    final ankle = schedule.firstWhere(
      (item) => item.jointId == 'ankle-dorsiflexion',
    );

    expect(ankle.nextTestAt, now.add(const Duration(days: 14)));
    expect(ankle.reason, contains('14-day'));
  });

  test('mobility screens persist through store JSON', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();
    await store.saveMobilityScreen(
      jointId: 'thoracic-rotation',
      leftValue: 42,
      rightValue: 48,
      painLevel: 0,
    );
    final restored = FitnessData.fromJson(repository.value.toJson());

    expect(restored.mobilityScreenLogs, hasLength(1));
    expect(restored.mobilityScreenLogs.single.leftValue, 42);
  });

  test('mobility integrity audit removes impossible measurements', () {
    final damaged = FitnessData.initial().copyWith(
      mobilityScreenLogs: [
        MobilityScreenLog(
          id: 'bad',
          jointId: 'ankle-dorsiflexion',
          leftValue: 80,
          rightValue: -2,
          painLevel: 8,
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );
    final report = DataValidationEngine.audit(damaged);
    final repaired = DataValidationEngine.repair(damaged);

    expect(
      report.issues.any((item) => item.code == 'invalid-mobility-screen-log'),
      isTrue,
    );
    expect(repaired.mobilityScreenLogs, isEmpty);
  });

  test('global search discovers Mobility Intelligence', () {
    final results = GlobalSearchEngine.search(
      FitnessData.initial(),
      'ankle dorsiflexion retest',
    );

    expect(results.single.route, 'mobility-intelligence');
  });

  testWidgets('Mobility Intelligence exposes screen report snacks and plan', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(
      MaterialApp(home: MobilityIntelligencePage(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('MOBILITY INTELLIGENCE'), findsOneWidget);
    expect(find.text('JOINT-BY-JOINT MOBILITY SCREEN'), findsOneWidget);

    await tester.tap(find.text('ASYMMETRY'));
    await tester.pumpAndSettle();
    expect(find.text('MOBILITY ASYMMETRY REPORT'), findsOneWidget);

    await tester.tap(find.text('5-MIN SNACKS'));
    await tester.pumpAndSettle();
    expect(find.text('FIVE-MINUTE MOBILITY SNACKS'), findsOneWidget);

    await tester.tap(find.text('MATCH & RETEST'));
    await tester.pumpAndSettle();
    expect(find.text('PRE-LIFT MOBILITY MATCHING'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('MOBILITY RETEST SCHEDULE'),
      find.byType(ListView).hitTestable(),
      const Offset(0, -300),
    );
    expect(find.text('MOBILITY RETEST SCHEDULE'), findsOneWidget);
  });

  test('recovery trend dashboard compares current and previous windows', () {
    final checks = [
      for (var index = 0; index < 14; index++)
        RecoveryCheckIn(
          sleepHours: index < 7 ? 6 : 8,
          energy: index < 7 ? 2 : 5,
          soreness: index < 7 ? 4 : 1,
          stress: index < 7 ? 4 : 1,
          restingHeartRate: index < 7 ? 66 : 58,
          recordedAt: DateTime(2026, 7, index + 1),
        ),
    ];
    final trend = RecoveryIntelligenceEngine.trendDashboard(checks);

    expect(trend.sampleDays, 7);
    expect(trend.currentReadiness, greaterThan(trend.previousReadiness));
    expect(trend.direction, 'IMPROVING');
    expect(trend.dailyScores, hasLength(7));
  });

  test('sleep-debt estimate totals seven guarded nightly deficits', () {
    final checks = [
      for (var day = 1; day <= 7; day++)
        RecoveryCheckIn(
          sleepHours: 6,
          energy: 3,
          soreness: 2,
          stress: 2,
          recordedAt: DateTime(2026, 7, day),
        ),
    ];
    final debt = RecoveryIntelligenceEngine.sleepDebt(
      checks,
      now: DateTime(2026, 7, 7),
    );

    expect(debt.totalHours, 14);
    expect(debt.averageDailyDebt, 2);
    expect(debt.level, 'SEVERE');
  });

  test('soreness decay forecasts time to a low score', () {
    final result = RecoveryIntelligenceEngine.sorenessDecay([
      RecoveryCheckIn(
        sleepHours: 7,
        energy: 3,
        soreness: 5,
        stress: 2,
        recordedAt: DateTime(2026, 7, 1),
      ),
      RecoveryCheckIn(
        sleepHours: 7,
        energy: 3,
        soreness: 4,
        stress: 2,
        recordedAt: DateTime(2026, 7, 2),
      ),
      RecoveryCheckIn(
        sleepHours: 7,
        energy: 4,
        soreness: 3,
        stress: 2,
        sorenessAreas: const {'Quads': 3, 'Chest': 1},
        recordedAt: DateTime(2026, 7, 3),
      ),
    ]);

    expect(result.status, 'DECAYING');
    expect(result.dailyDecay, 1);
    expect(result.daysToLow, 2);
    expect(result.focusArea, 'Quads');
  });

  test('stress-load trend detects a rising seven-day window', () {
    final checks = [
      for (var index = 0; index < 14; index++)
        RecoveryCheckIn(
          sleepHours: 7,
          energy: 3,
          soreness: 2,
          stress: index < 7 ? 2 : 5,
          recordedAt: DateTime(2026, 7, index + 1),
        ),
    ];
    final trend = RecoveryIntelligenceEngine.stressTrend(checks);

    expect(trend.currentAverage, 5);
    expect(trend.previousAverage, 2);
    expect(trend.highStressDays, 7);
    expect(trend.direction, 'RISING');
  });

  test('resting-heart-rate deviation alerts above personal baseline', () {
    final checks = [
      for (var day = 1; day <= 5; day++)
        RecoveryCheckIn(
          sleepHours: 8,
          energy: 4,
          soreness: 2,
          stress: 2,
          restingHeartRate: 60,
          recordedAt: DateTime(2026, 7, day),
        ),
      RecoveryCheckIn(
        sleepHours: 6,
        energy: 2,
        soreness: 4,
        stress: 4,
        restingHeartRate: 70,
        recordedAt: DateTime(2026, 7, 6),
      ),
    ];
    final deviation = RecoveryIntelligenceEngine.restingHeartRateDeviation(
      checks,
    );

    expect(deviation.baseline, 60);
    expect(deviation.deviation, 10);
    expect(deviation.hasAlert, isTrue);
    expect(deviation.status, 'ELEVATED');
  });

  test('recovery-day recommendation prioritizes full rest on red flags', () {
    final checks = [
      for (var day = 1; day <= 4; day++)
        RecoveryCheckIn(
          sleepHours: 8,
          energy: 4,
          soreness: 2,
          stress: 2,
          restingHeartRate: 60,
          recordedAt: DateTime(2026, 7, day),
        ),
      RecoveryCheckIn(
        sleepHours: 4,
        energy: 1,
        soreness: 5,
        stress: 5,
        restingHeartRate: 72,
        recordedAt: DateTime(2026, 7, 5),
      ),
    ];
    final recommendation = RecoveryIntelligenceEngine.recoveryDayRecommendation(
      checkIns: checks,
      now: DateTime(2026, 7, 5),
    );

    expect(recommendation.level, 'FULL REST');
    expect(recommendation.trainingLoadPercent, 0);
  });

  test('active recovery generator creates a bounded low-intensity session', () {
    const recommendation = RecoveryDayRecommendation(
      level: 'FULL REST',
      title: 'RECOVERY',
      reason: 'test',
      trainingLoadPercent: 0,
      accent: 'red',
    );
    final session = RecoveryIntelligenceEngine.activeRecoverySession(
      recommendation: recommendation,
      latest: RecoveryCheckIn(
        sleepHours: 5,
        energy: 2,
        soreness: 5,
        stress: 5,
        recordedAt: DateTime(2026, 7, 5),
      ),
    );

    expect(session.totalMinutes, inInclusiveRange(20, 35));
    expect(session.segments, hasLength(4));
    expect(
      session.segments.every((item) => item.intensity.contains('RPE')),
      isTrue,
    );
    expect(session.stopRule, contains('dizziness'));
  });

  test('recovery intervention model survives JSON roundtrip', () {
    final original = RecoveryInterventionLog(
      id: 'sauna-1',
      intervention: 'Sauna',
      durationMinutes: 15,
      temperatureCelsius: 82,
      beforeScore: 5,
      afterScore: 8,
      recordedAt: DateTime(2026, 7, 29),
      notes: 'Hydrated',
    );
    final restored = RecoveryInterventionLog.fromJson(original.toJson());

    expect(restored.intervention, 'Sauna');
    expect(restored.temperatureCelsius, 82);
    expect(restored.response, 3);
  });

  test('recovery interventions persist through the local store', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();
    await store.saveRecoveryIntervention(
      intervention: 'Cold exposure',
      durationMinutes: 3,
      temperatureCelsius: 12,
      beforeScore: 4,
      afterScore: 6,
    );
    final restored = FitnessData.fromJson(repository.value.toJson());

    expect(restored.recoveryInterventions, hasLength(1));
    expect(restored.recoveryInterventions.single.response, 2);
  });

  test('recovery intervention comparison ranks personal response', () {
    final logs = [
      for (var index = 0; index < 3; index++)
        RecoveryInterventionLog(
          id: 'walk-$index',
          intervention: 'Recovery walk',
          durationMinutes: 20,
          temperatureCelsius: 0,
          beforeScore: 4,
          afterScore: 7,
          recordedAt: DateTime(2026, 7, index + 1),
        ),
      RecoveryInterventionLog(
        id: 'nap',
        intervention: 'Nap',
        durationMinutes: 25,
        temperatureCelsius: 0,
        beforeScore: 6,
        afterScore: 5,
        recordedAt: DateTime(2026, 7, 4),
      ),
    ];
    final comparison = RecoveryIntelligenceEngine.compareInterventions(logs);

    expect(comparison.first.intervention, 'Recovery walk');
    expect(comparison.first.averageResponse, 3);
    expect(comparison.first.label, 'HELPFUL');
  });

  test('return-to-baseline forecast caps its horizon at fourteen days', () {
    final checks = [
      for (var day = 1; day <= 5; day++)
        RecoveryCheckIn(
          sleepHours: 8,
          energy: 5,
          soreness: 1,
          stress: 1,
          recordedAt: DateTime(2026, 7, day),
        ),
      RecoveryCheckIn(
        sleepHours: 5,
        energy: 2,
        soreness: 5,
        stress: 5,
        recordedAt: DateTime(2026, 7, 6),
      ),
      RecoveryCheckIn(
        sleepHours: 6,
        energy: 3,
        soreness: 4,
        stress: 4,
        recordedAt: DateTime(2026, 7, 7),
      ),
      RecoveryCheckIn(
        sleepHours: 7,
        energy: 3,
        soreness: 3,
        stress: 3,
        recordedAt: DateTime(2026, 7, 8),
      ),
    ];
    final forecast = RecoveryIntelligenceEngine.returnToBaseline(
      checks,
      now: DateTime(2026, 7, 8),
    );

    expect(forecast.targetScore, greaterThan(forecast.latestScore));
    expect(forecast.estimatedDays, inInclusiveRange(1, 14));
    expect(forecast.estimatedDate, isNotNull);
  });

  test('recovery integrity audit removes unsafe intervention values', () {
    final damaged = FitnessData.initial().copyWith(
      recoveryInterventions: [
        RecoveryInterventionLog(
          id: 'unsafe',
          intervention: 'Sauna',
          durationMinutes: 400,
          temperatureCelsius: 10,
          beforeScore: 0,
          afterScore: 12,
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );
    final report = DataValidationEngine.audit(damaged);
    final repaired = DataValidationEngine.repair(damaged);

    expect(
      report.issues.any((item) => item.code == 'invalid-recovery-intervention'),
      isTrue,
    );
    expect(repaired.recoveryInterventions, isEmpty);
  });

  test('global search discovers Recovery Intelligence', () {
    final results = GlobalSearchEngine.search(
      FitnessData.initial(),
      'sleep debt rhr forecast',
    );

    expect(results.single.route, 'recovery-intelligence');
  });

  testWidgets('Recovery Intelligence exposes all four functional tabs', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(
      MaterialApp(home: RecoveryIntelligencePage(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('RECOVERY INTELLIGENCE'), findsOneWidget);
    expect(find.text('RECOVERY TREND DASHBOARD'), findsOneWidget);

    await tester.tap(find.text('RECOVERY DAY'));
    await tester.pumpAndSettle();
    expect(find.text('RECOVERY-DAY DECISION'), findsOneWidget);

    await tester.tap(find.text('INTERVENTIONS'));
    await tester.pumpAndSettle();
    expect(find.text('RECOVERY INTERVENTION LOG'), findsOneWidget);

    await tester.tap(find.text('FORECAST'));
    await tester.pumpAndSettle();
    expect(find.text('RETURN-TO-BASELINE FORECAST'), findsOneWidget);
  });

  test('recommended nutrition builds a complete vegan week', () {
    const targets = NutritionTargets(
      calories: 2200,
      proteinGrams: 140,
      carbohydrateGrams: 260,
      fatGrams: 65,
      fiberGrams: 30,
      sodiumLimitMilligrams: 2300,
      goalLabel: 'Maintenance',
      isTrainingDay: true,
    );
    final week = RecommendedNutritionEngine.buildWeek(
      startDate: DateTime(2026, 8, 17),
      targetsForDate: (_) => targets,
      dietStyle: 'vegan',
      mealsPerDay: 4,
      budgetMode: 'economy',
      quickPrep: true,
    );

    expect(week.days, hasLength(7));
    expect(week.days.every((day) => day.meals.length == 4), isTrue);
    expect(
      week.days.expand((day) => day.meals).expand((meal) => meal.ingredients),
      everyElement(
        isNot(isIn(const {'chicken', 'tuna', 'eggs', 'greek-yogurt'})),
      ),
    );
    expect(
      week.days.every(
        (day) =>
            (day.estimatedCalories - targets.calories).abs() <
            targets.calories * .18,
      ),
      isTrue,
    );
    expect(week.groceryItems, isNotEmpty);
  });

  test(
    'nutrition plan choices persist locally and reject unsafe values',
    () async {
      final repository = MemoryRepository();
      final store = FitnessStore(repository);
      await store.load();
      await store.updateNutritionPlanPreferences(
        dietStyle: 'vegan',
        mealsPerDay: 5,
        budgetMode: 'economy',
        quickPrep: false,
      );
      final restored = FitnessData.fromJson(repository.value.toJson());

      expect(restored.preferences.nutritionDietStyle, 'vegan');
      expect(restored.preferences.nutritionMealsPerDay, 5);
      expect(restored.preferences.nutritionBudgetMode, 'economy');
      expect(restored.preferences.nutritionQuickPrep, isFalse);

      await store.updateNutritionPlanPreferences(
        dietStyle: 'medical-crash-diet',
        mealsPerDay: 99,
        budgetMode: 'unknown',
      );
      expect(store.preferences.nutritionDietStyle, 'balanced');
      expect(store.preferences.nutritionMealsPerDay, 5);
      expect(store.preferences.nutritionBudgetMode, 'standard');
    },
  );

  test('goal-phase calorie planner orders deficit maintenance and surplus', () {
    final loss = NutritionPlannerEngine.phasePlan(
      weightKilograms: 80,
      phase: 'Fat loss',
      trainingDaysPerWeek: 4,
    );
    final maintenance = NutritionPlannerEngine.phasePlan(
      weightKilograms: 80,
      phase: 'Maintenance',
      trainingDaysPerWeek: 4,
    );
    final gain = NutritionPlannerEngine.phasePlan(
      weightKilograms: 80,
      phase: 'Muscle gain',
      trainingDaysPerWeek: 4,
    );

    expect(loss.dailyCalories, lessThan(maintenance.dailyCalories));
    expect(gain.dailyCalories, greaterThan(maintenance.dailyCalories));
    expect(loss.targetWeeklyChangePercent, lessThan(0));
    expect(gain.targetWeeklyChangePercent, greaterThan(0));
  });

  test('weekly calorie budget preserves the seven-day total', () {
    final plan = NutritionPlannerEngine.phasePlan(
      weightKilograms: 80,
      phase: 'Maintenance',
      trainingDaysPerWeek: 4,
    );
    final budget = NutritionPlannerEngine.weeklyBudget(
      plan: plan,
      trainingWeekdays: const {1, 2, 4, 6},
    );

    expect(budget.days, hasLength(7));
    expect(budget.totalCalories, plan.dailyCalories * 7);
    expect(
      budget.days.firstWhere((item) => item.weekday == 1).calories,
      greaterThan(budget.days.firstWhere((item) => item.weekday == 3).calories),
    );
  });

  test('protein distribution reaches the target across selected meals', () {
    final plan = NutritionPlannerEngine.proteinDistribution(
      dailyProteinGrams: 180,
      meals: 5,
    );

    expect(plan.meals, hasLength(5));
    expect(
      plan.meals.fold<double>(0, (sum, item) => sum + item.grams),
      closeTo(180, .001),
    );
    expect(plan.maximumGapHours, 5);
  });

  test('carb timing reserves pre and post workout shares', () {
    final training = NutritionPlannerEngine.carbTiming(
      dailyCarbohydrates: 300,
      isTrainingDay: true,
    );
    final rest = NutritionPlannerEngine.carbTiming(
      dailyCarbohydrates: 300,
      isTrainingDay: false,
    );

    expect(training.preWorkoutGrams, 75);
    expect(training.postWorkoutGrams, 90);
    expect(rest.preWorkoutGrams, 0);
    expect(rest.otherMealGrams, 300);
  });

  test('fat minimum guard exposes a real shortfall', () {
    final guard = NutritionPlannerEngine.fatGuard(
      weightKilograms: 80,
      dailyCalories: 2400,
      plannedFatGrams: 30,
    );

    expect(guard.minimumGrams, greaterThan(50));
    expect(guard.shortfallGrams, greaterThan(0));
    expect(guard.status, 'BELOW FLOOR');
  });

  test('fiber progression rises gradually and stops at target', () {
    final plan = NutritionPlannerEngine.fiberProgression(
      currentGrams: 16,
      dailyCalories: 2500,
    );

    expect(plan.steps.first.targetGrams, 19);
    expect(plan.steps.last.targetGrams, plan.finalTargetGrams);
    expect(
      plan.steps.every((item) => item.targetGrams <= plan.finalTargetGrams),
      isTrue,
    );
  });

  test('hot high-sweat training raises hydration and sodium context', () {
    final normal = NutritionPlannerEngine.sodiumHydration(
      weightKilograms: 80,
      trainingMinutes: 60,
      sweatLevel: 'Low',
      hotConditions: false,
      waterConsumedMilliliters: 2000,
    );
    final hot = NutritionPlannerEngine.sodiumHydration(
      weightKilograms: 80,
      trainingMinutes: 60,
      sweatLevel: 'High',
      hotConditions: true,
      waterConsumedMilliliters: 2000,
    );

    expect(
      hot.waterTargetMilliliters,
      greaterThan(normal.waterTargetMilliliters),
    );
    expect(
      hot.sodiumFloorMilligrams,
      greaterThan(normal.sodiumFloorMilligrams),
    );
  });

  test('training-day meal timeline anchors pre and post workout slots', () {
    final protein = NutritionPlannerEngine.proteinDistribution(
      dailyProteinGrams: 160,
      meals: 4,
    );
    final carbs = NutritionPlannerEngine.carbTiming(
      dailyCarbohydrates: 240,
      isTrainingDay: true,
    );
    final slots = NutritionPlannerEngine.trainingMealTiming(
      trainingMinutesSinceMidnight: 18 * 60,
      protein: protein,
      carbohydrates: carbs,
    );

    expect(slots, hasLength(4));
    expect(slots[1].label, 'PRE-WORKOUT');
    expect(slots[1].time, '16:00');
    expect(slots[2].time, '19:00');
  });

  test('diet-break planner triggers maintenance after a long deficit', () {
    final loss = NutritionPlannerEngine.phasePlan(
      weightKilograms: 80,
      phase: 'Fat loss',
      trainingDaysPerWeek: 4,
    );
    final plan = NutritionPlannerEngine.dietBreak(
      plan: loss,
      consecutiveDeficitWeeks: 12,
      adherence: .8,
      readinessScore: 60,
    );

    expect(plan.recommended, isTrue);
    expect(plan.durationDays, 14);
    expect(plan.dailyCalories, loss.maintenanceCalories);
  });

  test('reverse diet increments conservatively and reaches maintenance', () {
    final plan = NutritionPlannerEngine.reverseDiet(
      currentCalories: 1800,
      maintenanceCalories: 2400,
    );

    expect(plan.incrementCalories, 100);
    expect(plan.weeks.first.dailyCalories, 1900);
    expect(plan.weeks.last.dailyCalories, 2400);
    expect(plan.weeks.every((item) => item.change <= 100), isTrue);
  });

  test('nutrition phase persists through store and JSON', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();
    await store.saveNutritionPhase(
      phase: 'Muscle gain',
      dailyCalories: 2800,
      durationWeeks: 16,
      targetWeeklyChangePercent: .2,
    );
    final restored = FitnessData.fromJson(repository.value.toJson());

    expect(restored.nutritionPhaseLogs, hasLength(1));
    expect(restored.nutritionPhaseLogs.single.phase, 'Muscle gain');
    expect(restored.nutritionPhaseLogs.single.dailyCalories, 2800);
  });

  test('nutrition integrity audit removes impossible phase plans', () {
    final damaged = FitnessData.initial().copyWith(
      nutritionPhaseLogs: [
        NutritionPhaseLog(
          id: 'bad-phase',
          phase: 'Crash diet',
          dailyCalories: 500,
          durationWeeks: 100,
          targetWeeklyChangePercent: -5,
          startedAt: DateTime(2026, 7, 29),
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );
    final report = DataValidationEngine.audit(damaged);
    final repaired = DataValidationEngine.repair(damaged);

    expect(
      report.issues.any((item) => item.code == 'invalid-nutrition-phase'),
      isTrue,
    );
    expect(repaired.nutritionPhaseLogs, isEmpty);
  });

  test('global search discovers Nutrition Planner', () {
    final results = GlobalSearchEngine.search(
      FitnessData.initial(),
      'protein carb diet break reverse',
    );

    expect(results.single.route, 'nutrition-planner');
  });

  test('global search discovers the simple recommended meal plan', () {
    final results = GlobalSearchEngine.search(
      FitnessData.initial(),
      'εβδομαδιαίο πρόγραμμα φαγητού',
    );

    expect(
      results.any((result) => result.route == 'recommended-nutrition'),
      isTrue,
    );
  });

  testWidgets('Nutrition Planner exposes all four planning zones', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(
      MaterialApp(home: NutritionPlannerPage(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('NUTRITION PLANNER'), findsOneWidget);
    expect(find.text('GOAL-PHASE CALORIE PLANNER'), findsOneWidget);

    await tester.tap(find.text('MACRO GUARDS'));
    await tester.pumpAndSettle();
    expect(find.text('PROTEIN, CARBS, FAT & FIBER'), findsOneWidget);

    await tester.tap(find.text('TIMING & FLUIDS'));
    await tester.pumpAndSettle();
    expect(find.text('TRAINING-DAY MEAL TIMING'), findsOneWidget);

    await tester.tap(find.text('BREAK & REVERSE'));
    await tester.pumpAndSettle();
    expect(find.text('DIET BREAK & REVERSE DIET'), findsOneWidget);
  });

  test('ingredient catalog exposes complete nutrition and cost fields', () {
    final catalog = MealIntelligenceEngine.catalog;

    expect(catalog.length, greaterThanOrEqualTo(12));
    expect(catalog.map((item) => item.id).toSet().length, catalog.length);
    expect(
      catalog.every(
        (item) =>
            item.name.isNotEmpty &&
            item.caloriesPer100Grams > 0 &&
            item.referenceCostPer100Grams > 0 &&
            item.defaultShelfDays > 0,
      ),
      isTrue,
    );
  });

  test('ingredient meal builder calculates summed recipe macros', () {
    final nutrition = MealIntelligenceEngine.recipeNutrition(const [
      IngredientPortion(ingredientId: 'chicken-breast', grams: 100),
      IngredientPortion(ingredientId: 'rice', grams: 100),
    ]);

    expect(nutrition.calories, 295);
    expect(nutrition.proteinGrams, closeTo(33.7, .01));
    expect(nutrition.carbohydrateGrams, 28);
    expect(nutrition.totalWeightGrams, 200);
  });

  test('recipe serving calculator scales every ingredient exactly', () {
    final scaled = MealIntelligenceEngine.scaleRecipe(
      portions: const [
        IngredientPortion(ingredientId: 'oats', grams: 120),
        IngredientPortion(ingredientId: 'berries', grams: 200),
      ],
      originalServings: 2,
      targetServings: 5,
    );

    expect(scaled[0].grams, 300);
    expect(scaled[1].grams, 500);
  });

  test(
    'meal duplication preserves macros and creates a new timestamp',
    () async {
      final repository = MemoryRepository();
      final store = FitnessStore(repository);
      await store.load();
      final source = MealEntry(
        name: 'Power bowl',
        calories: 600,
        proteinGrams: 45,
        carbohydrateGrams: 70,
        fatGrams: 15,
        fiberGrams: 9,
        sodiumMilligrams: 500,
        loggedAt: DateTime(2026, 7, 1),
      );
      await store.duplicateMeal(source);

      expect(store.data.meals.single.name, contains('copy'));
      expect(store.data.meals.single.calories, 600);
      expect(store.data.meals.single.proteinGrams, 45);
      expect(store.data.meals.single.loggedAt, isNot(source.loggedAt));
    },
  );

  test('favorite ingredient library persists and toggles cleanly', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();
    await store.toggleFavoriteIngredient('oats');
    var restored = FitnessData.fromJson(repository.value.toJson());
    expect(restored.favoriteIngredientIds, ['oats']);

    await store.toggleFavoriteIngredient('oats');
    restored = FitnessData.fromJson(repository.value.toJson());
    expect(restored.favoriteIngredientIds, isEmpty);
  });

  test('recent-food shortcuts keep the newest unique meal names', () {
    final meals = [
      MealEntry(
        name: 'Bowl',
        calories: 500,
        proteinGrams: 30,
        carbohydrateGrams: 60,
        fatGrams: 15,
        loggedAt: DateTime(2026, 7, 1),
      ),
      MealEntry(
        name: 'Toast',
        calories: 350,
        proteinGrams: 20,
        carbohydrateGrams: 40,
        fatGrams: 12,
        loggedAt: DateTime(2026, 7, 2),
      ),
      MealEntry(
        name: 'bowl',
        calories: 550,
        proteinGrams: 35,
        carbohydrateGrams: 65,
        fatGrams: 15,
        loggedAt: DateTime(2026, 7, 3),
      ),
    ];
    final recent = MealIntelligenceEngine.recentFoods(meals);

    expect(recent, hasLength(2));
    expect(recent.first.loggedAt, DateTime(2026, 7, 3));
  });

  test('macro-aware suggestions rank meals and expose pantry coverage', () {
    final suggestions = MealIntelligenceEngine.macroSuggestions(
      proteinRemaining: 50,
      carbohydrateRemaining: 80,
      fatRemaining: 20,
      calorieRemaining: 700,
      pantry: [
        PantryItem(
          id: 'rice',
          ingredientId: 'rice',
          name: 'Cooked rice',
          quantityGrams: 500,
          costPer100Grams: .2,
          updatedAt: DateTime(2026, 7, 29),
        ),
      ],
    );

    expect(suggestions, hasLength(4));
    expect(
      suggestions.first.matchScore,
      greaterThanOrEqualTo(suggestions.last.matchScore),
    );
    expect(suggestions.any((item) => item.pantryCoverage > 0), isTrue);
  });

  test(
    'pantry inventory upserts quantity instead of duplicating rows',
    () async {
      final repository = MemoryRepository();
      final store = FitnessStore(repository);
      await store.load();
      await store.savePantryItem(
        ingredientId: 'oats',
        name: 'Oats',
        quantityGrams: 500,
        costPer100Grams: .3,
      );
      await store.savePantryItem(
        ingredientId: 'oats',
        name: 'Oats',
        quantityGrams: 800,
        costPer100Grams: .25,
      );

      expect(store.pantryItems, hasLength(1));
      expect(store.pantryItems.single.quantityGrams, 800);
    },
  );

  test('expiry reminders prioritize expired and soon food', () {
    final now = DateTime(2026, 7, 29);
    final reminders = MealIntelligenceEngine.expiryReminders([
      PantryItem(
        id: 'fresh',
        ingredientId: 'oats',
        name: 'Oats',
        quantityGrams: 500,
        costPer100Grams: .3,
        updatedAt: now,
        expiresAt: now.add(const Duration(days: 30)),
      ),
      PantryItem(
        id: 'expired',
        ingredientId: 'greek-yogurt',
        name: 'Greek yogurt',
        quantityGrams: 200,
        costPer100Grams: .5,
        updatedAt: now,
        expiresAt: now.subtract(const Duration(days: 1)),
      ),
    ], now: now);

    expect(reminders.first.status, 'EXPIRED');
    expect(reminders.last.status, 'FRESH');
  });

  test('budget grocery mode subtracts pantry stock from purchase', () {
    final plan = MealIntelligenceEngine.budgetGrocery(
      portions: const [
        IngredientPortion(ingredientId: 'rice', grams: 600),
        IngredientPortion(ingredientId: 'chicken-breast', grams: 400),
      ],
      pantry: [
        PantryItem(
          id: 'rice',
          ingredientId: 'rice',
          name: 'Rice',
          quantityGrams: 500,
          costPer100Grams: .2,
          updatedAt: DateTime(2026, 7, 29),
        ),
      ],
    );
    final rice = plan.items.firstWhere((item) => item.ingredientId == 'rice');

    expect(rice.buyGrams, 100);
    expect(rice.estimatedCost, closeTo(.2, .001));
    expect(plan.pantrySavings, closeTo(1, .001));
  });

  test('batch-cooking plan scales recipe nutrition and containers', () {
    final suggestion = MealIntelligenceEngine.macroSuggestions(
      proteinRemaining: 50,
      carbohydrateRemaining: 80,
      fatRemaining: 20,
      calorieRemaining: 700,
      pantry: const [],
    ).first;
    final batch = MealIntelligenceEngine.batchCooking(
      recipe: suggestion,
      servings: 5,
      pantry: const [],
    );

    expect(batch.servings, 5);
    expect(batch.total.calories, closeTo(batch.perServing.calories * 5, 2));
    expect(batch.prepSteps, hasLength(3));
    expect(batch.grocery.items, isNotEmpty);
  });

  test('meal intelligence integrity repairs pantry and favorites', () {
    final damaged = FitnessData.initial().copyWith(
      pantryItems: [
        PantryItem(
          id: 'bad',
          ingredientId: 'unknown',
          name: '',
          quantityGrams: -2,
          costPer100Grams: 200,
          updatedAt: DateTime(2026, 7, 29),
        ),
      ],
      favoriteIngredientIds: const ['oats', 'oats', 'unknown'],
    );
    final report = DataValidationEngine.audit(damaged);
    final repaired = DataValidationEngine.repair(damaged);

    expect(
      report.issues.any((item) => item.code == 'invalid-pantry-item'),
      isTrue,
    );
    expect(
      report.issues.any((item) => item.code == 'invalid-favorite-ingredients'),
      isTrue,
    );
    expect(repaired.pantryItems, isEmpty);
    expect(repaired.favoriteIngredientIds, ['oats']);
  });

  test('global search discovers Meal Intelligence', () {
    final results = GlobalSearchEngine.search(
      FitnessData.initial(),
      'ingredient pantry expiry batch cooking',
    );

    expect(results.single.route, 'meal-intelligence');
  });

  testWidgets('Meal Intelligence exposes builder library pantry and budget', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(
      MaterialApp(home: MealIntelligencePage(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('MEAL INTELLIGENCE'), findsOneWidget);
    expect(find.text('INGREDIENT-LEVEL MEAL BUILDER'), findsOneWidget);

    await tester.tap(find.text('LIBRARY'));
    await tester.pumpAndSettle();
    expect(find.text('FAVORITES & RECENT FOODS'), findsOneWidget);

    await tester.tap(find.text('PANTRY'));
    await tester.pumpAndSettle();
    expect(find.text('PANTRY INVENTORY & EXPIRY'), findsOneWidget);

    await tester.tap(find.text('BUDGET & PREP'));
    await tester.pumpAndSettle();
    expect(find.text('MACRO-AWARE BUDGET & BATCH PREP'), findsOneWidget);
  });

  test('smoothed weight trend dampens a single-day scale spike', () {
    final trend = BodyCompositionEngine.smoothedWeightTrend([
      WeightEntry(kilograms: 80, recordedAt: DateTime(2026, 7, 1)),
      WeightEntry(kilograms: 80, recordedAt: DateTime(2026, 7, 2)),
      WeightEntry(kilograms: 84, recordedAt: DateTime(2026, 7, 3)),
    ]);

    expect(trend, hasLength(3));
    expect(trend.last.rawKilograms, 84);
    expect(trend.last.trendKilograms, lessThan(82));
  });

  test('weekly weight rate compares two seven-day averages', () {
    final weights = [
      for (var day = 1; day <= 14; day++)
        WeightEntry(
          kilograms: day <= 7 ? 80 : 79,
          recordedAt: DateTime(2026, 7, day),
        ),
    ];
    final rate = BodyCompositionEngine.weeklyRate(weights);

    expect(rate.currentAverage, 79);
    expect(rate.previousAverage, 80);
    expect(rate.kilogramsPerWeek, -1);
    expect(rate.label, 'FALLING');
  });

  test('multi-site measurement trend calculates waist direction', () {
    final trend = BodyCompositionEngine.measurementTrend([
      BodyMeasurementLog(
        id: 'first',
        weightKilograms: 80,
        waistCentimeters: 90,
        neckCentimeters: 38,
        chestCentimeters: 100,
        hipsCentimeters: 98,
        upperArmCentimeters: 34,
        thighCentimeters: 58,
        recordedAt: DateTime(2026, 7, 1),
      ),
      BodyMeasurementLog(
        id: 'last',
        weightKilograms: 78,
        waistCentimeters: 86,
        neckCentimeters: 38,
        chestCentimeters: 99,
        hipsCentimeters: 96,
        upperArmCentimeters: 34,
        thighCentimeters: 57,
        recordedAt: DateTime(2026, 7, 29),
      ),
    ]);

    expect(trend.latest, 86);
    expect(trend.change, -4);
    expect(trend.days, 28);
  });

  test('body-fat estimate remains a broad bounded range', () {
    final estimate = BodyCompositionEngine.bodyFatRange(
      weightKilograms: 80,
      heightCentimeters: 180,
      waistCentimeters: 88,
      neckCentimeters: 38,
      hipsCentimeters: 98,
    );

    expect(estimate.minimumPercent, greaterThan(3));
    expect(estimate.centralPercent, inInclusiveRange(8, 45));
    expect(estimate.maximumPercent, greaterThan(estimate.centralPercent));
    expect(estimate.confidence, 'CONTEXTUAL RANGE');
  });

  test('lean-mass trend uses the same broad estimate consistently', () {
    final trend = BodyCompositionEngine.leanMassTrend(
      heightCentimeters: 180,
      logs: [
        BodyMeasurementLog(
          id: 'first',
          weightKilograms: 80,
          waistCentimeters: 90,
          neckCentimeters: 38,
          chestCentimeters: 100,
          hipsCentimeters: 98,
          upperArmCentimeters: 34,
          thighCentimeters: 58,
          recordedAt: DateTime(2026, 7, 1),
        ),
        BodyMeasurementLog(
          id: 'last',
          weightKilograms: 80,
          waistCentimeters: 85,
          neckCentimeters: 38,
          chestCentimeters: 100,
          hipsCentimeters: 98,
          upperArmCentimeters: 34,
          thighCentimeters: 58,
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );

    expect(trend.sampleSize, 2);
    expect(trend.latestKilograms, greaterThan(trend.earliestKilograms));
    expect(trend.changeKilograms, greaterThan(0));
  });

  test('progress-photo comparison selects oldest and newest', () {
    final comparison = BodyCompositionEngine.photoComparison([
      ProgressPhoto(
        id: 'new',
        encodedBytes: 'AA==',
        mimeType: 'image/jpeg',
        recordedAt: DateTime(2026, 7, 29),
        weightKilograms: 78,
      ),
      ProgressPhoto(
        id: 'old',
        encodedBytes: 'AA==',
        mimeType: 'image/jpeg',
        recordedAt: DateTime(2026, 7, 1),
        weightKilograms: 80,
      ),
    ]);

    expect(comparison.available, isTrue);
    expect(comparison.before!.id, 'old');
    expect(comparison.after!.id, 'new');
    expect(comparison.daysBetween, 28);
    expect(comparison.weightChangeKilograms, -2);
  });

  test('measurement reminders use a quieter cadence after three logs', () {
    final now = DateTime(2026, 7, 29);
    final logs = [
      for (var day in [1, 15, 29])
        BodyMeasurementLog(
          id: '$day',
          weightKilograms: 80,
          waistCentimeters: 88,
          neckCentimeters: 38,
          chestCentimeters: 100,
          hipsCentimeters: 98,
          upperArmCentimeters: 34,
          thighCentimeters: 58,
          recordedAt: DateTime(2026, 7, day),
        ),
    ];
    final reminder = BodyCompositionEngine.reminder(logs: logs, now: now);

    expect(reminder.cadenceDays, 28);
    expect(reminder.daysRemaining, 28);
    expect(reminder.status, 'SCHEDULED');
  });

  test('goal projection returns a bounded band and target ETA', () {
    final projection = BodyCompositionEngine.projection(
      currentKilograms: 80,
      targetKilograms: 75,
      weeklyRateKilograms: -.4,
    );

    expect(projection.estimatedWeeks, 13);
    expect(projection.points, isNotEmpty);
    expect(
      projection.points.every(
        (item) =>
            item.lowerKilograms <= item.centralKilograms &&
            item.upperKilograms >= item.centralKilograms,
      ),
      isTrue,
    );
  });

  test('plateau-aware calorie review makes only a small adjustment', () {
    final weights = [
      for (var day = 1; day <= 14; day++)
        WeightEntry(kilograms: 80, recordedAt: DateTime(2026, 7, day)),
    ];
    final review = BodyCompositionEngine.calorieReview(
      phase: 'Fat loss',
      currentCalories: 2200,
      weights: weights,
      nutritionAdherence: .9,
    );

    expect(review.status, 'PLATEAU REVIEW');
    expect(review.adjustment, -100);
    expect(review.suggestedCalories, 2100);
    expect(review.reviewAfterDays, 14);
  });

  test('body measurement saves a matching weight entry', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();
    await store.saveBodyMeasurement(
      weightKilograms: 79,
      waistCentimeters: 87,
      neckCentimeters: 38,
      chestCentimeters: 100,
      hipsCentimeters: 98,
      upperArmCentimeters: 34,
      thighCentimeters: 58,
    );
    final restored = FitnessData.fromJson(repository.value.toJson());

    expect(restored.bodyMeasurementLogs, hasLength(1));
    expect(restored.weights, hasLength(1));
    expect(restored.weights.single.kilograms, 79);
  });

  test('body composition integrity removes impossible measurements', () {
    final damaged = FitnessData.initial().copyWith(
      bodyMeasurementLogs: [
        BodyMeasurementLog(
          id: 'bad',
          weightKilograms: 5,
          waistCentimeters: 0,
          neckCentimeters: 500,
          chestCentimeters: 0,
          hipsCentimeters: 0,
          upperArmCentimeters: 0,
          thighCentimeters: 0,
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );
    final report = DataValidationEngine.audit(damaged);
    final repaired = DataValidationEngine.repair(damaged);

    expect(
      report.issues.any((item) => item.code == 'invalid-body-measurement'),
      isTrue,
    );
    expect(repaired.bodyMeasurementLogs, isEmpty);
  });

  test('global search discovers Body Composition', () {
    final results = GlobalSearchEngine.search(
      FitnessData.initial(),
      'smoothed weight waist photo projection',
    );

    expect(results.single.route, 'body-composition');
  });

  testWidgets('Body Composition exposes trends measurements and review', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(
      MaterialApp(home: BodyCompositionPage(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('BODY COMPOSITION'), findsOneWidget);
    expect(find.text('SMOOTHED WEIGHT TREND'), findsOneWidget);

    await tester.tap(find.text('MEASURE'));
    await tester.pumpAndSettle();
    expect(find.text('WAIST & MULTI-SITE MEASUREMENTS'), findsOneWidget);

    await tester.tap(find.text('COMPOSITION'));
    await tester.pumpAndSettle();
    expect(find.text('BODY-COMPOSITION RANGE'), findsOneWidget);

    await tester.tap(find.text('PHOTOS & REVIEW'));
    await tester.pumpAndSettle();
    expect(find.text('PHOTO COMPARISON & CALORIE REVIEW'), findsOneWidget);
  });

  test('daily habit checklist separates full, minimum and open states', () {
    final habit = HealthHabit(
      id: 'mobility',
      name: '10-minute mobility',
      category: 'Movement',
      targetDaysPerWeek: 5,
      minimumVersion: 'One drill',
      stackAfter: 'work',
      preferredMinutesSinceMidnight: 1080,
      createdAt: DateTime(2026, 7, 1),
    );
    final day = DateTime(2026, 7, 29);
    final minimum = HabitCheckIn(
      id: 'check',
      habitId: habit.id,
      day: day,
      completed: false,
      usedMinimum: true,
      frictionLevel: 3,
      reflection: '',
      recordedAt: day,
    );
    final items = HabitBuilderEngine.dailyChecklist(
      habits: [
        habit,
        HealthHabit(
          id: 'second',
          name: 'Second habit',
          category: 'Mindset',
          targetDaysPerWeek: 3,
          minimumVersion: 'One minute',
          stackAfter: 'lunch',
          preferredMinutesSinceMidnight: 780,
          createdAt: DateTime(2026, 7, 1),
        ),
      ],
      checkIns: [minimum],
      day: day,
    );

    expect(items.first.status, 'MINIMUM DAY');
    expect(items.last.status, 'OPEN');
  });

  test('streak protection counts full and minimum days', () {
    final habit = HealthHabit(
      id: 'sleep',
      name: 'Lights out routine',
      category: 'Recovery',
      targetDaysPerWeek: 7,
      minimumVersion: 'Dim the lights',
      stackAfter: 'alarm',
      preferredMinutesSinceMidnight: 1320,
      createdAt: DateTime(2026, 7, 1),
    );
    final checks = [
      for (var index = 0; index < 3; index++)
        HabitCheckIn(
          id: '$index',
          habitId: habit.id,
          day: DateTime(2026, 7, 29 - index),
          completed: index != 1,
          usedMinimum: index == 1,
          frictionLevel: 2,
          reflection: '',
          recordedAt: DateTime(2026, 7, 29 - index),
        ),
    ];
    final streak = HabitBuilderEngine.streakProtection(
      habit: habit,
      checkIns: checks,
      now: DateTime(2026, 7, 29),
    );

    expect(streak.days, 3);
    expect(streak.minimumDays, 1);
    expect(streak.status, 'STREAK SECURE');
  });

  test('weekly habit score weights a minimum day as one half', () {
    final habit = HealthHabit(
      id: 'walk',
      name: 'Post-meal walk',
      category: 'Movement',
      targetDaysPerWeek: 2,
      minimumVersion: 'Walk two minutes',
      stackAfter: 'dinner',
      preferredMinutesSinceMidnight: 1200,
      createdAt: DateTime(2026, 7, 1),
    );
    final score = HabitBuilderEngine.weeklyScore(
      habit: habit,
      checkIns: [
        HabitCheckIn(
          id: 'full',
          habitId: habit.id,
          day: DateTime(2026, 7, 27),
          completed: true,
          usedMinimum: false,
          frictionLevel: 1,
          reflection: '',
          recordedAt: DateTime(2026, 7, 27),
        ),
        HabitCheckIn(
          id: 'minimum',
          habitId: habit.id,
          day: DateTime(2026, 7, 28),
          completed: false,
          usedMinimum: true,
          frictionLevel: 4,
          reflection: '',
          recordedAt: DateTime(2026, 7, 28),
        ),
      ],
      now: DateTime(2026, 7, 29),
    );

    expect(score.points, 1.5);
    expect(score.percent, 75);
  });

  test('implementation intention includes exact anchor and time', () {
    final prompt = HabitBuilderEngine.implementationIntention(
      HealthHabit(
        id: 'protein',
        name: 'Prepare protein breakfast',
        category: 'Nutrition',
        targetDaysPerWeek: 5,
        minimumVersion: 'Set out yogurt',
        stackAfter: 'making coffee',
        preferredMinutesSinceMidnight: 450,
        createdAt: DateTime(2026, 7, 1),
      ),
    );

    expect(prompt, contains('07:30'));
    expect(prompt, contains('after making coffee'));
  });

  test('habit stacking returns category-aware anchors', () {
    final stacks = HabitBuilderEngine.stackSuggestions(
      HealthHabit(
        id: 'water',
        name: 'Drink water',
        category: 'Nutrition',
        targetDaysPerWeek: 7,
        minimumVersion: 'Take one sip',
        stackAfter: '',
        preferredMinutesSinceMidnight: 480,
        createdAt: DateTime(2026, 7, 1),
      ),
    );

    expect(stacks, hasLength(3));
    expect(stacks.join(' '), contains('meal'));
  });

  test('friction audit exposes a high-friction system', () {
    final habit = HealthHabit(
      id: 'journal',
      name: 'Evening journal',
      category: 'Mindset',
      targetDaysPerWeek: 4,
      minimumVersion: 'Write one sentence',
      stackAfter: 'alarm',
      preferredMinutesSinceMidnight: 1260,
      createdAt: DateTime(2026, 7, 1),
    );
    final report = HabitBuilderEngine.frictionAudit(
      habit: habit,
      checkIns: [
        for (var level in [4, 5, 4])
          HabitCheckIn(
            id: '$level-${DateTime.now().microsecondsSinceEpoch}',
            habitId: habit.id,
            day: DateTime(2026, 7, level),
            completed: true,
            usedMinimum: false,
            frictionLevel: level,
            reflection: '',
            recordedAt: DateTime(2026, 7, level),
          ),
      ],
    );

    expect(report.label, 'HIGH FRICTION');
    expect(report.highFrictionDays, 3);
    expect(report.action, contains('halve'));
  });

  test('minimum-day fallback returns the designed tiny action', () {
    final fallback = HabitBuilderEngine.minimumDayFallback(
      HealthHabit(
        id: 'breathing',
        name: 'Breathing practice',
        category: 'Recovery',
        targetDaysPerWeek: 5,
        minimumVersion: 'Take three slow breaths',
        stackAfter: 'lunch',
        preferredMinutesSinceMidnight: 780,
        createdAt: DateTime(2026, 7, 1),
      ),
    );

    expect(fallback, 'Take three slow breaths');
  });

  test('reflection summary selects the newest note', () {
    final habit = HealthHabit(
      id: 'steps',
      name: 'Walk outside',
      category: 'Movement',
      targetDaysPerWeek: 5,
      minimumVersion: 'Step outside',
      stackAfter: 'lunch',
      preferredMinutesSinceMidnight: 780,
      createdAt: DateTime(2026, 7, 1),
    );
    final summary = HabitBuilderEngine.reflectionSummary(
      habit: habit,
      checkIns: [
        for (var day in [1, 2])
          HabitCheckIn(
            id: '$day',
            habitId: habit.id,
            day: DateTime(2026, 7, day),
            completed: true,
            usedMinimum: false,
            frictionLevel: 1,
            reflection: day == 1 ? 'Old note' : 'New note',
            recordedAt: DateTime(2026, 7, day),
          ),
      ],
    );

    expect(summary.count, 2);
    expect(summary.latest, 'New note');
  });

  test('habit correlation stays cautious with early data', () {
    final habit = HealthHabit(
      id: 'early',
      name: 'Early habit',
      category: 'Mindset',
      targetDaysPerWeek: 3,
      minimumVersion: 'One minute',
      stackAfter: 'coffee',
      preferredMinutesSinceMidnight: 480,
      createdAt: DateTime(2026, 7, 1),
    );
    final result = HabitBuilderEngine.progressCorrelation(
      habit: habit,
      checkIns: const [],
      recoveryChecks: const [],
      workouts: const [],
    );

    expect(result.label, 'EARLY DATA');
    expect(result.caution, contains('three'));
  });

  test('habit progress correlation compares readiness and workouts', () {
    final habit = HealthHabit(
      id: 'correlation',
      name: 'Morning walk',
      category: 'Movement',
      targetDaysPerWeek: 3,
      minimumVersion: 'Walk one minute',
      stackAfter: 'coffee',
      preferredMinutesSinceMidnight: 480,
      createdAt: DateTime(2026, 7, 1),
    );
    final completedDays = [1, 2, 3];
    final result = HabitBuilderEngine.progressCorrelation(
      habit: habit,
      checkIns: [
        for (final day in completedDays)
          HabitCheckIn(
            id: '$day',
            habitId: habit.id,
            day: DateTime(2026, 7, day),
            completed: true,
            usedMinimum: false,
            frictionLevel: 1,
            reflection: '',
            recordedAt: DateTime(2026, 7, day),
          ),
      ],
      recoveryChecks: [
        for (var day = 1; day <= 5; day++)
          RecoveryCheckIn(
            sleepHours: day <= 3 ? 8 : 5,
            energy: day <= 3 ? 5 : 2,
            soreness: day <= 3 ? 1 : 4,
            stress: day <= 3 ? 1 : 4,
            recordedAt: DateTime(2026, 7, day),
          ),
      ],
      workouts: [
        for (final day in completedDays)
          WorkoutLog(
            templateName: 'Workout',
            completedAt: DateTime(2026, 7, day),
            minutes: 45,
          ),
      ],
    );

    expect(result.sampleDays, 5);
    expect(result.readinessLift, greaterThan(20));
    expect(result.workoutLift, greaterThan(.5));
    expect(result.label, 'POSITIVE ASSOCIATION');
  });

  test('habit models survive JSON round trip', () {
    final source = FitnessData.initial().copyWith(
      healthHabits: [
        HealthHabit(
          id: 'roundtrip',
          name: 'Read ten pages',
          category: 'Mindset',
          targetDaysPerWeek: 4,
          minimumVersion: 'Read one page',
          stackAfter: 'dinner',
          preferredMinutesSinceMidnight: 1200,
          createdAt: DateTime(2026, 7, 1),
        ),
      ],
      habitCheckIns: [
        HabitCheckIn(
          id: 'check',
          habitId: 'roundtrip',
          day: DateTime(2026, 7, 29),
          completed: true,
          usedMinimum: false,
          frictionLevel: 2,
          reflection: 'Quiet room helped.',
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );
    final restored = FitnessData.fromJson(source.toJson());

    expect(restored.healthHabits.single.name, 'Read ten pages');
    expect(restored.habitCheckIns.single.reflection, 'Quiet room helped.');
  });

  test('store upserts one check-in per habit and day', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();
    final habit = await store.saveHealthHabit(
      name: 'Prepare gym bag',
      category: 'Movement',
      targetDaysPerWeek: 4,
      minimumVersion: 'Put shoes by the door',
      stackAfter: 'dinner',
      preferredMinutesSinceMidnight: 1200,
    );
    await store.saveHabitCheckIn(
      habitId: habit.id,
      day: DateTime(2026, 7, 29),
      completed: false,
      usedMinimum: true,
      frictionLevel: 4,
    );
    await store.saveHabitCheckIn(
      habitId: habit.id,
      day: DateTime(2026, 7, 29, 22),
      completed: true,
      usedMinimum: false,
      frictionLevel: 1,
      reflection: 'Prepared earlier.',
    );

    expect(store.habitCheckIns, hasLength(1));
    expect(store.habitCheckIns.single.completed, isTrue);
    expect(store.habitCheckIns.single.reflection, 'Prepared earlier.');
  });

  test('habit integrity removes orphan and contradictory check-ins', () {
    final damaged = FitnessData.initial().copyWith(
      habitCheckIns: [
        HabitCheckIn(
          id: 'bad',
          habitId: 'missing',
          day: DateTime(2026, 7, 29),
          completed: true,
          usedMinimum: true,
          frictionLevel: 9,
          reflection: '',
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );
    final report = DataValidationEngine.audit(damaged);
    final repaired = DataValidationEngine.repair(damaged);

    expect(
      report.issues.any((item) => item.code == 'invalid-habit-check-in'),
      isTrue,
    );
    expect(repaired.habitCheckIns, isEmpty);
  });

  test('global search discovers Habit Builder', () {
    final results = GlobalSearchEngine.search(
      FitnessData.initial(),
      'streak stacking friction reflection correlation',
    );

    expect(results.single.route, 'habit-builder');
  });

  testWidgets('Habit Builder exposes all four working surfaces', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(MaterialApp(home: HabitBuilderPage(store: store)));
    await tester.pumpAndSettle();

    expect(find.text('HABIT BUILDER'), findsOneWidget);
    expect(find.text('TODAY’S SYSTEM'), findsOneWidget);

    await tester.tap(find.text('BUILD'));
    await tester.pumpAndSettle();
    expect(find.text('DESIGN A REPEATABLE HABIT'), findsOneWidget);

    await tester.tap(find.text('SYSTEM'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Create your first habit'), findsOneWidget);

    await tester.tap(find.text('INSIGHTS'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Create your first habit'), findsOneWidget);
  });

  test('sleep schedule handles an overnight window', () {
    final result = SleepStressEngine.schedule([
      SleepRoutineLog(
        id: 'one',
        day: DateTime(2026, 7, 28),
        bedtimeMinutes: 1380,
        wakeMinutes: 420,
        lastCaffeineMinutes: 840,
        screenFreeMinutes: 45,
        windDownSteps: const ['Dim lights'],
        recordedAt: DateTime(2026, 7, 29),
      ),
    ]);

    expect(result.durationMinutes, 480);
    expect(result.bedtimeMinutes, 1380);
    expect(result.wakeMinutes, 420);
    expect(result.label, 'RECOVERY WINDOW');
  });

  test('bedtime consistency normalizes minutes across midnight', () {
    final logs = [
      for (final bedtime in [1410, 30, 0])
        SleepRoutineLog(
          id: '$bedtime',
          day: DateTime(2026, 7, bedtime == 1410 ? 1 : bedtime + 2),
          bedtimeMinutes: bedtime,
          wakeMinutes: 420,
          lastCaffeineMinutes: 840,
          screenFreeMinutes: 45,
          windDownSteps: const [],
          recordedAt: DateTime(2026, 7, 1),
        ),
    ];
    final score = SleepStressEngine.bedtimeConsistency(logs);

    expect(score.score, greaterThanOrEqualTo(70));
    expect(score.averageDeviationMinutes, 20);
  });

  test('wake consistency flags an irregular pattern', () {
    final logs = [
      for (final wake in [300, 420, 600])
        SleepRoutineLog(
          id: '$wake',
          day: DateTime(2026, 7, wake ~/ 100),
          bedtimeMinutes: 1380,
          wakeMinutes: wake,
          lastCaffeineMinutes: 840,
          screenFreeMinutes: 30,
          windDownSteps: const [],
          recordedAt: DateTime(2026, 7, 1),
        ),
    ];
    final score = SleepStressEngine.wakeConsistency(logs);

    expect(score.score, lessThan(50));
    expect(score.label, 'IRREGULAR');
  });

  test('caffeine cutoff detects intake inside the pre-bed buffer', () {
    final plan = SleepStressEngine.caffeineCutoff(
      bedtimeMinutes: 1380,
      lastCaffeineMinutes: 1020,
    );

    expect(plan.cutoffMinutes, 900);
    expect(plan.status, 'LATE CAFFEINE');
    expect(plan.bufferHours, 8);
  });

  test('wind-down routine escalates the last step under high stress', () {
    final routine = SleepStressEngine.windDownRoutine(
      bedtimeMinutes: 1380,
      stressLevel: 5,
    );

    expect(routine, hasLength(4));
    expect(routine[2].title, 'DOWNSHIFT');
    expect(routine.last.minutesBeforeBed, 0);
  });

  test('screen-free planner returns a fixed actionable start time', () {
    final plan = SleepStressEngine.screenFree(
      bedtimeMinutes: 1380,
      actualMinutes: 20,
    );

    expect(plan.startMinutes, 1335);
    expect(plan.targetMinutes, 45);
    expect(plan.status, 'BUILD THE BUFFER');
  });

  test('stress timeline detects a rising recent signal', () {
    final logs = [
      for (var index = 0; index < 6; index++)
        StressCheckInLog(
          id: '$index',
          level: index < 3 ? 2 : 5,
          context: '',
          recordedAt: DateTime(2026, 7, 20 + index),
        ),
    ];
    final summary = SleepStressEngine.stressTimeline(
      logs,
      now: DateTime(2026, 7, 29),
    );

    expect(summary.sampleSize, 6);
    expect(summary.direction, 'RISING');
    expect(summary.peak, 5);
  });

  test('guided relaxation library includes explicit stop rules', () {
    final library = SleepStressEngine.relaxationLibrary();

    expect(library, hasLength(3));
    expect(library.every((item) => item.steps.isNotEmpty), isTrue);
    expect(library.every((item) => item.stopRule.isNotEmpty), isTrue);
  });

  test('sleep training correlation separates rested and short nights', () {
    final checks = [
      for (var day = 1; day <= 6; day++)
        RecoveryCheckIn(
          sleepHours: day <= 3 ? 8 : 5.5,
          energy: 3,
          soreness: 2,
          stress: 2,
          recordedAt: DateTime(2026, 7, day),
        ),
    ];
    final workouts = [
      for (var day = 1; day <= 3; day++)
        WorkoutLog(
          templateName: 'Session',
          completedAt: DateTime(2026, 7, day),
          minutes: 45,
        ),
    ];
    final correlation = SleepStressEngine.trainingCorrelation(
      recoveryChecks: checks,
      workouts: workouts,
    );

    expect(correlation.sampleNights, 6);
    expect(correlation.wellRestedWorkoutRate, 1);
    expect(correlation.shortSleepWorkoutRate, 0);
    expect(correlation.label, 'BETTER AFTER 7H+');
  });

  test('morning brief escalates short sleep stress and dense training', () {
    final brief = SleepStressEngine.morningBrief(
      recovery: RecoveryCheckIn(
        sleepHours: 5,
        energy: 2,
        soreness: 4,
        stress: 5,
        recordedAt: DateTime(2026, 7, 29),
      ),
      stress: const StressTimelineSummary(
        average: 4.5,
        peak: 5,
        direction: 'RISING',
        sampleSize: 5,
      ),
      hardWorkoutsLast72Hours: 2,
    );

    expect(brief.score, greaterThanOrEqualTo(70));
    expect(brief.status, 'HIGH FATIGUE RISK');
    expect(brief.action, contains('avoid maximal'));
  });

  test('sleep and stress models survive JSON round trip', () {
    final source = FitnessData.initial().copyWith(
      sleepRoutineLogs: [
        SleepRoutineLog(
          id: 'sleep',
          day: DateTime(2026, 7, 29),
          bedtimeMinutes: 1380,
          wakeMinutes: 420,
          lastCaffeineMinutes: 840,
          screenFreeMinutes: 45,
          windDownSteps: const ['Phone away'],
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
      stressCheckInLogs: [
        StressCheckInLog(
          id: 'stress',
          level: 3,
          context: 'Normal workday',
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );
    final restored = FitnessData.fromJson(source.toJson());

    expect(restored.sleepRoutineLogs.single.screenFreeMinutes, 45);
    expect(restored.stressCheckInLogs.single.context, 'Normal workday');
  });

  test('sleep routine store upserts a single day', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();
    await store.saveSleepRoutine(
      day: DateTime(2026, 7, 29),
      bedtimeMinutes: 1380,
      wakeMinutes: 420,
      lastCaffeineMinutes: 840,
      screenFreeMinutes: 30,
      windDownSteps: const ['Dim lights'],
    );
    await store.saveSleepRoutine(
      day: DateTime(2026, 7, 29, 23),
      bedtimeMinutes: 1365,
      wakeMinutes: 405,
      lastCaffeineMinutes: 780,
      screenFreeMinutes: 60,
      windDownSteps: const ['Phone away'],
    );

    expect(store.sleepRoutineLogs, hasLength(1));
    expect(store.sleepRoutineLogs.single.bedtimeMinutes, 1365);
    expect(store.sleepRoutineLogs.single.screenFreeMinutes, 60);
  });

  test('sleep and stress integrity repairs impossible values', () {
    final damaged = FitnessData.initial().copyWith(
      sleepRoutineLogs: [
        SleepRoutineLog(
          id: 'bad-sleep',
          day: DateTime(2026, 7, 29),
          bedtimeMinutes: 2000,
          wakeMinutes: -1,
          lastCaffeineMinutes: 900,
          screenFreeMinutes: 500,
          windDownSteps: const [],
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
      stressCheckInLogs: [
        StressCheckInLog(
          id: 'bad-stress',
          level: 9,
          context: '',
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );
    final report = DataValidationEngine.audit(damaged);
    final repaired = DataValidationEngine.repair(damaged);

    expect(
      report.issues.any((item) => item.code == 'invalid-sleep-routine'),
      isTrue,
    );
    expect(
      report.issues.any((item) => item.code == 'invalid-stress-check-in'),
      isTrue,
    );
    expect(repaired.sleepRoutineLogs, isEmpty);
    expect(repaired.stressCheckInLogs, isEmpty);
  });

  test('global search discovers Sleep and Stress', () {
    final results = GlobalSearchEngine.search(
      FitnessData.initial(),
      'caffeine wind down screen free fatigue brief',
    );

    expect(results.single.route, 'sleep-stress');
  });

  testWidgets('Sleep and Stress exposes all four functional tabs', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(MaterialApp(home: SleepStressPage(store: store)));
    await tester.pumpAndSettle();

    expect(find.text('SLEEP & STRESS'), findsOneWidget);
    expect(find.text('SLEEP SCHEDULE TRACKER'), findsOneWidget);

    await tester.tap(find.text('WIND-DOWN'));
    await tester.pumpAndSettle();
    expect(find.text('EVENING WIND-DOWN'), findsOneWidget);

    await tester.tap(find.text('STRESS'));
    await tester.pumpAndSettle();
    expect(find.text('STRESS TIMELINE'), findsOneWidget);

    await tester.tap(find.text('MORNING'));
    await tester.pumpAndSettle();
    expect(find.text('FATIGUE-RISK MORNING BRIEF'), findsOneWidget);
  });

  test('advanced coach explains evidence confidence and rules', () {
    final plan = DailyCoachPlan(
      score: 60,
      headline: 'Control',
      actions: const [
        CoachAction(
          id: 'recovery',
          title: 'Protect recovery',
          detail: 'Keep two RIR.',
          priority: CoachPriority.critical,
          iconKey: 'recovery',
        ),
      ],
    );
    final data = FitnessData.initial().copyWith(
      recoveryChecks: [
        RecoveryCheckIn(
          sleepHours: 5.5,
          energy: 2,
          soreness: 4,
          stress: 4,
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );
    final result = AdvancedCoachEngine.explain(plan: plan, data: data).single;

    expect(result.confidence, CoachConfidence.high);
    expect(result.confidencePercent, greaterThanOrEqualTo(82));
    expect(result.why, hasLength(2));
    expect(result.ruleTrace, contains('R-REC-01: readiness score < 55'));
  });

  test('coach rule trace stays deterministic per recommendation', () {
    expect(
      AdvancedCoachEngine.ruleTrace('water'),
      contains('R-NUT-04: hydration < 55% of target'),
    );
    expect(
      AdvancedCoachEngine.ruleTrace('reschedule').first,
      startsWith('R-SCH-01'),
    );
  });

  test('competing goals put safety ahead of performance', () {
    final priorities = AdvancedCoachEngine.prioritizeGoals(
      profileGoal: 'Strength',
      recoveryScore: 35,
      painFlag: true,
      nutritionAdherence: .7,
    );

    expect(priorities.first.goal, 'Recovery & safety');
    expect(priorities.first.status, 'OVERRIDES');
    expect(priorities[1].goal, 'Strength');
    expect(priorities[2].status, 'SUPPORT');
  });

  test('coach learns the most accepted local action', () {
    final feedback = [
      for (var index = 0; index < 3; index++)
        CoachRecommendationFeedback(
          id: 'water-$index',
          recommendationId: 'water',
          accepted: true,
          helpful: index < 2,
          note: '',
          recordedAt: DateTime(2026, 7, index + 1),
        ),
      CoachRecommendationFeedback(
        id: 'protein',
        recommendationId: 'protein',
        accepted: false,
        helpful: false,
        note: '',
        recordedAt: DateTime(2026, 7, 4),
      ),
    ];
    final result = AdvancedCoachEngine.learning(feedback);

    expect(result.feedbackCount, 4);
    expect(result.acceptanceRate, .75);
    expect(result.helpfulRate, .5);
    expect(result.learnedPreference, contains('water'));
  });

  test('accepted actions increase personal confidence signal', () {
    const action = CoachAction(
      id: 'water',
      title: 'Hydrate',
      detail: 'Close the gap.',
      priority: CoachPriority.normal,
      iconKey: 'water',
    );
    const plan = DailyCoachPlan(score: 80, headline: 'Plan', actions: [action]);
    final neutral = AdvancedCoachEngine.explain(
      plan: plan,
      data: FitnessData.initial(),
    ).single;
    final learned = AdvancedCoachEngine.explain(
      plan: plan,
      data: FitnessData.initial().copyWith(
        coachRecommendationFeedback: [
          for (var index = 0; index < 3; index++)
            CoachRecommendationFeedback(
              id: '$index',
              recommendationId: 'water',
              accepted: true,
              helpful: true,
              note: '',
              recordedAt: DateTime(2026, 7, index + 1),
            ),
        ],
      ),
    ).single;

    expect(learned.personalAcceptanceRate, 1);
    expect(learned.confidencePercent, greaterThan(neutral.confidencePercent));
  });

  test('weekly coach review identifies wins and one next focus', () {
    final now = DateTime(2026, 7, 29);
    final data = FitnessData.initial().copyWith(
      logs: [
        for (var day in [25, 27, 29])
          WorkoutLog(
            templateName: 'Session',
            completedAt: DateTime(2026, 7, day),
            minutes: 45,
          ),
      ],
      recoveryChecks: [
        RecoveryCheckIn(
          sleepHours: 8,
          energy: 4,
          soreness: 2,
          stress: 2,
          recordedAt: now,
        ),
      ],
    );
    final review = AdvancedCoachEngine.weeklyReview(
      data: data,
      now: now,
      nutritionAdherence: .9,
    );

    expect(review.period, 'WEEKLY REVIEW');
    expect(review.score, greaterThan(70));
    expect(review.wins.join(' '), contains('3 completed'));
    expect(review.nextFocus, isNotEmpty);
  });

  test('monthly coach review exposes consistency gaps', () {
    final review = AdvancedCoachEngine.monthlyReview(
      data: FitnessData.initial(),
      now: DateTime(2026, 7, 29),
      nutritionAdherence: .4,
    );

    expect(review.period, 'MONTHLY REVIEW');
    expect(review.score, lessThan(30));
    expect(review.gaps.join(' '), contains('Nutrition'));
    expect(review.nextFocus, isNotEmpty);
  });

  test('goal drift detects conditioning against a strength profile', () {
    final now = DateTime(2026, 7, 29);
    final data = FitnessData.initial().copyWith(
      profile: const UserProfile(
        goal: 'Strength',
        trainingPlace: 'Gym',
        equipment: 'Full gym',
        daysPerWeek: 4,
        heightCentimeters: 180,
        weightKilograms: 80,
      ),
      cardioSessions: [
        for (var index = 0; index < 5; index++)
          CardioSessionLog(
            id: '$index',
            modality: 'Bike',
            durationMinutes: 40,
            rpe: 6,
            averageHeartRate: 140,
            targetZone: 2,
            recordedAt: now.subtract(Duration(days: index * 3)),
          ),
      ],
    );
    final drift = AdvancedCoachEngine.goalDrift(data, now: now);

    expect(drift.detected, isTrue);
    expect(drift.observedBehavior, 'Conditioning-dominant');
    expect(drift.action, contains('Confirm the goal'));
  });

  test('coach safety escalation stops severe repeated pain', () {
    final now = DateTime(2026, 7, 29);
    final data = FitnessData.initial().copyWith(
      logs: [
        WorkoutLog(
          templateName: 'Painful session',
          completedAt: now,
          minutes: 30,
          painArea: 'Knee',
          painSeverity: 5,
        ),
      ],
    );
    final safety = AdvancedCoachEngine.safetyEscalation(data, now: now);

    expect(safety.level, 3);
    expect(safety.professionalHelp, isTrue);
    expect(safety.title, 'STOP & SEEK ASSESSMENT');
    expect(safety.action, contains('Pause hard training'));
  });

  test('coach feedback survives FitnessData JSON round trip', () {
    final source = FitnessData.initial().copyWith(
      coachRecommendationFeedback: [
        CoachRecommendationFeedback(
          id: 'feedback',
          recommendationId: 'protein',
          accepted: true,
          helpful: true,
          note: 'Easy to follow.',
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );
    final restored = FitnessData.fromJson(source.toJson());

    expect(restored.coachRecommendationFeedback, hasLength(1));
    expect(restored.coachRecommendationFeedback.single.helpful, isTrue);
    expect(restored.coachRecommendationFeedback.single.note, 'Easy to follow.');
  });

  test('coach feedback persists through the local store', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();
    await store.saveCoachRecommendationFeedback(
      recommendationId: 'water',
      accepted: true,
      helpful: true,
      note: 'Useful timing.',
    );
    final restored = FitnessData.fromJson(repository.value.toJson());

    expect(
      restored.coachRecommendationFeedback.single.recommendationId,
      'water',
    );
    expect(restored.coachRecommendationFeedback.single.accepted, isTrue);
  });

  test('coach integrity removes invalid feedback records', () {
    final damaged = FitnessData.initial().copyWith(
      coachRecommendationFeedback: [
        CoachRecommendationFeedback(
          id: 'bad',
          recommendationId: '',
          accepted: false,
          helpful: false,
          note: List.filled(250, 'x').join(),
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );
    final report = DataValidationEngine.audit(damaged);
    final repaired = DataValidationEngine.repair(damaged);

    expect(
      report.issues.any((item) => item.code == 'invalid-coach-feedback'),
      isTrue,
    );
    expect(repaired.coachRecommendationFeedback, isEmpty);
  });

  test('global search discovers Advanced Coach', () {
    final results = GlobalSearchEngine.search(
      FitnessData.initial(),
      'explainable confidence rule trace feedback safety escalation',
    );

    expect(results.single.route, 'advanced-coach');
  });

  testWidgets('Advanced Coach exposes explain priorities reviews and safety', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(MaterialApp(home: AdvancedCoachPage(store: store)));
    await tester.pumpAndSettle();

    expect(find.text('ADVANCED COACH'), findsOneWidget);
    expect(find.text('EXPLAINABLE RECOMMENDATIONS'), findsOneWidget);

    await tester.tap(find.text('PRIORITIES'));
    await tester.pumpAndSettle();
    expect(find.text('COMPETING-GOAL PRIORITIES'), findsOneWidget);

    await tester.tap(find.text('REVIEWS'));
    await tester.pumpAndSettle();
    expect(find.text('COACH REVIEWS'), findsOneWidget);

    await tester.tap(find.text('SAFETY'));
    await tester.pumpAndSettle();
    expect(find.text('COACH SAFETY ESCALATION'), findsOneWidget);
  });

  test('custom analytics dashboard returns only selected metrics', () {
    final now = DateTime(2026, 7, 29);
    final data = FitnessData.initial().copyWith(
      logs: [
        WorkoutLog(
          templateName: 'Session',
          completedAt: now,
          minutes: 45,
          sets: [
            ExerciseSetLog(
              exerciseName: 'Squat',
              reps: 5,
              weightKilograms: 100,
              rir: 2,
              holdSeconds: 0,
              loggedAt: now,
            ),
          ],
        ),
      ],
      weights: [WeightEntry(kilograms: 79, recordedAt: now)],
    );
    final metrics = AnalyticsStudioEngine.customDashboard(
      data: data,
      selectedMetrics: const ['sessions', 'volume', 'bodyweight'],
      now: now,
    );

    expect(metrics.map((item) => item.id), [
      'sessions',
      'volume',
      'bodyweight',
    ]);
    expect(metrics[0].value, 1);
    expect(metrics[1].value, 500);
    expect(metrics[2].value, 79);
  });

  test('date range comparison contrasts equivalent windows', () {
    final logs = [
      WorkoutLog(
        templateName: 'Current',
        completedAt: DateTime(2026, 7, 27),
        minutes: 50,
        sessionRpe: 8,
      ),
      WorkoutLog(
        templateName: 'Previous',
        completedAt: DateTime(2026, 7, 18),
        minutes: 25,
        sessionRpe: 4,
      ),
    ];
    final comparison = AnalyticsStudioEngine.compareRanges(
      logs: logs,
      currentStart: DateTime(2026, 7, 22),
      currentEnd: DateTime(2026, 7, 30),
      previousDays: 8,
    );

    expect(comparison.current, greaterThan(comparison.previous));
    expect(comparison.changePercent, greaterThan(100));
    expect(comparison.label, 'RISING');
  });

  test('moving average supports adjustable windows', () {
    final average = AnalyticsStudioEngine.movingAverage(const [1, 3, 5, 7], 3);

    expect(average, [1, 2, 3, 5]);
    expect(
      () => AnalyticsStudioEngine.movingAverage(const [1], 0),
      throwsFormatException,
    );
  });

  test('training monotony and strain rise for repeated daily load', () {
    final now = DateTime(2026, 7, 29);
    final logs = [
      for (var offset = 0; offset < 7; offset++)
        WorkoutLog(
          templateName: 'Same load',
          completedAt: now.subtract(Duration(days: offset)),
          minutes: 30,
          sessionRpe: 6,
        ),
    ];
    final result = AnalyticsStudioEngine.monotony(logs: logs, now: now);

    expect(result.monotony, 10);
    expect(result.strain, result.weeklyLoad * 10);
    expect(result.label, 'HIGH MONOTONY');
  });

  test('volume intensity distribution creates three load buckets', () {
    final now = DateTime(2026, 7, 29);
    final data = WorkoutLog(
      templateName: 'Distribution',
      completedAt: now,
      minutes: 45,
      sets: [
        for (final weight in [50.0, 75.0, 100.0])
          ExerciseSetLog(
            exerciseName: 'Squat',
            reps: 5,
            weightKilograms: weight,
            rir: 2,
            holdSeconds: 0,
            loggedAt: now,
          ),
      ],
    );
    final result = AnalyticsStudioEngine.volumeIntensityDistribution([data]);

    expect(result.low, 1);
    expect(result.moderate, 1);
    expect(result.high, 1);
    expect(result.totalSets, 3);
  });

  test('set rep heatmap counts bodyweight and heavy work', () {
    final now = DateTime(2026, 7, 29);
    final cells = AnalyticsStudioEngine.setRepHeatmap([
      WorkoutLog(
        templateName: 'Heatmap',
        completedAt: now,
        minutes: 40,
        sets: [
          ExerciseSetLog(
            exerciseName: 'Push-up',
            reps: 12,
            weightKilograms: 0,
            rir: 2,
            holdSeconds: 0,
            loggedAt: now,
          ),
          ExerciseSetLog(
            exerciseName: 'Deadlift',
            reps: 3,
            weightKilograms: 120,
            rir: 2,
            holdSeconds: 0,
            loggedAt: now,
          ),
        ],
      ),
    ]);

    expect(
      cells
          .singleWhere(
            (item) => item.repBand == '11–15' && item.loadBand == 'BODYWEIGHT',
          )
          .count,
      1,
    );
    expect(
      cells
          .singleWhere(
            (item) => item.repBand == '1–5' && item.loadBand == 'HEAVY',
          )
          .count,
      1,
    );
  });

  test('exercise adherence funnel preserves descending stages', () {
    final now = DateTime(2026, 7, 29);
    final funnel = AnalyticsStudioEngine.adherenceFunnel(
      plannedSessions: 4,
      logs: [
        WorkoutLog(
          templateName: 'Reviewed',
          completedAt: now,
          minutes: 45,
          sessionRpe: 8,
          sets: [
            ExerciseSetLog(
              exerciseName: 'Squat',
              reps: 5,
              weightKilograms: 100,
              rir: 2,
              holdSeconds: 0,
              loggedAt: now,
            ),
          ],
        ),
        WorkoutLog(
          templateName: 'Bare log',
          completedAt: now.subtract(const Duration(days: 1)),
          minutes: 30,
        ),
      ],
      start: now.subtract(const Duration(days: 7)),
      end: now.add(const Duration(days: 1)),
    );

    expect(funnel.planned, 4);
    expect(funnel.completed, 2);
    expect(funnel.loggedSets, 1);
    expect(funnel.qualityReviewed, 1);
    expect(funnel.completionRate, .5);
  });

  test('goal forecast projects a positive e1RM trajectory', () {
    final logs = [
      for (var index = 0; index < 3; index++)
        WorkoutLog(
          templateName: 'Strength',
          completedAt: DateTime(2026, 7, 1 + index * 7),
          minutes: 45,
          sets: [
            ExerciseSetLog(
              exerciseName: 'Squat',
              reps: 5,
              weightKilograms: 80 + index * 5,
              rir: 2,
              holdSeconds: 0,
              loggedAt: DateTime(2026, 7, 1 + index * 7),
            ),
          ],
        ),
    ];
    final forecast = AnalyticsStudioEngine.forecast(
      exercise: 'Squat',
      logs: logs,
      target: 120,
    );

    expect(forecast.current, greaterThan(100));
    expect(forecast.weeklyChange, greaterThan(0));
    expect(forecast.estimatedWeeks, greaterThan(0));
    expect(forecast.status, 'ON TRAJECTORY');
  });

  test('annotation layer filters and orders the visible range', () {
    final annotations = [
      for (var day in [20, 10, 30])
        AnalyticsAnnotation(
          id: '$day',
          date: DateTime(2026, 7, day),
          category: 'Training',
          label: 'Day $day',
          note: '',
          recordedAt: DateTime(2026, 7, day),
        ),
    ];
    final result = AnalyticsStudioEngine.annotationsForRange(
      annotations: annotations,
      start: DateTime(2026, 7, 15),
      end: DateTime(2026, 8),
    );

    expect(result.map((item) => item.id), ['20', '30']);
  });

  test('analytics configuration and annotation survive JSON round trip', () {
    final source = FitnessData.initial().copyWith(
      analyticsDashboardMetrics: const ['sessions', 'duration'],
      analyticsAnnotations: [
        AnalyticsAnnotation(
          id: 'block',
          date: DateTime(2026, 7, 29),
          category: 'Training',
          label: 'New block',
          note: 'Reduced volume.',
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );
    final restored = FitnessData.fromJson(source.toJson());

    expect(restored.analyticsDashboardMetrics, ['sessions', 'duration']);
    expect(restored.analyticsAnnotations.single.label, 'New block');
  });

  test('analytics studio settings persist through the local store', () async {
    final repository = MemoryRepository();
    final store = FitnessStore(repository);
    await store.load();
    await store.setAnalyticsDashboardMetrics(const ['volume', 'set-count']);
    await store.saveAnalyticsAnnotation(
      date: DateTime(2026, 7, 29),
      category: 'Life',
      label: 'Travel day',
      note: 'Long flight.',
    );

    expect(store.analyticsDashboardMetrics, ['volume', 'set-count']);
    expect(store.analyticsAnnotations.single.category, 'Life');
    expect(repository.value.analyticsAnnotations, hasLength(1));
  });

  test('analytics integrity repairs metrics and malformed annotations', () {
    final damaged = FitnessData.initial().copyWith(
      analyticsDashboardMetrics: const ['unknown', 'unknown'],
      analyticsAnnotations: [
        AnalyticsAnnotation(
          id: 'bad',
          date: DateTime(2026, 7, 29),
          category: 'Unknown',
          label: '',
          note: '',
          recordedAt: DateTime(2026, 7, 29),
        ),
      ],
    );
    final report = DataValidationEngine.audit(damaged);
    final repaired = DataValidationEngine.repair(damaged);

    expect(
      report.issues.any((item) => item.code == 'invalid-analytics-dashboard'),
      isTrue,
    );
    expect(
      report.issues.any((item) => item.code == 'invalid-analytics-annotation'),
      isTrue,
    );
    expect(repaired.analyticsDashboardMetrics, isNotEmpty);
    expect(repaired.analyticsAnnotations, isEmpty);
  });

  test('global search discovers Analytics Studio', () {
    final results = GlobalSearchEngine.search(
      FitnessData.initial(),
      'monotony strain set rep heatmap adherence forecast annotation',
    );

    expect(results.single.route, 'analytics-studio');
  });

  testWidgets('Analytics Studio exposes dashboard load sets and forecast', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(
      MaterialApp(home: AnalyticsStudioPage(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('ANALYTICS STUDIO'), findsOneWidget);
    expect(find.text('CUSTOM METRIC DASHBOARD'), findsOneWidget);

    await tester.tap(find.text('LOAD'));
    await tester.pumpAndSettle();
    expect(find.text('MONOTONY & STRAIN'), findsOneWidget);

    await tester.tap(find.text('SETS'));
    await tester.pumpAndSettle();
    expect(find.text('VOLUME–INTENSITY DISTRIBUTION'), findsOneWidget);

    await tester.tap(find.text('FORECAST'));
    await tester.pumpAndSettle();
    expect(find.text('GOAL PROGRESS FORECAST'), findsOneWidget);
  });

  test(
    'reports studio produces honest local nutrition and recovery reports',
    () {
      final now = DateTime(2026, 8, 1, 12);
      final data = FitnessData.initial().copyWith(
        meals: [
          MealEntry(
            name: 'Lunch',
            calories: 700,
            proteinGrams: 45,
            carbohydrateGrams: 70,
            fatGrams: 20,
            fiberGrams: 8,
            sodiumMilligrams: 400,
            loggedAt: now.subtract(const Duration(days: 1)),
          ),
        ],
        recoveryChecks: [
          RecoveryCheckIn(
            sleepHours: 7.5,
            energy: 4,
            soreness: 2,
            stress: 2,
            recordedAt: now.subtract(const Duration(days: 1)),
          ),
        ],
      );

      final nutrition = ReportsStudioEngine.build(
        data: data,
        kind: PhoenixReportKind.nutrition,
        now: now,
      );
      final recovery = ReportsStudioEngine.build(
        data: data,
        kind: PhoenixReportKind.recovery,
        now: now,
      );

      expect(nutrition.metrics.first.value, '1/7');
      expect(nutrition.plainText, contains('Generated locally by Phoenix.'));
      expect(recovery.metrics.first.value, '1/7');
      expect(recovery.metrics[1].value, '7.5 h');
    },
  );

  testWidgets('Reports Studio composes and copies a local report', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(MaterialApp(home: ReportsStudioPage(store: store)));
    await tester.pumpAndSettle();

    expect(find.text('REPORTS STUDIO'), findsOneWidget);
    expect(find.text('CUSTOM REPORT COMPOSER'), findsOneWidget);
    expect(find.text('WEEKLY ATHLETE REPORT'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('COPY REPORT'),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('COPY REPORT'));
    await tester.pump();
    expect(find.text('COPY REPORT'), findsOneWidget);
  });

  test('wearable intelligence uses personal medians and reports quality', () {
    final now = DateTime(2026, 8, 7, 12);
    final data = FitnessData.initial().copyWith(
      wearableSummaries: [
        for (var day = 0; day < 14; day++)
          WearableDailySummary(
            id: 'wearable-$day',
            day: now.subtract(Duration(days: day)),
            source: day.isEven ? 'Health Connect' : 'CSV',
            steps: day == 0 ? 3000 : 8000,
            restingHeartRate: 58,
            sleepMinutes: 450,
          ),
      ],
    );

    final report = AdvancedFeaturePackEngine.wearable(data, now: now);

    expect(report.stepsBaseline, 8000);
    expect(report.sleepMinutesBaseline, 450);
    expect(report.qualityScore, 100);
    expect(report.missingDays, 0);
    expect(report.sourceCounts, {'Health Connect': 7, 'CSV': 7});
    expect(report.readinessContribution, greaterThan(50));
    expect(report.hrvAvailable, isFalse);
  });

  test(
    'athlete progress derives XP levels and earned badges from local data',
    () {
      final now = DateTime(2026, 8, 7);
      final data = FitnessData.initial().copyWith(
        logs: [
          for (var index = 0; index < 10; index++)
            WorkoutLog(
              templateName: 'Strength',
              completedAt: now.subtract(Duration(days: index)),
              minutes: 40,
              sets: [
                ExerciseSetLog(
                  exerciseName: 'Squat',
                  reps: 5,
                  weightKilograms: 80,
                  rir: 2,
                  holdSeconds: 0,
                  loggedAt: now.subtract(Duration(days: index)),
                ),
              ],
            ),
        ],
        skillAssessments: [
          SkillAssessmentResult(
            id: 'skill-1',
            skillId: 'pull-up',
            value: 60,
            unit: 'seconds',
            level: 5,
            recordedAt: now,
          ),
        ],
      );

      final progress = AdvancedFeaturePackEngine.athleteProgress(data);

      expect(progress.experiencePoints, 1090);
      expect(progress.level, 4);
      expect(progress.badges, containsAll(['First Session', 'Consistency 10']));
      expect(progress.badges, contains('Skill Builder'));
      expect(progress.rarity['Skill Builder'], 'epic');
    },
  );

  test(
    'challenge builder enforces safety limits and measures local progress',
    () {
      expect(
        () => AdvancedFeaturePackEngine.customChallenge(
          title: 'Unsafe steps',
          metric: 'steps',
          target: 400000,
          days: 14,
        ),
        throwsFormatException,
      );
      final now = DateTime(2026, 8, 7);
      final challenge = AdvancedFeaturePackEngine.customChallenge(
        title: 'Steady steps',
        metric: 'steps',
        target: 10000,
        days: 7,
      );
      final data = FitnessData.initial().copyWith(
        wearableSummaries: [
          WearableDailySummary(
            id: 'one',
            day: now,
            source: 'manual',
            steps: 6000,
          ),
          WearableDailySummary(
            id: 'two',
            day: now.subtract(const Duration(days: 1)),
            source: 'manual',
            steps: 5000,
          ),
        ],
      );

      final progress = AdvancedFeaturePackEngine.challengeProgress(
        challenge,
        data,
        now: now,
      );

      expect(progress.current, 11000);
      expect(progress.ratio, 1);
      expect(progress.completed, isTrue);
      expect(progress.activeDays, hasLength(2));
    },
  );

  test('advanced logging completeness exposes present and missing fields', () {
    final full = AdvancedFeaturePackEngine.loggingCompleteness(
      ExerciseSetLog(
        exerciseName: 'Squat',
        reps: 5,
        weightKilograms: 80,
        rir: 2,
        holdSeconds: 0,
        loggedAt: DateTime(2026, 8, 7),
        setRpe: 8,
        velocityNote: 'fast',
        techniqueChecks: const ['depth', 'bracing'],
      ),
    );
    final sparse = AdvancedFeaturePackEngine.loggingCompleteness(
      ExerciseSetLog(
        exerciseName: 'Plank',
        reps: 0,
        weightKilograms: 0,
        rir: -1,
        holdSeconds: 0,
        loggedAt: DateTime(2026, 8, 7),
      ),
    );

    expect(full.score, 100);
    expect(full.missing, isEmpty);
    expect(sparse.score, lessThan(50));
    expect(sparse.missing, contains('technique'));
  });

  test('month calendar combines plans completions and deload markers', () {
    final day = DateTime(2026, 8, 7);
    final data = FitnessData.initial().copyWith(
      dateAssignments: {'2026-08-07': 'iron-hybrid'},
      logs: [
        WorkoutLog(templateName: 'IRON HYBRID', completedAt: day, minutes: 45),
      ],
    );

    final calendar = AdvancedFeaturePackEngine.monthCalendar(data, month: day);
    final summary = calendar.singleWhere((item) => item.day.day == 7);

    expect(calendar, hasLength(31));
    expect(summary.planned, isNotEmpty);
    expect(summary.completed, ['IRON HYBRID']);
    expect(calendar.any((item) => item.isDeload), isTrue);
  });

  test('interval engine advances countdown phases rounds and completion', () {
    final timer = IntervalTimerEngine.custom(
      name: 'Fast Test',
      rounds: 2,
      segments: const [
        TimerSegment(label: 'WORK', seconds: 10),
        TimerSegment(label: 'REST', seconds: 5),
      ],
    );

    expect(
      IntervalTimerEngine.snapshot(timer, Duration.zero).phase,
      'GET READY',
    );
    final first = IntervalTimerEngine.snapshot(
      timer,
      const Duration(seconds: 3),
    );
    expect(first.phase, 'WORK');
    expect(first.round, 1);
    expect(first.remainingSeconds, 10);
    final second = IntervalTimerEngine.snapshot(
      timer,
      const Duration(seconds: 18),
    );
    expect(second.phase, 'WORK');
    expect(second.round, 2);
    expect(
      IntervalTimerEngine.snapshot(
        timer,
        const Duration(seconds: 33),
      ).isComplete,
      isTrue,
    );
  });

  test('interval builder rejects unsafe duration and invalid segments', () {
    expect(
      () => IntervalTimerEngine.custom(
        name: 'Too long',
        rounds: 100,
        segments: const [TimerSegment(label: 'WORK', seconds: 3600)],
      ),
      throwsFormatException,
    );
    expect(
      () => IntervalTimerEngine.custom(
        name: 'Bad segment',
        rounds: 1,
        segments: const [TimerSegment(label: '', seconds: 10)],
      ),
      throwsFormatException,
    );
    expect(IntervalTimerEngine.formatSeconds(125), '2:05');
  });

  testWidgets('Athlete Intelligence exposes five evidence-based views', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(
      MaterialApp(home: AdvancedFeaturePackPage(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('ATHLETE INTELLIGENCE'), findsOneWidget);
    expect(find.text('WEARABLE QUALITY & READINESS'), findsOneWidget);
    await tester.tap(find.text('PROGRESS'));
    await tester.pumpAndSettle();
    expect(find.text('LOCAL XP & BADGES'), findsOneWidget);
    await tester.tap(find.text('ASSESSMENT'));
    await tester.pumpAndSettle();
    expect(find.text('MODULAR ONBOARDING ASSESSMENT'), findsOneWidget);
  });

  testWidgets('Interval Timer Lab adds independent preset timers', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(MaterialApp(home: IntervalTimerPage(store: store)));
    await tester.pumpAndSettle();

    expect(find.text('INTERVAL TIMER LAB'), findsOneWidget);
    expect(find.text('MULTI-TIMER WORKSPACE'), findsOneWidget);
    await tester.tap(find.text('TABATA 8'));
    await tester.pump();
    expect(find.text('TABATA 8'), findsNWidgets(2));
    expect(find.text('GET READY'), findsOneWidget);
  });

  test('symptom assessment stops red flags and bounds modifications', () {
    final redFlag = SafetyAdaptationEngine.assessSymptom(
      area: 'knee',
      severity: 8,
      sudden: true,
      swelling: true,
      numbness: false,
      worsening: true,
      toleratesIsometric: false,
      painFreeDays: 0,
    );
    final moderate = SafetyAdaptationEngine.assessSymptom(
      area: 'shoulder',
      severity: 4,
      sudden: false,
      swelling: false,
      numbness: false,
      worsening: false,
      toleratesIsometric: true,
      painFreeDays: 3,
    );

    expect(redFlag.decision, TrainingDecision.stopAndSeekCare);
    expect(redFlag.loadMultiplier, 0);
    expect(redFlag.careReminder, contains('qualified medical care'));
    expect(moderate.decision, TrainingDecision.modify);
    expect(moderate.loadMultiplier, inInclusiveRange(.5, .7));
    expect(
      moderate.fallbacks,
      contains('short pain-free isometric at low effort'),
    );
    expect(
      moderate.exportNote(area: 'shoulder', severity: 4),
      contains('not a diagnosis'),
    );
  });

  test('pain timeline detects worsening recurrence risk from session logs', () {
    final data = FitnessData.initial().copyWith(
      logs: [
        for (var index = 0; index < 4; index++)
          WorkoutLog(
            templateName: 'Return',
            completedAt: DateTime(2026, 8, 1 + index),
            minutes: 20,
            painArea: 'knee',
            painSeverity: 2 + index,
          ),
      ],
    );

    final trend = SafetyAdaptationEngine.painTrend(data, area: 'knee');

    expect(trend.values, [2, 3, 4, 5]);
    expect(trend.direction, 'worsening');
    expect(trend.recurrenceRisk, isTrue);
  });

  test('periodization plans contain bounded ramps deloads and taper', () {
    final linear = SafetyAdaptationEngine.periodization(
      style: 'linear',
      weeks: 8,
    );
    final block = SafetyAdaptationEngine.periodization(
      style: 'block',
      weeks: 12,
    );

    expect(linear.phases.last.name, 'Deload');
    expect(linear.phases.last.volumeMultiplier, lessThan(.7));
    expect(block.phases.map((item) => item.name), [
      'Accumulation',
      'Intensification',
      'Realization / taper',
    ]);
    expect(block.deloadCriteria, hasLength(4));
    expect(
      () => SafetyAdaptationEngine.periodization(
        style: 'linear',
        weeks: 8,
        volumeRamp: .3,
      ),
      throwsFormatException,
    );
  });

  test('performance battery scores eight tests and schedules retest', () {
    final testedAt = DateTime(2026, 8, 7);
    final battery = SafetyAdaptationEngine.performanceBattery(
      values: const {
        'push-up': 40,
        'pull-up': 6,
        'squat': 60,
        'plank': 180,
        'broad-jump': 240,
        'vertical-jump': 60,
        'cooper': 2800,
        'step-recovery': 45,
      },
      testedAt: testedAt,
    );

    expect(battery.results, hasLength(8));
    expect(battery.radar['strength'], 50);
    expect(battery.lowestCategory, 'strength');
    expect(battery.nextTestDate, testedAt.add(const Duration(days: 42)));
    expect(battery.results.every((item) => item.stopRule.isNotEmpty), isTrue);
  });

  test('sport and adaptive plans respect season travel and life stage', () {
    final sport = SafetyAdaptationEngine.sportProfile(
      'football',
      inSeason: true,
      daysToCompetition: 5,
    );
    final travel = SafetyAdaptationEngine.adaptivePlan(
      context: 'hotel',
      availableMinutes: 15,
      lowImpact: true,
      balanceSupport: true,
      fatigueLimited: true,
      lifeStage: 'older-adult',
    );
    final pregnancy = SafetyAdaptationEngine.adaptivePlan(
      context: 'home',
      lifeStage: 'pregnancy',
    );

    expect(sport.inSeasonVolumeMultiplier, .65);
    expect(
      sport.competitionWeek,
      contains('No novel drills or exhaustive conditioning.'),
    );
    expect(travel.minutes, 15);
    expect(travel.streakProtected, isTrue);
    expect(travel.exercises, contains('Supported hip hinge'));
    expect(
      pregnancy.safetyChecklist.join(' '),
      contains('qualified healthcare professional'),
    );
  });

  testWidgets('Safety and Adaptation exposes five guarded planning views', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(
      MaterialApp(home: SafetyAdaptationPage(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('SAFETY & ADAPTATION'), findsOneWidget);
    expect(find.text('SYMPTOM-AWARE TRAINING BOUNDARY'), findsOneWidget);
    expect(find.text('PROCEED'), findsOneWidget);
    await tester.tap(find.text('PHASES'));
    await tester.pumpAndSettle();
    expect(find.text('PERIODIZATION & TAPER'), findsOneWidget);
    await tester.tap(find.text('ADAPTIVE'));
    await tester.pumpAndSettle();
    expect(find.text('TRAVEL, ADAPTIVE & LIFE-STAGE PLAN'), findsOneWidget);
  });

  test(
    'dashboard configuration reorders backs up restores and rejects duplicates',
    () {
      final preset = OperationalReadinessEngine.dashboardPreset('strength');
      final reordered = OperationalReadinessEngine.reorderDashboard(
        preset,
        preset.cards.reversed.toList(),
        compact: true,
      );
      final restored = OperationalReadinessEngine.importDashboard(
        OperationalReadinessEngine.exportDashboard(reordered),
      );

      expect(restored.cards, reordered.cards);
      expect(restored.compact, isTrue);
      expect(restored.preset, 'custom');
      expect(
        () => OperationalReadinessEngine.reorderDashboard(preset, const [
          'readiness',
          'readiness',
        ]),
        throwsFormatException,
      );
    },
  );

  test('quiet hours and snooze move reminders into an allowed window', () {
    const policy = ReminderPolicy();
    final late = DateTime(2026, 8, 7, 23, 30);

    expect(OperationalReadinessEngine.isQuiet(late, policy), isTrue);
    expect(
      OperationalReadinessEngine.snooze(late, minutes: 30, policy: policy),
      DateTime(2026, 8, 8, 7),
    );
    expect(
      () => OperationalReadinessEngine.snooze(late, minutes: 2, policy: policy),
      throwsFormatException,
    );
  });

  test('smart reminders use context and enforce daily fatigue protection', () {
    final now = DateTime(2026, 8, 7, 12);
    final data = FitnessData.initial().copyWith(
      dateAssignments: {'2026-08-07': 'iron-hybrid'},
    );
    final reminders = OperationalReadinessEngine.smartReminders(
      data: data,
      now: now,
      policy: const ReminderPolicy(maximumPerDay: 3),
    );
    final exhausted = OperationalReadinessEngine.smartReminders(
      data: data,
      now: now,
      policy: const ReminderPolicy(maximumPerDay: 2),
      history: [
        ReminderDelivery(kind: 'meal', scheduledAt: now, status: 'delivered'),
        ReminderDelivery(
          kind: 'hydration',
          scheduledAt: now,
          status: 'delivered',
        ),
      ],
    );

    expect(reminders.first.kind, 'workout');
    expect(reminders, hasLength(3));
    expect(
      reminders.every(
        (item) => !OperationalReadinessEngine.isQuiet(
          item.scheduledAt,
          const ReminderPolicy(maximumPerDay: 3),
        ),
      ),
      isTrue,
    );
    expect(exhausted, isEmpty);
  });

  test('locale catalog formats dates decimals and language backups', () {
    final german = OperationalReadinessEngine.localeReadiness('de');
    final spanish = OperationalReadinessEngine.localeReadiness('es');

    expect(german.coverage, 100);
    expect(spanish.coverage, 100);
    expect(OperationalReadinessEngine.localized('today', 'de'), 'Heute');
    expect(
      OperationalReadinessEngine.formatDate(DateTime(2026, 3, 7), 'de'),
      '7 Mär 2026',
    );
    expect(OperationalReadinessEngine.parseDecimal('1.234,5', 'de'), 1234.5);
    expect(
      OperationalReadinessEngine.importLanguage(
        OperationalReadinessEngine.exportLanguage('es'),
      ),
      'es',
    );
  });

  test('performance budgets report measured regressions without telemetry', () {
    final pass = OperationalReadinessEngine.performanceBudget(const {
      'startup-ms': 900,
      'database-query-ms': 40,
      'json-serialization-ms': 20,
      'chart-frame-ms': 12,
      'rebuild-count': 10,
      'web-bundle-mb': 8,
      'image-memory-mb': 32,
    });
    final regression = OperationalReadinessEngine.performanceBudget(const {
      'startup-ms': 1700,
      'chart-frame-ms': 30,
    });

    expect(pass.passes, isTrue);
    expect(regression.passes, isFalse);
    expect(regression.violations, hasLength(2));
  });

  test('duplicate-event reconciliation is deterministic and checksummed', () {
    final workout = WorkoutLog(
      templateName: 'Strength',
      completedAt: DateTime(2026, 8, 7),
      minutes: 40,
    );
    final meal = MealEntry(
      name: 'Meal',
      calories: 500,
      proteinGrams: 30,
      carbohydrateGrams: 60,
      fatGrams: 15,
      loggedAt: DateTime(2026, 8, 7, 13),
    );
    final data = FitnessData.initial().copyWith(
      logs: [workout, workout],
      meals: [meal, meal],
    );

    final result = OperationalReadinessEngine.reconcileDuplicates(data);

    expect(result.data.logs, hasLength(1));
    expect(result.data.meals, hasLength(1));
    expect(result.totalRemoved, 2);
    expect(result.checksum, hasLength(64));
    expect(result.checksum, OperationalReadinessEngine.checksum(result.data));
  });

  test(
    'duplicate reconciliation persists and supports one-step undo',
    () async {
      final repository = MemoryRepository();
      final workout = WorkoutLog(
        templateName: 'Strength',
        completedAt: DateTime(2026, 8, 7),
        minutes: 40,
      );
      repository.value = FitnessData.initial().copyWith(
        logs: [workout, workout],
      );
      final store = FitnessStore(repository);
      await store.load();

      final result = await store.reconcileDuplicateEvents();

      expect(result.totalRemoved, 1);
      expect(repository.value.logs, hasLength(1));
      expect(store.canUndo, isTrue);
      expect(await store.undoLastMutation(), isTrue);
      expect(repository.value.logs, hasLength(2));
    },
  );

  testWidgets('Operations Studio exposes five local operational controls', (
    tester,
  ) async {
    final store = FitnessStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(
      MaterialApp(home: OperationsStudioPage(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('OPERATIONS STUDIO'), findsOneWidget);
    expect(find.text('CUSTOM DASHBOARD LAYOUT'), findsOneWidget);
    await tester.tap(find.text('REMINDERS'));
    await tester.pumpAndSettle();
    expect(find.text('REMINDER FATIGUE PROTECTION'), findsOneWidget);
    await tester.tap(find.text('LOCALES'));
    await tester.pumpAndSettle();
    expect(find.text('LOCALE READINESS'), findsOneWidget);
    expect(find.textContaining('Heute'), findsOneWidget);
    await tester.tap(find.text('DATA'));
    await tester.pumpAndSettle();
    expect(find.text('DATA RELIABILITY V4'), findsOneWidget);
  });

  testWidgets('desktop shell uses navigation rail and Ctrl-number shortcuts', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = MemoryRepository()
      ..value = FitnessData.initial().copyWith(
        profile: const UserProfile(
          goal: 'Strength',
          trainingPlace: 'Home',
          equipment: 'Bodyweight',
          daysPerWeek: 3,
          heightCentimeters: 180,
          weightKilograms: 80,
        ),
      );
    final store = FitnessStore(repository);
    await store.load();
    await tester.pumpWidget(MaterialApp(home: PhoenixShell(store: store)));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.byType(WorkoutsPage), findsOneWidget);
  });

  testWidgets(
    'responsive shell remains usable across phone and tablet widths',
    (tester) async {
      final repository = MemoryRepository()
        ..value = FitnessData.initial().copyWith(
          profile: const UserProfile(
            goal: 'Strength',
            trainingPlace: 'Home',
            equipment: 'Bodyweight',
            daysPerWeek: 3,
            heightCentimeters: 180,
            weightKilograms: 80,
          ),
        );
      final store = FitnessStore(repository);
      await store.load();
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (final size in const [
        Size(360, 800),
        Size(600, 900),
        Size(899, 700),
      ]) {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(MaterialApp(home: PhoenixShell(store: store)));
        await tester.pumpAndSettle();

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(
          tester.takeException(),
          isNull,
          reason: 'Unexpected layout exception at ${size.width}×${size.height}',
        );
      }
    },
  );

  testWidgets('primary shell controls expose accessible semantic labels', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final repository = MemoryRepository()
      ..value = FitnessData.initial().copyWith(
        profile: const UserProfile(
          goal: 'Strength',
          trainingPlace: 'Home',
          equipment: 'Bodyweight',
          daysPerWeek: 3,
          heightCentimeters: 180,
          weightKilograms: 80,
        ),
      );
    final store = FitnessStore(repository);
    await store.load();
    await tester.pumpWidget(MaterialApp(home: PhoenixShell(store: store)));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Search'), findsOneWidget);
    expect(find.bySemanticsLabel('Change colors and theme'), findsOneWidget);
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Training'), findsWidgets);
    expect(find.text('More'), findsWidgets);
    semantics.dispose();
  });

  testWidgets('the simple shell keeps advanced features under More', (
    tester,
  ) async {
    final repository = MemoryRepository()
      ..value = FitnessData.initial().copyWith(
        profile: const UserProfile(
          goal: 'Strength',
          trainingPlace: 'Home',
          equipment: 'Bodyweight',
          daysPerWeek: 3,
          heightCentimeters: 180,
          weightKilograms: 80,
        ),
      );
    final store = FitnessStore(repository);
    await store.load();
    await tester.pumpWidget(MaterialApp(home: PhoenixShell(store: store)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    expect(find.text('My progress'), findsOneWidget);
    expect(find.text('Music & photos'), findsOneWidget);
    expect(find.text('Colors & appearance'), findsOneWidget);
    expect(find.text('All tools'), findsOneWidget);
    expect(find.text('Profile, data & settings'), findsOneWidget);
  });

  test('every historical storage version reaches the current schema', () {
    final source = FitnessData.initial().toJson();
    for (
      var version = 1;
      version <= StorageMigrationEngine.currentVersion;
      version++
    ) {
      final result = StorageMigrationEngine.migrate(
        source,
        fromVersion: version,
      );
      expect(result.toVersion, StorageMigrationEngine.currentVersion);
      expect(
        result.appliedSteps,
        hasLength(StorageMigrationEngine.currentVersion - version),
      );
      expect(FitnessData.fromJson(result.json), isA<FitnessData>());
    }
  });

  test('malformed structured imports fail closed across fuzz corpus', () {
    const invalidWorkoutCsv = [
      '',
      'date,workout,exercise,reps,weight',
      'date,workout,exercise,reps,weight\nnot-a-date,A,B,8,20',
      'date,workout,exercise,reps,weight\n2026-08-07,A,B,9999,20',
      'date,workout\n2026-08-07,A',
      'date,workout,exercise,reps,weight\n2026-08-07,A,B,-1,20',
    ];
    const invalidNutritionCsv = [
      '',
      'date,name,calories,protein,carbs,fat',
      'date,name,calories,protein,carbs,fat\nbad,Lunch,500,20,30,10',
      'date,name,calories,protein,carbs,fat\n2026-08-07,Lunch,50000,20,30,10',
      'date,name,calories\n2026-08-07,Lunch,500',
    ];
    const invalidGpx = [
      '',
      '<gpx><trkpt lat="91" lon="0"></trkpt><trkpt lat="0" lon="0"></trkpt></gpx>',
      '<gpx><trkpt lat="0" lon="181"></trkpt><trkpt lat="0" lon="0"></trkpt></gpx>',
      '<gpx><trkpt lat="0" lon="0"></trkpt></gpx>',
      '<gpx>not xml</gpx>',
    ];

    for (final source in invalidWorkoutCsv) {
      expect(
        () => StructuredImportExportEngine.parseWorkoutCsv(source),
        throwsFormatException,
      );
    }
    for (final source in invalidNutritionCsv) {
      expect(
        () => StructuredImportExportEngine.parseNutritionCsv(source),
        throwsFormatException,
      );
    }
    for (final source in invalidGpx) {
      expect(
        () => StructuredImportExportEngine.parseGpx(source),
        throwsFormatException,
      );
    }
  });

  test('PWA manifest and service worker preserve offline import contracts', () {
    final manifest =
        jsonDecode(File('web/manifest.json').readAsStringSync())
            as Map<String, dynamic>;
    final handlers = manifest['file_handlers'] as List<dynamic>;
    final accept =
        (handlers.single as Map<String, dynamic>)['accept']
            as Map<String, dynamic>;
    final worker = File('web/phoenix-service-worker.js').readAsStringSync();

    expect(manifest['display'], 'standalone');
    expect(manifest['prefer_related_applications'], isFalse);
    expect(manifest['share_target'], isA<Map<String, dynamic>>());
    expect(
      accept.keys,
      containsAll(['application/json', 'text/csv', 'application/octet-stream']),
    );
    expect(accept['application/octet-stream'], contains('.phxsync'));
    expect(worker, contains('CACHE_VERSION'));
    expect(worker, contains('offline'));
  });

  test(
    'German and Spanish shell translations are reviewed and deterministic',
    () {
      const german = PhoenixL10n(Locale('de'));
      const spanish = PhoenixL10n(Locale('es'));
      const english = PhoenixL10n(Locale('en'));

      expect(german.text('Αρχική', 'Home'), 'Start');
      expect(spanish.text('Διατροφή', 'Nutrition'), 'Nutrición');
      expect(english.text('Αποθήκευση', 'Save'), 'Save');
      expect(
        german.text('Άγνωστο', 'Feature-specific copy'),
        'Feature-specific copy',
      );
      expect(
        PhoenixTranslations.translatedCount('de'),
        PhoenixTranslations.catalog.length,
      );
      expect(
        PhoenixTranslations.translatedCount('es'),
        PhoenixTranslations.catalog.length,
      );
    },
  );
}
