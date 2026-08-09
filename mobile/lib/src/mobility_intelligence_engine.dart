import 'models/fitness_models.dart';

class MobilityJointDefinition {
  const MobilityJointDefinition({
    required this.id,
    required this.name,
    required this.test,
    required this.unit,
    required this.minimumTarget,
    required this.optimalTarget,
    required this.asymmetryTolerance,
    required this.setup,
    required this.stopRule,
  });

  final String id;
  final String name;
  final String test;
  final String unit;
  final double minimumTarget;
  final double optimalTarget;
  final double asymmetryTolerance;
  final String setup;
  final String stopRule;
}

class MobilityJointResult {
  const MobilityJointResult({
    required this.jointId,
    required this.leftValue,
    required this.rightValue,
    required this.lowerValue,
    required this.averageValue,
    required this.asymmetry,
    required this.score,
    required this.status,
    required this.action,
  });

  final String jointId;
  final double leftValue;
  final double rightValue;
  final double lowerValue;
  final double averageValue;
  final double asymmetry;
  final int score;
  final String status;
  final String action;
}

class MobilityAsymmetryItem {
  const MobilityAsymmetryItem({
    required this.jointId,
    required this.jointName,
    required this.difference,
    required this.unit,
    required this.weakerSide,
    required this.severity,
    required this.action,
  });

  final String jointId;
  final String jointName;
  final double difference;
  final String unit;
  final String weakerSide;
  final String severity;
  final String action;
}

class MobilitySnack {
  const MobilitySnack({
    required this.id,
    required this.name,
    required this.focusJoint,
    required this.minutes,
    required this.drills,
    required this.dosing,
    required this.stopRule,
  });

  final String id;
  final String name;
  final String focusJoint;
  final int minutes;
  final List<String> drills;
  final String dosing;
  final String stopRule;
}

class PreLiftMobilityPlan {
  const PreLiftMobilityPlan({
    required this.lift,
    required this.minutes,
    required this.focusJoints,
    required this.drills,
    required this.performanceRule,
  });

  final String lift;
  final int minutes;
  final List<String> focusJoints;
  final List<String> drills;
  final String performanceRule;
}

class PostureBreak {
  const PostureBreak({
    required this.minutesSinceMidnight,
    required this.label,
    required this.actions,
  });

  final int minutesSinceMidnight;
  final String label;
  final List<String> actions;
}

class MobilityRetest {
  const MobilityRetest({
    required this.jointId,
    required this.jointName,
    required this.lastTestedAt,
    required this.nextTestAt,
    required this.status,
    required this.reason,
  });

  final String jointId;
  final String jointName;
  final DateTime? lastTestedAt;
  final DateTime nextTestAt;
  final String status;
  final String reason;
}

class MobilityIntelligenceEngine {
  const MobilityIntelligenceEngine._();

  static const joints = <MobilityJointDefinition>[
    MobilityJointDefinition(
      id: 'ankle-dorsiflexion',
      name: 'ANKLE DORSIFLEXION',
      test: 'Knee-to-wall distance',
      unit: 'cm',
      minimumTarget: 8,
      optimalTarget: 12,
      asymmetryTolerance: 2,
      setup:
          'Heel down, knee tracks over second toe, measure maximum pain-free distance.',
      stopRule: 'Stop if the heel lifts or ankle/knee pain appears.',
    ),
    MobilityJointDefinition(
      id: 'hip-internal-rotation',
      name: 'HIP INTERNAL ROTATION',
      test: 'Seated hip internal rotation',
      unit: '°',
      minimumTarget: 25,
      optimalTarget: 40,
      asymmetryTolerance: 7,
      setup:
          'Sit tall with hip and knee at 90°, rotate the foot outward without pelvis shift.',
      stopRule: 'Stop before pinching, pain or pelvic compensation.',
    ),
    MobilityJointDefinition(
      id: 'shoulder-flexion',
      name: 'SHOULDER FLEXION',
      test: 'Supine shoulder flexion',
      unit: '°',
      minimumTarget: 150,
      optimalTarget: 175,
      asymmetryTolerance: 10,
      setup: 'Ribs down and low back neutral; raise a straight arm overhead.',
      stopRule: 'Stop before rib flare, numbness or shoulder pain.',
    ),
    MobilityJointDefinition(
      id: 'thoracic-rotation',
      name: 'THORACIC ROTATION',
      test: 'Half-kneeling thoracic rotation',
      unit: '°',
      minimumTarget: 40,
      optimalTarget: 55,
      asymmetryTolerance: 8,
      setup: 'Hips square, rotate the upper trunk without lumbar extension.',
      stopRule: 'Stop if the pelvis turns or symptoms radiate.',
    ),
  ];

  static MobilityJointDefinition joint(String id) =>
      joints.firstWhere((item) => item.id == id, orElse: () => joints.first);

  static MobilityJointResult evaluate({
    required String jointId,
    required double leftValue,
    required double rightValue,
    int painLevel = 0,
  }) {
    final definition = joint(jointId);
    final lower = leftValue < rightValue ? leftValue : rightValue;
    final average = (leftValue + rightValue) / 2;
    final asymmetry = (leftValue - rightValue).abs();
    final rangeScore = ((lower / definition.optimalTarget) * 80).round().clamp(
      0,
      80,
    );
    final symmetryScore = asymmetry <= definition.asymmetryTolerance
        ? 20
        : (20 -
                  (asymmetry - definition.asymmetryTolerance) /
                      definition.asymmetryTolerance *
                      10)
              .round()
              .clamp(0, 20);
    final painPenalty = painLevel >= 2
        ? 35
        : painLevel == 1
        ? 10
        : 0;
    final score = (rangeScore + symmetryScore - painPenalty).clamp(0, 100);
    final status = painLevel >= 2
        ? 'PAIN FLAG'
        : lower < definition.minimumTarget
        ? 'LIMITED'
        : asymmetry > definition.asymmetryTolerance
        ? 'ASYMMETRY'
        : lower >= definition.optimalTarget
        ? 'OPTIMAL'
        : 'FUNCTIONAL';
    return MobilityJointResult(
      jointId: jointId,
      leftValue: leftValue,
      rightValue: rightValue,
      lowerValue: lower,
      averageValue: average,
      asymmetry: asymmetry,
      score: score,
      status: status,
      action: status == 'PAIN FLAG'
          ? 'Do not force range; use pain-free motion and seek qualified assessment if persistent.'
          : status == 'LIMITED'
          ? 'Use the matching five-minute snack 4–6 days/week, then retest in 14 days.'
          : status == 'ASYMMETRY'
          ? 'Start with the lower side and use one extra controlled set only.'
          : 'Maintain range with two brief exposures per week.',
    );
  }

  static Map<String, MobilityScreenLog> latestByJoint(
    List<MobilityScreenLog> logs,
  ) {
    final latest = <String, MobilityScreenLog>{};
    for (final log in logs) {
      final current = latest[log.jointId];
      if (current == null || log.recordedAt.isAfter(current.recordedAt)) {
        latest[log.jointId] = log;
      }
    }
    return latest;
  }

  static List<MobilityAsymmetryItem> asymmetryReport(
    List<MobilityScreenLog> logs,
  ) {
    final latest = latestByJoint(logs);
    final result = <MobilityAsymmetryItem>[];
    for (final entry in latest.entries) {
      final definition = joint(entry.key);
      final log = entry.value;
      final difference = (log.leftValue - log.rightValue).abs();
      final ratio = difference / definition.asymmetryTolerance;
      result.add(
        MobilityAsymmetryItem(
          jointId: entry.key,
          jointName: definition.name,
          difference: difference,
          unit: definition.unit,
          weakerSide: log.leftValue < log.rightValue ? 'LEFT' : 'RIGHT',
          severity: ratio > 2
              ? 'HIGH'
              : ratio > 1
              ? 'MODERATE'
              : 'LOW',
          action: ratio > 1
              ? 'Lead with ${log.leftValue < log.rightValue ? 'left' : 'right'}; add one low-intensity set, not extra stretching force.'
              : 'Sides are within the repeatable test tolerance.',
        ),
      );
    }
    result.sort((left, right) => right.difference.compareTo(left.difference));
    return result;
  }

  static const snacks = <MobilitySnack>[
    MobilitySnack(
      id: 'ankle-snack',
      name: 'ANKLE 5',
      focusJoint: 'ankle-dorsiflexion',
      minutes: 5,
      drills: [
        'Calf pulse raise',
        'Knee-to-wall rocks',
        'Slow split-squat iso',
      ],
      dosing: '45s each side per drill, repeat the most limited drill.',
      stopRule: 'Heel stays down and knee tracks cleanly.',
    ),
    MobilitySnack(
      id: 'hip-snack',
      name: 'HIP ROTATION 5',
      focusJoint: 'hip-internal-rotation',
      minutes: 5,
      drills: [
        '90/90 switches',
        'Seated internal-rotation lift-off',
        'Hip airplane support',
      ],
      dosing: '5 slow reps each side; smaller range is acceptable.',
      stopRule: 'No hip pinching or forced end range.',
    ),
    MobilitySnack(
      id: 'shoulder-snack',
      name: 'OVERHEAD 5',
      focusJoint: 'shoulder-flexion',
      minutes: 5,
      drills: ['Wall slide', 'Bench lat rock-back', 'Serratus reach'],
      dosing: '6 slow reps each drill with quiet ribs.',
      stopRule: 'No pain, numbness or rib flare.',
    ),
    MobilitySnack(
      id: 'thoracic-snack',
      name: 'T-SPINE 5',
      focusJoint: 'thoracic-rotation',
      minutes: 5,
      drills: [
        'Open book',
        'Half-kneeling rotation',
        'Quadruped reach-through',
      ],
      dosing: '5 controlled breaths or reps each side.',
      stopRule: 'Hips stay quiet; rotation comes from the upper trunk.',
    ),
  ];

  static MobilitySnack snackFor(String jointId) => snacks.firstWhere(
    (item) => item.focusJoint == jointId,
    orElse: () => snacks.first,
  );

  static PreLiftMobilityPlan preLiftPlan({
    required String lift,
    required List<MobilityScreenLog> logs,
  }) {
    final normalized = lift.toLowerCase();
    final relevant = normalized.contains('squat')
        ? ['ankle-dorsiflexion', 'hip-internal-rotation']
        : normalized.contains('overhead')
        ? ['shoulder-flexion', 'thoracic-rotation']
        : normalized.contains('bench')
        ? ['shoulder-flexion', 'thoracic-rotation']
        : ['hip-internal-rotation', 'thoracic-rotation'];
    final latest = latestByJoint(logs);
    final limited = relevant.where((id) {
      final log = latest[id];
      if (log == null) return true;
      final result = evaluate(
        jointId: id,
        leftValue: log.leftValue,
        rightValue: log.rightValue,
        painLevel: log.painLevel,
      );
      return const {
        'LIMITED',
        'ASYMMETRY',
        'PAIN FLAG',
      }.contains(result.status);
    }).toList();
    final focus = limited.isEmpty ? relevant.take(1).toList() : limited;
    final drills = <String>[
      for (final jointId in focus) ...snackFor(jointId).drills.take(2),
      '2–3 progressive warm-up sets of $lift',
    ];
    return PreLiftMobilityPlan(
      lift: lift,
      minutes: (focus.length * 3 + 3).clamp(5, 10),
      focusJoints: focus,
      drills: drills,
      performanceRule:
          'Mobility work should improve the first warm-up set; never fatigue the target muscles.',
    );
  }

  static List<PostureBreak> postureBreaks({
    required int startMinutes,
    required int endMinutes,
    required int intervalMinutes,
  }) {
    if (endMinutes <= startMinutes || intervalMinutes < 20) return const [];
    final interval = intervalMinutes.clamp(20, 180);
    return [
      for (
        var minute = startMinutes + interval;
        minute < endMinutes;
        minute += interval
      )
        PostureBreak(
          minutesSinceMidnight: minute,
          label:
              '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}',
          actions: const [
            'Stand and take 20–40 steps',
            '3 slow thoracic rotations per side',
            '5 scapular wall slides or reaches',
          ],
        ),
    ].take(12).toList();
  }

  static List<MobilityRetest> retestSchedule(
    List<MobilityScreenLog> logs, {
    DateTime? now,
  }) {
    final anchor = now ?? DateTime.now();
    final latest = latestByJoint(logs);
    return [
      for (final definition in joints)
        (() {
          final log = latest[definition.id];
          if (log == null) {
            return MobilityRetest(
              jointId: definition.id,
              jointName: definition.name,
              lastTestedAt: null,
              nextTestAt: DateTime(anchor.year, anchor.month, anchor.day),
              status: 'DUE',
              reason: 'No baseline measurement saved.',
            );
          }
          final result = evaluate(
            jointId: definition.id,
            leftValue: log.leftValue,
            rightValue: log.rightValue,
            painLevel: log.painLevel,
          );
          final interval =
              const {
                'LIMITED',
                'ASYMMETRY',
                'PAIN FLAG',
              }.contains(result.status)
              ? 14
              : 28;
          final next = DateTime(
            log.recordedAt.year,
            log.recordedAt.month,
            log.recordedAt.day,
          ).add(Duration(days: interval));
          return MobilityRetest(
            jointId: definition.id,
            jointName: definition.name,
            lastTestedAt: log.recordedAt,
            nextTestAt: next,
            status: next.isBefore(anchor) ? 'OVERDUE' : 'SCHEDULED',
            reason:
                '$interval-day retest based on ${result.status.toLowerCase()} status.',
          );
        })(),
    ];
  }
}
