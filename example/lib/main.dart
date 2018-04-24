import 'package:fcharts_example/line/simple.dart';
import 'package:flutter/material.dart';

void main() => runApp(new FChartsExampleApp());

class ChartExample {
  ChartExample(this.name, this.widget);

  final String name;
  final Widget widget;
}

final charts = [
  new ChartExample('City Coolness', new SimpleLineChart()),
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
          child: new Padding(
            padding: new EdgeInsets.all(20.0),
            child: new AspectRatio(
              aspectRatio: 4/3,
              child: chart.widget,
            ),
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
