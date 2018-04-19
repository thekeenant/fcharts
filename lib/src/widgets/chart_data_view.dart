import 'dart:math';

import 'package:fcharts/src/chart_data.dart';
import 'package:fcharts/src/chart_drawable.dart';
import 'package:fcharts/src/decor/decor.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// Used as a callback for touch/move pointer events. For each touch/move/release, a unique
/// [pointer] id is generated. The [data] parameter maps the chart index to the chart touch
/// data that the chart resolved to.
typedef void ChartTouchListener(int pointer, Map<int, ChartTouch> data);

/// Used as a callback for pointer release events. The [pointer] is the same unique id
/// used in the [ChartTouchListener] callback.
typedef void ChartTouchCallback(int pointer);

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
    this.animationDuration: const Duration(milliseconds: 400),
    this.animationCurve: Curves.fastOutSlowIn,
    this.onTouch,
    this.onMove,
    this.onRelease,
  })  : assert(charts != null),
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

  final ChartTouchListener onTouch;

  final ChartTouchListener onMove;

  final ChartTouchCallback onRelease;

  @override
  _ChartDataViewState createState() => new _ChartDataViewState();
}

class _ChartDataViewState extends State<ChartDataView>
    with TickerProviderStateMixin {
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
      fromCharts = widget.charts
          .map((c) => c.createDrawable().empty as ChartDrawable)
          .toList();
    } else {
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
      final matches =
          fromCharts.where((c) => c.runtimeType == drawable.runtimeType);

      ChartDrawable prevDrawable;

      if (matches.isEmpty) {
        // if there is no match, animate from empty
        prevDrawable = drawable.empty as ChartDrawable;
      } else {
        // otherwise we take the first match and remove it from the list,
        // to prevent other charts in the list from tweening from it
        prevDrawable = matches.first;
        fromCharts.remove(prevDrawable);
      }

      final tween = prevDrawable.tweenTo(drawable);
      toCharts.add(tween.animate(_curve) as Animation<ChartDrawable>);
    }

    return new _ChartPainter(
      charts: toCharts,
      decor: toDecor,
      rotation: rotation,
      chartPadding: chartPadding,
      repaint: _controller,
    );
  }

  void _updatePainter() {
    // TODO: Figure out why Duration.zero doesn't actually work...
    var duration = widget.animationDuration ?? Duration.zero;
    if (duration.inMilliseconds == 0) duration = new Duration(milliseconds: 1);

    _controller = new AnimationController(vsync: this, duration: duration);
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
    return new Listener(
      onPointerDown: (event) {
        if (widget.onTouch != null) {
          RenderBox box = _paintKey.currentContext.findRenderObject();
          Offset offset = box.globalToLocal(event.position);
          final events = _painter.resolveTouch(offset, box.size);
          if (events != null) widget.onTouch(event.pointer, events);
        }
      },
      onPointerMove: (event) {
        if (widget.onMove != null) {
          RenderBox box = _paintKey.currentContext.findRenderObject();
          Offset offset = box.globalToLocal(event.position);

          final events = _painter.resolveTouch(offset, box.size);
          if (events != null) widget.onMove(event.pointer, events);
        }
      },
      onPointerUp: (event) {
        if (widget.onRelease != null) {
          widget.onRelease(event.pointer);
        }
      },
      child: new CustomPaint(
        key: _paintKey,
        painter: _painter,
        child: new AspectRatio(aspectRatio: 1.0),
      ),
    );
  }
}

/// Paints animated [ChartDrawable] and [ChartDecor].
class _ChartPainter extends CustomPainter {
  final List<Animation<ChartDrawable>> charts;
  final Animation<ChartDecor> decor;
  final ChartRotation rotation;
  final EdgeInsets chartPadding;

  Size _size;

  _ChartPainter({
    @required this.charts,
    @required this.decor,
    @required this.rotation,
    @required this.chartPadding,
    @required Listenable repaint,
  }) : super(repaint: repaint);

  Map<int, ChartTouch> resolveTouch(Offset touch, Size boxSize) {
    final size = _size ?? boxSize;
    final touchChart = touch.translate(-chartPadding.left, -chartPadding.top);

    final width = size.width - chartPadding.left - chartPadding.right;
    final height = size.height - chartPadding.top - chartPadding.bottom;

    if (touchChart.dx < 0 || touchChart.dy < 0) return null;
    if (touchChart.dx > width || touchChart.dy > height) return null;

    final events = <int, ChartTouch>{};

    for (var i = 0; i < charts.length; i++) {
      final chart = charts[i];

      final event =
          chart.value.resolveTouch(new Size(width, height), touchChart);
      events[i] = event;
    }

    return events;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _size = size;

    // it is important to definitively not draw outside the canvas so we clip
    //  to the size of the canvas. subsequent drawings can be clipped further
    // (i.e. the chart should stay within its bounds, not reach outside the
    // canvas
    canvas.clipRect(Offset.zero & size);
    canvas.save();


    var canvasArea = new CanvasArea.fromCanvas(canvas, size);
    var chartArea = canvasArea.contract(chartPadding);

    if (decor != null) {
      decor.value.draw(canvasArea, chartArea);
    }

    Size rotatedCanvasSize;

    // rotate and translate canvas as necessary based on rotation
    canvas.rotate(rotation.theta);
    switch (rotation) {
      case ChartRotation.none:
        rotatedCanvasSize = size;
        break;
      case ChartRotation.upsideDown:
        rotatedCanvasSize = size;
        canvas.translate(-rotatedCanvasSize.width, -rotatedCanvasSize.height);
        break;
      case ChartRotation.clockwise:
        rotatedCanvasSize = size.flipped;
        canvas.translate(0.0, -rotatedCanvasSize.height);
        break;
      case ChartRotation.counterClockwise:
        rotatedCanvasSize = size.flipped;
        canvas.translate(-rotatedCanvasSize.width, 0.0);
        break;
    }

    var rotatedCanvasArea = new CanvasArea.fromCanvas(canvas, rotatedCanvasSize);
    var rotatedChartArea = rotatedCanvasArea.contract(chartPadding);

    for (final animation in charts) {
      final chart = animation.value;
      chart.draw(rotatedChartArea);
    }

    // restore to before clip (see start of method)
    canvas.restore();


  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
