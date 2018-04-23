import 'dart:ui' show lerpDouble;

import 'package:fcharts/src/utils/scale.dart';
import 'package:meta/meta.dart';

/// A generic typedef for a function that takes two types and returns another.
typedef SpanBase<T> SpanGenerator<T>(T min, T max);

abstract class SpanBase<T> {
  T get min;

  T get max;

  /// Get the position of a particular value in the format of a double.
  /// When value is [min], returns 0.0
  /// When value is [max], returns 1.0
  double toDouble(T value);

  T fromDouble(double value);
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

  @override
  DateTime fromDouble(double value) {
    final ms = (value * length.inMilliseconds).floor();
    return min.add(new Duration(milliseconds: ms));
  }
}

abstract class NumSpan<T extends num> implements SpanBase<T> {
  const NumSpan(this.min, this.max);

  final T min;

  final T max;

  num get length => max - min;

  DoubleSpan mapToScale(Scale scale) {
    return new DoubleSpan(
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

class IntSpan extends NumSpan<int> {
  IntSpan(int min, int max) : super(min, max);

  @override
  int fromDouble(double value) {
    final relative = value * length;
    return (min + relative).floor();
  }
}

/// A range from a low value to a high value.
@immutable
class DoubleSpan extends NumSpan<double> {
  DoubleSpan(double min, double max) : super(min, max);

  @override
  double fromDouble(double value) {
    final relative = value * length;
    return min + relative;
  }

  /// Linearly interpolate between two range values and a given time.
  static DoubleSpan lerp(DoubleSpan begin, DoubleSpan end, double t) {
    return new DoubleSpan(
      lerpDouble(begin.min, end.min, t),
      lerpDouble(begin.max, end.max, t),
    );
  }
}
