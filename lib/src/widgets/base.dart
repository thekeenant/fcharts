import 'package:fcharts/src/decor/axis.dart';
import 'package:fcharts/src/decor/tick.dart';
import 'package:fcharts/src/utils/chart_position.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/span.dart';
import 'package:fcharts/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

abstract class Chart extends StatefulWidget {
  const Chart({Key key}) : super(key: key);
}

abstract class ContinuousTickGenerator<T> {
  List<T> generate(SpanBase<T> span);
}

abstract class CategoricalTickGenerator<T> {
  List<T> generate(List<T> categories);
}

/// Generates ticks for a continuous measure based on a given interval.
@immutable
class IntervalTickGenerator<T> implements ContinuousTickGenerator<T> {
  const IntervalTickGenerator({
    @required this.increment,
    @required this.comparator,
  });

  static IntervalTickGenerator<T> byN<T extends num>(T n) {
    return new IntervalTickGenerator<T>(
      increment: (a) => a + n,
      comparator: (a, b) => a.compareTo(b),
    );
  }

  static IntervalTickGenerator<DateTime> byDuration(Duration interval) {
    return new IntervalTickGenerator<DateTime>(
      increment: (a) => a.add(interval),
      comparator: (a, b) => a.compareTo(b),
    );
  }

  /// The increment function. For each interval this will be called on the
  /// current value.
  final UnaryFunction<T, T> increment;

  /// The method used to compare with the maximum value to ensure we are
  /// within the range of the values.
  final Comparator<T> comparator;

  @override
  List<T> generate(SpanBase<T> span) {
    final result = <T>[];
    var curr = span.min;

    while (comparator(curr, span.max) <= 0) {
      result.add(curr);
      curr = increment(curr);
    }

    return result;
  }
}

/// Generates a fixed number of ticks including the minimum and maximum
/// if possible.
@immutable
class AutoContinuousTickGenerator<T> implements ContinuousTickGenerator<T> {
  const AutoContinuousTickGenerator({
    @required this.tickCount,
  });

  /// The number of ticks.
  final int tickCount;

  @override
  List<T> generate(SpanBase<T> span) {
    // return nothing
    if (tickCount == 0) return const [];

    // just return the middle value
    if (tickCount == 1) return [span.fromDouble(0.5)];

    return new List.generate(tickCount, (i) {
      final percent = i / (tickCount - 1);
      return span.fromDouble(percent);
    });
  }
}

/// Generates ticks based on all the categories present in the data provided.
@immutable
class AutoCategoricalTickGenerator<T> implements CategoricalTickGenerator<T> {
  const AutoCategoricalTickGenerator();

  @override
  List<T> generate(List<T> categories) => categories;
}

/// Generates ticks based on the ones provided.
@immutable
class FixedContinuousTickGenerator<T> implements ContinuousTickGenerator<T> {
  FixedContinuousTickGenerator(this.ticks);

  final List<T> ticks;

  @override
  List<T> generate(SpanBase<T> span) => ticks;
}

/// Generates ticks based on the ones provided.
@immutable
class FixedCategoricalTickGenerator<T> implements CategoricalTickGenerator<T> {
  FixedCategoricalTickGenerator(this.ticks);

  final List<T> ticks;

  @override
  List<T> generate(List<T> categories) => ticks;
}

/// Places a type of object on a scale from 0 to 1.
abstract class Measure<T> {
  List<T> generateTicks();

  /// Get the position within 0 to 1 of a value.
  double position(T value);
}

@immutable
class ContinuousMeasure<T> implements Measure<T> {
  ContinuousMeasure({
    @required this.span,
    ContinuousTickGenerator<T> tickGenerator,
  }) : this.tickGenerator =
            tickGenerator ?? new AutoContinuousTickGenerator<T>(tickCount: 5);

  final SpanBase<T> span;

  final ContinuousTickGenerator<T> tickGenerator;

  @override
  double position(T value) => span.toDouble(value);

  @override
  List<T> generateTicks() {
    return tickGenerator.generate(span);
  }
}

@immutable
class CategoricalMeasure<T> implements Measure<T> {
  CategoricalMeasure({
    @required this.categories,
    CategoricalTickGenerator<T> tickGenerator,
  }) : this.tickGenerator =
            tickGenerator ?? new AutoCategoricalTickGenerator<T>();

  final List<T> categories;

  final CategoricalTickGenerator<T> tickGenerator;

  @override
  double position(T value) {
    final ticks = generateCategoricalTicks(categories.length);
    return ticks[categories.indexOf(value)];
  }

  @override
  List<T> generateTicks() {
    return tickGenerator.generate(categories);
  }
}

@immutable
abstract class AxisBase<Value, M extends Measure<Value>> {
  static String defaultTickLabelFn<V>(V value) => value.toString();

  const AxisBase({
    @required this.measure,
    @required this.tickLabelFn,
    @required this.opposite,
    @required this.size,
    @required this.offset,
    @required this.paint,
  });

  final M measure;

  final UnaryFunction<Value, String> tickLabelFn;

  final bool opposite;

  final double size;

  final double offset;

  final PaintOptions paint;

  ChartAxisData generateAxisData(ChartPosition position) {
    final tickData = generateAxisTicks();

    return new ChartAxisData(
      ticks: tickData,
      position: position,
      size: size,
      offset: offset,
      paint: paint,
    );
  }

  List<AxisTickData> generateAxisTicks() {
    final ticks = measure.generateTicks();

    return new List.generate(ticks.length, (i) {
      final tick = ticks[i];
      final pos = measure.position(tick);

      final label = (tickLabelFn ?? defaultTickLabelFn)(tick);

      return new AxisTickData(
        value: pos,
        width: 1 / ticks.length,
        labelers: [
          new NotchTickLabeler(
            paint: paint,
          ),
          new TextTickLabeler(text: label),
        ],
      );
    });
  }
}

/// An axis which maps data points to continuous values.
///
/// Time, amounts, and percentages are examples of continuous values.
@immutable
class ContinuousAxis<Value> extends AxisBase<Value, ContinuousMeasure<Value>> {
  ContinuousAxis({
    ContinuousMeasure<Value> measure,
    UnaryFunction<Value, String> tickLabelFn,
    bool opposite: false,
    double size: null,
    double offset: 0.0,
    PaintOptions paint: const PaintOptions.stroke(color: Colors.black),
  }) : super(
          measure: measure,
          tickLabelFn: tickLabelFn,
          opposite: opposite,
          size: size,
          offset: offset,
          paint: paint,
        );
}

/// An axis which categorizes data points into discrete values.
///
/// For example, someone's first name is either "John" or not "John". There is no in-between
/// "John" and "Adam".
@immutable
class CategoricalAxis<Category>
    extends AxisBase<Category, CategoricalMeasure<Category>> {
  CategoricalAxis({
    CategoricalMeasure<Category> measure,
    UnaryFunction<Category, String> tickLabelFn,
    bool opposite: false,
    double size: null,
    double offset: 0.0,
    PaintOptions paint: const PaintOptions.stroke(color: Colors.black),
  }) : super(
          measure: measure,
          tickLabelFn: tickLabelFn,
          opposite: opposite,
          size: size,
          offset: offset,
          paint: paint,
        );
}
