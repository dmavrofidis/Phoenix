import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'capability_studio_engine.dart';
import 'state/fitness_store.dart';

class CapabilityStudioPage extends StatefulWidget {
  const CapabilityStudioPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<CapabilityStudioPage> createState() => _CapabilityStudioPageState();
}

class _CapabilityStudioPageState extends State<CapabilityStudioPage> {
  final _query = TextEditingController();
  int? _batch;
  CapabilityKind? _kind;
  bool _configuredOnly = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<CapabilitySpec> get _visible {
    final query = _query.text.trim().toLowerCase();
    final configuredIds = widget.store.capabilityStates
        .map((item) => item.capabilityId)
        .toSet();
    return CapabilityStudioEngine.catalog
        .where((item) => query.isEmpty || item.searchText.contains(query))
        .where((item) => _batch == null || item.batch == _batch)
        .where((item) => _kind == null || item.kind == _kind)
        .where((item) => !_configuredOnly || configuredIds.contains(item.id))
        .toList();
  }

  Future<void> _copyAudit() async {
    final payload = {
      'app': 'Phoenix',
      'generatedAt': DateTime.now().toIso8601String(),
      'catalogSize': CapabilityStudioEngine.catalog.length,
      'configured': widget.store.capabilityStates
          .map((item) => item.toJson())
          .toList(),
    };
    await Clipboard.setData(ClipboardData(text: jsonEncode(payload)));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Το local capability audit αντιγράφηκε.')),
    );
  }

  Future<void> _open(CapabilitySpec spec) async {
    var state = widget.store.capabilityStateFor(spec.id);
    var enabled = state.enabled;
    var guardLevel = state.guardLevel.toDouble();
    var mode = state.mode;
    final note = TextEditingController(text: state.note);
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) => StatefulBuilder(
          builder: (context, setSheetState) {
            final draft = state.copyWith(
              enabled: enabled,
              guardLevel: guardLevel.round(),
              mode: mode,
              note: note.text,
            );
            final outcome = CapabilityStudioEngine.evaluate(
              spec: spec,
              data: widget.store.data,
              state: draft,
            );
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  20 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${spec.id} • BATCH ${spec.batch}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      spec.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text('${spec.batchTitle} • ${_kindLabel(spec.kind)}'),
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${outcome.score}')),
                        title: Text(
                          outcome.status,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Text(outcome.summary),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enabled locally'),
                      subtitle: const Text(
                        'No account, cloud, or automatic upload.',
                      ),
                      value: enabled,
                      onChanged: (value) =>
                          setSheetState(() => enabled = value),
                    ),
                    Text('Guard level ${guardLevel.round()}/100'),
                    Slider(
                      value: guardLevel,
                      divisions: 20,
                      max: 100,
                      label: '${guardLevel.round()}',
                      onChanged: (value) =>
                          setSheetState(() => guardLevel = value),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: mode,
                      decoration: const InputDecoration(
                        labelText: 'Operating mode',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'conservative',
                          child: Text('Conservative'),
                        ),
                        DropdownMenuItem(
                          value: 'balanced',
                          child: Text('Balanced'),
                        ),
                        DropdownMenuItem(
                          value: 'progressive',
                          child: Text('Progressive'),
                        ),
                      ],
                      onChanged: (value) =>
                          setSheetState(() => mode = value ?? mode),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: note,
                      maxLength: 500,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Private local note',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    Text(
                      'NEXT SAFE ACTION',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(outcome.nextAction),
                    const SizedBox(height: 8),
                    for (final evidence in outcome.evidence)
                      Text('• $evidence'),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await widget.store.saveCapabilityState(draft);
                              state = widget.store.capabilityStateFor(spec.id);
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
                            },
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('SAVE'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: enabled
                                ? () async {
                                    await widget.store.saveCapabilityState(
                                      draft,
                                    );
                                    final result =
                                        CapabilityStudioEngine.evaluate(
                                          spec: spec,
                                          data: widget.store.data,
                                          state: draft,
                                        );
                                    await widget.store.recordCapabilityRun(
                                      capabilityId: spec.id,
                                      result: result.exportText,
                                    );
                                    if (!context.mounted) return;
                                    await showDialog<void>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(
                                          '${result.status} • ${result.score}/100',
                                        ),
                                        content: SelectableText(
                                          result.exportText,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              await Clipboard.setData(
                                                ClipboardData(
                                                  text: result.exportText,
                                                ),
                                              );
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: const Text('COPY'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (sheetContext.mounted) {
                                      Navigator.pop(sheetContext);
                                    }
                                  }
                                : null,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('RUN LOCAL CHECK'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } finally {
      note.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final visible = _visible;
      final configured = widget.store.capabilityStates.length;
      final runs = widget.store.capabilityStates.fold<int>(
        0,
        (sum, item) => sum + item.runCount,
      );
      return Scaffold(
        appBar: AppBar(
          title: const Text('PHOENIX CAPABILITY STUDIO'),
          actions: [
            IconButton(
              tooltip: 'Copy local audit',
              onPressed: _copyAudit,
              icon: const Icon(Icons.content_copy),
            ),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '289 LOCAL-FIRST CONTROLS',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Αριθμημένα #279–#567. Κάθε control έχει persisted ρύθμιση, evidence score και ασφαλή local εκτέλεση.',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Metric(label: 'CATALOG', value: '289'),
                        _Metric(label: 'CONFIGURED', value: '$configured'),
                        _Metric(label: 'RUNS', value: '$runs'),
                        _Metric(label: 'VISIBLE', value: '${visible.length}'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SearchBar(
                      controller: _query,
                      hintText: 'Search ID, capability, batch or kind…',
                      leading: const Icon(Icons.search),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        DropdownButton<int?>(
                          value: _batch,
                          hint: const Text('All batches'),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All batches'),
                            ),
                            for (var batch = 28; batch <= 57; batch++)
                              DropdownMenuItem<int?>(
                                value: batch,
                                child: Text('Batch $batch'),
                              ),
                          ],
                          onChanged: (value) => setState(() => _batch = value),
                        ),
                        DropdownButton<CapabilityKind?>(
                          value: _kind,
                          hint: const Text('All kinds'),
                          items: [
                            const DropdownMenuItem<CapabilityKind?>(
                              value: null,
                              child: Text('All kinds'),
                            ),
                            for (final kind in CapabilityKind.values)
                              DropdownMenuItem<CapabilityKind?>(
                                value: kind,
                                child: Text(_kindLabel(kind)),
                              ),
                          ],
                          onChanged: (value) => setState(() => _kind = value),
                        ),
                        FilterChip(
                          label: const Text('Configured only'),
                          selected: _configuredOnly,
                          onSelected: (value) =>
                              setState(() => _configuredOnly = value),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (visible.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text('No capability matches the filters.'),
                ),
              )
            else
              SliverList.builder(
                itemCount: visible.length,
                itemBuilder: (context, index) {
                  final spec = visible[index];
                  final state = widget.store.capabilityStateFor(spec.id);
                  final persisted = widget.store.capabilityStates.any(
                    (item) => item.capabilityId == spec.id,
                  );
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                    leading: CircleAvatar(child: Text('${spec.id}')),
                    title: Text(
                      spec.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      'Batch ${spec.batch} • ${_kindLabel(spec.kind)}'
                      '${state.runCount == 0 ? '' : ' • ${state.runCount} run(s)'}',
                    ),
                    trailing: Icon(
                      persisted ? Icons.check_circle : Icons.chevron_right,
                      color: persisted
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onTap: () => _open(spec),
                  );
                },
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      );
    },
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
    label: Text(label),
  );
}

String _kindLabel(CapabilityKind kind) => switch (kind) {
  CapabilityKind.planner => 'Planner',
  CapabilityKind.tracker => 'Tracker',
  CapabilityKind.audit => 'Audit',
  CapabilityKind.automation => 'Automation',
  CapabilityKind.importExport => 'Import / Export',
  CapabilityKind.education => 'Education',
  CapabilityKind.security => 'Security',
  CapabilityKind.timer => 'Timer',
  CapabilityKind.accessibility => 'Accessibility',
};
