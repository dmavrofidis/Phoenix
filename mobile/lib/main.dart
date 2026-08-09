import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/data/drift_fitness_repository.dart';
import 'src/data/local_fitness_repository.dart';
import 'src/local_notification_bridge.dart';
import 'src/state/fitness_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = FitnessStore(
    DriftFitnessRepository(legacyRepository: LocalFitnessRepository()),
  );
  await store.load();
  for (final reminder in store.dueWorkoutReminders(DateTime.now())) {
    final templateName = store.data.templates
        .where((item) => item.id == reminder.templateId)
        .map((item) => item.name)
        .firstOrNull;
    await showLocalWorkoutNotification(
      title: 'Phoenix workout reminder',
      body: templateName ?? 'Η σημερινή αποστολή σε περιμένει.',
    );
  }
  if (Uri.base.queryParameters['preview'] == '1') {
    store.previewWithoutProfile();
  }
  runApp(PhoenixApp(store: store));
}
