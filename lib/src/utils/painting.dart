import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:fcharts/src/utils/merge_tween.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// An area on a canvas to paint.
@immutable
class CanvasArea {
  const CanvasArea._(this.canvas, this.rect, [this.isCanvas = false]);

  CanvasArea.fromCanvas(this.canvas, Size size)
      : rect = Offset.zero & size,
        isCanvas = true;

  /// the canvas this paint area resides
  final Canvas canvas;

  /// the painting area relative to the canvas (aka absolute)
  final Rect rect;

  /// true if this canvas area is the actual whole canvas
  final bool isCanvas;

  /// the width of the paint area
  double get width => size.width;

  /// the height of the paint area
  double get height => size.height;

  Offset get center => new Offset(width / 2, height / 2);

  /// the size of the paint area (the width and height)
  Size get size => rect.size;

  Rect get full => Offset.zero & size;

  /// Contract this canvas area inwards by a given [delta].
  CanvasArea contract(EdgeInsets delta) {
    final left = rect.left + delta.left;
    final top = rect.top + delta.top;
    final width = rect.width - delta.left - delta.right;
    final height = rect.height - delta.top - delta.bottom;
    return new CanvasArea._(
      canvas,
      new Rect.fromLTWH(left, top, width, height),
    );
  }

  /// Expand this canvas area outwards by a given [delta].
  /// This is the opposite of [contract].
  CanvasArea expand(EdgeInsets delta) {
    return contract(delta * -1.0);
  }

  /// Perform a draw operation within this area. This is done by
  /// translate to the top left of this area, then performing the draw,
  /// then restoring back.
  void performDraw(VoidCallback draw) {
    canvas.save();
    canvas.translate(rect.topLeft.dx, rect.topLeft.dy);
    draw();
    canvas.restore();
  }

  /// Fill this area with a paint.
  void paint(PaintOptions paint) {
    drawRect(Offset.zero & size, paint);
  }

  /// Construct a canvas area that resides somewhere within this canvas area.
  CanvasArea child(Rect child) {
    final offsetRect = child.shift(rect.topLeft);
    return new CanvasArea._(canvas, offsetRect);
  }

  /// Clips the canvas to this canvas area for the operations that exist
  /// within the [drawing] callback.
  void clipDrawing(VoidCallback drawing, [EdgeInsets padding]) {
    canvas.save();
    canvas.clipRect(padding == null ? rect : expand(padding).rect);
    drawing();
    canvas.restore();
  }

  /// Force a point into this area's bounds.
  Offset boundPoint(Offset p) => new Offset(
        p.dx.clamp(0.0, width < 1 ? 1 : width).toDouble(),
        p.dy.clamp(0.0, height < 1 ? 1 : height).toDouble(),
      );

  /// Force a rectangle into this area's bounds.
  Rect boundRect(Rect rect) => new Rect.fromPoints(
      boundPoint(rect.topLeft), boundPoint(rect.bottomRight));

  /// Draw an arc within a rectangle.
  void drawArc(
    Rect arcArea,
    double startAngle,
    double sweepAngle,
    PaintOptions paint,
  ) {
    performDraw(() {
      canvas.drawArc(
        arcArea,
        startAngle,
        sweepAngle,
        false,
        paint.build(
          rect: Offset.zero & arcArea.size,
        ),
      );
    });
  }

  /// Draw a rectangle.
  void drawRect(Rect rect, PaintOptions paint) {
    performDraw(() => canvas.drawRect(rect, paint.build(rect: rect)));
  }

  /// Draw a path.
  ///
  /// Warning: Make sure the path is within the bounds of this chart area
  /// by using [boundPoint]!
  void drawPath(Path path, PaintOptions paint, {Rect rect}) {
    performDraw(() => canvas.drawPath(path, paint.build(rect: rect)));
  }

  /// Draw a line.
  void drawLine(Offset p1, Offset p2, PaintOptions paint) {
    performDraw(() => canvas.drawLine(p1, p2, paint.build()));
  }

  void drawStar(
    Offset center,
    PaintOptions paint,
    int spikes,
    double outerRadius,
    double innerRadius,
  ) {
    var rot = pi / 2.0 * 3.0;
    var step = pi / spikes;

    var cx = center.dx;
    var cy = center.dy;
    var x = cx;
    var y = cy;

    final path = new Path();
    path.moveTo(cx, cy - outerRadius);

    for (var i = 0; i < spikes; i++) {
      // go out
      x = cx + cos(rot) * outerRadius;
      y = cy + sin(rot) * outerRadius;
      path.lineTo(x, y);
      rot += step;

      // go back in
      x = cx + cos(rot) * innerRadius;
      y = cy + sin(rot) * innerRadius;
      path.lineTo(x, y);
      rot += step;
    }

    path.lineTo(cx, cy - outerRadius);
    path.close();

    drawPath(path, paint);
  }

  /// Draw text.
  void drawText(
    Offset point,
    String text, {
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
    Offset shift: Offset.zero,
  }) {
    TextPainter painter = options.build(text);

    performDraw(() {
      canvas.save();
      canvas.translate(point.dx, point.dy);

      canvas.translate(0.0, 0.0);

      // pre shift before rotation transform
      canvas.translate(-shift.dx * painter.width, -shift.dy * painter.height);

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
    drawLine(Offset.zero, new Offset(size.width, size.height),
        new PaintOptions.stroke(color: color));
    drawLine(new Offset(0.0, size.height), new Offset(size.width, 0.0),
        new PaintOptions.stroke(color: color));
  }
}

/// Generate paint options based on an area in which the paint will be applied.
typedef List<PaintOptions> PaintGenerator(CanvasArea area);

/// Options for conveniently building a [Paint].
@immutable
class PaintOptions implements MergeTweenable<PaintOptions> {
  const PaintOptions._({
    this.color: Colors.black,
    this.strokeWidth: 1.0,
    this.strokeCap: StrokeCap.square,
    this.gradient,
    this.style: PaintingStyle.fill,
  });

  /// Construct paint options with fill style.
  const PaintOptions.fill({
    this.color: Colors.black,
    this.strokeWidth: 1.0,
    this.strokeCap: StrokeCap.butt,
    this.gradient,
  }) : this.style = PaintingStyle.fill;

  /// Construct paint options with stroke style.
  const PaintOptions.stroke({
    this.color: Colors.black,
    this.strokeWidth: 1.0,
    this.strokeCap: StrokeCap.butt,
    this.gradient,
  }) : this.style = PaintingStyle.stroke;

  bool operator ==(dynamic o) {
    if (o is PaintOptions) {
      return color == o.color &&
          strokeWidth == o.strokeWidth &&
          strokeCap == o.strokeCap &&
          gradient == o.gradient &&
          style == o.style;
    }
    return false;
  }

  @override
  int get hashCode {
    // TODO
    throw new UnimplementedError();
  }

  /// The color of the paint.
  final Color color;

  /// The width of the stroke.
  final double strokeWidth;

  /// How the ends of a stroke appear.
  final StrokeCap strokeCap;

  /// The gradient of the paint, overrides [color].
  final Gradient gradient;

  /// The style of the paint (fill/stroke).
  final PaintingStyle style;

  Paint build({Rect rect}) {
    final paint = new Paint();

    if (color != null) paint.color = color;

    // stroke
    if (strokeWidth != null) paint.strokeWidth = strokeWidth;
    if (strokeCap != null) paint.strokeCap = strokeCap;
    if (style != null) paint.style = style;

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
    return new PaintOptions._(
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeCap: strokeCap ?? this.strokeCap,
      gradient: gradient ?? this.gradient,
      style: style ?? this.style,
    );
  }

  static PaintOptions lerp(PaintOptions begin, PaintOptions end, double t) {
    final beginColor = begin?.color ?? Colors.transparent;
    final beginStyle = begin?.style ?? begin?.style;
    final endColor = end?.color ?? Colors.transparent;
    final endStyle = end?.style ?? end?.style;

    if (begin == null) {
      begin = new PaintOptions._(
        color: endColor.withOpacity(0.0),
        style: endStyle,
      );
    }
    if (end == null) {
      end = new PaintOptions._(
        color: beginColor.withOpacity(0.0),
        style: beginStyle,
      );
    }

    return new PaintOptions._(
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
        strokeWidth: 0.0,
      );
    }

    // otherwise fade to transparent gradient
    else {
      return this.copyWith(
        gradient: new LinearGradient(
          colors: [Colors.transparent, Colors.transparent],
        ),
        strokeWidth: 0.0,
      );
    }
  }

  @override
  Tween<PaintOptions> tweenTo(PaintOptions other) =>
      new _PaintOptionsTween(this, other);
}

/// Lerp between tow paint options.
class _PaintOptionsTween extends Tween<PaintOptions> {
  _PaintOptionsTween(PaintOptions begin, PaintOptions end)
      : super(begin: begin, end: end);

  @override
  PaintOptions lerp(double t) => PaintOptions.lerp(begin, end, t);
}

/// Options for conveniently building a [TextPainter].
@immutable
class TextOptions {
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

  /// The minimum width of the text area.
  final double minWidth;

  /// The maximum width of the text area.
  final double maxWidth;

  /// The maximum number of lines.
  final int maxLines;

  /// The ending of the text if it needs to be shortened (i.e. "...")
  final String ellipsis;

  /// The text's alignment within its text area.
  final TextAlign textAlign;

  /// The direction of the text.
  final TextDirection textDirection;

  /// The style of the text.
  final TextStyle style;

  /// The scale of the text (i.e. 2.0 means twice as large).
  final double scaleFactor;

  TextPainter build(String text) {
    TextPainter span = new TextPainter(
      text: new TextSpan(text: text, style: style),
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: ellipsis,
      textScaleFactor: scaleFactor,
    );

    // prevent layout from crashing
    var maxWidth = this.maxWidth;
    if (maxWidth != null && minWidth != null && maxWidth - minWidth < 0)
      maxWidth = minWidth + 1;

    span.layout(
      maxWidth: maxWidth ?? double.infinity,
      minWidth: minWidth ?? 0.0,
    );

    return span;
  }
}
