import 'package:flutter/material.dart';

class ExerciseGuide {
  const ExerciseGuide({
    required this.assetPath,
    required this.bandIndex,
    required this.bandCount,
    required this.execution,
    required this.avoid,
  });

  final String assetPath;
  final int bandIndex;
  final int bandCount;
  final String execution;
  final String avoid;
}

class ExerciseGuideCatalog {
  const ExerciseGuideCatalog._();

  static ExerciseGuide? forExercise(String exercise) {
    final name = exercise.toLowerCase();

    if (name.contains('landmine')) {
      return _advanced(
        1,
        'Σφίξε κορμό και πίεσε διαγώνια χωρίς να ανοίγουν τα πλευρά.',
        'Μην υπερεκτείνεις τη μέση και μη στρίβεις τον κορμό.',
      );
    }
    if (name.contains('trap-bar')) {
      return _advanced(
        0,
        'Πίεσε το πάτωμα, κράτησε τον κορμό σταθερό και σήκω όρθιος.',
        'Μην καμπουριάζεις και μη γέρνεις πίσω στο τελείωμα.',
      );
    }
    if (name.contains('βυθίσεις') || name.contains('dip')) {
      return _advanced(
        2,
        'Κατέβα ελεγχόμενα μόνο όσο ο ώμος μένει σταθερός και πίεσε ψηλά.',
        'Όχι υπερβολικό βάθος, αναπήδηση ή ώμοι προς τα αυτιά.',
      );
    }
    if (name.contains('pistol')) {
      return _advanced(
        3,
        'Κάθισε απαλά στο κουτί με το γόνατο να ακολουθεί τα δάχτυλα.',
        'Μην πέφτεις στο κουτί και μη στρίβεις το γόνατο προς τα μέσα.',
      );
    }

    if (name.contains('pike')) {
      return _push(
        1,
        'Κράτησε τους γοφούς ψηλά και κατέβασε το κεφάλι ανάμεσα στα χέρια.',
        'Μην ανοίγεις απότομα τους αγκώνες και μη χάνεις τον έλεγχο.',
      );
    }
    if (name.contains('πιέσεις στήθους') || name.contains('πιέσεις πάγκου')) {
      return _push(
        2,
        'Πέλματα σταθερά, καρποί ουδέτεροι και αλτήρες πάνω από το στήθος.',
        'Μην ανασηκώνεις τους ώμους και μη χτυπάς τους αλτήρες μεταξύ τους.',
      );
    }
    if (name.contains('πιέσεις ώμων')) {
      return _push(
        1,
        'Κράτησε τον κορμό σφιχτό και πίεσε χωρίς να ανοίγουν τα πλευρά.',
        'Μην υπερεκτείνεις τη μέση και μη βιάζεις την αρνητική φάση.',
      );
    }
    if (name.contains('κάμψεις') || name.contains('push-up')) {
      return _push(
        0,
        'Σώμα σε μία γραμμή, αγκώνες περίπου 30–45° και ελεγχόμενη κάθοδος.',
        'Μην αφήνεις τη μέση να κρεμάσει και μη σηκώνεις πρώτα το στήθος.',
      );
    }

    if (name.contains('scapular')) {
      return _skills(
        1,
        'Με ίσιους αγκώνες, κατέβασε ελαφρά τις ωμοπλάτες και ξαναχαλάρωσε.',
        'Μην λυγίζεις τους αγκώνες και μη χρησιμοποιείς αιώρηση.',
      );
    }
    if (name.contains('hanging knee') ||
        name.contains('hanging leg') ||
        name.contains('κρεμαστ')) {
      return _skills(
        3,
        'Ξεκίνα από ενεργό κρέμασμα και σήκωσε τα γόνατα χωρίς φόρα.',
        'Μην κουνιέσαι μπρος-πίσω και μη χαλαρώνεις απότομα τους ώμους.',
      );
    }
    if (name.contains('έλξεις') || name.contains('pull-up')) {
      return _pull(
        0,
        'Ξεκίνα από ενεργούς ώμους και τράβα το στήθος προς τη μπάρα.',
        'Χωρίς κλωτσιές, αιώρηση ή βίαιο τέντωμα στον πάτο.',
      );
    }
    if (name.contains('κωπηλατικό εργόμετρο')) {
      return _conditioning(
        0,
        'Πόδια πρώτα, μετά κορμός και χέρια· επέστρεψε με αντίστροφη σειρά.',
        'Μην τραβάς μόνο με τα χέρια και μη στρογγυλεύεις τη μέση.',
      );
    }
    if (name.contains('κωπηλατική με λάστιχο') || name.contains('face pull')) {
      return _pull(
        1,
        'Τράβα τους αγκώνες πίσω με σταθερό κορμό και ήρεμη επιστροφή.',
        'Μην ανασηκώνεις ώμους και μη γέρνεις για να κερδίσεις εύρος.',
      );
    }
    if (name.contains('κωπηλατική')) {
      return _pull(
        2,
        'Στήριξε το στήθος, τράβα τους αγκώνες προς τα ισχία και κατέβα αργά.',
        'Μην τινάζεις τα βάρη και μη σηκώνεις το κεφάλι.',
      );
    }

    if (name.contains('ρουμανικ')) {
      return _legs(
        1,
        'Στείλε τους γοφούς πίσω, κράτα τα βάρη κοντά και τη μέση ουδέτερη.',
        'Μην κυνηγάς βάθος όταν αρχίζει να στρογγυλεύει η πλάτη.',
      );
    }
    if (name.contains('bulgarian') ||
        name.contains('βουλγαρ') ||
        name.contains('προβολ')) {
      return _legs(
        2,
        'Κατέβα κατακόρυφα με το μπροστινό πέλμα ολόκληρο στο έδαφος.',
        'Μην πιέζεις από το πίσω πόδι και μη γέρνει το γόνατο προς τα μέσα.',
      );
    }
    if (name.contains('squat') ||
        name.contains('καθίσματα') ||
        name.contains('πιέσεις ποδιών')) {
      return _legs(
        0,
        'Πάτησε όλο το πέλμα και άφησε τα γόνατα να ακολουθούν τα δάχτυλα.',
        'Μην κατεβαίνεις βαθύτερα από όσο κρατάς έλεγχο και ουδέτερη μέση.',
      );
    }

    if (name.contains('hip thrust') || name.contains('γέφυρ')) {
      return _accessory(
        0,
        'Κράτησε πλευρά κάτω και ολοκλήρωσε με γλουτούς, όχι με τη μέση.',
        'Μην πετάς το κεφάλι πίσω και μη συνεχίζεις πέρα από ουδέτερη θέση.',
      );
    }
    if (name.contains('γάμπ')) {
      return _accessory(
        1,
        'Ανέβα ψηλά, κράτησε μία στιγμή και κατέβασε τη φτέρνα αργά.',
        'Μην αναπηδάς και μη γυρίζει ο αστράγαλος προς τα έξω.',
      );
    }
    if (name.contains('pallof')) {
      return _accessory(
        2,
        'Πίεσε τα χέρια μπροστά χωρίς να επιτρέψεις περιστροφή του κορμού.',
        'Μην στρίβεις προς το λάστιχο και μην κρατάς την αναπνοή.',
      );
    }
    if (name.contains('dead bug')) {
      return _accessory(
        3,
        'Πίεσε τη μέση στο έδαφος και άνοιξε αντίθετο χέρι και πόδι.',
        'Σταμάτα το εύρος μόλις η μέση αρχίζει να σηκώνεται.',
      );
    }

    if (name.contains('handstand')) {
      return _skills(
        0,
        'Χρησιμοποίησε τον τοίχο, πίεσε το πάτωμα και κράτησε τον κορμό σφιχτό.',
        'Μην επιχειρείς ελεύθερη ισορροπία όταν είσαι κουρασμένος.',
      );
    }
    if (name.contains('l-sit')) {
      return _skills(
        2,
        'Πίεσε δυνατά τις μπάρες, κράτησε ώμους χαμηλά και μάζεψε γόνατα.',
        'Μην βυθίζεσαι στους ώμους και μη συνεχίζεις όταν χάνεται η στήριξη.',
      );
    }
    if (name.contains('hollow') || name.contains('arch body')) {
      return _core(
        0,
        'Κράτησε τη μέση σε επαφή με το έδαφος και άνοιξε σταδιακά το σώμα.',
        'Μίκρυνε τον μοχλό αμέσως αν σηκώνεται ή ενοχλείται η μέση.',
      );
    }
    if (name.contains('farmer') ||
        name.contains('suitcase') ||
        name.contains('φορτωμένο σακίδιο')) {
      return _core(
        1,
        'Περπάτα ψηλά με μικρά σταθερά βήματα και ώμους στο ίδιο ύψος.',
        'Μην γέρνεις προς το βάρος και μη βιάζεις τις στροφές.',
      );
    }
    if (name.contains('step-up')) {
      return _core(
        2,
        'Βάλε όλο το πέλμα στο κουτί και ανέβα πιέζοντας από το μπροστινό πόδι.',
        'Μην σπρώχνεις δυνατά από το κάτω πόδι και μη χρησιμοποιείς ασταθή βάση.',
      );
    }
    if (name.contains('sled')) {
      return _core(
        3,
        'Κράτησε σταθερή κλίση κορμού και ώθησε με μικρά δυνατά βήματα.',
        'Μην στρογγυλεύεις τη μέση και μην επιλέγεις βάρος που σε σταματά.',
      );
    }

    if (name.contains('air bike')) {
      return _conditioning(
        1,
        'Κράτησε κορμό σταθερό και συντόνισε ομαλά χέρια και πόδια.',
        'Μην ξεκινάς με sprint και μη χάνεις τη θέση σου στη σέλα.',
      );
    }
    if (name.contains('bear crawl')) {
      return _conditioning(
        2,
        'Κράτησε γόνατα χαμηλά και κίνησε αντίθετο χέρι και πόδι.',
        'Μην σηκώνεις ψηλά τους γοφούς και μη βιάζεις τα βήματα.',
      );
    }
    if (name.contains('mountain climber')) {
      return _conditioning(
        3,
        'Διατήρησε δυνατή σανίδα και φέρε το γόνατο μπροστά ελεγχόμενα.',
        'Μην αναπηδούν οι γοφοί και μη θυσιάζεις τη θέση για ταχύτητα.',
      );
    }

    return null;
  }

  static ExerciseGuide _push(int index, String execution, String avoid) =>
      _guide('push-guide.png', index, 3, execution, avoid);

  static ExerciseGuide _pull(int index, String execution, String avoid) =>
      _guide('pull-guide.png', index, 3, execution, avoid);

  static ExerciseGuide _legs(int index, String execution, String avoid) =>
      _guide('legs-guide.png', index, 3, execution, avoid);

  static ExerciseGuide _core(int index, String execution, String avoid) =>
      _guide('core-conditioning-guide.png', index, 4, execution, avoid);

  static ExerciseGuide _accessory(int index, String execution, String avoid) =>
      _guide('accessory-guide.png', index, 4, execution, avoid);

  static ExerciseGuide _skills(int index, String execution, String avoid) =>
      _guide('skills-guide.png', index, 4, execution, avoid);

  static ExerciseGuide _conditioning(
    int index,
    String execution,
    String avoid,
  ) => _guide('conditioning-guide.png', index, 4, execution, avoid);

  static ExerciseGuide _advanced(int index, String execution, String avoid) =>
      _guide('advanced-guide.png', index, 4, execution, avoid);

  static ExerciseGuide _guide(
    String filename,
    int bandIndex,
    int bandCount,
    String execution,
    String avoid,
  ) => ExerciseGuide(
    assetPath: 'assets/exercise_guides/$filename',
    bandIndex: bandIndex,
    bandCount: bandCount,
    execution: execution,
    avoid: avoid,
  );
}

Future<void> showExerciseGuide(
  BuildContext context,
  String exercise,
  ExerciseGuide guide,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'ΑΡΧΙΚΗ ΘΕΣΗ  →  ΤΕΛΙΚΗ ΘΕΣΗ',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _GuideBand(guide: guide),
          ),
          const SizedBox(height: 18),
          _GuideCue(
            icon: Icons.check_circle_outline,
            color: const Color(0xFF61D095),
            title: 'ΕΚΤΕΛΕΣΗ',
            detail: guide.execution,
          ),
          const SizedBox(height: 12),
          _GuideCue(
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFFF9E80),
            title: 'ΑΠΟΦΥΓΕ',
            detail: guide.avoid,
          ),
          const SizedBox(height: 14),
          Text(
            'Η εικόνα είναι οδηγός τεχνικής, όχι ιατρική αξιολόγηση. '
            'Αν υπάρχει πόνος, σταμάτα την άσκηση.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .45),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
  ),
);

class _GuideBand extends StatelessWidget {
  const _GuideBand({required this.guide});

  final ExerciseGuide guide;

  @override
  Widget build(BuildContext context) {
    final alignment = guide.bandCount == 1
        ? 0.0
        : -1 + (2 * guide.bandIndex / (guide.bandCount - 1));
    return ClipRect(
      child: Align(
        alignment: Alignment(0, alignment),
        heightFactor: 1 / guide.bandCount,
        child: Image.asset(
          guide.assetPath,
          width: double.infinity,
          fit: BoxFit.fitWidth,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

class _GuideCue extends StatelessWidget {
  const _GuideCue({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        border: Border.all(color: color.withValues(alpha: .22)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(detail, style: const TextStyle(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
