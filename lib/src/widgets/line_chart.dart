import 'dart:collection';

import 'package:fcharts/src/decor/decor.dart';
import 'package:fcharts/src/line/curves.dart';
import 'package:fcharts/src/line/drawable.dart';
import 'package:fcharts/src/utils/chart_position.dart';
import 'package:fcharts/src/utils/marker.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/span.dart';
import 'package:fcharts/src/utils/utils.dart';
import 'package:fcharts/src/widgets/base.dart';
import 'package:fcharts/src/widgets/chart_view.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class MarkerOptions {
  const MarkerOptions({
    this.paint: const PaintOptions.fill(),
    this.shape: MarkerShapes.circle,
    this.size: 3.0,
  });

  final PaintOptions paint;

  // TODO: list of paint vs single paint
  List<PaintOptions> get paintList => paint == null ? [] : [paint];

  final MarkerShape shape;

  final double size;
}

class Line<Datum, X, Y> {
  Line({
    @required this.data,
    @required this.xFn,
    @required this.yFn,
    ChartAxis<X> xAxis,
    ChartAxis<Y> yAxis,
    this.stroke: const PaintOptions.stroke(color: Colors.black),
    this.fill,
    this.curve: LineCurves.monotone,
    this.marker: const MarkerOptions(),
    this.markerFn,
  })  : this.xAxis = xAxis ?? new ChartAxis<X>(),
        this.yAxis = yAxis ?? new ChartAxis<Y>();

  List<Datum> data;

  UnaryFunction<Datum, X> xFn;

  UnaryFunction<Datum, Y> yFn;

  ChartAxis<X> xAxis;

  ChartAxis<Y> yAxis;

  PaintOptions stroke;

  PaintOptions fill;

  LineCurve curve;

  MarkerOptions marker;

  UnaryFunction<Datum, MarkerOptions> markerFn;

  MarkerOptions markerFor(Datum datum) {
    return marker ?? markerFn(datum);
  }

  Iterable<X> get xs => data.map(xFn);

  Iterable<Y> get ys => data.map(yFn);

  LineChartDrawable generateChartData(List xValues, List yValues) {
    final xValuesCasted = xValues.map((dynamic x) => x as X).toList();
    final yValuesCasted = yValues.map((dynamic y) => y as Y).toList();

    final xSpan = xAxis.span ?? xAxis.spanFn(xValuesCasted);
    final ySpan = yAxis.span ?? yAxis.spanFn(yValuesCasted);

    return new LineChartDrawable(
      points: _generatePoints(xSpan, ySpan),
      stroke: stroke,
      fill: fill,
      curve: curve,
    );
  }

  List<LinePointDrawable> _generatePoints(
    SpanBase<X> xSpan,
    SpanBase<Y> ySpan,
  ) {
    return new List.generate(data.length, (j) {
      final datum = data[j];
      final X x = xFn(datum);
      final Y y = yFn(datum);

      final xPos = xSpan.toDouble(x);
      final yPos = y == null ? null : ySpan.toDouble(y);

      // todo: should this be able to be null
      final marker = markerFor(datum);

      return new LinePointDrawable(
        x: xPos,
        y: yPos,
        paint: marker == null ? [] : marker.paintList,
        shape: marker == null ? MarkerShapes.circle : marker.shape,
        size: marker == null ? 4.0 : marker.size,
      );
    });
  }
}

class LineChart extends Chart {
  LineChart({
    Key key,
    @required this.lines,
    this.vertical: false,
    this.chartPadding: const EdgeInsets.all(20.0),
  }) : super(key: key);

  final List<Line> lines;

  final bool vertical;

  final EdgeInsets chartPadding;

  @override
  _LineChartState createState() => new _LineChartState();
}

class _LineChartState extends State<LineChart> {
  Widget build(BuildContext context) {
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

    final lineCharts = widget.lines.map((line) {
      final xValues = axisData[line.xAxis];
      final yValues = axisData[line.yAxis];

      return line.generateChartData(xValues, yValues);
    }).toList();

    return new ChartView(
      charts: lineCharts,
      decor: new ChartDecor(
        axes: axesData,
      ),
      chartPadding: widget.chartPadding,
      rotation: widget.vertical ? ChartRotation.clockwise : ChartRotation.none,
    );
  }
}
