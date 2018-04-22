import 'package:fcharts/src/decor/tick.dart';
import 'package:fcharts/src/utils/span.dart';
import 'package:fcharts/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

abstract class Chart extends StatefulWidget {
  const Chart({Key key}) : super(key: key);
}

abstract class AxisBase<Datum, Range, Value> {
  AxisBase({
    @required this.range,
    @required this.tickLabelFn,
    this.opposite,
  });

  final UnaryFunction<Value, String> tickLabelFn;

  final Range range;

  final bool opposite;

  double position(Value value, Range range);

  List<Value> generateTicks(Range range);

  List<AxisTickData> generateAxisTicks(Range range) {
    final ticks = generateTicks(range);

    return new List.generate(ticks.length, (i) {
      final tick = ticks[i];
      final pos = position(tick, range);
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
class ContinuousAxis<Datum, Value>
    extends AxisBase<Datum, SpanBase<Value>, Value> {
  ContinuousAxis({
    @required UnaryFunction<Value, String> tickLabelFn,
    SpanBase<Value> span,
    this.ticks,
  }) : super(
          range: span,
          tickLabelFn: tickLabelFn,
        );

  List<Value> ticks;

  @override
  double position(Value value, SpanBase<Value> range) {
    return range.toDouble(value);
  }

  @override
  List<Value> generateTicks(SpanBase<Value> range) {
    return ticks;
  }
}

/// An axis which categorizes data points into discrete values.
///
/// For example, someone's first name is either "John" or not "John". There is no in-between
/// "John" and "Adam".
class CategoricalAxis<Datum, Category>
    extends AxisBase<Datum, List<Category>, Category> {
  CategoricalAxis({
    UnaryFunction<Category, String> tickLabelFn,
    List<Category> categories,
  }) : super(
          range: categories,
          tickLabelFn: tickLabelFn,
        );

  @override
  double position(Category value, List<Category> categories) {
    final index = categories.indexOf(value);
    return generateCategoricalTicks(categories.length)[index];
  }

  @override
  List<Category> generateTicks(List<Category> range) {
    return range;
  }
}
