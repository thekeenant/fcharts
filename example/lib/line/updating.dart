import 'package:fcharts/fcharts.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class UpdatingChart extends StatefulWidget {
  @override
  _UpdatingChartState createState() => _UpdatingChartState();
}

class _UpdatingChartState extends State<UpdatingChart> {
  var _data = [0.0, 1.0];
  Timer _timer;

  @override
  void initState() {
    var random = new Random();
    _timer = new Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _data.add(random.nextInt(100).toDouble());
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
      aspectRatio: 4.0,
      child: new LineChart(
        lines: [
          new Sparkline(
            data: _data,
            stroke: new PaintOptions.stroke(
              color: Colors.green,
              strokeWidth: 2.0,
            ),
            marker: new MarkerOptions(
              paint: new PaintOptions.fill(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}

