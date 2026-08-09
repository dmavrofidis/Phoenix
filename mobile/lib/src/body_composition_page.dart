import 'dart:convert';

import 'package:flutter/material.dart';

import 'body_composition_engine.dart';
import 'state/fitness_store.dart';

class BodyCompositionPage extends StatefulWidget {
  const BodyCompositionPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<BodyCompositionPage> createState() => _BodyCompositionPageState();
}

class _BodyCompositionPageState extends State<BodyCompositionPage> {
  late final TextEditingController _weight;
  final _waist = TextEditingController(text: '85');
  final _neck = TextEditingController(text: '38');
  final _chest = TextEditingController(text: '100');
  final _hips = TextEditingController(text: '98');
  final _arm = TextEditingController(text: '34');
  final _thigh = TextEditingController(text: '58');
  final _notes = TextEditingController();
  late double _targetWeight;
  bool _saving = false;

  FitnessStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    _weight = TextEditingController(
      text: store.currentWeightKilograms.toStringAsFixed(1),
    );
    _targetWeight = store.currentWeightKilograms - 5;
  }

  @override
  void dispose() {
    _weight.dispose();
    _waist.dispose();
    _neck.dispose();
    _chest.dispose();
    _hips.dispose();
    _arm.dispose();
    _thigh.dispose();
    _notes.dispose();
    super.dispose();
  }

  double _number(TextEditingController controller) =>
      double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _saveMeasurement() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await store.saveBodyMeasurement(
        weightKilograms: _number(_weight),
        waistCentimeters: _number(_waist),
        neckCentimeters: _number(_neck),
        chestCentimeters: _number(_chest),
        hipsCentimeters: _number(_hips),
        upperArmCentimeters: _number(_arm),
        thighCentimeters: _number(_thigh),
        notes: _notes.text,
      );
      _notes.clear();
      if (mounted) _message('Body measurements saved locally.');
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
        title: const Text('BODY COMPOSITION'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'WEIGHT TREND', icon: Icon(Icons.show_chart)),
            Tab(text: 'MEASURE', icon: Icon(Icons.straighten)),
            Tab(text: 'COMPOSITION', icon: Icon(Icons.accessibility_new)),
            Tab(text: 'PHOTOS & REVIEW', icon: Icon(Icons.compare)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => TabBarView(
          children: [
            _trendTab(context),
            _measureTab(context),
            _compositionTab(context),
            _reviewTab(context),
          ],
        ),
      ),
    ),
  );

  Widget _trendTab(BuildContext context) {
    final trend = BodyCompositionEngine.smoothedWeightTrend(store.data.weights);
    final rate = BodyCompositionEngine.weeklyRate(store.data.weights);
    final projection = BodyCompositionEngine.projection(
      currentKilograms: store.currentWeightKilograms,
      targetKilograms: _targetWeight,
      weeklyRateKilograms: rate.kilogramsPerWeek,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _BodyHero(
          icon: Icons.show_chart,
          title: 'SMOOTHED WEIGHT TREND',
          detail:
              'Separate daily scale noise from the underlying direction and compare seven-day windows.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Metric(
              label: 'TREND WEIGHT',
              value: trend.isEmpty
                  ? '${store.currentWeightKilograms.toStringAsFixed(1)}kg'
                  : '${trend.last.trendKilograms.toStringAsFixed(1)}kg',
              detail: trend.isEmpty ? 'PROFILE BASELINE' : 'EWMA',
            ),
            _Metric(
              label: 'WEEKLY RATE',
              value: rate.sampleDays == 0
                  ? '—'
                  : '${rate.kilogramsPerWeek >= 0 ? '+' : ''}${rate.kilogramsPerWeek.toStringAsFixed(2)}kg',
              detail: rate.label,
            ),
            _Metric(
              label: 'RATE %',
              value: rate.sampleDays == 0
                  ? '—'
                  : '${rate.percentPerWeek >= 0 ? '+' : ''}${rate.percentPerWeek.toStringAsFixed(2)}%',
              detail: 'PER WEEK',
            ),
          ],
        ),
        const SizedBox(height: 14),
        _WeightChart(points: trend),
        const SizedBox(height: 18),
        Text(
          'GOAL PROJECTION BANDS',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _DoubleSlider(
          label: 'TARGET WEIGHT',
          value: _targetWeight,
          minimum: 40,
          maximum: 180,
          onChanged: (value) => setState(() => _targetWeight = value),
        ),
        _ProjectionChart(projection: projection),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(
              '${projection.status} • ${projection.estimatedWeeks} estimated weeks',
            ),
            subtitle: Text(projection.assumption),
          ),
        ),
      ],
    );
  }

  Widget _measureTab(BuildContext context) {
    final reminder = BodyCompositionEngine.reminder(
      logs: store.bodyMeasurementLogs,
      now: DateTime.now(),
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _BodyHero(
          icon: Icons.straighten,
          title: 'WAIST & MULTI-SITE MEASUREMENTS',
          detail:
              'Use the same tape, time and posture. Waist is required; other sites are optional context.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MeasurementField(
              controller: _weight,
              label: 'WEIGHT',
              suffix: 'kg',
            ),
            _MeasurementField(controller: _waist, label: 'WAIST', suffix: 'cm'),
            _MeasurementField(controller: _neck, label: 'NECK', suffix: 'cm'),
            _MeasurementField(controller: _chest, label: 'CHEST', suffix: 'cm'),
            _MeasurementField(controller: _hips, label: 'HIPS', suffix: 'cm'),
            _MeasurementField(
              controller: _arm,
              label: 'UPPER ARM',
              suffix: 'cm',
            ),
            _MeasurementField(controller: _thigh, label: 'THIGH', suffix: 'cm'),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notes,
          maxLength: 160,
          decoration: const InputDecoration(
            labelText: 'OPTIONAL NOTES',
            hintText: 'Morning, relaxed waist, same tape…',
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _saving ? null : _saveMeasurement,
            icon: const Icon(Icons.save_outlined),
            label: const Text('SAVE MEASUREMENTS'),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${reminder.cadenceDays}d')),
            title: Text('MEASUREMENT REMINDER • ${reminder.status}'),
            subtitle: Text(
              '${reminder.daysRemaining} day(s) remaining. ${reminder.reason}',
            ),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.rule_outlined),
            title: Text('CONSISTENCY PROTOCOL'),
            subtitle: Text(
              'Measure in the morning, before food, at the same anatomical landmark, without pulling the tape tight.',
            ),
          ),
        ),
      ],
    );
  }

  Widget _compositionTab(BuildContext context) {
    final logs = store.bodyMeasurementLogs;
    final latest = logs.isEmpty
        ? null
        : ([...logs]..sort(
                (left, right) => right.recordedAt.compareTo(left.recordedAt),
              ))
              .first;
    final height = (store.profile?.heightCentimeters ?? 175).toDouble();
    final bodyFat = BodyCompositionEngine.bodyFatRange(
      weightKilograms: latest?.weightKilograms ?? 0,
      heightCentimeters: height,
      waistCentimeters: latest?.waistCentimeters ?? 0,
      neckCentimeters: latest?.neckCentimeters ?? 0,
      hipsCentimeters: latest?.hipsCentimeters ?? 0,
    );
    final lean = BodyCompositionEngine.leanMassTrend(
      logs: logs,
      heightCentimeters: height,
    );
    final waist = BodyCompositionEngine.measurementTrend(logs);
    final chest = BodyCompositionEngine.measurementTrend(logs, metric: 'chest');
    final arm = BodyCompositionEngine.measurementTrend(logs, metric: 'arm');
    final thigh = BodyCompositionEngine.measurementTrend(logs, metric: 'thigh');
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _BodyHero(
          icon: Icons.accessibility_new,
          title: 'BODY-COMPOSITION RANGE',
          detail:
              'Use broad estimate ranges and multi-site direction; no single tape formula is treated as ground truth.',
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Text(
                  bodyFat.centralPercent == 0
                      ? '—'
                      : '${bodyFat.minimumPercent.toStringAsFixed(1)}–${bodyFat.maximumPercent.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'BODY-FAT ESTIMATE • ${bodyFat.confidence}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                Text(
                  bodyFat.centralPercent == 0
                      ? 'Save weight and waist to create the first broad range.'
                      : '${bodyFat.label} • waist/height ${bodyFat.waistToHeightRatio.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.fitness_center),
            title: Text(
              lean.sampleSize == 0
                  ? 'LEAN-MASS TREND • NO DATA'
                  : 'LEAN-MASS TREND • ${lean.latestKilograms.toStringAsFixed(1)}KG',
            ),
            subtitle: Text(
              '${lean.label} • ${lean.changeKilograms >= 0 ? '+' : ''}${lean.changeKilograms.toStringAsFixed(1)}kg estimated change',
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'MULTI-SITE DIRECTION',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final item in [waist, chest, arm, thigh])
          Card(
            child: ListTile(
              title: Text(item.metric.toUpperCase()),
              subtitle: Text('${item.sampleSize} measurement(s)'),
              trailing: Text(
                item.sampleSize == 0
                    ? '—'
                    : '${item.latest.toStringAsFixed(1)}cm\n'
                          '${item.change >= 0 ? '+' : ''}${item.change.toStringAsFixed(1)}cm',
                textAlign: TextAlign.end,
              ),
            ),
          ),
        const Text(
          'This is a non-diagnostic estimate. Hydration, tape placement and formulas can materially change the result.',
          style: TextStyle(color: Colors.white54),
        ),
      ],
    );
  }

  Widget _reviewTab(BuildContext context) {
    final comparison = BodyCompositionEngine.photoComparison(
      store.progressPhotos,
    );
    final phase = store.nutritionPhaseLogs.isEmpty
        ? 'Maintenance'
        : store.nutritionPhaseLogs.first.phase;
    final calories = store.nutritionPhaseLogs.isEmpty
        ? store.nutritionTargets.calories
        : store.nutritionPhaseLogs.first.dailyCalories;
    final review = BodyCompositionEngine.calorieReview(
      phase: phase,
      currentCalories: calories,
      weights: store.data.weights,
      nutritionAdherence: store.weeklyMacroAdherence,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _BodyHero(
          icon: Icons.compare,
          title: 'PHOTO COMPARISON & CALORIE REVIEW',
          detail:
              'Compare the oldest and newest private photo, then review calories only from sufficient trend data.',
        ),
        const SizedBox(height: 14),
        if (!comparison.available)
          const Card(
            child: ListTile(
              leading: Icon(Icons.photo_library_outlined),
              title: Text('TWO PRIVATE PHOTOS NEEDED'),
              subtitle: Text(
                'Add progress photos in Media Hub to unlock side-by-side comparison.',
              ),
            ),
          )
        else
          Column(
            children: [
              SizedBox(
                height: 300,
                child: Row(
                  children: [
                    Expanded(
                      child: _PhotoFrame(
                        label: 'BEFORE',
                        encoded: comparison.before!.encodedBytes,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PhotoFrame(
                        label: 'AFTER',
                        encoded: comparison.after!.encodedBytes,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${comparison.daysBetween} days apart'
                '${comparison.weightChangeKilograms == null ? '' : ' • ${comparison.weightChangeKilograms! >= 0 ? '+' : ''}${comparison.weightChangeKilograms!.toStringAsFixed(1)}kg'}',
              ),
            ],
          ),
        const SizedBox(height: 18),
        Text(
          'PLATEAU-AWARE CALORIE REVIEW',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          color: review.adjustment == 0
              ? const Color(0xFF153C2D)
              : const Color(0xFF3D321E),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.status,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(review.reason),
                const Divider(height: 24),
                Text(
                  '${review.currentCalories} → ${review.suggestedCalories} kcal/day'
                  ' • ${review.adjustment >= 0 ? '+' : ''}${review.adjustment}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text('Review again after ${review.reviewAfterDays} days.'),
              ],
            ),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.no_photography_outlined),
            title: Text('PRIVATE & LOCAL'),
            subtitle: Text(
              'Comparison never uploads images. Photos remain behind the local vault controls.',
            ),
          ),
        ),
      ],
    );
  }
}

class _BodyHero extends StatelessWidget {
  const _BodyHero({
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
      gradient: const LinearGradient(
        colors: [Color(0xFF2B254A), Color(0xFF111820)],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.deepPurpleAccent.withValues(alpha: .3)),
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
    width: 180,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10)),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(detail, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    ),
  );
}

class _WeightChart extends StatelessWidget {
  const _WeightChart({required this.points});

  final List<SmoothedWeightPoint> points;

  @override
  Widget build(BuildContext context) {
    final sample = points.length > 20
        ? points.sublist(points.length - 20)
        : points;
    if (sample.isEmpty) {
      return const Card(
        child: SizedBox(
          height: 170,
          child: Center(child: Text('Log weights to draw the smoothed trend.')),
        ),
      );
    }
    final values = sample.map((item) => item.trendKilograms).toList();
    final minimum = values.reduce((a, b) => a < b ? a : b);
    final maximum = values.reduce((a, b) => a > b ? a : b);
    final span = mathMax(.2, maximum - minimum);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 170,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var index = 0; index < sample.length; index++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      height:
                          35 +
                          (sample[index].trendKilograms - minimum) / span * 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7E57C2),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(5),
                        ),
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

  static double mathMax(double left, double right) =>
      left > right ? left : right;
}

class _ProjectionChart extends StatelessWidget {
  const _ProjectionChart({required this.projection});

  final GoalProjectionBand projection;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 150,
        child: projection.points.isEmpty
            ? const Center(child: Text('Set a valid target.'))
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final point in projection.points)
                    Expanded(
                      child: Tooltip(
                        message:
                            'Week ${point.week}: ${point.lowerKilograms.toStringAsFixed(1)}–${point.upperKilograms.toStringAsFixed(1)}kg',
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height:
                              35 +
                              (point.centralKilograms -
                                          projection.points
                                              .map(
                                                (item) => item.centralKilograms,
                                              )
                                              .reduce((a, b) => a < b ? a : b))
                                      .abs() *
                                  18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF26A69A),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(5),
                            ),
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

class _DoubleSlider extends StatelessWidget {
  const _DoubleSlider({
    required this.label,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double minimum;
  final double maximum;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 10),
      Text(
        '$label • ${value.toStringAsFixed(1)}kg',
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      Slider(
        value: value.clamp(minimum, maximum),
        min: minimum,
        max: maximum,
        divisions: ((maximum - minimum) * 2).round(),
        onChanged: onChanged,
      ),
    ],
  );
}

class _MeasurementField extends StatelessWidget {
  const _MeasurementField({
    required this.controller,
    required this.label,
    required this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 180,
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, suffixText: suffix),
    ),
  );
}

class _PhotoFrame extends StatelessWidget {
  const _PhotoFrame({required this.label, required this.encoded});

  final String label;
  final String encoded;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(base64Decode(encoded), fit: BoxFit.cover),
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    ),
  );
}
