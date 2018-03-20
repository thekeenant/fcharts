import 'package:fcharts/src/chart.dart';
import 'package:fcharts/src/line/curves.dart';
import 'package:fcharts/src/line/drawable.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/range.dart';
import 'package:meta/meta.dart';

class LineChartData implements ChartData {
  LineChartData({
    @required this.points,
    @required this.range,
    this.linePaint: const PaintOptions.stroke(),
    this.fillPaint,
    this.curve: const MonotoneCurve(),
  }) :
      assert(points != null),
      assert(range != null),
      assert(curve != null);

  /// The points for the line chart, in ascending x value.
  final List<LinePoint> points;

  /// The range for this chart.
  final Range range;

  /// The paint to use for the line.
  final PaintOptions linePaint;

  /// The paint to use to fill the area beneath the line.
  final PaintOptions fillPaint;

  /// The curve generator to smoothly interpolate between lines.
  /// See [LineCurves].
  final LineCurveGenerator curve;

  LineChartData copyWith({
    List<LinePoint> points,
    Range range,
    PaintOptions linePaint,
    PaintOptions fillPaint,
    LineCurveGenerator curve
  }) {
    return new LineChartData(
      points: points ?? this.points,
      range: range ?? this.range,
      linePaint: linePaint ?? this.linePaint,
      fillPaint: fillPaint ?? this.fillPaint,
      curve: curve ?? this.curve
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
  LinePoint({
    @required this.x,
    @required this.value,
    this.paint: const [],
    this.pointRadius: 1.0
  }) :
      assert(x != null & x >= 0 && x <= 1.0),
      assert(paint != null),
      assert(pointRadius != null);


  /// The x position of this point. Should be 0..1 inclusive.
  final double x;

  /// The value of this point, relative to the chart's range. It can be
  /// null to indicate no value present.
  final double value;
  final List<PaintOptions> paint;
  final double pointRadius;
}