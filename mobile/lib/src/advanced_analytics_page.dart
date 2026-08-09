import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'advanced_analytics_engine.dart';
import 'models/fitness_models.dart';
import 'state/fitness_store.dart';

class AdvancedAnalyticsPage extends StatefulWidget {
  const AdvancedAnalyticsPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<AdvancedAnalyticsPage> createState() => _AdvancedAnalyticsPageState();
}

class _AdvancedAnalyticsPageState extends State<AdvancedAnalyticsPage> {
  late String _exercise = widget.store.exerciseLibrary.first;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final logs = store.data.logs;
    final streaks = AdvancedAnalyticsEngine.streaks(
      logs: logs,
      now: DateTime.now(),
    );
    final workload = AdvancedAnalyticsEngine.workloadRatio(
      logs: logs,
      now: DateTime.now(),
    );
    final performance = AdvancedAnalyticsEngine.performanceTimeline(
      _exercise,
      logs,
    );
    final standard = AdvancedAnalyticsEngine.strengthStandard(
      exercise: _exercise,
      logs: logs,
      bodyweightKilograms: store.currentWeightKilograms,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('ADVANCED ANALYTICS')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          Text(
            'Δες την πραγματική τάση',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            'Όγκος, δύναμη, συνέπεια και workload από τα δικά σου logs.',
            style: TextStyle(color: Colors.white.withValues(alpha: .55)),
          ),
          const SizedBox(height: 16),
          _AnalyticsOverview(streaks: streaks, workload: workload),
          const SizedBox(height: 12),
          _MuscleHistoryCard(store: store),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                initialValue: _exercise,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Άσκηση για ανάλυση',
                  prefixIcon: Icon(Icons.fitness_center),
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final exercise in store.exerciseLibrary)
                    DropdownMenuItem(
                      value: exercise,
                      child: Text(exercise, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (value) => setState(() => _exercise = value!),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _PerformanceCard(
            exercise: _exercise,
            points: performance,
            standard: standard,
          ),
          const SizedBox(height: 12),
          _PrTimeline(logs: logs),
          const SizedBox(height: 12),
          _ConsistencyCalendar(logs: logs),
          const SizedBox(height: 12),
          _DurationTrend(logs: logs),
          const SizedBox(height: 12),
          _ExportCard(store: store),
        ],
      ),
    );
  }
}

class _AnalyticsOverview extends StatelessWidget {
  const _AnalyticsOverview({required this.streaks, required this.workload});

  final ConsistencyStreaks streaks;
  final WorkloadRatio workload;

  @override
  Widget build(BuildContext context) {
    final ratioColor = workload.ratio >= .8 && workload.ratio <= 1.3
        ? const Color(0xFF66BB6A)
        : workload.ratio == 0
        ? Colors.white38
        : const Color(0xFFFF7043);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                _OverviewMetric(
                  value: '${streaks.currentDaily}',
                  label: 'Daily streak',
                ),
                _OverviewMetric(
                  value: '${streaks.currentWeekly}',
                  label: 'Weekly streak',
                ),
                _OverviewMetric(
                  value: workload.ratio == 0
                      ? '—'
                      : workload.ratio.toStringAsFixed(2),
                  label: 'A:C ratio',
                  color: ratioColor,
                ),
              ],
            ),
            const Divider(height: 28),
            Row(
              children: [
                Icon(Icons.monitor_heart_outlined, color: ratioColor),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    workload.label,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.value,
    required this.label,
    this.color = const Color(0xFFFF9E80),
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _MuscleHistoryCard extends StatelessWidget {
  const _MuscleHistoryCard({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final history = AdvancedAnalyticsEngine.muscleVolumeHistory(
      logs: store.data.logs,
      now: DateTime.now(),
    );
    final latest = history.last;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MUSCLE VOLUME • 8 ΕΒΔΟΜΑΔΕΣ',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            for (final muscle in AdvancedAnalyticsEngine.muscles) ...[
              Row(
                children: [
                  SizedBox(width: 110, child: Text(muscle)),
                  Expanded(
                    child: Row(
                      children: [
                        for (final week in history)
                          Expanded(
                            child: Container(
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: Color.lerp(
                                  Colors.white12,
                                  const Color(0xFFFF6E40),
                                  ((week.setsByMuscle[muscle] ?? 0) / 14)
                                      .clamp(0, 1)
                                      .toDouble(),
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${latest.setsByMuscle[muscle] ?? 0}',
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
            ],
          ],
        ),
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({
    required this.exercise,
    required this.points,
    required this.standard,
  });

  final String exercise;
  final List<PerformancePoint> points;
  final StrengthStandard standard;

  @override
  Widget build(BuildContext context) {
    final shown = points.reversed.take(10).toList().reversed.toList();
    final maxValue = shown.fold<double>(
      1,
      (best, point) =>
          best > point.estimatedOneRepMax ? best : point.estimatedOneRepMax,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EXERCISE PERFORMANCE & e1RM',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(exercise, style: const TextStyle(color: Color(0xFFFFAB91))),
            const SizedBox(height: 14),
            SizedBox(
              height: 105,
              child: shown.isEmpty
                  ? const Center(
                      child: Text('Κατάγραψε weighted sets για timeline.'),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final point in shown)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    point.estimatedOneRepMax.toStringAsFixed(0),
                                    style: const TextStyle(fontSize: 9),
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    height:
                                        70 *
                                        point.estimatedOneRepMax /
                                        maxValue,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFF6E40),
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            const Divider(height: 26),
            Row(
              children: [
                const Icon(Icons.military_tech, color: Color(0xFFFFB74D)),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Strength standard: ${standard.level} • '
                    '${standard.ratio.toStringAsFixed(2)}× BW',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Text(
                  'Next ${standard.nextTargetKilograms.toStringAsFixed(0)} kg',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PrTimeline extends StatelessWidget {
  const _PrTimeline({required this.logs});

  final List<WorkoutLog> logs;

  @override
  Widget build(BuildContext context) {
    final records = AdvancedAnalyticsEngine.personalRecordTimeline(logs);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PR TIMELINE',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            if (records.isEmpty)
              const Text('Τα νέα strength και hold PRs θα εμφανιστούν εδώ.')
            else
              for (final record in records.take(6))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.emoji_events, size: 17),
                  ),
                  title: Text(record.exercise),
                  subtitle: Text(
                    '${record.kind} • ${record.date.day}/${record.date.month}',
                  ),
                  trailing: Text(
                    record.value,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _ConsistencyCalendar extends StatelessWidget {
  const _ConsistencyCalendar({required this.logs});

  final List<WorkoutLog> logs;

  @override
  Widget build(BuildContext context) {
    final dates = AdvancedAnalyticsEngine.consistencyCalendar(logs);
    final today = DateTime.now();
    final days = [
      for (var offset = 83; offset >= 0; offset--)
        DateTime(
          today.year,
          today.month,
          today.day,
        ).subtract(Duration(days: offset)),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CONSISTENCY CALENDAR • 12 ΕΒΔΟΜΑΔΕΣ',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                for (final day in days)
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: dates.contains(day)
                          ? const Color(0xFFFF6E40)
                          : Colors.white12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationTrend extends StatelessWidget {
  const _DurationTrend({required this.logs});

  final List<WorkoutLog> logs;

  @override
  Widget build(BuildContext context) {
    final durations = AdvancedAnalyticsEngine.sessionDurationTrend(logs);
    final maxDuration = durations.fold<int>(1, (a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SESSION DURATION • 12 ΤΕΛΕΥΤΑΙΕΣ',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 80,
              child: durations.isEmpty
                  ? const Center(child: Text('Δεν υπάρχουν sessions ακόμη.'))
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final duration in durations)
                          Expanded(
                            child: Container(
                              height: 70 * duration / maxDuration,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: const BoxDecoration(
                                color: Color(0xFF8D6E63),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(5),
                                ),
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

class _ExportCard extends StatelessWidget {
  const _ExportCard({required this.store});

  final FitnessStore store;

  Future<void> _copy(BuildContext context, String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label αντιγράφηκε.')));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EXPORT ANALYTICS REPORT',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            const Text(
              'Εξαγωγή χωρίς λογαριασμό σε CSV ή αναλυτικό JSON.',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => _copy(
                    context,
                    AdvancedAnalyticsEngine.exportCsv(
                      logs: store.data.logs,
                      weights: store.data.weights,
                    ),
                    'CSV report',
                  ),
                  icon: const Icon(Icons.table_chart_outlined),
                  label: const Text('Αντιγραφή CSV'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _copy(
                    context,
                    AdvancedAnalyticsEngine.exportJson(
                      logs: store.data.logs,
                      weights: store.data.weights,
                      generatedAt: DateTime.now(),
                    ),
                    'JSON report',
                  ),
                  icon: const Icon(Icons.data_object),
                  label: const Text('Αντιγραφή JSON'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
