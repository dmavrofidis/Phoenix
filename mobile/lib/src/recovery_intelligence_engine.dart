import 'dart:math' as math;

import 'models/fitness_models.dart';
import 'recovery_engine.dart';

class RecoveryTrendDashboard {
  const RecoveryTrendDashboard({
    required this.currentReadiness,
    required this.previousReadiness,
    required this.averageSleepHours,
    required this.averageSoreness,
    required this.averageStress,
    required this.averageRestingHeartRate,
    required this.sampleDays,
    required this.dailyScores,
  });

  final int currentReadiness;
  final int previousReadiness;
  final double averageSleepHours;
  final double averageSoreness;
  final double averageStress;
  final int averageRestingHeartRate;
  final int sampleDays;
  final List<int> dailyScores;

  int get readinessChange => currentReadiness - previousReadiness;
  String get direction => sampleDays < 3
      ? 'BUILDING BASELINE'
      : readinessChange >= 5
      ? 'IMPROVING'
      : readinessChange <= -5
      ? 'DECLINING'
      : 'STABLE';
}

class SleepDebtEstimate {
  const SleepDebtEstimate({
    required this.targetHours,
    required this.totalHours,
    required this.averageDailyDebt,
    required this.nights,
    required this.level,
    required this.action,
  });

  final double targetHours;
  final double totalHours;
  final double averageDailyDebt;
  final int nights;
  final String level;
  final String action;
}

class SorenessDecayForecast {
  const SorenessDecayForecast({
    required this.latestSoreness,
    required this.dailyDecay,
    required this.daysToLow,
    required this.status,
    required this.focusArea,
  });

  final int latestSoreness;
  final double dailyDecay;
  final int daysToLow;
  final String status;
  final String focusArea;
}

class StressLoadTrend {
  const StressLoadTrend({
    required this.currentAverage,
    required this.previousAverage,
    required this.highStressDays,
    required this.direction,
  });

  final double currentAverage;
  final double previousAverage;
  final int highStressDays;
  final String direction;

  double get change => currentAverage - previousAverage;
}

class RestingHeartRateDeviation {
  const RestingHeartRateDeviation({
    required this.latest,
    required this.baseline,
    required this.deviation,
    required this.percentDeviation,
    required this.status,
    required this.hasAlert,
    required this.sampleDays,
  });

  final int latest;
  final int baseline;
  final int deviation;
  final double percentDeviation;
  final String status;
  final bool hasAlert;
  final int sampleDays;
}

class RecoveryDayRecommendation {
  const RecoveryDayRecommendation({
    required this.level,
    required this.title,
    required this.reason,
    required this.trainingLoadPercent,
    required this.accent,
  });

  final String level;
  final String title;
  final String reason;
  final int trainingLoadPercent;
  final String accent;
}

class ActiveRecoverySegment {
  const ActiveRecoverySegment({
    required this.name,
    required this.minutes,
    required this.detail,
    required this.intensity,
  });

  final String name;
  final int minutes;
  final String detail;
  final String intensity;
}

class ActiveRecoverySession {
  const ActiveRecoverySession({
    required this.title,
    required this.totalMinutes,
    required this.segments,
    required this.stopRule,
  });

  final String title;
  final int totalMinutes;
  final List<ActiveRecoverySegment> segments;
  final String stopRule;
}

class RecoveryInterventionComparison {
  const RecoveryInterventionComparison({
    required this.intervention,
    required this.sampleSize,
    required this.averageResponse,
    required this.positiveResponses,
    required this.label,
  });

  final String intervention;
  final int sampleSize;
  final double averageResponse;
  final int positiveResponses;
  final String label;

  double get positiveRate =>
      sampleSize == 0 ? 0 : positiveResponses / sampleSize;
}

class ReturnToBaselineForecast {
  const ReturnToBaselineForecast({
    required this.latestScore,
    required this.targetScore,
    required this.dailyTrend,
    required this.estimatedDays,
    required this.confidence,
    required this.status,
    required this.estimatedDate,
  });

  final int latestScore;
  final int targetScore;
  final double dailyTrend;
  final int estimatedDays;
  final String confidence;
  final String status;
  final DateTime? estimatedDate;
}

class RecoveryIntelligenceEngine {
  const RecoveryIntelligenceEngine._();

  static const supportedInterventions = <String>[
    'Sauna',
    'Cold exposure',
    'Recovery walk',
    'Mobility',
    'Breathing',
    'Nap',
  ];

  static RecoveryTrendDashboard trendDashboard(List<RecoveryCheckIn> checkIns) {
    if (checkIns.isEmpty) {
      return const RecoveryTrendDashboard(
        currentReadiness: 0,
        previousReadiness: 0,
        averageSleepHours: 0,
        averageSoreness: 0,
        averageStress: 0,
        averageRestingHeartRate: 0,
        sampleDays: 0,
        dailyScores: [],
      );
    }
    final sorted = _descending(checkIns);
    final current = sorted.take(7).toList();
    final previous = sorted.skip(7).take(7).toList();
    final rhr = current
        .where((item) => item.restingHeartRate > 0)
        .map((item) => item.restingHeartRate)
        .toList();
    final currentScores = current.map(_score).toList();
    final previousScores = previous.map(_score).toList();
    return RecoveryTrendDashboard(
      currentReadiness: _averageInt(currentScores),
      previousReadiness: previousScores.isEmpty
          ? _averageInt(currentScores)
          : _averageInt(previousScores),
      averageSleepHours: _average(
        current.map((item) => item.sleepHours).toList(),
      ),
      averageSoreness: _average(
        current.map((item) => item.soreness.toDouble()).toList(),
      ),
      averageStress: _average(
        current.map((item) => item.stress.toDouble()).toList(),
      ),
      averageRestingHeartRate: _averageInt(rhr),
      sampleDays: current.length,
      dailyScores: currentScores.reversed.toList(),
    );
  }

  static SleepDebtEstimate sleepDebt(
    List<RecoveryCheckIn> checkIns, {
    double targetHours = 8,
    DateTime? now,
  }) {
    final anchor = now ?? DateTime.now();
    final start = DateTime(
      anchor.year,
      anchor.month,
      anchor.day,
    ).subtract(const Duration(days: 6));
    final recent = checkIns
        .where(
          (item) =>
              !item.recordedAt.isBefore(start) &&
              item.recordedAt.isBefore(anchor.add(const Duration(days: 1))),
        )
        .toList();
    final debt = recent.fold<double>(
      0,
      (sum, item) => sum + math.max(0, targetHours - item.sleepHours),
    );
    final average = recent.isEmpty ? 0.0 : debt / recent.length;
    final level = debt >= 7
        ? 'SEVERE'
        : debt >= 4
        ? 'HIGH'
        : debt >= 1.5
        ? 'MILD'
        : 'CLEAR';
    final action = switch (level) {
      'SEVERE' =>
        'Protect two earlier bedtimes; avoid trying to erase the debt with one extreme sleep-in.',
      'HIGH' =>
        'Add 30–60 minutes of sleep opportunity for the next three nights.',
      'MILD' => 'Use one earlier bedtime and keep wake time consistent.',
      _ => 'Sleep opportunity is close to target; protect the current routine.',
    };
    return SleepDebtEstimate(
      targetHours: targetHours,
      totalHours: debt,
      averageDailyDebt: average,
      nights: recent.length,
      level: level,
      action: action,
    );
  }

  static SorenessDecayForecast sorenessDecay(List<RecoveryCheckIn> checkIns) {
    if (checkIns.isEmpty) {
      return const SorenessDecayForecast(
        latestSoreness: 0,
        dailyDecay: 0,
        daysToLow: 0,
        status: 'NO DATA',
        focusArea: 'None recorded',
      );
    }
    final sorted = [...checkIns]
      ..sort((left, right) => left.recordedAt.compareTo(right.recordedAt));
    final sample = sorted.length > 7
        ? sorted.sublist(sorted.length - 7)
        : sorted;
    final latest = sample.last;
    var accumulatedDecay = 0.0;
    var observedDays = 0;
    for (var index = 1; index < sample.length; index++) {
      final days = math.max(
        1,
        sample[index].recordedAt
            .difference(sample[index - 1].recordedAt)
            .inDays,
      );
      accumulatedDecay +=
          (sample[index - 1].soreness - sample[index].soreness) / days;
      observedDays++;
    }
    final decay = observedDays == 0 ? 0.0 : accumulatedDecay / observedDays;
    final daysToLow = latest.soreness <= 1
        ? 0
        : decay > .05
        ? ((latest.soreness - 1) / decay).ceil().clamp(1, 14)
        : 14;
    final focus = latest.sorenessAreas.entries
        .where((entry) => entry.value > 0)
        .fold<MapEntry<String, int>?>(
          null,
          (best, item) => best == null || item.value > best.value ? item : best,
        );
    return SorenessDecayForecast(
      latestSoreness: latest.soreness,
      dailyDecay: decay,
      daysToLow: daysToLow,
      status: latest.soreness <= 1
          ? 'RESOLVED'
          : decay > .2
          ? 'DECAYING'
          : decay < -.1
          ? 'RISING'
          : 'STALLED',
      focusArea: focus?.key ?? 'General',
    );
  }

  static StressLoadTrend stressTrend(List<RecoveryCheckIn> checkIns) {
    final sorted = _descending(checkIns);
    final current = sorted
        .take(7)
        .map((item) => item.stress.toDouble())
        .toList();
    final previous = sorted
        .skip(7)
        .take(7)
        .map((item) => item.stress.toDouble())
        .toList();
    final currentAverage = _average(current);
    final previousAverage = previous.isEmpty
        ? currentAverage
        : _average(previous);
    final change = currentAverage - previousAverage;
    return StressLoadTrend(
      currentAverage: currentAverage,
      previousAverage: previousAverage,
      highStressDays: current.where((value) => value >= 4).length,
      direction: change >= .5
          ? 'RISING'
          : change <= -.5
          ? 'EASING'
          : 'STABLE',
    );
  }

  static RestingHeartRateDeviation restingHeartRateDeviation(
    List<RecoveryCheckIn> checkIns,
  ) {
    final valid = _descending(
      checkIns.where((item) => item.restingHeartRate > 0).toList(),
    );
    if (valid.isEmpty) {
      return const RestingHeartRateDeviation(
        latest: 0,
        baseline: 0,
        deviation: 0,
        percentDeviation: 0,
        status: 'NO DATA',
        hasAlert: false,
        sampleDays: 0,
      );
    }
    final latest = valid.first.restingHeartRate;
    final baselineValues = valid
        .skip(1)
        .take(14)
        .map((item) => item.restingHeartRate)
        .toList();
    if (baselineValues.length < 3) {
      return RestingHeartRateDeviation(
        latest: latest,
        baseline: _averageInt(baselineValues),
        deviation: 0,
        percentDeviation: 0,
        status: 'BUILDING BASELINE',
        hasAlert: false,
        sampleDays: baselineValues.length,
      );
    }
    final baseline = _averageInt(baselineValues);
    final deviation = latest - baseline;
    final percent = baseline == 0 ? 0.0 : deviation / baseline * 100;
    final alert = deviation >= 7 || percent >= 10;
    return RestingHeartRateDeviation(
      latest: latest,
      baseline: baseline,
      deviation: deviation,
      percentDeviation: percent,
      status: alert
          ? 'ELEVATED'
          : deviation >= 4
          ? 'WATCH'
          : deviation <= -5
          ? 'BELOW BASELINE'
          : 'NORMAL',
      hasAlert: alert,
      sampleDays: baselineValues.length,
    );
  }

  static RecoveryDayRecommendation recoveryDayRecommendation({
    required List<RecoveryCheckIn> checkIns,
    double targetSleepHours = 8,
    DateTime? now,
  }) {
    if (checkIns.isEmpty) {
      return const RecoveryDayRecommendation(
        level: 'BASELINE',
        title: 'COMPLETE A RECOVERY CHECK-IN',
        reason: 'A recommendation needs at least one daily recovery entry.',
        trainingLoadPercent: 100,
        accent: 'neutral',
      );
    }
    final latest = _descending(checkIns).first;
    final readiness = RecoveryEngine.evaluate(latest);
    final debt = sleepDebt(
      checkIns,
      targetHours: targetSleepHours,
      now: now ?? latest.recordedAt,
    );
    final rhr = restingHeartRateDeviation(checkIns);
    if (readiness.score < 45 ||
        debt.totalHours >= 7 ||
        latest.soreness >= 5 ||
        rhr.hasAlert) {
      return RecoveryDayRecommendation(
        level: 'FULL REST',
        title: 'RECOVERY TAKES PRIORITY',
        reason:
            'Readiness ${readiness.score}/100 • sleep debt ${debt.totalHours.toStringAsFixed(1)}h'
            '${rhr.hasAlert ? ' • elevated RHR' : ''}.',
        trainingLoadPercent: 0,
        accent: 'red',
      );
    }
    if (readiness.score < 70 ||
        debt.totalHours >= 2 ||
        latest.soreness >= 4 ||
        latest.stress >= 4) {
      return RecoveryDayRecommendation(
        level: 'ACTIVE RECOVERY',
        title: 'MOVE, BUT DO NOT CHASE FATIGUE',
        reason:
            'Readiness ${readiness.score}/100 • soreness ${latest.soreness}/5 • stress ${latest.stress}/5.',
        trainingLoadPercent: 35,
        accent: 'amber',
      );
    }
    return RecoveryDayRecommendation(
      level: 'TRAIN',
      title: 'TRAIN AS PLANNED',
      reason: 'Readiness ${readiness.score}/100 with no major recovery alert.',
      trainingLoadPercent: 100,
      accent: 'green',
    );
  }

  static ActiveRecoverySession activeRecoverySession({
    required RecoveryDayRecommendation recommendation,
    RecoveryCheckIn? latest,
  }) {
    final fullRest = recommendation.level == 'FULL REST';
    final highStress = (latest?.stress ?? 0) >= 4;
    final highSoreness = (latest?.soreness ?? 0) >= 4;
    final segments = <ActiveRecoverySegment>[
      ActiveRecoverySegment(
        name: 'Downshift',
        minutes: highStress ? 5 : 3,
        detail: 'Nasal breathing with a longer, unforced exhale.',
        intensity: 'RPE 1',
      ),
      ActiveRecoverySegment(
        name: fullRest ? 'Easy walk' : 'Walk or easy bike',
        minutes: fullRest ? 10 : 15,
        detail: 'Conversational pace; heart rate stays comfortably low.',
        intensity: 'RPE 2',
      ),
      ActiveRecoverySegment(
        name: highSoreness ? 'Pain-free mobility' : 'Mobility flow',
        minutes: 7,
        detail:
            'Controlled ankle, hip and thoracic motion; no forced end range.',
        intensity: 'RPE 1–2',
      ),
      const ActiveRecoverySegment(
        name: 'Reset',
        minutes: 3,
        detail: 'Slow breathing and re-check how the body feels.',
        intensity: 'RPE 1',
      ),
    ];
    return ActiveRecoverySession(
      title: fullRest ? 'REST-DAY RESET' : 'ACTIVE RECOVERY 28',
      totalMinutes: segments.fold(0, (sum, item) => sum + item.minutes),
      segments: segments,
      stopRule:
          'Stop for pain, dizziness, unusual breathlessness or worsening symptoms.',
    );
  }

  static List<RecoveryInterventionComparison> compareInterventions(
    List<RecoveryInterventionLog> logs,
  ) {
    final groups = <String, List<RecoveryInterventionLog>>{};
    for (final log in logs) {
      groups.putIfAbsent(log.intervention, () => []).add(log);
    }
    final result =
        groups.entries.map((entry) {
          final response = _average(
            entry.value.map((item) => item.response.toDouble()).toList(),
          );
          final positive = entry.value
              .where((item) => item.response > 0)
              .length;
          return RecoveryInterventionComparison(
            intervention: entry.key,
            sampleSize: entry.value.length,
            averageResponse: response,
            positiveResponses: positive,
            label: entry.value.length < 3
                ? 'EARLY SIGNAL'
                : response >= 1
                ? 'HELPFUL'
                : response <= -.5
                ? 'NOT HELPING'
                : 'NEUTRAL',
          );
        }).toList()..sort(
          (left, right) =>
              right.averageResponse.compareTo(left.averageResponse),
        );
    return result;
  }

  static ReturnToBaselineForecast returnToBaseline(
    List<RecoveryCheckIn> checkIns, {
    DateTime? now,
  }) {
    if (checkIns.isEmpty) {
      return const ReturnToBaselineForecast(
        latestScore: 0,
        targetScore: 0,
        dailyTrend: 0,
        estimatedDays: 0,
        confidence: 'NONE',
        status: 'NO DATA',
        estimatedDate: null,
      );
    }
    final sorted = [...checkIns]
      ..sort((left, right) => left.recordedAt.compareTo(right.recordedAt));
    final scores = sorted.map(_score).toList();
    final latest = scores.last;
    final baselineSource = scores.length >= 5
        ? scores.take(scores.length - 3).toList()
        : scores;
    final target = _averageInt(baselineSource);
    final recentStart = math.max(0, scores.length - 4);
    final recentScores = scores.sublist(recentStart);
    var dailyTrend = 0.0;
    var transitions = 0;
    for (var index = 1; index < recentScores.length; index++) {
      final originalIndex = recentStart + index;
      final days = math.max(
        1,
        sorted[originalIndex].recordedAt
            .difference(sorted[originalIndex - 1].recordedAt)
            .inDays,
      );
      dailyTrend += (recentScores[index] - recentScores[index - 1]) / days;
      transitions++;
    }
    if (transitions > 0) dailyTrend /= transitions;
    if (latest >= target) {
      return ReturnToBaselineForecast(
        latestScore: latest,
        targetScore: target,
        dailyTrend: dailyTrend,
        estimatedDays: 0,
        confidence: scores.length >= 7 ? 'HIGH' : 'MEDIUM',
        status: 'AT BASELINE',
        estimatedDate: now ?? sorted.last.recordedAt,
      );
    }
    final usableTrend = dailyTrend > .25 ? dailyTrend : 2.0;
    final days = ((target - latest) / usableTrend).ceil().clamp(1, 14);
    final anchor = now ?? sorted.last.recordedAt;
    return ReturnToBaselineForecast(
      latestScore: latest,
      targetScore: target,
      dailyTrend: dailyTrend,
      estimatedDays: days,
      confidence: scores.length >= 7 && dailyTrend > .25
          ? 'HIGH'
          : scores.length >= 4
          ? 'MEDIUM'
          : 'LOW',
      status: dailyTrend > .25 ? 'RECOVERING' : 'TREND NOT YET POSITIVE',
      estimatedDate: anchor.add(Duration(days: days)),
    );
  }

  static List<RecoveryCheckIn> _descending(List<RecoveryCheckIn> checkIns) =>
      [...checkIns]
        ..sort((left, right) => right.recordedAt.compareTo(left.recordedAt));

  static int _score(RecoveryCheckIn item) =>
      RecoveryEngine.evaluate(item).score;

  static double _average(List<double> values) => values.isEmpty
      ? 0
      : values.reduce((left, right) => left + right) / values.length;

  static int _averageInt(List<int> values) => values.isEmpty
      ? 0
      : (values.reduce((left, right) => left + right) / values.length).round();
}
