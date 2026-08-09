import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'local_notification_schedule.dart';

final FlutterLocalNotificationsPlugin _notifications =
    FlutterLocalNotificationsPlugin();

bool _initialized = false;
bool _timezoneReady = false;

const _notificationDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    'phoenix_workout_reminders',
    'Workout reminders',
    channelDescription: 'Private weekly Phoenix workout reminders',
    importance: Importance.high,
    priority: Priority.high,
    category: AndroidNotificationCategory.reminder,
  ),
  iOS: DarwinNotificationDetails(),
  macOS: DarwinNotificationDetails(),
  linux: LinuxNotificationDetails(),
  windows: WindowsNotificationDetails(),
);

Future<bool> initializeLocalNotifications() async {
  if (_initialized) return true;
  try {
    await _configureLocalTimezone();
    final initialized = await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_phoenix'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
        linux: LinuxInitializationSettings(defaultActionName: 'Open Phoenix'),
        windows: WindowsInitializationSettings(
          appName: 'Phoenix',
          appUserModelId: 'PhoenixFitness.Local.First',
          guid: '4b455e6f-7b7a-4e7d-b9dc-c7d4df2320af',
        ),
      ),
    );
    _initialized = initialized ?? false;
    return _initialized;
  } on Object {
    return false;
  }
}

Future<bool> _configureLocalTimezone() async {
  if (_timezoneReady) return true;
  try {
    tz_data.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
    _timezoneReady = true;
    return true;
  } on Object {
    // A missing timezone must not move a reminder to an incorrect UTC hour.
    return false;
  }
}

Future<bool> requestLocalNotificationPermission() async {
  if (!await initializeLocalNotifications()) return false;
  try {
    if (Platform.isAndroid) {
      return await _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }
    if (Platform.isIOS) {
      return await _notifications
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, sound: true, badge: true) ??
          false;
    }
    if (Platform.isMacOS) {
      return await _notifications
              .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, sound: true, badge: true) ??
          false;
    }
    return true;
  } on Object {
    return false;
  }
}

Future<bool> showLocalWorkoutNotification({
  required String title,
  required String body,
}) async {
  if (!await initializeLocalNotifications()) return false;
  try {
    await _notifications.show(
      id: 0x706878,
      title: title,
      body: body,
      notificationDetails: _notificationDetails,
      payload: 'phoenix-workout-now',
    );
    return true;
  } on Object {
    return false;
  }
}

Future<bool> syncLocalWorkoutNotifications({
  required List<LocalWorkoutNotificationSchedule> reminders,
}) async {
  if (!await initializeLocalNotifications()) return false;
  if (!await _configureLocalTimezone()) return false;
  var successful = true;
  try {
    final pending = await _notifications.pendingNotificationRequests();
    for (final request in pending) {
      if (request.payload?.startsWith(
            phoenixWorkoutNotificationPayloadPrefix,
          ) ??
          false) {
        await _notifications.cancel(id: request.id);
      }
    }
    final now = tz.TZDateTime.now(tz.local);
    for (final reminder in reminders.where((item) => item.enabled)) {
      try {
        final next = nextWeeklyReminderOccurrence(
          now: now,
          weekday: reminder.weekday,
          minutesSinceMidnight: reminder.minutesSinceMidnight,
        );
        await _notifications.zonedSchedule(
          id: reminder.notificationId,
          title: reminder.title,
          body: reminder.body,
          scheduledDate: tz.TZDateTime(
            tz.local,
            next.year,
            next.month,
            next.day,
            next.hour,
            next.minute,
          ),
          notificationDetails: _notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: reminder.payload,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      } on Object {
        successful = false;
      }
    }
    return successful;
  } on Object {
    return false;
  }
}

Future<bool> installPhoenixPwa() async => false;
