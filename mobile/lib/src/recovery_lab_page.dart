import 'dart:async';

import 'package:flutter/material.dart';

import 'recovery_lab_engine.dart';
import 'state/fitness_store.dart';

class RecoveryLabPage extends StatelessWidget {
  const RecoveryLabPage({super.key, required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RECOVERY LAB')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          children: [
            Text(
              'Αποκατάσταση με δεδομένα',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(
              'Ύπνος, κόπωση, ζωτικά σημεία και προπονητική απόδοση — μόνο '
              'στη συσκευή σου.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .55),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _RecoveryStatusCard(store: store),
            const SizedBox(height: 12),
            _BaselineCard(baseline: store.readinessBaseline),
            const SizedBox(height: 12),
            _SleepTrendCard(store: store),
            const SizedBox(height: 12),
            _SorenessBodyMap(store: store),
            const SizedBox(height: 12),
            _RecommendationsCard(
              recommendations: store.recoveryRecommendations,
              onBreathing: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const BreathingTimerPage(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _FatigueHeatmap(cells: store.fatigueHeatmap),
            const SizedBox(height: 12),
            _CorrelationCard(correlation: store.recoveryPerformanceCorrelation),
          ],
        ),
      ),
    );
  }
}

class _RecoveryStatusCard extends StatelessWidget {
  const _RecoveryStatusCard({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final status = store.data.recoveryStatus;
    final ramp = store.currentReturnRamp;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: status.illnessMode,
              onChanged: store.setIllnessMode,
              secondary: Icon(
                status.illnessMode
                    ? Icons.health_and_safety
                    : Icons.shield_outlined,
                color: status.illnessMode
                    ? const Color(0xFFEF5350)
                    : const Color(0xFF81C784),
              ),
              title: const Text(
                'ILLNESS / PAUSE MODE',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                status.illnessMode
                    ? 'Οι προπονήσεις έχουν παγώσει. Προέχει η ανάρρωση.'
                    : 'Ενεργοποίησέ το σε πυρετό, λοίμωξη ή έντονη αδιαθεσία.',
              ),
            ),
            if (ramp != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.trending_up, color: Color(0xFFFF8A65)),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'RETURN RAMP • ΗΜΕΡΑ ${ramp.day}/7',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Text(
                    '${(ramp.loadFactor * 100).round()}% load',
                    style: const TextStyle(color: Color(0xFFFFAB91)),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              LinearProgressIndicator(
                value: ramp.progress,
                minHeight: 7,
                borderRadius: BorderRadius.circular(20),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BaselineCard extends StatelessWidget {
  const _BaselineCard({required this.baseline});

  final ReadinessBaseline baseline;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0x22FF6E40),
                shape: BoxShape.circle,
              ),
              child: Text(
                baseline.sampleDays == 0 ? '—' : '${baseline.latestScore}',
                style: const TextStyle(
                  color: Color(0xFFFF9E80),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ΠΡΟΣΩΠΙΚΟ READINESS BASELINE',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(baseline.label),
                  Text(
                    baseline.sampleDays == 0
                        ? 'Κάνε το πρώτο check-in.'
                        : 'Μ.Ο. ${baseline.averageScore} • '
                              '${baseline.sampleDays} ημέρες • '
                              'Διαφορά ${baseline.deviation >= 0 ? '+' : ''}'
                              '${baseline.deviation}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SleepTrendCard extends StatelessWidget {
  const _SleepTrendCard({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = [
      for (var offset = 13; offset >= 0; offset--)
        DateTime(now.year, now.month, now.day).subtract(Duration(days: offset)),
    ];
    final values = [
      for (final day in days)
        store.data.recoveryChecks
            .where(
              (item) =>
                  item.recordedAt.year == day.year &&
                  item.recordedAt.month == day.month &&
                  item.recordedAt.day == day.day,
            )
            .map((item) => item.sleepHours)
            .firstOrNull,
    ];
    final available = values.whereType<double>().toList();
    final average = available.isEmpty
        ? 0.0
        : available.reduce((a, b) => a + b) / available.length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bedtime_outlined, color: Color(0xFF9575CD)),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'SLEEP TREND • 14 ΗΜΕΡΕΣ',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Text(
                  available.isEmpty ? '—' : '${average.toStringAsFixed(1)} h',
                  style: const TextStyle(
                    color: Color(0xFFB39DDB),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 88,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var index = 0; index < values.length; index++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: values[index] == null
                                  ? 4
                                  : 68 *
                                        (values[index]! / 10)
                                            .clamp(.15, 1)
                                            .toDouble(),
                              decoration: BoxDecoration(
                                color: values[index] == null
                                    ? Colors.white12
                                    : values[index]! >= 7
                                    ? const Color(0xFF7E57C2)
                                    : const Color(0xFFFF7043),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${days[index].day}',
                              style: const TextStyle(
                                fontSize: 8,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SorenessBodyMap extends StatelessWidget {
  const _SorenessBodyMap({required this.store});

  final FitnessStore store;

  static const _areas = ['Ώμοι', 'Στήθος', 'Πλάτη', 'Μέση', 'Ισχία', 'Πόδια'];

  @override
  Widget build(BuildContext context) {
    final values = store.todaysRecoveryCheckIn?.sorenessAreas ?? const {};
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SORENESS BODY MAP',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .7),
            ),
            const SizedBox(height: 5),
            Text(
              'Καταγράφεται μέσα από το καθημερινό readiness check-in.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .48),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final area in _areas)
                  _SorenessChip(area: area, value: values[area] ?? 0),
              ],
            ),
            if (store.todaysRecoveryCheckIn != null) ...[
              const SizedBox(height: 12),
              Text(
                'Βήματα ${store.todaysRecoveryCheckIn!.steps == 0 ? '—' : store.todaysRecoveryCheckIn!.steps}'
                ' • RHR ${store.todaysRecoveryCheckIn!.restingHeartRate == 0 ? '—' : '${store.todaysRecoveryCheckIn!.restingHeartRate} bpm'}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SorenessChip extends StatelessWidget {
  const _SorenessChip({required this.area, required this.value});

  final String area;
  final int value;

  @override
  Widget build(BuildContext context) {
    final color = value >= 4
        ? const Color(0xFFEF5350)
        : value >= 2
        ? const Color(0xFFFFB74D)
        : const Color(0xFF66BB6A);
    return Container(
      width: 98,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .11),
        border: Border.all(color: color.withValues(alpha: .35)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              area,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            '$value',
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  const _RecommendationsCard({
    required this.recommendations,
    required this.onBreathing,
  });

  final List<RecoveryRecommendation> recommendations;
  final VoidCallback onBreathing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'RECOVERY ACTIONS',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: onBreathing,
                  icon: const Icon(Icons.air, size: 17),
                  label: const Text('Breathing'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final recommendation in recommendations)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.check, size: 17)),
                title: Text(
                  recommendation.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(recommendation.detail),
              ),
          ],
        ),
      ),
    );
  }
}

class _FatigueHeatmap extends StatelessWidget {
  const _FatigueHeatmap({required this.cells});

  final List<FatigueCell> cells;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FATIGUE HEATMAP • 28 ΗΜΕΡΕΣ',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final cell in cells)
                  Tooltip(
                    message:
                        '${cell.date.day}/${cell.date.month}: ${cell.score ?? 'χωρίς δεδομένα'}',
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _fatigueColor(cell.score),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _fatigueColor(int? score) => score == null
      ? Colors.white12
      : score >= 76
      ? const Color(0xFF388E3C)
      : score >= 55
      ? const Color(0xFFF9A825)
      : const Color(0xFFD32F2F);
}

class _CorrelationCard extends StatelessWidget {
  const _CorrelationCard({required this.correlation});

  final RecoveryCorrelation correlation;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.scatter_plot, color: Color(0xFFFF8A65), size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RECOVERY × PERFORMANCE',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(correlation.label),
                  Text(
                    'r = ${correlation.value.toStringAsFixed(2)} • '
                    'n = ${correlation.sampleSize}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BreathingTimerPage extends StatefulWidget {
  const BreathingTimerPage({super.key});

  @override
  State<BreathingTimerPage> createState() => _BreathingTimerPageState();
}

class _BreathingTimerPageState extends State<BreathingTimerPage> {
  static const _totalSeconds = 300;
  Timer? _timer;
  int _remaining = _totalSeconds;
  bool _running = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        timer.cancel();
        setState(() {
          _remaining = 0;
          _running = false;
        });
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _totalSeconds - _remaining;
    final cycle = elapsed % 10;
    final inhale = cycle < 4;
    final phaseSeconds = inhale ? 4 - cycle : 10 - cycle;
    return Scaffold(
      appBar: AppBar(title: const Text('DOWNSHIFT BREATHING')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                width: inhale && _running ? 220 : 150,
                height: inhale && _running ? 220 : 150,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x22FF6E40),
                  border: Border.all(color: const Color(0x88FF6E40), width: 3),
                ),
                child: Text(
                  _running ? (inhale ? 'ΕΙΣΠΝΟΗ' : 'ΕΚΠΝΟΗ') : '4 / 6',
                  style: const TextStyle(
                    color: Color(0xFFFFAB91),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '${_remaining ~/ 60}:${(_remaining % 60).toString().padLeft(2, '0')}',
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              Text(
                _running
                    ? '$phaseSeconds″ μέχρι την επόμενη φάση'
                    : '5 λεπτά • 4″ εισπνοή / 6″ εκπνοή',
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _remaining == 0
                    ? () => setState(() => _remaining = _totalSeconds)
                    : _toggle,
                icon: Icon(
                  _remaining == 0
                      ? Icons.replay
                      : _running
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
                label: Text(
                  _remaining == 0
                      ? 'Ξανά'
                      : _running
                      ? 'Παύση'
                      : 'Έναρξη',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
