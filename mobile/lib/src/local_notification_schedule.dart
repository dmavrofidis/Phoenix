const phoenixWorkoutNotificationPayloadPrefix = 'phoenix-workout:';

class LocalWorkoutNotificationSchedule {
  const LocalWorkoutNotificationSchedule({
    required this.id,
    required this.weekday,
    required this.minutesSinceMidnight,
    required this.title,
    required this.body,
    required this.enabled,
  });

  final String id;
  final int weekday;
  final int minutesSinceMidnight;
  final String title;
  final String body;
  final bool enabled;

  int get notificationId => stableWorkoutNotificationId(id);

  String get payload => '$phoenixWorkoutNotificationPayloadPrefix$id';
}

int stableWorkoutNotificationId(String reminderId) {
  var hash = 0x811c9dc5;
  for (final codeUnit in reminderId.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}

DateTime nextWeeklyReminderOccurrence({
  required DateTime now,
  required int weekday,
  required int minutesSinceMidnight,
}) {
  if (weekday < DateTime.monday || weekday > DateTime.sunday) {
    throw RangeError.range(
      weekday,
      DateTime.monday,
      DateTime.sunday,
      'weekday',
    );
  }
  if (minutesSinceMidnight < 0 || minutesSinceMidnight >= 24 * 60) {
    throw RangeError.range(
      minutesSinceMidnight,
      0,
      24 * 60 - 1,
      'minutesSinceMidnight',
    );
  }
  final daysAhead = (weekday - now.weekday + 7) % 7;
  var candidate = DateTime(
    now.year,
    now.month,
    now.day + daysAhead,
    minutesSinceMidnight ~/ 60,
    minutesSinceMidnight % 60,
  );
  if (!candidate.isAfter(now)) {
    candidate = candidate.add(const Duration(days: 7));
  }
  return candidate;
}
