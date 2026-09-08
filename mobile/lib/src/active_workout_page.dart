import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'exercise_substitution_engine.dart';
import 'equipment_availability.dart';
import 'exercise_guide.dart';
import 'deterministic_coach_engine.dart';
import 'models/fitness_models.dart';
import 'phoenix_copy.dart';
import 'phoenix_l10n.dart';
import 'recovery_widgets.dart';
import 'session_preparation_engine.dart';
import 'state/fitness_store.dart';
import 'spotify_card.dart';
import 'training_insights.dart';
import 'training_intelligence_widgets.dart';
import 'voice_coach.dart';

enum _ExerciseSupportMode { discomfort, tired, easier }

enum _ExerciseSupportAction { adapt, stop }

String _painAreaLabel(BuildContext context, String value) {
  return switch (value) {
    'Δεν προσδιορίστηκε' => context.l10n.text(
      'Δεν προσδιορίστηκε',
      'Not specified',
    ),
    'Δεν είμαι σίγουρος' => context.l10n.text(
      'Δεν είμαι σίγουρος',
      'I am not sure',
    ),
    'Ώμος' => context.l10n.text('Ώμος', 'Shoulder'),
    'Αγκώνας' => context.l10n.text('Αγκώνας', 'Elbow'),
    'Καρπός' => context.l10n.text('Καρπός', 'Wrist'),
    'Μέση' => context.l10n.text('Μέση', 'Lower back'),
    'Ισχίο' => context.l10n.text('Ισχίο', 'Hip'),
    'Γόνατο' => context.l10n.text('Γόνατο', 'Knee'),
    'Αστράγαλος' => context.l10n.text('Αστράγαλος', 'Ankle'),
    _ => value,
  };
}

class _ExerciseSupportResult {
  const _ExerciseSupportResult._({
    this.action,
    this.replacement,
    this.tired = false,
  });

  const _ExerciseSupportResult.adapt({required bool tired})
    : this._(action: _ExerciseSupportAction.adapt, tired: tired);

  const _ExerciseSupportResult.stop()
    : this._(action: _ExerciseSupportAction.stop);

  const _ExerciseSupportResult.replace(String exercise)
    : this._(replacement: exercise);

  final _ExerciseSupportAction? action;
  final String? replacement;
  final bool tired;
}

class ActiveWorkoutPage extends StatefulWidget {
  const ActiveWorkoutPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<ActiveWorkoutPage> createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends State<ActiveWorkoutPage> {
  Timer? _timer;
  int _remainingSeconds = 0;
  final VoiceCoach _voiceCoach = VoiceCoach();
  final Set<int> _completedWarmupSteps = {};
  final Set<int> _completedCooldownSteps = {};
  final Set<String> _stoppedExercises = {};

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_voiceCoach.stop());
    super.dispose();
  }

  bool get _voiceEnabled =>
      widget.store.preferences.audioCues &&
      widget.store.preferences.audioCueStyle == 'coach';

  Future<void> _toggleVoice() async {
    final enabled = !_voiceEnabled;
    await widget.store.updatePreferences(
      audioCues: enabled,
      audioCueStyle: enabled ? 'coach' : 'minimal',
    );
    if (!mounted) return;
    if (enabled) {
      await _voiceCoach.speak(
        text: context.l10n.text(
          'Η φωνητική καθοδήγηση ενεργοποιήθηκε. Θα σου λέω πότε τελειώνει η ξεκούραση.',
          'Voice guidance is on. I will tell you when rest ends.',
        ),
        languageCode: widget.store.preferences.languageCode,
      );
    } else {
      await _voiceCoach.stop();
    }
  }

  void _startRest(int seconds) {
    _timer?.cancel();
    setState(() => _remainingSeconds = seconds);
    if (_voiceEnabled) {
      unawaited(
        _voiceCoach.speak(
          text: context.l10n.text(
            'Ξεκουράσου για $seconds δευτερόλεπτα.',
            'Rest for $seconds seconds.',
          ),
          languageCode: widget.store.preferences.languageCode,
        ),
      );
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _remainingSeconds <= 1) {
        timer.cancel();
        unawaited(widget.store.playCountdownCue(finalCue: true));
        if (_voiceEnabled) {
          unawaited(
            _voiceCoach.speak(
              text: context.l10n.text(
                'Η ξεκούραση τελείωσε. Πάμε στο επόμενο σετ.',
                'Rest is over. Let us do the next set.',
              ),
              languageCode: widget.store.preferences.languageCode,
            ),
          );
        }
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
      final l = context.l10n;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${PhoenixCopy.exerciseName(l, exercise)} → '
              '${PhoenixCopy.exerciseName(l, replacement)}',
            ),
          ),
        );
    } on FormatException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _supportExercise(
    String exercise,
    _ExerciseSupportMode initialMode,
  ) async {
    final workout = widget.store.activeWorkout;
    if (workout == null) return;
    final result = await showModalBottomSheet<_ExerciseSupportResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ExerciseSupportSheet(
        exercise: exercise,
        initialMode: initialMode,
        profile: widget.store.profile,
        excludedExercises: workout.exercises,
        recentPainAreas: widget.store.recentPainAreas,
      ),
    );
    if (result == null) return;
    try {
      if (result.replacement != null) {
        widget.store.replaceActiveExercise(
          exercise: exercise,
          replacement: result.replacement!,
        );
        _stoppedExercises.remove(exercise);
      } else if (result.action == _ExerciseSupportAction.adapt) {
        widget.store.makeActiveExerciseEasier(
          exercise: exercise,
          tired: result.tired,
        );
        _stoppedExercises.remove(exercise);
      } else if (result.action == _ExerciseSupportAction.stop) {
        setState(() => _stoppedExercises.add(exercise));
      }
      if (!mounted) return;
      final message = result.replacement != null
          ? context.l10n.text(
              'Η άσκηση άλλαξε σε ασφαλέστερη επιλογή.',
              'The exercise was changed to a safer option.',
            )
          : result.action == _ExerciseSupportAction.stop
          ? context.l10n.text(
              'Η άσκηση σταμάτησε για σήμερα. Δεν χρειάζεται να πιεστείς.',
              'This exercise is stopped for today. You do not need to push through.',
            )
          : context.l10n.text(
              'Ο σημερινός στόχος έγινε πιο εύκολος.',
              'Today’s target is now easier.',
            );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } on FormatException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _speakExercise(String exercise, bool atHome) async {
    final guide = ExerciseGuideCatalog.forExercise(exercise, atHome: atHome);
    if (guide == null) return;
    final displayName = PhoenixCopy.exerciseName(context.l10n, exercise);
    await _voiceCoach.speak(
      text: context.l10n.text(
        '$displayName. ${guide.execution} Πρόσεξε: ${guide.avoid}',
        '$displayName. Move slowly, stay in a comfortable range and keep your breathing relaxed. Stop if you feel pain or lose control.',
      ),
      languageCode: widget.store.preferences.languageCode,
    );
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
        final isHome = EquipmentAvailability.isHome(widget.store.profile);
        final preparation = SessionPreparationEngine.forWorkout(
          workout,
          profile: widget.store.profile,
        );
        return Scaffold(
          appBar: AppBar(
            title: Text(
              isHome
                  ? context.l10n.text('ΠΡΟΠΟΝΗΣΗ ΣΤΟ ΣΠΙΤΙ', 'HOME WORKOUT')
                  : context.l10n.text('ΠΡΟΠΟΝΗΣΗ ΜΕ ΒΑΡΗ', 'STRENGTH WORKOUT'),
            ),
            actions: [
              IconButton(
                key: const ValueKey('workout-voice-coach'),
                tooltip: context.l10n.text(
                  _voiceEnabled
                      ? 'Κλείσιμο φωνητικής καθοδήγησης'
                      : 'Φωνητική καθοδήγηση',
                  _voiceEnabled ? 'Turn off voice guidance' : 'Voice guidance',
                ),
                onPressed: _toggleVoice,
                icon: Icon(
                  _voiceEnabled
                      ? Icons.record_voice_over_rounded
                      : Icons.voice_over_off_outlined,
                ),
              ),
              IconButton(
                tooltip: context.l10n.text(
                  'Ακύρωση προπόνησης',
                  'Cancel workout',
                ),
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
              _WorkoutVoiceCard(
                enabled: _voiceEnabled,
                onChanged: (_) => _toggleVoice(),
              ),
              const SizedBox(height: 12),
              PeriodizationCard(store: widget.store),
              const SizedBox(height: 12),
              _ProtocolChecklistCard(
                title: isHome
                    ? context.l10n.text('ΑΠΛΗ ΠΡΟΘΕΡΜΑΝΣΗ', 'SIMPLE WARM-UP')
                    : context.l10n.text('ΠΡΟΘΕΡΜΑΝΣΗ', 'WARM-UP'),
                subtitle: isHome
                    ? context.l10n.text(
                        '${preparation.warmupMinutes}′ πριν ξεκινήσεις',
                        '${preparation.warmupMinutes} min before you start',
                      )
                    : context.l10n.text(
                        '${preparation.warmupMinutes}′ πριν από τα βασικά σετ',
                        '${preparation.warmupMinutes} min before your working sets',
                      ),
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
                  atHome: isHome,
                  stopped: _stoppedExercises.contains(exercise),
                  onAdd: () => _addSet(exercise),
                  onSpeak: () => _speakExercise(exercise, isHome),
                  onSupport: (mode) => _supportExercise(exercise, mode),
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
                title: context.l10n.text('ΑΠΟΘΕΡΑΠΕΙΑ', 'COOL-DOWN'),
                subtitle: context.l10n.text(
                  '${preparation.cooldownMinutes}′ για να επανέλθει ήρεμα το σώμα',
                  '${preparation.cooldownMinutes} min to wind down gradually',
                ),
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
                      ? context.l10n.text(
                          'Κατάγραψε πρώτα ένα σετ',
                          'Log your first set',
                        )
                      : context.l10n.text(
                          'Ολοκλήρωση — ${PhoenixCopy.setCount(context.l10n, widget.store.activeSets.length)}',
                          'Finish — ${PhoenixCopy.setCount(context.l10n, widget.store.activeSets.length)}',
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WorkoutVoiceCard extends StatelessWidget {
  const _WorkoutVoiceCard({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.secondary.withValues(alpha: .08),
      child: SwitchListTile(
        key: const ValueKey('workout-voice-guidance-switch'),
        minTileHeight: 72,
        value: enabled,
        onChanged: onChanged,
        secondary: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: colors.secondary.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            enabled
                ? Icons.record_voice_over_rounded
                : Icons.voice_over_off_outlined,
            color: colors.secondary,
          ),
        ),
        title: Text(
          context.l10n.text('Φωνητική καθοδήγηση', 'Voice guidance'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          context.l10n.text(
            enabled
                ? 'Θα ακούς πότε τελειώνει το διάλειμμα. Σε κάθε άσκηση μπορείς να πατήσεις «Άκουσε οδηγίες».'
                : 'Άκουσε οδηγίες χωρίς να κοιτάζεις συνέχεια την οθόνη.',
            enabled
                ? 'You will hear when rest ends. You can also tap “Hear instructions” on every exercise.'
                : 'Hear guidance without watching the screen all the time.',
          ),
        ),
      ),
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
        initiallyExpanded: icon == Icons.whatshot_outlined,
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
              context.l10n.text(
                'Πώς πήγε η προπόνησή σου;',
                'How did your workout go?',
              ),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(
              context.l10n.text(
                'Η απάντησή σου βοηθά το Phoenix να προσαρμόσει καλύτερα την επόμενη προπόνησή σου.',
                'Your answer helps Phoenix adapt your next workout.',
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.text(
                      'Πόσο δύσκολη σου φάνηκε συνολικά;',
                      'How hard did it feel overall?',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w900),
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
                Expanded(
                  child: Text(
                    context.l10n.text(
                      'Ένιωσες ενόχληση ή πόνο;',
                      'Did you feel discomfort or pain?',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w900),
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
                decoration: InputDecoration(
                  labelText: context.l10n.text('Περιοχή', 'Area'),
                  border: const OutlineInputBorder(),
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
                          (area) => DropdownMenuItem(
                            value: area,
                            child: Text(_painAreaLabel(context, area)),
                          ),
                        )
                        .toList(),
                onChanged: (value) =>
                    setState(() => _painArea = value ?? _painArea),
              ),
            ],
            if (_painSeverity >= 3) ...[
              const SizedBox(height: 10),
              Text(
                context.l10n.text(
                  'Μην επιβαρύνεις την περιοχή. Αν ο πόνος είναι έντονος, επιμένει ή χειροτερεύει, απευθύνσου σε επαγγελματία υγείας.',
                  'Do not load the area. If pain is sharp, persistent or worsening, contact a health professional.',
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: context.l10n.text(
                  'Σημειώσεις προπόνησης',
                  'Workout notes',
                ),
                hintText: context.l10n.text(
                  'Πώς ένιωσες και τι θέλεις να θυμάσαι…',
                  'How you felt and what you want to remember…',
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.flag),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    context.l10n.text(
                      'Αποθήκευση και ολοκλήρωση',
                      'Save and finish',
                    ),
                  ),
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
                      PhoenixCopy.workoutName(context.l10n, workout),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${PhoenixCopy.exerciseCount(context.l10n, workout.exercises.length)}  •  ${PhoenixCopy.setCount(context.l10n, setCount)}',
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
                  PhoenixCopy.trainingText(context.l10n, workout.prescription),
                  style: const TextStyle(
                    color: Color(0xFFFF9E80),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  PhoenixCopy.trainingText(context.l10n, workout.coachingCue),
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
                remainingSeconds == 0
                    ? context.l10n.text('ΧΡΟΝΟΣ ΔΙΑΛΕΙΜΜΑΤΟΣ', 'REST TIMER')
                    : '$minutes:$seconds',
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
    required this.atHome,
    required this.stopped,
    required this.onAdd,
    required this.onSpeak,
    required this.onSupport,
    required this.onReplace,
    required this.onRemove,
  });

  final String exercise;
  final WorkoutBlock? block;
  final ExercisePrescription prescription;
  final List<ExerciseSetLog> sets;
  final ProgressionSuggestion suggestion;
  final String videoUrl;
  final bool atHome;
  final bool stopped;
  final VoidCallback onAdd;
  final VoidCallback onSpeak;
  final ValueChanged<_ExerciseSupportMode> onSupport;
  final VoidCallback? onReplace;
  final ValueChanged<ExerciseSetLog> onRemove;

  @override
  Widget build(BuildContext context) {
    final guide = ExerciseGuideCatalog.forExercise(exercise, atHome: atHome);
    final displayExercise = PhoenixCopy.exerciseName(context.l10n, exercise);
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
                  context.l10n.text(
                    '${block!.label} • χωρίς μεγάλο διάλειμμα ανάμεσα',
                    '${block!.label} • without a full rest between exercises',
                  ),
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
                    displayExercise,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.text(
                    'Ασφαλέστερη εναλλακτική',
                    'Safer alternative',
                  ),
                  onPressed: onReplace,
                  icon: const Icon(Icons.swap_horiz),
                ),
                if (videoUrl.isNotEmpty)
                  IconButton(
                    tooltip: context.l10n.text(
                      'Βίντεο τεχνικής',
                      'Technique video',
                    ),
                    onPressed: () => launchUrl(
                      Uri.parse(videoUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.play_circle_outline),
                  ),
                IconButton.filledTonal(
                  tooltip: context.l10n.text(
                    stopped ? 'Σταμάτησε για σήμερα' : 'Καταγραφή σετ',
                    stopped ? 'Stopped for today' : 'Log a set',
                  ),
                  onPressed: stopped ? null : onAdd,
                  icon: Icon(stopped ? Icons.block_rounded : Icons.add),
                ),
              ],
            ),
            if (guide != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Semantics(
                  button: true,
                  label: context.l10n.text(
                    'Δες πώς γίνεται η άσκηση $displayExercise',
                    'See how to perform $displayExercise',
                  ),
                  child: InkWell(
                    key: ValueKey('active-exercise-guide-$exercise'),
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => showExerciseGuide(context, exercise, guide),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ExerciseGuidePreview(
                          guide: guide,
                          semanticLabel: context.l10n.text(
                            'Αρχική και τελική θέση για την άσκηση $displayExercise',
                            'Start and finish position for $displayExercise',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.touch_app_outlined,
                                size: 17,
                                color: Color(0xFFFF9E80),
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  context.l10n.text(
                                    'Δες τα βήματα της άσκησης',
                                    'See the exercise steps',
                                  ),
                                  style: const TextStyle(
                                    color: Color(0xFFFF9E80),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (guide != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  key: ValueKey('speak-exercise-$exercise'),
                  onPressed: onSpeak,
                  icon: const Icon(Icons.volume_up_outlined),
                  label: Text(
                    context.l10n.text(
                      'Άκουσε τις οδηγίες',
                      'Hear instructions',
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            _ExerciseSupportActions(
              exercise: exercise,
              stopped: stopped,
              onSelected: onSupport,
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
                          PhoenixCopy.exercisePrescription(
                            context.l10n,
                            prescription,
                          ),
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
                    '${context.l10n.text('Ρυθμός', 'Tempo')} ${prescription.tempo}'
                    '${prescription.note.isEmpty ? '' : '  •  ${prescription.note}'}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .55),
                      fontSize: 12,
                    ),
                  ),
                ],
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
                  context.l10n.text(
                    'Δεν έχεις καταγράψει ακόμη κάποιο σετ.',
                    'You have not logged a set yet.',
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
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

class _ExerciseSupportActions extends StatelessWidget {
  const _ExerciseSupportActions({
    required this.exercise,
    required this.stopped,
    required this.onSelected,
  });

  final String exercise;
  final bool stopped;
  final ValueChanged<_ExerciseSupportMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (stopped) {
      return Container(
        key: ValueKey('exercise-stopped-$exercise'),
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.secondary.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.favorite_rounded, color: colors.secondary),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                context.l10n.text(
                  'Σταμάτησε για σήμερα. Αυτό είναι φροντίδα, όχι αποτυχία.',
                  'Stopped for today. That is care, not failure.',
                ),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(
              onPressed: () => onSelected(_ExerciseSupportMode.easier),
              child: Text(context.l10n.text('Αλλαγή', 'Change')),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text(
              'Τι χρειάζεσαι τώρα;',
              'What do you need right now?',
            ),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                key: ValueKey('exercise-discomfort-$exercise'),
                avatar: Icon(
                  Icons.healing_outlined,
                  size: 18,
                  color: colors.error,
                ),
                label: Text(context.l10n.text('Πονάω', 'I feel pain')),
                onPressed: () => onSelected(_ExerciseSupportMode.discomfort),
              ),
              ActionChip(
                key: ValueKey('exercise-tired-$exercise'),
                avatar: const Icon(Icons.battery_2_bar_rounded, size: 18),
                label: Text(context.l10n.text('Κουράστηκα', 'I am tired')),
                onPressed: () => onSelected(_ExerciseSupportMode.tired),
              ),
              ActionChip(
                key: ValueKey('exercise-easier-$exercise'),
                avatar: const Icon(Icons.south_rounded, size: 18),
                label: Text(context.l10n.text('Πιο εύκολη', 'Make it easier')),
                onPressed: () => onSelected(_ExerciseSupportMode.easier),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExerciseSupportSheet extends StatefulWidget {
  const _ExerciseSupportSheet({
    required this.exercise,
    required this.initialMode,
    required this.profile,
    required this.excludedExercises,
    required this.recentPainAreas,
  });

  final String exercise;
  final _ExerciseSupportMode initialMode;
  final UserProfile? profile;
  final List<String> excludedExercises;
  final Set<String> recentPainAreas;

  @override
  State<_ExerciseSupportSheet> createState() => _ExerciseSupportSheetState();
}

class _ExerciseSupportSheetState extends State<_ExerciseSupportSheet> {
  late _ExerciseSupportMode _mode = widget.initialMode;
  String _painArea = 'Δεν είμαι σίγουρος';

  List<ExerciseAlternative> get _alternatives =>
      ExerciseSubstitutionEngine.alternativesFor(
        exercise: widget.exercise,
        profile: widget.profile,
        excludedExercises: widget.excludedExercises,
        painAreas: {
          ...widget.recentPainAreas,
          if (_mode == _ExerciseSupportMode.discomfort &&
              _painArea != 'Δεν είμαι σίγουρος')
            _painArea,
        },
      );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final alternatives = _alternatives;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.text('Προσαρμογή χωρίς πίεση', 'Adjust without pressure'),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              PhoenixCopy.exerciseName(l, widget.exercise),
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            SegmentedButton<_ExerciseSupportMode>(
              segments: [
                ButtonSegment(
                  value: _ExerciseSupportMode.discomfort,
                  icon: const Icon(Icons.healing_outlined),
                  label: Text(l.text('Πόνος', 'Pain')),
                ),
                ButtonSegment(
                  value: _ExerciseSupportMode.tired,
                  icon: const Icon(Icons.battery_2_bar_rounded),
                  label: Text(l.text('Κούραση', 'Tired')),
                ),
                ButtonSegment(
                  value: _ExerciseSupportMode.easier,
                  icon: const Icon(Icons.south_rounded),
                  label: Text(l.text('Ευκολότερα', 'Easier')),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (value) =>
                  setState(() => _mode = value.first),
            ),
            const SizedBox(height: 14),
            if (_mode == _ExerciseSupportMode.discomfort) ...[
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: colors.errorContainer.withValues(alpha: .45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  l.text(
                    'Σταμάτα αν ο πόνος είναι οξύς, ξαφνικός ή αυξάνεται. Το Phoenix δεν αντικαθιστά επαγγελματία υγείας.',
                    'Stop if pain is sharp, sudden or increasing. Phoenix does not replace a health professional.',
                  ),
                  style: TextStyle(
                    color: colors.onErrorContainer,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _painArea,
                decoration: InputDecoration(
                  labelText: l.text(
                    'Πού νιώθεις την ενόχληση;',
                    'Where do you feel discomfort?',
                  ),
                  border: const OutlineInputBorder(),
                ),
                items: [
                  for (final area in const [
                    'Δεν είμαι σίγουρος',
                    'Ώμος',
                    'Αγκώνας',
                    'Καρπός',
                    'Μέση',
                    'Ισχίο',
                    'Γόνατο',
                    'Αστράγαλος',
                  ])
                    DropdownMenuItem(
                      value: area,
                      child: Text(_painAreaLabel(context, area)),
                    ),
                ],
                onChanged: (value) =>
                    setState(() => _painArea = value ?? _painArea),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  key: const ValueKey('stop-exercise-for-today'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.errorContainer,
                    foregroundColor: colors.onErrorContainer,
                  ),
                  onPressed: () => Navigator.of(
                    context,
                  ).pop(const _ExerciseSupportResult.stop()),
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: Text(
                    l.text(
                      'Σταμάτα αυτή την άσκηση για σήμερα',
                      'Stop this exercise for today',
                    ),
                  ),
                ),
              ),
            ] else ...[
              Text(
                _mode == _ExerciseSupportMode.tired
                    ? l.text(
                        'Θα αφαιρέσουμε ένα σετ και θα σου δώσουμε περισσότερο διάλειμμα.',
                        'We will remove one set and give you more rest.',
                      )
                    : l.text(
                        'Θα μειώσουμε τον σημερινό στόχο χωρίς να χαλάσουμε το πρόγραμμά σου.',
                        'We will lower today’s target without changing your program.',
                      ),
                style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: FilledButton.tonalIcon(
                key: const ValueKey('adapt-exercise-for-today'),
                onPressed: () => Navigator.of(context).pop(
                  _ExerciseSupportResult.adapt(
                    tired: _mode == _ExerciseSupportMode.tired,
                  ),
                ),
                icon: const Icon(Icons.tune_rounded),
                label: Text(
                  l.text(
                    'Κάνε τον σημερινό στόχο πιο εύκολο',
                    'Make today’s target easier',
                  ),
                ),
              ),
            ),
            if (alternatives.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                l.text('Ή άλλαξε άσκηση', 'Or change the exercise'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              for (final alternative in alternatives) ...[
                Card(
                  child: ListTile(
                    key: ValueKey('support-alternative-${alternative.name}'),
                    minTileHeight: 68,
                    leading: const Icon(Icons.swap_horiz_rounded),
                    title: Text(
                      PhoenixCopy.exerciseName(l, alternative.name),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(alternative.reason),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(
                      context,
                    ).pop(_ExerciseSupportResult.replace(alternative.name)),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ],
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
              context.l10n.text('Αλλαγή άσκησης', 'Change exercise'),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(
              PhoenixCopy.exerciseName(context.l10n, exercise),
              style: const TextStyle(
                color: Color(0xFFFF9E80),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.text(
                'Οι επιλογές έχουν παρόμοια κίνηση και χρησιμοποιούν μόνο τον εξοπλισμό που έχεις δηλώσει.',
                'These options use a similar movement and only the equipment you selected.',
              ),
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
                              PhoenixCopy.exerciseName(
                                context.l10n,
                                alternative.name,
                              ),
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
      '${set.rir} ακόμη σωστές επαναλήψεις',
      if (set.setRpe > 0) 'δυσκολία ${set.setRpe}/10',
      if (set.velocityNote.isNotEmpty) set.velocityNote.toUpperCase(),
      if (set.isAmrap) 'μέχρι το τεχνικό όριο',
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
                PhoenixCopy.exerciseName(context.l10n, widget.exercise),
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
                  '${PhoenixCopy.exercisePrescription(context.l10n, widget.prescription)}\n'
                  '${context.l10n.text('Ρυθμός', 'Tempo')} ${widget.prescription.tempo}'
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
              Text('Πόσες σωστές επαναλήψεις μπορούσες ακόμη: $_rir'),
              Slider(
                value: _rir.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: '$_rir',
                onChanged: (value) => setState(() => _rir = value.round()),
              ),
              Text(
                context.l10n.text(
                  'Δυσκολία του σετ: $_setRpe/10',
                  'SET RPE: $_setRpe',
                ),
              ),
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
                decoration: InputDecoration(
                  labelText: context.l10n.text(
                    'Ταχύτητα επαναλήψεων',
                    'Manual rep velocity',
                  ),
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'explosive',
                    child: Text(context.l10n.text('Εκρηκτική', 'Explosive')),
                  ),
                  DropdownMenuItem(
                    value: 'steady',
                    child: Text(context.l10n.text('Σταθερή', 'Steady')),
                  ),
                  DropdownMenuItem(
                    value: 'slow',
                    child: Text(context.l10n.text('Αργή', 'Slow')),
                  ),
                  DropdownMenuItem(
                    value: 'grinding',
                    child: Text(context.l10n.text('Πολύ δύσκολη', 'Grinding')),
                  ),
                ],
                onChanged: (value) => setState(() => _velocity = value!),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.text('ΕΛΕΓΧΟΣ ΤΕΧΝΙΚΗΣ', 'TECHNIQUE CHECK'),
                style: const TextStyle(
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
                title: Text(
                  context.l10n.text(
                    'Σετ με όσες σωστές επαναλήψεις μπορώ',
                    'AMRAP test set',
                  ),
                ),
                subtitle: const Text(
                  'Σταμάτα όταν χαλάσει η τεχνική σου — όχι όταν αποτύχεις.',
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
