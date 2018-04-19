import 'package:fcharts/src/utils/span.dart';
import 'package:fcharts/src/utils/utils.dart';
import 'package:meta/meta.dart';
import 'dart:math' as math;

abstract class AxisBase<Datum, Range, Value> {
  AxisBase({
    @required this.range,
    @required this.valueFn,
    @required this.tickLabelFn,
  });

  final Range range;

  final UnaryFunction<Datum, Value> valueFn;

  final UnaryFunction<Value, String> tickLabelFn;

  Range autoRange(List<Datum> data);
}

/// An axis which maps data points to continuous values.
///
/// Time, amounts, and percentages are examples of continuous values.
class ContinuousAxis<Datum> extends AxisBase<Datum, Span, double> {
  ContinuousAxis({
    @required Span span,
    @required UnaryFunction<Datum, double> valueFn,
    @required UnaryFunction<double, String> tickLabelFn,
  }) : super(
          range: span,
          valueFn: valueFn,
          tickLabelFn: tickLabelFn,
        );

  Span autoRange(List<Datum> data) {
    var min = double.maxFinite;
    var max = -double.maxFinite;
    for (final datum in data) {
      final value = valueFn(datum);
      min = math.min(min, value);
      max = math.max(max, value);
    }
    return new Span(min, max);
  }
}

/// An axis which categorizes data points into discrete values.
///
/// For example, someone's first name is either "John" or not "John". There is no in-between
/// "John" and "Adam".
class CategoricalAxis<Datum, Category>
    extends AxisBase<Datum, List<Category>, Category> {
  CategoricalAxis({
    @required List<Category> categories,
    @required UnaryFunction<Datum, Category> categoryFn,
    @required UnaryFunction<Category, String> tickLabelFn,
  }) : super(
          range: categories,
          valueFn: categoryFn,
          tickLabelFn: tickLabelFn,
        );

  @override
  List<Category> autoRange(List<Datum> data) {
    final result = new Set<Category>();
    for (final datum in data) result.add(valueFn(datum));
    return result.toList();
  }
}
