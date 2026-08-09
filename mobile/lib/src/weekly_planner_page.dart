import 'package:flutter/material.dart';

import 'models/fitness_models.dart';
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
      appBar: AppBar(title: const Text('WEEKLY PLANNER')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          children: [
            Text(
              'Χτίσε τη δική σου εβδομάδα',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Η χειροκίνητη επιλογή υπερισχύει του αυτόματου rotation μόνο '
              'για τη συγκεκριμένη ημέρα.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .58),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            for (var weekday = 1; weekday <= 7; weekday++) ...[
              _DayAssignmentCard(
                weekday: weekday,
                dayName: _dayNames[weekday - 1],
                templates: store.data.templates,
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
              label: const Text('Επαναφορά αυτόματου rotation'),
            ),
          ],
        ),
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
                initialValue: selectedId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: dayName,
                  helperText: selected == null
                      ? 'Αυτόματο πλάνο'
                      : selected.isRecoveryDay
                      ? 'Recovery / rest-day session'
                      : 'Χειροκίνητη ανάθεση',
                  border: const OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Αυτόματο rotation'),
                  ),
                  for (final template in templates)
                    DropdownMenuItem(
                      value: template.id,
                      child: Text(
                        template.name,
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
