import 'package:fcharts/src/decor/axis.dart';
import 'package:fcharts/src/util/merge_tween.dart';
import 'package:fcharts/src/util/painting.dart';
import 'package:flutter/material.dart';

/// Deccorations to apply to a [Chart].
class ChartDecor {
  final List<ChartAxis> axes;
  final Legend legend;

  ChartDecor({
    this.axes: const [],
    this.legend
  }) : assert(axes != null);

  void draw(CanvasArea fullArea, CanvasArea chartArea) {
    // organize axes by their position
    final axesByPos = <AxisPosition, List<ChartAxis>>{};
    for (final axis in axes) {
      axesByPos.putIfAbsent(axis.position, () => []);
      axesByPos[axis.position].add(axis);
    }

    for (final axisGroup in axesByPos.values) {
      for (var i = 0; i < axisGroup.length; i++) {
        axisGroup[i].draw(fullArea, chartArea, i, axisGroup.length);
      }
    }
  }
}

/// Lerp between two [ChartDecor]'s.
class ChartDecorTween extends Tween<ChartDecor> {
  final MergeTween<ChartAxis> _axesTween;

  ChartDecorTween(ChartDecor begin, ChartDecor end) :
    _axesTween = new MergeTween(begin.axes, end.axes),
    super(begin: begin, end: end);

  @override
  ChartDecor lerp(double t) {
    return new ChartDecor(
      axes: _axesTween.lerp(t),
    );
  }
}

/// A legend.
class Legend {
  final List<LegendItem> items;

  Legend({this.items});
  // Todo
}

class LegendItem {

}