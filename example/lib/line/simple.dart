import 'package:fcharts_example/data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:fcharts/fcharts.dart';

final data = [
  "A",
  "B",
  "C",
  "D",
  "E",
  "F",
  "G",
];

class SimpleLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new LineChart.single(
      line: new Line<String, String, int>(
        data: data,
        xFn: (datum) => datum,
        yFn: (datum) => data.indexOf(datum),
      ),
      chartPadding: new EdgeInsets.fromLTRB(60.0, 10.0, 10.0, 20.0),
    );
  }
}
