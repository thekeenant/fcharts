import 'package:fcharts/src/bar/bar_chart.dart';
import 'package:fcharts/src/bar/bar_graph.dart';
import 'package:fcharts/src/bar/histogram.dart';
import 'package:fcharts/src/line/drawable.dart';
import 'package:fcharts/src/util/chart.dart';
import 'package:fcharts/src/util/curves.dart';
import 'package:fcharts/src/util/merge_tween.dart';
import 'package:fcharts/src/util/painting.dart';
import 'package:meta/meta.dart';

/// A special type of line charh which aligns itself with the x values
/// of a [Histogram]'s bins or a [BarChart]'s groups.
class BarLineChart implements Chart {
  final BarGraph barGraph;
  final List<_BarLinePoint> points;
  final Range range;
  final PaintOptions linePaint;
  final PaintOptions fillPaint;
  final LineCurveFunction curve;
  final Collapser<LinePointDrawable> collapser;

  BarLineChart._({
    @required this.barGraph,
    @required this.points,
    @required this.range,
    this.curve: const MonotoneCurve(),
    this.linePaint: const PaintOptions.stroke(),
    this.fillPaint,
    this.collapser
  });

  // TODO
  // factory BarLineChart.fromBarChart(BarChart barChart) 
  //   return null;
  // }

  factory BarLineChart.fromHistogram(Histogram histogram, {
    List<PaintOptions> pointPaint: const [],
    double pointRadius: 3.0,
    LineCurveFunction curve: const MonotoneCurve(),
    PaintOptions linePaint: const PaintOptions.stroke(),
    PaintOptions fillPaint,
  }) {
    return new BarLineChart._(
      barGraph: histogram,
      points: new List.generate(histogram.bins.length, (i) {
        return new _BarLinePoint(
          value: histogram.bins[i].value,
          paint: pointPaint,
          pointRadius: pointRadius,
        );
      }),
      range: histogram.range,
      curve: curve,
      linePaint: linePaint,
      fillPaint: fillPaint,
    );
  }

  @override
  LineChartDrawable createDrawable() {
    final xValues = barGraph.scaledXValues();
    assert(xValues.length == points.length);

    final yOffset = range.min / range.span;

    var i = 0;
    final pointDrawables = points.map((point) {
      final x = xValues[i];
      final scaledValue = point.value == null ? null : point.value / range.span - yOffset;

      final pointDrawable = new LinePointDrawable(
        x: x,
        value: scaledValue,
        paint: point.paint,
        pointRadius: point.pointRadius,
      );

      final collapsed = this.collapser == null ?
        new LinePointDrawable(x: xValues.last, value: scaledValue) :
        this.collapser(pointDrawable);

      i++;
      return pointDrawable.copyWith(collapsed: collapsed);
    });

    return new LineChartDrawable(
      points: pointDrawables.toList(),
      curve: curve,
      linePaint: linePaint,
      fillPaint: fillPaint
    );
  }
}

/// A point on a bar line chart. It's x position is determined by the bar graph.
class _BarLinePoint {
  final double value;
  final List<PaintOptions> paint;
  final double pointRadius;

  _BarLinePoint({
    @required this.value,
    this.paint: const [],
    this.pointRadius: 1.0
  });
}