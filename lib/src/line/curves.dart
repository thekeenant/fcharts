import 'dart:math';
import 'dart:ui';

import 'package:fcharts/src/utils/monotone_interpolator.dart';
import 'package:meta/meta.dart';

/// Generates a curve based on given points.
abstract class LineCurve {
  List<Offset> generate(List<Offset> points);
}

/// Some default curves without explicit configuration.
@immutable
class LineCurves {
  /// Go straight from one point to the next. No interpolation.
  static const linear = const Linear._();

  /// Default cardinal spline curve generator.
  static const cardinalSpline = const CardinalSpline();

  /// Default monotone cubic spline curve generator.
  static const monotone = const MonotoneCurve();
}

/// Use [LineCurves.linear].
/// Go straight from one point to the next. No interpolation.
@immutable
class Linear implements LineCurve {
  const Linear._();

  @override
  List<Offset> generate(List<Offset> points) {
    return points;
  }
}

/// Cardinal spline curve.
@immutable
class CardinalSpline implements LineCurve {
  const CardinalSpline({
    this.tension: 0.5,
    this.segmentCount: 10,
  })  : assert(tension != null && tension >= 0.0 && tension <= 1.0),
        assert(segmentCount != null && segmentCount > 0);

  final double tension;
  final int segmentCount;

  @override
  List<Offset> generate(List<Offset> points) {
    final result = <Offset>[];
    final pts = new List<Offset>.from(points);

    pts.insert(0, points[0]);
    pts.add(points[points.length - 1]);

    for (var i = 1; i < pts.length - 2; i++) {
      var t1 = new Offset(
          pts[i + 1].dx - pts[i - 1].dx, pts[i + 1].dy - pts[i - 1].dy);

      var t2 = new Offset(pts[i + 2].dx - pts[i].dx, pts[i + 2].dy - pts[i].dy);

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

/// Monotone cubic spline.
@immutable
class MonotoneCurve implements LineCurve {
  const MonotoneCurve({this.stepsPer: 20});

  /// The number of steps for each point given. A set of 3 points would
  /// generate 45 total interpolated points.
  final int stepsPer;

  @override
  List<Offset> generate(List<Offset> points) {
    if (points.length <= 1) return new List.from(points);

    final interpolator = new MonotoneInterpolator.fromPoints(points);
    final count = points.length * stepsPer;

    final firstX = points.first.dx;
    final lastX = points.last.dx;

    final step = (lastX - firstX) / count;
    
    if (step == 0) return points;

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
