import 'package:fcharts/src/chart_drawable.dart';

/// Contains data for creating a drawable chart.
abstract class ChartData<T extends ChartDrawable<T, ChartTouch>> {
  /// Create a [ChartDrawable] from this chart.
  T createDrawable();
}
