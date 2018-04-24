import 'package:fcharts_example/line/city_coolness.dart';
import 'package:fcharts_example/line/simple.dart';
import 'package:flutter/material.dart';

void main() => runApp(new FChartsExampleApp());

class ChartExample {
  ChartExample(
    this.name,
    this.widget,
    this.description,
  );

  final String name;
  final Widget widget;
  final String description;
}

final charts = [
  new ChartExample(
    'Simple',
    new SimpleLineChart(),
    'Strings on the X-Axis and their index in the list on the Y-Axis.',
  ),
  new ChartExample(
    'City Coolness',
    new CityCoolnessChart(),
    'Cities on the X-Axis and coolness on the Y-Axis with a painted line.',
  ),
];

class FChartsExampleApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<FChartsExampleApp> {
  var _chartIndex = 0;

  @override
  Widget build(BuildContext context) {
    final chart = charts[_chartIndex % charts.length];

    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Example: ${chart.name}'),
        ),
        body: new Container(
          decoration: new BoxDecoration(
            color: Colors.white,
          ),
          child: new Column(
            children: [
              new Padding(
                padding: new EdgeInsets.all(30.0),
                child: new Text(
                  chart.description,
                  textAlign: TextAlign.center,
                ),
              ),
              new Padding(
                padding: new EdgeInsets.all(20.0),
                child: new AspectRatio(
                  aspectRatio: 4 / 3,
                  child: chart.widget,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            setState(() => _chartIndex++);
          },
          child: new Icon(Icons.refresh),
        ),
      ),
    );
  }
}
