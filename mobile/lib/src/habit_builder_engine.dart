import 'models/fitness_models.dart';

class HabitChecklistItem {
  const HabitChecklistItem({
    required this.habit,
    required this.checkIn,
    required this.status,
  });

  final HealthHabit habit;
  final HabitCheckIn? checkIn;
  final String status;
}

class HabitStreak {
  const HabitStreak({
    required this.days,
    required this.minimumDays,
    required this.status,
    required this.nextAction,
  });

  final int days;
  final int minimumDays;
  final String status;
  final String nextAction;
}

class HabitWeeklyScore {
  const HabitWeeklyScore({
    required this.points,
    required this.target,
    required this.percent,
    required this.label,
  });

  final double points;
  final int target;
  final int percent;
  final String label;
}

class HabitFrictionReport {
  const HabitFrictionReport({
    required this.average,
    required this.highFrictionDays,
    required this.label,
    required this.action,
  });

  final double average;
  final int highFrictionDays;
  final String label;
  final String action;
}

class HabitReflectionSummary {
  const HabitReflectionSummary({
    required this.count,
    required this.latest,
    required this.prompt,
  });

  final int count;
  final String latest;
  final String prompt;
}

class HabitCorrelation {
  const HabitCorrelation({
    required this.sampleDays,
    required this.readinessLift,
    required this.workoutLift,
    required this.label,
    required this.caution,
  });

  final int sampleDays;
  final double readinessLift;
  final double workoutLift;
  final String label;
  final String caution;
}

class HabitBuilderEngine {
  const HabitBuilderEngine._();

  static DateTime dayKey(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static List<HabitChecklistItem> dailyChecklist({
    required List<HealthHabit> habits,
    required List<HabitCheckIn> checkIns,
    required DateTime day,
  }) {
    final target = dayKey(day);
    final byHabit = <String, HabitCheckIn>{};
    for (final item in checkIns) {
      if (dayKey(item.day) == target) byHabit[item.habitId] = item;
    }
    return habits.where((item) => item.active).map((habit) {
      final checkIn = byHabit[habit.id];
      final status = switch (checkIn) {
        null => 'OPEN',
        HabitCheckIn(completed: true) => 'COMPLETE',
        HabitCheckIn(usedMinimum: true) => 'MINIMUM DAY',
        _ => 'SKIPPED',
      };
      return HabitChecklistItem(habit: habit, checkIn: checkIn, status: status);
    }).toList();
  }

  static HabitStreak streakProtection({
    required HealthHabit habit,
    required List<HabitCheckIn> checkIns,
    required DateTime now,
  }) {
    final relevant = <DateTime, HabitCheckIn>{};
    for (final item in checkIns.where((item) => item.habitId == habit.id)) {
      relevant[dayKey(item.day)] = item;
    }
    var cursor = dayKey(now);
    final today = relevant[cursor];
    if (today == null || (!today.completed && !today.usedMinimum)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var days = 0;
    var minimumDays = 0;
    while (true) {
      final item = relevant[cursor];
      if (item == null || (!item.completed && !item.usedMinimum)) break;
      days++;
      if (!item.completed && item.usedMinimum) minimumDays++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    final hasToday = today?.completed == true || today?.usedMinimum == true;
    return HabitStreak(
      days: days,
      minimumDays: minimumDays,
      status: hasToday
          ? today!.completed
                ? 'STREAK SECURE'
                : 'MINIMUM DAY'
          : days == 0
          ? 'START TODAY'
          : 'PROTECT TODAY',
      nextAction: hasToday
          ? 'The chain is protected. Full repetitions still count more.'
          : 'Use “${habit.minimumVersion}” if a full repetition is unrealistic.',
    );
  }

  static HabitWeeklyScore weeklyScore({
    required HealthHabit habit,
    required List<HabitCheckIn> checkIns,
    required DateTime now,
  }) {
    final today = dayKey(now);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    var points = 0.0;
    for (final item in checkIns) {
      final day = dayKey(item.day);
      if (item.habitId != habit.id ||
          day.isBefore(monday) ||
          day.isAfter(monday.add(const Duration(days: 6)))) {
        continue;
      }
      if (item.completed) {
        points += 1;
      } else if (item.usedMinimum) {
        points += .5;
      }
    }
    final target = habit.targetDaysPerWeek;
    final percent = target == 0
        ? 0
        : (points / target * 100).round().clamp(0, 100);
    return HabitWeeklyScore(
      points: points,
      target: target,
      percent: percent,
      label: percent >= 85
          ? 'ON SYSTEM'
          : percent >= 55
          ? 'BUILDING'
          : 'NEEDS A SMALLER LOOP',
    );
  }

  static String implementationIntention(HealthHabit habit) {
    final hours = habit.preferredMinutesSinceMidnight ~/ 60;
    final minutes = habit.preferredMinutesSinceMidnight % 60;
    final time =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    final anchor = habit.stackAfter.trim().isEmpty
        ? 'my planned anchor'
        : habit.stackAfter.trim();
    return 'At $time, after $anchor, I will ${habit.name.toLowerCase()}.';
  }

  static List<String> stackSuggestions(HealthHabit habit) {
    final category = habit.category;
    final options = switch (category) {
      'Movement' => [
        'After brushing my teeth',
        'After closing my laptop',
        'After my first coffee',
      ],
      'Nutrition' => [
        'After plating my meal',
        'After grocery unpacking',
        'After filling my water bottle',
      ],
      'Recovery' => [
        'After the final meal',
        'After setting my alarm',
        'After the last screen session',
      ],
      _ => ['After waking up', 'After lunch', 'Before getting into bed'],
    };
    return options;
  }

  static HabitFrictionReport frictionAudit({
    required HealthHabit habit,
    required List<HabitCheckIn> checkIns,
  }) {
    final relevant = checkIns
        .where((item) => item.habitId == habit.id && item.frictionLevel > 0)
        .toList();
    if (relevant.isEmpty) {
      return const HabitFrictionReport(
        average: 0,
        highFrictionDays: 0,
        label: 'NO SIGNAL YET',
        action: 'Rate friction after a repetition to expose hidden barriers.',
      );
    }
    final average =
        relevant.fold<int>(0, (sum, item) => sum + item.frictionLevel) /
        relevant.length;
    final high = relevant.where((item) => item.frictionLevel >= 4).length;
    return HabitFrictionReport(
      average: average,
      highFrictionDays: high,
      label: average >= 3.5
          ? 'HIGH FRICTION'
          : average >= 2
          ? 'MANAGEABLE'
          : 'LOW FRICTION',
      action: average >= 3.5
          ? 'Prepare the environment earlier and halve the first step.'
          : average >= 2
          ? 'Keep the anchor visible and remove one setup step.'
          : 'The environment is supporting this habit; preserve the setup.',
    );
  }

  static String minimumDayFallback(HealthHabit habit) =>
      habit.minimumVersion.trim().isEmpty
      ? 'Do one tiny repetition that takes under two minutes.'
      : habit.minimumVersion.trim();

  static HabitReflectionSummary reflectionSummary({
    required HealthHabit habit,
    required List<HabitCheckIn> checkIns,
  }) {
    final notes =
        checkIns
            .where(
              (item) =>
                  item.habitId == habit.id && item.reflection.trim().isNotEmpty,
            )
            .toList()
          ..sort((left, right) => right.recordedAt.compareTo(left.recordedAt));
    return HabitReflectionSummary(
      count: notes.length,
      latest: notes.isEmpty ? 'No reflection yet.' : notes.first.reflection,
      prompt: notes.isEmpty
          ? 'What made the first repetition easier or harder?'
          : 'What one change would make tomorrow easier?',
    );
  }

  static HabitCorrelation progressCorrelation({
    required HealthHabit habit,
    required List<HabitCheckIn> checkIns,
    required List<RecoveryCheckIn> recoveryChecks,
    required List<WorkoutLog> workouts,
  }) {
    final habitDays = <DateTime>{};
    for (final item in checkIns.where(
      (item) =>
          item.habitId == habit.id && (item.completed || item.usedMinimum),
    )) {
      habitDays.add(dayKey(item.day));
    }
    final recoveryByDay = <DateTime, double>{};
    for (final item in recoveryChecks) {
      recoveryByDay[dayKey(item.recordedAt)] = _readiness(item);
    }
    final workoutDays = workouts
        .map((item) => dayKey(item.completedAt))
        .toSet();
    final allDays = <DateTime>{
      ...habitDays,
      ...recoveryByDay.keys,
      ...workoutDays,
    };
    if (allDays.length < 3 || habitDays.length < 2) {
      return HabitCorrelation(
        sampleDays: allDays.length,
        readinessLift: 0,
        workoutLift: 0,
        label: 'EARLY DATA',
        caution: 'Log at least three matched days before comparing outcomes.',
      );
    }
    final withHabit = allDays.where(habitDays.contains).toList();
    final withoutHabit = allDays
        .where((day) => !habitDays.contains(day))
        .toList();
    final readinessLift =
        _average(withHabit.map((day) => recoveryByDay[day])) -
        _average(withoutHabit.map((day) => recoveryByDay[day]));
    final workoutLift =
        _rate(withHabit, workoutDays) - _rate(withoutHabit, workoutDays);
    return HabitCorrelation(
      sampleDays: allDays.length,
      readinessLift: readinessLift,
      workoutLift: workoutLift,
      label: readinessLift > 5 || workoutLift > .15
          ? 'POSITIVE ASSOCIATION'
          : readinessLift < -5 || workoutLift < -.15
          ? 'NEGATIVE ASSOCIATION'
          : 'NO CLEAR ASSOCIATION',
      caution:
          'Association only—not proof of cause. Sleep, training load and schedule can confound the result.',
    );
  }

  static double _readiness(RecoveryCheckIn item) {
    final sleep = (item.sleepHours / 8 * 100).clamp(0, 100);
    final energy = item.energy / 5 * 100;
    final soreness = (6 - item.soreness) / 5 * 100;
    final stress = (6 - item.stress) / 5 * 100;
    return (sleep * .35) + (energy * .25) + (soreness * .2) + (stress * .2);
  }

  static double _average(Iterable<double?> values) {
    final present = values.whereType<double>().toList();
    if (present.isEmpty) return 0;
    return present.reduce((left, right) => left + right) / present.length;
  }

  static double _rate(List<DateTime> days, Set<DateTime> positives) {
    if (days.isEmpty) return 0;
    return days.where(positives.contains).length / days.length;
  }
}
