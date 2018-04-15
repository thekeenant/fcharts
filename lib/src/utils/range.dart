import 'dart:ui' show lerpDouble;

import 'package:fcharts/src/utils/scale.dart';
import 'package:meta/meta.dart';

/// A range from a low value to a high value.
@immutable
class Range {
  const Range(this.min, this.max)
      : assert(min != null),
        assert(max != null),
        assert(min <= max);

  /// The low/min value.
  final double min;

  /// The high/max value.
  final double max;

  /// the distance between min and max
  double get span => max - min;

  Range mapToScale(Scale scale) {
    return new Range(
      scale.apply(min),
      scale.apply(max),
    );
  }

  /// Linearly interpolate between two range values and a given time.
  static Range lerp(Range begin, Range end, double t) {
    return new Range(
        lerpDouble(begin.min, end.min, t), lerpDouble(begin.max, end.max, t));
  }
}
