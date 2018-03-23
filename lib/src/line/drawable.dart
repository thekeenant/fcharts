import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:fcharts/src/chart_drawable.dart';
import 'package:fcharts/src/line/curves.dart';
import 'package:fcharts/src/utils/merge_tween.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

const clipPointPadding = 5.0;
const clipStrokePadding = 3.0;

class LineChartTouchEvent implements ChartTouchEvent {
  final int nearest;

  final int nearestHorizontally;

  LineChartTouchEvent(this.nearest, this.nearestHorizontally);

  @override
  String toString() {
    return 'LineChartTouchEvent($nearest, $nearestHorizontally)';
  }
}

/// A line chart is a set of points with (x, y) coordinates. A line
/// can connect the points and an area can be filled beneath the line.
/// Points can be illustrated by their own paint options.
class LineChartDrawable implements ChartDrawable<LineChartDrawable, LineChartTouchEvent> {
  LineChartDrawable({
    @required this.points,
    this.stroke: const PaintOptions.stroke(color: Colors.black),
    this.fill,
    this.curve: LineCurves.linear,
    this.bridgeNulls: false,
  }) : assert(bridgeNulls != null);

  /// The list of points (ascending x value).
  final List<LinePointDrawable> points;

  /// Paint to use to draw the line. Be sure to use [PaintingStyle.stroke].
  /// You can do this easily with [PaintOptions.stroke].
  final PaintOptions stroke;

  /// Paint to use to fill the area beneath the line.
  final PaintOptions fill;

  /// The method in which to interpolate the line in between points.
  /// See [Curves] for some default choices.
  final LineCurve curve;

  /// When true, the line is a continuous, single segment even if nulls
  /// are present. The gap is bridged between a null value.
  ///
  /// When false (default), null values create a break in the graph.
  final bool bridgeNulls;

  @override
  LineChartTouchEvent resolveTouch(Size area, Offset touch) {
    final scaledPoints = points.map((p) => p._locationWithin(area)).toList();

    int nearest;
    int nearestHoriz;
    double nearestDist = double.infinity;
    double nearestHorizDist = double.infinity;

    for (var i = 0; i < scaledPoints.length; i++) {
      final point = scaledPoints[i];
      final offset = point - touch;

      final d = (point - touch).distanceSquared;

      if (d < nearestDist) {
        nearest = i;
        nearestDist = d;
      }

      if (offset.dx.abs() < nearestHorizDist) {
        nearestHoriz = i;
        nearestHorizDist = offset.dx.abs();
      }
    }

    return new LineChartTouchEvent(nearest, nearestHoriz);
  }

  void _moveToLineTo(CanvasArea bounds, Path path, Offset point, {bool moveTo: false}) {
    var bounded = bounds.boundPoint(point);

    // todo? remove this
    bounded = point;

    if (moveTo) path.moveTo(bounded.dx, bounded.dy);
    path.lineTo(bounded.dx, bounded.dy);
  }

  /// get the top-, right-most point
  Offset _topRight(Offset a, Offset b) {
    // yes this is correct (y is inverted)
    return new Offset(math.max(a.dx, b.dx), math.min(a.dy, b.dy));
  }

  /// Generate the sequence of points based on any given curve.
  List<Offset> _curvePoints(List<Offset> points) {
    if (curve == null) return points;

    return curve.generate(points);
  }

  /// Create a list of paths which will each be drawn separately with their own
  /// line and fill area.
  ///
  /// This is necessary to support null values, which create a break in the line.
  /// A null value will create two segments, one on the left of it, one on the right
  /// (assuming it is not on the ends).
  List<List<LinePointDrawable>> _generateSegments() {
    final result = <List<LinePointDrawable>>[];
    if (points.isEmpty) return result;
    var current = <LinePointDrawable>[];
    points.forEach((point) {
      final value = point.value;
      if (value == null) {
        if (!bridgeNulls) {
          result.add(current);
          current = <LinePointDrawable>[];
        }
      } else {
        current.add(point);
      }
    });
    if (current.isNotEmpty) result.add(current);
    return result;
  }

  @override
  void draw(CanvasArea area) {
    if (points.isEmpty) return;

    final lineSegments = _generateSegments();

    // each segment gets its own paths
    for (final segment in lineSegments) {
      // create a new line
      final linePath = new Path();

      // create a new fill area
      final fillPath = new Path();

      // save points to their corresponding absolute location in the canvaa
      final pointToLoc = <LinePointDrawable, Offset>{};

      // scale points to the canvas
      final scaledPoints = segment.map((p) {
        final loc = p._locationWithin(area.size);
        pointToLoc[p] = loc;
        return loc;
      }).toList();

      // apply the curve to the scaled points
      final curvedPoints = _curvePoints(scaledPoints);

      // keep track if this is the first point
      var isFirst = true;

      // bounding box of fill area
      var leftMostX = double.INFINITY;
      var topRight = new Offset(-double.INFINITY, double.INFINITY);

      for (final loc in curvedPoints) {
        // if the first line, we move the fill path to the bottom left
        if (isFirst) fillPath.moveTo(loc.dx, area.height);

        // update bounding box of fill area
        leftMostX = math.min(leftMostX, loc.dx);
        topRight = _topRight(topRight, loc);

        // draw line to this point
        _moveToLineTo(area, linePath, loc, moveTo: isFirst);
        _moveToLineTo(area, fillPath, loc);

        isFirst = false;
      }

      // a rectangle covering the entire area of the line
      Rect lineRect = new Rect.fromPoints(new Offset(leftMostX, area.height), topRight);

      // finish off the fill area
      fillPath.lineTo(lineRect.bottomRight.dx, lineRect.bottomRight.dy);

      area.clipDrawing(() {
        // draw the fill (beneath the line)
        if (fill != null) area.drawPath(fillPath, fill, rect: lineRect);
        // draw the line
        if (stroke != null) area.drawPath(linePath, stroke, rect: lineRect);
      }, const EdgeInsets.all(clipStrokePadding));

      area.clipDrawing(() {
        // draw points
        for (final entry in pointToLoc.entries) {
          final point = entry.key;
          final loc = entry.value;
          final r = point.pointRadius;

          // create rectangle for arc
          final pointSquare = loc.translate(-r, -r) & new Size.fromRadius(r);
          final pointArea = area.child(pointSquare);

          // draw point given its arc rectangle
          point.draw(pointArea);
        }
      }, new EdgeInsets.all(clipPointPadding));
    }
  }

  @override
  _LineChartDrawableTween tweenTo(LineChartDrawable end) => new _LineChartDrawableTween(this, end);

  @override
  LineChartDrawable get empty => new LineChartDrawable(
        points: points.map((point) => point.copyWith(value: 0.0)).toList(),
        curve: curve,
        stroke: stroke,
        fill: fill,
        bridgeNulls: bridgeNulls,
      );
}

/// Lerp between two line charts.
class _LineChartDrawableTween extends Tween<LineChartDrawable> {
  _LineChartDrawableTween(LineChartDrawable begin, LineChartDrawable end)
      : _pointsTween = new MergeTween(begin.points, end.points),
        super(begin: begin, end: end);

  final MergeTween<LinePointDrawable> _pointsTween;

  @override
  LineChartDrawable lerp(double t) => new LineChartDrawable(
      points: _pointsTween.lerp(t),
      stroke: PaintOptions.lerp(begin.stroke, end.stroke, t),
      fill: PaintOptions.lerp(begin.fill, end.fill, t),
      curve: t < 0.5 ? begin.curve : end.curve,
      bridgeNulls: t < 0.5 ? begin.bridgeNulls : end.bridgeNulls);
}

/// A point on a line chart.
class LinePointDrawable implements MergeTweenable<LinePointDrawable> {
  LinePointDrawable({
    @required this.x,
    @required this.value,
    this.pointRadius: 3.0,
    this.paint: const [],
    this.collapsed,
  });

  /// The relative x value of this point. Should be 0..1 inclusive.
  final double x;

  /// The relative y value of this point. Should be 0..1 inclusive.
  final double value;

  /// Points can be illustrated by a circe on the graph. This indicates
  /// the radius of the point. Be sure to provide the point with [paint].
  final double pointRadius;

  /// All paint to be applied to the point.
  final List<PaintOptions> paint;

  /// Used for animation. This is the line point which this point should
  /// collapse to when it disappears, or when it comes from nothing.
  final LinePointDrawable collapsed;

  LinePointDrawable copyWith({
    double x,
    double value,
    double pointRadius,
    List<PaintOptions> paint,
    LinePointDrawable collapsed,
  }) {
    return new LinePointDrawable(
      x: x ?? this.x,
      value: value ?? this.value,
      pointRadius: pointRadius ?? this.pointRadius,
      paint: paint ?? this.paint,
      collapsed: collapsed ?? this.collapsed,
    );
  }

  /// Draw this point on the canvas within a given canvas area.
  void draw(CanvasArea pointArea) {
    for (final paint in this.paint) {
      pointArea.drawArc(Offset.zero & pointArea.size, 0.0, math.pi * 2, paint);
    }
  }

  /// Get the coordinates of this point witin a canvas area.
  Offset _locationWithin(Size size) {
    final width = size.width;
    final height = size.height;

    final actualX = x * width;
    final actualY = (1 - value) * height;

    return new Offset(actualX, actualY);
  }

  @override
  LinePointDrawable get empty {
    final collapsed = this.collapsed ?? collapse(this);
    // collapse the collapsed to itself
    return collapsed.copyWith(collapsed: collapsed);
  }

  @override
  Tween<LinePointDrawable> tweenTo(LinePointDrawable other) {
    return new _LinePointDrawableTween(this, other);
  }

  static LinePointDrawable collapse(LinePointDrawable point) {
    return new LinePointDrawable(x: 1.0, value: point.value);
  }
}

/// Lerp between two line points.
class _LinePointDrawableTween extends Tween<LinePointDrawable> {
  _LinePointDrawableTween(LinePointDrawable begin, LinePointDrawable end)
      : _paintsTween = new MergeTween(begin.paint, end.paint),
        super(begin: begin, end: end);

  final MergeTween<PaintOptions> _paintsTween;

  @override
  LinePointDrawable lerp(double t) => new LinePointDrawable(
        x: lerpDouble(begin.x, end.x, t),
        value: lerpDouble(begin.value, end.value, t),
        paint: _paintsTween.lerp(t),
        pointRadius: lerpDouble(begin.pointRadius, end.pointRadius, t),
        collapsed: end.collapsed,
      );
}
