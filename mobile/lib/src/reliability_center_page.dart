import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'local_notification_bridge.dart';
import 'release_audit_engine.dart';
import 'state/fitness_store.dart';
import 'workout_notification_sync.dart';

class ReliabilityCenterPage extends StatefulWidget {
  const ReliabilityCenterPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<ReliabilityCenterPage> createState() => _ReliabilityCenterPageState();
}

class _ReliabilityCenterPageState extends State<ReliabilityCenterPage> {
  @override
  void initState() {
    super.initState();
    widget.store.refreshReliabilityData();
  }

  Future<void> _addProfile() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('NEW LOCAL PROFILE'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
          decoration: const InputDecoration(
            labelText: 'Athlete name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ΑΚΥΡΟ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('ΔΗΜΙΟΥΡΓΙΑ'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null) return;
    try {
      await widget.store.createLocalProfile(name);
    } on Object catch (error) {
      if (mounted) _message('$error');
    }
  }

  Future<void> _switchProfile(String id, String name) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Μετάβαση στο $name;'),
        content: const Text(
          'Η τρέχουσα κατάσταση θα αποθηκευτεί και θα φορτωθεί το επιλεγμένο local profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ΑΚΥΡΟ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ΜΕΤΑΒΑΣΗ'),
          ),
        ],
      ),
    );
    if (accepted != true) return;
    await widget.store.switchLocalProfile(id);
    if (mounted) _message('Ενεργό προφίλ: $name');
  }

  Future<void> _addReminder() async {
    var weekday = DateTime.monday;
    var templateId = '';
    var time = const TimeOfDay(hour: 18, minute: 0);
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('LOCAL WORKOUT REMINDER'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: weekday,
                  decoration: const InputDecoration(labelText: 'Ημέρα'),
                  items: [
                    for (var index = 1; index <= 7; index++)
                      DropdownMenuItem(
                        value: index,
                        child: Text(_weekday(index)),
                      ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => weekday = value ?? weekday),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: templateId,
                  decoration: const InputDecoration(labelText: 'Πρόγραμμα'),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Daily recommendation'),
                    ),
                    for (final template in widget.store.data.templates)
                      DropdownMenuItem(
                        value: template.id,
                        child: Text(template.name),
                      ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => templateId = value ?? ''),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule),
                  title: const Text('Ώρα'),
                  trailing: Text(
                    time.format(context),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  onTap: () async {
                    final selected = await showTimePicker(
                      context: context,
                      initialTime: time,
                    );
                    if (selected != null) {
                      setDialogState(() => time = selected);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ΑΚΥΡΟ'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ΑΠΟΘΗΚΕΥΣΗ'),
            ),
          ],
        ),
      ),
    );
    if (accepted != true) return;
    await widget.store.saveWorkoutReminder(
      weekday: weekday,
      minutesSinceMidnight: time.hour * 60 + time.minute,
      templateId: templateId,
    );
    await syncPhoenixWorkoutNotifications(widget.store);
  }

  Future<void> _enableNotifications() async {
    final granted = await requestLocalNotificationPermission();
    final scheduled = granted
        ? await syncPhoenixWorkoutNotifications(widget.store)
        : false;
    if (mounted) {
      _message(
        granted && scheduled
            ? 'Οι ιδιωτικές local notifications ενεργοποιήθηκαν.'
            : granted
            ? 'Η άδεια δόθηκε, αλλά ο προγραμματισμός δεν υποστηρίζεται εδώ.'
            : 'Η άδεια notification δεν δόθηκε ή δεν υποστηρίζεται.',
      );
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final audit = ReleaseAuditEngine.audit(
        data: widget.store.data,
        integrity: widget.store.startupAudit,
        profiles: widget.store.localProfiles,
        diagnostics: widget.store.diagnostics,
        pwaReady: kIsWeb,
      );
      return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('RELIABILITY CENTER'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'STATUS', icon: Icon(Icons.dns_outlined)),
                Tab(text: 'PROFILES', icon: Icon(Icons.people_outline)),
                Tab(
                  text: 'REMINDERS',
                  icon: Icon(Icons.notifications_outlined),
                ),
                Tab(text: 'AUDIT', icon: Icon(Icons.verified_outlined)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _StatusTab(store: widget.store),
              _ProfilesTab(
                store: widget.store,
                onAdd: _addProfile,
                onSwitch: _switchProfile,
              ),
              _RemindersTab(
                store: widget.store,
                onAdd: _addReminder,
                onEnableNotifications: _enableNotifications,
              ),
              _AuditTab(store: widget.store, report: audit),
            ],
          ),
        ),
      );
    },
  );
}

class _StatusTab extends StatelessWidget {
  const _StatusTab({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
    children: [
      _HeroStatus(
        icon: Icons.storage,
        title: 'DRIFT / SQLITE ACTIVE',
        subtitle:
            'Schema v3 • ${store.localProfiles.length} local profile(s) • '
            '${store.startupAudit.checkedRecords} audited records',
      ),
      if (kIsWeb) ...[
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () async {
            final installed = await installPhoenixPwa();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  installed
                      ? 'Το Phoenix εγκαταστάθηκε ως offline PWA.'
                      : 'Το install prompt δεν είναι ακόμη διαθέσιμο ή η εφαρμογή είναι ήδη εγκατεστημένη.',
                ),
              ),
            );
          },
          icon: const Icon(Icons.install_desktop),
          label: const Text('INSTALL OFFLINE PWA'),
        ),
      ],
      const SizedBox(height: 18),
      Text(
        'LOCAL DIAGNOSTIC LOG',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 8),
      if (store.diagnostics.isEmpty)
        const Card(
          child: ListTile(
            leading: Icon(Icons.hourglass_empty),
            title: Text('Δεν υπάρχουν ακόμη diagnostics'),
          ),
        )
      else
        for (final entry in store.diagnostics.take(25))
          Card(
            child: ListTile(
              leading: Icon(
                entry.level == 'warning'
                    ? Icons.warning_amber
                    : Icons.check_circle_outline,
                color: entry.level == 'warning'
                    ? const Color(0xFFFFB74D)
                    : const Color(0xFF66BB6A),
              ),
              title: Text(
                entry.category.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(entry.message),
              trailing: Text(
                _dateTime(entry.createdAt),
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
    ],
  );
}

class _ProfilesTab extends StatelessWidget {
  const _ProfilesTab({
    required this.store,
    required this.onAdd,
    required this.onSwitch,
  });

  final FitnessStore store;
  final VoidCallback onAdd;
  final Future<void> Function(String id, String name) onSwitch;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
    children: [
      const Text(
        'Κάθε προφίλ έχει ανεξάρτητο πρόγραμμα, ιστορικό, διατροφή και vault.',
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.person_add_alt),
        label: const Text('NEW LOCAL PROFILE'),
      ),
      const SizedBox(height: 12),
      for (final profile in store.localProfiles)
        Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(
                profile.isActive ? Icons.person : Icons.person_outline,
              ),
            ),
            title: Text(
              profile.name,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              profile.isActive
                  ? 'ACTIVE • ${_dateTime(profile.updatedAt)}'
                  : 'Updated ${_dateTime(profile.updatedAt)}',
            ),
            trailing: profile.isActive
                ? const Icon(Icons.verified, color: Color(0xFF66BB6A))
                : PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'switch') {
                        onSwitch(profile.id, profile.name);
                      }
                      if (value == 'delete') {
                        store.deleteLocalProfile(profile.id);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'switch', child: Text('Μετάβαση')),
                      PopupMenuItem(value: 'delete', child: Text('Διαγραφή')),
                    ],
                  ),
          ),
        ),
    ],
  );
}

class _RemindersTab extends StatelessWidget {
  const _RemindersTab({
    required this.store,
    required this.onAdd,
    required this.onEnableNotifications,
  });

  final FitnessStore store;
  final VoidCallback onAdd;
  final VoidCallback onEnableNotifications;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_alarm),
            label: const Text('ADD REMINDER'),
          ),
          OutlinedButton.icon(
            onPressed: onEnableNotifications,
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('ENABLE NOTIFICATIONS'),
          ),
        ],
      ),
      const SizedBox(height: 14),
      if (store.workoutReminders.isEmpty)
        const Card(
          child: ListTile(
            leading: Icon(Icons.notifications_off_outlined),
            title: Text('Δεν υπάρχουν reminders'),
            subtitle: Text('Δημιούργησε εβδομαδιαίο local reminder.'),
          ),
        )
      else
        for (final reminder in store.workoutReminders)
          Card(
            child: SwitchListTile(
              secondary: IconButton(
                tooltip: 'Διαγραφή reminder',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  await store.removeWorkoutReminder(reminder.id);
                  await syncPhoenixWorkoutNotifications(store);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Το reminder διαγράφηκε.'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () async {
                          await store.undoLastMutation();
                          await syncPhoenixWorkoutNotifications(store);
                        },
                      ),
                    ),
                  );
                },
              ),
              title: Text(
                '${_weekday(reminder.weekday)} • ${reminder.timeLabel}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                reminder.templateId.isEmpty
                    ? 'Daily recommendation'
                    : store.data.templates
                              .where((item) => item.id == reminder.templateId)
                              .map((item) => item.name)
                              .firstOrNull ??
                          'Unknown workout',
              ),
              value: reminder.enabled,
              onChanged: (value) async {
                await store.toggleWorkoutReminder(reminder.id, value);
                await syncPhoenixWorkoutNotifications(store);
              },
            ),
          ),
    ],
  );
}

class _AuditTab extends StatelessWidget {
  const _AuditTab({required this.store, required this.report});

  final FitnessStore store;
  final ReleaseAuditReport report;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
    children: [
      _HeroStatus(
        icon: report.releaseReady ? Icons.verified : Icons.warning_amber,
        title: 'RELEASE AUDIT ${report.score}/100',
        subtitle: report.releaseReady
            ? 'No blocking security, integrity or accessibility failure.'
            : 'Blocking audit findings require attention.',
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<int>(
        initialValue: store.preferences.lockTimeoutMinutes,
        decoration: const InputDecoration(
          labelText: 'App lock timeout',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: 0, child: Text('Immediately')),
          DropdownMenuItem(value: 1, child: Text('After 1 minute')),
          DropdownMenuItem(value: 5, child: Text('After 5 minutes')),
          DropdownMenuItem(value: 15, child: Text('After 15 minutes')),
          DropdownMenuItem(value: 30, child: Text('After 30 minutes')),
          DropdownMenuItem(value: 60, child: Text('After 60 minutes')),
        ],
        onChanged: (value) =>
            store.updatePreferences(lockTimeoutMinutes: value),
      ),
      const SizedBox(height: 12),
      for (final check in report.checks)
        Card(
          child: ListTile(
            leading: Icon(
              switch (check.status) {
                ReleaseAuditStatus.pass => Icons.check_circle,
                ReleaseAuditStatus.warning => Icons.warning_amber,
                ReleaseAuditStatus.fail => Icons.cancel,
              },
              color: switch (check.status) {
                ReleaseAuditStatus.pass => const Color(0xFF66BB6A),
                ReleaseAuditStatus.warning => const Color(0xFFFFB74D),
                ReleaseAuditStatus.fail => const Color(0xFFEF5350),
              },
            ),
            title: Text(
              check.title,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(check.detail),
          ),
        ),
    ],
  );
}

class _HeroStatus extends StatelessWidget {
  const _HeroStatus({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [Color(0xFF102336), Color(0xFF070707)],
      ),
      border: Border.all(color: Theme.of(context).colorScheme.primary),
    ),
    child: Row(
      children: [
        Icon(icon, size: 42, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(subtitle),
            ],
          ),
        ),
      ],
    ),
  );
}

String _weekday(int value) => const {
  1: 'Δευτέρα',
  2: 'Τρίτη',
  3: 'Τετάρτη',
  4: 'Πέμπτη',
  5: 'Παρασκευή',
  6: 'Σάββατο',
  7: 'Κυριακή',
}[value]!;

String _dateTime(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/'
    '${value.month.toString().padLeft(2, '0')} '
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';
