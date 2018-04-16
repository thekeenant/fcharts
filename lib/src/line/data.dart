import 'package:fcharts/src/chart_data.dart';
import 'package:fcharts/src/line/curves.dart';
import 'package:fcharts/src/line/drawable.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/span.dart';
import 'package:meta/meta.dart';

/// A type of chart where a group of points are connected by a line.
@immutable
class LineChartData implements ChartData {
  const LineChartData({
    @required this.points,
    @required this.range,
    @required this.domain,
    this.stroke: const PaintOptions.stroke(),
    this.fill,
    this.curve: const MonotoneCurve(),
  })  : assert(points != null),
        assert(range != null),
        assert(curve != null);

  /// The points for the line chart, in ascending x value.
  final List<LinePointData> points;

  /// The range for this chart.
  final Span range;

  /// The domain for this chart.
  final Span domain;

  /// The paint to use for the line.
  final PaintOptions stroke;

  /// The paint to use to fill the area beneath the line.
  final PaintOptions fill;

  /// The curve generator to smoothly interpolate between lines.
  /// See [LineCurves].
  final LineCurve curve;

  LineChartData copyWith({
    List<LinePointData> points,
    Span range,
    PaintOptions stroke,
    PaintOptions fill,
    LineCurve curve,
  }) {
    return new LineChartData(
      points: points ?? this.points,
      range: range ?? this.range,
      stroke: stroke ?? this.stroke,
      fill: fill ?? this.fill,
      curve: curve ?? this.curve,
    );
  }

  @override
  LineChartDrawable createDrawable() {
    final xOffset = domain.min / domain.length;
    final yOffset = range.min / range.length;

    final pointDrawables = points.map((point) {
      final scaledX = point.x / domain.length - xOffset;
      final scaledY =
          point.y == null ? null : point.y / range.length - yOffset;

      return new LinePointDrawable(
        x: scaledX,
        value: scaledY,
        paint: point.paint,
        radius: point.radius,
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
@immutable
class LinePointData {
  const LinePointData({
    @required this.x,
    @required this.y,
    this.paint: const [],
    this.radius: 1.0,
  })  : assert(x != null),
        assert(paint != null),
        assert(radius != null);

  /// The x position of this point, relative to the chart's domain.
  final double x;

  /// The y position of this point, relative to the chart's range. It can be
  /// null to indicate no value present.
  final double y;

  final List<PaintOptions> paint;
  final double radius;
}
