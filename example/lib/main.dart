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
      new Datum(new DateTime(2018, 1), 0, 0),
      new Datum(new DateTime(2018, 2), 10, 7),
      new Datum(new DateTime(2018, 3), 20, 6),
      new Datum(new DateTime(2018, 4), 30, 4),
      new Datum(new DateTime(2018, 5), 80, 4),
      new Datum(new DateTime(2018, 6), 50, 2),
      new Datum(new DateTime(2018, 7), 0, 1),
    ];

    final axis1 = new CategoricalAxis<Datum, String>(
      measure: new CategoricalMeasure<String>(
        list: [
          "1",
          "2",
          "3",
          "4",
          "5",
          "6",
          "7",
          "8",
        ],
      ),
      tickLabelFn: (date) => date.toString(),
    );

    final axis2 = new ContinuousAxis<Datum, int>(
      measure: new NumMeasure<int>(
        span: new IntSpan(0, 100),
      ),
      tickLabelFn: (num) => num.toString(),
      opposite: false,
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
                new Line<Datum, String, int>(
                  data: data,
                  xFn: (day) => day.name,
                  yFn: (day) => day.cookies,
                  xAxis: axis1,
                  yAxis: axis2,
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
