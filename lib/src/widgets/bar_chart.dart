import 'dart:collection';

import 'package:fcharts/src/bar/drawable.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/utils.dart';
import 'package:fcharts/src/widgets/base.dart';
import 'package:fcharts/src/widgets/chart_view.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'dart:math' as math;

class BarGroup {
  BarGroup({
    this.widthFactor: 0.75,
  });

  final double widthFactor;
}

class BarStack<Datum, Y> {
  BarStack({
    this.widthFactor: 0.9,
    this.baseFn,
  });

  final double widthFactor;
  final UnaryFunction<Datum, Y> baseFn;
}

class Bar<Datum, X, Y> {
  Bar({
    this.xAxis,
    this.yAxis,
    this.stack,
    this.xFn,
    this.valueFn,
  });

  final ChartAxis<X> xAxis;

  final ChartAxis<Y> yAxis;

  final BarStack<Datum, Y> stack;

  final BarGroup group = null;

  final UnaryFunction<Datum, X> xFn;

  final UnaryFunction<Datum, Y> valueFn;

  BarStack<Datum, Y> generateStack() => new BarStack<Datum, Y>();
}

class BarChart<Datum, X, Y> extends StatefulWidget {
  BarChart({
    @required this.data,
    @required this.bars,
  });

  final List<Datum> data;
  final List<Bar<Datum, X, Y>> bars;

  @override
  _BarChartState createState() => new _BarChartState<Datum, X, Y>();
}

class _BarChartState<Datum, X, Y> extends State<BarChart<Datum, X, Y>> {
  @override
  Widget build(BuildContext context) {
    final bars = widget.bars;

    final defaultBarGroup = new BarGroup();

    // group -> stacks
    final barGroups = new LinkedHashMap<BarGroup, List<BarStack>>();

    // stack -> bars
    final barStacks = <BarStack<Datum, Y>, List<Bar<Datum, X, Y>>>{};

    for (final bar in bars) {
      final stack = bar.stack ?? bar.generateStack();
      barStacks.putIfAbsent(stack, () => <Bar<Datum, X, Y>>[]);
      barStacks[stack].add(bar);

      final group = bar.group ?? defaultBarGroup;
      barGroups.putIfAbsent(group, () => <BarStack>[]);
      barGroups[group].add(stack);
    }

    // convert keys to list, order is kept by linked hashmap
    final barGroupList = barGroups.keys.toList();

    final groupDrawables = new List.generate(widget.data.length, (i) {
      final datum = widget.data[i];
      final stacks = barGroups[barGroupList.first];

      final groupWidth = 1.0;

      final stackDrawables = new List.generate(stacks.length, (j) {
        final stack = stacks[j];
        final bars = barStacks[stack];

        final stackWidth = 1 / (stacks.length * widget.data.length) * stack.widthFactor;

        double xPos;

        final barDrawables = new List.generate(bars.length, (k) {
          final bar = bars[k];

          final xAxis = bar.xAxis;
          final yAxis = bar.yAxis;

          final x = bar.xFn(datum);
          xPos = xAxis.span.toDouble(x);

          final value = bar.valueFn(datum);
          final yPos = yAxis.span.toDouble(value);

          return new BarDrawable(
            base: 0.0,
            stackBase: 0.0,
            value: yPos,
            paint: [
              const PaintOptions.fill(),
            ],
          );
        });

        final stackOffset = j - stacks.length / 2 + (1 - stack.widthFactor) / 2;

        return new BarStackDrawable(
          bars: barDrawables,
          width: stackWidth,
          x: xPos + stackOffset,
        );
      });

      return new BarGroupDrawable(
        stacks: stackDrawables,
      );
    });

    final barGraph = new BarGraphDrawable(
      groups: groupDrawables,
    );

    return new ChartView(
      charts: [
        barGraph,
      ],
    );
  }
}
