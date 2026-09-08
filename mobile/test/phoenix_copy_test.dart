import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix/src/models/fitness_models.dart';
import 'package:phoenix/src/phoenix_copy.dart';
import 'package:phoenix/src/phoenix_l10n.dart';

void main() {
  const greek = PhoenixL10n(Locale('el'));
  const english = PhoenixL10n(Locale('en'));

  test('legacy workout names receive clear Greek display labels', () {
    final template = FitnessData.initial().templates.first;

    expect(
      PhoenixCopy.workoutName(greek, template),
      'Δύναμη με βάρη — Όλο το σώμα',
    );
    expect(
      PhoenixCopy.workoutName(greek, template, short: true),
      'Όλο το σώμα με βάρη',
    );
    expect(
      PhoenixCopy.workoutName(english, template),
      'Dumbbell strength — Full body',
    );
  });

  test('legacy exercise names are translated only for display', () {
    expect(
      PhoenixCopy.exerciseName(greek, 'Goblet squat'),
      'Κάθισμα με αλτήρα μπροστά',
    );
    expect(
      PhoenixCopy.exerciseName(greek, 'Farmer carry'),
      'Περπάτημα με βάρη',
    );
    expect(
      PhoenixCopy.exerciseName(greek, 'Pike push-ups'),
      'Κάμψεις ώμων με τη λεκάνη ψηλά',
    );
    expect(
      PhoenixCopy.exerciseName(greek, 'Προσωπική άσκηση'),
      'Προσωπική άσκηση',
    );
  });

  test('built-in meal presets receive natural Greek labels', () {
    final presets = FitnessData.initial().mealPresets;

    expect(
      PhoenixCopy.mealPresetName(greek, presets.first),
      'Δυναμωτικό πρωινό',
    );
    expect(
      PhoenixCopy.mealPresetName(greek, presets.last),
      'Μπολ αποκατάστασης',
    );
  });

  test('Greek counters use the correct singular and plural forms', () {
    expect(PhoenixCopy.exerciseCount(greek, 1), '1 άσκηση');
    expect(PhoenixCopy.exerciseCount(greek, 4), '4 ασκήσεις');
    expect(PhoenixCopy.setCount(greek, 1), '1 σετ');
    expect(PhoenixCopy.setCount(greek, 4), '4 σετ');
    expect(PhoenixCopy.setCount(english, 1), '1 set');
    expect(PhoenixCopy.setCount(english, 4), '4 sets');
    expect(PhoenixCopy.minuteCount(greek, 1), '1 λεπτό');
    expect(PhoenixCopy.minuteCount(greek, 20), '20 λεπτά');
    expect(
      PhoenixCopy.weeklyWorkoutProgress(greek, completed: 0, target: 1),
      '0 από 1 προπόνηση αυτή την εβδομάδα',
    );
    expect(
      PhoenixCopy.weeklyWorkoutProgress(greek, completed: 1, target: 3),
      '1 από 3 προπονήσεις αυτή την εβδομάδα',
    );
  });

  test('compact exercise targets remain grammatical for singular values', () {
    const repetitions = ExercisePrescription(
      workingSets: 1,
      minReps: 1,
      maxReps: 1,
      targetRir: 1,
      restSeconds: 60,
      tempo: '2–1–2',
    );
    const timed = ExercisePrescription(
      workingSets: 1,
      minReps: 0,
      maxReps: 0,
      targetRir: 1,
      restSeconds: 60,
      tempo: '2–1–2',
      minHoldSeconds: 1,
      maxHoldSeconds: 1,
    );

    expect(
      PhoenixCopy.compactExerciseTarget(greek, repetitions),
      '1 σετ • 1 επανάληψη',
    );
    expect(
      PhoenixCopy.compactExerciseTarget(greek, timed),
      '1 σετ • 1 δευτερόλεπτο',
    );
  });
}
