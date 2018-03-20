import 'package:fcharts/fcharts.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int index = 0;

  final _charts = new List<ChartDataView>.generate(10, (a) {
    return new ChartDataView(
      charts: [
        randomHistogram(15),
      ],
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
          child: new ChartDataView(
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
