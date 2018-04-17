import 'dart:ui' show lerpDouble;

import 'package:fcharts/src/utils/scale.dart';
import 'package:meta/meta.dart';

/// A range from a low value to a high value.
@immutable
class Span {
  const Span(this.min, this.max)
      : assert(min != null),
        assert(max != null);

  /// The low/min value.
  final double min;

  /// The high/max value.
  final double max;

  /// the distance between min and max
  double get length => max - min;

  Span mapToScale(Scale scale) {
    return new Span(
      scale.apply(min),
      scale.apply(max),
    );
  }

  String toString() => "Span($min → $max)";

  /// Linearly interpolate between two range values and a given time.
  static Span lerp(Span begin, Span end, double t) {
    return new Span(
      lerpDouble(begin.min, end.min, t),
      lerpDouble(begin.max, end.max, t),
    );
  }
}
