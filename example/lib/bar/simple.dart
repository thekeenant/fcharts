import 'package:fcharts/fcharts.dart';
import 'package:flutter/material.dart';

class SimpleBarChart extends StatelessWidget {
  // X value -> Y value
  static const myData = [
    ["A", "✔", "❓"],
    ["B", "❓", "✔"],
    ["C", "✖", "✔"],
  ];

  @override
  Widget build(BuildContext context) {
    final xAxis = new ChartAxis<String>(
      span: new ListSpan(myData.map((list) => list[0]).toList()),
    );

    final yAxis = new ChartAxis<String>(
      span: new ListSpan(myData.map((list) => list[1]).toList()),
    );

    return new AspectRatio(
      aspectRatio: 4/3,
      child: new BarChart<List<String>, String, String>(
        data: myData,
        bars: [
          new Bar<List<String>, String, String>(
            xFn: (datum) => datum[0],
            valueFn: (datum) => datum[1],
            xAxis: xAxis,
            yAxis: yAxis,
          ),
        ],
      ),
    );
  }
}
