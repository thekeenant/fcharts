import 'dart:ui' show lerpDouble;

import 'package:fcharts/src/decor/axis_data.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/merge_tween.dart';
import 'package:fcharts/src/utils/chart_position.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// A tick located on a [ChartAxis].
class AxisTick implements MergeTweenable<AxisTick> {
  AxisTick({
    @required this.value,
    @required this.width,
    this.labelers: const [
      const NotchTickLabeler()
    ],
    this.opacity: 1.0
  });

  /// The relative value of this tick. Should be 0..1 inclusive.
  /// A value of 0.25 means this tick falls at 25% the way up the axis.
  final double value;

  /// The relative width of this tick. Should be 0..1 inclusive.
  /// A width of 0.5 means this tick is 50% of the width of the axis.
  final double width;

  /// Labelers to use for this tick. They are drawn in the same order
  /// as the list.
  final List<TickLabeler> labelers;

  /// Draw this axis tick within its [tickArea] given an [side].
  void draw(CanvasArea tickArea, ChartPosition side) {
    for (final labeler in labelers)
      labeler.draw(tickArea, side);
  }

  @override
  AxisTick get empty => new AxisTick(
    value: value,
    width: width,
    labelers: labelers
  );

  @override
  Tween<AxisTick> tweenTo(AxisTick other) => new _AxisTickTween(this, other);
}

/// Lerp between two axis ticks.
class _AxisTickTween extends Tween<AxisTick> {
  _AxisTickTween(AxisTick begin, AxisTick end) : super(begin: begin, end: end);

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

/// Places a label on a tick.
abstract class TickLabeler<T extends TickLabeler<T>> extends MergeTweenable<T> {
  /// Draw this label in its [tickArea], given the [side] of the axis
  /// which this tick resides, and its [opacity] (used for animation).
  void draw(CanvasArea tickArea, ChartPosition side);

  @override
  Tween<T> tweenTo(T other) => new _TickLabelerTween<T>(this, other);
}

/// A basic implementation of a tick labeler tween.
class _TickLabelerTween<T extends TickLabeler<T>> extends Tween<T> {
  _TickLabelerTween(T begin, T end) : super(begin: begin, end: end);

  @override
  T lerp(double t) {
    return t < 0.5 ? begin : end;
  }
}

/// Text to place at the tick.
class TextTickLabeler extends TickLabeler<TextTickLabeler> {
  TextTickLabeler({
    @required this.text,
    this.style: const TextStyle(color: Colors.black),
    this.offset: Offset.zero,
    this.rotation: 0.0,
    this.distance: 10.0,
    this.opacity,
  });

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

  /// Opacity of the text.
  final double opacity;

  _styleWithOpacity(double opacity) {
    return style.copyWith(
      color: (style.color ?? Colors.black).withOpacity(opacity)
    );
  }

  @override
  void draw(CanvasArea tickArea, ChartPosition position) {
    double minWidth;

    switch (position) {
      case ChartPosition.top:
        minWidth = tickArea.width;
        break;
      case ChartPosition.left:
        minWidth = 0.0;
        break;
      case ChartPosition.right:
        minWidth = 0.0;
        break;
      case ChartPosition.bottom:
        minWidth = tickArea.width;
        break;
      default:
        break;
    }

    // Todo: Pass in rotation all the way down here?

    final textOptions = new TextOptions(
      minWidth: minWidth,
      textAlign: TextAlign.center,
      style: _styleWithOpacity(opacity)
    );

    tickArea.drawText(tickArea.center, text,
      shift: new Offset(0.5, 0.5),
      options: textOptions,
      rotation: rotation,
      rotationOrigin: new Offset(0.5, 0.5),
    );
  }

  @override
  TextTickLabeler get empty => new TextTickLabeler(
    text: text,
    style: style,
    offset: offset,
    rotation: rotation,
    distance: distance,
    opacity: 0.0
  );
}

/// A little line placed at the tick value, perpendiular to the axis.
@immutable
class NotchTickLabeler extends TickLabeler<NotchTickLabeler> {
  NotchTickLabeler({
    this.length: 5.0,
    this.paint: const PaintOptions.stroke(),
  });

  /// The length of the notch in the absolute units.
  final double length;

  /// The paint to use for this notch.
  final PaintOptions paint;

  PaintOptions _paintWithOpacity(double opacity) {
    return paint.copyWith(
      color: (paint.color ?? Colors.black).withOpacity(opacity)
    );
  }

  @override
  void draw(CanvasArea tickArea, ChartPosition position) {
    Offset lineStart;
    Offset lineEnd;

    switch (position) {
      case ChartPosition.top:
        lineStart = new Offset(tickArea.width / 2, tickArea.height);
        lineEnd = lineStart.translate(0.0, -length);
        break;
      case ChartPosition.left:
        lineStart = new Offset(tickArea.width, tickArea.height / 2);
        lineEnd = lineStart.translate(-length, 0.0);
        break;
      case ChartPosition.right:
        lineStart = new Offset(0.0, tickArea.height / 2);
        lineEnd = lineStart.translate(length, 0.0);
        break;
      case ChartPosition.bottom:
        lineStart = new Offset(tickArea.width / 2, 0.0);
        lineEnd = lineStart.translate(0.0, length);
        break;
      default:
        break;
    }

    // TODO: Opacity
    tickArea.drawLine(lineStart, lineEnd, _paintWithOpacity(1.0));
  }

  // TODO: implement empty
  @override
  NotchTickLabeler get empty => this;
}