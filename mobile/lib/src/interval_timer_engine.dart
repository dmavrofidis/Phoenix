class TimerSegment {
  const TimerSegment({required this.label, required this.seconds});

  final String label;
  final int seconds;
}

class TimerProtocol {
  const TimerProtocol({
    required this.id,
    required this.name,
    required this.rounds,
    required this.segments,
    this.countdownSeconds = 3,
  });

  final String id;
  final String name;
  final int rounds;
  final List<TimerSegment> segments;
  final int countdownSeconds;

  int get roundSeconds => segments.fold(0, (sum, item) => sum + item.seconds);
  int get activeSeconds => roundSeconds * rounds;
  int get totalSeconds => countdownSeconds + activeSeconds;
}

class TimerSnapshot {
  const TimerSnapshot({
    required this.phase,
    required this.round,
    required this.rounds,
    required this.remainingSeconds,
    required this.phaseProgress,
    required this.totalProgress,
    required this.isCountdown,
    required this.isComplete,
  });

  final String phase;
  final int round;
  final int rounds;
  final int remainingSeconds;
  final double phaseProgress;
  final double totalProgress;
  final bool isCountdown;
  final bool isComplete;

  String get announcement => isComplete
      ? 'Timer complete.'
      : isCountdown
      ? 'Starting in $remainingSeconds.'
      : '$phase, round $round of $rounds, $remainingSeconds seconds remaining.';
}

class IntervalTimerEngine {
  const IntervalTimerEngine._();

  static const presets = <TimerProtocol>[
    TimerProtocol(
      id: 'emom-10',
      name: 'EMOM 10',
      rounds: 10,
      segments: [TimerSegment(label: 'EVERY MINUTE', seconds: 60)],
    ),
    TimerProtocol(
      id: 'amrap-12',
      name: 'AMRAP 12',
      rounds: 1,
      segments: [TimerSegment(label: 'WORK', seconds: 720)],
    ),
    TimerProtocol(
      id: 'tabata-8',
      name: 'TABATA 8',
      rounds: 8,
      segments: [
        TimerSegment(label: 'WORK', seconds: 20),
        TimerSegment(label: 'REST', seconds: 10),
      ],
    ),
  ];

  static TimerProtocol custom({
    required String name,
    required int rounds,
    required List<TimerSegment> segments,
    int countdownSeconds = 3,
  }) {
    final normalized = name.trim();
    final activeSeconds = segments.fold<int>(
      0,
      (sum, item) => sum + item.seconds,
    );
    if (normalized.length < 3 ||
        rounds < 1 ||
        rounds > 100 ||
        segments.isEmpty ||
        segments.length > 20 ||
        segments.any(
          (item) =>
              item.label.trim().isEmpty ||
              item.seconds < 1 ||
              item.seconds > 3600,
        ) ||
        countdownSeconds < 0 ||
        countdownSeconds > 30 ||
        activeSeconds * rounds > 7200) {
      throw const FormatException(
        'Timer must be 1–100 rounds and no longer than two hours.',
      );
    }
    return TimerProtocol(
      id: 'custom-${normalized.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}',
      name: normalized,
      rounds: rounds,
      segments: List.unmodifiable(segments),
      countdownSeconds: countdownSeconds,
    );
  }

  static TimerSnapshot snapshot(TimerProtocol timer, Duration elapsed) {
    final elapsedSeconds = elapsed.inMilliseconds ~/ 1000;
    if (elapsedSeconds < timer.countdownSeconds) {
      final remaining = timer.countdownSeconds - elapsedSeconds;
      return TimerSnapshot(
        phase: 'GET READY',
        round: 0,
        rounds: timer.rounds,
        remainingSeconds: remaining,
        phaseProgress: timer.countdownSeconds == 0
            ? 1
            : elapsedSeconds / timer.countdownSeconds,
        totalProgress: (elapsedSeconds / timer.totalSeconds).clamp(0, 1),
        isCountdown: true,
        isComplete: false,
      );
    }
    final activeElapsed = elapsedSeconds - timer.countdownSeconds;
    if (activeElapsed >= timer.activeSeconds) {
      return TimerSnapshot(
        phase: 'COMPLETE',
        round: timer.rounds,
        rounds: timer.rounds,
        remainingSeconds: 0,
        phaseProgress: 1,
        totalProgress: 1,
        isCountdown: false,
        isComplete: true,
      );
    }
    final round = activeElapsed ~/ timer.roundSeconds;
    var withinRound = activeElapsed % timer.roundSeconds;
    late TimerSegment segment;
    for (final candidate in timer.segments) {
      if (withinRound < candidate.seconds) {
        segment = candidate;
        break;
      }
      withinRound -= candidate.seconds;
    }
    return TimerSnapshot(
      phase: segment.label,
      round: round + 1,
      rounds: timer.rounds,
      remainingSeconds: segment.seconds - withinRound,
      phaseProgress: withinRound / segment.seconds,
      totalProgress: (elapsedSeconds / timer.totalSeconds).clamp(0, 1),
      isCountdown: false,
      isComplete: false,
    );
  }

  static String formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }
}
