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

abstract class TickGenerator<Value> {
  List<Value> generate(List<Value> values);
}

class AxisSpanBuilder<Value> {
  AxisSpanBuilder(this.axis);

  final List data = <dynamic>[];
  final ChartAxis<Value> axis;

  void addData(List<dynamic> data) {
    this.data.addAll(data);
  }

  SpanBase<Value> build() {
    final values = <Value>[];
    for (final value in data) values.add(value as Value);
    return axis.span ?? axis.spanFn(values);
  }
}

@immutable
class ChartAxis<Value> {
  static String defaultTickLabelFn<V>(V value) => value.toString();

  const ChartAxis({
    @required this.span,
    this.spanFn,
    this.tickGenerator,
    this.tickLabelFn: defaultTickLabelFn,
    this.opposite: false,
    this.size,
    this.offset: 0.0,
    this.paint: const PaintOptions.stroke(),
  });

  final SpanBase<Value> span;

  final UnaryFunction<List<Value>, SpanBase<Value>> spanFn;

  final TickGenerator<Value> tickGenerator;

  final UnaryFunction<Value, String> tickLabelFn;

  final bool opposite;

  final double size;

  final double offset;

  final PaintOptions paint;

  ChartAxisData generateAxisData(ChartPosition position, List<dynamic> values) {
    final castedValues = values.map((dynamic value) => value as Value).toList();
    final axisSpan = span ?? spanFn(castedValues);

    final tickData = generateAxisTicks(axisSpan, castedValues);

    return new ChartAxisData(
      ticks: tickData,
      position: position,
      size: size,
      offset: offset,
      paint: paint,
    );
  }

  List<AxisTickData> generateAxisTicks(
      SpanBase<Value> span, List<Value> values) {
    final ticks = tickGenerator.generate(values);

    return new List.generate(ticks.length, (i) {
      final tick = ticks[i];
      final pos = span.toDouble(tick);

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
