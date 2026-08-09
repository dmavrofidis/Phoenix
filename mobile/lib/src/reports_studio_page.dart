import 'package:flutter/material.dart';

import 'reports_studio_engine.dart';
import 'secure_clipboard.dart';
import 'state/fitness_store.dart';

class ReportsStudioPage extends StatefulWidget {
  const ReportsStudioPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<ReportsStudioPage> createState() => _ReportsStudioPageState();
}

class _ReportsStudioPageState extends State<ReportsStudioPage> {
  final Set<PhoenixReportKind> _selected = {
    PhoenixReportKind.weekly,
    PhoenixReportKind.nutrition,
    PhoenixReportKind.recovery,
  };
  PhoenixReportKind _active = PhoenixReportKind.weekly;

  @override
  Widget build(BuildContext context) {
    final reports = [
      for (final kind in _selected)
        ReportsStudioEngine.build(
          data: widget.store.data,
          kind: kind,
          now: DateTime.now(),
        ),
    ];
    final active = reports.firstWhere(
      (item) => item.kind == _active,
      orElse: () => reports.first,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('REPORTS STUDIO')),
      body: ListenableBuilder(
        listenable: widget.store,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const _Hero(),
            const SizedBox(height: 18),
            const Text(
              'CUSTOM REPORT COMPOSER',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final kind in PhoenixReportKind.values)
                  FilterChip(
                    selected: _selected.contains(kind),
                    label: Text(_label(kind)),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _selected.add(kind);
                        _active = kind;
                      } else if (_selected.length > 1) {
                        _selected.remove(kind);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                for (final report in reports)
                  ChoiceChip(
                    selected: report.kind == active.kind,
                    label: Text(_label(report.kind)),
                    onSelected: (_) => setState(() => _active = report.kind),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _ReportCard(report: active),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () async {
                await setSecureClipboard(active.plainText);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report copied locally.')),
                  );
                }
              },
              icon: const Icon(Icons.content_copy),
              label: const Text('COPY REPORT'),
            ),
            const SizedBox(height: 18),
            Card(
              child: const ListTile(
                leading: Icon(Icons.schedule_send_outlined),
                title: Text('LOCAL REPORT SCHEDULE'),
                subtitle: Text(
                  'Weekly reports refresh when you open Phoenix; no account, cloud job or background tracking is required.',
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Print-friendly reports can be copied now or exported through Media & Portability. All calculations use only your local Phoenix data.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  String _label(PhoenixReportKind kind) => switch (kind) {
    PhoenixReportKind.weekly => 'WEEKLY',
    PhoenixReportKind.monthly => 'MONTHLY',
    PhoenixReportKind.nutrition => 'NUTRITION',
    PhoenixReportKind.recovery => 'RECOVERY',
    PhoenixReportKind.strength => 'STRENGTH',
    PhoenixReportKind.calisthenics => 'SKILLS',
    PhoenixReportKind.coach => 'HANDOFF',
  };
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [Color(0xFF5B33CC), Color(0xFF18112E)],
      ),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.summarize_outlined, size: 30),
        SizedBox(height: 8),
        Text(
          'YOUR DATA, MADE USEFUL',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
        SizedBox(height: 4),
        Text(
          'Build clear reports from real local logs. No invented insights and no cloud account.',
        ),
      ],
    ),
  );
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final PhoenixReport report;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            report.title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          Text(
            report.periodLabel,
            style: const TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 12),
          Text(report.summary),
          const SizedBox(height: 14),
          for (final metric in report.metrics)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(metric.label),
              subtitle: metric.detail.isEmpty ? null : Text(metric.detail),
              trailing: Text(
                metric.value,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          if (report.actions.isNotEmpty) ...[
            const Divider(),
            const Text(
              'NEXT ACTIONS',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            for (final action in report.actions)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('• $action'),
              ),
          ],
        ],
      ),
    ),
  );
}
