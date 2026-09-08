import 'package:flutter/material.dart';

import 'media_portability_page.dart';
import 'phoenix_l10n.dart';
import 'state/fitness_store.dart';

class PrivateHealthPage extends StatelessWidget {
  const PrivateHealthPage({super.key, required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.l10n.text('Υγεία στη συσκευή', 'On-device health')),
    ),
    body: ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final l = context.l10n;
        final latest = store.wearableSummaries.isEmpty
            ? null
            : (store.wearableSummaries.toList()
                    ..sort((a, b) => b.day.compareTo(a.day)))
                  .first;
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          children: [
            Text(
              l.text(
                'Τα βήματά σου ανήκουν σε εσένα',
                'Your steps belong to you',
              ),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              l.text(
                'Το Phoenix χρησιμοποιεί μόνο στοιχεία που επιλέγεις να εισαγάγεις. Δεν δημιουργεί λογαριασμό και δεν τα στέλνει σε διακομιστή.',
                'Phoenix only uses information you choose to import. It creates no account and sends nothing to a server.',
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Card(
              child: SwitchListTile(
                value: store.preferences.healthConnectionEnabled,
                onChanged: (value) => store.updatePrivateHealthOptions(
                  healthConnectionEnabled: value,
                ),
                secondary: const Icon(Icons.favorite_outline_rounded),
                title: Text(
                  l.text(
                    'Χρησιμοποίησε τα εισαγμένα βήματα στην καθημερινή εικόνα',
                    'Use imported steps in the daily view',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  l.text(
                    'Η επιλογή αποθηκεύεται μόνο σε αυτή τη συσκευή.',
                    'This choice is saved only on this device.',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.watch_outlined),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l.text(
                              'Apple Health και wearable αρχεία',
                              'Apple Health and wearable files',
                            ),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      latest == null
                          ? l.text(
                              'Δεν έχει εισαχθεί ακόμη αρχείο. Μπορείς να επιλέξεις ένα αρχείο εξαγωγής από το κινητό σου.',
                              'No file has been imported yet. You can select an export file from your phone.',
                            )
                          : l.text(
                              'Τελευταία ημέρα: ${latest.day.day}/${latest.day.month} • ${latest.steps} βήματα • πηγή ${latest.source}',
                              'Latest day: ${latest.day.day}/${latest.day.month} • ${latest.steps} steps • source ${latest.source}',
                            ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              MediaPortabilityPage(store: store, initialTab: 3),
                        ),
                      ),
                      icon: const Icon(Icons.file_open_outlined),
                      label: Text(
                        l.text('Εισαγωγή τοπικού αρχείου', 'Import local file'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(
                  l.text(
                    'Άμεση σύνδεση HealthKit',
                    'Direct HealthKit connection',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  l.text(
                    'Θα ενεργοποιηθεί μόνο στην εγκατεστημένη έκδοση iPhone, με ξεχωριστή άδεια για κάθε είδος δεδομένων. Η web εφαρμογή παραμένει με ασφαλή εισαγωγή αρχείου.',
                    'It will be enabled only in the installed iPhone build, with separate permission for every data type. The web app keeps secure file import.',
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
