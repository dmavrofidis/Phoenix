import 'models/fitness_models.dart';

class ProtocolStep {
  const ProtocolStep({
    required this.title,
    required this.durationSeconds,
    required this.cue,
  });

  final String title;
  final int durationSeconds;
  final String cue;

  String get durationLabel =>
      durationSeconds >= 60 ? '${durationSeconds ~/ 60}′' : '$durationSeconds″';
}

class SessionPreparationPlan {
  const SessionPreparationPlan({required this.warmup, required this.cooldown});

  final List<ProtocolStep> warmup;
  final List<ProtocolStep> cooldown;

  int get warmupMinutes =>
      (warmup.fold<int>(0, (sum, step) => sum + step.durationSeconds) / 60)
          .ceil();
  int get cooldownMinutes =>
      (cooldown.fold<int>(0, (sum, step) => sum + step.durationSeconds) / 60)
          .ceil();
}

class MobilityRoutine {
  const MobilityRoutine({
    required this.id,
    required this.title,
    required this.focus,
    required this.steps,
  });

  final String id;
  final String title;
  final String focus;
  final List<ProtocolStep> steps;

  int get totalMinutes =>
      (steps.fold<int>(0, (sum, step) => sum + step.durationSeconds) / 60)
          .ceil();
}

class SessionPreparationEngine {
  const SessionPreparationEngine._();

  static SessionPreparationPlan forWorkout(WorkoutTemplate workout) {
    final names = workout.exercises.join(' ').toLowerCase();
    final lowerBody = _containsAny(names, [
      'squat',
      'καθίσ',
      'bulgarian',
      'προβολ',
      'άρσεις',
      'step-up',
      'sled',
    ]);
    final upperPush = _containsAny(names, [
      'πιέσεις',
      'κάμψεις',
      'pike',
      'dip',
      'βυθίσεις',
      'landmine',
    ]);
    final upperPull = _containsAny(names, ['έλξεις', 'κωπηλα', 'pull', 'face']);

    return SessionPreparationPlan(
      warmup: [
        const ProtocolStep(
          title: 'Ανέβασε θερμοκρασία',
          durationSeconds: 120,
          cue: 'Γρήγορο περπάτημα, ποδήλατο ή ήρεμο rowing.',
        ),
        if (lowerBody)
          const ProtocolStep(
            title: 'Ισχία και αστράγαλοι',
            durationSeconds: 90,
            cue: 'Ελεγχόμενα ανοίγματα ισχίων και knee-to-wall.',
          ),
        if (upperPush || upperPull)
          const ProtocolStep(
            title: 'Ώμοι και ωμοπλάτες',
            durationSeconds: 90,
            cue: 'Κύκλοι ώμων, band pull-aparts και scapular κινήσεις.',
          ),
        const ProtocolStep(
          title: 'Ενεργοποίηση κορμού',
          durationSeconds: 60,
          cue: 'Dead bug ή ήπιο plank χωρίς κόπωση.',
        ),
        const ProtocolStep(
          title: 'Ramp-up πρώτης άσκησης',
          durationSeconds: 180,
          cue: '2–4 προοδευτικά σετ πριν από το πρώτο working set.',
        ),
      ],
      cooldown: [
        const ProtocolStep(
          title: 'Κατέβασε παλμούς',
          durationSeconds: 120,
          cue: 'Ήρεμο περπάτημα και ρινική αναπνοή.',
        ),
        if (lowerBody)
          const ProtocolStep(
            title: 'Αποφόρτιση κάτω σώματος',
            durationSeconds: 120,
            cue: 'Ήπιες θέσεις για καμπτήρες ισχίου και γλουτούς.',
          ),
        if (upperPush || upperPull)
          const ProtocolStep(
            title: 'Αποφόρτιση άνω σώματος',
            durationSeconds: 120,
            cue: 'Ήπια διάταση θωρακικών και lat χωρίς πίεση στην άρθρωση.',
          ),
        const ProtocolStep(
          title: 'Reset αναπνοής',
          durationSeconds: 90,
          cue: 'Εισπνοή 4″, αργή εκπνοή 6″ σε άνετη θέση.',
        ),
      ],
    );
  }

  static List<MobilityRoutine> mobilityRoutines(UserProfile? profile) {
    final limitation = profile?.limitations.toLowerCase() ?? '';
    return [
      const MobilityRoutine(
        id: 'full-reset',
        title: 'FULL BODY RESET',
        focus: 'Καθημερινή αποσυμπίεση και ήπια κινητικότητα',
        steps: [
          ProtocolStep(
            title: '90/90 breathing',
            durationSeconds: 120,
            cue: 'Μέση χαλαρή και αργή εκπνοή.',
          ),
          ProtocolStep(
            title: 'Cat-cow ελεγχόμενο',
            durationSeconds: 60,
            cue: 'Μικρό άνετο εύρος, χωρίς πίεση.',
          ),
          ProtocolStep(
            title: 'World’s greatest stretch',
            durationSeconds: 120,
            cue: 'Εναλλάξ πλευρές και ήρεμη αναπνοή.',
          ),
          ProtocolStep(
            title: 'Deep squat hold με στήριξη',
            durationSeconds: 90,
            cue: 'Κράτησε στήριξη και άνετο βάθος.',
          ),
        ],
      ),
      const MobilityRoutine(
        id: 'hips',
        title: 'HIPS & ANKLES',
        focus: 'Καθίσματα, προβολές και hinge μοτίβα',
        steps: [
          ProtocolStep(
            title: 'Knee-to-wall',
            durationSeconds: 120,
            cue: 'Φτέρνα κάτω, 10 αργές επαναλήψεις ανά πλευρά.',
          ),
          ProtocolStep(
            title: '90/90 switches',
            durationSeconds: 120,
            cue: 'Χωρίς φόρα και χωρίς πόνο στο γόνατο.',
          ),
          ProtocolStep(
            title: 'Adductor rock-back',
            durationSeconds: 90,
            cue: 'Ουδέτερη μέση και αργή μεταφορά πίσω.',
          ),
          ProtocolStep(
            title: 'Hip flexor stretch',
            durationSeconds: 120,
            cue: 'Σφίξε τον πίσω γλουτό, χωρίς υπερέκταση.',
          ),
        ],
      ),
      const MobilityRoutine(
        id: 'shoulders',
        title: 'SHOULDERS & T-SPINE',
        focus: 'Πιέσεις, έλξεις και θέση πάνω από το κεφάλι',
        steps: [
          ProtocolStep(
            title: 'Wall slides',
            durationSeconds: 90,
            cue: 'Πλευρά κάτω και αργή κίνηση.',
          ),
          ProtocolStep(
            title: 'Open books',
            durationSeconds: 120,
            cue: 'Περιστροφή από θώρακα, γόνατα σταθερά.',
          ),
          ProtocolStep(
            title: 'Scapular push-ups',
            durationSeconds: 90,
            cue: 'Ίσιοι αγκώνες και ελεγχόμενες ωμοπλάτες.',
          ),
          ProtocolStep(
            title: 'Lat stretch με στήριξη',
            durationSeconds: 120,
            cue: 'Χωρίς πίεση στον ώμο ή στη μέση.',
          ),
        ],
      ),
      if (!limitation.contains('γόνατ'))
        const MobilityRoutine(
          id: 'squat-primer',
          title: 'SQUAT PRIMER',
          focus: 'Προετοιμασία για ασφαλές και σταθερό squat',
          steps: [
            ProtocolStep(
              title: 'Ankle rocks',
              durationSeconds: 90,
              cue: 'Γόνατο ακολουθεί τα δάχτυλα.',
            ),
            ProtocolStep(
              title: 'Supported squat pry',
              durationSeconds: 120,
              cue: 'Χρησιμοποίησε σταθερή στήριξη.',
            ),
            ProtocolStep(
              title: 'Glute bridge',
              durationSeconds: 90,
              cue: 'Παύση ψηλά χωρίς υπερέκταση.',
            ),
            ProtocolStep(
              title: 'Tempo bodyweight squat',
              durationSeconds: 120,
              cue: '3″ κάθοδος και άνετο βάθος.',
            ),
          ],
        ),
    ];
  }

  static bool _containsAny(String value, List<String> terms) =>
      terms.any(value.contains);
}
