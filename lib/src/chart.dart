import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:fcharts/src/utils/merge_tween.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:meta/meta.dart';

/// Contains data for creating a drawable chart.
abstract class ChartData {
  /// Create a [ChartDrawable] from this chart
  ChartDrawable createDrawable();
}

/// A chart which can be drawn within a [CanvasArea].
abstract class ChartDrawable<T extends ChartDrawable<T>> extends MergeTweenable<T> {
  /// Draw the chart within a [CanvasArea]. It should scale according
  /// to the width and height of the area.
  void draw(CanvasArea area);
}