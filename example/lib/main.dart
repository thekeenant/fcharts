import 'package:fcharts/fcharts.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class Datum {
  DateTime time;
  int cookies;
  int brownies;

  Datum(this.time, this.cookies, this.brownies);

  String get name => time.month.toString();

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
      new Datum(new DateTime(2018, 1, 1), 0, 0),
      new Datum(new DateTime(2018, 1, 2), 10, 7),
      new Datum(new DateTime(2018, 1, 3), 50, 6),
      new Datum(new DateTime(2018, 1, 4), 30, 4),
      new Datum(new DateTime(2018, 1, 5), 100, 4),
      new Datum(new DateTime(2018, 1, 6), 50, 2),
      new Datum(new DateTime(2018, 1, 7), 48, 1),
    ];

    final xAxis = new ChartAxis<DateTime>(
      spanFn: (values) {
        values.sort();
        return new TimeSpan(values.first, values.last);
      },
      tickLabelFn: (day) => "Day ${day.day}",
      tickGenerator: IntervalTickGenerator.byDuration(
        const Duration(
          days: 1,
        ),
      ),
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
            aspectRatio: 4.0 / 3.0,
            child: new LineChart(
              lines: [
                new Line<Datum, DateTime, int>(
                  data: data,
                  xFn: (day) => day.time,
                  yFn: (day) => day.cookies,
                  curve: LineCurves.monotone,
                  xAxis: xAxis,
                  yAxis: new ChartAxis<int>(
                    span: new IntSpan(0, 100),
                    paint: new PaintOptions.stroke(color: Colors.green),
                    tickGenerator: IntervalTickGenerator.byN(25),
                  ),
                  stroke: new PaintOptions.stroke(
                    color: Colors.green,
                    strokeWidth: 2.0,
                  ),
                  marker: new MarkerOptions(
                    paint: [
                      new PaintOptions(color: Colors.green[700]),
                    ],
                    size: 4.0,
                    shape: MarkerShapes.circle,
                  ),
                ),
                new Line<Datum, DateTime, int>(
                  data: [
                    new Datum(new DateTime(2018, 1, 1), 15, 1),
                    new Datum(new DateTime(2018, 1, 2), 10, 100),
                    new Datum(new DateTime(2018, 1, 3), 30, 00),
                    new Datum(new DateTime(2018, 1, 4), 35, 60),
                    new Datum(new DateTime(2018, 1, 5), 40, 20),
                  ],
                  xFn: (day) => day.time,
                  yFn: (day) => day.cookies,
                  curve: LineCurves.monotone,
                  xAxis: xAxis,
                  yAxis: new ChartAxis<int>(
                    span: new IntSpan(0, 100),
                    paint: new PaintOptions.stroke(color: Colors.blue),
                    tickGenerator: IntervalTickGenerator.byN(10),
                    opposite: true,
                  ),
                  stroke: new PaintOptions.stroke(
                    color: Colors.blue,
                    strokeWidth: 2.0,
                  ),
                  marker: new MarkerOptions(
                    paint: [
                      new PaintOptions(color: Colors.blue[700]),
                    ],
                    size: 4.0,
                    shape: MarkerShapes.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
