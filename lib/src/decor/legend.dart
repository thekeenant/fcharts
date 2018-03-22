import 'dart:math' as math;

import 'package:fcharts/src/utils/chart_position.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:flutter/material.dart';


enum LegendLayout {
  /// Each item is on the same horizontal plane, they are
  /// side by side, left to right.
  horizontal,

  /// Each item is on the same vertical plane, they are
  /// stacked above one another, top to bottom.
  vertical
}

/// TODO
class LegendData {
  LegendData({
    this.items,
    this.layout: LegendLayout.vertical,
    this.position: ChartPosition.right,
    this.offset: const Offset(0.0, 0.0)
  }) : assert(items != null),
       assert(layout != null),
       assert(position != null);

  final List<LegendItemData> items;

  final LegendLayout layout;

  final ChartPosition position;

  final Offset offset;

  void draw(CanvasArea fullArea, CanvasArea chartArea) {
    if (layout == LegendLayout.vertical) {
      final totalHeight = items.map((item) => item.height).fold(0.0, (a, b) => a + b);
      final maxWidth = items.map((item) => item.width).reduce(math.max);

      Offset topLeft;
      Size size;

      switch (position) {
        case ChartPosition.right:
          topLeft = chartArea.rect.centerRight.translate(0.0, -totalHeight / 2);
          size = new Size(
            fullArea.width - chartArea.width - chartArea.rect.left,
            totalHeight
          );
          break;
        case ChartPosition.left:
          topLeft = chartArea.rect.centerLeft.translate(-chartArea.rect.left, -totalHeight / 2);
          size = new Size(
            chartArea.rect.left,
            totalHeight
          );
          break;
        default:
          break;
      }

      final legendRect = (topLeft + offset) & size;
      final legendArea = fullArea.child(legendRect);

      for (var i = 0; i < items.length; i++) {
        final offset = i / items.length * legendRect.height;
        final legendItemArea = legendArea.child(new Rect.fromLTWH(
          0.0, offset, legendArea.width, legendRect.height / items.length
        ));
        items[i].draw(legendItemArea);
      }
    }
  }
}

class LegendItemData {
  LegendItemData({
    this.symbol,
    this.text: '',
    this.textStyle: const TextStyle(color: Colors.black),
    this.padding: const EdgeInsets.all(5.0),
    this.fixedWidth,
  });

  final LegendSymbol symbol;

  final String text;

  final TextStyle textStyle;

  final EdgeInsets padding;

  /// The fixed width of this legend item. When set to null, the width
  /// is automatically computed based on the width of the text and symbol.
  final double fixedWidth;

  void draw(CanvasArea area) {
    // contract area by padding
    area = area.contract(padding);

    // build text
    final textOptions = _textOptions;
    final textPainter = textOptions.build(text);

    // used to center vertically
    final maxHeight = math.max(textPainter.height, symbol.height);

    // draw the text
    final textArea = area.child(new Rect.fromLTWH(
      symbol.width, (maxHeight - textPainter.height), width - symbol.width, textPainter.height
    ));
    textArea.drawText(Offset.zero, text, options: textOptions);

    // draw symbol
    final symbolArea = area.child(new Rect.fromLTWH(
      0.0, (maxHeight - symbol.height) / 2, symbol.width, symbol.height
    ));
    symbol.draw(symbolArea);
  }

  TextOptions get _textOptions => new TextOptions(
    style: textStyle
  );

  /// The total height of this legend.
  double get height =>
    math.max(symbol.height, _textOptions.build(text).height) + padding.vertical;

  /// The total width of this legend.
  double get width =>
    math.max(symbol.width, _textOptions.build(text).width) + padding.vertical;
}


class LegendSquareSymbol implements LegendSymbol {
  LegendSquareSymbol({
    this.size: 14.0,
    this.paint
  });

  final double size;

  final List<PaintOptions> paint;

  @override
  void draw(CanvasArea area) {
    for (final paint in this.paint)
      area.paint(paint);
  }

  @override
  double get height => size;

  @override
  double get width => size;
}


abstract class LegendSymbol {
  void draw(CanvasArea area);

  double get height;

  double get width;
}