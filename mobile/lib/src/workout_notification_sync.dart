import 'local_notification_bridge.dart';
import 'local_notification_schedule.dart';
import 'state/fitness_store.dart';

Future<bool> syncPhoenixWorkoutNotifications(FitnessStore store) {
  final schedules = <LocalWorkoutNotificationSchedule>[
    for (final reminder in store.workoutReminders)
      LocalWorkoutNotificationSchedule(
        id: reminder.id,
        weekday: reminder.weekday,
        minutesSinceMidnight: reminder.minutesSinceMidnight,
        title: 'Phoenix workout reminder',
        body:
            store.data.templates
                .where((item) => item.id == reminder.templateId)
                .map((item) => item.name)
                .firstOrNull ??
            'Η σημερινή αποστολή σε περιμένει.',
        enabled: reminder.enabled,
      ),
  ];
  return syncLocalWorkoutNotifications(reminders: schedules);
}
