import 'package:fcharts/src/chart_data.dart';
import 'package:fcharts/src/chart_drawable.dart';
import 'package:fcharts/src/decor/decor.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'dart:math';

/// The rotation of a chart.
@immutable
class ChartRotation {
  /// rotated 0 degrees
  static const none = const ChartRotation._(0.0);
  /// rotated 180 degrees
  static const upsideDown = const ChartRotation._(pi);
  /// rotated 90 degrees clockwise
  static const clockwise = const ChartRotation._(pi / 2);
  /// rotated 90 degrees counter clockwise (270 clockwise)
  static const counterClockwise = const ChartRotation._(-pi / 2);

  const ChartRotation._(this.theta);

  /// The rotation in radians.
  final double theta;
}

/// A widget for displaying chart data.
class ChartDataView extends StatefulWidget {
  ChartDataView({
    @required this.charts,
    this.decor,
    this.rotation: ChartRotation.none,
    this.chartPadding: const EdgeInsets.all(0.0),
    this.animationDuration: const Duration(milliseconds: 500),
    this.animationCurve: Curves.fastOutSlowIn,
  }) :
      assert(charts != null),
      assert(rotation != null),
      assert(chartPadding != null),
      assert(animationCurve != null);

  /// The charts to draw within the view. The order of the list is the
  /// order that they are drawn (later means they are on top).
  final List<ChartData> charts;

  /// The chart decoration to use.
  final ChartDecor decor;

  /// The rotation of the chart.
  final ChartRotation rotation;

  /// The padding for the chart which gives room for the [decor]
  /// around the chart.
  final EdgeInsets chartPadding;

  /// The time it takes to animate from one chart to another. Set to null
  /// or [Duration.zero] to disable animation.
  final Duration animationDuration;

  /// The animation curve.
  final Curve animationCurve;

  @override
  _ChartDataViewState createState() => new _ChartDataViewState();
}

class _ChartDataViewState extends State<ChartDataView> with TickerProviderStateMixin {
  final GlobalKey _paintKey = new GlobalKey();

  AnimationController _controller;
  Animation<double> _curve;
  _ChartPainter _painter;

  _ChartPainter _createPainter() {
    final charts = widget.charts;
    final decor = widget.decor == null ? ChartDecor.none : widget.decor;
    final rotation = widget.rotation;
    final chartPadding = widget.chartPadding;

    // animate from these
    ChartDecor fromDecor;
    List<ChartDrawable> fromCharts;

    if (_painter == null) {
      fromDecor = ChartDecor.none;
      fromCharts = widget.charts.map((c) => c.createDrawable().empty).toList();
    }
    else {
      fromDecor = _painter.decor.value;
      fromCharts = _painter.charts.map((c) => c.value).toList();
    }

    // to these
    final toDecor = fromDecor.tweenTo(decor).animate(_curve);
    final toCharts = <Animation<ChartDrawable>>[];

    for (var i = 0; i < charts.length; i++) {
      final chart = charts[i];
      final drawable = chart.createDrawable();

      // find a chart which be tween to the new chart
      final matches = fromCharts.where((c) => c.runtimeType == drawable.runtimeType);

      ChartDrawable prevDrawable;

      if (matches.isEmpty) {
        // if there is no match, animate from empty
        prevDrawable = drawable.empty;
      }
      else {
        // otherwise we take the first match and remove it from the list,
        // to prevent other charts in the list from tweening from it
        prevDrawable = matches.first;
        fromCharts.remove(prevDrawable);
      }

      final tween = prevDrawable.tweenTo(drawable);
      toCharts.add(tween.animate(_curve));
    }

    return new _ChartPainter(
      charts: toCharts,
      decor: toDecor,
      rotation: rotation,
      chartPadding: chartPadding,
      repaint: _controller
    );
  }

  void _updatePainter() {
    _controller = new AnimationController(
      vsync: this,
      duration: widget.animationDuration ?? Duration.zero,
    );
    _curve = new CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    );

    _ChartPainter painter = _createPainter();
    setState(() {
      _painter = painter;
    });
    _controller.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(ChartDataView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePainter();
  }

  @override
  void initState() {
    super.initState();
    _updatePainter();
  }

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      key: _paintKey,
      painter: _painter,
      child: new AspectRatio(aspectRatio: 1.0),
    );
  }
}

/// Paints animated [ChartDrawable] and [ChartDecor].
class _ChartPainter extends CustomPainter {
  final List<Animation<ChartDrawable>> charts;
  final Animation<ChartDecor> decor;
  final ChartRotation rotation;
  final EdgeInsets chartPadding;

  _ChartPainter({
    @required this.charts,
    @required this.decor,
    @required this.rotation,
    @required this.chartPadding,
    @required Listenable repaint,
  }) :
      super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    // clip to canvas area
    canvas.clipRect(Offset.zero & size);
    canvas.save();

    Size canvasSize;

    // rotate and translate canvas as necessary based on rotation
    canvas.rotate(rotation.theta);
    switch (rotation) {
      case ChartRotation.none:
        canvasSize = size;
        break;
      case ChartRotation.upsideDown:
        canvasSize = size;
        canvas.translate(-canvasSize.width, -canvasSize.height);
        break;
      case ChartRotation.clockwise:
        canvasSize = size.flipped;
        canvas.translate(0.0, -canvasSize.height);
        break;
      case ChartRotation.counterClockwise:
        canvasSize = size.flipped;
        canvas.translate(-canvasSize.width, 0.0);
        break;
    }

    var canvasArea = new CanvasArea.fromCanvas(canvas, canvasSize);
    var chartArea = canvasArea;

    if (decor != null)
      chartArea = chartArea.contract(chartPadding);

    for (final animation in charts) {
      final chart = animation.value;
      chart.draw(chartArea);
    }

    if (decor != null)
      decor.value.draw(canvasArea, chartArea);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}