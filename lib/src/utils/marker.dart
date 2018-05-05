import 'dart:math';
import 'dart:ui';

import 'package:fcharts/src/utils/painting.dart';

class MarkerOptions {
  const MarkerOptions({
    this.paint: const PaintOptions.fill(),
    this.shape: MarkerShapes.square,
    this.size: 3.0,
  });

  final PaintOptions paint;

  // TODO: list of paint vs single paint
  List<PaintOptions> get paintList => paint == null ? [] : [paint];

  final MarkerShape shape;

  final double size;
}

class MarkerShapes {
  /// All the available default marker shapes.
  static const List<MarkerShape> all = const [
    circle,
    square,
    plus,
    x,
    star,
    star6,
    star8,
    star12,
    triangle,
    pentagon,
    hexagon,
    horizontalLine,
    verticalLine,
  ];

  static const MarkerShape circle = const CircleMarkerShape();

  static const MarkerShape square = const SquareMarkerShape();

  static const MarkerShape plus = const PlusMarkerShape();

  static const MarkerShape x = const XMarkerShape();

  static const MarkerShape star = const StarMarkerShape();

  static const MarkerShape star6 = const StarMarkerShape(spikes: 6);

  static const MarkerShape star8 = const StarMarkerShape(spikes: 8);

  static const MarkerShape star12 = const StarMarkerShape(spikes: 12);

  static const MarkerShape triangle = const StarMarkerShape(
    spikes: 3,
    inset: 1 / 2,
  );

  static const MarkerShape pentagon = const StarMarkerShape(
    spikes: 5,
    inset: 1 / 5,
  );

  static const MarkerShape hexagon = const StarMarkerShape(
    spikes: 6,
    inset: 1 / 6,
  );

  /// A horizontal line with respect to the chart direction.
  static const MarkerShape horizontalLine = const LineMarkerShape();

  /// A vertical line with respect to the chart direction.
  static const MarkerShape verticalLine = const LineMarkerShape(vertical: true);
}

abstract class MarkerShape {
  void draw(CanvasArea area, List<PaintOptions> paints);
}

class CircleMarkerShape implements MarkerShape {
  const CircleMarkerShape();

  @override
  void draw(CanvasArea area, List<PaintOptions> paints) {
    for (final paint in paints) area.drawArc(area.full, 0.0, 2 * pi, paint);
  }
}

class SquareMarkerShape implements MarkerShape {
  const SquareMarkerShape();

  @override
  void draw(CanvasArea area, List<PaintOptions> paints) {
    for (final paint in paints) area.paint(paint);
  }
}

class PlusMarkerShape implements MarkerShape {
  const PlusMarkerShape();

  @override
  void draw(CanvasArea area, List<PaintOptions> paints) {
    final p1 = area.full.centerLeft;
    final p2 = area.full.centerRight;
    final p3 = area.full.topCenter;
    final p4 = area.full.bottomCenter;

    for (final paint in paints) {
      area.drawLine(p1, p2, paint);
      area.drawLine(p3, p4, paint);
    }
  }
}

class XMarkerShape implements MarkerShape {
  const XMarkerShape();

  @override
  void draw(CanvasArea area, List<PaintOptions> paints) {
    final p1 = area.full.topLeft;
    final p2 = area.full.bottomRight;
    final p3 = area.full.bottomLeft;
    final p4 = area.full.topRight;

    for (final paint in paints) {
      area.drawLine(p1, p2, paint);
      area.drawLine(p3, p4, paint);
    }
  }
}

class LineMarkerShape implements MarkerShape {
  const LineMarkerShape({
    this.vertical: false,
  });

  final bool vertical;

  @override
  void draw(CanvasArea area, List<PaintOptions> paints) {
    Offset p1, p2;

    if (vertical) {
      p1 = area.full.topCenter;
      p2 = area.full.bottomCenter;
    } else {
      p1 = area.full.centerLeft;
      p2 = area.full.centerRight;
    }

    for (final paint in paints) {
      area.drawLine(p1, p2, paint);
    }
  }
}

class StarMarkerShape implements MarkerShape {
  const StarMarkerShape({
    this.spikes: 5,
    this.inset: 0.5,
  });

  final int spikes;

  final double inset;

  @override
  void draw(CanvasArea area, List<PaintOptions> paints) {
    final center = area.center;

    // inner radius is 1/2 of width with the inset
    final inner = area.width / 2 - area.width * inset / 2;

    // outer radius is 1/2 the width
    final outer = area.width / 2;

    for (final paint in paints) {
      area.drawStar(center, paint, spikes, outer, inner);
    }
  }
}
