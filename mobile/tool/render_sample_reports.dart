import 'dart:io';

import 'package:phoenix/src/coaching_report_engine.dart';
import 'package:phoenix/src/models/fitness_models.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.length != 1) {
    stderr.writeln('Usage: dart run tool/render_sample_reports.dart <output>');
    exitCode = 64;
    return;
  }
  final output = Directory(arguments.single)..createSync(recursive: true);
  final data = FitnessData.initial().copyWith(
    profile: const UserProfile(
      goal: 'Μυϊκή ανάπτυξη και δύναμη',
      trainingPlace: 'Γυμναστήριο',
      equipment: 'Πλήρης εξοπλισμός',
      daysPerWeek: 4,
      heightCentimeters: 180,
      weightKilograms: 82,
      age: 30,
      experienceLevel: 'Προχωρημένος',
      sessionMinutes: 60,
    ),
    weights: [WeightEntry(kilograms: 82, recordedAt: DateTime(2026, 7, 29))],
  );
  final report = await CoachingReportEngine.buildCoachingReport(
    data,
    generatedAt: DateTime(2026, 7, 29),
  );
  final sheet = await CoachingReportEngine.buildWorkoutSheet(
    data.templates.first,
  );
  File(
    '${output.path}/phoenix-coaching-report-sample.pdf',
  ).writeAsBytesSync(report);
  File(
    '${output.path}/phoenix-workout-sheet-sample.pdf',
  ).writeAsBytesSync(sheet);
}
