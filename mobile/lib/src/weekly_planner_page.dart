import 'package:flutter/material.dart';

import 'models/fitness_models.dart';
import 'phoenix_copy.dart';
import 'phoenix_l10n.dart';
import 'state/fitness_store.dart';

class WeeklyPlannerPage extends StatelessWidget {
  const WeeklyPlannerPage({super.key, required this.store});

  final FitnessStore store;

  static const _dayNames = [
    'Δευτέρα',
    'Τρίτη',
    'Τετάρτη',
    'Πέμπτη',
    'Παρασκευή',
    'Σάββατο',
    'Κυριακή',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.text('Εβδομαδιαίος προγραμματισμός', 'Weekly planner'),
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final next = store.weeklySchedule.nextEntry(DateTime.now());
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            children: [
              Text(
                'Χτίσε τη δική σου εβδομάδα',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Η χειροκίνητη επιλογή υπερισχύει της αυτόματης εναλλαγής μόνο '
                'για τη συγκεκριμένη ημέρα.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .58),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              if (next != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Η επόμενη προπόνησή σου',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${PhoenixCopy.workoutName(context.l10n, next.template)} • ${next.date.day}/${next.date.month}',
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          key: const ValueKey('reschedule-next-workout'),
                          onPressed: () async {
                            final now = DateTime.now();
                            final today = DateTime(
                              now.year,
                              now.month,
                              now.day,
                            );
                            final initial = next.date.isBefore(today)
                                ? today
                                : next.date;
                            final selected = await showDatePicker(
                              context: context,
                              initialDate: initial,
                              firstDate: today,
                              lastDate: today.add(const Duration(days: 14)),
                              helpText: 'Διάλεξε νέα ημέρα',
                              cancelText: 'ΑΚΥΡΟ',
                              confirmText: 'ΜΕΤΑΦΟΡΑ',
                            );
                            if (selected == null) return;
                            await store.rescheduleWorkout(
                              template: next.template,
                              targetDate: selected,
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Η προπόνηση μεταφέρθηκε στις ${selected.day}/${selected.month}.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.event_repeat_outlined),
                          label: const Text('Μεταφορά σε άλλη ημέρα'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              for (var weekday = 1; weekday <= 7; weekday++) ...[
                _DayAssignmentCard(
                  weekday: weekday,
                  dayName: _dayNames[weekday - 1],
                  templates: store.equipmentCompatibleTemplates,
                  selectedId: store.data.weeklyAssignments['$weekday'],
                  onChanged: (templateId) async {
                    await store.assignTemplateToWeekday(weekday, templateId);
                  },
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: store.data.weeklyAssignments.isEmpty
                    ? null
                    : () async {
                        for (var weekday = 1; weekday <= 7; weekday++) {
                          await store.assignTemplateToWeekday(weekday, null);
                        }
                      },
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Επαναφορά αυτόματης εναλλαγής'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DayAssignmentCard extends StatelessWidget {
  const _DayAssignmentCard({
    required this.weekday,
    required this.dayName,
    required this.templates,
    required this.selectedId,
    required this.onChanged,
  });

  final int weekday;
  final String dayName;
  final List<WorkoutTemplate> templates;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = templates
        .where((template) => template.id == selectedId)
        .firstOrNull;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected == null
                    ? Colors.white.withValues(alpha: .05)
                    : const Color(0x22FF3D00),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                '$weekday',
                style: const TextStyle(
                  color: Color(0xFFFF8A65),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selected?.id,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: dayName,
                  helperText: selected == null
                      ? 'Αυτόματο πλάνο'
                      : selected.isRecoveryDay
                      ? 'Ήπιο πρόγραμμα ημέρας ξεκούρασης'
                      : 'Χειροκίνητη ανάθεση',
                  border: const OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Αυτόματη εναλλαγή'),
                  ),
                  for (final template in templates)
                    DropdownMenuItem(
                      value: template.id,
                      child: Text(
                        PhoenixCopy.workoutName(context.l10n, template),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
