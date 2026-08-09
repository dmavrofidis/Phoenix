import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'local_file_bridge.dart';
import 'models/fitness_models.dart';
import 'state/fitness_store.dart';
import 'structured_import_export_engine.dart';

class StructuredImportExportPage extends StatefulWidget {
  const StructuredImportExportPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<StructuredImportExportPage> createState() =>
      _StructuredImportExportPageState();
}

class _StructuredImportExportPageState
    extends State<StructuredImportExportPage> {
  String _mapping = 'generic';
  List<WorkoutLog> _workoutPreview = const [];
  List<MealEntry> _mealPreview = const [];
  RouteImportSummary? _routePreview;
  String _selectiveBackup = '';
  SelectiveRestorePreview? _restorePreview;
  final Set<String> _selectedSections = {};

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _previewWorkouts() async {
    try {
      final file = await pickLocalFile(
        extensions: const ['csv'],
        maxBytes: 20 * 1024 * 1024,
      );
      if (file == null) return;
      final parsed = StructuredImportExportEngine.parseWorkoutCsv(
        utf8.decode(file.bytes, allowMalformed: false),
        mapping: _mapping,
      );
      setState(() => _workoutPreview = parsed);
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  Future<void> _previewMeals() async {
    try {
      final file = await pickLocalFile(
        extensions: const ['csv'],
        maxBytes: 20 * 1024 * 1024,
      );
      if (file == null) return;
      final parsed = StructuredImportExportEngine.parseNutritionCsv(
        utf8.decode(file.bytes, allowMalformed: false),
      );
      setState(() => _mealPreview = parsed);
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  Future<void> _previewGpx() async {
    try {
      final file = await pickLocalFile(
        extensions: const ['gpx'],
        maxBytes: 30 * 1024 * 1024,
      );
      if (file == null) return;
      final parsed = StructuredImportExportEngine.parseGpx(
        utf8.decode(file.bytes, allowMalformed: false),
      );
      setState(() => _routePreview = parsed);
      await widget.store.recordCapabilityRun(
        capabilityId: 325,
        result:
            '${parsed.points} points • ${parsed.distanceKilometers.toStringAsFixed(2)} km • ${parsed.elevationGainMeters.toStringAsFixed(0)} m gain',
      );
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  Future<void> _saveText(String filename, String mimeType, String text) async {
    final saved = await saveLocalBytes(
      bytes: Uint8List.fromList(utf8.encode(text)),
      filename: filename,
      mimeType: mimeType,
    );
    if (mounted) _message(saved ? '$filename exported.' : 'Export canceled.');
  }

  Future<void> _previewRestore() async {
    final file = await pickLocalFile(
      extensions: const ['json'],
      maxBytes: 20 * 1024 * 1024,
    );
    if (file == null) return;
    final backup = utf8.decode(file.bytes, allowMalformed: false);
    final preview = StructuredImportExportEngine.previewSelectiveRestore(
      backup: backup,
      current: widget.store.data,
    );
    setState(() {
      _selectiveBackup = backup;
      _restorePreview = preview;
      _selectedSections
        ..clear()
        ..addAll(
          preview.availableSections.where(
            const {'logs', 'weights', 'meals', 'recoveryChecks'}.contains,
          ),
        );
    });
  }

  Future<void> _applyRestore() async {
    try {
      await widget.store.restoreBackupSections(
        backup: _selectiveBackup,
        sections: _selectedSections,
      );
      if (mounted) _message('${_selectedSections.length} sections restored.');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('STRUCTURED IMPORT / EXPORT'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'WORKOUTS'),
            Tab(text: 'NUTRITION'),
            Tab(text: 'ROUTES'),
            Tab(text: 'BACKUP'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          ListView(
            padding: const EdgeInsets.all(18),
            children: [
              DropdownButtonFormField<String>(
                initialValue: _mapping,
                decoration: const InputDecoration(
                  labelText: 'CSV mapping',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'generic',
                    child: Text('Generic Phoenix CSV'),
                  ),
                  DropdownMenuItem(
                    value: 'strong',
                    child: Text('Strong-style CSV'),
                  ),
                  DropdownMenuItem(
                    value: 'hevy',
                    child: Text('Hevy-style CSV'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _mapping = value ?? _mapping),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _previewWorkouts,
                icon: const Icon(Icons.upload_file),
                label: const Text('SELECT & PREVIEW CSV'),
              ),
              if (_workoutPreview.isNotEmpty) ...[
                const SizedBox(height: 12),
                _PreviewCard(
                  title: '${_workoutPreview.length} workout session(s)',
                  subtitle:
                      '${_workoutPreview.fold<int>(0, (sum, item) => sum + item.sets.length)} sets validated',
                ),
                FilledButton(
                  onPressed: () async {
                    final imported = await widget.store.importWorkoutLogs(
                      _workoutPreview,
                    );
                    if (mounted) _message('$imported new workout(s) imported.');
                  },
                  child: const Text('APPROVE WORKOUT IMPORT'),
                ),
              ],
            ],
          ),
          ListView(
            padding: const EdgeInsets.all(18),
            children: [
              FilledButton.icon(
                onPressed: _previewMeals,
                icon: const Icon(Icons.upload_file),
                label: const Text('SELECT NUTRITION CSV'),
              ),
              if (_mealPreview.isNotEmpty) ...[
                const SizedBox(height: 12),
                _PreviewCard(
                  title: '${_mealPreview.length} meal(s)',
                  subtitle:
                      '${_mealPreview.fold<int>(0, (sum, item) => sum + item.calories)} total kcal in preview',
                ),
                FilledButton(
                  onPressed: () async {
                    final imported = await widget.store.importMealEntries(
                      _mealPreview,
                    );
                    if (mounted) _message('$imported new meal(s) imported.');
                  },
                  child: const Text('APPROVE NUTRITION IMPORT'),
                ),
              ],
            ],
          ),
          ListView(
            padding: const EdgeInsets.all(18),
            children: [
              FilledButton.icon(
                onPressed: _previewGpx,
                icon: const Icon(Icons.route_outlined),
                label: const Text('SELECT GPX ROUTE'),
              ),
              if (_routePreview case final route?)
                _PreviewCard(
                  title: '${route.distanceKilometers.toStringAsFixed(2)} km',
                  subtitle:
                      '${route.points} points • ${route.elevationGainMeters.toStringAsFixed(0)} m elevation gain',
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _saveText(
                  'phoenix-training-calendar.ics',
                  'text/calendar',
                  StructuredImportExportEngine.calendarIcs(
                    reminders: widget.store.workoutReminders,
                    from: DateTime.now(),
                  ),
                ),
                icon: const Icon(Icons.calendar_month_outlined),
                label: const Text('EXPORT TRAINING CALENDAR ICS'),
              ),
            ],
          ),
          ListView(
            padding: const EdgeInsets.all(18),
            children: [
              OutlinedButton.icon(
                onPressed: () => _saveText(
                  'phoenix-json-schema.json',
                  'application/json',
                  const JsonEncoder.withIndent('  ').convert(
                    StructuredImportExportEngine.jsonSchemaDocumentation(
                      widget.store.data,
                    ),
                  ),
                ),
                icon: const Icon(Icons.schema_outlined),
                label: const Text('EXPORT JSON SCHEMA MAP'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _saveText(
                  'phoenix-incremental.json',
                  'application/json',
                  StructuredImportExportEngine.incremental(
                    baseline: FitnessData.initial(),
                    current: widget.store.data,
                  ).encode(),
                ),
                icon: const Icon(Icons.difference_outlined),
                label: const Text('EXPORT INCREMENTAL BACKUP'),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _previewRestore,
                icon: const Icon(Icons.restore_page_outlined),
                label: const Text('PREVIEW SELECTIVE RESTORE'),
              ),
              if (_restorePreview case final preview?) ...[
                const SizedBox(height: 12),
                for (final section in preview.availableSections)
                  CheckboxListTile(
                    value: _selectedSections.contains(section),
                    title: Text(section),
                    onChanged: (value) => setState(() {
                      if (value ?? false) {
                        _selectedSections.add(section);
                      } else {
                        _selectedSections.remove(section);
                      }
                    }),
                  ),
                if (preview.conflicts.isNotEmpty)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber),
                      title: const Text('CONFLICT PREVIEW'),
                      subtitle: Text(preview.conflicts.join('\n')),
                    ),
                  ),
                FilledButton(
                  onPressed: _selectedSections.isEmpty ? null : _applyRestore,
                  child: const Text('APPROVE SELECTED SECTIONS'),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.verified_outlined),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(subtitle),
    ),
  );
}
