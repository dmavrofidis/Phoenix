import 'package:flutter/material.dart';

import 'models/fitness_models.dart';
import 'state/fitness_store.dart';

class ProgramHistoryPage extends StatelessWidget {
  const ProgramHistoryPage({
    super.key,
    required this.store,
    required this.templateId,
  });

  final FitnessStore store;
  final String templateId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VERSION HISTORY')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final versions = store.historyForTemplate(templateId);
          final template = store.data.templates
              .where((item) => item.id == templateId)
              .firstOrNull;
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            children: [
              Text(
                template?.name ?? 'Πρόγραμμα',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Κάθε ουσιαστική αποθήκευση κρατά αυτόματα το προηγούμενο '
                'snapshot τοπικά στη συσκευή.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .58),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              if (versions.isEmpty)
                const _EmptyHistory()
              else
                for (final version in versions) ...[
                  _VersionCard(
                    version: version,
                    onRestore: () => _restore(context, version),
                  ),
                  const SizedBox(height: 10),
                ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _restore(BuildContext context, ProgramVersion version) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Επαναφορά έκδοσης;'),
        content: const Text(
          'Η τρέχουσα μορφή θα κρατηθεί επίσης στο ιστορικό, ώστε να μην '
          'χαθεί καμία αλλαγή.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Άκυρο'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Επαναφορά'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await store.restoreProgramVersion(version);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Η έκδοση επανήλθε με ασφάλεια.')),
    );
  }
}

class _VersionCard extends StatelessWidget {
  const _VersionCard({required this.version, required this.onRestore});

  final ProgramVersion version;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final snapshot = version.snapshot;
    final date = version.savedAt;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Color(0xFFFF6E40)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${date.day}/${date.month}/${date.year} • '
                    '${date.hour.toString().padLeft(2, '0')}:'
                    '${date.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                OutlinedButton(
                  onPressed: onRestore,
                  child: const Text('Επαναφορά'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              snapshot.name,
              style: const TextStyle(
                color: Color(0xFFFFAB91),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${snapshot.exercises.length} ασκήσεις'
              '${snapshot.blocks.isEmpty ? '' : ' • ${snapshot.blocks.length} blocks'}'
              '${snapshot.tags.isEmpty ? '' : ' • ${snapshot.tags.join(', ')}'}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .52),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .04),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(Icons.history_toggle_off, size: 36, color: Colors.white38),
          SizedBox(height: 10),
          Text(
            'Δεν υπάρχουν προηγούμενες εκδόσεις ακόμη.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
