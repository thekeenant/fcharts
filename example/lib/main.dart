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
  DateTime _releasedAt = new DateTime.now();

  @override
  Widget build(BuildContext context) {
    var ms = 200;
    if (_active == null) {
      final now = new DateTime.now();
      if (now.difference(_releasedAt) > new Duration(milliseconds: 50)) ms = 1000;
    }

    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Cookies & Brownies Consumption'),
        ),
        body: new Column(
          children: [
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
                  setState(() => _active = day);
                },
                onRelease: () {
                  setState(() {
                    _active = null;
                    _releasedAt = new DateTime.now();
                  });
                },
                data: days,
                animationDuration: new Duration(
                  milliseconds: ms,
                ),
                padding: new EdgeInsets.only(left: 40.0, bottom: 50.0, right: 40.0, top: 15.0),
                axes: [
                  new XAxis(label: (stat) => stat.name, size: 30.0),
                  new YAxis(
                    label: (val) => val.toInt().toString(),
                    tickCount: 5,
                    range: new Range(0.0, 16.0),
                    stroke: new PaintOptions.stroke(color: Colors.green, strokeWidth: 2.0),
                  ),
                  new YAxis(
                    id: 'brownies',
                    label: (val) => val.toDouble().toStringAsFixed(1),
                    tickCount: 11,
                    range: new Range(0.0, 8.0),
                    stroke: new PaintOptions.stroke(color: Colors.blue, strokeWidth: 2.0),
                    opposite: true,
                  ),
                ],
                lines: [
                  new Line(
                    name: 'Cookies',
                    value: (stat) => stat.cookies.toDouble(),
                    stroke: new PaintOptions.stroke(color: Colors.green, strokeWidth: 2.0),
                    pointPaint: (day) => [
                          new PaintOptions(
                            color: Colors.green,
                          ),
                        ],
                    pointRadius: (day) => _active == day ? 6.0 : 3.0,
                  ),
                  new Line(
                    name: 'Brownies',
                    value: (stat) => stat.brownies.toDouble(),
                    yAxisId: 'brownies',
                    stroke: new PaintOptions.stroke(color: Colors.blue, strokeWidth: 2.0),
                    pointPaint: (day) => [
                          new PaintOptions(
                            color: Colors.blue,
                          ),
                        ],
                    pointRadius: (day) => _active == day ? 6.0 : 3.0,
                  ),
                ],
                legend: new Legend(),
              ),
            ),
          ],
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
