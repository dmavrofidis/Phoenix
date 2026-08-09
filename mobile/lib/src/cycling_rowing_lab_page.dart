import 'package:flutter/material.dart';

import 'cycling_rowing_engine.dart';
import 'state/fitness_store.dart';

class CyclingRowingLabPage extends StatefulWidget {
  const CyclingRowingLabPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<CyclingRowingLabPage> createState() => _CyclingRowingLabPageState();
}

class _CyclingRowingLabPageState extends State<CyclingRowingLabPage> {
  final _ftp = TextEditingController(text: '240');
  final _testPower = TextEditingController(text: '260');
  final _rideMinutes = TextEditingController(text: '45');
  final _ridePower = TextEditingController(text: '170');
  final _normalizedPower = TextEditingController(text: '180');
  final _cadence = TextEditingController(text: '90');
  final _rowDistance = TextEditingController(text: '2000');
  final _rowMinutes = TextEditingController(text: '8');
  final _rowSeconds = TextEditingController(text: '0');
  final _strokeRate = TextEditingController(text: '28');
  String _ftpProtocol = '20-minute';
  String _cyclingGoal = 'Endurance';
  String _workoutType = 'Endurance';
  String _rowingGoal = 'Race';
  String _benchmark = '2k';
  int _cyclingRpe = 6;
  int _rowingRpe = 8;
  bool _saving = false;

  FitnessStore get store => widget.store;

  @override
  void dispose() {
    _ftp.dispose();
    _testPower.dispose();
    _rideMinutes.dispose();
    _ridePower.dispose();
    _normalizedPower.dispose();
    _cadence.dispose();
    _rowDistance.dispose();
    _rowMinutes.dispose();
    _rowSeconds.dispose();
    _strokeRate.dispose();
    super.dispose();
  }

  int _integer(TextEditingController controller) =>
      int.tryParse(controller.text) ?? 0;

  int get _rowDuration => _integer(_rowMinutes) * 60 + _integer(_rowSeconds);

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _saveRide() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await store.saveCyclingSession(
        durationMinutes: _integer(_rideMinutes),
        averagePowerWatts: _integer(_ridePower),
        normalizedPowerWatts: _integer(_normalizedPower),
        cadenceRpm: _integer(_cadence),
        rpe: _cyclingRpe,
        workoutType: _workoutType,
      );
      if (mounted) _message('Cycling session saved to weekly load.');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveRow() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await store.saveRowingSession(
        distanceMeters: _integer(_rowDistance),
        durationSeconds: _rowDuration,
        strokeRate: _integer(_strokeRate),
        rpe: _rowingRpe,
        benchmarkType: _benchmark,
      );
      if (mounted) _message('Rowing session saved to weekly load.');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('CYCLING & ROWING LAB'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'CYCLING', icon: Icon(Icons.pedal_bike)),
            Tab(text: 'ROWING', icon: Icon(Icons.rowing)),
            Tab(text: 'WORKOUTS', icon: Icon(Icons.route_outlined)),
            Tab(text: 'MULTI-SPORT LOAD', icon: Icon(Icons.query_stats)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => TabBarView(
          children: [
            _cyclingTab(context),
            _rowingTab(context),
            _workoutsTab(context),
            _loadTab(context),
          ],
        ),
      ),
    ),
  );

  Widget _cyclingTab(BuildContext context) {
    final ftp = _integer(_ftp).clamp(1, 1000);
    final estimate = CyclingRowingEngine.estimateFtp(
      protocol: _ftpProtocol,
      testPowerWatts: _integer(_testPower).toDouble(),
    );
    final cadence = CyclingRowingEngine.cyclingCadence(
      rpm: _integer(_cadence),
      goal: _cyclingGoal,
    );
    final zones = CyclingRowingEngine.powerZones(ftp.toDouble());
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _EnduranceHero(
          icon: Icons.pedal_bike,
          title: 'CYCLING POWER & FTP',
          detail:
              'Estimate FTP, calculate seven power zones, audit cadence and save real indoor or outdoor rides.',
        ),
        const SizedBox(height: 14),
        Text(
          'FTP ESTIMATE PROTOCOL',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _NumberField(
              controller: _testPower,
              label: 'TEST POWER',
              suffix: 'W',
              onChanged: () => setState(() {}),
            ),
            _ChoiceField(
              label: 'PROTOCOL',
              value: _ftpProtocol,
              items: const ['20-minute', '8-minute', 'Ramp'],
              onChanged: (value) => setState(() => _ftpProtocol = value),
            ),
            _Metric(
              label: 'ESTIMATED FTP',
              value: '${estimate.estimatedFtpWatts} W',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(estimate.guidance),
        const SizedBox(height: 18),
        _NumberField(
          controller: _ftp,
          label: 'WORKING FTP',
          suffix: 'W',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 10),
        Text('7 POWER ZONES', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final zone in zones)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('Z${zone.number}')),
              title: Text(zone.name),
              subtitle: Text(zone.purpose),
              trailing: Text(
                zone.rangeLabel,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        const SizedBox(height: 18),
        Text('CADENCE TRACKER', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _NumberField(
              controller: _cadence,
              label: 'CADENCE',
              suffix: 'rpm',
              onChanged: () => setState(() {}),
            ),
            _ChoiceField(
              label: 'SESSION GOAL',
              value: _cyclingGoal,
              items: const ['Endurance', 'Climb', 'Speed', 'Recovery'],
              onChanged: (value) => setState(() => _cyclingGoal = value),
            ),
            _Metric(label: 'STATUS', value: cadence.status),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${cadence.targetMinimum}–${cadence.targetMaximum} rpm • ${cadence.cue}',
        ),
        const SizedBox(height: 20),
        Text(
          'LOG CYCLING SESSION',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _NumberField(
              controller: _rideMinutes,
              label: 'DURATION',
              suffix: 'min',
              onChanged: () {},
            ),
            _NumberField(
              controller: _ridePower,
              label: 'AVERAGE POWER',
              suffix: 'W',
              onChanged: () {},
            ),
            _NumberField(
              controller: _normalizedPower,
              label: 'NORMALIZED POWER',
              suffix: 'W',
              onChanged: () {},
            ),
            _ChoiceField(
              label: 'WORKOUT TYPE',
              value: _workoutType,
              items: const [
                'Endurance',
                'Tempo',
                'Threshold',
                'VO2',
                'Recovery',
                'Race',
              ],
              onChanged: (value) => setState(() => _workoutType = value),
            ),
          ],
        ),
        _RpeSlider(
          label: 'CYCLING RPE',
          value: _cyclingRpe,
          onChanged: (value) => setState(() => _cyclingRpe = value),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _saving ? null : _saveRide,
            icon: const Icon(Icons.save_outlined),
            label: const Text('SAVE RIDE'),
          ),
        ),
      ],
    );
  }

  Widget _rowingTab(BuildContext context) {
    final split = CyclingRowingEngine.rowingSplit(
      distanceMeters: _integer(_rowDistance),
      durationSeconds: _rowDuration,
    );
    final stroke = CyclingRowingEngine.rowingStrokeRate(
      strokesPerMinute: _integer(_strokeRate),
      watts: split.watts,
      goal: _rowingGoal,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _EnduranceHero(
          icon: Icons.rowing,
          title: 'ROWING SPLIT & STROKE LAB',
          detail:
              'Converts distance and time into /500m split and watts, then checks rate and stroke efficiency.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _NumberField(
              controller: _rowDistance,
              label: 'DISTANCE',
              suffix: 'm',
              onChanged: () => setState(() {}),
            ),
            _NumberField(
              controller: _rowMinutes,
              label: 'MINUTES',
              onChanged: () => setState(() {}),
            ),
            _NumberField(
              controller: _rowSeconds,
              label: 'SECONDS',
              onChanged: () => setState(() {}),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Metric(label: 'SPLIT', value: split.formattedSplit),
            _Metric(
              label: 'POWER',
              value: '${split.watts.toStringAsFixed(1)} W',
            ),
            _Metric(
              label: 'SPEED',
              value: '${split.metersPerSecond.toStringAsFixed(2)} m/s',
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'STROKE-RATE TRACKER',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _NumberField(
              controller: _strokeRate,
              label: 'STROKE RATE',
              suffix: 'spm',
              onChanged: () => setState(() {}),
            ),
            _ChoiceField(
              label: 'ROWING GOAL',
              value: _rowingGoal,
              items: const ['Steady', 'Power', 'Race'],
              onChanged: (value) => setState(() => _rowingGoal = value),
            ),
            _Metric(label: 'RATE STATUS', value: stroke.status),
            _Metric(
              label: 'W / STROKE',
              value: stroke.efficiencyWattsPerStroke.toStringAsFixed(1),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(stroke.cue),
        const SizedBox(height: 20),
        Text(
          'ERG BENCHMARK LIBRARY',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final item in CyclingRowingEngine.ergBenchmarks)
          Card(
            child: ListTile(
              onTap: () => setState(() => _benchmark = item.id),
              leading: Icon(
                _benchmark == item.id
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              title: Text(item.name),
              subtitle: Text('${item.targetStrokeRate} • ${item.protocol}'),
            ),
          ),
        _RpeSlider(
          label: 'ROWING RPE',
          value: _rowingRpe,
          onChanged: (value) => setState(() => _rowingRpe = value),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _saving ? null : _saveRow,
            icon: const Icon(Icons.save_outlined),
            label: const Text('SAVE ROW'),
          ),
        ),
      ],
    );
  }

  Widget _workoutsTab(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const _EnduranceHero(
        icon: Icons.route_outlined,
        title: 'INDOOR CYCLING WORKOUTS',
        detail:
            'Four structured sessions with FTP targets, cadence bands, recovery and explicit safety stops.',
      ),
      const SizedBox(height: 14),
      for (final workout in CyclingRowingEngine.indoorWorkouts)
        Card(
          child: ExpansionTile(
            leading: const CircleAvatar(child: Icon(Icons.pedal_bike)),
            title: Text(workout.name),
            subtitle: Text('${workout.totalMinutes} min • ${workout.focus}'),
            children: [
              for (final segment in workout.segments)
                ListTile(
                  dense: true,
                  title: Text(
                    '${segment.repeats > 1 ? '${segment.repeats}× ' : ''}'
                    '${segment.minutes} MIN ${segment.label.toUpperCase()}',
                  ),
                  subtitle: Text(
                    '${segment.ftpPercentage}% FTP • '
                    '${segment.cadenceMinimum}–${segment.cadenceMaximum} rpm',
                  ),
                ),
              ListTile(
                leading: const Icon(Icons.shield_outlined),
                title: const Text('SAFETY RULE'),
                subtitle: Text(workout.safetyNote),
              ),
            ],
          ),
        ),
      const SizedBox(height: 20),
      Text(
        'ENDURANCE MODALITY COMPARISON',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      for (final profile in CyclingRowingEngine.modalityProfiles)
        Card(
          child: ExpansionTile(
            title: Text(profile.modality),
            subtitle: Text(profile.bestFor),
            children: [
              ListTile(
                title: const Text('IMPACT'),
                trailing: Text(profile.impact),
              ),
              ListTile(
                title: const Text('PRIMARY MUSCLES'),
                subtitle: Text(profile.primaryMuscles),
              ),
              ListTile(
                title: const Text('SKILL DEMAND'),
                trailing: Text(profile.skillDemand),
              ),
              ListTile(
                title: const Text('STRENGTH INTERFERENCE'),
                subtitle: Text(profile.strengthInterference),
              ),
            ],
          ),
        ),
    ],
  );

  Widget _loadTab(BuildContext context) {
    final current = CyclingRowingEngine.weeklyLoad(
      cardio: store.cardioSessions,
      running: store.runningSessions,
      cycling: store.cyclingSessions,
      rowing: store.rowingSessions,
    );
    final previous = CyclingRowingEngine.weeklyLoad(
      cardio: store.cardioSessions,
      running: store.runningSessions,
      cycling: store.cyclingSessions,
      rowing: store.rowingSessions,
      weeksAgo: 1,
    );
    final change = previous.totalLoad == 0
        ? (current.totalLoad > 0 ? 100.0 : 0.0)
        : (current.totalLoad - previous.totalLoad) / previous.totalLoad * 100;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _EnduranceHero(
          icon: Icons.query_stats,
          title: 'MULTI-SPORT WEEKLY LOAD',
          detail:
              'Combines cycling, rowing, running and cardio with session-RPE load instead of counting sessions equally.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Metric(label: 'TOTAL LOAD', value: '${current.totalLoad} AU'),
            _Metric(label: 'DURATION', value: '${current.durationMinutes} min'),
            _Metric(label: 'SESSIONS', value: '${current.sessions}'),
            _Metric(label: 'HARD DAYS', value: '${current.hardSessions}'),
            _Metric(
              label: 'WEEK CHANGE',
              value: '${change.toStringAsFixed(0)}%',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          color: current.status == 'HIGH'
              ? Theme.of(context).colorScheme.errorContainer
              : null,
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.monitor_heart_outlined),
            ),
            title: Text('${current.status} ENDURANCE LOAD'),
            subtitle: Text(current.guidance),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'LOAD BY MODALITY',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final entry in current.byModality.entries)
          Card(
            child: ListTile(
              leading: Icon(
                entry.key == 'CYCLING'
                    ? Icons.pedal_bike
                    : entry.key == 'ROWING'
                    ? Icons.rowing
                    : entry.key == 'RUNNING'
                    ? Icons.directions_run
                    : Icons.favorite_outline,
              ),
              title: Text(entry.key),
              trailing: Text(
                '${entry.value} AU',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        const SizedBox(height: 20),
        Text(
          'DISTANCE–TIME CONVERTER',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (context) {
            final cycling = CyclingRowingEngine.convertDistanceTime(
              modality: 'Cycling',
              distance: 20,
              durationSeconds: 3600,
            );
            final rowing = CyclingRowingEngine.convertDistanceTime(
              modality: 'Rowing',
              distance: _integer(_rowDistance).toDouble(),
              durationSeconds: _rowDuration,
            );
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _Metric(
                  label: '20 KM CYCLING',
                  value: '${cycling.speed.toStringAsFixed(1)} km/h',
                ),
                _Metric(label: 'ROWING PACE', value: rowing.paceLabel),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _EnduranceHero extends StatelessWidget {
  const _EnduranceHero({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(radius: 28, child: Icon(icon)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(detail),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.suffix = '',
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 200,
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix.isEmpty ? null : suffix,
      ),
      onChanged: (_) => onChanged(),
    ),
  );
}

class _ChoiceField extends StatelessWidget {
  const _ChoiceField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 220,
    child: DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in items)
          DropdownMenuItem(value: item, child: Text(item)),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 200,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 2),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    ),
  );
}

class _RpeSlider extends StatelessWidget {
  const _RpeSlider({
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
      const SizedBox(height: 10),
      Text('$label • $value/10'),
      Slider(
        value: value.toDouble(),
        min: 1,
        max: 10,
        divisions: 9,
        label: '$value',
        onChanged: (next) => onChanged(next.round()),
      ),
    ],
  );
}
