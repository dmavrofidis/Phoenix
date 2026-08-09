import 'package:flutter/material.dart';

import 'safety_adaptation_engine.dart';
import 'secure_clipboard.dart';
import 'state/fitness_store.dart';

class SafetyAdaptationPage extends StatefulWidget {
  const SafetyAdaptationPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<SafetyAdaptationPage> createState() => _SafetyAdaptationPageState();
}

class _SafetyAdaptationPageState extends State<SafetyAdaptationPage> {
  String _area = 'knee';
  int _severity = 0;
  bool _sudden = false;
  bool _swelling = false;
  bool _numbness = false;
  bool _worsening = false;
  bool _toleratesIsometric = true;
  int _painFreeDays = 0;
  String _periodization = 'linear';
  int _weeks = 8;
  String _sport = 'football';
  bool _inSeason = false;
  String _context = 'hotel';
  bool _seated = false;
  bool _lowImpact = true;
  bool _balanceSupport = false;
  bool _fatigueLimited = false;
  String _lifeStage = 'adult';

  SymptomAssessment get _assessment => SafetyAdaptationEngine.assessSymptom(
    area: _area,
    severity: _severity,
    sudden: _sudden,
    swelling: _swelling,
    numbness: _numbness,
    worsening: _worsening,
    toleratesIsometric: _toleratesIsometric,
    painFreeDays: _painFreeDays,
  );

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveAssessment() async {
    final result = _assessment.exportNote(area: _area, severity: _severity);
    await widget.store.recordCapabilityRun(capabilityId: 421, result: result);
    if (mounted) _message('Symptom assessment saved locally.');
  }

  Future<void> _copyAssessment() async {
    final result = _assessment.exportNote(area: _area, severity: _severity);
    await setSecureClipboard(result);
    await widget.store.recordCapabilityRun(capabilityId: 430, result: result);
    if (mounted) _message('Handoff note copied for two minutes.');
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 5,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('SAFETY & ADAPTATION'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'SYMPTOMS', icon: Icon(Icons.health_and_safety_outlined)),
            Tab(text: 'PHASES', icon: Icon(Icons.stacked_line_chart)),
            Tab(text: 'TESTS', icon: Icon(Icons.speed_outlined)),
            Tab(text: 'SPORT', icon: Icon(Icons.sports_soccer_outlined)),
            Tab(
              text: 'ADAPTIVE',
              icon: Icon(Icons.accessible_forward_outlined),
            ),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          _symptomTab(context),
          _phaseTab(context),
          _testsTab(context),
          _sportTab(context),
          _adaptiveTab(context),
        ],
      ),
    ),
  );

  Widget _symptomTab(BuildContext context) {
    final assessment = _assessment;
    final trend = SafetyAdaptationEngine.painTrend(
      widget.store.data,
      area: _area,
    );
    final decisionColor = switch (assessment.decision) {
      TrainingDecision.proceed => Colors.green,
      TrainingDecision.modify => Colors.amber,
      TrainingDecision.recoveryOnly => Colors.orange,
      TrainingDecision.stopAndSeekCare => Theme.of(context).colorScheme.error,
    };
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _SafetyHero(
          icon: Icons.health_and_safety_outlined,
          title: 'SYMPTOM-AWARE TRAINING BOUNDARY',
          detail:
              'This check modifies or stops training. It is not a diagnosis and never overrides professional care.',
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _area,
          decoration: const InputDecoration(labelText: 'Symptom area'),
          items: const ['knee', 'ankle', 'shoulder', 'elbow', 'back', 'other']
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (value) => setState(() => _area = value ?? _area),
        ),
        const SizedBox(height: 8),
        Text('SEVERITY $_severity/10'),
        Slider(
          value: _severity.toDouble(),
          max: 10,
          divisions: 10,
          label: '$_severity',
          onChanged: (value) => setState(() => _severity = value.round()),
        ),
        Wrap(
          spacing: 6,
          children: [
            _FlagChip(
              label: 'SUDDEN',
              selected: _sudden,
              onChanged: (value) => setState(() => _sudden = value),
            ),
            _FlagChip(
              label: 'SWELLING',
              selected: _swelling,
              onChanged: (value) => setState(() => _swelling = value),
            ),
            _FlagChip(
              label: 'NUMBNESS',
              selected: _numbness,
              onChanged: (value) => setState(() => _numbness = value),
            ),
            _FlagChip(
              label: 'WORSENING',
              selected: _worsening,
              onChanged: (value) => setState(() => _worsening = value),
            ),
            _FlagChip(
              label: 'ISOMETRIC OK',
              selected: _toleratesIsometric,
              onChanged: (value) => setState(() => _toleratesIsometric = value),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text('PAIN-FREE DAYS $_painFreeDays'),
        Slider(
          value: _painFreeDays.toDouble(),
          max: 21,
          divisions: 21,
          label: '$_painFreeDays',
          onChanged: (value) => setState(() => _painFreeDays = value.round()),
        ),
        Card(
          color: decisionColor.withValues(alpha: .15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assessment.decision.name.toUpperCase(),
                  style: TextStyle(
                    color: decisionColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Load ${(assessment.loadMultiplier * 100).round()}% · range ${(assessment.rangeMultiplier * 100).round()}% · return stage ${assessment.returnStage}/4',
                ),
                Text(assessment.careReminder),
              ],
            ),
          ),
        ),
        _DetailCard(title: 'ALLOWED', values: assessment.allowedPatterns),
        _DetailCard(title: 'AVOID', values: assessment.blockedPatterns),
        _DetailCard(title: 'FALLBACKS', values: assessment.fallbacks),
        _DetailCard(
          title: 'LOCAL PAIN TREND',
          values: [
            '${trend.values.length} matching session(s) · ${trend.direction}',
            if (trend.recurrenceRisk) 'Recurrence-risk flag is active.',
          ],
        ),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _saveAssessment,
                icon: const Icon(Icons.save_outlined),
                label: const Text('SAVE CHECK'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _copyAssessment,
                icon: const Icon(Icons.copy_outlined),
                label: const Text('COPY HANDOFF'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _phaseTab(BuildContext context) {
    final plan = SafetyAdaptationEngine.periodization(
      style: _periodization,
      weeks: _weeks,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _SafetyHero(
          icon: Icons.stacked_line_chart,
          title: 'PERIODIZATION & TAPER',
          detail:
              'Bounded volume and intensity ramps with explicit pivot, deload and taper logic.',
        ),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'linear', label: Text('LINEAR')),
            ButtonSegment(value: 'undulating', label: Text('UNDULATING')),
            ButtonSegment(value: 'block', label: Text('BLOCK')),
          ],
          selected: {_periodization},
          onSelectionChanged: (value) =>
              setState(() => _periodization = value.single),
        ),
        const SizedBox(height: 12),
        Text('BLOCK LENGTH $_weeks WEEKS'),
        Slider(
          value: _weeks.toDouble(),
          min: 4,
          max: 24,
          divisions: 20,
          label: '$_weeks weeks',
          onChanged: (value) => setState(() => _weeks = value.round()),
        ),
        Text(plan.summary, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        for (final phase in plan.phases)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${phase.weeks}w')),
              title: Text(phase.name.toUpperCase()),
              subtitle: Text(
                '${phase.focus}\nVolume ${(phase.volumeMultiplier * 100).round()}% · intensity ${(phase.intensityMultiplier * 100).round()}%',
              ),
              isThreeLine: true,
            ),
          ),
        _DetailCard(title: 'AUTO-DELOAD CRITERIA', values: plan.deloadCriteria),
      ],
    );
  }

  Widget _testsTab(BuildContext context) {
    final battery = SafetyAdaptationEngine.performanceBattery(
      values: const {
        'push-up': 20,
        'pull-up': 5,
        'squat': 35,
        'plank': 90,
        'broad-jump': 180,
        'vertical-jump': 35,
        'cooper': 2200,
        'step-recovery': 30,
      },
      testedAt: DateTime.now(),
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _SafetyHero(
          icon: Icons.speed_outlined,
          title: 'PERFORMANCE TEST BATTERY',
          detail:
              'Eight field tests, normalized only for personal visualization, with a six-week retest interval.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in battery.radar.entries)
              Chip(
                label: Text('${entry.key.toUpperCase()} ${entry.value}/100'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Lowest measured category: ${battery.lowestCategory}'),
        Text(
          'Next full battery: ${battery.nextTestDate.toIso8601String().split('T').first}',
        ),
        const SizedBox(height: 8),
        for (final result in battery.results)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${result.score}')),
              title: Text(result.name),
              subtitle: Text(
                '${result.value.toStringAsFixed(0)} ${result.unit}\n${result.stopRule}',
              ),
              isThreeLine: true,
            ),
          ),
      ],
    );
  }

  Widget _sportTab(BuildContext context) {
    final profile = SafetyAdaptationEngine.sportProfile(
      _sport,
      inSeason: _inSeason,
      daysToCompetition: 7,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _SafetyHero(
          icon: Icons.sports_soccer_outlined,
          title: 'SPORT DEMAND PROFILE',
          detail:
              'Acceleration, agility, landing, sprint exposure and competition-week load in one bounded profile.',
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _sport,
          decoration: const InputDecoration(labelText: 'Sport'),
          items: const ['football', 'basketball', 'tennis', 'general']
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (value) => setState(() => _sport = value ?? _sport),
        ),
        SwitchListTile(
          value: _inSeason,
          title: const Text('IN-SEASON MAINTENANCE'),
          subtitle: Text(
            'Volume ${(profile.inSeasonVolumeMultiplier * 100).round()}%',
          ),
          onChanged: (value) => setState(() => _inSeason = value),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in profile.demands.entries)
              Chip(label: Text('${entry.key.toUpperCase()} ${entry.value}')),
          ],
        ),
        _DetailCard(title: 'SESSION BUILDERS', values: profile.sessions),
        _DetailCard(title: 'COMPETITION WEEK', values: profile.competitionWeek),
        Text('Sprint exposure ceiling: ${profile.sprintExposureLimit} reps'),
      ],
    );
  }

  Widget _adaptiveTab(BuildContext context) {
    final plan = SafetyAdaptationEngine.adaptivePlan(
      context: _context,
      availableMinutes: 15,
      seatedOnly: _seated,
      lowImpact: _lowImpact,
      balanceSupport: _balanceSupport,
      fatigueLimited: _fatigueLimited,
      lifeStage: _lifeStage,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _SafetyHero(
          icon: Icons.accessible_forward_outlined,
          title: 'TRAVEL, ADAPTIVE & LIFE-STAGE PLAN',
          detail:
              'Constraints remove unsuitable work and add explicit safety boundaries; they never infer medical clearance.',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _context,
                decoration: const InputDecoration(labelText: 'Context'),
                items:
                    const ['hotel', 'no-equipment', 'band', 'outdoor', 'home']
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                onChanged: (value) =>
                    setState(() => _context = value ?? _context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _lifeStage,
                decoration: const InputDecoration(labelText: 'Life stage'),
                items:
                    const [
                          'adult',
                          'teen',
                          'older-adult',
                          'pregnancy',
                          'postpartum',
                          'menopause',
                        ]
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                onChanged: (value) =>
                    setState(() => _lifeStage = value ?? _lifeStage),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 6,
          children: [
            _FlagChip(
              label: 'SEATED',
              selected: _seated,
              onChanged: (value) => setState(() => _seated = value),
            ),
            _FlagChip(
              label: 'LOW IMPACT',
              selected: _lowImpact,
              onChanged: (value) => setState(() => _lowImpact = value),
            ),
            _FlagChip(
              label: 'BALANCE SUPPORT',
              selected: _balanceSupport,
              onChanged: (value) => setState(() => _balanceSupport = value),
            ),
            _FlagChip(
              label: 'FATIGUE LIMITED',
              selected: _fatigueLimited,
              onChanged: (value) => setState(() => _fatigueLimited = value),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${plan.name.toUpperCase()} · ${plan.minutes} MIN',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        Wrap(
          spacing: 6,
          children: plan.tags.map((item) => Chip(label: Text(item))).toList(),
        ),
        _DetailCard(title: 'SESSION', values: plan.exercises),
        _DetailCard(title: 'SAFETY CHECKLIST', values: plan.safetyChecklist),
        Text(
          'Streak protected: ${plan.streakProtected ? 'yes' : 'no'} · return-home ramp ${plan.returnRampDays} days',
        ),
      ],
    );
  }
}

class _FlagChip extends StatelessWidget {
  const _FlagChip({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) =>
      FilterChip(label: Text(label), selected: selected, onSelected: onChanged);
}

class _SafetyHero extends StatelessWidget {
  const _SafetyHero({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.primaryContainer,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, size: 34),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(detail),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          if (values.isEmpty) const Text('No restriction in this category.'),
          for (final value in values)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $value'),
            ),
        ],
      ),
    ),
  );
}
