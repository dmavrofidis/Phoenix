import 'package:flutter/material.dart';

import 'equipment_quick_choices.dart';
import 'models/fitness_models.dart';
import 'phoenix_l10n.dart';
import 'state/fitness_store.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _equipmentController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _limitationsController = TextEditingController();
  final _scrollController = ScrollController();

  String _goal = 'Μυϊκή ανάπτυξη';
  String _trainingPlace = 'Γυμναστήριο';
  String _experienceLevel = 'Αρχάριος';
  int _daysPerWeek = 3;
  int _sessionMinutes = 45;
  int _step = 0;
  bool _gentleStart = false;
  bool _saving = false;

  @override
  void dispose() {
    _equipmentController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _limitationsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _step = step.clamp(0, 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _nextStep() {
    if (_step == 1 && _equipmentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.text(
                'Διάλεξε τι έχεις διαθέσιμο — ακόμη και «Χωρίς εξοπλισμό».',
                'Choose what you have — even “No equipment”.',
              ),
            ),
          ),
        );
      return;
    }
    _goToStep(_step + 1);
  }

  void _chooseGentleStart() {
    setState(() {
      _gentleStart = true;
      _goal = 'Γενική φυσική κατάσταση';
      _experienceLevel = 'Αρχάριος';
      _daysPerWeek = 2;
      _sessionMinutes = 20;
    });
  }

  void _chooseGoal(String goal) {
    setState(() {
      _gentleStart = false;
      _goal = goal;
    });
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.store.saveProfile(
        UserProfile(
          goal: _goal,
          trainingPlace: _trainingPlace,
          equipment: _equipmentController.text.trim(),
          daysPerWeek: _daysPerWeek,
          heightCentimeters: int.parse(_heightController.text),
          weightKilograms: double.parse(
            _weightController.text.replaceAll(',', '.'),
          ),
          age: _ageController.text.trim().isEmpty
              ? null
              : int.parse(_ageController.text),
          experienceLevel: _experienceLevel,
          sessionMinutes: _sessionMinutes,
          limitations: _limitationsController.text.trim(),
        ),
      );
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _requiredNumber(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Συμπλήρωσε $label.';
    if (double.tryParse(value.replaceAll(',', '.')) == null) {
      return 'Γράψε έναν έγκυρο αριθμό.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    String goalLabel(String value) => switch (value) {
      'Μυϊκή ανάπτυξη' => l.text(value, 'Muscle gain'),
      'Δύναμη' => l.text(value, 'Strength'),
      'Απώλεια λίπους' => l.text(value, 'Fat loss'),
      _ => l.text(value, 'General fitness'),
    };
    String experienceLabel(String value) => switch (value) {
      'Αρχάριος' => l.text(value, 'Beginner'),
      'Μέτριος' => l.text(value, 'Intermediate'),
      _ => l.text(value, 'Advanced'),
    };
    final titles = [
      l.text('Τι θέλεις να αλλάξεις πρώτα;', 'What would you like to change?'),
      l.text('Με τι μπορείς να ξεκινήσεις;', 'What can you start with?'),
      l.text('Τι χωράει στη ζωή σου;', 'What fits into your life?'),
    ];
    final subtitles = [
      l.text(
        'Δεν υπάρχει λάθος απάντηση. Θα ξεκινήσουμε απλά και με ασφάλεια.',
        'There is no wrong answer. We will start simply and safely.',
      ),
      l.text(
        'Ακόμη και λίγος χώρος ή ένα ζευγάρι βαράκια είναι αρκετά.',
        'A little space or one pair of dumbbells is enough.',
      ),
      l.text(
        'Διάλεξε κάτι ρεαλιστικό. Μπορείς να το αλλάξεις οποιαδήποτε στιγμή.',
        'Choose something realistic. You can change it at any time.',
      ),
    ];
    final primaryAction = _step < 2
        ? FilledButton.icon(
            onPressed: _nextStep,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                l.text('Συνέχεια', 'Continue'),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          )
        : FilledButton.icon(
            onPressed: _saving ? null : _continue,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.favorite_rounded),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                l.text(
                  'Φτιάξε το πρώτο μου πρόγραμμα',
                  'Create my first program',
                ),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          );
    return Scaffold(
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          child: Row(
            children: [
              if (_step > 0) ...[
                IconButton.outlined(
                  onPressed: () => _goToStep(_step - 1),
                  tooltip: l.text('Πίσω', 'Back'),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(child: primaryAction),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                key: const ValueKey('onboarding-scroll'),
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.local_fire_department,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'PHOENIX',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.5,
                            ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => widget.store.updatePreferences(
                          languageCode: widget.store.isEnglish ? 'el' : 'en',
                        ),
                        icon: const Icon(Icons.language),
                        label: Text(widget.store.isEnglish ? 'ΕΛ' : 'EN'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .22),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l.text(
                              'ΝΕΑ ΑΠΛΗ ΕΜΠΕΙΡΙΑ • ΒΗΜΑ ${_step + 1} ΑΠΟ 3',
                              'NEW SIMPLE EXPERIENCE • STEP ${_step + 1} OF 3',
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: .4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      for (var index = 0; index < 3; index++) ...[
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            height: 6,
                            decoration: BoxDecoration(
                              color: index <= _step
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        if (index < 2) const SizedBox(width: 7),
                      ],
                    ],
                  ),
                  const SizedBox(height: 28),
                  if (_step == 0) ...[
                    const _WelcomeIllustration(),
                    const SizedBox(height: 22),
                  ],
                  Text(
                    _step == 0
                        ? l.text(
                            'Δεν χρειάζεται να τα έχεις όλα ξεκαθαρίσει.',
                            'You do not need to have everything figured out.',
                          )
                        : titles[_step],
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.06,
                    ),
                  ),
                  if (_step == 0) ...[
                    const SizedBox(height: 10),
                    Text(
                      l.text(
                        'Είμαι εδώ. Θα βρούμε μαζί το πρώτο μικρό βήμα.',
                        'I am here. We will find your first small step together.',
                      ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    subtitles[_step],
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .64),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_step == 0) ...[
                    _GuidedStartChoice(
                      selected: _gentleStart,
                      onTap: _chooseGentleStart,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.white.withValues(alpha: .12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            l.text('Ή διάλεξε έναν στόχο', 'Or choose a goal'),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .46),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.white.withValues(alpha: .12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _GoalChoice(
                      icon: Icons.fitness_center_rounded,
                      title: goalLabel('Μυϊκή ανάπτυξη'),
                      subtitle: l.text(
                        'Να δυναμώσω και να χτίσω το σώμα μου',
                        'Get stronger and build my body',
                      ),
                      selected: !_gentleStart && _goal == 'Μυϊκή ανάπτυξη',
                      onTap: () => _chooseGoal('Μυϊκή ανάπτυξη'),
                    ),
                    const SizedBox(height: 10),
                    _GoalChoice(
                      icon: Icons.bolt_rounded,
                      title: goalLabel('Δύναμη'),
                      subtitle: l.text(
                        'Να σηκώνω περισσότερο με σωστή τεχνική',
                        'Lift more with good technique',
                      ),
                      selected: !_gentleStart && _goal == 'Δύναμη',
                      onTap: () => _chooseGoal('Δύναμη'),
                    ),
                    const SizedBox(height: 10),
                    _GoalChoice(
                      icon: Icons.favorite_outline_rounded,
                      title: goalLabel('Απώλεια λίπους'),
                      subtitle: l.text(
                        'Να κινηθώ περισσότερο και να νιώθω καλύτερα',
                        'Move more and feel better',
                      ),
                      selected: !_gentleStart && _goal == 'Απώλεια λίπους',
                      onTap: () => _chooseGoal('Απώλεια λίπους'),
                    ),
                    const SizedBox(height: 10),
                    _GoalChoice(
                      icon: Icons.directions_walk_rounded,
                      title: goalLabel('Γενική φυσική κατάσταση'),
                      subtitle: l.text(
                        'Να κάνω μια καλή αρχή για την υγεία μου',
                        'Make a good start for my health',
                      ),
                      selected:
                          !_gentleStart && _goal == 'Γενική φυσική κατάσταση',
                      onTap: () => _chooseGoal('Γενική φυσική κατάσταση'),
                    ),
                  ],
                  if (_step == 1) ...[
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel(
                            icon: Icons.home_outlined,
                            label: l.text(
                              'Πού θέλεις να γυμνάζεσαι;',
                              'Where do you want to train?',
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<String>(
                              segments: [
                                ButtonSegment(
                                  value: 'Σπίτι',
                                  label: Text(l.text('Σπίτι', 'Home')),
                                  icon: const Icon(Icons.home_outlined),
                                ),
                                ButtonSegment(
                                  value: 'Γυμναστήριο',
                                  label: Text(l.text('Γυμναστήριο', 'Gym')),
                                  icon: const Icon(Icons.fitness_center),
                                ),
                              ],
                              selected: {_trainingPlace},
                              onSelectionChanged: (value) =>
                                  setState(() => _trainingPlace = value.first),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel(
                            icon: Icons.sports_gymnastics,
                            label: l.text(
                              'Τι έχεις διαθέσιμο;',
                              'What equipment do you have?',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l.text(
                              'Μπορείς να διαλέξεις περισσότερα από ένα.',
                              'You can choose more than one.',
                            ),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .5),
                            ),
                          ),
                          const SizedBox(height: 12),
                          EquipmentQuickChoices(
                            controller: _equipmentController,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const ValueKey('equipment-input'),
                            controller: _equipmentController,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: l.text(
                                'Κάτι άλλο; Γράψε το εδώ (προαιρετικά)',
                                'Anything else? Add it here (optional)',
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_step == 2) ...[
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel(
                            icon: Icons.calendar_month_outlined,
                            label: l.text(
                              'Πόσες ημέρες είναι ρεαλιστικές;',
                              'How many days are realistic?',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final days in const [1, 2, 3, 4, 5])
                                ChoiceChip(
                                  label: Text(
                                    l.text(
                                      '$days ${days == 1 ? 'ημέρα' : 'ημέρες'}',
                                      '$days ${days == 1 ? 'day' : 'days'}',
                                    ),
                                  ),
                                  selected: _daysPerWeek == days,
                                  onSelected: (_) =>
                                      setState(() => _daysPerWeek = days),
                                ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          _SectionLabel(
                            icon: Icons.timer_outlined,
                            label: l.text(
                              'Πόσο χρόνο έχεις συνήθως;',
                              'How much time do you usually have?',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final minutes in const [20, 30, 45, 60])
                                ChoiceChip(
                                  label: Text(
                                    l.text(
                                      '$minutes λεπτά',
                                      '$minutes minutes',
                                    ),
                                  ),
                                  selected: _sessionMinutes == minutes,
                                  onSelected: (_) =>
                                      setState(() => _sessionMinutes = minutes),
                                ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          _SectionLabel(
                            icon: Icons.trending_up,
                            label: l.text(
                              'Πόση εμπειρία έχεις;',
                              'How much experience do you have?',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final level in const [
                                'Αρχάριος',
                                'Μέτριος',
                                'Προχωρημένος',
                              ])
                                ChoiceChip(
                                  label: Text(experienceLabel(level)),
                                  selected: _experienceLevel == level,
                                  onSelected: (_) =>
                                      setState(() => _experienceLevel = level),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PlanPreviewCard(
                      gentleStart: _gentleStart,
                      daysPerWeek: _daysPerWeek,
                      sessionMinutes: _sessionMinutes,
                      experienceLabel: experienceLabel(_experienceLevel),
                      equipment: _equipmentController.text,
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel(
                            icon: Icons.person_outline,
                            label: l.text(
                              'Δύο βασικές πληροφορίες',
                              'Two basic details',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l.text(
                              'Μας βοηθούν να κρατήσουμε το πλάνο ασφαλές και ρεαλιστικό.',
                              'They help keep your plan safe and realistic.',
                            ),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .5),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  key: const ValueKey('height-input'),
                                  controller: _heightController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: l.text('Ύψος', 'Height'),
                                    suffixText: 'cm',
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (value) =>
                                      _requiredNumber(value, 'το ύψος'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  key: const ValueKey('weight-input'),
                                  controller: _weightController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: InputDecoration(
                                    labelText: l.text('Βάρος', 'Weight'),
                                    suffixText: 'kg',
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (value) =>
                                      _requiredNumber(value, 'το βάρος'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            childrenPadding: const EdgeInsets.only(bottom: 8),
                            title: Text(
                              l.text(
                                'Προαιρετικές πληροφορίες',
                                'Optional details',
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(
                              l.text(
                                'Ηλικία ή κάποια ενόχληση',
                                'Age or any discomfort',
                              ),
                            ),
                            children: [
                              TextFormField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: l.text(
                                    'Ηλικία (προαιρετικά)',
                                    'Age (optional)',
                                  ),
                                  suffixText: l.text('έτη', 'years'),
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return null;
                                  }
                                  return int.tryParse(value) == null
                                      ? l.text(
                                          'Γράψε μια έγκυρη ηλικία.',
                                          'Enter a valid age.',
                                        )
                                      : null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _limitationsController,
                                minLines: 2,
                                maxLines: 3,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  labelText: l.text(
                                    'Περιορισμοί ή ενοχλήσεις',
                                    'Limitations or pain',
                                  ),
                                  hintText: l.text(
                                    'π.χ. ενόχληση στο γόνατο',
                                    'e.g. knee discomfort',
                                  ),
                                  alignLabelWithHint: true,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: .45),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lock_outline, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l.text(
                                'Όλα τα δεδομένα αποθηκεύονται μόνο στη συσκευή σου.',
                                'All data stays only on your device.',
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    l.text(
                      'Δεν χρειάζεται να είσαι έτοιμος για όλα. Αρκεί να ξεκινήσεις.',
                      'You do not have to be ready for everything. You only have to start.',
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: .5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('gentle-start-illustration'),
      height: 178,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colors.primary.withValues(alpha: .22)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: .09),
            blurRadius: 32,
            spreadRadius: -10,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/illustrations/phoenix-gentle-start-v1.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(0, .12),
            semanticLabel: context.l10n.text(
              'Ένας καθημερινός άνθρωπος ετοιμάζεται να ξεκινήσει στο σπίτι',
              'An everyday person getting ready to start at home',
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC090D0F)],
                stops: [.42, 1],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Text(
              context.l10n.text(
                'Όχι τέλεια. Απλώς μια αρχή.',
                'Not perfect. Just a beginning.',
              ),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidedStartChoice extends StatelessWidget {
  const _GuidedStartChoice({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: selected ? .22 : .14),
            colors.primary.withValues(alpha: selected ? .08 : .035),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.primary.withValues(alpha: selected ? .9 : .42),
          width: selected ? 1.7 : 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          key: const ValueKey('guided-start-choice'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.text(
                          'Δεν ξέρω — βοήθησέ με να ξεκινήσω',
                          'I am not sure — help me get started',
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.text(
                          'Θα σου δώσω ένα ήπιο πλάνο 20 λεπτών, 2 φορές την εβδομάδα. Τίποτα δεν είναι μόνιμο.',
                          'I will give you a gentle 20-minute plan, twice a week. Nothing is permanent.',
                        ),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .64),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.arrow_forward_rounded,
                  color: colors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanPreviewCard extends StatelessWidget {
  const _PlanPreviewCard({
    required this.gentleStart,
    required this.daysPerWeek,
    required this.sessionMinutes,
    required this.experienceLabel,
    required this.equipment,
  });

  final bool gentleStart;
  final int daysPerWeek;
  final int sessionMinutes;
  final String experienceLabel;
  final String equipment;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('starter-plan-preview'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: .15),
            colors.surfaceContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.primary.withValues(alpha: .28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.favorite_rounded, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.text(
                        gentleStart
                            ? 'Το ήπιο ξεκίνημά σου'
                            : 'Το πρώτο σου πλάνο',
                        gentleStart ? 'Your gentle start' : 'Your first plan',
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.text(
                        'Είναι σχεδόν έτοιμο.',
                        'It is almost ready.',
                      ),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .56),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PreviewPill(
                icon: Icons.calendar_today_outlined,
                label: context.l10n.text(
                  '$daysPerWeek ${daysPerWeek == 1 ? 'ημέρα' : 'ημέρες'}',
                  '$daysPerWeek ${daysPerWeek == 1 ? 'day' : 'days'}',
                ),
              ),
              _PreviewPill(
                icon: Icons.timer_outlined,
                label: context.l10n.text(
                  '$sessionMinutes λεπτά',
                  '$sessionMinutes minutes',
                ),
              ),
              _PreviewPill(
                icon: Icons.trending_up_rounded,
                label: experienceLabel,
              ),
            ],
          ),
          const SizedBox(height: 15),
          _PreviewLine(
            icon: Icons.photo_outlined,
            text: context.l10n.text(
              '4 απλές ασκήσεις με εικόνες και καθαρές οδηγίες',
              '4 simple exercises with images and clear instructions',
            ),
          ),
          const SizedBox(height: 9),
          _PreviewLine(
            icon: Icons.home_outlined,
            text: context.l10n.text(
              'Με ό,τι έχεις: $equipment',
              'Using what you have: $equipment',
            ),
          ),
          const SizedBox(height: 9),
          _PreviewLine(
            icon: Icons.tune_rounded,
            text: context.l10n.text(
              'Μπορείς να αλλάξεις τα πάντα οποιαδήποτε στιγμή',
              'You can change everything at any time',
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewPill extends StatelessWidget {
  const _PreviewPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _PreviewLine extends StatelessWidget {
  const _PreviewLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .7),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalChoice extends StatelessWidget {
  const _GoalChoice({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? colors.primary.withValues(alpha: .12)
          : colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: colors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .55),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selected ? colors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? colors.primary : colors.outline,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 16, color: Colors.black)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(padding: const EdgeInsets.all(17), child: child),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
