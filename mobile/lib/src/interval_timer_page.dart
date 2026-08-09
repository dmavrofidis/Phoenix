import 'dart:async';

import 'package:flutter/material.dart';

import 'interval_timer_engine.dart';
import 'state/fitness_store.dart';

class IntervalTimerPage extends StatefulWidget {
  const IntervalTimerPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<IntervalTimerPage> createState() => _IntervalTimerPageState();
}

class _IntervalTimerPageState extends State<IntervalTimerPage> {
  final List<_TimerRuntime> _timers = [];
  Timer? _ticker;
  int _workSeconds = 30;
  int _restSeconds = 30;
  int _rounds = 5;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _tick() async {
    if (!mounted || !_timers.any((item) => item.running)) return;
    setState(() {});
    for (final timer in _timers.where((item) => item.running)) {
      final snapshot = IntervalTimerEngine.snapshot(
        timer.protocol,
        timer.elapsed,
      );
      final cueKey =
          '${snapshot.phase}-${snapshot.round}-${snapshot.remainingSeconds}';
      if (snapshot.remainingSeconds <= 3 && cueKey != timer.lastCueKey) {
        timer.lastCueKey = cueKey;
        await widget.store.playCountdownCue(
          finalCue: snapshot.isComplete || snapshot.remainingSeconds == 1,
        );
      }
      if (snapshot.isComplete && !timer.saved) {
        timer
          ..pause()
          ..saved = true;
        await widget.store.recordCapabilityRun(
          capabilityId: 400,
          result:
              '${timer.protocol.name} completed in ${IntervalTimerEngine.formatSeconds(timer.protocol.activeSeconds)}.',
        );
        await widget.store.feedback(success: true);
      }
    }
  }

  void _add(TimerProtocol protocol) {
    setState(() => _timers.add(_TimerRuntime(protocol)));
  }

  void _addCustom() {
    try {
      _add(
        IntervalTimerEngine.custom(
          name: 'Custom $_workSeconds/$_restSeconds',
          rounds: _rounds,
          segments: [
            TimerSegment(label: 'WORK', seconds: _workSeconds),
            TimerSegment(label: 'REST', seconds: _restSeconds),
          ],
        ),
      );
    } on FormatException catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('INTERVAL TIMER LAB')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
      children: [
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MULTI-TIMER WORKSPACE',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 6),
                Text(
                  'Run independent EMOM, AMRAP, Tabata or custom timers. Audio and haptics follow your local app preferences.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in IntervalTimerEngine.presets)
              FilledButton.tonalIcon(
                onPressed: () => _add(preset),
                icon: const Icon(Icons.add_alarm),
                label: Text(preset.name),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CUSTOM INTERVAL BUILDER',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                _SliderField(
                  label: 'WORK',
                  value: _workSeconds,
                  min: 5,
                  max: 180,
                  suffix: 'sec',
                  onChanged: (value) => setState(() => _workSeconds = value),
                ),
                _SliderField(
                  label: 'REST',
                  value: _restSeconds,
                  min: 5,
                  max: 180,
                  suffix: 'sec',
                  onChanged: (value) => setState(() => _restSeconds = value),
                ),
                _SliderField(
                  label: 'ROUNDS',
                  value: _rounds,
                  min: 1,
                  max: 30,
                  suffix: '',
                  onChanged: (value) => setState(() => _rounds = value),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _addCustom,
                    icon: const Icon(Icons.add),
                    label: const Text('ADD TIMER'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_timers.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(22),
              child: Text(
                'No active timer. Add a preset or build a custom interval.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          for (final timer in _timers)
            _TimerCard(
              timer: timer,
              onToggle: () => setState(timer.toggle),
              onReset: () => setState(timer.reset),
              onRemove: () => setState(() => _timers.remove(timer)),
            ),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: widget.store,
          builder: (context, _) {
            final history = widget.store.capabilityStateFor(400);
            return Text(
              'Completed timers stored locally: ${history.runCount}${history.lastResult.isEmpty ? '' : '\nLatest: ${history.lastResult}'}',
              style: Theme.of(context).textTheme.bodySmall,
            );
          },
        ),
      ],
    ),
  );
}

class _TimerRuntime {
  _TimerRuntime(this.protocol);

  final TimerProtocol protocol;
  Duration accumulated = Duration.zero;
  DateTime? startedAt;
  bool saved = false;
  String lastCueKey = '';

  bool get running => startedAt != null;
  Duration get elapsed =>
      accumulated +
      (startedAt == null
          ? Duration.zero
          : DateTime.now().difference(startedAt!));

  void toggle() => running ? pause() : startedAt = DateTime.now();

  void pause() {
    accumulated = elapsed;
    startedAt = null;
  }

  void reset() {
    accumulated = Duration.zero;
    startedAt = null;
    saved = false;
    lastCueKey = '';
  }
}

class _TimerCard extends StatelessWidget {
  const _TimerCard({
    required this.timer,
    required this.onToggle,
    required this.onReset,
    required this.onRemove,
  });

  final _TimerRuntime timer;
  final VoidCallback onToggle;
  final VoidCallback onReset;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final snapshot = IntervalTimerEngine.snapshot(
      timer.protocol,
      timer.elapsed,
    );
    return Semantics(
      liveRegion: true,
      label: snapshot.announcement,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      timer.protocol.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Text('ROUND ${snapshot.round}/${snapshot.rounds}'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                snapshot.phase,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                IntervalTimerEngine.formatSeconds(snapshot.remainingSeconds),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              LinearProgressIndicator(value: snapshot.totalProgress),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    tooltip: timer.running ? 'Pause timer' : 'Start timer',
                    onPressed: snapshot.isComplete ? null : onToggle,
                    icon: Icon(timer.running ? Icons.pause : Icons.play_arrow),
                  ),
                  IconButton(
                    tooltip: 'Reset timer',
                    onPressed: onReset,
                    icon: const Icon(Icons.replay),
                  ),
                  IconButton(
                    tooltip: 'Remove timer',
                    onPressed: onRemove,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderField extends StatelessWidget {
  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final String suffix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(width: 72, child: Text(label)),
      Expanded(
        child: Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          label: '$value $suffix',
          onChanged: (next) => onChanged(next.round()),
        ),
      ),
      SizedBox(width: 58, child: Text('$value $suffix')),
    ],
  );
}
