import 'package:fcharts/src/utils/chart_position.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/range.dart';
import 'package:fcharts/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

abstract class Chart<Datum> extends StatelessWidget {
  final List<AxisBase<Datum>> axes;
  final EdgeInsets padding;

  Chart({
    @required this.axes,
    @required this.padding
  }) :
      assert(axes != null),
      assert(padding != null);

  get xAxes =>
    axes.where((a) => a is XAxis<Datum>).map((a) => a as XAxis<Datum>);

  get yAxes =>
    axes.where((a) => a is YAxis<Datum>).map((a) => a as YAxis<Datum>);
}

abstract class AxisBase<T> {
  AxisBase({
    this.id,
    this.stroke,
    this.labelStyle,
    this.position
  });

  final String id;
  final PaintOptions stroke;
  final TextStyle labelStyle;
  final ChartPosition position;
}

class XAxis<Datum> extends AxisBase<Datum> {
  XAxis({
    @required this.label,
    String id,
    PaintOptions stroke: const PaintOptions.stroke(),
    TextStyle labelStyle: const TextStyle(color: Colors.black),
    ChartPosition position: ChartPosition.bottom
  }) :
      assert(position == ChartPosition.top || position == ChartPosition.bottom),
      super(id: id, stroke: stroke, labelStyle: labelStyle, position: position);

  final UnaryFunction<Datum, String> label;
}

class YAxis<Datum> extends AxisBase<Datum> {
  YAxis({
    @required this.label,
    this.range,
    this.tickCount: 5,
    String id,
    PaintOptions stroke: const PaintOptions.stroke(),
    TextStyle labelStyle: const TextStyle(color: Colors.black),
    ChartPosition position: ChartPosition.left
  }) :
      assert(position == ChartPosition.left || position == ChartPosition.right),
      super(id: id,stroke: stroke, labelStyle: labelStyle, position: position);

  final UnaryFunction<double, String> label;
  final Range range;
  final int tickCount;
}