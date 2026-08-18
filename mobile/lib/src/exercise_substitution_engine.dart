import 'equipment_availability.dart';
import 'models/fitness_models.dart';

class ExerciseAlternative {
  const ExerciseAlternative({
    required this.name,
    required this.reason,
    required this.tag,
  });

  final String name;
  final String reason;
  final String tag;
}

class ExerciseSubstitutionEngine {
  const ExerciseSubstitutionEngine._();

  static List<ExerciseAlternative> alternativesFor({
    required String exercise,
    required UserProfile? profile,
    required Iterable<String> excludedExercises,
    Iterable<String> painAreas = const [],
  }) {
    final name = exercise.toLowerCase();
    final candidates = _candidatesFor(name);
    final excluded = excludedExercises.toSet()..add(exercise);
    final pain = painAreas.map((item) => item.toLowerCase()).toSet();
    return candidates
        .where((candidate) => !excluded.contains(candidate.name))
        .where(
          (candidate) =>
              EquipmentAvailability.supportsExercise(candidate.name, profile),
        )
        .where((candidate) => !_conflictsWithPain(candidate.name, pain))
        .map(
          (candidate) => pain.isEmpty
              ? candidate
              : ExerciseAlternative(
                  name: candidate.name,
                  reason:
                      '${candidate.reason} Επιλέχθηκε λαμβάνοντας υπόψη το πρόσφατο pain log.',
                  tag: 'PAIN-AWARE',
                ),
        )
        .take(4)
        .toList();
  }

  static bool _conflictsWithPain(String exercise, Set<String> painAreas) {
    final name = exercise.toLowerCase();
    final hasKnee = painAreas.any(
      (area) => _containsAny(area, ['γόνα', 'knee']),
    );
    final hasShoulder = painAreas.any(
      (area) => _containsAny(area, ['ώμ', 'shoulder']),
    );
    final hasBack = painAreas.any(
      (area) => _containsAny(area, ['μέση', 'πλάτ', 'back']),
    );
    if (hasKnee &&
        _containsAny(name, ['pistol', 'bulgarian', 'step-up', 'front squat'])) {
      return true;
    }
    if (hasShoulder &&
        _containsAny(name, ['pike', 'πιέσεις ώμων', 'dip', 'βυθίσεις'])) {
      return true;
    }
    if (hasBack &&
        _containsAny(name, ['deadlift', 'άρσεις', 'μονόχειρη κωπηλατική'])) {
      return true;
    }
    return false;
  }

  static List<ExerciseAlternative> _candidatesFor(String name) {
    if (_containsAny(name, ['πιέσεις στήθους', 'κάμψεις', 'push-up'])) {
      return const [
        ExerciseAlternative(
          name: 'Κάμψεις σε υπερυψωμένη επιφάνεια',
          reason: 'Ίδιο push μοτίβο με μικρότερο σχετικό φορτίο.',
          tag: 'ΕΥΚΟΛΟΤΕΡΗ',
        ),
        ExerciseAlternative(
          name: 'Κάμψεις με παύση 1″',
          reason: 'Χωρίς εξοπλισμό και με αυστηρό έλεγχο.',
          tag: 'ΣΩΜΑΤΙΚΟ ΒΑΡΟΣ',
        ),
        ExerciseAlternative(
          name: 'Πιέσεις στήθους με αλτήρες',
          reason: 'Ουδέτερη, ανεξάρτητη τροχιά για κάθε ώμο.',
          tag: 'ΑΛΤΗΡΕΣ',
        ),
        ExerciseAlternative(
          name: 'Κάμψεις κλειστής λαβής',
          reason: 'Push παραλλαγή με μεγαλύτερη έμφαση στους τρικεφάλους.',
          tag: 'ΠΑΡΑΛΛΑΓΗ',
        ),
      ];
    }
    if (_containsAny(name, ['pike', 'πιέσεις ώμων', 'landmine'])) {
      return const [
        ExerciseAlternative(
          name: 'Πιέσεις ώμων με λάστιχο',
          reason: 'Ελεγχόμενη αντίσταση χωρίς βαρύ εξοπλισμό.',
          tag: 'ΛΑΣΤΙΧΟ',
        ),
        ExerciseAlternative(
          name: 'Landmine press',
          reason: 'Διαγώνια πίεση με φιλική τροχιά για τον ώμο.',
          tag: 'ΕΛΕΓΧΟΜΕΝΗ',
        ),
        ExerciseAlternative(
          name: 'Pike push-ups',
          reason: 'Κάθετη πίεση με σωματικό βάρος.',
          tag: 'ΣΩΜΑΤΙΚΟ ΒΑΡΟΣ',
        ),
      ];
    }
    if (_containsAny(name, ['έλξεις', 'pull-up', 'τροχαλίας'])) {
      return const [
        ExerciseAlternative(
          name: 'Υποβοηθούμενες έλξεις',
          reason: 'Ίδιο κάθετο pull με ελεγχόμενη δυσκολία.',
          tag: 'REGRESSION',
        ),
        ExerciseAlternative(
          name: 'Έλξεις τροχαλίας ουδέτερη λαβή',
          reason: 'Σταθερή αντίσταση και εύκολη ρύθμιση φορτίου.',
          tag: 'ΤΡΟΧΑΛΙΑ',
        ),
        ExerciseAlternative(
          name: 'Κωπηλατική με λάστιχο — αργό tempo',
          reason: 'Ασφαλής pull επιλογή όταν δεν υπάρχει μονόζυγο.',
          tag: 'ΧΩΡΙΣ ΜΟΝΟΖΥΓΟ',
        ),
        ExerciseAlternative(
          name: 'Αυστηρές έλξεις',
          reason: 'Η βασική παραλλαγή χωρίς πρόσθετο φορτίο.',
          tag: 'ΒΑΣΙΚΗ',
        ),
      ];
    }
    if (_containsAny(name, ['κωπηλατική', 'face pull'])) {
      return const [
        ExerciseAlternative(
          name: 'Κωπηλατική με λάστιχο — αργό tempo',
          reason: 'Ίδιο horizontal pull με ελαφρύ εξοπλισμό.',
          tag: 'ΛΑΣΤΙΧΟ',
        ),
        ExerciseAlternative(
          name: 'Κωπηλατική με στήριξη στήθους',
          reason: 'Μειώνει την απαίτηση σταθεροποίησης της μέσης.',
          tag: 'ΣΤΗΡΙΞΗ',
        ),
        ExerciseAlternative(
          name: 'Μονόχειρη κωπηλατική με αλτήρα',
          reason: 'Μονόπλευρη δουλειά με εύκολη ρύθμιση φορτίου.',
          tag: 'ΑΛΤΗΡΑΣ',
        ),
        ExerciseAlternative(
          name: 'Face pulls',
          reason: 'Ελαφρύτερο pull με έμφαση στον έλεγχο ωμοπλάτης.',
          tag: 'ACCESSORY',
        ),
      ];
    }
    if (_containsAny(name, ['squat', 'καθίσματα'])) {
      return const [
        ExerciseAlternative(
          name: 'Goblet squat σε πάγκο',
          reason: 'Σταθερό βάθος και εύκολος έλεγχος της τεχνικής.',
          tag: 'ΕΛΕΓΧΟΜΕΝΗ',
        ),
        ExerciseAlternative(
          name: 'Καθίσματα σε πάγκο με σακίδιο',
          reason: 'Λειτουργεί στο σπίτι με απλό φορτίο.',
          tag: 'ΣΠΙΤΙ',
        ),
        ExerciseAlternative(
          name: 'Goblet squat με tempo 3″',
          reason: 'Μικρότερο φορτίο, περισσότερος έλεγχος.',
          tag: 'TEMPO',
        ),
        ExerciseAlternative(
          name: 'Front squat με safety bars',
          reason: 'Δυναμική παραλλαγή με ασφαλή ρύθμιση rack.',
          tag: 'ΔΥΝΑΜΗ',
        ),
      ];
    }
    if (_containsAny(name, ['ρουμανικ', 'trap-bar', 'deadlift'])) {
      return const [
        ExerciseAlternative(
          name: 'Ρουμανικές άρσεις με αλτήρες',
          reason: 'Hinge με εύκολη ρύθμιση φορτίου και εύρους.',
          tag: 'ΑΛΤΗΡΕΣ',
        ),
        ExerciseAlternative(
          name: 'Ρουμανικές άρσεις με σακίδιο',
          reason: 'Το ίδιο μοτίβο χωρίς γυμναστηριακό εξοπλισμό.',
          tag: 'ΣΠΙΤΙ',
        ),
        ExerciseAlternative(
          name: 'Hip thrust με παύση',
          reason: 'Γλουτιαία δουλειά με μικρότερη απαίτηση από τη μέση.',
          tag: 'ΕΛΕΓΧΟΜΕΝΗ',
        ),
        ExerciseAlternative(
          name: 'Trap-bar deadlift από υπερύψωση',
          reason: 'Μειωμένο εύρος και πιο εύκολη αρχική θέση.',
          tag: 'REGRESSION',
        ),
      ];
    }
    if (_containsAny(name, ['bulgarian', 'προβολ', 'pistol', 'step-up'])) {
      return const [
        ExerciseAlternative(
          name: 'Ανάστροφες προβολές με στήριξη',
          reason: 'Μονόπλευρη άσκηση με εξωτερική σταθερότητα.',
          tag: 'ΕΥΚΟΛΟΤΕΡΗ',
        ),
        ExerciseAlternative(
          name: 'Bulgarian split squat με στήριξη',
          reason: 'Ίδιο μοτίβο με καλύτερο έλεγχο ισορροπίας.',
          tag: 'ΣΤΗΡΙΞΗ',
        ),
        ExerciseAlternative(
          name: 'Step-ups σε σταθερό πάγκο',
          reason: 'Μονόπλευρη δουλειά με ελεγχόμενο ύψος.',
          tag: 'ΣΤΑΘΕΡΗ',
        ),
        ExerciseAlternative(
          name: 'Bulgarian split squat',
          reason: 'Η βασική αυστηρή παραλλαγή.',
          tag: 'ΒΑΣΙΚΗ',
        ),
      ];
    }
    if (_containsAny(name, ['hollow', 'dead bug', 'pallof', 'hanging'])) {
      return const [
        ExerciseAlternative(
          name: 'Dead bug',
          reason: 'Core έλεγχος με τη μέση υποστηριζόμενη.',
          tag: 'ΕΥΚΟΛΟΤΕΡΗ',
        ),
        ExerciseAlternative(
          name: 'Pallof press με λάστιχο',
          reason: 'Anti-rotation χωρίς φόρτιση της σπονδυλικής στήλης.',
          tag: 'ANTI-ROTATION',
        ),
        ExerciseAlternative(
          name: 'Hollow body hold',
          reason: 'Στατικό anti-extension με προοδευτικό μοχλό.',
          tag: 'ΙΣΟΜΕΤΡΙΚΗ',
        ),
        ExerciseAlternative(
          name: 'Hanging knee raises',
          reason: 'Core με ενεργό έλεγχο ώμων και λεκάνης.',
          tag: 'ΠΡΟΧΩΡΗΜΕΝΗ',
        ),
      ];
    }
    if (_containsAny(name, ['farmer', 'suitcase', 'carry', 'march'])) {
      return const [
        ExerciseAlternative(
          name: 'Suitcase carry με αλτήρα',
          reason: 'Μονόπλευρη μεταφορά με μικρότερο συνολικό φορτίο.',
          tag: 'ΜΟΝΟΠΛΕΥΡΗ',
        ),
        ExerciseAlternative(
          name: 'March με φορτωμένο σακίδιο',
          reason: 'Carry μοτίβο σε μικρό χώρο και χωρίς αλτήρες.',
          tag: 'ΣΠΙΤΙ',
        ),
        ExerciseAlternative(
          name: 'Farmer carry με αλτήρες',
          reason: 'Βασική συμμετρική μεταφορά φορτίου.',
          tag: 'ΒΑΣΙΚΗ',
        ),
      ];
    }
    if (_containsAny(name, [
      'sled',
      'εργόμετρο',
      'air bike',
      'bear crawl',
      'mountain climber',
    ])) {
      return const [
        ExerciseAlternative(
          name: 'Κωπηλατικό εργόμετρο',
          reason: 'Low-impact conditioning με μετρήσιμο ρυθμό.',
          tag: 'LOW IMPACT',
        ),
        ExerciseAlternative(
          name: 'Air bike',
          reason: 'Conditioning χωρίς κραδασμούς ή άλματα.',
          tag: 'LOW IMPACT',
        ),
        ExerciseAlternative(
          name: 'Bear crawl αργού ρυθμού',
          reason: 'Conditioning και core με σωματικό βάρος.',
          tag: 'ΣΠΙΤΙ',
        ),
        ExerciseAlternative(
          name: 'Mountain climbers ελεγχόμενα',
          reason: 'Ρυθμιζόμενη ένταση χωρίς εξοπλισμό.',
          tag: 'ΧΩΡΙΣ ΕΞΟΠΛΙΣΜΟ',
        ),
      ];
    }
    return const [];
  }

  static bool _containsAny(String value, List<String> terms) =>
      terms.any(value.contains);
}
