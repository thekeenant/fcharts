import 'package:fcharts/fcharts.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class Datum {
  DateTime time;
  int cookies;
  int brownies;

  Datum(this.time, this.cookies, this.brownies);

  @override
  String toString() {
    return 'Day($time, cookies=$cookies, brownies=$brownies)';
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    final data = [
      new Datum(new DateTime(2018, 1), 0, 7),
      new Datum(new DateTime(2018, 2), 10, 7),
      new Datum(new DateTime(2018, 3), 20, 6),
      new Datum(new DateTime(2018, 4), 30, 4),
      new Datum(new DateTime(2018, 5), 80, 4),
      new Datum(new DateTime(2018, 6), 50, 2),
      new Datum(new DateTime(2018, 7), 100, 1),
    ];

    final axis1 = new ContinuousAxis<Datum, DateTime>(
      span: new TimeSpan(new DateTime(2018, 1), new DateTime(2018, 7)),
      ticks: [
        new DateTime(2018, 1),
        new DateTime(2018, 2),
        new DateTime(2018, 3),
        new DateTime(2018, 4),
        new DateTime(2018, 5),
        new DateTime(2018, 6),
        new DateTime(2018, 7),
      ],
      tickLabelFn: (date) => date.month.toString(),
    );

    final axis2 = new ContinuousAxis<Datum, int>(
      span: new NumSpan(0, 100),
      ticks: [
        0,
        50,
        100
      ],
      tickLabelFn: (num) => num.toString(),
    );

    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Cookies & Brownies Consumption'),
        ),
        body: new Container(
          decoration: new BoxDecoration(
            color: Colors.white,
          ),
          child: new AspectRatio(
            aspectRatio: 4.0/3.0,
            child: new LineChart(
              vertical: true,
              lines: [
                new Line<Datum, DateTime, int>(
                  data: data,
                  xFn: (day) => day.time,
                  yFn: (day) => day.cookies,
                  xAxis: axis1,
                  yAxis: axis2,
                  stroke: new PaintOptions.stroke(color: Colors.green, strokeWidth: 2.0),
                  fill: new PaintOptions(color: Colors.green[200].withOpacity(0.8)),
                  marker: new MarkerOptions(
                    paint: [
                      new PaintOptions(color: Colors.green[700])
                    ],
                    size: 4.0
                  ),
                  curve: LineCurves.monotone,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
