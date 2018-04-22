import 'dart:collection';

import 'package:fcharts/src/decor/axis.dart';
import 'package:fcharts/src/decor/decor.dart';
import 'package:fcharts/src/line/curves.dart';
import 'package:fcharts/src/line/data.dart';
import 'package:fcharts/src/utils/chart_position.dart';
import 'package:fcharts/src/utils/marker.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/span.dart';
import 'package:fcharts/src/utils/utils.dart';
import 'package:fcharts/src/widgets/base.dart';
import 'package:fcharts/src/widgets/chart_data_view.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class MarkerOptions {
  const MarkerOptions({
    this.paint: const [],
    this.shape: MarkerShapes.circle,
    this.size: 3.0,
  });

  final List<PaintOptions> paint;

  final MarkerShape shape;

  final double size;
}

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
    this.marker: const MarkerOptions(),
    this.markerFn,
  });

  List<Datum> data;

  AxisBase<Datum, dynamic, X> xAxis;

  AxisBase<Datum, dynamic, Y> yAxis;

  UnaryFunction<Datum, X> xFn;

  UnaryFunction<Datum, Y> yFn;

  PaintOptions stroke;

  PaintOptions fill;

  LineCurve curve;

  MarkerOptions marker;

  UnaryFunction<Datum, MarkerOptions> markerFn;

  MarkerOptions markerOptions(Datum datum) {
    if (markerFn != null) return markerFn(datum);
    return marker;
  }

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

      final marker = markerOptions(datum);

      return new LinePointData(
        x: xPos,
        y: yPos,
        paint: marker.paint,
        shape: marker.shape,
        size: marker.size,
      );
    });
  }
}

class LineChart extends Chart {
  const LineChart({
    Key key,
    @required this.lines,
    this.vertical: false,
  }) : super(key: key);

  final List<Line> lines;

  final bool vertical;

  @override
  _LineChartState createState() => new _LineChartState();
}

class _LineChartState extends State<LineChart> {
  List<LineChartData> buildCharts() {
    return widget.lines.map((line) => line.generateChartData()).toList();
  }

  ChartDecor buildDecor() {
    final lines = widget.lines;
    final vertical = widget.vertical;

    // TODO: Deal with axes
    final xAxes = new LinkedHashSet<AxisBase>();
    final yAxes = new LinkedHashSet<AxisBase>();

    lines.forEach((line) {
      xAxes.add(vertical ? line.yAxis : line.xAxis);
      yAxes.add(vertical ? line.xAxis : line.yAxis);
    });

    final axes = xAxes.toSet()..addAll(yAxes);

    final axesData = <ChartAxisData>[];

    for (final axis in axes) {
      final tickData = axis.generateAxisTicks(axis.range);

      final position = xAxes.contains(axis) ? ChartPosition.bottom : ChartPosition.left;

      axesData.add(new ChartAxisData(
        ticks: tickData,
        position: position,
      ));
    }

    return new ChartDecor(
      axes: axesData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new ChartDataView(
      charts: buildCharts(),
      decor: buildDecor(),
      chartPadding: new EdgeInsets.all(40.0),
      rotation: widget.vertical ? ChartRotation.clockwise : ChartRotation.none,
    );
  }
}
