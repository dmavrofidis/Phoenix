import 'package:flutter/material.dart';

import 'phoenix_l10n.dart';
import 'state/fitness_store.dart';
import 'training_analytics_engine.dart';

class PeriodizationCard extends StatelessWidget {
  const PeriodizationCard({super.key, required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final plan = store.currentPeriodizationPlan;
    final deload = store.deloadAdvice;
    final color = plan.isDeload
        ? const Color(0xFF64B5F6)
        : const Color(0xFFFF6E40);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        border: Border.all(color: color.withValues(alpha: .3)),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'W${plan.week}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${plan.label} • ${l.text('ΚΥΚΛΟΣ 4 ΕΒΔΟΜΑΔΩΝ', '4-WEEK CYCLE')}',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l.isEnglish
                      ? switch (plan.week) {
                          1 => 'Foundation and technique',
                          2 => 'Progressive overload',
                          3 => 'Cycle peak',
                          _ => 'Deload week',
                        }
                      : plan.headline,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  l.isEnglish
                      ? switch (plan.week) {
                          1 => 'Build quality volume with one extra RIR.',
                          2 => 'Normal volume and steady performance gains.',
                          3 =>
                            'Slightly more volume without failure or loose form.',
                          _ => 'Fewer sets, lighter load and more recovery.',
                        }
                      : deload.recommended
                      ? deload.reason
                      : plan.detail,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .55),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MuscleVolumeCard extends StatelessWidget {
  const MuscleVolumeCard({super.key, required this.volumes});

  final List<MuscleVolume> volumes;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.monitor_heart_outlined, color: Color(0xFFFF6E40)),
                SizedBox(width: 9),
                Text(
                  'ΜΥΪΚΟΣ ΟΓΚΟΣ 7 ΗΜΕΡΩΝ',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final volume in volumes) ...[
              Row(
                children: [
                  SizedBox(
                    width: 116,
                    child: Text(
                      volume.muscle,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: volume.progress,
                        minHeight: 7,
                        backgroundColor: Colors.white10,
                        color: volume.status == 'Υψηλά'
                            ? const Color(0xFFEF5350)
                            : volume.status == 'Στόχος'
                            ? const Color(0xFF66BB6A)
                            : const Color(0xFFFF8A65),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 50,
                    child: Text(
                      '${volume.sets} σετ',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFFFFAB91),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            Text(
              'Τα εύρη είναι πρακτικοί δείκτες, όχι ιατρική σύσταση.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .35),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyTrainingReportCard extends StatelessWidget {
  const WeeklyTrainingReportCard({super.key, required this.report});

  final WeeklyTrainingReport report;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF35130D), Color(0xFF15110F)],
        ),
        border: Border.all(color: const Color(0x55FF3D00)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WEEKLY TRAINING REPORT',
            style: TextStyle(
              color: Color(0xFFFF9E80),
              fontWeight: FontWeight.w900,
              letterSpacing: .9,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            report.headline,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            report.action,
            style: TextStyle(color: Colors.white.withValues(alpha: .58)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _ReportMetric(
                value: '${report.workouts}/${report.workoutTarget}',
                label: 'Προπονήσεις',
              ),
              _ReportMetric(value: '${report.sets}', label: 'Σετ'),
              _ReportMetric(value: '${report.minutes}′', label: 'Χρόνος'),
              _ReportMetric(
                value: report.averageRpe == 0
                    ? '—'
                    : report.averageRpe.toStringAsFixed(1),
                label: 'Ø RPE',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportMetric extends StatelessWidget {
  const _ReportMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFFFAB91),
              fontSize: 18,
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
