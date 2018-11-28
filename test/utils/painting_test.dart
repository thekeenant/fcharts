import 'package:test/test.dart';
import 'package:fcharts/src/utils/painting.dart';
import 'package:flutter/material.dart';

void main() {
  test('Paint stroke vs fill', () {
    final stroke = PaintOptions.stroke();
    final fill = PaintOptions.fill();
    expect(stroke.style, equals(PaintingStyle.stroke));
    expect(fill.style, equals(PaintingStyle.fill));
  });

  test('Paint lerp', () {
    final begin = PaintOptions.fill(
      color: Color(0x11111111),
    );

    final end = PaintOptions.fill(
      color: Color(0x33333333),
    );

    final actual = PaintOptions.lerp(begin, end, 0.5);
    final expected = PaintOptions.fill(
      color: Color.lerp(begin.color, end.color, 0.5),
    );

    expect(actual, equals(expected));
  });
}
