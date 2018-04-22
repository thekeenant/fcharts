import 'dart:ui' show lerpDouble;

import 'package:fcharts/src/utils/scale.dart';
import 'package:meta/meta.dart';


abstract class SpanBase<T> {
  T get min;

  T get max;

  /// Get the position of a particular value in the format of a double.
  /// When value is [min], returns 0.0
  /// When value is [max], returns 1.0
  double toDouble(T value);
}

class TimeSpan implements SpanBase<DateTime> {
  const TimeSpan(this.min, this.max);

  final DateTime min;

  final DateTime max;

  Duration get length => max.difference(min);

  @override
  double toDouble(DateTime value) {
    final durationSinceMin = value.difference(min);
    return durationSinceMin.inMilliseconds / length.inMilliseconds;
  }
}

class NumSpan<T extends num> implements SpanBase<T> {
  const NumSpan(this.min, this.max);

  final T min;

  final T max;

  num get length => max - min;

  Range mapToScale(Scale scale) {
    return new Range(
      scale.apply(min.toDouble()),
      scale.apply(max.toDouble()),
    );
  }

  @override
  double toDouble(num value) {
    final distToMin = value - min;
    return distToMin / length;
  }
}

/// A range from a low value to a high value.
@immutable
class Range extends NumSpan<double> {
  Range(double min, double max) : super(min, max);

  String toString() => "Span($min → $max)";

  /// Linearly interpolate between two range values and a given time.
  static Range lerp(Range begin, Range end, double t) {
    return new Range(
      lerpDouble(begin.min, end.min, t),
      lerpDouble(begin.max, end.max, t),
    );
  }
}
