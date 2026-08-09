import 'models/fitness_models.dart';

class ScheduledWorkout {
  const ScheduledWorkout({
    required this.date,
    required this.template,
    this.completedLog,
  });

  final DateTime date;
  final WorkoutTemplate template;
  final WorkoutLog? completedLog;

  bool get isCompleted => completedLog != null;

  bool isToday(DateTime now) => _sameDay(date, now);

  bool isOverdue(DateTime now) => !isCompleted && date.isBefore(_dateOnly(now));

  static bool _sameDay(DateTime left, DateTime right) =>
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

class TrainingSchedule {
  const TrainingSchedule({required this.weekStart, required this.entries});

  final DateTime weekStart;
  final List<ScheduledWorkout> entries;

  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  int get completedCount => entries.where((entry) => entry.isCompleted).length;

  double get progress => entries.isEmpty ? 0 : completedCount / entries.length;

  ScheduledWorkout? nextEntry(DateTime now) {
    for (final entry in entries) {
      if (!entry.isCompleted && !entry.date.isAfter(_dateOnly(now))) {
        return entry;
      }
    }
    for (final entry in entries) {
      if (!entry.isCompleted) return entry;
    }
    return null;
  }
}

class TrainingScheduleEngine {
  const TrainingScheduleEngine._();

  static TrainingSchedule build({
    required DateTime now,
    required int daysPerWeek,
    required List<WorkoutTemplate> rotation,
    required List<WorkoutLog> logs,
    Map<String, String> assignments = const {},
    Map<String, String> dateAssignments = const {},
    List<WorkoutTemplate>? catalog,
  }) {
    final today = _dateOnly(now);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    if (rotation.isEmpty) {
      return TrainingSchedule(weekStart: weekStart, entries: const []);
    }

    final previousLogs =
        logs.where((log) => log.completedAt.isBefore(weekStart)).toList()..sort(
          (left, right) => right.completedAt.compareTo(left.completedAt),
        );
    var rotationStart = 0;
    if (previousLogs.isNotEmpty) {
      final previousIndex = rotation.indexWhere(
        (template) => template.name == previousLogs.first.templateName,
      );
      if (previousIndex >= 0) {
        rotationStart = (previousIndex + 1) % rotation.length;
      }
    }

    final nextWeek = weekStart.add(const Duration(days: 7));
    final currentWeekLogs =
        logs
            .where(
              (log) =>
                  !log.completedAt.isBefore(weekStart) &&
                  log.completedAt.isBefore(nextWeek),
            )
            .toList()
          ..sort(
            (left, right) => left.completedAt.compareTo(right.completedAt),
          );
    final usedLogIndexes = <int>{};
    final datedWeekdays = <int>{};
    for (final key in dateAssignments.keys) {
      final date = DateTime.tryParse(key);
      if (date != null &&
          !date.isBefore(weekStart) &&
          date.isBefore(nextWeek)) {
        datedWeekdays.add(date.weekday);
      }
    }
    final weekdays = <int>{
      ...distributedWeekdays(daysPerWeek),
      ...assignments.keys
          .map(int.tryParse)
          .whereType<int>()
          .where((weekday) => weekday >= 1 && weekday <= 7),
      ...datedWeekdays,
    }.toList()..sort();
    final entries = <ScheduledWorkout>[];

    for (var index = 0; index < weekdays.length; index++) {
      final weekday = weekdays[index];
      final date = weekStart.add(Duration(days: weekday - 1));
      final assignedId =
          dateAssignments[_dateKey(date)] ?? assignments['$weekday'];
      final assignedTemplate = assignedId == null
          ? null
          : (catalog ?? rotation).cast<WorkoutTemplate?>().firstWhere(
              (template) => template?.id == assignedId,
              orElse: () => null,
            );
      final template =
          assignedTemplate ??
          rotation[(rotationStart + index) % rotation.length];
      WorkoutLog? completedLog;
      for (var logIndex = 0; logIndex < currentWeekLogs.length; logIndex++) {
        if (usedLogIndexes.contains(logIndex)) continue;
        final log = currentWeekLogs[logIndex];
        if (log.templateName == template.name) {
          usedLogIndexes.add(logIndex);
          completedLog = log;
          break;
        }
      }
      entries.add(
        ScheduledWorkout(
          date: date,
          template: template,
          completedLog: completedLog,
        ),
      );
    }

    return TrainingSchedule(weekStart: weekStart, entries: entries);
  }

  static List<int> distributedWeekdays(int daysPerWeek) {
    return switch (daysPerWeek.clamp(1, 7)) {
      1 => const [3],
      2 => const [1, 4],
      3 => const [1, 3, 5],
      4 => const [1, 2, 4, 6],
      5 => const [1, 2, 3, 5, 6],
      6 => const [1, 2, 3, 4, 5, 6],
      _ => const [1, 2, 3, 4, 5, 6, 7],
    };
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

String _dateKey(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
