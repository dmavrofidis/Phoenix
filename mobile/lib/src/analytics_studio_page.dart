import 'package:flutter/material.dart';

import 'analytics_studio_engine.dart';
import 'state/fitness_store.dart';

class AnalyticsStudioPage extends StatefulWidget {
  const AnalyticsStudioPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<AnalyticsStudioPage> createState() => _AnalyticsStudioPageState();
}

class _AnalyticsStudioPageState extends State<AnalyticsStudioPage> {
  int _rangeDays = 7;
  double _movingWindow = 3;
  late String _exercise;
  double _target = 120;
  final _annotationLabel = TextEditingController(text: 'Training block change');
  final _annotationNote = TextEditingController();
  String _annotationCategory = 'Training';

  FitnessStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    _exercise = store.exerciseLibrary.first;
  }

  @override
  void dispose() {
    _annotationLabel.dispose();
    _annotationNote.dispose();
    super.dispose();
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _toggleMetric(String id) async {
    final metrics = [...store.analyticsDashboardMetrics];
    if (metrics.contains(id)) {
      if (metrics.length == 1) {
        _message('Keep at least one dashboard metric.');
        return;
      }
      metrics.remove(id);
    } else {
      metrics.add(id);
    }
    await store.setAnalyticsDashboardMetrics(metrics);
  }

  Future<void> _addAnnotation() async {
    try {
      await store.saveAnalyticsAnnotation(
        date: DateTime.now(),
        category: _annotationCategory,
        label: _annotationLabel.text,
        note: _annotationNote.text,
      );
      _annotationNote.clear();
      if (mounted) _message('Analytics annotation saved locally.');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('ANALYTICS STUDIO'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'DASHBOARD', icon: Icon(Icons.dashboard_customize)),
            Tab(text: 'LOAD', icon: Icon(Icons.monitor_heart_outlined)),
            Tab(text: 'SETS', icon: Icon(Icons.grid_on_outlined)),
            Tab(text: 'FORECAST', icon: Icon(Icons.trending_up)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => TabBarView(
          children: [
            _dashboardTab(context),
            _loadTab(context),
            _setsTab(context),
            _forecastTab(context),
          ],
        ),
      ),
    ),
  );

  Widget _dashboardTab(BuildContext context) {
    final now = DateTime.now();
    final metrics = AnalyticsStudioEngine.customDashboard(
      data: store.data,
      selectedMetrics: store.analyticsDashboardMetrics,
      now: now,
    );
    final comparison = AnalyticsStudioEngine.compareRanges(
      logs: store.data.logs,
      currentStart: now.subtract(Duration(days: _rangeDays)),
      currentEnd: now.add(const Duration(seconds: 1)),
      previousDays: _rangeDays,
    );
    final dailySessions = [
      for (var offset = 13; offset >= 0; offset--)
        store.data.logs
            .where((item) {
              final day = DateTime(
                now.year,
                now.month,
                now.day,
              ).subtract(Duration(days: offset));
              return item.completedAt.year == day.year &&
                  item.completedAt.month == day.month &&
                  item.completedAt.day == day.day;
            })
            .length
            .toDouble(),
    ];
    final average = AnalyticsStudioEngine.movingAverage(
      dailySessions,
      _movingWindow.round(),
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _StudioHero(
          icon: Icons.dashboard_customize,
          title: 'CUSTOM METRIC DASHBOARD',
          detail:
              'Choose the signals that deserve attention and compare equivalent date ranges.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final id in AnalyticsStudioEngine.supportedMetrics)
              FilterChip(
                selected: store.analyticsDashboardMetrics.contains(id),
                label: Text(id.toUpperCase()),
                onSelected: (_) => _toggleMetric(id),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final metric in metrics)
              _MetricCard(
                label: metric.label,
                value:
                    '${metric.value.toStringAsFixed(metric.value % 1 == 0 ? 0 : 1)}${metric.unit}',
                detail: metric.detail,
              ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(
              child: Text(
                'DATE-RANGE COMPARISON',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 7, label: Text('7D')),
                ButtonSegment(value: 14, label: Text('14D')),
                ButtonSegment(value: 28, label: Text('28D')),
              ],
              selected: {_rangeDays},
              onSelectionChanged: (value) =>
                  setState(() => _rangeDays = value.single),
            ),
          ],
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.compare_arrows),
            title: Text(
              '${comparison.current.toStringAsFixed(0)} vs ${comparison.previous.toStringAsFixed(0)} load',
            ),
            subtitle: Text(
              '${comparison.changePercent >= 0 ? '+' : ''}${comparison.changePercent.toStringAsFixed(1)}% • ${comparison.label}',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'MOVING AVERAGE • ${_movingWindow.round()}D',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        Slider(
          value: _movingWindow,
          min: 1,
          max: 7,
          divisions: 6,
          onChanged: (value) => setState(() => _movingWindow = value),
        ),
        _MiniBars(values: average),
      ],
    );
  }

  Widget _loadTab(BuildContext context) {
    final now = DateTime.now();
    final monotony = AnalyticsStudioEngine.monotony(
      logs: store.data.logs,
      now: now,
    );
    final annotations = AnalyticsStudioEngine.annotationsForRange(
      annotations: store.analyticsAnnotations,
      start: now.subtract(const Duration(days: 28)),
      end: now.add(const Duration(days: 1)),
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _StudioHero(
          icon: Icons.monitor_heart_outlined,
          title: 'MONOTONY & STRAIN',
          detail:
              'Track how repetitive the seven-day load is, then multiply it by total load to expose strain.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _MetricCard(
              label: 'WEEKLY LOAD',
              value: monotony.weeklyLoad.toStringAsFixed(0),
              detail: 'SESSION LOAD',
            ),
            _MetricCard(
              label: 'MONOTONY',
              value: monotony.monotony.toStringAsFixed(2),
              detail: monotony.label,
            ),
            _MetricCard(
              label: 'STRAIN',
              value: monotony.strain.toStringAsFixed(0),
              detail: 'LOAD × MONOTONY',
            ),
          ],
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('INTERPRET IN CONTEXT'),
            subtitle: Text(
              'Monotony is a descriptive workload signal, not an injury prediction or medical threshold.',
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'ANNOTATION LAYER',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        DropdownButtonFormField<String>(
          initialValue: _annotationCategory,
          decoration: const InputDecoration(labelText: 'CATEGORY'),
          items: const [
            DropdownMenuItem(value: 'Training', child: Text('Training')),
            DropdownMenuItem(value: 'Recovery', child: Text('Recovery')),
            DropdownMenuItem(value: 'Nutrition', child: Text('Nutrition')),
            DropdownMenuItem(value: 'Life', child: Text('Life')),
          ],
          onChanged: (value) =>
              setState(() => _annotationCategory = value ?? 'Training'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _annotationLabel,
          maxLength: 60,
          decoration: const InputDecoration(labelText: 'EVENT LABEL'),
        ),
        TextField(
          controller: _annotationNote,
          maxLength: 240,
          decoration: const InputDecoration(labelText: 'OPTIONAL NOTE'),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _addAnnotation,
            icon: const Icon(Icons.add_comment_outlined),
            label: const Text('ADD ANNOTATION'),
          ),
        ),
        for (final item in annotations.reversed)
          Card(
            child: ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: Text('${item.category} • ${item.label}'),
              subtitle: Text(
                '${item.date.day}/${item.date.month}/${item.date.year}'
                '${item.note.isEmpty ? '' : '\n${item.note}'}',
              ),
              trailing: IconButton(
                tooltip: 'Remove annotation',
                onPressed: () => store.removeAnalyticsAnnotation(item.id),
                icon: const Icon(Icons.delete_outline),
              ),
            ),
          ),
      ],
    );
  }

  Widget _setsTab(BuildContext context) {
    final distribution = AnalyticsStudioEngine.volumeIntensityDistribution(
      store.data.logs,
    );
    final heatmap = AnalyticsStudioEngine.setRepHeatmap(store.data.logs);
    final now = DateTime.now();
    final funnel = AnalyticsStudioEngine.adherenceFunnel(
      plannedSessions: (store.profile?.daysPerWeek ?? 3) * 4,
      logs: store.data.logs,
      start: now.subtract(const Duration(days: 28)),
      end: now.add(const Duration(seconds: 1)),
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _StudioHero(
          icon: Icons.grid_on_outlined,
          title: 'VOLUME–INTENSITY DISTRIBUTION',
          detail:
              'See where logged working sets sit relative to each exercise’s heaviest recorded load.',
        ),
        const SizedBox(height: 14),
        _DistributionBar(distribution: distribution),
        const SizedBox(height: 18),
        Text('SET–REP HEATMAP', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _Heatmap(cells: heatmap),
        const SizedBox(height: 18),
        Text(
          'EXERCISE ADHERENCE FUNNEL',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _FunnelRow(
          label: 'PLANNED',
          value: funnel.planned,
          maximum: funnel.planned,
        ),
        _FunnelRow(
          label: 'COMPLETED',
          value: funnel.completed,
          maximum: funnel.planned,
        ),
        _FunnelRow(
          label: 'SETS LOGGED',
          value: funnel.loggedSets,
          maximum: funnel.planned,
        ),
        _FunnelRow(
          label: 'QUALITY REVIEW',
          value: funnel.qualityReviewed,
          maximum: funnel.planned,
        ),
      ],
    );
  }

  Widget _forecastTab(BuildContext context) {
    final forecast = AnalyticsStudioEngine.forecast(
      exercise: _exercise,
      logs: store.data.logs,
      target: _target,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _StudioHero(
          icon: Icons.trending_up,
          title: 'GOAL PROGRESS FORECAST',
          detail:
              'Project an e1RM target from logged performance while keeping the assumptions visible.',
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _exercise,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'EXERCISE'),
          items: [
            for (final exercise in store.exerciseLibrary)
              DropdownMenuItem(
                value: exercise,
                child: Text(exercise, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (value) => setState(() => _exercise = value ?? _exercise),
        ),
        const SizedBox(height: 14),
        Text(
          'TARGET E1RM • ${_target.toStringAsFixed(0)}KG',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        Slider(
          value: _target,
          min: 20,
          max: 300,
          divisions: 56,
          onChanged: (value) => setState(() => _target = value),
        ),
        Card(
          color: forecast.status == 'TARGET REACHED'
              ? const Color(0xFF17382D)
              : const Color(0xFF252E3D),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Text(
                  forecast.estimatedWeeks == 0
                      ? '—'
                      : '${forecast.estimatedWeeks} WEEKS',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  forecast.status,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const Divider(height: 24),
                Text(
                  '${forecast.current.toStringAsFixed(1)} → ${forecast.target.toStringAsFixed(1)}kg e1RM',
                ),
                Text(
                  '${forecast.weeklyChange >= 0 ? '+' : ''}${forecast.weeklyChange.toStringAsFixed(2)}kg/week',
                ),
                const SizedBox(height: 8),
                Text(forecast.assumption, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StudioHero extends StatelessWidget {
  const _StudioHero({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFF18313B),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, size: 34, color: const Color(0xFF81D4FA)),
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
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 160,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(detail),
          ],
        ),
      ),
    ),
  );
}

class _MiniBars extends StatelessWidget {
  const _MiniBars({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final maximum = values.fold<double>(
      1,
      (max, value) => value > max ? value : max,
    );
    return SizedBox(
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final value in values)
            Expanded(
              child: Container(
                height: 8 + (value / maximum * 72),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4FC3F7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DistributionBar extends StatelessWidget {
  const _DistributionBar({required this.distribution});

  final TrainingLoadDistribution distribution;

  @override
  Widget build(BuildContext context) {
    final total = distribution.totalSets == 0 ? 1 : distribution.totalSets;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Expanded(
                    flex: distribution.low + 1,
                    child: Container(
                      height: 20,
                      color: const Color(0xFF66BB6A),
                    ),
                  ),
                  Expanded(
                    flex: distribution.moderate + 1,
                    child: Container(
                      height: 20,
                      color: const Color(0xFFFFB74D),
                    ),
                  ),
                  Expanded(
                    flex: distribution.high + 1,
                    child: Container(
                      height: 20,
                      color: const Color(0xFFEF5350),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'LOW ${distribution.low} • MODERATE ${distribution.moderate} • '
              'HIGH ${distribution.high} • TOTAL ${total == 1 && distribution.totalSets == 0 ? 0 : total}',
            ),
          ],
        ),
      ),
    );
  }
}

class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.cells});

  final List<SetRepHeatCell> cells;

  @override
  Widget build(BuildContext context) {
    final maximum = cells.fold<int>(
      1,
      (max, item) => item.count > max ? item.count : max,
    );
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        for (final cell in cells)
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Color.lerp(
                Colors.white10,
                const Color(0xFF29B6F6),
                cell.count / maximum,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${cell.repBand}\n${cell.loadBand}\n${cell.count}',
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _FunnelRow extends StatelessWidget {
  const _FunnelRow({
    required this.label,
    required this.value,
    required this.maximum,
  });

  final String label;
  final int value;
  final int maximum;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        SizedBox(width: 110, child: Text(label)),
        Expanded(
          child: LinearProgressIndicator(
            value: maximum == 0 ? 0 : value / maximum,
            minHeight: 12,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(width: 35, child: Text('$value', textAlign: TextAlign.end)),
      ],
    ),
  );
}
