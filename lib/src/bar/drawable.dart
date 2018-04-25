import 'dart:ui' show lerpDouble;

import 'package:fcharts/src/chart_drawable.dart';
import 'package:fcharts/src/utils/merge_tween.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class BarGraphTouch implements ChartTouch {}

/// A drawable bar graph.
@immutable
class BarGraphDrawable
    implements ChartDrawable<BarGraphDrawable, BarGraphTouch> {
  const BarGraphDrawable({
    @required this.groups,
  });

  final List<BarGroupDrawable> groups;

  @override
  void draw(CanvasArea area) {
    for (final group in groups) {
      group.draw(area);
    }
  }

  @override
  BarGraphDrawable get empty => new BarGraphDrawable(
        groups: groups.map((group) {
          return new BarGroupDrawable(
            stacks: group.stacks.map((stack) {
              return stack.empty;
            }).toList(),
          );
        }).toList(),
      );

  @override
  BarGraphTouch resolveTouch(Size area, Offset touch) {
    // todo
    return null;
  }

  @override
  _BarGraphDrawableTween tweenTo(BarGraphDrawable end) =>
      new _BarGraphDrawableTween(this, end);
}

/// Lerp between two bar graphs.
class _BarGraphDrawableTween extends Tween<BarGraphDrawable> {
  _BarGraphDrawableTween(BarGraphDrawable begin, BarGraphDrawable end)
      : _groupsTween = new MergeTween(begin.groups, end.groups),
        super(begin: begin, end: end);

  final MergeTween<BarGroupDrawable> _groupsTween;

  @override
  BarGraphDrawable lerp(double t) {
    return new BarGraphDrawable(
      groups: _groupsTween.lerp(t),
    );
  }
}

/// A group of bar stacks.
@immutable
class BarGroupDrawable implements MergeTweenable<BarGroupDrawable> {
  const BarGroupDrawable({
    @required this.stacks,
  }) : assert(stacks != null);

  /// The group of bar stacks.
  final List<BarStackDrawable> stacks;

  @override
  BarGroupDrawable get empty => new BarGroupDrawable(stacks: []);

  @override
  Tween<BarGroupDrawable> tweenTo(BarGroupDrawable other) {
    return new _BarGroupDrawableTween(this, other);
  }

  void draw(CanvasArea graphArea) {
    for (final stack in stacks) {
      stack.draw(graphArea);
    }
  }
}

/// Lerp between two bar groups.
class _BarGroupDrawableTween extends Tween<BarGroupDrawable> {
  _BarGroupDrawableTween(BarGroupDrawable begin, BarGroupDrawable end)
      : this._stacksTween = new MergeTween(begin.stacks, end.stacks),
        super(begin: begin, end: end);

  final MergeTween<BarStackDrawable> _stacksTween;

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
  const BarStackDrawable({
    @required this.x,
    @required this.width,
    @required this.bars,
    this.collapsed,
  })  : assert(x != null),
        assert(bars != null),
        assert(width != null),
        assert(bars != null);

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

  @override
  BarStackDrawable get empty => collapsed ?? collapse(this);

  @override
  Tween<BarStackDrawable> tweenTo(BarStackDrawable other) =>
      new _BarStackDrawableTween(this, other);

  void draw(CanvasArea chartArea) {
    for (final bar in bars) {
      // the size of the stack (stack width x chart height)
      final stackSize = new Size(width * chartArea.width, chartArea.height);

      // the area of the stack
      final stackArea =
          chartArea.child(new Offset(x * chartArea.width, 0.0) & stackSize);

      // draw the bar
      bar.draw(stackArea);
    }
  }

  /// The default implementation for collapsing a bar stack to nothing.
  /// It retains it's x value but removes all bars and shrinks to 0 width.
  ///
  /// This can be overridden on a per-barstack basis with [collapsed].
  static BarStackDrawable collapse(BarStackDrawable stack) =>
      new BarStackDrawable(
        x: stack.x,
        width: 0.0,
        bars: [],
      );
}

/// Lerp between two bar stacks.
class _BarStackDrawableTween extends Tween<BarStackDrawable> {
  _BarStackDrawableTween(BarStackDrawable begin, BarStackDrawable end)
      : _barsTween = new MergeTween(begin.bars, end.bars),
        super(begin: begin, end: end);

  final MergeTween<BarDrawable> _barsTween;

  @override
  BarStackDrawable lerp(double t) {
    return new BarStackDrawable(
        x: lerpDouble(begin.x, end.x, t),
        width: lerpDouble(begin.width, end.width, t),
        bars: _barsTween.lerp(t));
  }
}

/// A segment of a stacked bar.
@immutable
class BarDrawable implements MergeTweenable<BarDrawable> {
  const BarDrawable({
    @required this.value,
    @required this.base,
    @required this.stackBase,
    this.paint: const [const PaintOptions.fill()],
    this.paintGenerator,
    this.widthFactor: 1.0,
    this.xOffset: 0.0,
    this.collapsed,
  });

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

  BarDrawable copyWith({
    double value,
    double base,
    double stackBase,
    List<PaintOptions> paint,
    PaintGenerator paintGenerator,
    double widthFactor,
    double xOffset,
    BarDrawable collapsed,
  }) {
    return new BarDrawable(
      value: value ?? this.value,
      base: base ?? this.base,
      stackBase: stackBase ?? this.stackBase,
      paint: paint ?? this.paint,
      paintGenerator: paintGenerator ?? this.paintGenerator,
      widthFactor: widthFactor ?? this.widthFactor,
      xOffset: xOffset ?? this.xOffset,
      collapsed: collapsed ?? this.collapsed,
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
    return collapsed.copyWith(
      collapsed: collapsed,
    );
  }

  @override
  Tween<BarDrawable> tweenTo(BarDrawable other) {
    return new _BarDrawableTween(this, other);
  }

  void draw(CanvasArea stackArea) {
    if (value == null || base == null) return;

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
      actualHeight,
    ));

    // fill in the bar area
    for (final paint in paintFor(barArea)) {
      barArea.paint(paint);
    }
  }

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
}

/// Lerp between two bars.
class _BarDrawableTween extends Tween<BarDrawable> {
  _BarDrawableTween(BarDrawable begin, BarDrawable end)
      : this._paintTween = new MergeTween(begin.paint, end.paint),
        super(begin: begin, end: end);

  final MergeTween<PaintOptions> _paintTween;

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
