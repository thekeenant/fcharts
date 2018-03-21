import 'package:fcharts/fcharts.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());


class Person {
  final String name;
  final int cookies;
  final int brownies;
  final int crackers;

  const Person(this.name, this.cookies, this.brownies, this.crackers);
}

const stats = const [
  const Person("A", 10, 2, 3),
  const Person("B", 15, 4, 10),
  const Person("C", 8, 4, 11),
  const Person("D", 6, 2, 20),
  const Person("E", 12, 5, 19),
  const Person("F", 10, 2, 4),
  const Person("G", 19, 4, 15),
];

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
              padding: new EdgeInsets.only(left: 60.0, bottom: 25.0, right: 15.0, top: 15.0),
              axes: [
                new XAxis(label: (stat) => stat.name),
                new YAxis(
                  label: (val) => val.toInt().toString(),
                  tickCount: 5,
                  range: new Range(0.0, 20.0),
                  stroke: new PaintOptions.stroke(color: Colors.green),
                ),
                new YAxis(
                  id: 'brownies',
                  label: (val) => val.toDouble().toString(),
                  tickCount: 11,
                  stroke: new PaintOptions.stroke(color: Colors.blue)
                ),
              ],
              lines: [
                new Line(
                  value: (stat) => stat.cookies.toDouble(),
                  stroke: new PaintOptions.stroke(color: Colors.green, strokeWidth: 2.0),
//                  fill: new PaintOptions(color: Colors.green.withOpacity(0.3)),
                  pointPaint: (stat) => [
                    new PaintOptions(color: Colors.green)
                  ],
                ),
                new Line(
                  value: (stat) => stat.brownies.toDouble(),
                  yAxisId: 'brownies',
                  stroke: new PaintOptions.stroke(color: Colors.blue, strokeWidth: 2.0),
//                  fill: new PaintOptions(color: Colors.blue.withOpacity(0.3)),
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
            // todo: nothing
          },
          child: new Icon(Icons.refresh),
        ),
      ),
    );
  }
}
