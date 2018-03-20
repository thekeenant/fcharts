import 'package:fcharts/bar/drawable.dart';
import 'package:fcharts/util/charts.dart';

/// See [BarChart] or [Histogram].
abstract class BarGraph implements Chart {
  @override
  BarGraphDrawable createDrawable();

  List<double> scaledXValues();
}