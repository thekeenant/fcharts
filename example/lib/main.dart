import 'dart:math';

import 'package:fcharts/fcharts.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int index = 0;

  final _charts = new List<ChartView>.generate(4, (a) {
    return new ChartView(
      charts: [
        new LineChart.random(8),
        new LineChart.random(8),
        new LineChart.random(8)
      ],
      decor: new ChartDecor(
        axes: [
          new ChartAxis(
            position: AxisPosition.left,
            ticks: [
              new AxisTick(
                value: 0.5,
                width: 0.2,
                labelers: [
                  new TextTickLabeler(
                    text: 'Test',
                  ),
                  new NotchTickLabeler()
                ]
              )
            ]
          )
        ]
      )
    );
  });

  @override
  Widget build(BuildContext context) {
    final curr = _charts[index % _charts.length];

    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('FCharts Example'),
        ),
        body: new Center(
          child: new ChartView(
            charts: curr.charts,
            decor: curr.decor,
            chartPadding: new EdgeInsets.only(left: 50.0, right: 15.0, bottom: 25.0),
          ),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            setState(() {
              index++;
            });
          },
          child: new Icon(Icons.refresh),
        ),
      ),
    );
  }
}
