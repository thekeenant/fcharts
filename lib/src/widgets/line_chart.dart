import 'package:fcharts/src/widgets/base.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

abstract class Chart<Datum> extends StatefulWidget {
  const Chart({
    Key key,
    @required this.data,
    @required this.axes,
  }) : super(key: key);

  final List<Datum> data;

  final List<AxisBase> axes;
}

class Line<Datum> {}

class LineChart<Datum> extends Chart<Datum> {
  const LineChart({
    Key key,
    @required List<Datum> data,
    @required List<AxisBase> axes,
  }) : super(
          key: key,
          data: data,
          axes: axes,
        );

  @override
  _LineChartState<Datum> createState() => new _LineChartState<Datum>();
}

class _LineChartState<Datum> extends State<LineChart> {
  @override
  Widget build(BuildContext context) {
    return new Container();
  }
}
