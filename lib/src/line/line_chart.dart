import 'package:fcharts/src/decor/axis_data.dart';
import 'package:fcharts/src/decor/decor.dart';
import 'package:fcharts/src/decor/tick.dart';
import 'package:fcharts/src/line/curves.dart';
import 'package:fcharts/src/line/data.dart';
import 'package:fcharts/src/utils/chart_position.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/range.dart';
import 'package:fcharts/src/utils/utils.dart';
import 'package:fcharts/src/widget/chart_data_view.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';


class LineChart<Datum> extends StatelessWidget {
  LineChart({
    this.data,
    this.axes,
    this.lines,
    this.padding: const EdgeInsets.all(50.0)
  });

  final List<Axis<Datum>> axes;
  final List<Line<Datum>> lines;
  final List<Datum> data;
  final EdgeInsets padding;

  Iterable<XAxis<Datum>> _xAxes() =>
    axes.where((a) => a is XAxis<Datum>).map((a) => a as XAxis<Datum>);

  Iterable<YAxis<Datum>> _yAxes() =>
    axes.where((a) => a is YAxis<Datum>).map((a) => a as YAxis<Datum>);

  @override
  Widget build(BuildContext context) {
    final autoRanges = <Axis<Datum>, Range>{};

    final lineCharts = new List.generate(lines.length, (i) {
      final line = lines[i];

      final matches = _yAxes().where((a) => a.id == line.yAxisId);

      if (matches.isEmpty)
        throw new StateError('no y-axis found for id: ${line.yAxisId}');
      else if (matches.length > 1)
        throw new StateError('multiple y-axis with same id: ${line.yAxisId}');

      final yAxis = matches.first;
      var autoRange = new Range(0.0, 0.0);

      final linePoints = new List.generate(data.length, (j) {
        final datum = data[j];
        final x = j / (data.length - 1);
        final value = line.value(datum);

        if (value < autoRange.min)
          autoRange = new Range(value, autoRange.max);
        if (value > autoRange.max)
          autoRange = new Range(autoRange.min, value);

        return new LinePointData(
          x: x,
          value: value,
          paint: line.pointPaint == null ? [] : line.pointPaint(datum),
          radius: line.pointRadius == null ? 3.0 : line.pointRadius(datum)
        );
      });

      autoRanges[yAxis] = autoRange;

      return new LineChartData(
        points: linePoints,
        range: yAxis.range ?? autoRange,
        curve: line.curve,
        fill: line.fill,
        stroke: line.stroke,
      );
    });

    final chartAxes = new List.generate(axes.length, (i) {
      final axis = axes[i];

      if (axis is XAxis<Datum>) {
        return new ChartAxis(
          position: axis.position,
          paint: axis.stroke,
          ticks: new List.generate(data.length, (j) {
            final datum = data[j];
            final text = axis.label(datum);

            final value = j / (data.length - 1);
            final width = 1 / data.length;

            return new AxisTick(
              value: value,
              width: width,
              labelers: [
                new TextTickLabeler(
                  text: text,
                  style: axis.labelStyle
                ),
                new NotchTickLabeler(
                  paint: axis.stroke
                )
              ]
            );
          })
        );
      }
      else if (axis is YAxis<Datum>) {
        return new ChartAxis(
          position: axis.position,
          paint: axis.stroke,
          ticks: new List.generate(axis.tickCount, (j) {
            final value = j / (axis.tickCount - 1);
            final width = 1 / axis.tickCount;
            final range = axis.range ?? autoRanges[axis];
            final rangedValue = value * range.span + range.min;

            return new AxisTick(
              value: value,
              width: width,
              labelers: [
                new TextTickLabeler(
                  text: axis.label(rangedValue),
                  style: axis.labelStyle
                ),
                new NotchTickLabeler(
                  paint: axis.stroke
                )
              ],
            );
          })
        );
      }
    });

    return new ChartDataView(
      charts: lineCharts,
      decor: new ChartDecor(
        axes: chartAxes
      ),
      chartPadding: padding,
    );
  }
}

abstract class Axis<T> {
  Axis({
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

class XAxis<Datum> extends Axis<Datum> {
  XAxis({
    @required this.label,
    String id,
    PaintOptions stroke: const PaintOptions.stroke(),
    TextStyle labelStyle: const TextStyle(color: Colors.black),
    ChartPosition position: ChartPosition.bottom
  }) : super(id: id, stroke: stroke, labelStyle: labelStyle, position: position);

  final UnaryFunction<Datum, String> label;
}

class YAxis<Datum> extends Axis<Datum> {
  YAxis({
    @required this.label,
    this.range,
    this.tickCount: 5,
    String id,
    PaintOptions stroke: const PaintOptions.stroke(),
    TextStyle labelStyle: const TextStyle(color: Colors.black),
    ChartPosition position: ChartPosition.left
  }) : super(id: id, stroke: stroke, labelStyle: labelStyle, position: position);

  final UnaryFunction<double, String> label;
  final Range range;
  final int tickCount;
}

class Line<T> {
  Line({
    @required this.value,
    this.xAxisId,
    this.yAxisId,
    this.stroke: const PaintOptions.stroke(),
    this.fill,
    this.curve: LineCurves.monotone,
    this.pointPaint,
    this.pointRadius
  });

  final UnaryFunction<T, double> value;
  final String xAxisId;
  final String yAxisId;
  final PaintOptions stroke;
  final PaintOptions fill;
  final LineCurve curve;
  final UnaryFunction<T, List<PaintOptions>> pointPaint;
  final UnaryFunction<T, double> pointRadius;
}