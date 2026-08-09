import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'exercise_substitution_engine.dart';
import 'exercise_guide.dart';
import 'deterministic_coach_engine.dart';
import 'models/fitness_models.dart';
import 'recovery_widgets.dart';
import 'session_preparation_engine.dart';
import 'state/fitness_store.dart';
import 'spotify_card.dart';
import 'training_insights.dart';
import 'training_intelligence_widgets.dart';

class ActiveWorkoutPage extends StatefulWidget {
  const ActiveWorkoutPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<ActiveWorkoutPage> createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends State<ActiveWorkoutPage> {
  Timer? _timer;
  int _remainingSeconds = 0;
  final Set<int> _completedWarmupSteps = {};
  final Set<int> _completedCooldownSteps = {};

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRest(int seconds) {
    _timer?.cancel();
    setState(() => _remainingSeconds = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _remainingSeconds <= 1) {
        timer.cancel();
        unawaited(widget.store.playCountdownCue(finalCue: true));
        if (mounted) setState(() => _remainingSeconds = 0);
        return;
      }
      final next = _remainingSeconds - 1;
      if (next <= widget.store.preferences.countdownCueSeconds) {
        unawaited(widget.store.playCountdownCue());
      }
      setState(() => _remainingSeconds = next);
    });
  }

  Future<void> _addSet(String exercise) async {
    final workout = widget.store.activeWorkout;
    if (workout == null) return;
    final prescription = workout.prescriptionFor(exercise);
    final suggestion = widget.store.progressionFor(exercise);
    final input = await showModalBottomSheet<_SetInput>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _SetEntrySheet(
        exercise: exercise,
        suggestion: suggestion,
        prescription: prescription,
      ),
    );
    if (input == null) return;
    try {
      widget.store.logSet(
        exerciseName: exercise,
        reps: input.reps,
        weightKilograms: input.weight,
        rir: input.rir,
        holdSeconds: input.holdSeconds,
        setRpe: input.setRpe,
        velocityNote: input.velocityNote,
        techniqueChecks: input.techniqueChecks,
        isAmrap: input.isAmrap,
      );
      _startRest(prescription.restSeconds);
    } on FormatException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _replaceExercise(String exercise) async {
    final alternatives = widget.store.alternativesForActiveExercise(exercise);
    if (alternatives.isEmpty) return;
    final replacement = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ExerciseSubstitutionSheet(
        exercise: exercise,
        alternatives: alternatives,
      ),
    );
    if (replacement == null) return;
    try {
      widget.store.replaceActiveExercise(
        exercise: exercise,
        replacement: replacement,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$exercise → $replacement')));
    } on FormatException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _finish() async {
    final review = await showModalBottomSheet<_SessionReviewInput>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _SessionReviewSheet(),
    );
    if (review == null) return;
    await widget.store.finishWorkout(
      sessionRpe: review.sessionRpe,
      notes: review.notes,
      painArea: review.painArea,
      painSeverity: review.painSeverity,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final workout = widget.store.activeWorkout;
        if (workout == null) {
          return const Scaffold(body: SizedBox.shrink());
        }
        final preparation = SessionPreparationEngine.forWorkout(workout);
        return Scaffold(
          appBar: AppBar(
            title: const Text('IRON SESSION'),
            actions: [
              IconButton(
                tooltip: 'Ακύρωση προπόνησης',
                onPressed: () {
                  widget.store.cancelWorkout();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              _SessionHeader(
                workout: workout,
                setCount: widget.store.activeSets.length,
              ),
              const SizedBox(height: 12),
              PeriodizationCard(store: widget.store),
              const SizedBox(height: 12),
              _ProtocolChecklistCard(
                title: 'WARM-UP PROTOCOL',
                subtitle:
                    '${preparation.warmupMinutes}′ πριν από τα working sets',
                icon: Icons.whatshot_outlined,
                steps: preparation.warmup,
                completed: _completedWarmupSteps,
                onToggle: (index) => setState(() {
                  if (!_completedWarmupSteps.add(index)) {
                    _completedWarmupSteps.remove(index);
                  }
                }),
              ),
              const SizedBox(height: 12),
              SpotifyCard(
                store: widget.store,
                compact: true,
                templateId: workout.id,
              ),
              if (widget.store.todaysRecoveryPlan != null) ...[
                const SizedBox(height: 12),
                RecoverySessionBanner(store: widget.store),
              ],
              const SizedBox(height: 12),
              _RestTimer(
                remainingSeconds: _remainingSeconds,
                onStart: _startRest,
                onStop: () {
                  _timer?.cancel();
                  setState(() => _remainingSeconds = 0);
                },
              ),
              const SizedBox(height: 20),
              for (final exercise in workout.exercises) ...[
                _ExerciseCard(
                  exercise: exercise,
                  block: workout.blockFor(exercise),
                  prescription: workout.prescriptionFor(exercise),
                  sets: widget.store.activeSets
                      .where((set) => set.exerciseName == exercise)
                      .toList(),
                  suggestion: widget.store.progressionFor(exercise),
                  videoUrl: widget.store.exerciseVideoFor(exercise),
                  onAdd: () => _addSet(exercise),
                  onReplace:
                      widget.store.activeSets.any(
                            (set) => set.exerciseName == exercise,
                          ) ||
                          widget.store
                              .alternativesForActiveExercise(exercise)
                              .isEmpty
                      ? null
                      : () => _replaceExercise(exercise),
                  onRemove: widget.store.removeSet,
                ),
                const SizedBox(height: 12),
              ],
              _ProtocolChecklistCard(
                title: 'COOLDOWN PROTOCOL',
                subtitle:
                    '${preparation.cooldownMinutes}′ για σταδιακή επαναφορά',
                icon: Icons.air,
                steps: preparation.cooldown,
                completed: _completedCooldownSteps,
                onToggle: (index) => setState(() {
                  if (!_completedCooldownSteps.add(index)) {
                    _completedCooldownSteps.remove(index);
                  }
                }),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: widget.store.activeSets.isEmpty ? null : _finish,
              icon: const Icon(Icons.flag),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  widget.store.activeSets.isEmpty
                      ? 'Κατάγραψε το πρώτο σετ'
                      : 'Ολοκλήρωση — ${widget.store.activeSets.length} σετ',
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProtocolChecklistCard extends StatelessWidget {
  const _ProtocolChecklistCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.steps,
    required this.completed,
    required this.onToggle,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<ProtocolStep> steps;
  final Set<int> completed;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: title.startsWith('WARM'),
        leading: Icon(icon, color: const Color(0xFFFF6E40)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: .6,
          ),
        ),
        subtitle: Text('$subtitle • ${completed.length}/${steps.length}'),
        children: [
          for (var index = 0; index < steps.length; index++)
            CheckboxListTile(
              value: completed.contains(index),
              onChanged: (_) => onToggle(index),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                '${steps[index].title} • ${steps[index].durationLabel}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(steps[index].cue),
            ),
        ],
      ),
    );
  }
}

class _SessionReviewInput {
  const _SessionReviewInput({
    required this.sessionRpe,
    required this.notes,
    required this.painArea,
    required this.painSeverity,
  });

  final int sessionRpe;
  final String notes;
  final String painArea;
  final int painSeverity;
}

class _SessionReviewSheet extends StatefulWidget {
  const _SessionReviewSheet();

  @override
  State<_SessionReviewSheet> createState() => _SessionReviewSheetState();
}

class _SessionReviewSheetState extends State<_SessionReviewSheet> {
  final _notes = TextEditingController();
  int _sessionRpe = 7;
  int _painSeverity = 0;
  String _painArea = 'Δεν προσδιορίστηκε';

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(
      _SessionReviewInput(
        sessionRpe: _sessionRpe,
        notes: _notes.text,
        painArea: _painArea,
        painSeverity: _painSeverity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session review',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(
              'Η αναφορά αυτή τροφοδοτεί το deload και το εβδομαδιαίο report.',
              style: TextStyle(color: Colors.white.withValues(alpha: .5)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Session RPE',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Text(
                  '$_sessionRpe/10',
                  style: const TextStyle(
                    color: Color(0xFFFF9E80),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            Slider(
              value: _sessionRpe.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$_sessionRpe',
              onChanged: (value) => setState(() => _sessionRpe = value.round()),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Ενόχληση ή πόνος',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Text(
                  '$_painSeverity/5',
                  style: TextStyle(
                    color: _painSeverity >= 3
                        ? const Color(0xFFEF9A9A)
                        : const Color(0xFFFF9E80),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            Slider(
              value: _painSeverity.toDouble(),
              min: 0,
              max: 5,
              divisions: 5,
              label: '$_painSeverity',
              onChanged: (value) =>
                  setState(() => _painSeverity = value.round()),
            ),
            if (_painSeverity > 0) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _painArea,
                decoration: const InputDecoration(
                  labelText: 'Περιοχή',
                  border: OutlineInputBorder(),
                ),
                items:
                    const [
                          'Δεν προσδιορίστηκε',
                          'Ώμος',
                          'Αγκώνας',
                          'Καρπός',
                          'Μέση',
                          'Ισχίο',
                          'Γόνατο',
                          'Αστράγαλος',
                        ]
                        .map(
                          (area) =>
                              DropdownMenuItem(value: area, child: Text(area)),
                        )
                        .toList(),
                onChanged: (value) =>
                    setState(() => _painArea = value ?? _painArea),
              ),
            ],
            if (_painSeverity >= 3) ...[
              const SizedBox(height: 10),
              const Text(
                'Pain flag: απόφυγε φόρτιση της περιοχής. Επίμονος ή οξύς '
                'πόνος χρειάζεται επαγγελματική αξιολόγηση.',
                style: TextStyle(
                  color: Color(0xFFEF9A9A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Σημειώσεις συνεδρίας',
                hintText: 'Τεχνική, ενέργεια, τι θέλεις να θυμάσαι…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.flag),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Αποθήκευση και ολοκλήρωση'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({required this.workout, required this.setCount});

  final WorkoutTemplate workout;
  final int setCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF481208), Color(0xFF19100E)],
        ),
        border: Border.all(color: const Color(0x66FF3D00)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Color(0xFFFF3D00),
                size: 38,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name.toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${workout.exercises.length} ασκήσεις  •  $setCount σετ',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .62),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.prescription,
                  style: const TextStyle(
                    color: Color(0xFFFF9E80),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  workout.coachingCue,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .65),
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

class _RestTimer extends StatelessWidget {
  const _RestTimer({
    required this.remainingSeconds,
    required this.onStart,
    required this.onStop,
  });

  final int remainingSeconds;
  final ValueChanged<int> onStart;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.timer_outlined, color: Color(0xFFFF3D00)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                remainingSeconds == 0 ? 'REST TIMER' : '$minutes:$seconds',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            if (remainingSeconds > 0)
              IconButton(onPressed: onStop, icon: const Icon(Icons.stop))
            else
              for (final duration in [60, 90, 120])
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: ActionChip(
                    label: Text('${duration}s'),
                    onPressed: () => onStart(duration),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.block,
    required this.prescription,
    required this.sets,
    required this.suggestion,
    required this.videoUrl,
    required this.onAdd,
    required this.onReplace,
    required this.onRemove,
  });

  final String exercise;
  final WorkoutBlock? block;
  final ExercisePrescription prescription;
  final List<ExerciseSetLog> sets;
  final ProgressionSuggestion suggestion;
  final String videoUrl;
  final VoidCallback onAdd;
  final VoidCallback? onReplace;
  final ValueChanged<ExerciseSetLog> onRemove;

  @override
  Widget build(BuildContext context) {
    final guide = ExerciseGuideCatalog.forExercise(exercise);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (block != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x2281C784),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${block!.label} • χωρίς πλήρες διάλειμμα ανάμεσα',
                  style: const TextStyle(
                    color: Color(0xFFA5D6A7),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Ασφαλής εναλλακτική',
                  onPressed: onReplace,
                  icon: const Icon(Icons.swap_horiz),
                ),
                if (videoUrl.isNotEmpty)
                  IconButton(
                    tooltip: 'Video τεχνικής',
                    onPressed: () => launchUrl(
                      Uri.parse(videoUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.play_circle_outline),
                  ),
                IconButton.filledTonal(
                  tooltip: 'Καταγραφή σετ',
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6E40).withValues(alpha: .08),
                border: Border.all(
                  color: const Color(0xFFFF6E40).withValues(alpha: .2),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.tune,
                        size: 18,
                        color: Color(0xFFFF9E80),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          prescription.summary,
                          style: const TextStyle(
                            color: Color(0xFFFFAB91),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        '${sets.length}/${prescription.workingSets}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Tempo ${prescription.tempo}'
                    '${prescription.note.isEmpty ? '' : '  •  ${prescription.note}'}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (guide != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: TextButton.icon(
                  onPressed: () => showExerciseGuide(context, exercise, guide),
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text('Οδηγός άσκησης'),
                ),
              ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3D00).withValues(alpha: .09),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.trending_up,
                    color: Color(0xFFFF3D00),
                    size: 19,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.headline,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          suggestion.detail,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .58),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (sets.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Δεν έχει καταγραφεί σετ.',
                  style: TextStyle(color: Colors.white.withValues(alpha: .45)),
                ),
              )
            else
              for (var index = 0; index < sets.length; index++)
                _SetRow(
                  index: index + 1,
                  set: sets[index],
                  prescription: prescription,
                  onRemove: () => onRemove(sets[index]),
                ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseSubstitutionSheet extends StatelessWidget {
  const _ExerciseSubstitutionSheet({
    required this.exercise,
    required this.alternatives,
  });

  final String exercise;
  final List<ExerciseAlternative> alternatives;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Αλλαγή άσκησης',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(
              exercise,
              style: const TextStyle(
                color: Color(0xFFFF9E80),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Οι επιλογές κρατούν παρόμοιο κινητικό μοτίβο και '
              'φιλτράρονται με βάση τον διαθέσιμο εξοπλισμό.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .52),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            for (final alternative in alternatives) ...[
              InkWell(
                onTap: () => Navigator.of(context).pop(alternative.name),
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .045),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0x22FF3D00),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.change_circle_outlined,
                          color: Color(0xFFFF6E40),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alternative.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              alternative.reason,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .52),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              alternative.tag,
                              style: const TextStyle(
                                color: Color(0xFFFF9E80),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .7,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.index,
    required this.set,
    required this.prescription,
    required this.onRemove,
  });

  final int index;
  final ExerciseSetLog set;
  final ExercisePrescription prescription;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final quality = DeterministicCoachEngine.setQuality(
      set: set,
      prescription: prescription,
    );
    final weight = set.weightKilograms == set.weightKilograms.roundToDouble()
        ? set.weightKilograms.toStringAsFixed(0)
        : set.weightKilograms.toStringAsFixed(1);
    final performance = [
      if (set.reps > 0) '${set.reps} επαν.',
      if (set.weightKilograms > 0) '$weight kg',
      if (set.holdSeconds > 0) '${set.holdSeconds}s hold',
      'RIR ${set.rir}',
      if (set.setRpe > 0) 'RPE ${set.setRpe}',
      if (set.velocityNote.isNotEmpty) set.velocityNote.toUpperCase(),
      if (set.isAmrap) 'AMRAP',
    ].join('  •  ');
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            '$index',
            style: const TextStyle(
              color: Color(0xFFFF3D00),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(performance)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: quality.score >= 78
                  ? const Color(0x2266BB6A)
                  : const Color(0x22FFB74D),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${quality.score}',
              style: TextStyle(
                color: quality.score >= 78
                    ? const Color(0xFF81C784)
                    : const Color(0xFFFFB74D),
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, size: 19),
          ),
        ],
      ),
    );
  }
}

class _SetInput {
  const _SetInput({
    required this.reps,
    required this.weight,
    required this.rir,
    required this.holdSeconds,
    required this.setRpe,
    required this.velocityNote,
    required this.techniqueChecks,
    required this.isAmrap,
  });

  final int reps;
  final double weight;
  final int rir;
  final int holdSeconds;
  final int setRpe;
  final String velocityNote;
  final List<String> techniqueChecks;
  final bool isAmrap;
}

class _SetEntrySheet extends StatefulWidget {
  const _SetEntrySheet({
    required this.exercise,
    required this.suggestion,
    required this.prescription,
  });

  final String exercise;
  final ProgressionSuggestion suggestion;
  final ExercisePrescription prescription;

  @override
  State<_SetEntrySheet> createState() => _SetEntrySheetState();
}

class _SetEntrySheetState extends State<_SetEntrySheet> {
  late final TextEditingController _reps;
  late final TextEditingController _weight;
  late final TextEditingController _hold;
  int _rir = 2;
  int _setRpe = 7;
  String _velocity = 'steady';
  final Set<String> _techniqueChecks = {};
  bool _isAmrap = false;

  @override
  void initState() {
    super.initState();
    final targetReps = widget.prescription.isTimed
        ? 0
        : widget.suggestion.targetReps.clamp(
            widget.prescription.minReps,
            widget.prescription.maxReps,
          );
    final suggestedHold = widget.suggestion.targetHoldSeconds;
    final targetHold = widget.prescription.isTimed
        ? (suggestedHold <= 0
              ? widget.prescription.minHoldSeconds
              : suggestedHold.clamp(
                  widget.prescription.minHoldSeconds,
                  widget.prescription.maxHoldSeconds,
                ))
        : 0;
    _reps = TextEditingController(text: targetReps.toString());
    _weight = TextEditingController(
      text: widget.suggestion.targetWeightKilograms.toStringAsFixed(
        widget.suggestion.targetWeightKilograms ==
                widget.suggestion.targetWeightKilograms.roundToDouble()
            ? 0
            : 1,
      ),
    );
    _hold = TextEditingController(text: targetHold.toString());
    _rir = widget.prescription.targetRir;
  }

  @override
  void dispose() {
    _reps.dispose();
    _weight.dispose();
    _hold.dispose();
    super.dispose();
  }

  void _submit() {
    final reps = int.tryParse(_reps.text) ?? 0;
    final weight = double.tryParse(_weight.text.replaceAll(',', '.')) ?? 0;
    final hold = int.tryParse(_hold.text) ?? 0;
    Navigator.of(context).pop(
      _SetInput(
        reps: reps,
        weight: weight,
        rir: _rir,
        holdSeconds: hold,
        setRpe: _setRpe,
        velocityNote: _velocity,
        techniqueChecks: _techniqueChecks.toList(),
        isAmrap: _isAmrap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final technique = DeterministicCoachEngine.techniqueFor(widget.exercise);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .82,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.exercise,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.suggestion.headline} — ${widget.suggestion.detail}',
                style: TextStyle(color: Colors.white.withValues(alpha: .58)),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3D00).withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.prescription.summary}\n'
                  'Tempo ${widget.prescription.tempo}'
                  '${widget.prescription.note.isEmpty ? '' : ' • ${widget.prescription.note}'}',
                  style: const TextStyle(
                    color: Color(0xFFFFAB91),
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  if (!widget.prescription.isTimed) ...[
                    Expanded(
                      child: TextField(
                        controller: _reps,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Επαναλήψεις',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: TextField(
                      controller: _weight,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Πρόσθετα κιλά',
                        suffixText: 'kg',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  if (widget.prescription.isTimed) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _hold,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Χρόνος',
                          suffixText: 'sec',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              Text('RIR — επαναλήψεις σε απόθεμα: $_rir'),
              Slider(
                value: _rir.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: '$_rir',
                onChanged: (value) => setState(() => _rir = value.round()),
              ),
              Text('SET RPE: $_setRpe'),
              Slider(
                value: _setRpe.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: '$_setRpe',
                onChanged: (value) => setState(() => _setRpe = value.round()),
              ),
              DropdownButtonFormField<String>(
                initialValue: _velocity,
                decoration: const InputDecoration(
                  labelText: 'Manual rep velocity',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'explosive',
                    child: Text('Explosive'),
                  ),
                  DropdownMenuItem(value: 'steady', child: Text('Steady')),
                  DropdownMenuItem(value: 'slow', child: Text('Slow')),
                  DropdownMenuItem(value: 'grinding', child: Text('Grinding')),
                ],
                onChanged: (value) => setState(() => _velocity = value!),
              ),
              const SizedBox(height: 12),
              const Text(
                'TECHNIQUE GATE',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: .8,
                ),
              ),
              const SizedBox(height: 6),
              for (final item in technique.items)
                CheckboxListTile(
                  value: _techniqueChecks.contains(item),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(item, style: const TextStyle(fontSize: 12)),
                  onChanged: (value) => setState(() {
                    if (value == true) {
                      _techniqueChecks.add(item);
                    } else {
                      _techniqueChecks.remove(item);
                    }
                  }),
                ),
              Text(
                technique.stopRule,
                style: const TextStyle(
                  color: Color(0xFFFFAB91),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SwitchListTile(
                value: _isAmrap,
                contentPadding: EdgeInsets.zero,
                title: const Text('AMRAP test set'),
                subtitle: const Text(
                  'Τεχνικό stop — όχι αποτυχία, όχι forced reps.',
                ),
                onChanged: (value) => setState(() {
                  _isAmrap = value;
                  if (value) _rir = 0;
                }),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.add),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Καταγραφή σετ'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
