import 'dart:async';

import 'package:flutter/material.dart';

import 'session_preparation_engine.dart';
import 'state/fitness_store.dart';

class MobilityPage extends StatelessWidget {
  const MobilityPage({super.key, required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final routines = SessionPreparationEngine.mobilityRoutines(store.profile);
    return Scaffold(
      appBar: AppBar(title: const Text('MOBILITY LAB')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        children: [
          Text(
            'Κινήσου καλύτερα',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Σύντομα, ήπια πρωτόκολλα. Κανένα stretch δεν πρέπει να πονάει.',
            style: TextStyle(color: Colors.white.withValues(alpha: .52)),
          ),
          const SizedBox(height: 20),
          for (final routine in routines) ...[
            _MobilityRoutineCard(routine: routine),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
          Text(
            'Αν υπάρχει οξύς ή επίμονος πόνος, σταμάτα και ζήτησε '
            'επαγγελματική αξιολόγηση.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobilityRoutineCard extends StatelessWidget {
  const _MobilityRoutineCard({required this.routine});

  final MobilityRoutine routine;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: const CircleAvatar(child: Icon(Icons.self_improvement)),
        title: Text(
          routine.title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text('${routine.totalMinutes}′ • ${routine.focus}'),
        children: [
          for (var index = 0; index < routine.steps.length; index++)
            _MobilityStepRow(index: index + 1, step: routine.steps[index]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => MobilityTimerPage(routine: routine),
                ),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Έναρξη ρουτίνας'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobilityStepRow extends StatelessWidget {
  const _MobilityStepRow({required this.index, required this.step});

  final int index;
  final ProtocolStep step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index',
            style: const TextStyle(
              color: Color(0xFFFF6E40),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${step.title} • ${step.durationLabel}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  step.cue,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MobilityTimerPage extends StatefulWidget {
  const MobilityTimerPage({super.key, required this.routine});

  final MobilityRoutine routine;

  @override
  State<MobilityTimerPage> createState() => _MobilityTimerPageState();
}

class _MobilityTimerPageState extends State<MobilityTimerPage> {
  Timer? _timer;
  int _stepIndex = 0;
  late int _remaining;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.routine.steps.first.durationSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remaining > 1) {
        setState(() => _remaining--);
      } else if (_stepIndex < widget.routine.steps.length - 1) {
        setState(() {
          _stepIndex++;
          _remaining = widget.routine.steps[_stepIndex].durationSeconds;
        });
      } else {
        timer.cancel();
        setState(() {
          _remaining = 0;
          _running = false;
        });
      }
    });
  }

  void _next() {
    if (_stepIndex >= widget.routine.steps.length - 1) return;
    setState(() {
      _stepIndex++;
      _remaining = widget.routine.steps[_stepIndex].durationSeconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.routine.steps[_stepIndex];
    final progress = 1 - _remaining / step.durationSeconds;
    final minutes = (_remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remaining % 60).toString().padLeft(2, '0');
    return Scaffold(
      appBar: AppBar(title: Text(widget.routine.title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Text(
              'ΒΗΜΑ ${_stepIndex + 1}/${widget.routine.steps.length}',
              style: const TextStyle(
                color: Color(0xFFFF9E80),
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox.square(
              dimension: 210,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress.clamp(0, 1),
                    strokeWidth: 13,
                    backgroundColor: Colors.white10,
                  ),
                  Center(
                    child: Text(
                      '$minutes:$seconds',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Text(
              step.title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              step.cue,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .58),
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _remaining == 0 ? null : _toggle,
                    icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(_running ? 'Παύση' : 'Έναρξη'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  tooltip: 'Επόμενο βήμα',
                  onPressed: _stepIndex < widget.routine.steps.length - 1
                      ? _next
                      : null,
                  icon: const Icon(Icons.skip_next),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
