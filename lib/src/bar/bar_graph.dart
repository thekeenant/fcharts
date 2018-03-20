import 'package:fcharts/src/bar/drawable.dart';
import 'package:fcharts/src/util/chart.dart';

/// See [BarChart] or [Histogram].
abstract class BarGraph implements Chart {
  @override
  BarGraphDrawable createDrawable();

  List<double> scaledXValues();
}