import 'package:fcharts/fcharts.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

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
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: new ChartView(
            charts: [
              new Histogram.random()
            ],
            decor: new ChartDecor(
              axes: [
                new ChartAxis(
                  range: new Range(0.0, 1.0),
                  position: AxisPosition.left,
                  paint: new PaintOptions.stroke(strokeWidth: 2.0),
                  ticks: [
                    new AxisTick(
                      value: 0.5,
                      width: 1.0,
                      labeler: new SimpleTickLabeler(
                        text: "Testing",
                        textStyle: new TextStyle(color: Colors.blue),
                      )
                    ),
                  ]
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}
