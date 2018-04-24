import 'package:fcharts/fcharts.dart';
import 'package:flutter/material.dart';

class SimpleLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // X value -> Y value
    final data = [
      ["A", "✔"],
      ["B", "❓"],
      ["C", "✖"],
      ["D", "❓"],
      ["E", "✖"],
      ["F", "✖"],
      ["G", "✔"],
    ];

    return new LineChart(
      lines: [
        new Line<List<String>, String, String>(
          data: data,
          xFn: (datum) => datum[0],
          yFn: (datum) => datum[1],
        ),
      ],
      chartPadding: new EdgeInsets.fromLTRB(30.0, 10.0, 10.0, 30.0),
    );
  }
}
