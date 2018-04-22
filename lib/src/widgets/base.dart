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
  });

  final UnaryFunction<Value, String> tickLabelFn;

  final Range range;

  double position(Value value, Range range);
}

/// An axis which maps data points to continuous values.
///
/// Time, amounts, and percentages are examples of continuous values.
class ContinuousAxis<Datum, Value> extends AxisBase<Datum, SpanBase<Value>, Value> {
  ContinuousAxis({
    UnaryFunction<Value, String> tickLabelFn,
    SpanBase<Value> span,
  }) : super(
          range: span,
          tickLabelFn: tickLabelFn,
        );

  @override
  double position(Value value, SpanBase<Value> range) {
    return range.toDouble(value);
  }
}

/// An axis which categorizes data points into discrete values.
///
/// For example, someone's first name is either "John" or not "John". There is no in-between
/// "John" and "Adam".
class CategoricalAxis<Datum, Category> extends AxisBase<Datum, List<Category>, Category> {
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
}
