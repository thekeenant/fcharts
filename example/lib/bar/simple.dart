import 'package:fcharts/fcharts.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
class Sales {
  const Sales(this.season, this.iceCream, this.chocolate, this.cookies);

  final String season;
  final int iceCream;
  final int chocolate;
  final int cookies;
}

class SimpleBarChart extends StatelessWidget {
  // X value -> Y value
  static const myData = [
    const Sales("Winter", 5, 20, 15),
    const Sales("Spring", 10, 23, 5),
    const Sales("Summer", 35, 18, 12),
    const Sales("Fall", 18, 24, 15),
  ];

  @override
  Widget build(BuildContext context) {
    final xAxis = ChartAxis<String>(
      span: ListSpan(myData.map((sales) => sales.season).toList()),
    );

    final yAxis = ChartAxis<int>(
      span: IntSpan(0, 75),
      tickGenerator: IntervalTickGenerator.byN(15),
    );

    final barStack1 = BarStack<int>();

    return AspectRatio(
      aspectRatio: 2.0,
      child: BarChart<Sales, String, int>(
        data: myData,
        xAxis: xAxis,
        yAxis: yAxis,
        bars: [
          Bar<Sales, String, int>(
            xFn: (sales) => sales.season,
            valueFn: (sales) => sales.chocolate,
            fill: PaintOptions.fill(color: Colors.brown),
            stack: barStack1,
          ),
          Bar<Sales, String, int>(
            xFn: (sales) => sales.season,
            valueFn: (sales) => sales.cookies,
            fill: PaintOptions.fill(color: Colors.orange),
            stack: barStack1,
          ),
          Bar<Sales, String, int>(
            xFn: (sales) => sales.season,
            valueFn: (sales) => sales.iceCream,
            fill: PaintOptions.fill(color: Colors.yellow),
            stack: barStack1,
          ),
        ],
      ),
    );
  }
}
