import 'dart:math';
import 'dart:ui';

import 'package:meta/meta.dart';

abstract class LineCurveFunction {
  List<Offset> generate(List<Offset> points);
}

/// Some default curves without explicit configuration.
class LineCurves {
  static const linear = const Linear._();

  static const cardinalSpline = const CardinalSpline();

  static const monotone = const MonotoneCurve();
}

/// Use Curves.linear
class Linear implements LineCurveFunction {
  const Linear._();

  @override
  List<Offset> generate(List<Offset> points) {
    return points;
  }
}

@immutable
class CardinalSpline implements LineCurveFunction {
  final double tension;
  final int segmentCount;

  const CardinalSpline({
    this.tension: 0.5,
    this.segmentCount: 10,
  }) :
      assert(tension != null && tension >= 0.0 && tension <= 1.0),
      assert(segmentCount != null && segmentCount > 0);

  @override
  List<Offset> generate(List<Offset> points) {
    final result = <Offset>[];
    final pts = new List<Offset>.from(points);

    pts.insert(0, points[0]);
    pts.add(points[points.length - 1]);

    for (var i = 1; i < pts.length - 2; i++) {
      var t1 = new Offset(
        pts[i + 1].dx - pts[i - 1].dx,
        pts[i + 1].dy - pts[i - 1].dy
      );

      var t2 = new Offset(
        pts[i + 2].dx - pts[i].dx,
        pts[i + 2].dy - pts[i].dy
      );

      t1 *= tension;
      t2 *= tension;

      for (var t = 0; t <= segmentCount; t++) {
        // steps
        final step = t / segmentCount;

        // cardinals
        final c1 = (2 * pow(step, 3) - 3 * pow(step, 2) + 1).toDouble();
        final c2 = (-(2 * pow(step, 3)) + 3 * pow(step, 2)).toDouble();
        final c3 = (pow(step, 3) - 2 * pow(step, 2) + step).toDouble();
        final c4 = (pow(step, 3) - pow(step, 2)).toDouble();

        // calc x and y cords with common control vectors
        final x = c1 * pts[i].dx + c2 * pts[i + 1].dx + c3 * t1.dx + c4 * t2.dx;
        final y = c1 * pts[i].dy + c2 * pts[i + 1].dy + c3 * t1.dy + c4 * t2.dy;

        //store points in array
        result.add(new Offset(x, y));
      }
    }
    return result;
  }
}

@immutable
class MonotoneCurve implements LineCurveFunction {
  final int stepsPer;

  const MonotoneCurve({this.stepsPer: 15});

  @override
  List<Offset> generate(List<Offset> points) {
    if (points.length <= 1)
      return new List.from(points);

    final interpolator = new _MonotoneInterpolator.fromPoints(points);
    final count = points.length * stepsPer;

    final firstX = points.first.dx;
    final lastX = points.last.dx;

    final step = (lastX - firstX) / count;

    final result = <Offset>[];
    for (var x = firstX; x <= lastX; x += step) {
      result.add(new Offset(x, interpolator.interpolate(x)));
    }

    // make sure we add the last point, just in case we didn't quite get to
    // it when incrementing by "step" above
    result.add(points.last);

    return result;
  }
}

/// https://gist.github.com/lecho/7627739
@immutable
class _MonotoneInterpolator {
  final List<Offset> _points;
  final List<double> _m;

  const _MonotoneInterpolator._(this._points, this._m);

  factory _MonotoneInterpolator.fromPoints(List<Offset> points, {bool sort: true}) {
    assert(points.isNotEmpty);

    if (sort)
      points.sort((a, b) => a.dx.compareTo(b.dx));

    final n = points.length;
    final d = new List<double>(n - 1); // could optimize this out
    final m = new List<double>(n);

    // Compute slopes of secant lines between successive points.
    for (int i = 0; i < n - 1; i++) {
      final h = points[i + 1].dx - points[i].dx;
      if (h <= 0) {
        throw new StateError("The control points must all have strictly increasing X values.");
      }
      d[i] = (points[i + 1].dy - points[i].dy) / h;
    }

    // Initialize the tangents as the average of the secants.
    m[0] = d[0];
    for (int i = 1; i < n - 1; i++) {
      m[i] = (d[i - 1] + d[i]) * 0.5;
    }
    m[n - 1] = d[n - 2];

    // Update the tangents to preserve monotonicity.
    for (int i = 0; i < n - 1; i++) {
      if (d[i] == 0) { // successive Y values are equal
        m[i] = 0.0;
        m[i + 1] = 0.0;
      } else {
        final a = m[i] / d[i];
        final b = m[i + 1] / d[i];
        final h = sqrt(pow(a, 2) + pow(b, 2));
        if (h > 9) {
          final t = 3 / h;
          m[i] = t * a * d[i];
          m[i + 1] = t * b * d[i];
        }
      }
    }
    return new _MonotoneInterpolator._(points, m);
  }

  double interpolate(double x) {

    // Handle the boundary cases.
    final int n = _points.length;
    if (x <= _points[0].dx) {
      return _points[0].dy;
    }
    if (x >= _points[n - 1].dx) {
      return _points[n - 1].dy;
    }

    // Find the index 'i' of the last point with smaller X.
    // We know this will be within the spline due to the boundary tests.
    int i = 0;
    while (x >= _points[i + 1].dx) {
      i += 1;
      if (x == _points[i].dx) {
        return _points[i].dy;
      }
    }

    // Perform cubic Hermite spline interpolation.
    final h = _points[i + 1].dx - _points[i].dx;
    final t = (x - _points[i].dx) / h;

    return (_points[i].dy * (1 + 2 * t) + h * _m[i] * t) * (1 - t) * (1 - t)
      + (_points[i + 1].dy * (3 - 2 * t) + h * _m[i + 1] * (t - 1)) * t * t;
  }
}
