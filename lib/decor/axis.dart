import 'package:fcharts/decor/tick.dart';
import 'package:fcharts/util/merge_tween.dart';
import 'package:fcharts/util/painting.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';


enum AxisPosition {
  top,
  left,
  right,
  bottom
}

class ChartAxis implements MergeTweenable<ChartAxis> {
  final List<AxisTick> ticks;
  final AxisPosition position;
  final PaintOptions paint;

  ChartAxis({
    @required this.position,
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
      final tickCenter = vertical ? (1 - tick.value) : tick.value;
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
    ticks: ticks.map((tick) => tick.empty).toList(),
    paint: paint,
  );

  @override
  Tween<ChartAxis> tweenTo(ChartAxis other) => new _ChartAxisTween(this, other);
}

class _ChartAxisTween extends Tween<ChartAxis> {
  final MergeTween<AxisTick> _ticksTween;

  _ChartAxisTween(ChartAxis begin, ChartAxis end) :
    _ticksTween = new MergeTween(begin.ticks, end.ticks),
    super(begin: begin, end: end);

  @override
  ChartAxis lerp(double t) {
    return new ChartAxis(
      position: t < 0.5 ? begin.position : end.position,
      ticks: _ticksTween.lerp(t),
      paint: PaintOptions.lerp(begin.paint, end.paint, t),
    );
  }
}