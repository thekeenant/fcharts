import 'dart:ui' show lerpDouble;

import 'package:collection/collection.dart';
import 'package:fcharts/src/decor/axis.dart';
import 'package:fcharts/src/utils/chart_position.dart';
import 'package:fcharts/src/utils/merge_tween.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// A tick located on a [ChartAxisDrawable].
@immutable
class AxisTickDrawable implements MergeTweenable<AxisTickDrawable> {
  const AxisTickDrawable({
    @required this.value,
    @required this.width,
    this.labelers: const [const NotchTickLabeler()],
    this.opacity: 1.0,
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

  /// The opacity of the label. This is used for animation. The labelers
  /// should take the value into account.
  final double opacity;

  /// Draw this axis tick within its [tickArea] given an [side].
  void draw(CanvasArea tickArea, ChartPosition side) {
    for (final labeler in labelers) labeler.draw(tickArea, side, opacity);
  }

  @override
  AxisTickDrawable get empty => new AxisTickDrawable(
      value: value, width: width, labelers: labelers, opacity: 0.0);

  @override
  Tween<AxisTickDrawable> tweenTo(AxisTickDrawable other) =>
      new _AxisTickDataTween(this, other);
}

/// Lerp between two axis ticks.
class _AxisTickDataTween extends Tween<AxisTickDrawable> {
  _AxisTickDataTween(AxisTickDrawable begin, AxisTickDrawable end)
      : super(begin: begin, end: end) {
    final listsEqual = const ListEquality<TickLabeler>().equals;
    _labelersEqual = listsEqual(begin.labelers, end.labelers);
  }

  bool _labelersEqual;

  @override
  AxisTickDrawable lerp(double t) {
    double opacity = 1.0;

    if (!_labelersEqual) {
      // fade to 0 at t=0.5, then to 1
      if (t < 0.5)
        opacity = lerpDouble(begin.opacity, 0.0, t * 2);
      else
        opacity = lerpDouble(0.0, end.opacity, (t - 0.5) * 2);
    }

    return new AxisTickDrawable(
        value: lerpDouble(begin.value, end.value, t),
        width: lerpDouble(begin.width, end.width, t),
        labelers: t < 0.5 ? begin.labelers : end.labelers,
        opacity: opacity);
  }
}

/// Places a label on a tick.
abstract class TickLabeler {
  /// Draw this label in its [tickArea], given the [side] of the axis
  /// which this tick resides, and its [opacity] (used for animation).
  void draw(CanvasArea tickArea, ChartPosition side, double opacity);

  @override
  operator ==(dynamic o);

  @override
  int get hashCode;
}

/// Text to place at the tick.
@immutable
class TextTickLabeler implements TickLabeler {
  const TextTickLabeler({
    @required this.text,
    this.style: const TextStyle(color: Colors.black),
    this.offset: Offset.zero,
    this.rotation: 0.0,
    this.distance: 8.0,
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

  TextStyle _styleWithOpacity(double opacity) {
    return style.copyWith(
      color: (style.color ?? Colors.black).withOpacity(opacity),
    );
  }

  @override
  bool operator ==(dynamic o) {
    if (o is TextTickLabeler) {
      return text == o.text &&
          style == o.style &&
          offset == o.offset &&
          rotation == o.rotation &&
          distance == o.distance;
    }
    return false;
  }

  @override
  int get hashCode {
    // TODO
    throw new UnimplementedError();
  }

  @override
  void draw(CanvasArea tickArea, ChartPosition position, double opacity) {
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
        style: _styleWithOpacity(opacity));

    tickArea.drawText(
      tickArea.center,
      text,
      shift: new Offset(0.5, 0.5),
      options: textOptions,
      rotation: rotation,
      rotationOrigin: new Offset(0.5, 0.5),
    );
  }
}

/// A little line placed at the tick value, perpendicular to the axis.
@immutable
class NotchTickLabeler implements TickLabeler {
  const NotchTickLabeler({
    this.length: 5.0,
    this.paint: const PaintOptions.stroke(),
    this.begin: 0.0,
  });

  /// The length of the notch in the absolute units.
  final double length;

  /// The paint to use for this notch.
  final PaintOptions paint;

  /// Offset where the line begins. For example you could set [begin]
  /// to `-5.0` and [length] to `10.0` to have a notch which extends
  /// equally on both sides of the axis because it is a line which goes
  /// from -5 to 5 (length 10).
  final double begin;

  PaintOptions _paintWithOpacity(double opacity) {
    return paint.copyWith(
      color: (paint.color ?? Colors.black).withOpacity(opacity),
    );
  }

  @override
  bool operator ==(dynamic o) {
    return o is NotchTickLabeler &&
        length == o.length &&
        paint == o.paint &&
        begin == o.begin;
  }

  @override
  int get hashCode {
    // TODO
    throw new UnimplementedError();
  }

  @override
  void draw(CanvasArea tickArea, ChartPosition position, double opacity) {
    Offset lineStart;
    double lineX = 0.0;
    double lineY = 0.0;

    switch (position) {
      case ChartPosition.top:
        // starts at center and goes up
        lineStart = new Offset(tickArea.width / 2, tickArea.height + begin);
        lineY = -length;
        break;
      case ChartPosition.left:
        // start at center vertically and go left
        lineStart = new Offset(tickArea.width + begin, tickArea.height / 2);
        lineX = -length;
        break;
      case ChartPosition.right:
        // start at middle vertically and go right
        lineStart = new Offset(-begin, tickArea.height / 2);
        lineX = length;
        break;
      case ChartPosition.bottom:
        // start at center and down
        lineStart = new Offset(tickArea.width / 2, -begin);
        lineY = length;
        break;
      default:
        break;
    }

    // draw the line from start to end
    tickArea.drawLine(
      lineStart,
      lineStart.translate(lineX, lineY),
      _paintWithOpacity(opacity),
    );
  }
}
