import 'dart:math';

import 'package:fcharts/fcharts.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

final _random = new Random();

class Day {
  String name;
  int cookies;
  int brownies;

  Day(this.name, this.cookies, this.brownies);

  @override
  String toString() {
    return 'Day($name, cookies=$cookies, brownies=$brownies)';
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final days = [
    new Day("Day 1", 10000, 7),
    new Day("Day 2", 1000, 7),
    new Day("Day 3", 100, 6),
    new Day("Day 4", null, 4),
    new Day("Day 5", 10, 4),
    new Day("Day 6", null, 2),
    new Day("Day 7", null, 1),
  ];

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Cookies & Brownies Consumption'),
        ),
        body: new AspectRatio(
          aspectRatio: 4.0 / 3.0,
          child: new ChartDataView(
            charts: [
              new LineChartData(
                domain: new Span(0.0, 1.0),
                range: new Span(0.0, 20.0),
                stroke: new PaintOptions.stroke(
                    color: Colors.blue, strokeWidth: 4.0),
                fill: new PaintOptions(color: Colors.blue.withOpacity(0.5)),
                points: [
                  new LinePointData(
                    x: 0.0,
                    y: 2.0,
                    shape: MarkerShapes.x,
                    paint: [
                      new PaintOptions.stroke(
                        color: Colors.blue[700],
                        strokeCap: StrokeCap.butt,
                        strokeWidth: 3.0,
                      ),
                    ],
                    size: 6.0,
                  ),
                  new LinePointData(
                    x: 0.2,
                    y: 19.0,
                    shape: MarkerShapes.x,
                    paint: [
                      new PaintOptions.stroke(
                        color: Colors.blue[700],
                        strokeCap: StrokeCap.butt,
                        strokeWidth: 3.0,
                      ),
                    ],
                    size: 6.0,
                  ),
                  new LinePointData(
                    x: 0.5,
                    y: 12.0,
                    shape: MarkerShapes.triangle,
                    paint: [
                      new PaintOptions(
                        color: Colors.green[700],
                        strokeCap: StrokeCap.butt,
                        strokeWidth: 3.0,
                      ),
                    ],
                    size: 50.0,
                  ),
                  new LinePointData(
                    x: 1.0,
                    y: 15.0,
                    shape: MarkerShapes.circle,
                    paint: [
                      new PaintOptions(
                        color: Colors.blue[700],
                        strokeCap: StrokeCap.butt,
                        strokeWidth: 3.0,
                      ),
                    ],
                    size: 6.0,
                  ),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            setState(() {
              int idx = _random.nextInt(days.length);
              days[idx].brownies = _random.nextInt(5) + 1;
              days[idx].cookies = _random.nextInt(15) + 1;
            });
          },
          child: new Icon(Icons.refresh),
        ),
      ),
    );
  }
}
