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

class IntervalTickGenerator<T> implements ContinuousTickGenerator<T> {
  const IntervalTickGenerator({this.increment, this.comparator});

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

  final UnaryFunction<T, T> increment;

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

class AutoContinuousTickGenerator<T extends num>
    implements ContinuousTickGenerator<T> {
  const AutoContinuousTickGenerator({
    @required this.tickCount,
  });

  final int tickCount;

  @override
  List<T> generate(SpanBase<T> span) {
    return new List.generate(tickCount, (i) {
      final percent = i / (tickCount - 1);
      return span.fromDouble(percent);
    });
  }
}

class AutoCategoricalTickGenerator<T> implements CategoricalTickGenerator<T> {
  const AutoCategoricalTickGenerator();

  @override
  List<T> generate(List<T> categories) => categories;
}

class FixedContinuousTickGenerator<T> implements ContinuousTickGenerator<T> {
  FixedContinuousTickGenerator(this.list);

  final List<T> list;

  @override
  List<T> generate(SpanBase<T> span) => list;
}

class FixedCategoricalTickGenerator<T> implements CategoricalTickGenerator<T> {
  FixedCategoricalTickGenerator(this.list);

  final List<T> list;

  @override
  List<T> generate(List<T> categories) => list;
}

abstract class Measure<T> {
  List<T> generateTicks();

  double position(T value);
}

class NumMeasure<T extends num> extends ContinuousMeasure<T> {
  NumMeasure({
    @required NumSpan<T> span,
    ContinuousTickGenerator<T> tickGenerator,
  }) : super(
          span: span,
          tickGenerator:
              tickGenerator ?? new AutoContinuousTickGenerator(tickCount: 5),
        );
}

class ContinuousMeasure<T> implements Measure<T> {
  ContinuousMeasure({
    @required this.span,
    @required this.tickGenerator,
  });

  final SpanBase<T> span;

  final ContinuousTickGenerator<T> tickGenerator;

  @override
  double position(T value) => span.toDouble(value);

  @override
  List<T> generateTicks() {
    return tickGenerator.generate(span);
  }
}

class CategoricalMeasure<T> implements Measure<T> {
  CategoricalMeasure({
    this.list,
    CategoricalTickGenerator<T> tickGenerator,
  }) : this.tickGenerator =
            tickGenerator ?? new AutoCategoricalTickGenerator<T>();

  final List<T> list;

  final CategoricalTickGenerator<T> tickGenerator;

  @override
  double position(T value) {
    final ticks = generateCategoricalTicks(list.length);
    return ticks[list.indexOf(value)];
  }

  @override
  List<T> generateTicks() {
    return tickGenerator.generate(list);
  }
}

abstract class AxisBase<Datum, Value> {
  AxisBase({
    @required this.measure,
    @required this.tickLabelFn,
    @required this.opposite,
    @required this.size,
    @required this.offset,
    @required this.paint,
  });

  final Measure<Value> measure;

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
      final label = tickLabelFn(tick);

      return new AxisTickData(
        value: pos,
        width: 1 / ticks.length,
        labelers: [
          new NotchTickLabeler(),
          new TextTickLabeler(text: label),
        ],
      );
    });
  }
}

/// An axis which maps data points to continuous values.
///
/// Time, amounts, and percentages are examples of continuous values.
class ContinuousAxis<Datum, Value> extends AxisBase<Datum, Value> {
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
class CategoricalAxis<Datum, Category> extends AxisBase<Datum, Category> {
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
