import 'dart:math' as math;

import 'package:fcharts/fcharts.dart';
import 'package:fcharts/src/utils/chart_position.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:flutter/material.dart';

import 'package:meta/meta.dart';

enum LegendLayout {
  /// Each item is on the same horizontal plane, they are
  /// side by side, left to right.
  horizontal,

  /// Each item is on the same vertical plane, they are
  /// stacked above one another, top to bottom.
  vertical
}

@immutable
class LegendDrawable {
  const LegendDrawable({
    this.items,
    this.layout: LegendLayout.vertical,
    this.position: ChartPosition.right,
    this.offset: const Offset(0.0, 0.0),
  })  : assert(items != null),
        assert(layout != null),
        assert(position != null);

  final List<LegendItemDrawable> items;

  final LegendLayout layout;

  final ChartPosition position;

  final Offset offset;

  void draw(CanvasArea fullArea, CanvasArea chartArea) {
    double width, height;

    if (layout == LegendLayout.vertical) {
      width = items.map((item) => item.width).reduce(math.max);
      height = items.map((item) => item.height).reduce((a, b) => a + b);
    } else {
      width = items.map((item) => item.width).reduce((a, b) => a + b);
      height = items.map((item) => item.height).reduce(math.max);
    }

    double x, y;
    Size size = new Size(width, height);

    switch (position) {
      case ChartPosition.right:
        x = chartArea.width;
        y = chartArea.height / 2 - height / 2;
        break;
      case ChartPosition.left:
        x = -width;
        y = chartArea.height / 2 - height / 2;
        break;
      case ChartPosition.top:
        x = chartArea.width / 2 - width / 2;
        y = -height;
        break;
      case ChartPosition.bottom:
        x = chartArea.width / 2 - width / 2;
        y = chartArea.height;
        break;
      default:
        break;
    }

    final legendRect = offset.translate(x, y) & size;
    final legendArea = chartArea.child(legendRect);

    var d = 0.0;
    if (layout == LegendLayout.vertical) {
      for (var i = 0; i < items.length; i++) {
        final curr = items[i];
        final legendItemArea = legendArea.child(new Rect.fromLTWH(
          (legendRect.width - curr.width) / 2,
          d,
          legendArea.width,
          legendRect.height / items.length,
        ));
        items[i].draw(legendItemArea);
        d += curr.height;
      }
    } else {
      for (var i = 0; i < items.length; i++) {
        final curr = items[i];
        final legendItemArea = legendArea.child(new Rect.fromLTWH(
          d,
          (legendRect.height - curr.height) / 2,
          legendArea.width / items.length,
          legendRect.height,
        ));
        curr.draw(legendItemArea);
        d += curr.width;
      }
    }
  }
}

@immutable
class LegendItemDrawable {
  const LegendItemDrawable({
    this.markerShape,
    this.markerPaint,
    this.text: '',
    this.textStyle: const TextStyle(color: Colors.black),
    this.padding: const EdgeInsets.all(0.0),
  });

  final MarkerShape markerShape;

  final List<PaintOptions> markerPaint;

  final String text;

  final TextStyle textStyle;

  final EdgeInsets padding;

  final markerSize = 10.0;

  void draw(CanvasArea area) {
    // contract area by padding
    area = area.contract(padding);

    // build text
    final textOptions = _textOptions;
    final textPainter = textOptions.build(text);

    // used to center vertically
    final maxHeight = math.max(textPainter.height, markerSize);

    // draw the text
    final textArea = area.child(new Rect.fromLTWH(
      markerSize,
      (maxHeight - textPainter.height),
      width - markerSize,
      textPainter.height,
    ));
    textArea.drawText(new Offset(3.0, 0.0), text, options: textOptions);

    // draw symbol
    final symbolArea = area.child(new Rect.fromLTWH(
      0.0,
      (maxHeight - markerSize) / 2,
      markerSize,
      markerSize,
    ));

    markerShape.draw(symbolArea, markerPaint);
  }

  TextOptions get _textOptions => new TextOptions(style: textStyle);

  /// The total height of this legend.
  double get height =>
      math.max(markerSize, _textOptions.build(text).height) + padding.vertical;

  /// The total width of this legend.
  double get width =>
      markerSize + _textOptions.build(text).width + padding.horizontal;
}

@immutable
class LegendSquareSymbol implements LegendSymbol {
  const LegendSquareSymbol({
    this.size: 14.0,
    this.paint,
  });

  final double size;

  final List<PaintOptions> paint;

  @override
  void draw(CanvasArea area) {
    for (final paint in this.paint) area.paint(paint);
  }

  @override
  double get height => size;

  @override
  double get width => size;
}

@immutable
abstract class LegendSymbol {
  void draw(CanvasArea area);

  double get height;

  double get width;
}
