import 'dart:collection';

import 'package:fcharts/src/decor/decor.dart';
import 'package:fcharts/src/line/curves.dart';
import 'package:fcharts/src/line/drawable.dart';
import 'package:fcharts/src/utils/chart_position.dart';
import 'package:fcharts/src/utils/marker.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/utils.dart';
import 'package:fcharts/src/widgets/base.dart';
import 'package:fcharts/src/widgets/chart_view.dart';
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

  ChartAxis<X> xAxis;

  ChartAxis<Y> yAxis;

  UnaryFunction<Datum, X> xFn;

  UnaryFunction<Datum, Y> yFn;

  PaintOptions stroke;

  PaintOptions fill;

  LineCurve curve;

  MarkerOptions marker;

  UnaryFunction<Datum, MarkerOptions> markerFn;

  MarkerOptions markerFor(Datum datum) {
    if (markerFn != null) return markerFn(datum);
    return marker;
  }

  Iterable<X> get xs => data.map(xFn);

  Iterable<Y> get ys => data.map(yFn);

  LineChartDrawable generateChartData() {
    return new LineChartDrawable(
      points: _generatePoints(),
      stroke: stroke,
      fill: fill,
      curve: curve,
    );
  }

  List<LinePointDrawable> _generatePoints() {
    final xSpan = xAxis.span;
    final ySpan = yAxis.span;

    return new List.generate(data.length, (j) {
      final datum = data[j];
      final X x = xFn(datum);
      final Y y = yFn(datum);

      final xPos = xSpan.toDouble(x);
      final yPos = y == null ? null : ySpan.toDouble(y);

      final marker = markerFor(datum);

      return new LinePointDrawable(
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
  List<LineChartDrawable> buildCharts() {
    return widget.lines.map((line) => line.generateChartData()).toList();
  }

  ChartDecor buildDecor() {
    final lines = widget.lines;
    final vertical = widget.vertical;

    // TODO: Deal with axes
    final xAxes = new LinkedHashSet<ChartAxis>();
    final yAxes = new LinkedHashSet<ChartAxis>();

    final axisData = <ChartAxis, List<dynamic>>{};

    lines.forEach((line) {
      xAxes.add(vertical ? line.yAxis : line.xAxis);
      yAxes.add(vertical ? line.xAxis : line.yAxis);

      final xs = line.xs;
      final ys = line.ys;

      axisData.putIfAbsent(line.xAxis, () => <dynamic>[]);
      axisData.putIfAbsent(line.yAxis, () => <dynamic>[]);
      axisData[line.xAxis].addAll(xs);
      axisData[line.yAxis].addAll(ys);
    });

    final axes = xAxes.toSet()..addAll(yAxes);

    final axesData = axes.map((axis) {
      var position =
          xAxes.contains(axis) ? ChartPosition.bottom : ChartPosition.left;

      if (axis.opposite) {
        position = position == ChartPosition.bottom
            ? ChartPosition.top
            : ChartPosition.right;
      }

      return axis.generateAxisData(position, axisData[axis]);
    }).toList();

    return new ChartDecor(
      axes: axesData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new ChartView(
      charts: buildCharts(),
      decor: buildDecor(),
      chartPadding: new EdgeInsets.all(40.0),
      rotation: widget.vertical ? ChartRotation.clockwise : ChartRotation.none,
    );
  }
}
