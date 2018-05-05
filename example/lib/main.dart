import 'package:fcharts/fcharts.dart';
import 'package:fcharts_example/bar/simple.dart';
import 'package:fcharts_example/line/cities.dart';
import 'package:fcharts_example/line/simple.dart';
import 'package:fcharts_example/line/sparkline.dart';
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
    'Simple Line Chart',
    new SimpleLineChart(),
    'Strings on the X-Axis and their index in the list on the Y-Axis.',
  ),
  new ChartExample(
    'City Coolness & Size Line Chart',
    new CityLineChart(),
    'Cities on the X-Axis with coolness & size on the Y-Axis with painted lines.',
  ),
  new ChartExample(
    'Random Sparkline Chart',
    new SparklineChart(),
    'Just a list of doubles was provided to the constructor.',
  ),
  new ChartExample(
    'Simple Bar Chart',
    new SimpleBarChart(),
    'Bar charts are not quite ready yet.',
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
                  child: new Container(
                    child: chart.widget,
                  )),
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
