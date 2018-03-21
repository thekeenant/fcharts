import 'package:fcharts/src/chart_data.dart';
import 'package:fcharts/src/line/curves.dart';
import 'package:fcharts/src/line/drawable.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/range.dart';
import 'package:meta/meta.dart';

/// A type of chart where a group of points are connected by a line.
class LineChartData implements ChartData {
  LineChartData({
    @required this.points,
    @required this.range,
    this.stroke: const PaintOptions.stroke(),
    this.fill,
    this.curve: const MonotoneCurve(),
  }) :
      assert(points != null),
      assert(range != null),
      assert(curve != null);

  /// The points for the line chart, in ascending x value.
  final List<LinePointData> points;

  /// The range for this chart.
  final Range range;

  /// The paint to use for the line.
  final PaintOptions stroke;

  /// The paint to use to fill the area beneath the line.
  final PaintOptions fill;

  /// The curve generator to smoothly interpolate between lines.
  /// See [LineCurves].
  final LineCurve curve;

  LineChartData copyWith({
    List<LinePointData> points,
    Range range,
    PaintOptions stroke,
    PaintOptions fill,
    LineCurve curve
  }) {
    return new LineChartData(
      points: points ?? this.points,
      range: range ?? this.range,
      stroke: stroke ?? this.stroke,
      fill: fill ?? this.fill,
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
        pointRadius: point.radius
      );
    });

    return new LineChartDrawable(
      points: pointDrawables.toList(),
      curve: curve,
      stroke: stroke,
      fill: fill,
    );
  }
}

/// A point on a line chart.
class LinePointData {
  LinePointData({
    @required this.x,
    @required this.value,
    this.paint: const [],
    this.radius: 1.0
  }) :
      assert(x != null && x >= 0 && x <= 1.0),
      assert(paint != null),
      assert(radius != null);


  /// The x position of this point. Should be 0..1 inclusive.
  final double x;

  /// The value of this point, relative to the chart's range. It can be
  /// null to indicate no value present.
  final double value;
  final List<PaintOptions> paint;
  final double radius;
}