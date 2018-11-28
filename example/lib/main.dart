import 'bar/simple.dart';
import 'line/cities.dart';
import 'line/simple.dart';
import 'line/sparkline.dart';
import 'package:flutter/material.dart';

void main() => runApp(FChartsExampleApp());

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
  ChartExample(
    'Simple Line Chart',
    SimpleLineChart(),
    'Strings on the X-Axis and their index in the list on the Y-Axis.',
  ),
  ChartExample(
    'City Coolness & Size Line Chart',
    CityLineChart(),
    'Cities on the X-Axis with coolness & size on the Y-Axis with painted lines.',
  ),
  ChartExample(
    'Random Sparkline Chart',
    SparklineChart(),
    'Just a list of doubles was provided to the constructor.',
  ),
  ChartExample(
    'Simple Bar Chart',
    SimpleBarChart(),
    'Bar charts are not quite ready yet.',
  ),
];

class FChartsExampleApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<FChartsExampleApp> {
  var _chartIndex = 0;

  @override
  Widget build(BuildContext context) {
    final chart = charts[_chartIndex % charts.length];

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Example: ${chart.name}'),
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  chart.description,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Container(
                  child: chart.widget,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() => _chartIndex++);
          },
          child: Icon(Icons.refresh),
        ),
      ),
    );
  }
}
