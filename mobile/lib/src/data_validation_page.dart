import 'package:flutter/material.dart';

import 'data_validation_engine.dart';
import 'phoenix_l10n.dart';
import 'state/fitness_store.dart';

class DataValidationPage extends StatelessWidget {
  const DataValidationPage({super.key, required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final l = context.l10n;
        final report = store.validationReport;
        final color = report.isHealthy
            ? const Color(0xFF66BB6A)
            : report.criticalCount > 0
            ? const Color(0xFFEF5350)
            : const Color(0xFFFFB74D);
        return Scaffold(
          appBar: AppBar(
            title: Text(l.text('ΕΛΕΓΧΟΣ ΔΕΔΟΜΕΝΩΝ', 'DATA VALIDATION')),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  border: Border.all(color: color.withValues(alpha: .55)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    SizedBox.square(
                      dimension: 74,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: report.integrityScore / 100,
                            strokeWidth: 8,
                            backgroundColor: Colors.white10,
                            color: color,
                          ),
                          Center(
                            child: Text(
                              '${report.integrityScore}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.isHealthy
                                ? l.text(
                                    'Άριστη ακεραιότητα',
                                    'Excellent integrity',
                                  )
                                : l.text(
                                    'Χρειάζεται έλεγχος',
                                    'Review recommended',
                                  ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l.text(
                              '${report.checkedRecords} εγγραφές ελέγχθηκαν τοπικά.',
                              '${report.checkedRecords} records checked locally.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (report.issues.isEmpty)
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.verified_outlined,
                      color: Color(0xFF66BB6A),
                    ),
                    title: Text(
                      l.text('Δεν βρέθηκαν προβλήματα', 'No issues found'),
                    ),
                    subtitle: Text(
                      l.text(
                        'Οι συσχετίσεις και οι αριθμητικές τιμές είναι έγκυρες.',
                        'References and numeric ranges are valid.',
                      ),
                    ),
                  ),
                )
              else
                ...report.issues.map((issue) => _IssueCard(issue: issue)),
              if (report.hasRepairableIssues) ...[
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () async {
                    await store.repairData();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l.text(
                            'Η επιδιόρθωση ολοκληρώθηκε. Υπάρχει διαθέσιμο Undo.',
                            'Repair completed. Undo is available.',
                          ),
                        ),
                        action: SnackBarAction(
                          label: 'UNDO',
                          onPressed: store.undoLastMutation,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.build_circle_outlined),
                  label: Text(
                    l.text(
                      'Ασφαλής αυτόματη επιδιόρθωση',
                      'Safe automatic repair',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Text(
                l.text(
                  'Ο έλεγχος γίνεται χωρίς αποστολή δεδομένων. Πριν από επιδιόρθωση κρατιέται προσωρινό snapshot.',
                  'Validation runs without uploading data. A temporary snapshot is kept before repair.',
                ),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({required this.issue});

  final ValidationIssue issue;

  @override
  Widget build(BuildContext context) {
    final color = switch (issue.severity) {
      ValidationSeverity.info => Colors.lightBlueAccent,
      ValidationSeverity.warning => const Color(0xFFFFB74D),
      ValidationSeverity.critical => const Color(0xFFEF5350),
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        leading: Icon(Icons.report_gmailerrorred_outlined, color: color),
        title: Text(
          issue.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(issue.detail),
        trailing: issue.repairable
            ? const Icon(Icons.auto_fix_high, size: 18)
            : null,
      ),
    );
  }
}
