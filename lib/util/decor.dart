import 'dart:ui' show lerpDouble;

import 'package:fcharts/util/charts.dart';
import 'package:fcharts/util/painting.dart';
import 'package:fcharts/util/merge_tween.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';


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

class ChartDecor {
  final List<ChartAxis> axes;
  final Legend legend;

  ChartDecor({
    this.axes: const [],
    this.legend
  });

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


class Legend {

}

class SimpleTickLabeler implements TickLabeler {
  final String text;
  final TextStyle textStyle;
  final double notchLength;
  final PaintOptions notchPaint;
  final Offset offset;
  final double rotation;

  SimpleTickLabeler({
    @required this.text,
    this.textStyle: const TextStyle(color: Colors.black),
    this.notchLength: 8.0,
    this.notchPaint: const PaintOptions.stroke(),
    this.offset: Offset.zero,
    this.rotation: 0.0,
  });

  @override
  void draw(CanvasArea tickArea, AxisPosition position, double opacity) {
    var width = tickArea.width;
    var minWidth = tickArea.width;
    var offset = new Offset(0.0, notchLength);
    var shift = Offset.zero;
    var align = TextAlign.center;

    var lineStart = new Offset(tickArea.width / 2, 0.0);
    var lineEnd = lineStart.translate(0.0, notchLength);

    switch (position) {
      case AxisPosition.top:
        offset = new Offset(0.0, tickArea.height - notchLength);
        shift = new Offset(0.0, 1.0);
        lineStart = new Offset(tickArea.width / 2, tickArea.height);
        lineEnd = lineStart.translate(0.0, -notchLength);
        break;
      case AxisPosition.left:
        minWidth = 0.0;
        offset = new Offset(tickArea.width - notchLength, tickArea.height / 2);
        shift = new Offset(1.0, 0.5);
        align = TextAlign.right;
        lineStart = new Offset(tickArea.width, tickArea.height / 2);
        lineEnd = lineStart.translate(-notchLength, 0.0);
        width -= notchLength;
        break;
      case AxisPosition.right:
        minWidth = 0.0;
        offset = new Offset(notchLength, tickArea.height / 2);
        shift = new Offset(0.0, 0.5);
        align = TextAlign.left;
        lineStart = offset.translate(0.0, 0.0);
        lineEnd = lineStart.translate(-notchLength, 0.0);
        width -= notchLength;
        break;
      default:
        break;
    }

    tickArea.drawLine(lineStart, lineEnd, new PaintOptions.stroke(
      color: Colors.black.withOpacity(opacity)
    ));

    tickArea.drawText(this.offset + offset, text,
      options: new TextOptions(
        maxWidth: width,
        minWidth: minWidth,
        textAlign: align,
        style: textStyle.copyWith(
          color: textStyle.color.withOpacity(opacity)
        )
      ),
      shift: shift,
      rotation: rotation,
      rotationOrigin: new Offset(0.5, 0.5),
    );
  }
}

abstract class TickLabeler {
  void draw(CanvasArea tickArea, AxisPosition position, double opacity);
}

enum AxisPosition {
  top,
  left,
  right,
  bottom
}

class AxisTick implements MergeTweenable<AxisTick> {
  final double value;
  final double width;
  final TickLabeler labeler;
  final double opacity;

  AxisTick({
    @required this.value,
    @required this.width,
    this.labeler,
    this.opacity: 1.0
  });

  void draw(CanvasArea tickArea, AxisPosition axisPosition) {
    if (labeler != null)
      labeler.draw(tickArea, axisPosition, opacity);
  }

  @override
  AxisTick get empty => new AxisTick(
    value: value,
    width: width,
    labeler: labeler,
    opacity: 0.0
  );

  @override
  Tween<AxisTick> tweenTo(AxisTick other) => new AxisTickTween(this, other);
}

class AxisTickTween extends Tween<AxisTick> {
  AxisTickTween(AxisTick begin, AxisTick end) : super(begin: begin, end: end);

  @override
  AxisTick lerp(double t) {
    // fade to 0.0 at t = 0.5
    double opacity = 1.0;

    if (t < 0.5)
      opacity = lerpDouble(begin.opacity, 0.0, t * 2);
    else
      opacity = lerpDouble(0.0, end.opacity, (t - 0.5) * 2);

    return new AxisTick(
      value: lerpDouble(begin.value, end.value, t),
      width: lerpDouble(begin.width, end.width, t),
      labeler: t < 0.5 ? begin.labeler : end.labeler,
      opacity: opacity
    );
  }
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