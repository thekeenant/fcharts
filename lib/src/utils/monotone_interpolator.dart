import 'dart:math';
import 'dart:ui';

import 'package:meta/meta.dart';

/// Monotone cubic spline interpolation.
/// See: https://en.wikipedia.org/wiki/Monotone_cubic_interpolation
///
@immutable
class MonotoneInterpolator {
  const MonotoneInterpolator._(this.points, this._c1s, this._c2s, this._c3s);

  final List<Offset> points;
  final List<double> _c1s;
  final List<double> _c2s;
  final List<double> _c3s;

  factory MonotoneInterpolator.fromPoints(List<Offset> points) {
    assert(points.isNotEmpty);

    final n = points.length;

    final dxs = <double>[];
    final dys = <double>[];
    final ms = <double>[];

    // calculate differences and slopes
    for (var i = 0; i < n - 1; i++) {
      final dx = points[i + 1].dx - points[i].dx;
      final dy = points[i + 1].dy - points[i].dy;
      dxs.add(dx);
      dys.add(dy);
      ms.add(dy / dx);
    }

    // degrees 1, 2, and 3 coefficients
    final c1s = <double>[ms[0]];
    final c2s = <double>[];
    final c3s = <double>[];

    // calculate degree 1 coefficients
    for (var i = 0; i < dxs.length - 1; i++) {
      var m = ms[i];
      var mNext = ms[i + 1];
      if (m * mNext <= 0) {
        c1s.add(0.0);
      } else {
        var dx = dxs[i];
        var dxNext = dxs[i + 1];
        var common = dx + dxNext;
        c1s.add(3 * common / ((common + dxNext) / m + (common + dx) / mNext));
      }
    }
    c1s.add(ms[ms.length - 1]);

    // calculate degrees 2 and 3 coefficients
    for (var i = 0; i < c1s.length - 1; i++) {
      var c1 = c1s[i];
      var m = ms[i];
      var invDx = 1 / dxs[i];
      var common_ = c1 + c1s[i + 1] - m - m;
      c2s.add((m - c1 - common_) * invDx);
      c3s.add(common_ * invDx * invDx);
    }

    return new MonotoneInterpolator._(points, c1s, c2s, c3s);
  }

  double interpolate(double x) {
    // The rightmost point in the dataset should give an exact result
    var i = points.length - 1;
    if (x == points[i].dx) {
      return points[i].dy;
    }

    // Search for the interval x is in, returning the corresponding y if x is one of the original xs
    var low = 0;
    int mid;
    int high = _c3s.length - 1;

    while (low <= high) {
      mid = (0.5 * (low + high)).floor();
      var xHere = points[mid].dx;
      if (xHere < x) {
        low = mid + 1;
      } else if (xHere > x) {
        high = mid - 1;
      } else {
        return points[mid].dy;
      }
    }
    i = max(0, high);

    // Interpolate
    var diff = x - points[i].dx, diffSq = diff * diff;
    return points[i].dy +
        _c1s[i] * diff +
        _c2s[i] * diffSq +
        _c3s[i] * diff * diffSq;
  }
}
