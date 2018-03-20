import 'dart:math' as math;

import 'package:fcharts/src/bar/bar_graph.dart';
import 'package:fcharts/src/bar/drawable.dart';
import 'package:fcharts/src/chart.dart';
import 'package:fcharts/src/util/color_palette.dart';
import 'package:fcharts/src/painting.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
class BarChartData implements BarGraphData {
  BarChartData({
    @required this.groups,
    @required this.groupWidthFraction
  });

  final List<BarGroupData> groups;
  final double groupWidthFraction;

  /// Generate a random bar chart.
  factory BarChartData.random() {
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
            paint: [new PaintOptions(color: color)]
          );
        });

        return new BarStackData(
          bars: bars,
          range: new Range(
            0.0,
            50.0
          ),
          base: bars.map((b) => b.base).reduce(math.min)
        );
      });

      return new BarGroupData(
        stacks: stacks,
        stackWidthFraction: 0.9,
      );
    });

    return new BarChartData(
      groups: groups,
      groupWidthFraction: 0.75,
    );
  }

  BarChartData copyWith({
    List<BarGroupData> groups,
    double groupWidthFraction
  }) {
    return new BarChartData(
      groups: groups ?? this.groups,
      groupWidthFraction: groupWidthFraction ?? this.groupWidthFraction
    );
  }

  @override
  BarGraphDrawable createDrawable() {
    final groupDistance = 1 / groups.length;
    final groupWidth = groupDistance * groupWidthFraction;

    final graphX = groupDistance * (1 - groupWidthFraction) / 2;

    var i = 0;
    final groupDrawables = groups.map((group) {
      final stackDistance = groupWidth / group.stacks.length;
      final stackWidthFraction = group.stackWidthFraction;
      final stackWidth = stackDistance * stackWidthFraction;

      final groupX = graphX + i * groupDistance;

      var j = 0;
      final stackDrawables = group.stacks.map((stack) {
        final range = stack.range;
        final yOffset = range.min / range.span;
        final stackX = groupX + j * stackDistance + stackDistance * (1 - stackWidthFraction) / 2;

        final barDrawables = stack.bars.map((bar) {
          bool isNull = bar.base == null || bar.value == null;

          final scaledBase = isNull ? null : bar.base / range.span - yOffset;
          final scaledValue = isNull ? null : bar.value / range.span - yOffset;

          return new BarDrawable(
            base: scaledBase,
            value: scaledValue,
            stackBase: stack.base,
            paint: bar.paint,
            paintGenerator: bar.paintGenerator,
          );
        });

        j++;
        return new BarStackDrawable(
          x: stackX,
          width: stackWidth,
          bars: barDrawables.toList()
        );
      });

      i++;
      return new BarGroupDrawable(
        stacks: stackDrawables.toList()
      );
    });

    return new BarGraphDrawable(
      groups: groupDrawables.toList()
    );
  }

  @override
  List<double> scaledXValues() {
    final groupDistance = 1 / groups.length;

    return new List.generate(groups.length, (i) {
      return groupDistance * i + groupDistance / 2;
    });
  }
}

@immutable
class BarGroupData {
  final List<BarStackData> stacks;
  final double stackWidthFraction;

  const BarGroupData({
    @required this.stacks,
    @required this.stackWidthFraction
  });

  BarGroupData copyWith({
    List<BarStackData> stacks,
    double stackWidthFraction
  }) {
    return new BarGroupData(
      stacks: stacks ?? this.stacks,
      stackWidthFraction: stackWidthFraction ?? this.stackWidthFraction
    );
  }
}

@immutable
class BarStackData {
  final List<BarData> bars;
  final Range range;
  final double base;

  const BarStackData({
    @required this.bars,
    @required this.range,
    @required this.base,
  });

  BarStackData copyWith({
    List<BarData> bars,
    Range range,
    double base
  }) {
    return new BarStackData(
      bars: bars ?? this.bars,
      range: range ?? this.range,
      base: base ?? this.base
    );
  }
}

@immutable
class BarData {
  final double value;
  final double base;
  final List<PaintOptions> paint;
  final PaintGenerator paintGenerator;

  const BarData({
    @required this.value,
    @required this.base,
    this.paint: const [const PaintOptions(color: Colors.black)],
    this.paintGenerator
  });

  BarData copyWith({
    double value,
    double base,
    List<PaintOptions> paint,
    PaintGenerator paintGenerator
  }) {
    return new BarData(
      value: value ?? this.value,
      base: base ?? this.base,
      paint: paint ?? this.paint,
      paintGenerator: paintGenerator ?? this.paintGenerator
    );
  }
}