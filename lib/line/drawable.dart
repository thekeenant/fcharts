import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:fcharts/util/curves.dart';
import 'package:fcharts/util/painting.dart';
import 'package:fcharts/util/merge_tween.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class LineChartDrawableTween extends ChartDrawableTween<LineChartDrawable> {
  final MergeTween<LinePointDrawable> _pointsTween;

  LineChartDrawableTween(LineChartDrawable begin, LineChartDrawable end) :
    _pointsTween = new MergeTween(begin.points, end.points),
    super(begin: begin, end: end);

  @override
  LineChartDrawable lerp(double t) => new LineChartDrawable(
    points: _pointsTween.lerp(t),
    linePaint: PaintOptions.lerp(begin.linePaint, end.linePaint, t),
    fillPaint: PaintOptions.lerp(begin.fillPaint, end.fillPaint, t),
    curve: t < 0.5 ? begin.curve : end.curve
  );
}

class LineChartDrawable implements ChartDrawable<LineChartDrawable> {
  final List<LinePointDrawable> points;

  final PaintOptions linePaint;

  final PaintOptions fillPaint;

  final LineCurveFunction curve;

  /// When true, the line is a continuous, single segment even if nulls
  /// are present. The gap is bridged between a null value.
  ///
  /// When false (default), null values create a break in the graph.
  final bool bridgeNulls;

  LineChartDrawable({
    @required this.points,
    this.linePaint: const PaintOptions.stroke(color: Colors.black),
    this.fillPaint,
    this.curve,
    this.bridgeNulls: false
  }) : assert(bridgeNulls != null);

  void _moveToLineTo(Path path, Offset point, {bool moveTo: false}) {
    if (moveTo)
      path.moveTo(point.dx, point.dy);
    path.lineTo(point.dx, point.dy);
  }

  /// get the top-, right-most point
  Offset _topRight(Offset a, Offset b) {
    // yes this is correct (y is inverted)
    return new Offset(math.max(a.dx, b.dx), math.min(a.dy, b.dy));
  }

  List<Offset> _curvePoints(List<Offset> points) {
    if (curve == null)
      return points;
    return curve.generate(points);
  }

  List<List<LinePointDrawable>> _generateSegments() {
    final result = <List<LinePointDrawable>>[];
    if (points.isEmpty)
      return result;
    var current = <LinePointDrawable>[];
    points.forEach((point) {
      final value = point.value;
      if (value == null) {
        if (!bridgeNulls) {
          result.add(current);
          current = <LinePointDrawable>[];
        }
      }
      else {
        current.add(point);
      }
    });
    result.add(current);
    return result;
  }

  @override
  void draw(CanvasArea area) {
    if (points.isEmpty)
      return;

    final lineSegments = _generateSegments();

    for (final segment in lineSegments) {
      final linePath = new Path();
      final fillPath = new Path();

      var leftMostX = double.INFINITY;
      var topRight = new Offset(-double.INFINITY, double.INFINITY);

      final pointToLoc = <LinePointDrawable, Offset>{};
      final scaledPoints = segment.map((p) {
        final loc = p.locationWithin(area);
        pointToLoc[p] = loc;
        return loc;
      }).toList();
      final curvedPoints = _curvePoints(scaledPoints);

      var isFirst = true;
      for (final loc in curvedPoints) {
        if (isFirst)
          fillPath.moveTo(loc.dx, area.height);

        leftMostX = math.min(leftMostX, loc.dx);
        topRight = _topRight(topRight, loc);

        _moveToLineTo(linePath, loc, moveTo: isFirst);
        _moveToLineTo(fillPath, loc);

        isFirst = false;
      }

      // a rectangle covering the entire area of the line
      Rect lineRect = new Rect.fromPoints(
        new Offset(leftMostX, area.height),
        topRight
      );

      // finish off the fill area
      fillPath.lineTo(lineRect.bottomRight.dx, lineRect.bottomRight.dy);

      // draw the fill (beneath the line)
      if (fillPaint != null)
        area.drawPath(fillPath, fillPaint, rect: lineRect);

      // draw the line
      if (linePaint != null)
        area.drawPath(linePath, linePaint, rect: lineRect);

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
    }
  }

  @override
  LineChartDrawableTween tweenTo(LineChartDrawable end) =>
    new LineChartDrawableTween(this, end);

  @override
  LineChartDrawable get empty => new LineChartDrawable(
    points: points.map((point) => point.copyWith(value: 0.0)).toList(),
    curve: curve,
    linePaint: linePaint,
    fillPaint: fillPaint,
    bridgeNulls: bridgeNulls
  );
}


class LinePointDrawable implements MergeTweenable<LinePointDrawable> {
  static LinePointDrawable collapse(LinePointDrawable point) {
    return new LinePointDrawable(
      x: 1.0,
      value: point.value
    );
  }

  final double x;
  final double value;
  final double pointRadius;
  final List<PaintOptions> paint;
  final LinePointDrawable collapsed;

  LinePointDrawable({
    @required this.x,
    @required this.value,
    this.pointRadius: 1.0,
    this.paint: const [],
    this.collapsed
  });

  LinePointDrawable copyWith({
    double x,
    double value,
    double pointRadius,
    List<PaintOptions> paint,
    LinePointDrawable collapsed
  }) {
    return new LinePointDrawable(
      x: x ?? this.x,
      value: value ?? this.value,
      pointRadius: pointRadius ?? this.pointRadius,
      paint: paint ?? this.paint,
      collapsed: collapsed ?? this.collapsed
    );
  }

  void draw(CanvasArea area) {
    for (final paint in this.paint) {
      area.drawArc(
        Offset.zero & area.size,
        0.0,
        math.pi * 2,
        paint
      );
    }
  }

  Offset locationWithin(CanvasArea area) {
    final width = area.width;
    final height = area.height;

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
    return new LinePointDrawableTween(this, other);
  }
}

class LinePointDrawableTween extends Tween<LinePointDrawable> {
  final MergeTween<PaintOptions> _paintsTween;

  LinePointDrawableTween(LinePointDrawable begin, LinePointDrawable end) :
    _paintsTween = new MergeTween(begin.paint, end.paint),
    super(begin: begin, end: end);

  @override
  LinePointDrawable lerp(double t) => new LinePointDrawable(
    x: lerpDouble(begin.x, end.x, t),
    value: lerpDouble(begin.value, end.value, t),
    paint: _paintsTween.lerp(t),
    pointRadius: lerpDouble(begin.pointRadius, end.pointRadius, t),
    collapsed: end.collapsed,
  );
}