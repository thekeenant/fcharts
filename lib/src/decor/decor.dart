import 'package:fcharts/src/chart_data.dart';
import 'package:fcharts/src/decor/axis.dart';
import 'package:fcharts/src/decor/legend.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/merge_tween.dart';
import 'package:fcharts/src/utils/chart_position.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// Decorations to apply to a chart.
@immutable
class ChartDecor {
  static const ChartDecor none = const ChartDecor();

  const ChartDecor({
    this.axes: const [],
    this.legend
  }) : assert(axes != null);

  /// List of axes to draw around the chart. If two axes have the same
  /// [ChartPosition], they are drawn from the center of the chart outward in
  /// the order of the list.
  ///
  /// For example, if axes is A,B,C and all are on the left side, A will be
  /// drawn to the right of B, B will be to the right of C. C will be the
  /// furthest left, and away from the graph. A gets priority!
  final List<ChartAxisData> axes;

  /// A legend for the chart.
  final LegendData legend;

  void draw(CanvasArea fullArea, CanvasArea chartArea) {
    // organize axes by their position
    final axesByPos = <ChartPosition, List<ChartAxisData>>{};
    for (final axis in axes) {
      axesByPos.putIfAbsent(axis.position, () => []);
      axesByPos[axis.position].add(axis);
    }

    for (final axisGroup in axesByPos.values) {
      for (var i = 0; i < axisGroup.length; i++) {
        axisGroup[i].draw(fullArea, chartArea, i, axisGroup.length);
      }
    }

    legend?.draw(fullArea, chartArea);
  }

  Tween<ChartDecor> tweenTo(ChartDecor end) => new ChartDecorTween(this, end);
}

/// Lerp between two [ChartDecor]'s.
class ChartDecorTween extends Tween<ChartDecor> {
  ChartDecorTween(ChartDecor begin, ChartDecor end) :
      _axesTween = new MergeTween(begin.axes, end.axes),
      super(begin: begin, end: end);

  final MergeTween<ChartAxisData> _axesTween;

  @override
  ChartDecor lerp(double t) {
    return new ChartDecor(
      axes: _axesTween.lerp(t),
      legend: t < 0.5 ? begin.legend : end.legend
    );
  }
}