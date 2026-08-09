import 'dart:convert';

import 'package:flutter/material.dart';

import 'operational_readiness_engine.dart';
import 'secure_clipboard.dart';
import 'state/fitness_store.dart';

class OperationsStudioPage extends StatefulWidget {
  const OperationsStudioPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<OperationsStudioPage> createState() => _OperationsStudioPageState();
}

class _OperationsStudioPageState extends State<OperationsStudioPage> {
  late DashboardConfiguration _dashboard;
  int _quietStart = 22 * 60;
  int _quietEnd = 7 * 60;
  int _maxReminders = 4;
  late final PerformanceBudgetReport _performance;

  @override
  void initState() {
    super.initState();
    _dashboard = _loadDashboard();
    final timer = Stopwatch()..start();
    jsonEncode(widget.store.data.toJson());
    timer.stop();
    _performance = OperationalReadinessEngine.performanceBudget({
      'json-serialization-ms': timer.elapsedMicroseconds / 1000,
    });
  }

  DashboardConfiguration _loadDashboard() {
    final saved = widget.store.capabilityStateFor(510).note;
    if (saved.isNotEmpty) {
      try {
        return OperationalReadinessEngine.importDashboard(saved);
      } on Object {
        // A malformed layout never blocks the operational controls.
      }
    }
    return OperationalReadinessEngine.dashboardPreset(
      widget.store.profile?.goal ?? 'balanced',
    );
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveDashboard() async {
    final encoded = OperationalReadinessEngine.exportDashboard(_dashboard);
    await widget.store.saveCapabilityState(
      widget.store
          .capabilityStateFor(510)
          .copyWith(
            enabled: true,
            note: encoded,
            lastResult: 'Dashboard layout verified and saved locally.',
            updatedAt: DateTime.now(),
          ),
    );
    if (mounted) _message('Dashboard layout saved locally.');
  }

  Future<void> _copyDashboard() async {
    await setSecureClipboard(
      OperationalReadinessEngine.exportDashboard(_dashboard),
    );
    if (mounted) _message('Dashboard backup copied for two minutes.');
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 5,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('OPERATIONS STUDIO'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'DASHBOARD', icon: Icon(Icons.dashboard_outlined)),
            Tab(text: 'REMINDERS', icon: Icon(Icons.notifications_outlined)),
            Tab(text: 'LOCALES', icon: Icon(Icons.translate_outlined)),
            Tab(text: 'PERFORMANCE', icon: Icon(Icons.speed_outlined)),
            Tab(text: 'DATA', icon: Icon(Icons.verified_user_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          _dashboardTab(context),
          _reminderTab(context),
          _localeTab(context),
          _performanceTab(context),
          _dataTab(context),
        ],
      ),
    ),
  );

  Widget _dashboardTab(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
        child: Column(
          children: [
            const _OpsHero(
              icon: Icons.dashboard_customize_outlined,
              title: 'CUSTOM DASHBOARD LAYOUT',
              detail:
                  'Reorder cards, select compact density, reset from the athlete goal, and keep a portable local backup.',
            ),
            SwitchListTile(
              value: _dashboard.compact,
              title: const Text('COMPACT DENSITY'),
              subtitle: Text('Preset: ${_dashboard.preset}'),
              onChanged: (value) => setState(() {
                _dashboard = OperationalReadinessEngine.reorderDashboard(
                  _dashboard,
                  _dashboard.cards,
                  compact: value,
                );
              }),
            ),
          ],
        ),
      ),
      Expanded(
        child: ReorderableListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          itemCount: _dashboard.cards.length,
          onReorderItem: (oldIndex, newIndex) {
            final cards = [..._dashboard.cards];
            final card = cards.removeAt(oldIndex);
            cards.insert(newIndex, card);
            setState(() {
              _dashboard = OperationalReadinessEngine.reorderDashboard(
                _dashboard,
                cards,
              );
            });
          },
          itemBuilder: (context, index) {
            final id = _dashboard.cards[index];
            return Card(
              key: ValueKey(id),
              child: ListTile(
                leading: const Icon(Icons.drag_handle),
                title: Text(id.replaceAll('-', ' ').toUpperCase()),
                trailing: index < 3
                    ? const Icon(Icons.push_pin_outlined, size: 18)
                    : null,
              ),
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _saveDashboard,
                icon: const Icon(Icons.save_outlined),
                label: const Text('SAVE'),
              ),
            ),
            IconButton(
              tooltip: 'Copy layout backup',
              onPressed: _copyDashboard,
              icon: const Icon(Icons.copy_outlined),
            ),
            IconButton(
              tooltip: 'Reset from goal',
              onPressed: () => setState(() {
                _dashboard = OperationalReadinessEngine.dashboardPreset(
                  widget.store.profile?.goal ?? 'balanced',
                );
              }),
              icon: const Icon(Icons.restart_alt),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _reminderTab(BuildContext context) {
    final policy = ReminderPolicy(
      quietStartMinutes: _quietStart,
      quietEndMinutes: _quietEnd,
      maximumPerDay: _maxReminders,
    );
    final candidates = OperationalReadinessEngine.smartReminders(
      data: widget.store.data,
      now: DateTime.now(),
      policy: policy,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _OpsHero(
          icon: Icons.notifications_active_outlined,
          title: 'REMINDER FATIGUE PROTECTION',
          detail:
              'Quiet hours, spacing and a hard daily cap apply before context-aware workout, water, meal or measurement prompts.',
        ),
        const SizedBox(height: 12),
        _MinuteSlider(
          label: 'QUIET START',
          value: _quietStart,
          onChanged: (value) => setState(() => _quietStart = value),
        ),
        _MinuteSlider(
          label: 'QUIET END',
          value: _quietEnd,
          onChanged: (value) => setState(() => _quietEnd = value),
        ),
        Text('MAXIMUM $_maxReminders PROMPTS / DAY'),
        Slider(
          value: _maxReminders.toDouble(),
          min: 1,
          max: 8,
          divisions: 7,
          label: '$_maxReminders',
          onChanged: (value) => setState(() => _maxReminders = value.round()),
        ),
        const Text(
          'TODAY’S CONTEXT-AWARE CANDIDATES',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        if (candidates.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.notifications_off_outlined),
              title: Text('No useful reminder is due.'),
              subtitle: Text('Quiet or fatigue protection may be active.'),
            ),
          ),
        for (final reminder in candidates)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${reminder.priority}')),
              title: Text(reminder.title),
              subtitle: Text(
                '${reminder.reason}\n${_time(reminder.scheduledAt)}',
              ),
              isThreeLine: true,
              trailing: TextButton(
                onPressed: () async {
                  final snoozed = OperationalReadinessEngine.snooze(
                    reminder.scheduledAt,
                    minutes: 30,
                    policy: policy,
                  );
                  await widget.store.recordCapabilityRun(
                    capabilityId: 512,
                    result:
                        '${reminder.kind} snoozed safely to ${snoozed.toIso8601String()}.',
                  );
                  if (mounted) _message('Snoozed to ${_time(snoozed)}.');
                },
                child: const Text('SNOOZE'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _localeTab(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const _OpsHero(
        icon: Icons.translate_outlined,
        title: 'LOCALE READINESS',
        detail:
            'German and Spanish use a verified core catalog plus complete English fallback. Phoenix reports that boundary instead of claiming an unverified full translation.',
      ),
      const SizedBox(height: 12),
      for (final code in const ['el', 'en', 'de', 'es'])
        Builder(
          builder: (context) {
            final report = OperationalReadinessEngine.localeReadiness(code);
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(code.toUpperCase())),
                title: Text(
                  '${OperationalReadinessEngine.localized('today', code)} · ${OperationalReadinessEngine.localized('workout', code)}',
                ),
                subtitle: Text(
                  'Core catalog ${report.coverage}% · fallback ${report.fallbackLanguage.toUpperCase()} · RTL groundwork ${report.isRtlReady ? 'ready' : 'pending'}',
                ),
                trailing: IconButton(
                  tooltip: 'Use ${code.toUpperCase()}',
                  onPressed: () =>
                      widget.store.updatePreferences(languageCode: code),
                  icon: Icon(
                    widget.store.preferences.languageCode == code
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                ),
              ),
            );
          },
        ),
      Card(
        child: ListTile(
          title: const Text('LOCALE-AWARE SAMPLE'),
          subtitle: Text(
            '${OperationalReadinessEngine.formatDate(DateTime.now(), widget.store.preferences.languageCode)} · '
            '${OperationalReadinessEngine.formatDecimal(1234.5, widget.store.preferences.languageCode)} kg',
          ),
        ),
      ),
    ],
  );

  Widget _performanceTab(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const _OpsHero(
        icon: Icons.speed_outlined,
        title: 'LOCAL PERFORMANCE BUDGETS',
        detail:
            'Measurements run on this device. No telemetry leaves Phoenix, and unmeasured targets stay explicitly unmeasured.',
      ),
      const SizedBox(height: 12),
      for (final entry in _performance.budgets.entries)
        Card(
          child: ListTile(
            title: Text(entry.key.toUpperCase()),
            subtitle: Text('Budget ≤ ${entry.value.toStringAsFixed(1)}'),
            trailing: Text(
              _performance.measurements[entry.key]?.toStringAsFixed(2) ??
                  'NOT MEASURED',
              style: TextStyle(
                color: _performance.measurements.containsKey(entry.key)
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      _OpsDetails(
        title: 'REGRESSION REPORT',
        values: _performance.violations.isEmpty
            ? const ['No regression in the measurements available now.']
            : _performance.violations,
      ),
    ],
  );

  Widget _dataTab(BuildContext context) {
    final result = OperationalReadinessEngine.reconcileDuplicates(
      widget.store.data,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _OpsHero(
          icon: Icons.verified_user_outlined,
          title: 'DATA RELIABILITY V4',
          detail:
              'SHA-256 profile metadata, five-snapshot rotation, transactional switching, quarantine recovery and deterministic event reconciliation.',
        ),
        const SizedBox(height: 12),
        _OpsDetails(
          title: 'CURRENT CHECKSUM',
          values: [OperationalReadinessEngine.checksum(widget.store.data)],
        ),
        _OpsDetails(
          title: 'DUPLICATE PREVIEW',
          values: [
            for (final entry in result.removed.entries)
              '${entry.key}: ${entry.value}',
          ],
        ),
        FilledButton.icon(
          onPressed: result.totalRemoved == 0
              ? null
              : () async {
                  final applied = await widget.store.reconcileDuplicateEvents();
                  if (mounted) {
                    _message(
                      '${applied.totalRemoved} duplicate event(s) reconciled. Undo is available.',
                    );
                    setState(() {});
                  }
                },
          icon: const Icon(Icons.cleaning_services_outlined),
          label: Text(
            result.totalRemoved == 0
                ? 'NO DUPLICATES FOUND'
                : 'RECONCILE ${result.totalRemoved} EVENT(S)',
          ),
        ),
        const SizedBox(height: 10),
        if (widget.store.canUndo)
          OutlinedButton.icon(
            onPressed: widget.store.undoLastMutation,
            icon: const Icon(Icons.undo),
            label: Text('UNDO ${widget.store.undoLabel.toUpperCase()}'),
          ),
      ],
    );
  }

  String _time(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

class _MinuteSlider extends StatelessWidget {
  const _MinuteSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('$label ${_label(value)}'),
      Slider(
        value: value.toDouble(),
        min: 0,
        max: 23 * 60 + 30,
        divisions: 47,
        label: _label(value),
        onChanged: (next) => onChanged((next / 30).round() * 30),
      ),
    ],
  );

  String _label(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutes % 60).toString().padLeft(2, '0')}';
}

class _OpsHero extends StatelessWidget {
  const _OpsHero({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.primaryContainer,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, size: 34),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(detail),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _OpsDetails extends StatelessWidget {
  const _OpsDetails({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          for (final value in values)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SelectableText(value),
            ),
        ],
      ),
    ),
  );
}
