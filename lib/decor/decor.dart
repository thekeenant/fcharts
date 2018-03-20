import 'dart:ui' show lerpDouble;

import 'package:fcharts/decor/tick.dart';
import 'package:fcharts/util/charts.dart';
import 'package:fcharts/util/painting.dart';
import 'package:fcharts/util/merge_tween.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class ChartDecor {
  final List<ChartAxis> axes;
  final Legend legend;

  ChartDecor({
    this.axes: const [],
    this.legend
  }) : assert(axes != null);

  void draw(CanvasArea fullArea, CanvasArea chartArea) {
    // organize axes by their position
    final byPosition = <AxisPosition, List<ChartAxis>>{};
    for (final axis in axes) {
      byPosition.putIfAbsent(axis.position, () => []);
      byPosition[axis.position].add(axis);
    }

    for (final axisGroup in byPosition.values) {
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
  // Todo
}


enum AxisPosition {
  top,
  left,
  right,
  bottom
}

class ChartAxis implements MergeTweenable<ChartAxis> {
  final List<AxisTick> ticks;
  final Range range;
  final AxisPosition position;
  final PaintOptions paint;

  ChartAxis({
    @required this.position,
    @required this.range,
    this.ticks: const [],
    this.paint: const PaintOptions.stroke()
  });

  void draw(CanvasArea fullArea, CanvasArea chartArea, int rank, int rankTotal) {
    Rect axisRect;

    final paddingTop = chartArea.rect.top - fullArea.rect.top;
    final paddingLeft = chartArea.rect.left - fullArea.rect.left;
    final paddingRight = fullArea.rect.right - chartArea.rect.right;
    final paddingBottom = fullArea.rect.bottom - chartArea.rect.bottom;

    var vertical = false;

    Offset lineStart;
    Offset lineEnd;

    var rankFactor = (rankTotal - rank - 1) / rankTotal;

    switch (position) {
      case AxisPosition.top:
        axisRect = new Offset(paddingLeft, rankFactor * paddingTop) & new Size(
          chartArea.width,
          paddingTop / rankTotal
        );
        lineStart = axisRect.bottomLeft;
        lineEnd = axisRect.bottomRight;
        break;
      case AxisPosition.left:
        vertical = true;
        axisRect = new Offset(rankFactor * paddingLeft, paddingTop) & new Size(
          paddingLeft / rankTotal,
          chartArea.height
        );
        lineStart = axisRect.bottomRight;
        lineEnd = axisRect.topRight;
        break;
      case AxisPosition.right:
        vertical = true;
        axisRect = chartArea.rect.topRight.translate(rankFactor * paddingRight, 0.0) & new Size(
          paddingRight / rankTotal,
          chartArea.height
        );
        lineStart = axisRect.bottomLeft;
        lineEnd = axisRect.topLeft;
        break;
      case AxisPosition.bottom:
        axisRect = chartArea.rect.bottomLeft.translate(0.0, rankFactor * paddingBottom) & new Size(
          chartArea.width,
          paddingBottom / rankTotal
        );
        lineStart = axisRect.topLeft;
        lineEnd = axisRect.topRight;
        break;
      default:
        break;
    }

    fullArea.drawLine(lineStart, lineEnd, paint);

    CanvasArea axisArea = fullArea.child(axisRect);

    final primary = vertical ? axisArea.height : axisArea.width;
    final secondary = vertical ? axisArea.width : axisArea.height;

    for (var tick in ticks) {
      final relativeOffset = range.min / range.span;
      final relativeValue = tick.value / range.span - relativeOffset;

      final tickCenter = vertical ? (1 - relativeValue) : relativeValue;

      final tickPosition = (tickCenter  - tick.width / 2) * primary;
      final tickAreaSize = tick.width * primary;

      Rect tickRect;

      if (vertical) {
        tickRect = new Rect.fromLTWH(
          0.0,
          tickPosition,
          secondary,
          tickAreaSize
        );
      }
      else {
        tickRect = new Rect.fromLTWH(
          tickPosition,
          0.0,
          tickAreaSize,
          secondary
        );
      }

      tick.draw(axisArea.child(tickRect), position);
    }
  }

  // TODO: implement empty
  @override
  ChartAxis get empty => new ChartAxis(
    position: position,
    range: range,
    ticks: ticks.map((tick) => tick.empty).toList(),
    paint: paint,
  );

  @override
  Tween<ChartAxis> tweenTo(ChartAxis other) => new ChartAxisTween(this, other);
}

class ChartAxisTween extends Tween<ChartAxis> {
  final MergeTween<AxisTick> _ticksTween;

  ChartAxisTween(ChartAxis begin, ChartAxis end) :
    _ticksTween = new MergeTween(begin.ticks, end.ticks),
    super(begin: begin, end: end);

  @override
  ChartAxis lerp(double t) {
    return new ChartAxis(
      position: t < 0.5 ? begin.position : end.position,
      range: Range.lerp(begin.range, end.range, t),
      ticks: _ticksTween.lerp(t),
      paint: PaintOptions.lerp(begin.paint, end.paint, t),
    );
  }
}