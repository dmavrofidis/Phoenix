import 'models/fitness_models.dart';
import 'phoenix_l10n.dart';

/// User-facing wording for legacy values that remain stable in local storage.
///
/// Phoenix used several English fitness names as persisted identifiers. This
/// layer gives them natural labels without rewriting a user's history, custom
/// programs, active workout, or backups.
abstract final class PhoenixCopy {
  static String exerciseCount(PhoenixL10n l, int count) {
    if (l.locale.languageCode == 'el') {
      return '$count ${count == 1 ? 'άσκηση' : 'ασκήσεις'}';
    }
    return '$count ${count == 1 ? 'exercise' : 'exercises'}';
  }

  static String minuteCount(PhoenixL10n l, int count) {
    if (l.locale.languageCode == 'el') {
      return '$count ${count == 1 ? 'λεπτό' : 'λεπτά'}';
    }
    return '$count ${count == 1 ? 'minute' : 'minutes'}';
  }

  static String weeklyWorkoutProgress(
    PhoenixL10n l, {
    required int completed,
    required int target,
  }) {
    if (l.locale.languageCode == 'el') {
      final noun = target == 1 ? 'προπόνηση' : 'προπονήσεις';
      return '$completed από $target $noun αυτή την εβδομάδα';
    }
    final noun = target == 1 ? 'workout' : 'workouts';
    return '$completed of $target $noun this week';
  }

  static String compactExerciseTarget(
    PhoenixL10n l,
    ExercisePrescription prescription,
  ) {
    final sets = prescription.workingSets;
    if (l.locale.languageCode == 'el') {
      final target = prescription.isTimed
          ? _greekRange(
              prescription.minHoldSeconds,
              prescription.maxHoldSeconds,
              singular: 'δευτερόλεπτο',
              plural: 'δευτερόλεπτα',
            )
          : _greekRange(
              prescription.minReps,
              prescription.maxReps,
              singular: 'επανάληψη',
              plural: 'επαναλήψεις',
            );
      return '$sets σετ • $target';
    }
    final target = prescription.isTimed
        ? _englishRange(
            prescription.minHoldSeconds,
            prescription.maxHoldSeconds,
            singular: 'second',
            plural: 'seconds',
          )
        : _englishRange(
            prescription.minReps,
            prescription.maxReps,
            singular: 'repetition',
            plural: 'repetitions',
          );
    return '$sets ${sets == 1 ? 'set' : 'sets'} • $target';
  }

  static String workoutName(
    PhoenixL10n l,
    WorkoutTemplate template, {
    bool short = false,
  }) {
    return workoutNameFromRaw(l, template.name, short: short);
  }

  static String workoutNameFromRaw(
    PhoenixL10n l,
    String raw, {
    bool short = false,
  }) {
    final pair = (short ? _shortWorkoutNames : _workoutNames)[raw];
    if (pair != null) return pair.resolve(l);

    if (short) {
      final full = _workoutNames[raw];
      if (full != null) return full.resolve(l);
      return raw.split(' — ').first;
    }
    return raw;
  }

  static String exerciseName(PhoenixL10n l, String raw) {
    final pair = _exerciseNames[raw.trim()];
    return pair?.resolve(l) ?? raw;
  }

  static String mealPresetName(PhoenixL10n l, MealPreset preset) {
    final pair = _mealPresetNames[preset.id] ?? _mealPresetNames[preset.name];
    return pair?.resolve(l) ?? preset.name;
  }

  static String mealName(PhoenixL10n l, MealEntry meal) {
    final pair =
        _mealPresetNames[meal.presetId] ??
        _mealPresetNames[meal.name] ??
        _mealNames[meal.name];
    return pair?.resolve(l) ?? meal.name;
  }

  static String mealNameFromRaw(PhoenixL10n l, String raw) {
    final pair = _mealPresetNames[raw] ?? _mealNames[raw];
    return pair?.resolve(l) ?? raw;
  }

  static String exercisePrescription(
    PhoenixL10n l,
    ExercisePrescription prescription,
  ) {
    if (l.locale.languageCode != 'el') return prescription.summary;
    final target = prescription.isTimed
        ? _greekRange(
            prescription.minHoldSeconds,
            prescription.maxHoldSeconds,
            singular: 'δευτερόλεπτο',
            plural: 'δευτερόλεπτα',
          )
        : _greekRange(
            prescription.minReps,
            prescription.maxReps,
            singular: 'επανάληψη',
            plural: 'επαναλήψεις',
          );
    final rest = prescription.restSeconds >= 120
        ? minuteCount(l, prescription.restSeconds ~/ 60)
        : _greekRange(
            prescription.restSeconds,
            prescription.restSeconds,
            singular: 'δευτερόλεπτο',
            plural: 'δευτερόλεπτα',
          );
    final remaining = prescription.targetRir == 0
        ? 'σταμάτησε πριν χαλάσει η τεχνική σου'
        : prescription.targetRir == 1
        ? 'άφησε περίπου 1 σωστή επανάληψη'
        : 'άφησε περίπου ${prescription.targetRir} σωστές επαναλήψεις';
    return '${prescription.workingSets} σετ × $target • $remaining • $rest διάλειμμα';
  }

  static String _greekRange(
    int minimum,
    int maximum, {
    required String singular,
    required String plural,
  }) {
    if (minimum == maximum) {
      return '$minimum ${minimum == 1 ? singular : plural}';
    }
    return '$minimum–$maximum $plural';
  }

  static String _englishRange(
    int minimum,
    int maximum, {
    required String singular,
    required String plural,
  }) {
    if (minimum == maximum) {
      return '$minimum ${minimum == 1 ? singular : plural}';
    }
    return '$minimum–$maximum $plural';
  }

  static String trainingText(PhoenixL10n l, String raw) {
    if (l.locale.languageCode != 'el') return raw;
    return raw
        .replaceAll('RIR 1–2', 'άφησε 1–2 σωστές επαναλήψεις')
        .replaceAll('RIR 2', 'άφησε 2 σωστές επαναλήψεις')
        .replaceAll('RPE 5–6', 'μέτρια ένταση 5–6/10')
        .replaceAll('RPE 7–8', 'ένταση 7–8/10')
        .replaceAll('τεχνικό stop', 'σταμάτημα μόλις χαλάσει η τεχνική')
        .replaceAll('sprint', 'απότομη επιτάχυνση')
        .replaceAll('tempo', 'ρυθμό');
  }

  static const _workoutNames = <String, _CopyPair>{
    'IRON HYBRID — Full Body': _CopyPair(
      'Δύναμη με βάρη — Όλο το σώμα',
      'Dumbbell strength — Full body',
    ),
    'CALISTHENICS — Strict Strength': _CopyPair(
      'Δύναμη με το βάρος του σώματος',
      'Bodyweight training — Strength',
    ),
    'IRON ENGINE — Conditioning': _CopyPair(
      'Αντοχή και φυσική κατάσταση',
      'Strength and conditioning',
    ),
    'IRON UPPER — Strength': _CopyPair(
      'Δύναμη με βάρη — Άνω σώμα',
      'Strength — Upper body',
    ),
    'IRON LOWER — Strength': _CopyPair(
      'Δύναμη με βάρη — Πόδια',
      'Strength — Lower body',
    ),
    'CALISTHENICS — Skill Lab': _CopyPair(
      'Έλεγχος σώματος και σταθερότητα',
      'Body control and stability',
    ),
    'WEIGHTED CALISTHENICS': _CopyPair(
      'Ασκήσεις σώματος με πρόσθετο βάρος',
      'Weighted bodyweight training',
    ),
    'IRON FULL BODY — A': _CopyPair(
      'Όλο το σώμα με βάρη — Α',
      'Full body strength — A',
    ),
    'IRON FULL BODY — B': _CopyPair(
      'Όλο το σώμα με βάρη — Β',
      'Full body strength — B',
    ),
    'CUSTOM IRON — Νέο πρόγραμμα': _CopyPair(
      'Νέο πρόγραμμα με βάρη',
      'New strength program',
    ),
    'RECOVERY FLOW — Rest Day': _CopyPair(
      'Ήπια αποκατάσταση — Ημέρα ξεκούρασης',
      'Gentle recovery — Rest day',
    ),
  };

  static const _shortWorkoutNames = <String, _CopyPair>{
    'IRON HYBRID — Full Body': _CopyPair(
      'Όλο το σώμα με βάρη',
      'Full body strength',
    ),
    'CALISTHENICS — Strict Strength': _CopyPair(
      'Δύναμη με το σώμα',
      'Bodyweight strength',
    ),
    'IRON ENGINE — Conditioning': _CopyPair(
      'Αντοχή και φυσική κατάσταση',
      'Conditioning',
    ),
    'IRON UPPER — Strength': _CopyPair(
      'Άνω σώμα με βάρη',
      'Upper body strength',
    ),
    'IRON LOWER — Strength': _CopyPair('Πόδια με βάρη', 'Lower body strength'),
    'CALISTHENICS — Skill Lab': _CopyPair('Έλεγχος σώματος', 'Body control'),
    'WEIGHTED CALISTHENICS': _CopyPair(
      'Ασκήσεις σώματος με βάρος',
      'Weighted bodyweight training',
    ),
  };

  static const _exerciseNames = <String, _CopyPair>{
    'Goblet squat': _CopyPair('Κάθισμα με αλτήρα μπροστά', 'Goblet squat'),
    'Goblet squat σε πάγκο': _CopyPair(
      'Κάθισμα με αλτήρα σε πάγκο',
      'Goblet squat to bench',
    ),
    'Goblet squat με αλτήρα': _CopyPair(
      'Κάθισμα με αλτήρα μπροστά',
      'Dumbbell goblet squat',
    ),
    'Goblet squat με tempo 3″': _CopyPair(
      'Κάθισμα με αλτήρα σε αργό ρυθμό 3″',
      'Goblet squat with 3-second tempo',
    ),
    'Goblet squat με αλτήρα και tempo 3″': _CopyPair(
      'Κάθισμα με αλτήρα σε αργό ρυθμό 3″',
      'Dumbbell goblet squat with 3-second tempo',
    ),
    'Farmer carry': _CopyPair('Περπάτημα με βάρη', 'Farmer carry'),
    'Farmer carry με αλτήρες': _CopyPair(
      'Περπάτημα με αλτήρες',
      'Dumbbell farmer carry',
    ),
    'Suitcase carry με αλτήρα': _CopyPair(
      'Περπάτημα με έναν αλτήρα',
      'One-arm dumbbell carry',
    ),
    'Pike push-ups': _CopyPair(
      'Κάμψεις ώμων με τη λεκάνη ψηλά',
      'Pike push-ups',
    ),
    'Bulgarian split squat': _CopyPair(
      'Βουλγαρικό κάθισμα',
      'Bulgarian split squat',
    ),
    'Bulgarian split squat με στήριξη': _CopyPair(
      'Βουλγαρικό κάθισμα με στήριξη',
      'Supported Bulgarian split squat',
    ),
    'Bulgarian split squat με αλτήρες': _CopyPair(
      'Βουλγαρικό κάθισμα με αλτήρες',
      'Dumbbell Bulgarian split squat',
    ),
    'Hollow body hold': _CopyPair('Στατική θέση κοιλιακών', 'Hollow body hold'),
    'Step-ups': _CopyPair('Ανέβασμα σε σκαλοπάτι', 'Step-ups'),
    'Step-ups σε σταθερό πάγκο': _CopyPair(
      'Ανέβασμα σε σταθερό πάγκο',
      'Step-ups to a stable bench',
    ),
    'Sled push': _CopyPair('Σπρώξιμο έλκηθρου', 'Sled push'),
    'Bird dog': _CopyPair('Εναλλάξ έκταση χεριού και ποδιού', 'Bird dog'),
    'Dead bug': _CopyPair('Εναλλάξ κατέβασμα χεριού και ποδιού', 'Dead bug'),
    'Band face pulls': _CopyPair(
      'Τράβηγμα λάστιχου προς το πρόσωπο',
      'Band face pulls',
    ),
    'Κωπηλατική με λάστιχο — αργό tempo': _CopyPair(
      'Κωπηλατική με λάστιχο — αργός ρυθμός',
      'Slow-tempo band row',
    ),
    'Καθίσματα σε καρέκλα με tempo 3″': _CopyPair(
      'Καθίσματα σε καρέκλα με αργό ρυθμό 3″',
      'Chair squats with 3-second tempo',
    ),
    'March με φορτωμένο σακίδιο': _CopyPair(
      'Βάδισμα με φορτωμένο σακίδιο',
      'Loaded backpack march',
    ),
    'Face pulls': _CopyPair('Τράβηγμα τροχαλίας προς το πρόσωπο', 'Face pulls'),
    'Landmine press': _CopyPair('Μονόχειρη πίεση μπάρας', 'Landmine press'),
    'Pallof press': _CopyPair('Πίεση Pallof για σταθερό κορμό', 'Pallof press'),
    'Pallof press με λάστιχο': _CopyPair(
      'Πίεση λάστιχου μπροστά για σταθερό κορμό',
      'Band Pallof press',
    ),
    'Hip hinge χωρίς βάρος': _CopyPair(
      'Κάμψη ισχίων χωρίς βάρος',
      'Bodyweight hip hinge',
    ),
    'Hip thrust με παύση': _CopyPair(
      'Άρση λεκάνης με παύση',
      'Paused hip thrust',
    ),
    'Trap-bar deadlift': _CopyPair(
      'Άρση με εξάγωνη μπάρα',
      'Trap-bar deadlift',
    ),
    'Trap-bar deadlift από υπερύψωση': _CopyPair(
      'Άρση με εξάγωνη μπάρα από υπερύψωση',
      'Elevated trap-bar deadlift',
    ),
    'Front squat με safety bars': _CopyPair(
      'Μπροστινό κάθισμα με μπάρες ασφαλείας',
      'Front squat with safety bars',
    ),
    'Pistol squat σε κουτί': _CopyPair(
      'Μονόποδο κάθισμα σε κουτί',
      'Box pistol squat',
    ),
    'Hanging knee raises': _CopyPair(
      'Ανύψωση γονάτων σε μονόζυγο',
      'Hanging knee raises',
    ),
    'Hanging leg raises': _CopyPair(
      'Ανύψωση ποδιών σε μονόζυγο',
      'Hanging leg raises',
    ),
    'Air bike': _CopyPair('Στατικό ποδήλατο με χέρια', 'Air bike'),
    'Bear crawl αργού ρυθμού': _CopyPair(
      'Περπάτημα στα τέσσερα με αργό ρυθμό',
      'Slow bear crawl',
    ),
    'Mountain climbers ελεγχόμενα': _CopyPair(
      'Ελεγχόμενες εναλλαγές γονάτων σε σανίδα',
      'Controlled mountain climbers',
    ),
    'Handstand στον τοίχο': _CopyPair(
      'Κατακόρυφο στον τοίχο',
      'Wall handstand',
    ),
    'Scapular pull-ups': _CopyPair('Έλξεις ωμοπλάτης', 'Scapular pull-ups'),
    'Tuck L-sit': _CopyPair('Στήριξη L με λυγισμένα γόνατα', 'Tuck L-sit'),
    'Arch body hold': _CopyPair('Στατική έκταση κορμού', 'Arch body hold'),
  };

  static const _mealPresetNames = <String, _CopyPair>{
    'preset-power-breakfast': _CopyPair('Δυναμωτικό πρωινό', 'Power breakfast'),
    'Power πρωινό': _CopyPair('Δυναμωτικό πρωινό', 'Power breakfast'),
    'preset-recovery-bowl': _CopyPair('Μπολ αποκατάστασης', 'Recovery bowl'),
    'Recovery bowl': _CopyPair('Μπολ αποκατάστασης', 'Recovery bowl'),
  };

  static const _mealNames = <String, _CopyPair>{
    'Protein bowl (photo estimate)': _CopyPair(
      'Μπολ με πρωτεΐνη (εκτίμηση από φωτογραφία)',
      'Protein bowl (photo estimate)',
    ),
    'Rice & protein (photo estimate)': _CopyPair(
      'Ρύζι με πρωτεΐνη (εκτίμηση από φωτογραφία)',
      'Rice & protein (photo estimate)',
    ),
    'Sandwich / wrap (photo estimate)': _CopyPair(
      'Σάντουιτς ή πίτα (εκτίμηση από φωτογραφία)',
      'Sandwich or wrap (photo estimate)',
    ),
    'Pasta meal (photo estimate)': _CopyPair(
      'Ζυμαρικά (εκτίμηση από φωτογραφία)',
      'Pasta meal (photo estimate)',
    ),
    'Big salad (photo estimate)': _CopyPair(
      'Μεγάλη σαλάτα (εκτίμηση από φωτογραφία)',
      'Big salad (photo estimate)',
    ),
    'Snack / dessert (photo estimate)': _CopyPair(
      'Σνακ ή γλυκό (εκτίμηση από φωτογραφία)',
      'Snack or dessert (photo estimate)',
    ),
  };
}

class _CopyPair {
  const _CopyPair(this.greek, this.english);

  final String greek;
  final String english;

  String resolve(PhoenixL10n l) => l.text(greek, english);
}
