import 'dart:math';

import 'package:flutter/material.dart';

/// A collection of similar colors.
class ColorPalette extends ColorSwatch<int> {
  /// Primary colors from material specs.
  static final ColorPalette primary = new ColorPalette.fromList(<Color>[
    Colors.blue[400],
    Colors.red[400],
    Colors.green[400],
    Colors.yellow[400],
    Colors.purple[400],
    Colors.orange[400],
    Colors.teal[400],
  ]);

  ColorPalette(Color primary, Map<int, Color> colors) :
      this.length = colors.length,
      super(primary.value, colors);

  factory ColorPalette.fromList(List<Color> colors) {
    final map = new Map.fromIterables(
      new List.generate(colors.length, (i) => i),
      colors
    );
    return new ColorPalette(map[0], map);
  }

  factory ColorPalette.monochrome(Color base, int length) {
    return new ColorPalette.fromList(new List.generate(
      length,
        (i) => _brighterColor(base, i, length),
    ));
  }

  /// The number of colors in this palette.
  final int length;

  /// Pick a random color from the palette.
  Color random(Random random) => this[random.nextInt(length)];

  static Color _brighterColor(Color base, int i, int n) {
    return new Color.fromARGB(
      base.alpha,
      _brighterComponent(base.red, i, n),
      _brighterComponent(base.green, i, n),
      _brighterComponent(base.blue, i, n));
  }

  static int _brighterComponent(int base, int i, int n) {
    return (base + i * (255 - base) / n).floor();
  }
}