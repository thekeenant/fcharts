import 'dart:math';

import 'package:fcharts/fcharts.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

final _random = new Random();

class Person {
  String name;
  int cookies;
  int brownies;
  int crackers;

  Person(this.name, this.cookies, this.brownies, this.crackers);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final stats = [
    new Person("A", 10, 2, 3),
    new Person("AB", 15, 4, 10),
    new Person("ABC", 8, 4, 11),
    new Person("ABCD", 6, 2, 20),
    new Person("E", 12, 5, 19),
    new Person("F", 10, 2, 4),
    new Person("G", 19, 4, 15),
  ];

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('FCharts Example'),
        ),
        body: new Center(
          child: new AspectRatio(
            aspectRatio: 4/3,
            child: new LineChart<Person>(
              data: stats,
              padding: new EdgeInsets.only(left: 100.0, bottom: 50.0, right: 60.0, top: 15.0),
              axes: [
                new XAxis(label: (stat) => stat.name),
                new YAxis(
                  label: (val) => val.toInt().toString(),
                  tickCount: 5,
                  range: new Range(0.0, 20.0),
                  position: ChartPosition.right,
                  stroke: new PaintOptions.stroke(color: Colors.green, strokeWidth: 2.0),
                ),
                new YAxis(
                  id: 'brownies',
                  label: (val) => val.toDouble().toString(),
                  tickCount: 11,
                  stroke: new PaintOptions.stroke(color: Colors.blue, strokeWidth: 2.0),
                  position: ChartPosition.right
                ),
              ],
              lines: [
                new Line(
                  value: (stat) => stat.cookies.toDouble(),
                  stroke: new PaintOptions.stroke(color: Colors.green, strokeWidth: 2.0),
                  fill: new PaintOptions(color: Colors.green.withOpacity(0.3)),
                  pointPaint: (stat) => [
                    new PaintOptions(color: Colors.green),
                  ],
                ),
                new Line(
                  value: (stat) => stat.brownies.toDouble(),
                  yAxisId: 'brownies',
                  stroke: new PaintOptions.stroke(color: Colors.blue, strokeWidth: 2.0),
                  fill: new PaintOptions(color: Colors.blue.withOpacity(0.3)),
                  pointPaint: (stat) => [
                    new PaintOptions(color: Colors.blue)
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            setState(() {
              int idx = _random.nextInt(stats.length);
              stats[idx].brownies = _random.nextInt(5);
              stats[idx].cookies = _random.nextInt(19);
            });
          },
          child: new Icon(Icons.refresh),
        ),
      ),
    );
  }
}
