import 'local_notification_schedule.dart';

Future<bool> initializeLocalNotifications() async => false;

Future<bool> requestLocalNotificationPermission() async => false;

Future<bool> showLocalWorkoutNotification({
  required String title,
  required String body,
}) async => false;

Future<bool> syncLocalWorkoutNotifications({
  required List<LocalWorkoutNotificationSchedule> reminders,
}) async => false;

Future<bool> installPhoenixPwa() async => false;
