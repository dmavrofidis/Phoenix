import 'package:flutter/material.dart';

import 'models/fitness_models.dart';
import 'phoenix_copy.dart';
import 'phoenix_l10n.dart';
import 'training_insights.dart';

class PersonalRecordsSection extends StatelessWidget {
  const PersonalRecordsSection({super.key, required this.records});

  final List<ExerciseRecord> records;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Προσωπικά ρεκόρ',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        if (records.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Τα ρεκόρ θα εμφανιστούν μετά την πρώτη ολοκληρωμένη συνεδρία.',
              ),
            ),
          )
        else
          Card(
            child: Column(
              children: [
                for (
                  var index = 0;
                  index < records.length && index < 5;
                  index++
                )
                  _RecordTile(record: records[index], rank: index + 1),
              ],
            ),
          ),
      ],
    );
  }
}

class TrainingHistorySection extends StatelessWidget {
  const TrainingHistorySection({super.key, required this.logs});

  final List<WorkoutLog> logs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ιστορικό προπονήσεων',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        if (logs.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Δεν υπάρχει ακόμη ολοκληρωμένη προπόνηση.'),
            ),
          )
        else
          for (final log in logs.take(20)) ...[
            _WorkoutHistoryCard(log: log),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record, required this.rank});

  final ExerciseRecord record;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      if (record.hasWeightedRecord)
        context.l10n.text(
          'Εκτιμώμενο μέγιστο ${record.bestEstimatedOneRepMax.toStringAsFixed(1)} kg',
          'e1RM ${record.bestEstimatedOneRepMax.toStringAsFixed(1)} kg',
        ),
      if (record.maxReps > 0) '${record.maxReps} επαν.',
      if (record.hasHoldRecord)
        context.l10n.text(
          '${record.maxHoldSeconds} δευτ. στατική θέση',
          '${record.maxHoldSeconds}s hold',
        ),
    ].join('  •  ');
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: rank == 1
            ? const Color(0xFFFF3D00)
            : Colors.white.withValues(alpha: .08),
        foregroundColor: rank == 1 ? Colors.black : Colors.white,
        child: Text(
          '$rank',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      title: Text(PhoenixCopy.exerciseName(context.l10n, record.exerciseName)),
      subtitle: Text(metrics),
      trailing: const Icon(Icons.military_tech_outlined),
    );
  }
}

class _WorkoutHistoryCard extends StatelessWidget {
  const _WorkoutHistoryCard({required this.log});

  final WorkoutLog log;

  @override
  Widget build(BuildContext context) {
    final volume = log.sets.fold<double>(0, (sum, set) => sum + set.volume);
    return Card(
      child: ExpansionTile(
        leading: const Icon(
          Icons.local_fire_department,
          color: Color(0xFFFF3D00),
        ),
        title: Text(
          PhoenixCopy.workoutNameFromRaw(context.l10n, log.templateName),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${_formatDate(log.completedAt)}  •  ${log.minutes} λεπτά  •  '
          '${log.sets.length} σετ  •  ${_compact(volume)} kg'
          '${log.sessionRpe > 0 ? '  •  RPE ${log.sessionRpe}' : ''}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: [
          if (log.notes.isNotEmpty || log.painSeverity > 0)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: log.painSeverity >= 3
                    ? const Color(0x22EF5350)
                    : Colors.white.withValues(alpha: .04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (log.painSeverity > 0)
                    Text(
                      '${context.l10n.text('Ένδειξη πόνου', 'Pain flag')} ${log.painSeverity}/5'
                      '${log.painArea.isEmpty ? '' : ' • ${log.painArea}'}',
                      style: TextStyle(
                        color: log.painSeverity >= 3
                            ? const Color(0xFFEF9A9A)
                            : const Color(0xFFFFB74D),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  if (log.notes.isNotEmpty) ...[
                    if (log.painSeverity > 0) const SizedBox(height: 4),
                    Text(
                      log.notes,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .62),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (log.sets.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Η συνεδρία δεν περιέχει αναλυτικά σετ.'),
            )
          else
            for (final exercise in _exerciseNames(log.sets))
              _ExerciseHistory(
                exercise: exercise,
                sets: log.sets
                    .where((set) => set.exerciseName == exercise)
                    .toList(),
              ),
        ],
      ),
    );
  }
}

class _ExerciseHistory extends StatelessWidget {
  const _ExerciseHistory({required this.exercise, required this.sets});

  final String exercise;
  final List<ExerciseSetLog> sets;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PhoenixCopy.exerciseName(context.l10n, exercise),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          for (var index = 0; index < sets.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                '${index + 1}. ${_setDescription(context.l10n, sets[index])}',
                style: TextStyle(color: Colors.white.withValues(alpha: .6)),
              ),
            ),
        ],
      ),
    );
  }
}

Iterable<String> _exerciseNames(List<ExerciseSetLog> sets) sync* {
  final seen = <String>{};
  for (final set in sets) {
    if (seen.add(set.exerciseName)) yield set.exerciseName;
  }
}

String _setDescription(PhoenixL10n l, ExerciseSetLog set) {
  final parts = [
    if (set.reps > 0) '${set.reps} επαν.',
    if (set.weightKilograms > 0) '${set.weightKilograms.toStringAsFixed(1)} kg',
    if (set.holdSeconds > 0)
      l.text(
        '${set.holdSeconds} δευτ. στατική θέση',
        '${set.holdSeconds}s hold',
      ),
    l.text('${set.rir} επαναλήψεις σε απόθεμα', 'RIR ${set.rir}'),
  ];
  return parts.join('  •  ');
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String _compact(double value) {
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
  return value.toStringAsFixed(0);
}
