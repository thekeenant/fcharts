import 'package:fcharts/src/bar/drawable.dart';
import 'package:fcharts/src/chart.dart';

/// See [BarChartData] or [HistogramData].
abstract class BarGraphData implements ChartData {
  @override
  BarGraphDrawable createDrawable();

  List<double> scaledXValues();
}