import 'package:fcharts/src/decor/axis.dart';
import 'package:fcharts/src/decor/decor.dart';
import 'package:fcharts/src/decor/legend.dart';
import 'package:fcharts/src/decor/tick.dart';
import 'package:fcharts/src/line/curves.dart';
import 'package:fcharts/src/line/data.dart';
import 'package:fcharts/src/utils/chart_position.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/range.dart';
import 'package:fcharts/src/utils/utils.dart';
import 'package:fcharts/src/widgets/base.dart';
import 'package:fcharts/src/widgets/chart_data_view.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class LineChart<Datum> extends Chart<Datum> {
  LineChart({
    this.data,
    this.lines,
    List<AxisBase<Datum>> axes: const [],
    EdgeInsets padding: const EdgeInsets.all(50.0)
  }) : super(axes: axes, padding: padding);

  final List<Line<Datum>> lines;
  final List<Datum> data;

  @override
  Widget build(BuildContext context) {
    final autoRanges = <AxisBase<Datum>, Range>{};

    final lineCharts = new List.generate(lines.length, (i) {
      final line = lines[i];

      final matches = yAxes.where((a) => a.id == line.yAxisId);

      if (matches.isEmpty)
        throw new StateError('No y-axis found for id: ${line.yAxisId}');
      else if (matches.length > 1)
        throw new StateError('Multiple y-axis with same id: ${line.yAxisId}');

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
        return new ChartAxisData(
          position: axis.position,
          paint: axis.stroke,
          ticks: new List.generate(data.length, (j) {
            final datum = data[j];
            final text = axis.label(datum);

            final value = j / (data.length - 1);
            final width = 1 / data.length;

            return new AxisTickData(
              value: value,
              width: width,
              labelers: [
                new TextTickLabeler(
                  text: text,
                  style: axis.labelStyle,
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
        final range = axis.range ?? autoRanges[axis];

        return new ChartAxisData(
          position: axis.position,
          paint: axis.stroke,
          ticks: new List.generate(range == null ? 0 : axis.tickCount, (j) {
            final value = j / (axis.tickCount - 1);
            final width = 1 / axis.tickCount;
            final rangedValue = value * range.span + range.min;

            return new AxisTickData(
              value: value,
              width: width,
              labelers: [
                new TextTickLabeler(
                  text: axis.label(rangedValue),
                  style: axis.labelStyle,
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
        axes: chartAxes,
        legend: new LegendData(
          position: ChartPosition.left,
          items: [
            new LegendItemData(
              symbol: new LegendSquareSymbol(
                paint: [
                  const PaintOptions(color: Colors.blue)
                ]
              ),
              text: 'Cookies'
            ),
            new LegendItemData(
              symbol: new LegendSquareSymbol(
                paint: [
                  const PaintOptions(color: Colors.green)
                ]
              ),
              text: 'Brownies'
            )
          ]
        )
      ),
      chartPadding: padding,
//      rotation: ChartRotation.clockwise,
    );
  }
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