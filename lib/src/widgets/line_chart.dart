import 'dart:collection';

import 'package:fcharts/src/decor/decor.dart';
import 'package:fcharts/src/line/curves.dart';
import 'package:fcharts/src/line/data.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/span.dart';
import 'package:fcharts/src/utils/utils.dart';
import 'package:fcharts/src/widgets/base.dart';
import 'package:fcharts/src/widgets/chart_data_view.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class Line<Datum, X, Y> {
  Line({
    @required this.data,
    @required this.xAxis,
    @required this.yAxis,
    @required this.xFn,
    @required this.yFn,
    this.stroke: const PaintOptions.stroke(color: Colors.black),
    this.fill,
    this.curve: LineCurves.linear,
  });

  List<Datum> data;
  AxisBase<Datum, dynamic, X> xAxis;
  AxisBase<Datum, dynamic, Y> yAxis;

  UnaryFunction<Datum, X> xFn;

  UnaryFunction<Datum, Y> yFn;

  PaintOptions stroke;

  PaintOptions fill;

  LineCurve curve;

  LineChartData generateChartData() {
    return new LineChartData(
      points: _generatePoints(),
      range: new Range(0.0, 1.0),
      domain: new Range(0.0, 1.0),
      stroke: stroke,
      fill: fill,
      curve: curve,
    );
  }

  List<LinePointData> _generatePoints() {
    return new List.generate(data.length, (j) {
      final datum = data[j];
      final X x = xFn(datum);
      final Y y = yFn(datum);

      // todo?
      if (x == null) throw new Error();

      final xPos = xAxis.position(x, xAxis.range);
      final yPos = y == null ? null : yAxis.position(y, yAxis.range);

      print("$xPos, $yPos");

      return new LinePointData(
        x: xPos,
        y: yPos,
      );
    });
  }
}

class LineChart extends Chart {
  const LineChart({
    Key key,
    @required this.lines,
  }) : super(key: key);

  final List<Line> lines;

  @override
  _LineChartState createState() => new _LineChartState();
}

class _LineChartState extends State<LineChart> {
  List<LineChartData> buildCharts() {
    final lines = widget.lines;

    // TODO: Deal with axes
    final xAxes = new LinkedHashSet<AxisBase>();
    final yAxes = new LinkedHashSet<AxisBase>();
    lines.forEach((line) {
      xAxes.add(line.xAxis);
      yAxes.add(line.yAxis);
    });

    return lines.map((line) => line.generateChartData()).toList();
  }

  ChartDecor buildDecor() {
    return new ChartDecor();
  }

  @override
  Widget build(BuildContext context) {
    return new ChartDataView(
      charts: buildCharts(),
      decor: buildDecor(),
    );
  }
}
