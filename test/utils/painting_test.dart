import 'package:test/test.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:flutter/material.dart';

void main() {
  test('Paint stroke vs fill', () {
    final stroke = new PaintOptions.stroke();
    final fill = new PaintOptions.fill();
    expect(stroke.style, equals(PaintingStyle.stroke));
    expect(fill.style, equals(PaintingStyle.fill));
  });

  test('Paint lerp', () {
    final begin = new PaintOptions.fill(
      color: new Color(0x11111111),
    );

    final end = new PaintOptions.fill(
      color: new Color(0x33333333),
    );

    final actual = PaintOptions.lerp(begin, end, 0.5);
    final expected = new PaintOptions.fill(
      color: Color.lerp(begin.color, end.color, 0.5),
    );

    expect(actual, equals(expected));
  });
}
