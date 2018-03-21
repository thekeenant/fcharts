import 'package:fcharts/src/chart_drawable.dart';

/// Contains data for creating a drawable chart.
abstract class ChartData {
  /// Create a [ChartDrawable] from this chart
  ChartDrawable createDrawable();
}