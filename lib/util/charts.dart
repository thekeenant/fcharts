import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:fcharts/util/painting.dart';
import 'package:meta/meta.dart';

typedef T Collapser<T>(T object);


abstract class Chart {
  ChartDrawable createDrawable();
}

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

  final double amount;

  const ChartRotation._(this.amount);
}

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

  static Range lerp(Range begin, Range end, double t) {
    return new Range(
      lerpDouble(begin.min, end.min, t),
      lerpDouble(begin.max, end.max, t)
    );
  }
}