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
}
