import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'models/fitness_models.dart';

class WeightTrendChart extends StatelessWidget {
  const WeightTrendChart({super.key, required this.entries});

  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    final chronological = entries.take(12).toList().reversed.toList();
    return _ChartCard(
      title: 'Τάση σωματικού βάρους',
      subtitle: chronological.length < 2
          ? 'Χρειάζονται δύο καταχωρήσεις για να φανεί η τάση.'
          : 'Τελευταίες ${chronological.length} καταχωρήσεις',
      child: Semantics(
        label: chronological.isEmpty
            ? 'Δεν υπάρχουν δεδομένα βάρους.'
            : 'Γράφημα βάρους από '
                  '${chronological.first.kilograms.toStringAsFixed(1)} έως '
                  '${chronological.last.kilograms.toStringAsFixed(1)} κιλά.',
        child: SizedBox(
          height: 190,
          child: CustomPaint(
            painter: _WeightChartPainter(
              entries: chronological,
              lineColor: Theme.of(context).colorScheme.primary,
              gridColor: Colors.white.withValues(alpha: .1),
              labelColor: Colors.white.withValues(alpha: .58),
            ),
          ),
        ),
      ),
    );
  }
}

class TrainingLoadChart extends StatelessWidget {
  const TrainingLoadChart({super.key, required this.logs});

  final List<WorkoutLog> logs;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(
      7,
      (index) => DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - index)),
    );
    final volumes = <double>[];
    final setCounts = <double>[];
    for (final day in days) {
      final dayLogs = logs.where(
        (log) =>
            log.completedAt.year == day.year &&
            log.completedAt.month == day.month &&
            log.completedAt.day == day.day,
      );
      volumes.add(
        dayLogs.fold(
          0,
          (total, log) =>
              total + log.sets.fold<double>(0, (sum, set) => sum + set.volume),
        ),
      );
      setCounts.add(
        dayLogs.fold(0, (total, log) => total + log.sets.length).toDouble(),
      );
    }
    final hasVolume = volumes.any((value) => value > 0);
    final values = hasVolume ? volumes : setCounts;
    final total = values.fold<double>(0, (sum, value) => sum + value);
    final unit = hasVolume ? 'kg όγκου' : 'σετ';
    return _ChartCard(
      title: 'Φορτίο τελευταίων 7 ημερών',
      subtitle: '${_formatCompact(total)} $unit συνολικά',
      child: Semantics(
        label:
            'Ραβδόγραμμα προπονητικού φορτίου επτά ημερών. '
            'Σύνολο ${_formatCompact(total)} $unit.',
        child: SizedBox(
          height: 190,
          child: CustomPaint(
            painter: _LoadChartPainter(
              days: days,
              values: values,
              unit: unit,
              barColor: Theme.of(context).colorScheme.primary,
              gridColor: Colors.white.withValues(alpha: .1),
              labelColor: Colors.white.withValues(alpha: .58),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(color: Colors.white.withValues(alpha: .5)),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  const _WeightChartPainter({
    required this.entries,
    required this.lineColor,
    required this.gridColor,
    required this.labelColor,
  });

  final List<WeightEntry> entries;
  final Color lineColor;
  final Color gridColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 42.0;
    const right = 8.0;
    const top = 12.0;
    const bottom = 28.0;
    final plot = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    _drawHorizontalGrid(canvas, plot, gridColor);
    if (entries.isEmpty) {
      _drawCenteredLabel(canvas, plot, 'Χωρίς δεδομένα', labelColor);
      return;
    }

    var minWeight = entries.map((item) => item.kilograms).reduce(math.min);
    var maxWeight = entries.map((item) => item.kilograms).reduce(math.max);
    if ((maxWeight - minWeight).abs() < .5) {
      minWeight -= .5;
      maxWeight += .5;
    } else {
      final padding = (maxWeight - minWeight) * .15;
      minWeight -= padding;
      maxWeight += padding;
    }

    Offset pointFor(int index) {
      final x = entries.length == 1
          ? plot.center.dx
          : plot.left + plot.width * index / (entries.length - 1);
      final normalized =
          (entries[index].kilograms - minWeight) / (maxWeight - minWeight);
      return Offset(x, plot.bottom - plot.height * normalized);
    }

    final path = Path()..moveTo(pointFor(0).dx, pointFor(0).dy);
    for (var index = 1; index < entries.length; index++) {
      final point = pointFor(index);
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (var index = 0; index < entries.length; index++) {
      final point = pointFor(index);
      canvas.drawCircle(point, 4.5, Paint()..color = lineColor);
      canvas.drawCircle(point, 2, Paint()..color = const Color(0xFF080808));
    }

    _drawLabel(
      canvas,
      '${maxWeight.toStringAsFixed(1)} kg',
      Offset(0, plot.top - 3),
      labelColor,
    );
    _drawLabel(
      canvas,
      '${minWeight.toStringAsFixed(1)} kg',
      Offset(0, plot.bottom - 10),
      labelColor,
    );
    _drawLabel(
      canvas,
      _shortDate(entries.first.recordedAt),
      Offset(plot.left, plot.bottom + 8),
      labelColor,
    );
    final lastLabel = _textPainter(
      _shortDate(entries.last.recordedAt),
      labelColor,
    );
    lastLabel.paint(
      canvas,
      Offset(plot.right - lastLabel.width, plot.bottom + 8),
    );
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) =>
      oldDelegate.entries != entries;
}

class _LoadChartPainter extends CustomPainter {
  const _LoadChartPainter({
    required this.days,
    required this.values,
    required this.unit,
    required this.barColor,
    required this.gridColor,
    required this.labelColor,
  });

  final List<DateTime> days;
  final List<double> values;
  final String unit;
  final Color barColor;
  final Color gridColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 42.0;
    const right = 8.0;
    const top = 12.0;
    const bottom = 28.0;
    final plot = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    _drawHorizontalGrid(canvas, plot, gridColor);
    final maxValue = math
        .max(1.0, values.isEmpty ? 1 : values.reduce(math.max))
        .toDouble();
    final slotWidth = plot.width / 7;
    final barWidth = math.min(26.0, slotWidth * .58);
    for (var index = 0; index < 7; index++) {
      final value = values[index];
      final height = value == 0 ? 2.0 : plot.height * value / maxValue;
      final centerX = plot.left + slotWidth * (index + .5);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - barWidth / 2,
          plot.bottom - height,
          barWidth,
          height,
        ),
        const Radius.circular(5),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = value == 0
              ? gridColor
              : barColor.withValues(alpha: index == 6 ? 1 : .65),
      );
      final label = _textPainter(_dayInitial(days[index]), labelColor);
      label.paint(canvas, Offset(centerX - label.width / 2, plot.bottom + 8));
    }
    _drawLabel(
      canvas,
      _formatCompact(maxValue),
      Offset(0, plot.top - 3),
      labelColor,
    );
    _drawLabel(canvas, '0', Offset(28, plot.bottom - 10), labelColor);
  }

  @override
  bool shouldRepaint(covariant _LoadChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.unit != unit;
}

void _drawHorizontalGrid(Canvas canvas, Rect plot, Color color) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = 1;
  for (var index = 0; index <= 3; index++) {
    final y = plot.top + plot.height * index / 3;
    canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), paint);
  }
}

void _drawCenteredLabel(Canvas canvas, Rect plot, String text, Color color) {
  final painter = _textPainter(text, color);
  painter.paint(
    canvas,
    Offset(
      plot.center.dx - painter.width / 2,
      plot.center.dy - painter.height / 2,
    ),
  );
}

void _drawLabel(Canvas canvas, String text, Offset offset, Color color) {
  _textPainter(text, color).paint(canvas, offset);
}

TextPainter _textPainter(String text, Color color) {
  return TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: 11),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
}

String _dayInitial(DateTime date) {
  const labels = ['Δ', 'Τ', 'Τ', 'Π', 'Π', 'Σ', 'Κ'];
  return labels[date.weekday - 1];
}

String _shortDate(DateTime date) => '${date.day}/${date.month}';

String _formatCompact(double value) {
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}
