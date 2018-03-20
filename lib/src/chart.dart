import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:fcharts/src/util/merge_tween.dart';
import 'package:fcharts/src/painting.dart';
import 'package:meta/meta.dart';

/// Contains data for creating a drawable chart.
abstract class ChartData {
  /// Create a [ChartDrawable] from this chart
  ChartDrawable createDrawable();
}

/// A chart which can be drawn within a [CanvasArea].
abstract class ChartDrawable<T extends ChartDrawable<T>> extends MergeTweenable<T> {
  /// Draw the chart within a [CanvasArea]. It should scale according
  /// to the width and height of the area.
  void draw(CanvasArea area);
}

/// A side of the chart/a possible position of a [ChartAxis].
enum ChartSide {
  /// The top of the chart.
  top,

  /// The left of the chart (y-axis).
  left,

  /// The right of the chart.
  right,

  /// The bottom of the chart (x-axis).
  bottom
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
  const Range(this.min, this.max) :
      assert(min != null),
      assert(max != null),
      assert(min <= max);

  /// The low/min value.
  final double min;

  /// The high/max value.
  final double max;

  /// the distance between min and max
  double get span => (max - min).abs();

  /// Linearly interpolate between two range values and a given time.
  static Range lerp(Range begin, Range end, double t) {
    return new Range(
      lerpDouble(begin.min, end.min, t),
      lerpDouble(begin.max, end.max, t)
    );
  }
}