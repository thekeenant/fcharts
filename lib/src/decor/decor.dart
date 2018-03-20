import 'package:fcharts/src/decor/axis.dart';
import 'package:fcharts/src/decor/legend.dart';
import 'package:fcharts/src/painting.dart';
import 'package:fcharts/src/util/merge_tween.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// Decorations to apply to a [Chart].
@immutable
class ChartDecor {
  static const ChartDecor none = const ChartDecor();

  const ChartDecor({
    this.axes: const [],
    this.legend
  }) : assert(axes != null);

  final List<ChartAxis> axes;
  final Legend legend;

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

  Tween<ChartDecor> tweenTo(ChartDecor end) => new ChartDecorTween(this, end);
}

/// Lerp between two [ChartDecor]'s.
class ChartDecorTween extends Tween<ChartDecor> {
  ChartDecorTween(ChartDecor begin, ChartDecor end) :
      _axesTween = new MergeTween(begin.axes, end.axes),
      super(begin: begin, end: end);

  final MergeTween<ChartAxis> _axesTween;

  @override
  ChartDecor lerp(double t) {
    return new ChartDecor(
      axes: _axesTween.lerp(t),
    );
  }
}