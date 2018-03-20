import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:fcharts/util/painting.dart';
import 'package:meta/meta.dart';

/// Collapse [object] into nothing.
typedef T Collapser<T>(T object);

abstract class Chart {
  /// Create a drawable chart from this chart, something that can be drawn
  /// within a [CanvasArea].
  ChartDrawable createDrawable();
}

/// The rotation of a chart.
@immutable
class ChartRotation {
  /// rotated 0 degrees
  static const none = const ChartRotation._(0.0);
  /// rotated 180 degrees
  static const upsideDown = const ChartRotation._(math.pi);
  /// rotated 90 degrees clockwise
  static const clockwise = const ChartRotation._(math.pi / 2);
  /// rotated 90 degrees counter clockwise (270 clockwise)
  static const counterClockwise = const ChartRotation._(-math.pi / 2);

  /// The rotation in radians.
  final double theta;

  const ChartRotation._(this.theta);
}

/// A range from a low value to a high value.
@immutable
class Range {
  final double min;
  final double max;

  const Range(this.min, this.max) :
    assert(min != null),
    assert(max != null),
    assert(min < max);

  /// the distance between min and max
  double get span => (max - min).abs();

  /// Linearly interpolate between two range values and a given time, [t].
  static Range lerp(Range begin, Range end, double t) {
    return new Range(
      lerpDouble(begin.min, end.min, t),
      lerpDouble(begin.max, end.max, t)
    );
  }
}