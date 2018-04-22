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
      new Datum(new DateTime(2018, 1), 100, 7),
      new Datum(new DateTime(2018, 2), 30, 7),
      new Datum(new DateTime(2018, 3), 42, 6),
      new Datum(new DateTime(2018, 4), 2, 4),
      new Datum(new DateTime(2018, 5), 10, 4),
      new Datum(new DateTime(2018, 6), 5, 2),
      new Datum(new DateTime(2018, 7), 8, 1),
    ];

    final xAxis = new ContinuousAxis<Datum, DateTime>(
      span: new TimeSpan(new DateTime(2018, 1), new DateTime(2018, 7)),
    );

    final yAxis1 = new ContinuousAxis<Datum, int>(
      span: new NumSpan(0, 100),
    );

    final yAxis2 = new ContinuousAxis<Datum, int>(
      span: new NumSpan(0, 50),
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
              lines: [
                new Line<Datum, DateTime, int>(
                  data: data,
                  xFn: (day) => day.time,
                  yFn: (day) => day.cookies,
                  xAxis: xAxis,
                  yAxis: yAxis1,
                  stroke: new PaintOptions.stroke(color: Colors.green, strokeWidth: 2.0),
                  fill: new PaintOptions(color: Colors.green[200].withOpacity(0.8)),
                ),
                new Line<Datum, DateTime, int>(
                  data: data,
                  xFn: (day) => day.time,
                  yFn: (day) => day.brownies,
                  xAxis: xAxis,
                  yAxis: yAxis2,
                  stroke: new PaintOptions.stroke(color: Colors.blue, strokeWidth: 2.0),
                  fill: new PaintOptions(color: Colors.blue[200].withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
