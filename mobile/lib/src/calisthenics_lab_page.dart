import 'dart:async';

import 'package:flutter/material.dart';

import 'calisthenics_engine.dart';
import 'phoenix_l10n.dart';
import 'program_editor_page.dart';
import 'state/fitness_store.dart';

class CalisthenicsLabPage extends StatefulWidget {
  const CalisthenicsLabPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<CalisthenicsLabPage> createState() => _CalisthenicsLabPageState();
}

class _CalisthenicsLabPageState extends State<CalisthenicsLabPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  Timer? _timer;
  int _practiceSeconds = 0;
  bool _practiceRunning = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabs.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    if (_practiceRunning) {
      _timer?.cancel();
      setState(() => _practiceRunning = false);
      return;
    }
    setState(() => _practiceRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _practiceSeconds >= 300) {
        timer.cancel();
        if (mounted) setState(() => _practiceRunning = false);
        return;
      }
      setState(() => _practiceSeconds++);
    });
  }

  Future<void> _saveHandstand() async {
    if (_practiceSeconds <= 0) return;
    await widget.store.saveSkillAssessment(
      skillId: 'handstand',
      value: _practiceSeconds.toDouble(),
      unit: 'seconds',
      level: CalisthenicsEngine.levelFor(
        'handstand',
        _practiceSeconds.toDouble(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.text(
            'Καταγράφηκαν $_practiceSeconds″ handstand.',
            'Logged $_practiceSeconds seconds of handstand.',
          ),
        ),
      ),
    );
    setState(() {
      _practiceSeconds = 0;
      _practiceRunning = false;
    });
  }

  Future<void> _assessment({
    required String skillId,
    required String title,
    required String unit,
    required double max,
  }) async {
    final controller = TextEditingController();
    final value = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              unit == 'reps'
                  ? 'Μέτρα μόνο αυστηρές επαναλήψεις. Stop στην πρώτη απώλεια τεχνικής.'
                  : unit == 'seconds'
                  ? 'Κατέγραψε τον καλύτερο ανώδυνο, ελεγχόμενο χρόνο.'
                  : '0 = περιορισμένο, 100 = πλήρες ανώδυνο εύρος.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: unit == 'reps'
                    ? 'Strict reps'
                    : unit == 'seconds'
                    ? 'Seconds'
                    : 'Mobility score',
                suffixText: unit == 'seconds' ? 'sec' : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () {
                final parsed = double.tryParse(
                  controller.text.replaceAll(',', '.'),
                );
                if (parsed == null || parsed < 0 || parsed > max) return;
                Navigator.of(context).pop(parsed);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 13),
                child: Text('Αποθήκευση assessment'),
              ),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (value == null) return;
    await widget.store.saveSkillAssessment(
      skillId: skillId,
      value: value,
      unit: unit,
      level: CalisthenicsEngine.levelFor(skillId, value),
    );
  }

  Future<void> _buildSkillSession() async {
    final selected = <String>{'handstand', 'pull-up'};
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SKILL SESSION BUILDER',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Διάλεξε 1–3 skills. Το session κρατά χαμηλή κόπωση και τεχνικό stop.',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in const {
                      'handstand': 'Handstand',
                      'pull-up': 'Pull-up',
                      'push-up': 'Push-up',
                      'l-sit': 'L-sit',
                      'hollow-hold': 'Hollow',
                    }.entries)
                      FilterChip(
                        label: Text(item.value),
                        selected: selected.contains(item.key),
                        onSelected: (enabled) => setSheetState(() {
                          if (enabled && selected.length < 3) {
                            selected.add(item.key);
                          } else if (!enabled && selected.length > 1) {
                            selected.remove(item.key);
                          }
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(selected),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Δημιουργία skill session'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result == null) return;
    final template = CalisthenicsEngine.buildSkillSession(
      skillIds: result,
      id: 'custom-skill-${DateTime.now().microsecondsSinceEpoch}',
    );
    await widget.store.updateWorkoutTemplate(template);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ProgramEditorPage(store: widget.store, template: template),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('CALISTHENICS LAB'),
          bottom: TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'TREE', icon: Icon(Icons.account_tree_outlined)),
              Tab(text: 'ASSESS', icon: Icon(Icons.fact_check_outlined)),
              Tab(text: 'PRACTICE', icon: Icon(Icons.timer_outlined)),
              Tab(text: 'ANALYTICS', icon: Icon(Icons.query_stats)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabs,
          children: [
            _SkillTreeTab(store: widget.store),
            _AssessmentTab(store: widget.store, onAssess: _assessment),
            _PracticeTab(
              store: widget.store,
              seconds: _practiceSeconds,
              running: _practiceRunning,
              onToggle: _toggleTimer,
              onReset: () {
                _timer?.cancel();
                setState(() {
                  _practiceSeconds = 0;
                  _practiceRunning = false;
                });
              },
              onSave: _saveHandstand,
              onBuild: _buildSkillSession,
            ),
            _HoldAnalyticsTab(store: widget.store),
          ],
        ),
      ),
    );
  }
}

class _SkillTreeTab extends StatelessWidget {
  const _SkillTreeTab({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final nodes = CalisthenicsEngine.skillTree(store.data);
    final weighted = CalisthenicsEngine.weightedPullUpPlan(store.data);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      children: [
        Text(
          context.l10n.text(
            'Ο προσωπικός σου skill χάρτης',
            'Your personal skill map',
          ),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 5),
        Text(
          context.l10n.text(
            'Τα επίπεδα αλλάζουν μόνο από μετρήσιμα assessments.',
            'Levels change only through measurable assessments.',
          ),
        ),
        const SizedBox(height: 16),
        for (var index = 0; index < nodes.length; index++) ...[
          _SkillNodeCard(node: nodes[index]),
          if (index < nodes.length - 1)
            Center(
              child: Container(width: 2, height: 12, color: Colors.white24),
            ),
        ],
        const SizedBox(height: 18),
        _WeightedProgressionCard(plan: weighted),
      ],
    );
  }
}

class _SkillNodeCard extends StatelessWidget {
  const _SkillNodeCard({required this.node});

  final SkillNodeProgress node;

  @override
  Widget build(BuildContext context) {
    final color = node.unlocked
        ? Theme.of(context).colorScheme.primary
        : Colors.white30;
    return Card(
      color: node.unlocked ? null : const Color(0xFF0D0D0D),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: .16),
              child: Icon(
                node.unlocked ? Icons.sports_gymnastics : Icons.lock_outline,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          node.name,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Text(
                        'LVL ${node.level}/${node.maxLevel}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    node.unlocked
                        ? node.nextTarget
                        : 'Requires: ${node.prerequisiteIds.join(' + ')}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: node.progress,
                    color: color,
                    backgroundColor: Colors.white10,
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssessmentTab extends StatelessWidget {
  const _AssessmentTab({required this.store, required this.onAssess});

  final FitnessStore store;
  final Future<void> Function({
    required String skillId,
    required String title,
    required String unit,
    required double max,
  })
  onAssess;

  @override
  Widget build(BuildContext context) {
    final checks = CalisthenicsEngine.prerequisites(
      store.data,
      profile: store.profile,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      children: [
        const Text(
          'PREREQUISITE ASSESSMENT',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        for (final check in checks)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                check.passed ? Icons.verified : Icons.pending_outlined,
                color: check.passed
                    ? const Color(0xFF66BB6A)
                    : const Color(0xFFFFB74D),
              ),
              title: Text(
                check.title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(check.detail),
            ),
          ),
        const SizedBox(height: 18),
        const Text(
          'STANDARDIZED TESTS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        _AssessmentButton(
          icon: Icons.arrow_upward,
          title: 'Strict Pull-up Assessment',
          subtitle: 'Dead hang → chin over bar • no kip',
          onTap: () => onAssess(
            skillId: 'pull-up',
            title: 'STRICT PULL-UP TEST',
            unit: 'reps',
            max: 100,
          ),
        ),
        _AssessmentButton(
          icon: Icons.south_east,
          title: 'Strict Push-up Assessment',
          subtitle: 'Full lockout • chest to target • rigid body',
          onTap: () => onAssess(
            skillId: 'push-up',
            title: 'STRICT PUSH-UP TEST',
            unit: 'reps',
            max: 200,
          ),
        ),
        _AssessmentButton(
          icon: Icons.airline_seat_flat,
          title: 'Hollow Hold Assessment',
          subtitle: 'Low back stays connected • technical stop',
          onTap: () => onAssess(
            skillId: 'hollow-hold',
            title: 'HOLLOW HOLD TEST',
            unit: 'seconds',
            max: 300,
          ),
        ),
        _AssessmentButton(
          icon: Icons.accessibility_new,
          title: 'Overhead Mobility',
          subtitle: 'Pain-free shoulder flexion score 0–100',
          onTap: () => onAssess(
            skillId: 'mobility-overhead',
            title: 'OVERHEAD MOBILITY',
            unit: 'score',
            max: 100,
          ),
        ),
        _AssessmentButton(
          icon: Icons.sports_martial_arts,
          title: 'Deep Squat Mobility',
          subtitle: 'Stable heels, knees and torso score 0–100',
          onTap: () => onAssess(
            skillId: 'mobility-squat',
            title: 'DEEP SQUAT MOBILITY',
            unit: 'score',
            max: 100,
          ),
        ),
      ],
    );
  }
}

class _AssessmentButton extends StatelessWidget {
  const _AssessmentButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}

class _PracticeTab extends StatelessWidget {
  const _PracticeTab({
    required this.store,
    required this.seconds,
    required this.running,
    required this.onToggle,
    required this.onReset,
    required this.onSave,
    required this.onBuild,
  });

  final FitnessStore store;
  final int seconds;
  final bool running;
  final VoidCallback onToggle;
  final VoidCallback onReset;
  final VoidCallback onSave;
  final VoidCallback onBuild;

  @override
  Widget build(BuildContext context) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainder = (seconds % 60).toString().padLeft(2, '0');
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF172536), Color(0xFF101010)],
            ),
            border: Border.all(color: const Color(0x5542A5F5)),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.accessibility_new,
                size: 48,
                color: Color(0xFF64B5F6),
              ),
              const SizedBox(height: 10),
              const Text(
                'HANDSTAND PRACTICE TIMER',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              const SizedBox(height: 12),
              Text(
                '$minutes:$remainder',
                style: const TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'Short quality attempts • 45–90″ rest • stop before shaking',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onToggle,
                      icon: Icon(running ? Icons.pause : Icons.play_arrow),
                      label: Text(running ? 'Pause' : 'Start'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    onPressed: onReset,
                    icon: const Icon(Icons.restart_alt),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: seconds == 0 ? null : onSave,
                    icon: const Icon(Icons.save_outlined),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text(
              'Skill Session Builder',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: const Text(
              'Συνδύασε έως 3 skills σε ασφαλές low-fatigue session.',
            ),
            trailing: FilledButton(
              onPressed: onBuild,
              child: const Text('BUILD'),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeightedProgressionCard extends StatelessWidget {
  const _WeightedProgressionCard({required this.plan});

  final WeightedCalisthenicsPlan plan;

  @override
  Widget build(BuildContext context) => Card(
    color: plan.ready ? const Color(0xFF152115) : const Color(0xFF21190E),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WEIGHTED CALISTHENICS PROGRESSION',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .8),
          ),
          const SizedBox(height: 8),
          Text(
            plan.exercise,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(
            '${plan.currentLoad.toStringAsFixed(1)} → ${plan.nextLoad.toStringAsFixed(1)} kg • ${plan.target}',
          ),
          const SizedBox(height: 6),
          Text(
            plan.reason,
            style: TextStyle(
              color: plan.ready
                  ? const Color(0xFF81C784)
                  : const Color(0xFFFFB74D),
            ),
          ),
        ],
      ),
    ),
  );
}

class _HoldAnalyticsTab extends StatelessWidget {
  const _HoldAnalyticsTab({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final analytics = CalisthenicsEngine.holdAnalytics(store.data);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      children: [
        const Text(
          'HOLD-SPECIFIC ANALYTICS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        const SizedBox(height: 5),
        const Text(
          'Handstand, L-sit, hollow και κάθε timed set σε μία εικόνα.',
        ),
        const SizedBox(height: 14),
        if (analytics.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.timer_off_outlined),
              title: Text('Δεν υπάρχουν timed attempts'),
              subtitle: Text(
                'Κατάγραψε hold ή handstand practice για να αρχίσει το trend.',
              ),
            ),
          )
        else
          for (final item in analytics)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: Text(
                        '${item.bestSeconds}″',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.skill,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            '${item.attempts} attempts • previous ${item.previousBestSeconds}″',
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item.previousBestSeconds == 0
                          ? 'NEW'
                          : '${item.changePercent >= 0 ? '+' : ''}${item.changePercent.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Color(0xFF81C784),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
