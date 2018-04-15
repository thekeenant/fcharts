import 'package:fcharts/src/decor/axis.dart';
import 'package:fcharts/src/decor/decor.dart';
import 'package:fcharts/src/decor/legend.dart';
import 'package:fcharts/src/decor/tick.dart';
import 'package:fcharts/src/line/curves.dart';
import 'package:fcharts/src/line/data.dart';
import 'package:fcharts/src/line/drawable.dart';
import 'package:fcharts/src/utils/chart_position.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:fcharts/src/utils/range.dart';
import 'package:fcharts/src/utils/utils.dart';
import 'package:fcharts/src/widgets/base.dart';
import 'package:fcharts/src/widgets/chart_data_view.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

typedef void LineChartCallback<Datum>(Datum touched);

@immutable
class LineChart<Datum> extends Chart<Datum> {
  const LineChart({
    this.data,
    this.lines,
    this.onTouch,
    this.onRelease,
    List<AxisBase<Datum>> axes: const [],
    EdgeInsets padding: const EdgeInsets.all(50.0),
    Curve animationCurve: Curves.fastOutSlowIn,
    Duration animationDuration: const Duration(milliseconds: 500),
    Legend legend,
  }) : super(
          axes: axes,
          padding: padding,
          legend: legend,
          animationCurve: animationCurve,
          animationDuration: animationDuration,
        );

  final List<Line<Datum>> lines;
  final List<Datum> data;
  final LineChartCallback<Datum> onTouch;
  final VoidCallback onRelease;

  @override
  _LineChartState<Datum> createState() => new _LineChartState();
}

class _LineChartState<Datum> extends State<LineChart<Datum>> {
  Map<int, int> _active = {};

  @override
  Widget build(BuildContext context) {
    final legend = widget.legend;
    final axes = widget.axes;
    final yAxes = widget.yAxes;
    final lines = widget.lines;
    final data = widget.data;
    final padding = widget.padding;

    final autoRanges = <AxisBase<Datum>, Range>{};

    final lineCharts = new List.generate(lines.length, (i) {
      final line = lines[i];

      final matches = yAxes.where((a) => a.id == line.yAxisId);

      if (matches.isEmpty)
        throw new StateError('No y-axis found for id: ${line.yAxisId}');
      else if (matches.length > 1)
        throw new StateError('Multiple y-axis with same id: ${line.yAxisId}');

      final yAxis = matches.first;
      var autoRange = new Range(double.maxFinite, -double.maxFinite);

      final linePoints = new List.generate(data.length, (j) {
        final datum = data[j];
        final x = j / (data.length - 1);
        final value = line.value(datum);

        if (value != null) {
          if (value < autoRange.min)
            autoRange = new Range(value, autoRange.max);
          if (value > autoRange.max)
            autoRange = new Range(autoRange.min, value);
        }

        return new LinePointData(
          x: x,
          value: yAxis.scale.apply(value),
          paint: line.pointPaint == null ? [] : line.pointPaint(datum),
          radius: line.pointRadius == null ? 3.0 : line.pointRadius(datum),
        );
      });

      autoRanges[yAxis] = autoRange;

      return new LineChartData(
        points: linePoints,
        range: (yAxis.range ?? autoRange).mapToScale(yAxis.scale),
        curve: line.curve,
        fill: line.fill,
        stroke: line.stroke,
      );
    });

    final axesPerPosition = <ChartPosition, List<AxisBase<Datum>>>{};
    for (var i = 0; i < axes.length; i++) {
      final axis = axes[i];
      axesPerPosition.putIfAbsent(axis.position, () => []);
      axesPerPosition[axis.position].add(axis);
    }

    final chartAxes = new List.generate(axes.length, (i) {
      final axis = axes[i];

      if (axis is XAxis<Datum>) {
        return new ChartAxisData(
            position: axis.position,
            paint: axis.stroke,
            size: axis.size,
            offset: axis.offset,
            ticks: new List.generate(data.length, (j) {
              final datum = data[j];
              final text = axis.labelFn(datum);

              final value = j / (data.length - 1);
              final width = 1 / data.length;

              return new AxisTickData(
                value: value,
                width: width,
                labelers: [
                  new TextTickLabeler(
                    text: text,
                    style: axis.labelStyle,
                  ),
                  new NotchTickLabeler(
                    paint: axis.stroke,
                  ),
                ],
              );
            }));
      } else if (axis is YAxis<Datum>) {
        final range = (axis.range ?? autoRanges[axis]).mapToScale(axis.scale);

        return new ChartAxisData(
          position: axis.position,
          paint: axis.stroke,
          size: axis.size,
          offset: axis.offset,
          ticks: new List.generate(range == null ? 0 : axis.tickCount, (j) {
            final value = j / (axis.tickCount - 1);
            final width = 1 / axis.tickCount;
            final rangedValue = axis.scale.invert(value * range.span + range.min);

            return new AxisTickData(
              value: value,
              width: width,
              labelers: [
                new TextTickLabeler(
                  text: axis.labelFn(rangedValue),
                  style: axis.labelStyle,
                ),
                new NotchTickLabeler(
                  paint: axis.stroke,
                ),
              ],
            );
          }),
        );
      }
    });

    LegendData legendData;
    if (legend != null) {
      final padding = legend.layout == LegendLayout.horizontal
          ? new EdgeInsets.only(right: 5.0)
          : new EdgeInsets.only(bottom: 5.0);

      legendData = new LegendData(
        layout: legend.layout,
        position: legend.position,
        offset: legend.offset,
        items: new List.generate(lines.length, (i) {
          final line = lines[i];

          return new LegendItemData(
            symbol: new LegendSquareSymbol(
              paint: [line.stroke.copyWith(style: PaintingStyle.fill)],
            ),
            text: line.name ?? "",
            padding: padding,
          );
        }),
      );
    }

    return new ChartDataView(
      charts: lineCharts,
      animationCurve: widget.animationCurve,
      animationDuration: widget.animationDuration,
      onMove: (pointer, data) {
        for (final touch in data.values) {
          int active = (touch as LineChartTouch).nearestHorizontally;
          if (_active[pointer] == active) return;
          setState(() {
            _active[pointer] = active;
          });

          if (widget.onTouch != null) widget.onTouch(widget.data[active]);
          break;
        }
      },
      onTouch: (pointer, data) {
        for (final touch in data.values) {
          int active = (touch as LineChartTouch).nearestHorizontally;
          setState(() {
            _active[pointer] = active;
          });

          if (widget.onTouch != null) widget.onTouch(widget.data[active]);
          break;
        }
      },
      onRelease: (pointer) {
        setState(() {
          _active.remove(pointer);
          if (widget.onRelease != null) widget.onRelease();
        });
      },
      decor: new ChartDecor(
        axes: chartAxes,
        legend: legendData,
      ),
      chartPadding: padding,
    );
  }
}

class Line<T> {
  Line({
    @required this.value,
    this.xAxisId,
    this.yAxisId,
    this.stroke: const PaintOptions.stroke(),
    this.fill,
    this.curve: LineCurves.monotone,
    this.pointPaint,
    this.pointRadius,
    this.name,
  });

  final UnaryFunction<T, double> value;
  final String xAxisId;
  final String yAxisId;
  final PaintOptions stroke;
  final PaintOptions fill;
  final LineCurve curve;
  final UnaryFunction<T, List<PaintOptions>> pointPaint;
  final UnaryFunction<T, double> pointRadius;
  final String name;
}
