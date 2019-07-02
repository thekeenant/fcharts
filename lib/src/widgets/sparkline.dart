import 'package:fcharts/src/line/curves.dart';
import 'package:fcharts/src/utils/marker.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/span.dart';
import 'package:fcharts/src/utils/utils.dart';
import 'package:fcharts/src/widgets/base.dart';
import 'package:fcharts/src/widgets/line_chart.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class _SparklinePoint {
  _SparklinePoint(this.value, this.index);

  final double value;
  final int index;

  static List<_SparklinePoint> createPoints(List<double> values) {
    return new List.generate(values.length, (i) {
      return new _SparklinePoint(values[i], i);
    });
  }
}

class Sparkline extends Line<_SparklinePoint, int, double> {
  Sparkline({
    @required List<double> data,
    PaintOptions stroke: const PaintOptions.stroke(
      color: Colors.black,
      strokeWidth: 2.0,
    ),
    PaintOptions fill,
    MarkerOptions marker,
    UnaryFunction<double, MarkerOptions> markerFn,
    LineCurve curve: LineCurves.linear,
  }) : super(
          data: _SparklinePoint.createPoints(data),
          xFn: (point) => point.index,
          yFn: (point) => point.value,
          stroke: stroke,
          fill: fill,
          curve: curve,
          marker: marker,
          markerFn: (point) {
            if (markerFn == null) return null;
            return markerFn(point.value);
          },
          xAxis: new ChartAxis<int>(
            span: new IntSpan(0, data.length - 1),
            tickGenerator: const EmptyTickGenerator(),
            hideLine: true,
          ),
          yAxis: new ChartAxis<double>(
            spanFn: (values) {
              if (values.isEmpty) {
                return new DoubleSpan(0, 0);
              }

              final sorted = values.where((num) => num != null).toList();
              sorted.sort();
              return new DoubleSpan(sorted.first, sorted.last);
            },
            tickGenerator: const EmptyTickGenerator(),
            hideLine: true,
          ),
        );
}
