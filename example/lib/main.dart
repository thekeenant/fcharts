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
    final rand = new Random();
    final yTicks = rand.nextInt(3) * 2 + 6;
    final histo = new Histogram.random(rand.nextInt(5) + 5);
    int rando = rand.nextInt(20) * 2 + 20;

    final xAxis = new ChartAxis(
      position: AxisPosition.bottom,
      paint: new PaintOptions.stroke(strokeWidth: 1.0),
      ticks: new List.generate(histo.bins.length + 1, (i) {
        final value = i / histo.bins.length;
        return new AxisTick(
          value: value,
          width: 1 / histo.bins.length,
          labelers: [
            new TextTickLabeler(text: ((value * rando).round() * 2).toStringAsFixed(0)),
            new NotchTickLabeler(paint: new PaintOptions.stroke(strokeWidth: 1.0))
          ],
        );
      })
    );

    final yAxis = new ChartAxis(
      position: AxisPosition.left,
      paint: new PaintOptions.stroke(strokeWidth: 1.0),
      ticks: new List.generate(yTicks + 1, (i) {
        final value = i / yTicks;
        return new AxisTick(
          value: value,
          width: (1 / yTicks),
          labelers: [
            new TextTickLabeler(text: value.toStringAsFixed(1)),
            new NotchTickLabeler(paint: new PaintOptions.stroke(strokeWidth: 1.0))
          ]
        );
      })
    );

    return new ChartView(
      charts: [
        histo
      ],
      decor: new ChartDecor(axes: [xAxis, yAxis]),
      chartPadding: new EdgeInsets.only(left: 50.0, right: 40.0, bottom: 25.0),
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
            chartPadding: curr.chartPadding
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
