import 'package:flutter/material.dart';

import 'phoenix_copy.dart';
import 'phoenix_l10n.dart';

class ExerciseGuide {
  const ExerciseGuide({
    required this.assetPath,
    required this.bandIndex,
    required this.bandCount,
    required this.execution,
    required this.avoid,
    this.equipmentLabel = '',
    this.stageCount = 2,
  });

  final String assetPath;
  final int bandIndex;
  final int bandCount;
  final String execution;
  final String avoid;
  final String equipmentLabel;
  final int stageCount;

  String localizedEquipmentLabel(PhoenixL10n l) => switch (equipmentLabel) {
    'ΣΠΙΤΙ • ΧΩΡΙΣ ΕΞΟΠΛΙΣΜΟ' => l.text(
      'ΣΠΙΤΙ • ΧΩΡΙΣ ΕΞΟΠΛΙΣΜΟ',
      'HOME • NO EQUIPMENT',
    ),
    'ΣΠΙΤΙ • ΑΛΤΗΡΕΣ' => l.text('ΣΠΙΤΙ • ΑΛΤΗΡΕΣ', 'HOME • DUMBBELLS'),
    'ΣΠΙΤΙ • ΛΑΣΤΙΧΟ' => l.text('ΣΠΙΤΙ • ΛΑΣΤΙΧΟ', 'HOME • BAND'),
    'ΣΠΙΤΙ • ΑΠΛΟΣ ΔΙΑΔΡΟΜΟΣ' => l.text(
      'ΣΠΙΤΙ • ΑΠΛΟΣ ΔΙΑΔΡΟΜΟΣ',
      'HOME • BASIC TREADMILL',
    ),
    'ΣΠΙΤΙ • ΜΟΝΟΖΥΓΟ • ΧΩΡΙΣ ΛΑΣΤΙΧΟ' => l.text(
      'ΣΠΙΤΙ • ΜΟΝΟΖΥΓΟ • ΧΩΡΙΣ ΛΑΣΤΙΧΟ',
      'HOME • PULL-UP BAR • NO BAND',
    ),
    'ΣΠΙΤΙ • ΣΤΑΘΕΡΗ ΚΑΡΕΚΛΑ' => l.text(
      'ΣΠΙΤΙ • ΣΤΑΘΕΡΗ ΚΑΡΕΚΛΑ',
      'HOME • STABLE CHAIR',
    ),
    'ΣΠΙΤΙ • ΣΤΑΘΕΡΟ ΤΡΑΠΕΖΙ' => l.text(
      'ΣΠΙΤΙ • ΣΤΑΘΕΡΟ ΤΡΑΠΕΖΙ',
      'HOME • STURDY TABLE',
    ),
    'ΕΞΩ • ΧΩΡΙΣ ΕΞΟΠΛΙΣΜΟ' => l.text(
      'ΕΞΩ • ΧΩΡΙΣ ΕΞΟΠΛΙΣΜΟ',
      'OUTDOORS • NO EQUIPMENT',
    ),
    _ => equipmentLabel,
  };
}

class ExerciseGuideCatalog {
  const ExerciseGuideCatalog._();

  static ExerciseGuide? forExercise(String exercise, {bool atHome = false}) {
    final name = exercise.toLowerCase();

    if (name.contains('περπάτημα σε εξωτερικό') ||
        name.contains('outdoor walk')) {
      return _outdoorWalking(
        'Περπάτα με ήρεμο, φυσικό βήμα, χαλαρούς ώμους και βλέμμα μπροστά.',
        'Μην κυνηγάς ταχύτητα και μην συνεχίζεις αν νιώσεις πόνο ή ζάλη.',
      );
    }

    if (atHome) return _forHomeExercise(name);

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

  static ExerciseGuide? _forHomeExercise(String name) {
    if (name.contains('κάθισμα και σήκωμα από καρέκλα') ||
        name.contains('chair sit-to-stand')) {
      return _homeRestartBasics(
        0,
        'Πάτησε ολόκληρο το πέλμα, γείρε λίγο μπροστά και σηκώσου χωρίς φόρα.',
        'Μην πέφτεις στην καρέκλα και μην αφήνεις τα γόνατα να κλείνουν προς τα μέσα.',
      );
    }
    if (name.contains('κάμψεις στον τοίχο') || name.contains('wall push-up')) {
      return _homeRestartBasics(
        1,
        'Κράτησε το σώμα σε μία γραμμή και πλησίασε αργά το στήθος στον τοίχο.',
        'Μην αφήνεις τη μέση να κρεμάσει και μην ανοίγεις απότομα τους αγκώνες.',
      );
    }
    if (name.contains('bird dog')) {
      return _homeRestartBasics(
        2,
        'Τέντωσε αντίθετο χέρι και πόδι χωρίς να περιστρέφεται η λεκάνη.',
        'Μην σηκώνεις το πόδι ψηλότερα από όσο κρατάς τη μέση σταθερή.',
      );
    }
    if (name.contains('γέφυρα γλουτών') || name.contains('glute bridge')) {
      return _homeRestartBasics(
        3,
        'Πίεσε τα πέλματα και σήκωσε τη λεκάνη μέχρι ο κορμός να γίνει μία ήρεμη γραμμή.',
        'Μην υπερεκτείνεις τη μέση και μην πιέζεις από τον αυχένα.',
      );
    }
    if (name.contains('διάδρομ') || name.contains('treadmill')) {
      return _homeCardio(
        0,
        'Περπάτα όρθιος και άνετα, με μικρό σταθερό βήμα και χωρίς να κρατιέσαι σφιχτά.',
        'Μην ανεβάζεις ταχύτητα ή κλίση αν χάνεις τον φυσικό σου ρυθμό.',
      );
    }
    if (name.contains('step-up') || name.contains('σκαλοπάτι')) {
      return _homeCardio(
        1,
        'Βάλε όλο το πέλμα στη σταθερή χαμηλή επιφάνεια και ανέβα αργά.',
        'Μη χρησιμοποιείς καρέκλα ή ασταθές έπιπλο ως σκαλοπάτι.',
      );
    }
    if (name.contains('bear crawl')) {
      return _homeCardio(
        2,
        'Κράτησε τον κορμό σταθερό και κίνησε αντίθετο χέρι και πόδι αργά.',
        'Μη σηκώνεις ψηλά τους γοφούς και σταμάτα αν ενοχλούνται οι καρποί.',
      );
    }
    if (name.contains('mountain climber')) {
      return _homeCardio(
        3,
        'Από σταθερή σανίδα, φέρε ένα γόνατο μπροστά χωρίς αναπήδηση.',
        'Μην κυνηγάς ταχύτητα όταν μετακινείται η μέση ή οι ώμοι.',
      );
    }

    if (name.contains('κωπηλατική με λάστιχο') || name.contains('band row')) {
      return _homeBands(
        0,
        'Με ασφαλή άγκυρα, τράβα τους αγκώνες πίσω και επέστρεψε αργά.',
        'Μη χρησιμοποιείς χαλαρή πόρτα ή φθαρμένο λάστιχο.',
      );
    }
    if (name.contains('πιέσεις ώμων με λάστιχο') ||
        name.contains('band shoulder')) {
      return _homeBands(
        1,
        'Πάτησε το λάστιχο σταθερά και πίεσε ψηλά χωρίς να καμπυλώνει η μέση.',
        'Μην αφήνεις το λάστιχο να γλιστρά κάτω από τα πέλματα.',
      );
    }
    if (name.contains('face pull')) {
      return _homeBands(
        2,
        'Τράβα το λάστιχο προς το πρόσωπο με τους αγκώνες ανοιχτούς και ήρεμη επιστροφή.',
        'Μην ανασηκώνεις τους ώμους και μη χρησιμοποιείς ασταθή άγκυρα.',
      );
    }
    if (name.contains('έλξεις') || name.contains('pull-up')) {
      return _homePullUp(
        'Ανέβα με βοήθεια από το χαμηλό σκαλοπάτι και κατέβα αργά, κρατώντας τους ώμους ενεργούς.',
        'Μην πηδάς προς τη μπάρα, μην αιωρείσαι και μη χρησιμοποιείς ασταθές μονόζυγο ή καρέκλα.',
      );
    }

    if (name.contains('goblet') ||
        ((name.contains('squat') || name.contains('κάθισ')) &&
            (name.contains('αλτήρ') || name.contains('βαράκ')))) {
      return _homeDumbbells(
        0,
        'Κράτησε το βάρος κοντά στο στήθος, πάτησε όλο το πέλμα και κάθισε ελεγχόμενα.',
        'Μην επιλέγεις βάθος που σε κάνει να χάνεις ισορροπία ή ουδέτερη μέση.',
      );
    }
    if (name.contains('ρουμανικ') &&
        (name.contains('αλτήρ') || name.contains('βαράκ'))) {
      return _homeDumbbells(
        1,
        'Στείλε τους γοφούς πίσω και κράτησε τους αλτήρες κοντά στα πόδια.',
        'Μην κυνηγάς βάθος όταν αρχίζει να στρογγυλεύει η πλάτη.',
      );
    }
    if (name.contains('κωπηλατική') &&
        (name.contains('αλτήρ') || name.contains('βαράκ'))) {
      return _homeDumbbells(
        2,
        'Στηρίξου σε σταθερή καρέκλα και τράβα τον αγκώνα προς το ισχίο.',
        'Μην στρίβεις τον κορμό και μη χρησιμοποιείς ασταθές έπιπλο.',
      );
    }
    if (name.contains('πιέσεις ώμων') &&
        (name.contains('αλτήρ') || name.contains('βαράκ'))) {
      return _homeDumbbells(
        3,
        'Σφίξε ήπια τον κορμό και πίεσε τους αλτήρες ψηλά με έλεγχο.',
        'Μην υπερεκτείνεις τη μέση και μη βιάζεις την επιστροφή.',
      );
    }

    if (name.contains('κάθισμα και σήκωμα') ||
        name.contains('καθίσματα σε καρέκλα') ||
        name.contains('καθίσματα σε πάγκο') ||
        name.contains('chair sit')) {
      return _homeNoEquipment(
        0,
        'Κάθισε απαλά σε σταθερή καρέκλα και σήκω πιέζοντας όλο το πέλμα.',
        'Μην πέφτεις στο κάθισμα και μη χρησιμοποιείς καρέκλα με ροδάκια.',
      );
    }
    if (name.contains('squat') ||
        name.contains('κάθισ') ||
        name.contains('καθίσ')) {
      return _beginnerBodyweight(
        0,
        'Βάλε μια σταθερή καρέκλα πίσω σου, πάτησε όλο το πέλμα και κάθισε με έλεγχο.',
        'Μην κατεβαίνεις βαθύτερα από όσο κρατάς έλεγχο και ισορροπία.',
      );
    }
    if (name.contains('κάμψεις στον τοίχο') || name.contains('wall push')) {
      return _homeNoEquipment(
        1,
        'Κράτησε το σώμα σε μία γραμμή και πλησίασε αργά το στήθος στον τοίχο.',
        'Μην αφήνεις τη μέση να κρεμάσει και μη βιάζεις την επιστροφή.',
      );
    }
    if (name.contains('ανάστροφες προβολές') ||
        name.contains('bulgarian') ||
        name.contains('reverse lunge')) {
      return _beginnerBodyweight(
        2,
        'Κράτησε ελαφρά μια σταθερή καρέκλα και κάνε μικρό ελεγχόμενο βήμα πίσω.',
        'Μην πιέζεις σε βάθος που σε κάνει να χάνεις ισορροπία.',
      );
    }
    if (name.contains('γέφυρα') || name.contains('hip thrust')) {
      return _homeNoEquipment(
        3,
        'Πίεσε τα πέλματα στο πάτωμα και σήκωσε τους γοφούς μέχρι ουδέτερη θέση.',
        'Μην υπερεκτείνεις τη μέση και μη σπρώχνεις από τον αυχένα.',
      );
    }

    if (name.contains('hip hinge') ||
        name.contains('good morning') ||
        name.contains('ρουμανικ')) {
      return _homeNoEquipmentB(
        0,
        'Με μαλακά γόνατα, στείλε τους γοφούς πίσω και κράτησε τη μέση ουδέτερη.',
        'Μην μετατρέπεις την κίνηση σε βαθύ κάθισμα και μη στρογγυλεύεις την πλάτη.',
      );
    }
    if (name.contains('κάμψεις σε σταθερό τραπέζι') ||
        name.contains('κάμψεις σε υπερυψωμένη') ||
        name.contains('incline push') ||
        name.contains('pike') ||
        name.contains('κάμψεις')) {
      return _beginnerBodyweight(
        1,
        'Χρησιμοποίησε σταθερό τραπέζι, κράτησε το σώμα ίσιο και κατέβα αργά.',
        'Μη χρησιμοποιείς τραπεζάκι που μπορεί να μετακινηθεί ή να ανατραπεί.',
      );
    }
    if (name.contains('bird dog')) {
      return _homeNoEquipmentB(
        2,
        'Τέντωσε αντίθετο χέρι και πόδι χωρίς να στρίβει η λεκάνη.',
        'Μην σηκώνεις το πόδι ψηλότερα από όσο κρατάς ουδέτερη μέση.',
      );
    }
    if (name.contains('dead bug') ||
        name.contains('hollow') ||
        name.contains('core')) {
      return _beginnerBodyweight(
        3,
        'Κράτησε τη μέση ελεγχόμενη και άνοιξε αργά αντίθετο χέρι και πόδι.',
        'Μίκρυνε αμέσως το εύρος αν η μέση αρχίζει να σηκώνεται.',
      );
    }

    // At home, hiding an unmatched guide is safer than showing a gym photo
    // that may also imply equipment the user does not own.
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

  static ExerciseGuide _homeNoEquipment(
    int index,
    String execution,
    String avoid,
  ) => _guide(
    'home-no-equipment-guide-v1.jpg',
    index,
    4,
    execution,
    avoid,
    equipmentLabel: 'ΣΠΙΤΙ • ΧΩΡΙΣ ΕΞΟΠΛΙΣΜΟ',
  );

  static ExerciseGuide _homeNoEquipmentB(
    int index,
    String execution,
    String avoid,
  ) => _guide(
    'home-no-equipment-guide-b-v1.jpg',
    index,
    4,
    execution,
    avoid,
    equipmentLabel: 'ΣΠΙΤΙ • ΧΩΡΙΣ ΕΞΟΠΛΙΣΜΟ',
  );

  static ExerciseGuide _homeDumbbells(
    int index,
    String execution,
    String avoid,
  ) => _guide(
    'home-dumbbells-guide-v1.jpg',
    index,
    4,
    execution,
    avoid,
    equipmentLabel: 'ΣΠΙΤΙ • ΑΛΤΗΡΕΣ',
  );

  static ExerciseGuide _beginnerBodyweight(
    int index,
    String execution,
    String avoid,
  ) => _guide(
    'home-beginner-bodyweight-library-v1.png',
    index,
    4,
    execution,
    avoid,
    equipmentLabel: switch (index) {
      0 || 2 => 'ΣΠΙΤΙ • ΣΤΑΘΕΡΗ ΚΑΡΕΚΛΑ',
      1 => 'ΣΠΙΤΙ • ΣΤΑΘΕΡΟ ΤΡΑΠΕΖΙ',
      _ => 'ΣΠΙΤΙ • ΧΩΡΙΣ ΕΞΟΠΛΙΣΜΟ',
    },
    stageCount: 3,
  );

  static ExerciseGuide _homeCardio(int index, String execution, String avoid) =>
      _guide(
        'home-cardio-guide-v1.jpg',
        index,
        4,
        execution,
        avoid,
        equipmentLabel: index == 0
            ? 'ΣΠΙΤΙ • ΑΠΛΟΣ ΔΙΑΔΡΟΜΟΣ'
            : 'ΣΠΙΤΙ • ΧΩΡΙΣ ΕΞΟΠΛΙΣΜΟ',
      );

  static ExerciseGuide _homeBands(int index, String execution, String avoid) =>
      _guide(
        'home-bands-guide-v1.jpg',
        index,
        4,
        execution,
        avoid,
        equipmentLabel: 'ΣΠΙΤΙ • ΛΑΣΤΙΧΟ',
      );

  static ExerciseGuide _homePullUp(String execution, String avoid) => _guide(
    'home-pullup-guide-v1.png',
    0,
    1,
    execution,
    avoid,
    equipmentLabel: 'ΣΠΙΤΙ • ΜΟΝΟΖΥΓΟ • ΧΩΡΙΣ ΛΑΣΤΙΧΟ',
  );

  static ExerciseGuide _outdoorWalking(String execution, String avoid) =>
      _guide(
        'outdoor-walking-guide-v1.png',
        0,
        1,
        execution,
        avoid,
        equipmentLabel: 'ΕΞΩ • ΧΩΡΙΣ ΕΞΟΠΛΙΣΜΟ',
        stageCount: 3,
      );

  static ExerciseGuide _homeRestartBasics(
    int index,
    String execution,
    String avoid,
  ) => _guide(
    'home-restart-basics-v1.png',
    index,
    4,
    execution,
    avoid,
    equipmentLabel: index == 0
        ? 'ΣΠΙΤΙ • ΣΤΑΘΕΡΗ ΚΑΡΕΚΛΑ'
        : 'ΣΠΙΤΙ • ΧΩΡΙΣ ΕΞΟΠΛΙΣΜΟ',
    stageCount: 3,
  );

  static ExerciseGuide _guide(
    String filename,
    int bandIndex,
    int bandCount,
    String execution,
    String avoid, {
    String equipmentLabel = '',
    int stageCount = 2,
  }) => ExerciseGuide(
    assetPath: 'assets/exercise_guides/$filename',
    bandIndex: bandIndex,
    bandCount: bandCount,
    execution: execution,
    avoid: avoid,
    equipmentLabel: equipmentLabel,
    stageCount: stageCount,
  );
}

class ExerciseGuidePreview extends StatelessWidget {
  const ExerciseGuidePreview({
    super.key,
    required this.guide,
    required this.semanticLabel,
    this.width = double.infinity,
    this.height = 160,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
  });

  final ExerciseGuide guide;
  final String semanticLabel;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final alignment = guide.bandCount == 1
        ? 0.0
        : -1 + (2 * guide.bandIndex / (guide.bandCount - 1));
    return Semantics(
      image: true,
      label: semanticLabel,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Image.asset(
          guide.assetPath,
          width: width,
          height: height,
          fit: BoxFit.cover,
          alignment: Alignment(0, alignment),
          filterQuality: FilterQuality.medium,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}

Future<void> showExerciseGuide(
  BuildContext context,
  String exercise,
  ExerciseGuide guide,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) {
    final l = context.l10n;
    final equipmentLabel = guide.localizedEquipmentLabel(l);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              PhoenixCopy.exerciseName(context.l10n, exercise),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              l.text(
                'ΑΡΧΙΚΗ ΘΕΣΗ  →  ΤΕΛΙΚΗ ΘΕΣΗ',
                'START POSITION  →  END POSITION',
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: .7,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            if (equipmentLabel.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: .24),
                  ),
                ),
                child: Text(
                  equipmentLabel,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: .45,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _GuideBand(guide: guide),
            ),
            const SizedBox(height: 18),
            Text(
              l.text('3 απλά βήματα', '3 simple steps'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            _GuideStep(
              number: 1,
              detail: l.text(
                'Στήσου σταθερά και βεβαιώσου ότι έχεις αρκετό χώρο.',
                'Set up in a stable position and make sure you have enough room.',
              ),
            ),
            const SizedBox(height: 8),
            _GuideStep(number: 2, detail: guide.execution),
            const SizedBox(height: 8),
            _GuideStep(
              number: 3,
              detail: l.text(
                'Κινήσου αργά και σταμάτα πριν χάσεις τον έλεγχο.',
                'Move slowly and stop before you lose control.',
              ),
            ),
            const SizedBox(height: 16),
            _GuideCue(
              icon: Icons.check_circle_outline,
              color: const Color(0xFF61D095),
              title: l.text('ΤΙ ΝΑ ΠΡΟΣΕΞΕΙΣ', 'WHAT TO NOTICE'),
              detail: l.text(
                'Η κίνηση πρέπει να παραμένει άνετη και ελεγχόμενη.',
                'The movement should stay comfortable and controlled.',
              ),
            ),
            const SizedBox(height: 12),
            _GuideCue(
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFFF9E80),
              title: l.text('ΣΥΝΗΘΙΣΜΕΝΟ ΛΑΘΟΣ', 'COMMON MISTAKE'),
              detail: guide.avoid,
            ),
            const SizedBox(height: 12),
            _GuideCue(
              icon: Icons.health_and_safety_outlined,
              color: const Color(0xFF8FC5A8),
              title: l.text('ΑΣΦΑΛΕΣΤΕΡΗ ΕΠΙΛΟΓΗ', 'SAFER OPTION'),
              detail: l.text(
                'Μείωσε το βάρος ή το εύρος της κίνησης. Αν δεν νιώθεις ασφάλεια, διάλεξε ευκολότερη εκδοχή ή σταμάτα.',
                'Reduce the weight or range of motion. If you do not feel safe, choose an easier version or stop.',
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l.text(
                'Η εικόνα είναι οδηγός τεχνικής, όχι ιατρική αξιολόγηση. Αν υπάρχει πόνος, σταμάτα την άσκηση.',
                'The image is a technique guide, not a medical assessment. Stop the exercise if you feel pain.',
              ),
              style: TextStyle(
                color: Colors.white.withValues(alpha: .45),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  },
);

class _GuideStep extends StatelessWidget {
  const _GuideStep({required this.number, required this.detail});

  final int number;
  final String detail;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          '$number',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(child: Text(detail, style: const TextStyle(height: 1.4))),
    ],
  );
}

class _GuideBand extends StatelessWidget {
  const _GuideBand({required this.guide});

  final ExerciseGuide guide;

  @override
  Widget build(BuildContext context) {
    final alignment = guide.bandCount == 1
        ? 0.0
        : -1 + (2 * guide.bandIndex / (guide.bandCount - 1));
    return Stack(
      children: [
        ClipRect(
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
        ),
        Positioned(
          left: 10,
          top: 10,
          child: _GuidePositionLabel(label: context.l10n.text('ΑΡΧΗ', 'START')),
        ),
        if (guide.stageCount == 3)
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _GuidePositionLabel(
                  label: context.l10n.text('ΚΙΝΗΣΗ', 'MOVE'),
                ),
              ),
            ),
          ),
        Positioned(
          right: 10,
          top: 10,
          child: _GuidePositionLabel(label: context.l10n.text('ΤΕΛΟΣ', 'END')),
        ),
      ],
    );
  }
}

class _GuidePositionLabel extends StatelessWidget {
  const _GuidePositionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: .64),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: .65,
      ),
    ),
  );
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
