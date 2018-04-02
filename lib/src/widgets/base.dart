import 'package:fcharts/src/decor/legend.dart';
import 'package:fcharts/src/utils/chart_position.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/range.dart';
import 'package:fcharts/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
abstract class Chart<Datum> extends StatefulWidget {
  const Chart({
    @required this.axes,
    @required this.padding,
    @required this.legend,
    @required this.animationCurve,
    @required this.animationDuration,
  })
      : assert(axes != null),
        assert(padding != null);

  final List<AxisBase<Datum>> axes;
  final EdgeInsets padding;
  final Legend legend;
  final Curve animationCurve;
  final Duration animationDuration;

  Iterable<XAxis<Datum>> get xAxes =>
      axes.where((a) => a is XAxis<Datum>).map((a) => a as XAxis<Datum>);

  Iterable<YAxis<Datum>> get yAxes =>
      axes.where((a) => a is YAxis<Datum>).map((a) => a as YAxis<Datum>);
}

abstract class AxisBase<T> {
  AxisBase({
    @required this.id,
    @required this.stroke,
    @required this.labelStyle,
    @required this.opposite,
    @required this.size,
    @required this.offset,
  });

  final String id;
  final PaintOptions stroke;
  final TextStyle labelStyle;
  final bool opposite;
  final double size;
  final double offset;

  ChartPosition get position;
}

class XAxis<Datum> extends AxisBase<Datum> {
  XAxis({
    @required this.label,
    String id,
    PaintOptions stroke: const PaintOptions.stroke(),
    TextStyle labelStyle: const TextStyle(color: Colors.black),
    bool opposite: false,
    double size,
    double offset: 0.0,
  })
      : super(
          id: id,
          stroke: stroke,
          labelStyle: labelStyle,
          opposite: opposite,
          size: size,
          offset: offset,
        );

  final UnaryFunction<Datum, String> label;

  @override
  ChartPosition get position =>
      opposite ? ChartPosition.top : ChartPosition.bottom;
}

class YAxis<Datum> extends AxisBase<Datum> {
  YAxis({
    @required this.label,
    this.range,
    this.tickCount: 5,
    String id,
    PaintOptions stroke: const PaintOptions.stroke(),
    TextStyle labelStyle: const TextStyle(color: Colors.black),
    bool opposite: false,
    double size,
    double offset: 0.0,
  })
      : super(
          id: id,
          stroke: stroke,
          labelStyle: labelStyle,
          opposite: opposite,
          size: size,
          offset: offset,
        );

  final UnaryFunction<double, String> label;
  final Range range;
  final int tickCount;

  @override
  ChartPosition get position =>
      opposite ? ChartPosition.right : ChartPosition.left;
}

class Legend {
  Legend({
    this.position: ChartPosition.top,
    this.layout: LegendLayout.horizontal,
    this.offset: Offset.zero,
  });

  final ChartPosition position;
  final LegendLayout layout;
  final Offset offset;
}
