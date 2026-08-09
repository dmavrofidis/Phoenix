import 'package:flutter/material.dart';

import 'local_collaboration_engine.dart';
import 'models/fitness_models.dart';
import 'secure_clipboard.dart';
import 'state/fitness_store.dart';

class LocalCollaborationPage extends StatefulWidget {
  const LocalCollaborationPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<LocalCollaborationPage> createState() => _LocalCollaborationPageState();
}

class _LocalCollaborationPageState extends State<LocalCollaborationPage> {
  final _import = TextEditingController();
  final _feedback = TextEditingController();
  final _partner = TextEditingController();
  bool _redacted = true;
  double _expiryDays = 7;
  CollaborationPreview? _preview;

  @override
  void initState() {
    super.initState();
    _feedback.text = widget.store.capabilityStateFor(285).note;
    _partner.text = widget.store.capabilityStateFor(286).note;
  }

  @override
  void dispose() {
    _import.dispose();
    _feedback.dispose();
    _partner.dispose();
    super.dispose();
  }

  Future<void> _copyPackage(
    CollaborationPackage package,
    String message,
  ) async {
    await setSecureClipboard(LocalCollaborationEngine.encode(package));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveNote(int id, TextEditingController controller) async {
    final current = widget.store.capabilityStateFor(id);
    await widget.store.saveCapabilityState(
      current.copyWith(note: controller.text),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved only on this device.')));
  }

  void _previewImport() {
    try {
      final result = LocalCollaborationEngine.previewImport(
        code: _import.text,
        current: widget.store.data,
        now: DateTime.now(),
      );
      setState(() => _preview = result);
    } on FormatException catch (error) {
      setState(() => _preview = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('LOCAL COLLABORATION'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'EXPORT'),
            Tab(text: 'IMPORT'),
            Tab(text: 'PARTNER'),
            Tab(text: 'AUDIT'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text(
                'READ-ONLY SHARE PACKAGES',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const Text(
                'Checksum-protected, expiring packages. Phoenix never uploads them.',
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Redact nutrition details'),
                subtitle: const Text(
                  'Photos, PINs and tokens are always excluded.',
                ),
                value: _redacted,
                onChanged: (value) => setState(() => _redacted = value),
              ),
              Text('Expires in ${_expiryDays.round()} day(s)'),
              Slider(
                value: _expiryDays,
                min: 1,
                max: 30,
                divisions: 29,
                label: '${_expiryDays.round()}',
                onChanged: (value) => setState(() => _expiryDays = value),
              ),
              FilledButton.icon(
                onPressed: () => _copyPackage(
                  LocalCollaborationEngine.coachView(
                    data: widget.store.data,
                    now: DateTime.now(),
                    expiresInDays: _expiryDays.round(),
                    redacted: _redacted,
                  ),
                  'Coach-view export copied.',
                ),
                icon: const Icon(Icons.health_and_safety_outlined),
                label: const Text('COPY COACH VIEW'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<WorkoutTemplate>(
                decoration: const InputDecoration(
                  labelText: 'Copy session-plan share code',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final template in widget.store.data.templates)
                    DropdownMenuItem(
                      value: template,
                      child: Text(template.name),
                    ),
                ],
                onChanged: (template) {
                  if (template == null) return;
                  _copyPackage(
                    LocalCollaborationEngine.sessionPlan(
                      template: template,
                      now: DateTime.now(),
                      expiresInDays: _expiryDays.round(),
                    ),
                    'Session-plan share code copied.',
                  );
                },
              ),
            ],
          ),
          ListView(
            padding: const EdgeInsets.all(18),
            children: [
              TextField(
                controller: _import,
                minLines: 5,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'PHXC1 share code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _previewImport,
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('VALIDATE & PREVIEW'),
              ),
              if (_preview case final preview?) ...[
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: Icon(
                      preview.safeToApprove
                          ? Icons.verified
                          : Icons.warning_amber,
                    ),
                    title: Text('${preview.package.kind} • READ ONLY'),
                    subtitle: Text(
                      preview.conflicts.isEmpty
                          ? 'Checksum and expiry are valid. Explicit approval is still required.'
                          : preview.conflicts.join('\n'),
                    ),
                  ),
                ),
              ],
            ],
          ),
          ListView(
            padding: const EdgeInsets.all(18),
            children: [
              TextField(
                controller: _feedback,
                maxLength: 500,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Local coach feedback notes',
                  border: OutlineInputBorder(),
                ),
              ),
              FilledButton(
                onPressed: () => _saveNote(285, _feedback),
                child: const Text('SAVE FEEDBACK LOCALLY'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _partner,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Training partner session plan',
                  hintText: 'Partner name, exercises, spotting boundary…',
                  border: OutlineInputBorder(),
                ),
              ),
              FilledButton(
                onPressed: () => _saveNote(286, _partner),
                child: const Text('SAVE PARTNER SESSION'),
              ),
            ],
          ),
          ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text(
                'COLLABORATION AUDIT TRAIL',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const Text(
                'Only local configuration events are shown; no recipient tracking.',
              ),
              const SizedBox(height: 8),
              for (final state in widget.store.capabilityStates.where(
                (item) => item.capabilityId >= 281 && item.capabilityId <= 290,
              ))
                ListTile(
                  leading: CircleAvatar(child: Text('${state.capabilityId}')),
                  title: Text('Control #${state.capabilityId}'),
                  subtitle: Text(
                    '${state.runCount} run(s) • ${state.updatedAt?.toLocal() ?? 'not updated'}',
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
