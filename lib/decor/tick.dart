import 'dart:ui' show lerpDouble;

import 'package:fcharts/fcharts.dart';
import 'package:fcharts/util/merge_tween.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// A tick located on a [ChartAxis].
class AxisTick implements MergeTweenable<AxisTick> {
  final double value;
  final double width;
  final List<TickLabeler> labelers;
  final double opacity;

  AxisTick({
    @required this.value,
    @required this.width,
    this.labelers: const [],
    this.opacity: 1.0
  });

  /// Draw this axis tick within its [tickArea] given an [axisPosition].
  void draw(CanvasArea tickArea, AxisPosition axisPosition) {
    for (final labeler in labelers)
      labeler.draw(tickArea, axisPosition, opacity);
  }

  @override
  AxisTick get empty => new AxisTick(
    value: value,
    width: width,
    labelers: labelers,
    opacity: 0.0
  );

  @override
  Tween<AxisTick> tweenTo(AxisTick other) => new AxisTickTween(this, other);
}

/// Lerp between two axis ticks.
class AxisTickTween extends Tween<AxisTick> {
  AxisTickTween(AxisTick begin, AxisTick end) : super(begin: begin, end: end);

  @override
  AxisTick lerp(double t) {
    double opacity;

    // fade to 0 at t=0.5, then to 1
    if (t < 0.5)
      opacity = lerpDouble(begin.opacity, 0.0, t * 2);
    else
      opacity = lerpDouble(0.0, end.opacity, (t - 0.5) * 2);

    return new AxisTick(
      value: lerpDouble(begin.value, end.value, t),
      width: lerpDouble(begin.width, end.width, t),
      labelers: t < 0.5 ? begin.labelers : end.labelers,
      opacity: opacity
    );
  }
}

abstract class TickLabeler {
  /// Draw this label in its [tickArea], given the [position] of the axis
  /// which this tick resides, and its [opacity] (used for animation).
  void draw(CanvasArea tickArea, AxisPosition position, double opacity);
}

class TextTickLabeler implements TickLabeler {
  /// The text to draw.
  final String text;

  /// The style of the text.
  final TextStyle style;

  /// An offset to apply to the text's position.
  final Offset offset;

  /// The rotation of the text in radians.
  final double rotation;

  /// The distance in canvas units from the axis.
  final double distance;

  TextTickLabeler({
    @required this.text,
    this.style: const TextStyle(color: Colors.black),
    this.offset: Offset.zero,
    this.rotation: 0.0,
    this.distance: 8.0,
  });

  _styleWithOpacity(double opacity) {
    return style.copyWith(
      color: (style.color ?? Colors.black).withOpacity(opacity)
    );
  }

  @override
  void draw(CanvasArea tickArea, AxisPosition position, double opacity) {
    var maxWidth = tickArea.width;
    double minWidth;
    Offset axisOffset;
    Offset shift;
    TextAlign align;

    switch (position) {
      case AxisPosition.top:
        minWidth = tickArea.width;
        axisOffset = new Offset(0.0, tickArea.height - distance);
        shift = new Offset(0.0, 1.0);
        align = TextAlign.center;
        break;
      case AxisPosition.left:
        minWidth = 0.0;
        maxWidth -= distance;
        axisOffset = new Offset(tickArea.width - distance, tickArea.height / 2);
        shift = new Offset(1.0, 0.5);
        align = TextAlign.right;
        break;
      case AxisPosition.right:
        minWidth = 0.0;
        maxWidth -= distance;
        axisOffset = new Offset(distance, tickArea.height / 2);
        shift = new Offset(0.0, 0.5);
        align = TextAlign.left;
        break;
      case AxisPosition.bottom:
        minWidth = tickArea.width;
        axisOffset = new Offset(0.0, distance);
        shift = Offset.zero;
        align = TextAlign.center;
        break;
      default:
        break;
    }

    final textOptions = new TextOptions(
      maxWidth: maxWidth,
      minWidth: minWidth,
      textAlign: align,
      style: _styleWithOpacity(opacity)
    );

    tickArea.drawText(offset + axisOffset, text,
      options: textOptions,
      shift: shift,
      rotation: rotation,
      rotationOrigin: new Offset(0.5, 0.5),
    );
  }
}

class NotchTickLabeler implements TickLabeler {
  final double length;
  final PaintOptions paint;

  NotchTickLabeler({
    this.length: 8.0,
    this.paint: const PaintOptions.stroke(),
  });

  PaintOptions _paintWithOpacity(double opacity) {
    return paint.copyWith(
      color: (paint.color ?? Colors.black).withOpacity(opacity)
    );
  }

  @override
  void draw(CanvasArea tickArea, AxisPosition position, double opacity) {
    Offset lineStart;
    Offset lineEnd;

    switch (position) {
      case AxisPosition.top:
        lineStart = new Offset(tickArea.width / 2, tickArea.height);
        lineEnd = lineStart.translate(0.0, -length);
        break;
      case AxisPosition.left:
        lineStart = new Offset(tickArea.width, tickArea.height / 2);
        lineEnd = lineStart.translate(-length, 0.0);
        break;
      case AxisPosition.right:
        lineStart = new Offset(0.0, tickArea.height / 2);
        lineEnd = lineStart.translate(length, 0.0);
        break;
      case AxisPosition.bottom:
        lineStart = new Offset(tickArea.width / 2, 0.0);
        lineEnd = lineStart.translate(0.0, length);
        break;
      default:
        break;
    }

    tickArea.drawLine(lineStart, lineEnd, _paintWithOpacity(opacity));
  }
}