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

abstract class TickGenerator<T> {
  List<T> generate(List<T> values, SpanBase<T> span);
}

@immutable
class IntervalTickGenerator<T> implements TickGenerator<T> {
  IntervalTickGenerator({
    @required this.increment,
    @required this.comparator,
    this.includeMax: true,
  });

  final UnaryFunction<T, T> increment;

  final Comparator<T> comparator;

  final bool includeMax;

  static IntervalTickGenerator<T> byN<T extends num>(
    T n, [
    bool includeMax = true,
  ]) {
    return new IntervalTickGenerator<T>(
      increment: (num) => num + n,
      comparator: (a, b) => a.compareTo(b),
      includeMax: includeMax,
    );
  }

  static IntervalTickGenerator<DateTime> byDuration(
    Duration n, [
    bool includeMax = true,
  ]) {
    return new IntervalTickGenerator<DateTime>(
      increment: (date) => date.add(n),
      comparator: (a, b) => a.compareTo(b),
      includeMax: includeMax,
    );
  }

  @override
  List<T> generate(List<T> values, SpanBase<T> span) {
    final min = span.min;
    final max = span.max;

    final result = <T>[];
    var curr = min;
    while (comparator(curr, max) <= 0) {
      result.add(curr);
      curr = increment(curr);
    }

    if (includeMax && !result.contains(max)) result.add(max);

    return result;
  }
}

@immutable
class AutoTickGenerator<T> implements TickGenerator<T> {
  const AutoTickGenerator();

  @override
  List<T> generate(List<T> values, SpanBase<T> span) => values;
}

class FixedTickGenerator<T> implements TickGenerator<T> {
  const FixedTickGenerator({
    this.ticks,
  });

  final List<T> ticks;

  @override
  List<T> generate(List<T> values, SpanBase<T> span) => this.ticks;
}

@immutable
class ChartAxis<Value> {
  static String defaultTickLabelFn<V>(V value) => value.toString();

  ChartAxis({
    this.span,
    UnaryFunction<List<Value>, SpanBase<Value>> spanFn,
    TickGenerator<Value> tickGenerator,
    this.tickLabelFn,
    this.opposite: false,
    this.size,
    this.offset: 0.0,
    this.paint: const PaintOptions.stroke(),
  })  : this.spanFn = spanFn ??
            ((values) => new ListSpan<Value>(values.toSet().toList())),
        this.tickGenerator = tickGenerator ?? new AutoTickGenerator<Value>();

  final SpanBase<Value> span;

  final UnaryFunction<List<Value>, SpanBase<Value>> spanFn;

  final TickGenerator<Value> tickGenerator;

  final UnaryFunction<Value, String> tickLabelFn;

  final bool opposite;

  final double size;

  final double offset;

  final PaintOptions paint;

  ChartAxisDrawable generateAxisData(
      ChartPosition position, List<dynamic> values) {
    final castedValues = values.map((dynamic value) => value as Value).toList();
    final axisSpan = span ?? spanFn(castedValues);

    final tickData = generateAxisTicks(axisSpan, castedValues);

    return new ChartAxisDrawable(
      ticks: tickData,
      position: position,
      size: size,
      offset: offset,
      paint: paint,
    );
  }

  List<AxisTickDrawable> generateAxisTicks(
      SpanBase<Value> span, List<Value> values) {
    final ticks = tickGenerator.generate(values, span);

    return new List.generate(ticks.length, (i) {
      final tick = ticks[i];
      final pos = span.toDouble(tick);

      final label = (tickLabelFn ?? defaultTickLabelFn)(tick);

      return new AxisTickDrawable(
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
