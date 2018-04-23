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
      new Datum(new DateTime(2018, 1, 3), 20, 6),
      new Datum(new DateTime(2018, 1, 4), 30, 4),
      new Datum(new DateTime(2018, 1, 5), 80, 4),
      new Datum(new DateTime(2018, 1, 6), 50, 2),
      new Datum(new DateTime(2018, 1, 7), 0, 1),
    ];

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
                  xAxis: new ContinuousAxis<DateTime>(
                    measure: new ContinuousMeasure<DateTime>(
                      span: new TimeSpan(data.first.time, data.last.time),
                      tickGenerator: IntervalTickGenerator.byDuration(
                        const Duration(
                          hours: 24,
                        ),
                      ),
                    ),
                    tickLabelFn: (time) => time.day.toString(),
                  ),
                  yAxis: new ContinuousAxis<int>(
                    measure: new ContinuousMeasure(
                      span: new IntSpan(0, 100),
                    ),
                    paint: new PaintOptions.stroke(color: Colors.green),
                  ),
                  stroke: new PaintOptions.stroke(
                    color: Colors.green,
                    strokeWidth: 2.0,
                  ),
                  fill: new PaintOptions(
                    color: Colors.green[200].withOpacity(0.5),
                  ),
                  marker: new MarkerOptions(
                    paint: [
                      new PaintOptions(color: Colors.green[700]),
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
