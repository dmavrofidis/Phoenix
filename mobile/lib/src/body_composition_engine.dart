import 'dart:math' as math;

import 'models/fitness_models.dart';

class SmoothedWeightPoint {
  const SmoothedWeightPoint({
    required this.date,
    required this.rawKilograms,
    required this.trendKilograms,
  });

  final DateTime date;
  final double rawKilograms;
  final double trendKilograms;
}

class WeeklyWeightRate {
  const WeeklyWeightRate({
    required this.currentAverage,
    required this.previousAverage,
    required this.kilogramsPerWeek,
    required this.percentPerWeek,
    required this.sampleDays,
    required this.label,
  });

  final double currentAverage;
  final double previousAverage;
  final double kilogramsPerWeek;
  final double percentPerWeek;
  final int sampleDays;
  final String label;
}

class MeasurementTrend {
  const MeasurementTrend({
    required this.metric,
    required this.latest,
    required this.change,
    required this.days,
    required this.sampleSize,
  });

  final String metric;
  final double latest;
  final double change;
  final int days;
  final int sampleSize;
}

class BodyFatEstimateRange {
  const BodyFatEstimateRange({
    required this.minimumPercent,
    required this.centralPercent,
    required this.maximumPercent,
    required this.waistToHeightRatio,
    required this.confidence,
    required this.label,
  });

  final double minimumPercent;
  final double centralPercent;
  final double maximumPercent;
  final double waistToHeightRatio;
  final String confidence;
  final String label;
}

class LeanMassTrend {
  const LeanMassTrend({
    required this.earliestKilograms,
    required this.latestKilograms,
    required this.changeKilograms,
    required this.sampleSize,
    required this.label,
  });

  final double earliestKilograms;
  final double latestKilograms;
  final double changeKilograms;
  final int sampleSize;
  final String label;
}

class PhotoComparison {
  const PhotoComparison({
    required this.before,
    required this.after,
    required this.daysBetween,
    required this.weightChangeKilograms,
    required this.available,
  });

  final ProgressPhoto? before;
  final ProgressPhoto? after;
  final int daysBetween;
  final double? weightChangeKilograms;
  final bool available;
}

class MeasurementReminder {
  const MeasurementReminder({
    required this.nextDate,
    required this.daysRemaining,
    required this.status,
    required this.cadenceDays,
    required this.reason,
  });

  final DateTime nextDate;
  final int daysRemaining;
  final String status;
  final int cadenceDays;
  final String reason;
}

class GoalProjectionPoint {
  const GoalProjectionPoint({
    required this.week,
    required this.lowerKilograms,
    required this.centralKilograms,
    required this.upperKilograms,
  });

  final int week;
  final double lowerKilograms;
  final double centralKilograms;
  final double upperKilograms;
}

class GoalProjectionBand {
  const GoalProjectionBand({
    required this.targetKilograms,
    required this.estimatedWeeks,
    required this.points,
    required this.status,
    required this.assumption,
  });

  final double targetKilograms;
  final int estimatedWeeks;
  final List<GoalProjectionPoint> points;
  final String status;
  final String assumption;
}

class PlateauCalorieReview {
  const PlateauCalorieReview({
    required this.status,
    required this.currentCalories,
    required this.suggestedCalories,
    required this.adjustment,
    required this.reason,
    required this.reviewAfterDays,
  });

  final String status;
  final int currentCalories;
  final int suggestedCalories;
  final int adjustment;
  final String reason;
  final int reviewAfterDays;
}

class BodyCompositionEngine {
  const BodyCompositionEngine._();

  static List<SmoothedWeightPoint> smoothedWeightTrend(
    List<WeightEntry> weights, {
    double alpha = .35,
  }) {
    if (weights.isEmpty) return const [];
    final sorted = [...weights]
      ..sort((left, right) => left.recordedAt.compareTo(right.recordedAt));
    var trend = sorted.first.kilograms;
    return [
      for (final entry in sorted)
        SmoothedWeightPoint(
          date: entry.recordedAt,
          rawKilograms: entry.kilograms,
          trendKilograms: trend = alpha * entry.kilograms + (1 - alpha) * trend,
        ),
    ];
  }

  static WeeklyWeightRate weeklyRate(List<WeightEntry> weights) {
    if (weights.isEmpty) {
      return const WeeklyWeightRate(
        currentAverage: 0,
        previousAverage: 0,
        kilogramsPerWeek: 0,
        percentPerWeek: 0,
        sampleDays: 0,
        label: 'NO DATA',
      );
    }
    final sorted = [...weights]
      ..sort((left, right) => right.recordedAt.compareTo(left.recordedAt));
    final anchor = sorted.first.recordedAt;
    final current = sorted
        .where(
          (item) =>
              anchor.difference(item.recordedAt).inDays >= 0 &&
              anchor.difference(item.recordedAt).inDays <= 6,
        )
        .map((item) => item.kilograms)
        .toList();
    final previous = sorted
        .where(
          (item) =>
              anchor.difference(item.recordedAt).inDays >= 7 &&
              anchor.difference(item.recordedAt).inDays <= 13,
        )
        .map((item) => item.kilograms)
        .toList();
    final currentAverage = _average(current);
    final previousAverage = previous.isEmpty
        ? currentAverage
        : _average(previous);
    final change = currentAverage - previousAverage;
    final percent = previousAverage == 0 ? 0.0 : change / previousAverage * 100;
    return WeeklyWeightRate(
      currentAverage: currentAverage,
      previousAverage: previousAverage,
      kilogramsPerWeek: change,
      percentPerWeek: percent,
      sampleDays: current.length + previous.length,
      label: previous.isEmpty
          ? 'BUILDING BASELINE'
          : percent > .15
          ? 'RISING'
          : percent < -.15
          ? 'FALLING'
          : 'STABLE',
    );
  }

  static MeasurementTrend measurementTrend(
    List<BodyMeasurementLog> logs, {
    String metric = 'waist',
  }) {
    if (logs.isEmpty) {
      return MeasurementTrend(
        metric: metric,
        latest: 0,
        change: 0,
        days: 0,
        sampleSize: 0,
      );
    }
    final sorted = [...logs]
      ..sort((left, right) => left.recordedAt.compareTo(right.recordedAt));
    double value(BodyMeasurementLog item) => switch (metric) {
      'neck' => item.neckCentimeters,
      'chest' => item.chestCentimeters,
      'hips' => item.hipsCentimeters,
      'arm' => item.upperArmCentimeters,
      'thigh' => item.thighCentimeters,
      _ => item.waistCentimeters,
    };
    final valid = sorted.where((item) => value(item) > 0).toList();
    if (valid.isEmpty) {
      return MeasurementTrend(
        metric: metric,
        latest: 0,
        change: 0,
        days: 0,
        sampleSize: 0,
      );
    }
    return MeasurementTrend(
      metric: metric,
      latest: value(valid.last),
      change: value(valid.last) - value(valid.first),
      days: valid.last.recordedAt.difference(valid.first.recordedAt).inDays,
      sampleSize: valid.length,
    );
  }

  static BodyFatEstimateRange bodyFatRange({
    required double weightKilograms,
    required double heightCentimeters,
    required double waistCentimeters,
    double neckCentimeters = 0,
    double hipsCentimeters = 0,
  }) {
    if (weightKilograms <= 0 ||
        heightCentimeters <= 0 ||
        waistCentimeters <= 0) {
      return const BodyFatEstimateRange(
        minimumPercent: 0,
        centralPercent: 0,
        maximumPercent: 0,
        waistToHeightRatio: 0,
        confidence: 'NONE',
        label: 'MEASUREMENTS NEEDED',
      );
    }
    final ratio = waistCentimeters / heightCentimeters;
    final bmi =
        weightKilograms / math.pow(heightCentimeters / 100, 2).toDouble();
    final central = (ratio * 45 + bmi * .2 - 6).clamp(8, 45).toDouble();
    final contextAvailable = neckCentimeters > 0 && hipsCentimeters > 0;
    final spread = contextAvailable ? 4.0 : 6.0;
    return BodyFatEstimateRange(
      minimumPercent: (central - spread).clamp(3, 50),
      centralPercent: central,
      maximumPercent: (central + spread).clamp(5, 55),
      waistToHeightRatio: ratio,
      confidence: contextAvailable ? 'CONTEXTUAL RANGE' : 'BROAD RANGE',
      label: ratio < .5
          ? 'WAIST/HEIGHT BELOW 0.50'
          : ratio < .6
          ? 'WAIST/HEIGHT WATCH ZONE'
          : 'WAIST/HEIGHT HIGH ZONE',
    );
  }

  static LeanMassTrend leanMassTrend({
    required List<BodyMeasurementLog> logs,
    required double heightCentimeters,
  }) {
    if (logs.isEmpty || heightCentimeters <= 0) {
      return const LeanMassTrend(
        earliestKilograms: 0,
        latestKilograms: 0,
        changeKilograms: 0,
        sampleSize: 0,
        label: 'NO DATA',
      );
    }
    final sorted = [...logs]
      ..sort((left, right) => left.recordedAt.compareTo(right.recordedAt));
    double estimate(BodyMeasurementLog item) {
      final range = bodyFatRange(
        weightKilograms: item.weightKilograms,
        heightCentimeters: heightCentimeters,
        waistCentimeters: item.waistCentimeters,
        neckCentimeters: item.neckCentimeters,
        hipsCentimeters: item.hipsCentimeters,
      );
      return item.weightKilograms * (1 - range.centralPercent / 100);
    }

    final earliest = estimate(sorted.first);
    final latest = estimate(sorted.last);
    final change = latest - earliest;
    return LeanMassTrend(
      earliestKilograms: earliest,
      latestKilograms: latest,
      changeKilograms: change,
      sampleSize: sorted.length,
      label: sorted.length < 3
          ? 'EARLY ESTIMATE'
          : change > .5
          ? 'ESTIMATED LEAN MASS UP'
          : change < -.5
          ? 'ESTIMATED LEAN MASS DOWN'
          : 'ESTIMATED LEAN MASS STABLE',
    );
  }

  static PhotoComparison photoComparison(List<ProgressPhoto> photos) {
    if (photos.length < 2) {
      return PhotoComparison(
        before: photos.isEmpty ? null : photos.first,
        after: null,
        daysBetween: 0,
        weightChangeKilograms: null,
        available: false,
      );
    }
    final sorted = [...photos]
      ..sort((left, right) => left.recordedAt.compareTo(right.recordedAt));
    final before = sorted.first;
    final after = sorted.last;
    final change =
        before.weightKilograms == null || after.weightKilograms == null
        ? null
        : after.weightKilograms! - before.weightKilograms!;
    return PhotoComparison(
      before: before,
      after: after,
      daysBetween: after.recordedAt.difference(before.recordedAt).inDays,
      weightChangeKilograms: change,
      available: true,
    );
  }

  static MeasurementReminder reminder({
    required List<BodyMeasurementLog> logs,
    required DateTime now,
  }) {
    final latest = logs.isEmpty
        ? null
        : ([...logs]..sort(
                (left, right) => right.recordedAt.compareTo(left.recordedAt),
              ))
              .first;
    final cadence = logs.length >= 3 ? 28 : 14;
    final next = latest == null
        ? now
        : latest.recordedAt.add(Duration(days: cadence));
    final days = DateTime(
      next.year,
      next.month,
      next.day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;
    return MeasurementReminder(
      nextDate: next,
      daysRemaining: math.max(0, days),
      status: latest == null || days <= 0 ? 'DUE' : 'SCHEDULED',
      cadenceDays: cadence,
      reason: latest == null
          ? 'Create the first consistent morning baseline.'
          : 'Use the same conditions; more frequent tape measurements add noise.',
    );
  }

  static GoalProjectionBand projection({
    required double currentKilograms,
    required double targetKilograms,
    required double weeklyRateKilograms,
    int horizonWeeks = 16,
  }) {
    if (currentKilograms <= 0 || targetKilograms <= 0) {
      return const GoalProjectionBand(
        targetKilograms: 0,
        estimatedWeeks: 0,
        points: [],
        status: 'NO TARGET',
        assumption: 'Current and target weights are required.',
      );
    }
    final direction = targetKilograms >= currentKilograms ? 1.0 : -1.0;
    final defaultRate = currentKilograms * .004 * direction;
    final rate =
        weeklyRateKilograms.abs() < .05 ||
            weeklyRateKilograms.sign != direction.sign
        ? defaultRate
        : weeklyRateKilograms.clamp(
            -currentKilograms * .01,
            currentKilograms * .01,
          );
    final gap = (targetKilograms - currentKilograms).abs();
    final estimated = rate == 0 ? 0 : (gap / rate.abs()).ceil();
    final weeks = math.min(horizonWeeks, math.max(1, estimated));
    return GoalProjectionBand(
      targetKilograms: targetKilograms,
      estimatedWeeks: estimated,
      points: [
        for (var week = 0; week <= weeks; week++)
          GoalProjectionPoint(
            week: week,
            lowerKilograms:
                currentKilograms + rate * week - currentKilograms * .001 * week,
            centralKilograms: currentKilograms + rate * week,
            upperKilograms:
                currentKilograms + rate * week + currentKilograms * .001 * week,
          ),
      ],
      status: estimated <= horizonWeeks ? 'TARGET IN RANGE' : 'BEYOND HORIZON',
      assumption:
          'Projection assumes the smoothed weekly rate continues; it is a band, not a promise.',
    );
  }

  static PlateauCalorieReview calorieReview({
    required String phase,
    required int currentCalories,
    required List<WeightEntry> weights,
    required double nutritionAdherence,
  }) {
    final rate = weeklyRate(weights);
    if (rate.sampleDays < 8) {
      return PlateauCalorieReview(
        status: 'MORE DATA',
        currentCalories: currentCalories,
        suggestedCalories: currentCalories,
        adjustment: 0,
        reason: 'Collect at least eight days before changing intake.',
        reviewAfterDays: 7,
      );
    }
    if (nutritionAdherence < .8) {
      return PlateauCalorieReview(
        status: 'HOLD',
        currentCalories: currentCalories,
        suggestedCalories: currentCalories,
        adjustment: 0,
        reason:
            'Improve logging consistency before interpreting a calorie plateau.',
        reviewAfterDays: 14,
      );
    }
    var adjustment = 0;
    var status = 'ON TRACK';
    var reason = 'The smoothed rate matches the phase; keep calories stable.';
    if (phase == 'Fat loss') {
      if (rate.percentPerWeek > -.15) {
        adjustment = -100;
        status = 'PLATEAU REVIEW';
        reason = 'A consistent flat fat-loss trend supports a small reduction.';
      } else if (rate.percentPerWeek < -1) {
        adjustment = 150;
        status = 'LOSS TOO FAST';
        reason = 'The trend is faster than the conservative guardrail.';
      }
    } else if (phase == 'Muscle gain') {
      if (rate.percentPerWeek < .1) {
        adjustment = 100;
        status = 'GAIN PLATEAU';
        reason = 'A consistent flat gain phase supports a small addition.';
      } else if (rate.percentPerWeek > .5) {
        adjustment = -100;
        status = 'GAIN TOO FAST';
        reason = 'The gain rate is above the conservative phase band.';
      }
    }
    return PlateauCalorieReview(
      status: status,
      currentCalories: currentCalories,
      suggestedCalories: (currentCalories + adjustment).clamp(1200, 5000),
      adjustment: adjustment,
      reason: reason,
      reviewAfterDays: 14,
    );
  }

  static double _average(List<double> values) =>
      values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;
}
