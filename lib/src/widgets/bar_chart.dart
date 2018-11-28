import 'dart:collection';

import 'package:fcharts/src/bar/drawable.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/utils.dart';
import 'package:fcharts/src/widgets/base.dart';
import 'package:fcharts/src/widgets/chart_view.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class BarGroup {
  BarGroup({
    this.widthFactor: 0.75,
  });

  final double widthFactor;
}

class BarStack<Y> {
  BarStack({
    this.widthFactor: 0.9,
    this.base,
  });

  final double widthFactor;
  final Y base;
}

class Bar<Datum, X, Y> {
  Bar({
    this.stack,
    this.xFn,
    this.valueFn,
    this.fill: const PaintOptions.fill(),
    this.stroke,
  });

  final BarStack<Y> stack;

  final UnaryFunction<Datum, X> xFn;

  final UnaryFunction<Datum, Y> valueFn;

  final PaintOptions fill;

  final PaintOptions stroke;

  List<PaintOptions> get paint {
    final result = <PaintOptions>[];
    if (fill != null) result.add(fill);
    if (stroke != null) result.add(stroke);
    return result;
  }

  BarStack<Y> generateStack() => new BarStack<Y>();
}

class BarChart<Datum, X, Y> extends StatefulWidget {
  BarChart({
    @required this.data,
    @required this.bars,
    @required this.xAxis,
    @required this.yAxis,
  });

  final List<Datum> data;

  final List<Bar<Datum, X, Y>> bars;

  final ChartAxis<X> xAxis;

  final ChartAxis<Y> yAxis;

  @override
  _BarChartState createState() => new _BarChartState<Datum, X, Y>();
}

class _BarChartState<Datum, X, Y> extends State<BarChart<Datum, X, Y>> {
  @override
  Widget build(BuildContext context) {
    final bars = widget.bars;
    final xAxis = widget.xAxis;
    final yAxis = widget.yAxis;

    final defaultBarGroup = new BarGroup();

    // group -> stacks
    final barGroups = new LinkedHashMap<BarGroup, Set<BarStack<Y>>>();

    // stack -> bars
    final barStacks = <BarStack<Y>, List<Bar<Datum, X, Y>>>{};

    for (final bar in bars) {
      final stack = bar.stack ?? bar.generateStack();
      barStacks.putIfAbsent(stack, () => []);
      barStacks[stack].add(bar);

      // todo
      final group = defaultBarGroup;
      barGroups.putIfAbsent(group, () => new Set());
      barGroups[group].add(stack);
    }

    // convert keys to list, order is kept by linked hashmap
    final barGroupList = barGroups.keys.toList();

    final groupDrawables = new List.generate(widget.data.length, (i) {
      final datum = widget.data[i];
      final stacks = barGroups[barGroupList.first].toList();

      final groupWidthFactor = 0.75;
      final groupWidth = groupWidthFactor * 1 / widget.data.length;

      final stackDrawables = new List.generate(stacks.length, (j) {
        final stack = stacks[j];
        final bars = barStacks[stack];

        double stackBase = 0.0;
        double base = stackBase;
        double xPos;

        final barDrawables = new List.generate(bars.length, (k) {
          final bar = bars[k];

          final x = bar.xFn(datum);
          xPos = xAxis.span.toDouble(x);

          final value = bar.valueFn(datum);
          final yPos = yAxis.span.toDouble(value);

          final currBase = base;
          base += yPos;

          return new BarDrawable(
            stackBase: stackBase,
            base: currBase,
            value: currBase + yPos,
            paint: bar.paint,
          );
        });

        var stackWidth = 1 / stacks.length * groupWidth;
        var groupOffset = -stackWidth * stacks.length / 2;
        var stackOffset = stackWidth * j + groupOffset;

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
