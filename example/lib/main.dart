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
    new Day("Day 1", 14, 7),
    new Day("Day 2", 13, 7),
    new Day("Day 3", 9, 6),
    new Day("Day 4", 9, 4),
    new Day("Day 5", 8, 4),
    new Day("Day 6", 6, 2),
    new Day("Day 7", 3, 1),
  ];

  Day _active;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Cookies & Brownies Consumption'),
        ),
        body: new Column(children: [
          new Padding(
            child: new Column(
              children: [
                new Text("Selected: ${_active?.name}"),
                new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  new Text("Cookies: ", style: new TextStyle(fontWeight: FontWeight.bold)),
                  new Text(_active?.cookies.toString()),
                ]),
                new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  new Text("Brownies: ", style: new TextStyle(fontWeight: FontWeight.bold)),
                  new Text(_active?.brownies.toString()),
                ]),
              ],
            ),
            padding: new EdgeInsets.all(50.0),
          ),
          new AspectRatio(
            aspectRatio: 4 / 3,
            child: new LineChart<Day>(
              onTouch: (day) {
                setState(() {
                  _active = day;
                });
              },
              onRelease: () {
                setState(() => _active = null);
              },
              data: days,
              padding: new EdgeInsets.only(left: 40.0, bottom: 50.0, right: 40.0, top: 15.0),
              axes: [
                new XAxis(label: (stat) => stat.name, size: 30.0),
                new YAxis(
                  label: (val) => val.toInt().toString(),
                  tickCount: 5,
                  range: new Range(0.0, 15.0),
                  position: ChartPosition.left,
                  stroke: new PaintOptions.stroke(color: Colors.green, strokeWidth: 2.0),
                ),
                new YAxis(
                  id: 'brownies',
                  label: (val) => val.toDouble().toStringAsFixed(1),
                  tickCount: 11,
                  range: new Range(0.0, 8.0),
                  stroke: new PaintOptions.stroke(color: Colors.blue, strokeWidth: 2.0),
                  position: ChartPosition.right,
                ),
              ],
              lines: [
                new Line(
                  value: (stat) => stat.cookies.toDouble(),
                  stroke: new PaintOptions.stroke(color: Colors.green, strokeWidth: 2.0),
                  pointPaint: (stat) => [new PaintOptions(color: Colors.green)],
                ),
                new Line(
                  value: (stat) => stat.brownies.toDouble(),
                  yAxisId: 'brownies',
                  stroke: new PaintOptions.stroke(color: Colors.blue, strokeWidth: 2.0),
                  pointPaint: (stat) => [new PaintOptions(color: Colors.blue)],
                ),
              ],
            ),
          ),
        ]),
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
