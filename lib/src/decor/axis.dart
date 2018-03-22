import 'package:fcharts/src/decor/tick.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/merge_tween.dart';
import 'package:fcharts/src/utils/chart_position.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// An axis of a chart.
@immutable
class ChartAxisData implements MergeTweenable<ChartAxisData> {
  ChartAxisData({
    @required this.position,
    this.ticks: const [],
    this.paint: const PaintOptions.stroke(),
    this.size: 1.0,
    this.offset,
  });

  /// All the ticks which will be drawn along this axis.
  final List<AxisTickData> ticks;

  /// The position of the axis - which side it will be placed.
  final ChartPosition position;

  /// The paint options for this axis' line.
  final PaintOptions paint;

  final double size;

  /// TODO: when null, default to 1-size?
  final double offset;

  void draw(CanvasArea fullArea, CanvasArea chartArea) {
    Rect axisRect;

    final paddingTop = chartArea.rect.top - fullArea.rect.top;
    final paddingLeft = chartArea.rect.left - fullArea.rect.left;
    final paddingRight = fullArea.rect.right - chartArea.rect.right;
    final paddingBottom = fullArea.rect.bottom - chartArea.rect.bottom;

    var vertical = false;

    Offset lineStart;
    Offset lineEnd;

    final actualOffset = this.offset == null ? 1 - size : this.offset;

    switch (position) {
      case ChartPosition.top:
        axisRect = new Offset(paddingLeft, 0.0) & new Size(
          chartArea.width,
          paddingTop * size
        );
        lineStart = axisRect.bottomLeft;
        lineEnd = axisRect.bottomRight;
        break;
      case ChartPosition.left:
        vertical = true;
        axisRect = new Offset(actualOffset * paddingLeft, paddingTop) & new Size(
          paddingLeft * size,
          chartArea.height
        );
        lineStart = axisRect.bottomRight;
        lineEnd = axisRect.topRight;
        break;
      case ChartPosition.right:
        vertical = true;
        axisRect = chartArea.rect.topRight.translate(0.0, 0.0) & new Size(
          paddingRight * size,
          chartArea.height
        );
        lineStart = axisRect.bottomLeft;
        lineEnd = axisRect.topLeft;
        break;
      case ChartPosition.bottom:
        axisRect = chartArea.rect.bottomLeft.translate(0.0, 0.0) & new Size(
          chartArea.width,
          paddingBottom * size
        );
        lineStart = axisRect.topLeft;
        lineEnd = axisRect.topRight;
        break;
      default:
        break;
    }

    if (paint != null)
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

  @override
  ChartAxisData get empty => new ChartAxisData(
    position: position,
    ticks: ticks.map((tick) => tick.empty).toList(),
    paint: paint,
    size: size,
    offset: offset
  );

  @override
  Tween<ChartAxisData> tweenTo(ChartAxisData other) => new _ChartAxisDataTween(this, other);
}

/// Lerp between two [ChartAxisData]'s.
class _ChartAxisDataTween extends Tween<ChartAxisData> {
  _ChartAxisDataTween(ChartAxisData begin, ChartAxisData end) :
    _ticksTween = new MergeTween(begin.ticks, end.ticks),
    super(begin: begin, end: end);

  final MergeTween<AxisTickData> _ticksTween;

  @override
  ChartAxisData lerp(double t) {
    return new ChartAxisData(
      position: t < 0.5 ? begin.position : end.position,
      ticks: _ticksTween.lerp(t),
      paint: PaintOptions.lerp(begin.paint, end.paint, t),
      size: t < 0.5 ? begin.size : end.size,
      offset: t < 0.5 ? begin.offset : end.offset
    );
  }
}