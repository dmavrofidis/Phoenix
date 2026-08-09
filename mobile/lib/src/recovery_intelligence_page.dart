import 'package:flutter/material.dart';

import 'recovery_intelligence_engine.dart';
import 'state/fitness_store.dart';

class RecoveryIntelligencePage extends StatefulWidget {
  const RecoveryIntelligencePage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<RecoveryIntelligencePage> createState() =>
      _RecoveryIntelligencePageState();
}

class _RecoveryIntelligencePageState extends State<RecoveryIntelligencePage> {
  final _notes = TextEditingController();
  String _intervention = 'Sauna';
  int _durationMinutes = 15;
  double _temperatureCelsius = 80;
  int _beforeScore = 5;
  int _afterScore = 7;
  bool _saving = false;

  FitnessStore get store => widget.store;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  bool get _usesTemperature =>
      const {'Sauna', 'Cold exposure'}.contains(_intervention);

  void _selectIntervention(String value) {
    setState(() {
      _intervention = value;
      _durationMinutes = switch (value) {
        'Sauna' => 15,
        'Cold exposure' => 3,
        'Nap' => 25,
        _ => 15,
      };
      _temperatureCelsius = switch (value) {
        'Sauna' => 80,
        'Cold exposure' => 12,
        _ => 0,
      };
    });
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _saveIntervention() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await store.saveRecoveryIntervention(
        intervention: _intervention,
        durationMinutes: _durationMinutes,
        temperatureCelsius: _usesTemperature ? _temperatureCelsius : 0,
        beforeScore: _beforeScore,
        afterScore: _afterScore,
        notes: _notes.text,
      );
      _notes.clear();
      if (mounted) _message('Recovery intervention saved locally.');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('RECOVERY INTELLIGENCE'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'TRENDS', icon: Icon(Icons.query_stats)),
            Tab(text: 'RECOVERY DAY', icon: Icon(Icons.self_improvement)),
            Tab(text: 'INTERVENTIONS', icon: Icon(Icons.science_outlined)),
            Tab(text: 'FORECAST', icon: Icon(Icons.timeline)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => TabBarView(
          children: [
            _trendsTab(context),
            _recoveryDayTab(context),
            _interventionsTab(context),
            _forecastTab(context),
          ],
        ),
      ),
    ),
  );

  Widget _trendsTab(BuildContext context) {
    final trend = RecoveryIntelligenceEngine.trendDashboard(
      store.data.recoveryChecks,
    );
    final sleep = RecoveryIntelligenceEngine.sleepDebt(
      store.data.recoveryChecks,
    );
    final soreness = RecoveryIntelligenceEngine.sorenessDecay(
      store.data.recoveryChecks,
    );
    final stress = RecoveryIntelligenceEngine.stressTrend(
      store.data.recoveryChecks,
    );
    final rhr = RecoveryIntelligenceEngine.restingHeartRateDeviation(
      store.data.recoveryChecks,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _RecoveryHero(
          icon: Icons.query_stats,
          title: 'RECOVERY TREND DASHBOARD',
          detail:
              'Seven-day readiness, sleep, soreness, stress and resting-heart-rate context from local check-ins.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Metric(
              label: 'READINESS',
              value: trend.sampleDays == 0 ? '—' : '${trend.currentReadiness}',
              detail: trend.direction,
            ),
            _Metric(
              label: '7D CHANGE',
              value: trend.sampleDays < 2
                  ? '—'
                  : '${trend.readinessChange >= 0 ? '+' : ''}${trend.readinessChange}',
              detail: 'VS PRIOR WINDOW',
            ),
            _Metric(
              label: 'SLEEP',
              value: trend.sampleDays == 0
                  ? '—'
                  : '${trend.averageSleepHours.toStringAsFixed(1)}h',
              detail: '7D AVERAGE',
            ),
            _Metric(
              label: 'RHR',
              value: trend.averageRestingHeartRate == 0
                  ? '—'
                  : '${trend.averageRestingHeartRate}',
              detail: 'BPM AVERAGE',
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ReadinessChart(scores: trend.dailyScores),
        const SizedBox(height: 14),
        _InsightCard(
          icon: Icons.bedtime_outlined,
          title:
              'SLEEP DEBT • ${sleep.totalHours.toStringAsFixed(1)}h • ${sleep.level}',
          detail:
              '${sleep.nights}/7 nights • target ${sleep.targetHours.toStringAsFixed(1)}h. ${sleep.action}',
          alert: sleep.level == 'HIGH' || sleep.level == 'SEVERE',
        ),
        _InsightCard(
          icon: Icons.accessibility_new,
          title:
              'SORENESS DECAY • ${soreness.status} • ${soreness.focusArea.toUpperCase()}',
          detail: soreness.latestSoreness == 0
              ? 'Log daily soreness to estimate the decay curve.'
              : '${soreness.dailyDecay.toStringAsFixed(2)} points/day • '
                    '${soreness.daysToLow} estimated day(s) to low soreness.',
          alert: soreness.status == 'RISING',
        ),
        _InsightCard(
          icon: Icons.psychology_outlined,
          title:
              'STRESS LOAD • ${stress.direction} • ${stress.currentAverage.toStringAsFixed(1)}/5',
          detail:
              '${stress.highStressDays} high-stress day(s) in the recent window • '
              '${stress.change >= 0 ? '+' : ''}${stress.change.toStringAsFixed(1)} vs prior.',
          alert: stress.direction == 'RISING' && stress.highStressDays >= 3,
        ),
        _InsightCard(
          icon: Icons.monitor_heart_outlined,
          title: 'RESTING HR • ${rhr.status}',
          detail: rhr.latest == 0
              ? 'Add resting heart rate to morning check-ins to build a baseline.'
              : '${rhr.latest} bpm today • baseline ${rhr.baseline == 0 ? 'building' : '${rhr.baseline} bpm'}'
                    '${rhr.baseline == 0 ? '' : ' • ${rhr.deviation >= 0 ? '+' : ''}${rhr.deviation} bpm'}.',
          alert: rhr.hasAlert,
        ),
      ],
    );
  }

  Widget _recoveryDayTab(BuildContext context) {
    final sortedChecks = [...store.data.recoveryChecks]
      ..sort((left, right) => right.recordedAt.compareTo(left.recordedAt));
    final recommendation = RecoveryIntelligenceEngine.recoveryDayRecommendation(
      checkIns: store.data.recoveryChecks,
    );
    final session = RecoveryIntelligenceEngine.activeRecoverySession(
      recommendation: recommendation,
      latest: sortedChecks.isEmpty ? null : sortedChecks.first,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _RecoveryHero(
          icon: Icons.self_improvement,
          title: 'RECOVERY-DAY DECISION',
          detail:
              'A guarded decision combines readiness, sleep debt, soreness, stress and RHR deviation.',
        ),
        const SizedBox(height: 14),
        Card(
          color: _recommendationColor(context, recommendation.accent),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.level,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recommendation.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(recommendation.reason),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: recommendation.trainingLoadPercent / 100,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 7),
                Text(
                  'TRAINING-LOAD CEILING • ${recommendation.trainingLoadPercent}%',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'ACTIVE-RECOVERY SESSION GENERATOR',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(child: Text('${session.totalMinutes}m')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        session.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (var index = 0; index < session.segments.length; index++)
                  _SessionSegment(
                    index: index + 1,
                    segment: session.segments[index],
                  ),
                const Divider(height: 24),
                Text(
                  'STOP RULE • ${session.stopRule}',
                  style: const TextStyle(color: Colors.orangeAccent),
                ),
              ],
            ),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.health_and_safety_outlined),
            title: Text('SYMPTOMS OVERRIDE THE SCORE'),
            subtitle: Text(
              'Fever, chest pain, fainting, unusual shortness of breath or acute injury require rest and qualified medical guidance.',
            ),
          ),
        ),
      ],
    );
  }

  Widget _interventionsTab(BuildContext context) {
    final comparisons = RecoveryIntelligenceEngine.compareInterventions(
      store.recoveryInterventions,
    );
    final maxTemperature = _intervention == 'Sauna' ? 110.0 : 25.0;
    final minTemperature = _intervention == 'Sauna' ? 40.0 : 0.0;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _RecoveryHero(
          icon: Icons.science_outlined,
          title: 'RECOVERY INTERVENTION LOG',
          detail:
              'Track an immediate before/after response. Comparison shows personal signals, not medical effectiveness.',
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _intervention,
          decoration: const InputDecoration(labelText: 'INTERVENTION'),
          items: [
            for (final value
                in RecoveryIntelligenceEngine.supportedInterventions)
              DropdownMenuItem(value: value, child: Text(value.toUpperCase())),
          ],
          onChanged: (value) {
            if (value != null) _selectIntervention(value);
          },
        ),
        _ValueSlider(
          label: 'DURATION',
          value: _durationMinutes,
          minimum: 1,
          maximum: 60,
          suffix: 'min',
          onChanged: (value) => setState(() => _durationMinutes = value),
        ),
        if (_usesTemperature)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TEMPERATURE • ${_temperatureCelsius.toStringAsFixed(0)}°C',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Slider(
                value: _temperatureCelsius
                    .clamp(minTemperature, maxTemperature)
                    .toDouble(),
                min: minTemperature,
                max: maxTemperature,
                divisions: (maxTemperature - minTemperature).round(),
                onChanged: (value) =>
                    setState(() => _temperatureCelsius = value),
              ),
            ],
          ),
        Row(
          children: [
            Expanded(
              child: _ValueSlider(
                label: 'BEFORE',
                value: _beforeScore,
                minimum: 1,
                maximum: 10,
                suffix: '/10',
                onChanged: (value) => setState(() => _beforeScore = value),
              ),
            ),
            Expanded(
              child: _ValueSlider(
                label: 'AFTER',
                value: _afterScore,
                minimum: 1,
                maximum: 10,
                suffix: '/10',
                onChanged: (value) => setState(() => _afterScore = value),
              ),
            ),
          ],
        ),
        TextField(
          controller: _notes,
          maxLength: 160,
          decoration: const InputDecoration(
            labelText: 'OPTIONAL NOTES',
            hintText: 'Hydration, timing, how you felt…',
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _saving ? null : _saveIntervention,
            icon: const Icon(Icons.save_outlined),
            label: const Text('SAVE RESPONSE'),
          ),
        ),
        const SizedBox(height: 14),
        const _SafetyNotice(),
        const SizedBox(height: 18),
        Text(
          'PERSONAL INTERVENTION COMPARISON',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (comparisons.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.insights_outlined),
              title: Text('NO COMPARISON YET'),
              subtitle: Text(
                'Save repeated before/after responses to reveal personal patterns.',
              ),
            ),
          )
        else
          for (final item in comparisons)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${item.sampleSize}×')),
                title: Text(
                  '${item.intervention.toUpperCase()} • ${item.label}',
                ),
                subtitle: Text(
                  '${(item.positiveRate * 100).round()}% positive responses',
                ),
                trailing: Text(
                  '${item.averageResponse >= 0 ? '+' : ''}${item.averageResponse.toStringAsFixed(1)}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
      ],
    );
  }

  Widget _forecastTab(BuildContext context) {
    final forecast = RecoveryIntelligenceEngine.returnToBaseline(
      store.data.recoveryChecks,
    );
    final soreness = RecoveryIntelligenceEngine.sorenessDecay(
      store.data.recoveryChecks,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _RecoveryHero(
          icon: Icons.timeline,
          title: 'RETURN-TO-BASELINE FORECAST',
          detail:
              'A transparent short-range estimate from your readiness direction. It recalculates after every check-in.',
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ForecastPoint(
                      label: 'NOW',
                      value: forecast.latestScore == 0
                          ? '—'
                          : '${forecast.latestScore}',
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.white54),
                    _ForecastPoint(
                      label: 'BASELINE',
                      value: forecast.targetScore == 0
                          ? '—'
                          : '${forecast.targetScore}',
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.white54),
                    _ForecastPoint(
                      label: 'ETA',
                      value: forecast.latestScore == 0
                          ? '—'
                          : '${forecast.estimatedDays}d',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                LinearProgressIndicator(
                  value: forecast.targetScore <= 0
                      ? 0
                      : (forecast.latestScore / forecast.targetScore)
                            .clamp(0, 1)
                            .toDouble(),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 12),
                Text(
                  forecast.status,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  'Trend ${forecast.dailyTrend >= 0 ? '+' : ''}${forecast.dailyTrend.toStringAsFixed(1)} readiness points/day • '
                  '${forecast.confidence} confidence',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        _InsightCard(
          icon: Icons.accessibility_new,
          title: 'SORENESS ETA • ${soreness.daysToLow} DAY(S)',
          detail:
              '${soreness.focusArea.toUpperCase()} • ${soreness.status} • '
              '${soreness.dailyDecay.toStringAsFixed(2)} points/day.',
          alert: soreness.status == 'RISING',
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.rule_outlined),
            title: Text('FORECAST RULES'),
            subtitle: Text(
              'Maximum horizon is 14 days. A flat or worsening trend lowers confidence; symptoms and pain always override the estimate.',
            ),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('LOCAL-FIRST'),
            subtitle: Text(
              'Check-ins, interventions and forecasts remain on this device unless you export a backup.',
            ),
          ),
        ),
      ],
    );
  }

  Color? _recommendationColor(BuildContext context, String accent) =>
      switch (accent) {
        'red' => Theme.of(context).colorScheme.errorContainer,
        'amber' => const Color(0xFF3D321E),
        'green' => const Color(0xFF153C2D),
        _ => null,
      };
}

class _RecoveryHero extends StatelessWidget {
  const _RecoveryHero({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Theme.of(context).colorScheme.primary.withValues(alpha: .28),
          const Color(0xFF111820),
        ],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white12),
    ),
    child: Row(
      children: [
        CircleAvatar(radius: 25, child: Icon(icon)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              Text(detail),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 154,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 1,
                fontWeight: FontWeight.w900,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(detail, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    ),
  );
}

class _ReadinessChart extends StatelessWidget {
  const _ReadinessChart({required this.scores});

  final List<int> scores;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'READINESS • LAST 7 CHECK-INS',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          const SizedBox(height: 14),
          if (scores.isEmpty)
            const SizedBox(
              height: 110,
              child: Center(
                child: Text('Complete check-ins to draw the recovery curve.'),
              ),
            )
          else
            SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var index = 0; index < scores.length; index++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${scores[index]}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: mathHeight(scores[index]),
                              decoration: BoxDecoration(
                                color: _barColor(scores[index]),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(7),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${index + 1}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    ),
  );

  static double mathHeight(int value) => 20 + value.clamp(0, 100) * .75;

  static Color _barColor(int value) => value >= 76
      ? const Color(0xFF43A047)
      : value >= 55
      ? const Color(0xFFFFA726)
      : const Color(0xFFE53935);
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.title,
    required this.detail,
    this.alert = false,
  });

  final IconData icon;
  final String title;
  final String detail;
  final bool alert;

  @override
  Widget build(BuildContext context) => Card(
    color: alert ? Theme.of(context).colorScheme.errorContainer : null,
    child: ListTile(
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title),
      subtitle: Text(detail),
    ),
  );
}

class _SessionSegment extends StatelessWidget {
  const _SessionSegment({required this.index, required this.segment});

  final int index;
  final ActiveRecoverySegment segment;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(radius: 16, child: Text('$index')),
    title: Text('${segment.name.toUpperCase()} • ${segment.minutes} MIN'),
    subtitle: Text(segment.detail),
    trailing: Text(segment.intensity),
  );
}

class _ValueSlider extends StatelessWidget {
  const _ValueSlider({
    required this.label,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.suffix,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int minimum;
  final int maximum;
  final String suffix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),
      Text(
        '$label • $value $suffix',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      Slider(
        value: value.toDouble(),
        min: minimum.toDouble(),
        max: maximum.toDouble(),
        divisions: maximum - minimum,
        onChanged: (value) => onChanged(value.round()),
      ),
    ],
  );
}

class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice();

  @override
  Widget build(BuildContext context) => const Card(
    child: ListTile(
      leading: Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
      title: Text('HEAT & COLD SAFETY'),
      subtitle: Text(
        'Never use extreme exposure alone. Hydrate, avoid alcohol, stop for dizziness, numbness, chest pain or confusion, and seek medical advice for cardiovascular, pregnancy or medication concerns.',
      ),
    ),
  );
}

class _ForecastPoint extends StatelessWidget {
  const _ForecastPoint({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
      ),
      Text(label, style: const TextStyle(fontSize: 10, letterSpacing: 1)),
    ],
  );
}
