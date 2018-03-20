import 'dart:math' as math;
import 'dart:ui';

import 'package:fcharts/line/drawable.dart';
import 'package:fcharts/util/charts.dart';
import 'package:fcharts/util/color_palette.dart';
import 'package:fcharts/util/curves.dart';
import 'package:fcharts/util/painting.dart';
import 'package:meta/meta.dart';

class LineChart implements Chart {
  final List<LinePoint> points;
  final Range range;
  final PaintOptions linePaint;
  final PaintOptions fillPaint;
  final LineCurveFunction curve;

  LineChart({
    @required this.points,
    @required this.range,
    this.linePaint: const PaintOptions.stroke(),
    this.fillPaint,
    this.curve: const CardinalSpline(),
  });
  
  factory LineChart.random(final int pointCount) {
    final random = new math.Random();

    final pointDistance = 1 / (pointCount - 1);

    var nextValue = 0.5;

    final baseColor = ColorPalette.primary.random(random);
    final monochrome = new ColorPalette.monochrome(baseColor, 4);
    final color = monochrome[0];

    final points = new List.generate(pointCount, (i) {
      final x = pointDistance * i;
      final value = nextValue;

      nextValue += (random.nextDouble() - 0.5) * 0.2;

      return new LinePoint(
        x: x,
        value: (value).clamp(0.0, 1.0).toDouble(),
        paint: [
          new PaintOptions(color: color)
        ],
      );
    });

    return new LineChart(
      points: points,
      linePaint: new PaintOptions.stroke(
        color: color,
        strokeWidth: 3.0,
        strokeCap: StrokeCap.round
      ),
      fillPaint: new PaintOptions(
        color: monochrome[3].withOpacity(0.4)
      ),
      range: new Range(0.0, 1.0)
    );
  }

  @override
  LineChartDrawable createDrawable() {
    final yOffset = range.min / range.span;

    final pointDrawables = points.map((point) {
      final x = point.x;
      final scaledValue = point.value / range.span - yOffset;

      return new LinePointDrawable(
        x: x,
        value: scaledValue,
        paint: point.paint,
        pointRadius: point.pointRadius
      );
    });

    return new LineChartDrawable(
      points: pointDrawables.toList(),
      curve: curve,
      linePaint: linePaint,
      fillPaint: fillPaint,
    );
  }
}


class LinePoint {
  final double x;
  final double value;
  final List<PaintOptions> paint;
  final double pointRadius;

  LinePoint({
    @required this.x,
    @required this.value,
    this.paint: const [],
    this.pointRadius: 1.0
  });
}