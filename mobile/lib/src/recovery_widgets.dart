import 'package:flutter/material.dart';

import 'models/fitness_models.dart';
import 'phoenix_l10n.dart';
import 'recovery_engine.dart';
import 'state/fitness_store.dart';

class RecoveryCheckInCard extends StatelessWidget {
  const RecoveryCheckInCard({super.key, required this.store});

  final FitnessStore store;

  String _modeLabel(PhoenixL10n l, RecoveryMode mode) => switch (mode) {
    RecoveryMode.ready => l.text('ΠΛΗΡΗΣ ΕΝΤΑΣΗ', 'FULL INTENSITY'),
    RecoveryMode.controlled => l.text(
      'ΕΛΕΓΧΟΜΕΝΗ ΕΝΤΑΣΗ',
      'CONTROLLED INTENSITY',
    ),
    RecoveryMode.recovery => l.text(
      'ΠΡΟΤΕΡΑΙΟΤΗΤΑ ΣΤΗΝ ΑΠΟΚΑΤΑΣΤΑΣΗ',
      'RECOVERY FIRST',
    ),
  };

  Future<void> _openCheckIn(BuildContext context) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _RecoveryCheckInSheet(store: store),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Το σημερινό πλάνο προσαρμόστηκε στην αποκατάστασή σου.',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final checkIn = store.todaysRecoveryCheckIn;
    final plan = store.todaysRecoveryPlan;
    final color = switch (plan?.mode) {
      RecoveryMode.ready => const Color(0xFF66BB6A),
      RecoveryMode.controlled => const Color(0xFFFFB74D),
      RecoveryMode.recovery => const Color(0xFFEF5350),
      null => colors.primary,
    };

    return InkWell(
      onTap: () => _openCheckIn(context),
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          border: Border.all(color: color.withValues(alpha: .2)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .14),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: plan == null
                  ? Icon(Icons.battery_5_bar, color: color)
                  : Text(
                      '${plan.score}',
                      style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan == null
                        ? l.text('ΕΛΕΓΧΟΣ ΕΤΟΙΜΟΤΗΤΑΣ', 'READINESS CHECK-IN')
                        : _modeLabel(l, plan.mode),
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    plan == null
                        ? l.text(
                            'Πώς νιώθει πραγματικά το σώμα σου;',
                            'How does your body really feel?',
                          )
                        : l.isEnglish
                        ? switch (plan.mode) {
                            RecoveryMode.ready => 'Ready for full intensity',
                            RecoveryMode.controlled =>
                              'Controlled intensity today',
                            RecoveryMode.recovery => 'Recovery takes priority',
                          }
                        : plan.headline,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    checkIn == null
                        ? l.text(
                            'Χρειάζονται μόνο 30 δευτερόλεπτα για να προσαρμοστούν η ένταση και το φορτίο.',
                            'It takes only 30 seconds to adjust intensity and load.',
                          )
                        : l.text(
                            '${checkIn.sleepHours.toStringAsFixed(1).replaceAll('.', ',')} ώρες ύπνου • '
                                'ενέργεια ${checkIn.energy}/5 • '
                                'μυϊκή κόπωση ${checkIn.soreness}/5',
                            '${checkIn.sleepHours.toStringAsFixed(1)} h sleep • '
                                'energy ${checkIn.energy}/5 • '
                                'fatigue ${checkIn.soreness}/5',
                          ),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}

class RecoverySessionBanner extends StatelessWidget {
  const RecoverySessionBanner({super.key, required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final plan = store.todaysRecoveryPlan;
    if (plan == null) return const SizedBox.shrink();
    final color = switch (plan.mode) {
      RecoveryMode.ready => const Color(0xFF66BB6A),
      RecoveryMode.controlled => const Color(0xFFFFB74D),
      RecoveryMode.recovery => const Color(0xFFEF5350),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        border: Border.all(color: color.withValues(alpha: .3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(plan.adjustsWorkout ? Icons.tune : Icons.verified, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.adjustsWorkout
                      ? 'ΑΥΤΟΜΑΤΗ ΠΡΟΣΑΡΜΟΓΗ • ${plan.score}/100'
                      : 'ΠΛΗΡΕΣ ΠΛΑΝΟ • ${plan.score}/100',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  plan.detail,
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

class RecoveryTrendCard extends StatelessWidget {
  const RecoveryTrendCard({super.key, required this.checkIns});

  final List<RecoveryCheckIn> checkIns;

  static const _dayLabels = ['Δ', 'Τ', 'Τ', 'Π', 'Π', 'Σ', 'Κ'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = [
      for (var offset = 6; offset >= 0; offset--)
        today.subtract(Duration(days: offset)),
    ];
    final scores = <int?>[];
    for (final day in days) {
      RecoveryCheckIn? match;
      for (final checkIn in checkIns) {
        if (checkIn.recordedAt.year == day.year &&
            checkIn.recordedAt.month == day.month &&
            checkIn.recordedAt.day == day.day) {
          match = checkIn;
          break;
        }
      }
      scores.add(match == null ? null : RecoveryEngine.evaluate(match).score);
    }
    final availableScores = scores.whereType<int>().toList();
    final average = availableScores.isEmpty
        ? null
        : availableScores.reduce((left, right) => left + right) /
              availableScores.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.battery_charging_full,
                  color: Color(0xFFFF6E40),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ΑΠΟΚΑΤΑΣΤΑΣΗ 7 ΗΜΕΡΩΝ',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: .7,
                        ),
                      ),
                      Text(
                        'Ύπνος, ενέργεια, κόπωση και στρες',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  average == null ? '—' : average.round().toString(),
                  style: const TextStyle(
                    color: Color(0xFFFF9E80),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 118,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var index = 0; index < days.length; index++) ...[
                    if (index > 0) const SizedBox(width: 8),
                    Expanded(
                      child: _RecoveryDayBar(
                        dayLabel: _dayLabels[days[index].weekday - 1],
                        dayNumber: days[index].day,
                        score: scores[index],
                        isToday: index == days.length - 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (availableScores.isEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Κάνε έναν σύντομο καθημερινό έλεγχο για να δεις την πορεία της αποκατάστασής σου.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .5),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecoveryDayBar extends StatelessWidget {
  const _RecoveryDayBar({
    required this.dayLabel,
    required this.dayNumber,
    required this.score,
    required this.isToday,
  });

  final String dayLabel;
  final int dayNumber;
  final int? score;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final value = score ?? 0;
    final color = value >= 76
        ? const Color(0xFF66BB6A)
        : value >= 55
        ? const Color(0xFFFFB74D)
        : score == null
        ? Colors.white12
        : const Color(0xFFEF5350);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          score?.toString() ?? '·',
          style: TextStyle(
            color: score == null ? Colors.white24 : color,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: score == null ? .08 : (value / 100).clamp(.12, 1),
              widthFactor: .72,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: score == null
                      ? null
                      : [
                          BoxShadow(
                            color: color.withValues(alpha: .2),
                            blurRadius: 8,
                          ),
                        ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$dayLabel\n$dayNumber',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isToday ? const Color(0xFFFFAB91) : Colors.white38,
            fontSize: 9,
            fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RecoveryCheckInSheet extends StatefulWidget {
  const _RecoveryCheckInSheet({required this.store});

  final FitnessStore store;

  @override
  State<_RecoveryCheckInSheet> createState() => _RecoveryCheckInSheetState();
}

class _RecoveryCheckInSheetState extends State<_RecoveryCheckInSheet> {
  late double _sleepHours;
  late int _energy;
  late int _soreness;
  late int _stress;
  late final Map<String, int> _sorenessAreas;
  late final TextEditingController _steps;
  late final TextEditingController _restingHeartRate;
  bool _saving = false;

  static const _areas = ['Ώμοι', 'Στήθος', 'Πλάτη', 'Μέση', 'Ισχία', 'Πόδια'];

  @override
  void initState() {
    super.initState();
    final existing = widget.store.todaysRecoveryCheckIn;
    _sleepHours = existing?.sleepHours ?? 7.5;
    _energy = existing?.energy ?? 3;
    _soreness = existing?.soreness ?? 2;
    _stress = existing?.stress ?? 2;
    _sorenessAreas = {
      for (final area in _areas) area: existing?.sorenessAreas[area] ?? 0,
    };
    _steps = TextEditingController(
      text: existing?.steps == 0 ? '' : '${existing?.steps ?? ''}',
    );
    _restingHeartRate = TextEditingController(
      text: existing?.restingHeartRate == 0
          ? ''
          : '${existing?.restingHeartRate ?? ''}',
    );
  }

  @override
  void dispose() {
    _steps.dispose();
    _restingHeartRate.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.store.saveRecoveryCheckIn(
        sleepHours: _sleepHours,
        energy: _energy,
        soreness: _soreness,
        stress: _stress,
        sorenessAreas: _sorenessAreas,
        steps: int.tryParse(_steps.text) ?? 0,
        restingHeartRate: int.tryParse(_restingHeartRate.text) ?? 0,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on FormatException catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Σύντομος έλεγχος ετοιμότητας',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Δεν αποτελεί ιατρική αξιολόγηση. Αν νιώθεις πόνο ή αδιαθεσία, '
                'σταμάτησε και ζήτησε συμβουλή από επαγγελματία υγείας.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Ύπνος',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Text(
                    '${_sleepHours.toStringAsFixed(1).replaceAll('.', ',')} ώρες',
                    style: const TextStyle(
                      color: Color(0xFFFF9E80),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _sleepHours,
                min: 3,
                max: 11,
                divisions: 16,
                label: _sleepHours.toStringAsFixed(1),
                onChanged: (value) => setState(() => _sleepHours = value),
              ),
              _RatingSelector(
                title: 'Ενέργεια',
                lowLabel: 'Πολύ χαμηλή',
                highLabel: 'Πολύ υψηλή',
                value: _energy,
                onChanged: (value) => setState(() => _energy = value),
              ),
              _RatingSelector(
                title: 'Μυϊκή κόπωση',
                lowLabel: 'Καθόλου',
                highLabel: 'Έντονη',
                value: _soreness,
                onChanged: (value) => setState(() => _soreness = value),
              ),
              _RatingSelector(
                title: 'Στρες',
                lowLabel: 'Καθόλου',
                highLabel: 'Πολύ',
                value: _stress,
                onChanged: (value) => setState(() => _stress = value),
              ),
              const SizedBox(height: 12),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text(
                  'ΧΑΡΤΗΣ ΣΩΜΑΤΟΣ ΚΑΙ ΒΑΣΙΚΕΣ ΜΕΤΡΗΣΕΙΣ',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
                subtitle: const Text(
                  'Τοπική κόπωση, βήματα και παλμοί ηρεμίας',
                ),
                children: [
                  for (final area in _areas)
                    Row(
                      children: [
                        SizedBox(
                          width: 62,
                          child: Text(
                            area,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: _sorenessAreas[area]!.toDouble(),
                            min: 0,
                            max: 5,
                            divisions: 5,
                            label: '${_sorenessAreas[area]}',
                            onChanged: (value) => setState(
                              () => _sorenessAreas[area] = value.round(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                          child: Text('${_sorenessAreas[area]}'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _steps,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Βήματα',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _restingHeartRate,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Παλμοί ηρεμίας',
                            suffixText: 'σφύξεις/λεπτό',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.bolt),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: Text(
                      _saving
                          ? 'Αποθήκευση…'
                          : 'Προσαρμογή του σημερινού πλάνου',
                    ),
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

class _RatingSelector extends StatelessWidget {
  const _RatingSelector({
    required this.title,
    required this.lowLabel,
    required this.highLabel,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String lowLabel;
  final String highLabel;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(lowLabel, style: const TextStyle(color: Colors.white38)),
              const Spacer(),
              Text(highLabel, style: const TextStyle(color: Colors.white38)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var rating = 1; rating <= 5; rating++) ...[
                if (rating > 1) const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: SizedBox(
                      width: double.infinity,
                      child: Text(
                        '$rating',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    selected: value == rating,
                    onSelected: (_) => onChanged(rating),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
