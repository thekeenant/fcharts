import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:fcharts/util/color_palette.dart';
import 'package:fcharts/util/painting.dart';
import 'package:fcharts/util/merge_tween.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// A bar graph is a set of bar groups. Not to be confused with a bar chart,
/// which is strictly categorical data. A bar graph in this library's context
/// is any chart/graph represented using rectangles along axes (histogram, bar
/// chart, population pyramid, etc.).
@immutable
class BarGraphDrawable implements ChartDrawable<BarGraphDrawable> {
  final List<BarGroupDrawable> groups;

  const BarGraphDrawable({
    @required this.groups
  });

  /// Generate a randomized pretty bar graph!
  factory BarGraphDrawable.random() {
    var random = new math.Random();

    final groupCount = random.nextInt(4) + 1;
    final stackCount = 3;

    final groupWidthFraction = 0.75;
    final stackWidthFraction = 0.9;

    final groupDistance = 1 / groupCount;
    final groupWidth = groupDistance * groupWidthFraction;

    final startX = groupDistance * (1 - groupWidthFraction) / 2;

    final groups = new List.generate(groupCount, (i) {
      final stackDistance = groupWidth / stackCount;
      final stackWidth = stackDistance * stackWidthFraction;

      final groupX = startX + i * groupDistance;

      final stacks = new List.generate(stackCount, (j) {
        final barCount = random.nextInt(4) + 1;

        final baseColor = ColorPalette.primary[j];
        final monochrome = new ColorPalette.monochrome(baseColor, barCount * 2);

        final stackX = groupX + j * stackDistance + stackDistance * (1 - stackWidthFraction) / 2;

        var lastMax = 0.0;

        final bars = new List.generate(barCount, (k) {
          final base = lastMax;
          final value = base + random.nextDouble() * 0.3;
          lastMax = value;

          return new BarDrawable(
            value: value.clamp(0.0, 1.0).toDouble(),
            base: base.clamp(0.0, 1.0).toDouble(),
            stackBase: 0.0,
            paint: [
              new PaintOptions(
                color: monochrome[k]
              )
            ],
          );
        });

        return new BarStackDrawable(
          x: stackX,
          width: stackWidth,
          bars: bars
        );
      });

      return new BarGroupDrawable(
        stacks: stacks,
      );
    });

    return new BarGraphDrawable(
      groups: groups
    );
  }

  @override
  void draw(CanvasArea area) {
    for (final group in groups) {
      group.draw(area);
    }
  }

  @override
  BarGraphDrawableTween tweenTo(BarGraphDrawable end) =>
    new BarGraphDrawableTween(this, end);

  @override
  BarGraphDrawable get empty => new BarGraphDrawable(
    groups: groups.map((group) {
      return new BarGroupDrawable(
        stacks: group.stacks.map((stack) {
          return stack.empty;
        }).toList()
      );
    }).toList()
  );
}

/// Lerp between two bar graphs.
class BarGraphDrawableTween extends ChartDrawableTween<BarGraphDrawable> {
  final MergeTween<BarGroupDrawable> _groupsTween;

  BarGraphDrawableTween(BarGraphDrawable begin, BarGraphDrawable end) :
      _groupsTween = new MergeTween(begin.groups, end.groups),
      super(begin: begin, end: end);

  @override
  BarGraphDrawable lerp(double t) {
    return new BarGraphDrawable(
      groups: _groupsTween.lerp(t)
    );
  }
}

/// A group of bar stacks.
@immutable
class BarGroupDrawable implements MergeTweenable<BarGroupDrawable> {
  /// The group of bar stacks.
  final List<BarStackDrawable> stacks;

  const BarGroupDrawable({
    @required this.stacks
  }) : assert(stacks != null);

  @override
  BarGroupDrawable get empty => new BarGroupDrawable(stacks: []);

  @override
  Tween<BarGroupDrawable> tweenTo(BarGroupDrawable other) {
    return new BarGroupDrawableTween(this, other);
  }

  void draw(CanvasArea graphArea) {
    for (final stack in stacks) {
      stack.draw(graphArea);
    }
  }
}

/// Lerp between two bar groups.
class BarGroupDrawableTween extends Tween<BarGroupDrawable> {
  final MergeTween<BarStackDrawable> _stacksTween;

  BarGroupDrawableTween(
    BarGroupDrawable begin,
    BarGroupDrawable end) :
      this._stacksTween = new MergeTween(begin.stacks, end.stacks),
      super(begin: begin, end: end);

  @override
  BarGroupDrawable lerp(double t) {
    return new BarGroupDrawable(
      stacks: _stacksTween.lerp(t),
    );
  }
}

/// A collection of bars stacked vertically one on top of the other.
/// It may contain any number of bars including 0.
@immutable
class BarStackDrawable implements MergeTweenable<BarStackDrawable> {
  /// The default implementation for collapsing a bar stack to nothing.
  /// It retains it's x value but removes all bars and shrinks to 0 width.
  ///
  /// This can be overridden on a per-barstack basis with [collapsed].
  static BarStackDrawable collapse(BarStackDrawable stack) => new BarStackDrawable(
    x: stack.x,
    width: 0.0,
    bars: []
  );

  /// The x position of the bar.
  /// It should usually be between 0 and 1.
  final double x;

  /// The width of a bar.
  /// It should usually be between 0 and 1.
  final double width;

  /// Collection of bars which will be stacked vertically
  /// on this stack.
  final List<BarDrawable> bars;

  /// The bar stack this stack collapses to when it disappears in an animation.
  final BarStackDrawable collapsed;

  const BarStackDrawable({
    @required this.x,
    @required this.width,
    @required this.bars,
    this.collapsed,
  }) :
    assert(x != null),
    assert(bars != null),
    assert(width != null),
    assert(bars != null);

  @override
  BarStackDrawable get empty => collapsed ?? collapse(this);

  @override
  Tween<BarStackDrawable> tweenTo(BarStackDrawable other) => new BarStackDrawableTween(this, other);

  void draw(CanvasArea chartArea) {
    for (final bar in bars) {
      // the size of the stack (stack width x chart height)
      final stackSize = new Size(width * chartArea.width, chartArea.height);

      // the area of the stack
      final stackArea = chartArea.child(
        new Offset(x * chartArea.width, 0.0) & stackSize
      );

      // draw the bar
      bar.draw(stackArea);
    }
  }
}

/// Lerp between two bar stacks.
class BarStackDrawableTween extends Tween<BarStackDrawable> {
  final MergeTween<BarDrawable> _barsTween;

  BarStackDrawableTween(BarStackDrawable begin, BarStackDrawable end) :
      _barsTween = new MergeTween(begin.bars, end.bars),
      super(begin: begin, end: end);

  @override
  BarStackDrawable lerp(double t) {
    return new BarStackDrawable(
      x: lerpDouble(begin.x, end.x, t),
      width: lerpDouble(begin.width, end.width, t),
      bars: _barsTween.lerp(t)
    );
  }
}

/// A segment of a stacked bar.
@immutable
class BarDrawable implements MergeTweenable<BarDrawable> {
  /// The default implementation for collapsing a bar to nothing. It collapses
  /// to the original bar's stack base.
  ///
  /// This result be overridden on a per-bar basis with [collapsed].
  static BarDrawable collapse(BarDrawable bar) => new BarDrawable(
    base: bar.stackBase ?? bar.base,
    stackBase: bar.stackBase,
    value: 0.0,
    paint: bar.paint,
    paintGenerator: bar.paintGenerator,
    widthFactor: bar.widthFactor,
    xOffset: bar.xOffset,
  );

  /// The base of the bar, usually between 0 and 1.
  /// A value of 0 means the bar starts at the base of the graph.
  final double base;

  /// The base of the entire stack. This is used only for animations.
  final double stackBase;

  /// The value of the bar, usually between 0 and 1.
  /// A value of 1 means the bar extends to the top of the graph.
  final double value;

  /// The options to use to generate the paint for this bar.
  final List<PaintOptions> paint;

  /// A method to generate paint based on the area where this
  /// bar is being drawn. Useful if you desire to draw based on
  /// the size of the bar on the screen.
  ///
  /// If [paintGenerator] is set, it overrides [paint].
  final PaintGenerator paintGenerator;

  /// A factor to apply to the width of this bar. This is
  /// multiplied by the width of the bar stack of which this is a part.
  final double widthFactor;

  /// An offset to apply to the x position of this bar. A value of 1.0
  /// means it is shifted 100% off its bar stack. It is usually 0.0.
  final double xOffset;

  /// The bar that this one collapses to when it disappears during an
  /// animation.
  final BarDrawable collapsed;

  const BarDrawable({
    @required this.value,
    @required this.base,
    @required this.stackBase,
    this.paint: const [const PaintOptions()],
    this.paintGenerator,
    this.widthFactor: 1.0,
    this.xOffset: 0.0,
    this.collapsed
  });

  BarDrawable copyWith({
    double value,
    double base,
    double stackBase,
    List<PaintOptions> paint,
    PaintGenerator paintGenerator,
    double widthFactor,
    double xOffset,
    BarDrawable collapsed
  }) {
    return new BarDrawable(
      value: value ?? this.value,
      base: base ?? this.base,
      stackBase: stackBase ?? this.stackBase,
      paint: paint ?? this.paint,
      paintGenerator: paintGenerator ?? this.paintGenerator,
      widthFactor: widthFactor ?? this.widthFactor,
      xOffset: xOffset ?? this.xOffset,
      collapsed: collapsed ?? this.collapsed
    );
  }

  /// Generate the paint options for the area in which this bar is to painted.
  List<PaintOptions> paintFor(CanvasArea area) {
    return paintGenerator == null ? paint : paintGenerator(area);
  }

  @override
  BarDrawable get empty {
    final collapsed = this.collapsed ?? collapse(this);
    // collapse the collapsed to itself
    return collapsed.copyWith(collapsed: collapsed);
  }

  @override
  Tween<BarDrawable> tweenTo(BarDrawable other) {
    return new BarDrawableTween(this, other);
  }

  void draw(CanvasArea stackArea) {
    if (value == null || base == null)
      return;

    // invert value (y is down, weirdo)
    final barTop = 1 - value;

    // height of the bar is the span of it (base -> value)
    // todo: this technically could be negative, which is okay, right?
    final barHeight = value - base;

    // how far the bar should be shifted right
    final actualXOffset = stackArea.width * xOffset;

    final actualTop = stackArea.height * barTop;
    final actualWidth = stackArea.width * widthFactor;
    final actualHeight = stackArea.height * barHeight;

    // the area of the bar
    CanvasArea barArea = stackArea.child(new Rect.fromLTWH(
      actualXOffset,
      actualTop,
      actualWidth,
      actualHeight
    ));

    // fill in the bar area
    for (final paint in paintFor(barArea)) {
      barArea.paint(paint);
    }
  }
}

/// Lerp between two bars.
class BarDrawableTween extends Tween<BarDrawable> {
  final MergeTween<PaintOptions> _paintTween;

  BarDrawableTween(BarDrawable begin, BarDrawable end) :
      this._paintTween = new MergeTween(begin.paint, end.paint),
      super(begin: begin, end: end);

  @override
  BarDrawable lerp(double t) {
    return new BarDrawable(
      base: lerpDouble(begin.base, end.base, t),
      stackBase: lerpDouble(begin.stackBase, end.stackBase, t),
      value: lerpDouble(begin.value, end.value, t),
      paint: _paintTween.lerp(t),
      paintGenerator: t < 0.5 ? begin.paintGenerator : end.paintGenerator,
      widthFactor: lerpDouble(begin.widthFactor, end.widthFactor, t),
      xOffset: lerpDouble(begin.xOffset, end.xOffset, t),
    );
  }
}