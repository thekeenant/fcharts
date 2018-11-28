import 'package:fcharts/fcharts.dart';
import 'package:flutter/material.dart';

/// Our sparkline data.
const data = [0.0, -0.2, -0.9, -0.5, 0.0, 0.5, 0.6, 0.9, 0.8, 1.2, 0.5, 0.0];

class SparklineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4.0,
      child: LineChart(
        lines: [
          Sparkline(
            data: data,
            stroke: PaintOptions.stroke(
              color: Colors.blue,
              strokeWidth: 2.0,
            ),
            marker: MarkerOptions(
              paint: PaintOptions.fill(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
