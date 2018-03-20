import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:fcharts/util/merge_tween.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// Generate paint options based on an area in which the paint will be applied.
typedef List<PaintOptions> PaintGenerator(CanvasArea area);

/// Lerp between tow paint options.
class PaintOptionsTween extends Tween<PaintOptions> {
  PaintOptionsTween(PaintOptions begin, PaintOptions end) : super(begin: begin, end: end);

  @override
  PaintOptions lerp(double t) => PaintOptions.lerp(begin, end, t);
}

/// Options for conveniently building a [Paint].
@immutable
class PaintOptions implements MergeTweenable<PaintOptions> {
  final Color color;
  final double strokeWidth;
  final StrokeCap strokeCap;
  final Gradient gradient;
  final PaintingStyle style;

  const PaintOptions({
    this.color: Colors.black,
    this.strokeWidth: 1.0,
    this.strokeCap: StrokeCap.butt,
    this.gradient,
    this.style: PaintingStyle.fill
  });

  const PaintOptions.stroke({
    this.color: Colors.black,
    this.strokeWidth: 1.0,
    this.strokeCap: StrokeCap.butt,
    this.gradient
  }) : this.style = PaintingStyle.stroke;

  Paint build({Rect rect}) {
    final paint = new Paint();

    if (color != null)
      paint.color = color;

    // stroke
    if (strokeWidth != null)
      paint.strokeWidth = strokeWidth;
    if (strokeCap != null)
      paint.strokeCap = strokeCap;
    if (style != null)
      paint.style = style;

    // gradient used for rectangles
    if (gradient != null && rect != null)
      paint.shader = gradient.createShader(rect);

    return paint;
  }

  PaintOptions copyWith({
    Color color,
    double strokeWidth,
    StrokeCap strokeCap,
    Gradient gradient,
    PaintingStyle style,
  }) {
    return new PaintOptions(
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeCap: strokeCap ?? this.strokeCap,
      gradient: gradient ?? this.gradient,
      style: style ?? this.style,
    );
  }

  static PaintOptions lerp(PaintOptions begin, PaintOptions end, double t) {
    if (begin == null)
      begin = const PaintOptions(color: Colors.transparent);
    if (end == null)
      end = const PaintOptions(color: Colors.transparent);

    return new PaintOptions(
      color: Color.lerp(begin.color, end.color, t),
      strokeWidth: lerpDouble(begin.strokeWidth, end.strokeWidth, t),
      strokeCap: t < 0.5 ? begin.strokeCap : end.strokeCap,
      gradient: Gradient.lerp(begin.gradient, end.gradient, t),
      style: t < 0.5 ? begin.style : end.style,
    );
  }

  @override
  PaintOptions get empty {
    // if we dont have a gradient, then fade to transparent color
    if (gradient == null) {
      return this.copyWith(
        color: Colors.transparent,
        strokeWidth: 0.0
      );
    }

    // otherwise fade to transparent gradient
    else {
      return this.copyWith(
        color: null,
        gradient: new LinearGradient(
          colors: [
            Colors.transparent,
            Colors.transparent
          ],
        ),
        strokeWidth: 0.0
      );
    }
  }

  @override
  Tween<PaintOptions> tweenTo(PaintOptions other) =>
    new PaintOptionsTween(this, other);
}

/// Options for conveniently building a [TextPainter].
@immutable
class TextOptions {
  final double minWidth;
  final double maxWidth;
  final int maxLines;
  final String ellipsis;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final TextStyle style;
  final double scaleFactor;

  const TextOptions({
    this.minWidth,
    this.maxWidth,
    this.maxLines,
    this.ellipsis,
    this.textAlign: TextAlign.left,
    this.textDirection: TextDirection.ltr,
    this.style: const TextStyle(color: Colors.black),
    this.scaleFactor: 1.0,
  });

  TextPainter build(String text) {
    TextPainter span = new TextPainter(
      text: new TextSpan(
        text: text,
        style: style
      ),
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: ellipsis,
      textScaleFactor: scaleFactor
    );

    // prevent layout from crashing
    var maxWidth = this.maxWidth;
    if (maxWidth - minWidth < 0)
      maxWidth = minWidth + 1;

    span.layout(
      maxWidth: maxWidth ?? double.INFINITY,
      minWidth: minWidth ?? 0.0
    );

    return span;
  }
}

abstract class ChartDrawableTween<T extends ChartDrawable<T>> extends Tween<T> {
  ChartDrawableTween({@required T begin, @required T end}) :
    super(begin: begin, end: end);
}

abstract class ChartDrawable<T extends ChartDrawable<T>> extends MergeTweenable<T> {
  void draw(CanvasArea area);
}

/// An area on a canvas to paint.
class CanvasArea {
  /// the canvas this paint area resides
  final Canvas canvas;

  /// the painting area relative to the canvas (aka absolute)
  final Rect rect;

  CanvasArea(this.canvas, this.rect) {
    // hehe
    drawDebugCross();
  }

  /// the width of the paint area
  double get width => size.width;

  /// the height of the paint area
  double get height => size.height;

  /// the size of the paint area (the width and height)
  Size get size => rect.size;

  /// Contract this canvas area inwards by a given [delta].
  CanvasArea contract(EdgeInsets delta) {
    return new CanvasArea(canvas, new Rect.fromLTWH(
      rect.left + delta.left,
      rect.top + delta.top,
      rect.width - delta.left - delta.right,
      rect.height - delta.top - delta.bottom
    ));
  }

  /// Expand this canvas area outwards by a given [delta]. 
  /// This is the opposite of [contract].
  CanvasArea expand(EdgeInsets delta) {
    return contract(delta * -1.0);
  }

  /// Perform a draw operation within this area. This is done by
  /// translate to the top left of this area, then performing the draw,
  /// then restoring back.
  void _performDraw(VoidCallback draw) {
    canvas.save();
    canvas.translate(rect.topLeft.dx, rect.topLeft.dy);
    draw();
    canvas.restore();
  }

  /// Fill this area with a paint.
  void paint(PaintOptions paint) {
    drawRect(Offset.zero & size, paint);
  }

  /// Draw an arc within a rectangle.
  void drawArc(Rect arcArea, double startAngle, double sweepAngle, PaintOptions paint) {
    _performDraw(() {
      canvas.drawArc(
        arcArea,
        startAngle,
        sweepAngle,
        false,
        paint.build(rect: arcArea)
      );
    });
  }

  /// Draw a rectangle.
  void drawRect(Rect rect, PaintOptions paint) {
    _performDraw(() => canvas.drawRect(rect, paint.build(rect: rect)));
  }

  /// Draw a path.
  void drawPath(Path path, PaintOptions paint, {Rect rect}) {
    _performDraw(() => canvas.drawPath(path, paint.build(rect: rect)));
  }

  /// Draw a line.
  void drawLine(Offset p1, Offset p2, PaintOptions paint) {
    _performDraw(() => canvas.drawLine(p1, p2, paint.build()));
  }

  /// Draw text.
  void drawText(Offset point, String text, {
    TextOptions options: const TextOptions(),
    double rotation: 0.0,
    Offset rotationOrigin: Offset.zero,

    /// kind of like the anchor point of the drawing --
    /// i.e. (0.5, 0.5) means the text is drawn such that [point]
    ///      is the center of the text both horizontally and vertically.
    /// i.e. (0.0, 0.0), the default, means the text is drawn such that the
    ///      text appears below and to the right of [point]
    /// i.e. (1.0, 1.0) means the text is drawn such that the text is above
    ///      and to the left of [point].
    Offset shift: Offset.zero
  }) {
    TextPainter painter = options.build(text);

    final rwidth = painter.width * math.cos(rotation) + painter.height * math.sin(rotation);
    final rheight = painter.width * math.sin(rotation) + painter.height * math.cos(rotation);

    _performDraw(() {
      canvas.save();
      canvas.translate(point.dx, point.dy);

      canvas.translate(0.0, 0.0);

      // pre shift before rotation transform
      canvas.translate(
        -shift.dx * rwidth,
        -shift.dy * rheight
      );

      if (rotation != 0.0) {
        final dx = painter.width * rotationOrigin.dx;
        final dy = painter.height * rotationOrigin.dy;
        canvas.translate(dx, dy);
        canvas.rotate(rotation);
        canvas.translate(-dx, -dy);
      }

      painter.paint(canvas, Offset.zero);
      canvas.restore();
    });
  }

  /// Draw an X pattern (for debugging).
  void drawDebugCross({Color color: Colors.red}) {
    drawLine(Offset.zero, new Offset(size.width, size.height), new PaintOptions(color: color));
    drawLine(new Offset(0.0, size.height), new Offset(size.width, 0.0), new PaintOptions(color: color));
  }

  /// Construct a canvas area that resides somewhere within this canvas area.
  CanvasArea child(Rect child) {
    final offsetRect = child.shift(rect.topLeft);
    return new CanvasArea(canvas, offsetRect);
  }
}