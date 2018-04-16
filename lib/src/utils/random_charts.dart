library fcharts.random_charts;

import 'dart:math' as math;

import 'package:fcharts/src/bar/data.dart';
import 'package:fcharts/src/line/data.dart';
import 'package:fcharts/src/utils/color_palette.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/span.dart';
import 'package:flutter/material.dart';

final _random = new math.Random();

/// Create random line chart data.
LineChartData randomLineChart(final int pointCount) {
  final random = new math.Random();

  final pointDistance = 1 / (pointCount - 1);

  var nextValue = random.nextDouble() * 0.2 - 0.1 + 0.5;

  final baseColor = ColorPalette.primary.random(random);
  final monochrome = new ColorPalette.monochrome(baseColor, 4);
  final color = monochrome[0];

  final points = new List.generate(pointCount, (i) {
    final x = pointDistance * i;
    final value = nextValue;

    nextValue += (random.nextDouble() - 0.5) * 0.2;

    return new LinePointData(
      x: x,
      y: (value).clamp(0.0, 1.0).toDouble(),
      paint: [new PaintOptions(color: color)],
    );
  });

  return new LineChartData(
    points: points,
    stroke: new PaintOptions.stroke(
        color: color, strokeWidth: 3.0, strokeCap: StrokeCap.round),
    fill: new PaintOptions(color: monochrome[3].withOpacity(0.4)),
    range: new Span(0.0, 1.0),
  );
}

/// Create a random histogram.
BarGraphData randomHistogram(int binCount) {
  final range = new Span(0.0, _random.nextDouble() * 100);

  final baseColor = ColorPalette.primary.random(_random);
  final palette = new ColorPalette.monochrome(baseColor, 3);
  final color = palette.random(_random);

// used for sin(theta)
  var theta = _random.nextDouble() * 5;

  final bins = new List.generate(binCount, (i) {
    final value = (math.sin(theta) * range.max * 0.9).abs();

    theta += _random.nextDouble() * 0.5;

    return new BinData(value: value, paint: [
      new PaintOptions(color: color),
      new PaintOptions(
        color: Colors.grey[800],
        style: PaintingStyle.stroke,
      ),
    ]);
  });

  return new BarGraphData.fromHistogram(
    bins: bins,
    range: range,
  );
}

/// Create random bar chart data.
BarGraphData randomBarChart() {
  var random = new math.Random();

  final groupCount = random.nextInt(3) + 2;
  final stackCount = random.nextInt(2) + 2;

  final groups = new List.generate(groupCount, (i) {
    final stacks = new List.generate(stackCount, (j) {
      final barCount = random.nextInt(3) + 1;

      final baseColor = ColorPalette.primary[j];
      final monochrome = new ColorPalette.monochrome(baseColor, barCount);

      var nextBase = 0.0;

      final bars = new List.generate(barCount, (k) {
        final base = nextBase;
        final value = base + random.nextInt(10) + 8;
        final color = monochrome[k];
        nextBase = value;

        return new BarData(
          value: value,
          base: base,
          paint: [new PaintOptions(color: color)],
        );
      });

      return new BarStackData(
        bars: bars,
        range: new Span(0.0, 50.0),
        base: bars.map((b) => b.base).reduce(math.min),
      );
    });

    return new BarGroupData(
      stacks: stacks,
      stackWidthFraction: 0.9,
    );
  });

  return new BarGraphData(
    groups: groups,
    groupWidthFraction: 0.75,
  );
}
