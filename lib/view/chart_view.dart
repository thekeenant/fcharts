import 'package:fcharts/util/charts.dart';
import 'package:fcharts/util/decor.dart';
import 'package:fcharts/util/painting.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:quiver/time.dart';

class _ChartPainter extends CustomPainter {
  final AnimationController controller;
  final List<Animation<ChartDrawable>> charts;
  final Animation<ChartDecor> decor;
  final ChartRotation rotation;

  _ChartPainter(this.controller, this.charts, this.decor, this.rotation) :
    super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    Rect canvasRect;

    // rotate and translate canvas as necessary based on rotation
    canvas.rotate(rotation.amount);
    switch (rotation) {
      case ChartRotation.none:
        canvasRect = Offset.zero & size;
        break;
      case ChartRotation.upsideDown:
        canvasRect = Offset.zero & size;
        canvas.translate(-canvasRect.width, -canvasRect.height);
        break;
      case ChartRotation.clockwise:
        canvasRect = Offset.zero & size.flipped;
        canvas.translate(0.0, -canvasRect.height);
        break;
      case ChartRotation.counterClockwise:
        canvasRect = Offset.zero & size.flipped;
        canvas.translate(-canvasRect.width, 0.0);
        break;
    }

    var canvasArea = new CanvasArea(canvas, canvasRect);
    var chartArea = canvasArea;

    if (decor != null)
      chartArea = chartArea.contract(new EdgeInsets.only(left: 40.0, bottom: 25.0, right: 15.0, top: 10.0));

    for (final animation in charts) {
      final chart = animation.value;
      chart.draw(chartArea);
    }

    if (decor != null)
      decor.value.draw(canvasArea, chartArea);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ChartView extends StatefulWidget {
  final List<Chart> charts;
  final ChartDecor decor;
  final ChartRotation rotation;

  ChartView({
    @required this.charts,
    this.decor,
    this.rotation: ChartRotation.none
  });

  @override
  _ChartViewState createState() => new _ChartViewState();
}

class _ChartViewState extends State<ChartView> with TickerProviderStateMixin {
  final GlobalKey _paintKey = new GlobalKey();

  AnimationController controller;
  Animation<double> curve;
  _ChartPainter _painter;

  @override
  void didUpdateWidget(ChartView oldWidget) {
    super.didUpdateWidget(oldWidget);

    var decor;
    if (_painter.decor != null)
      decor = new ChartDecorTween(_painter.decor.value, widget.decor).animate(curve);

    final charts = <Animation<ChartDrawable>>[];
    final previousAnimations = _painter.charts;

    for (var i = 0; i < widget.charts.length; i++) {
      final chart = widget.charts[i];
      final drawable = chart.createDrawable();

      final prevAnims = previousAnimations
        .where((a) => a.value.runtimeType == drawable.runtimeType);

      var prev;

      if (prevAnims.isNotEmpty) {
        prev = prevAnims.first.value;
        previousAnimations.remove(prevAnims.first);
      }
      else {
        prev = drawable.empty;
      }

      final tween = prev.tweenTo(drawable);
      final animation = tween.animate(curve);
      charts.add(animation as Animation<ChartDrawable>);
    }

    controller.forward(from: 0.0);

    setState(() {
      _painter = new _ChartPainter(controller, charts, decor, widget.rotation);
    });
  }

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
      vsync: this,
      duration: aSecond * 0.5
    );
    curve = new CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn
    );

    var decor;
    if (widget.decor != null)
      decor = new ChartDecorTween(widget.decor, widget.decor).animate(curve);

    final charts = <Animation<ChartDrawable>>[];

    for (var i = 0; i < widget.charts.length; i++) {
      final chart = widget.charts[i];
      final drawable = chart.createDrawable();

      final tween = drawable.empty.tweenTo(drawable);
      final animation = tween.animate(curve);
      charts.add(animation as Animation<ChartDrawable>);
    }

    _painter = new _ChartPainter(controller, charts, decor, widget.rotation);
    controller.forward(from: 0.0);
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
