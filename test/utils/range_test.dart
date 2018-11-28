import 'package:test/test.dart';
import 'package:fcharts/src/utils/span.dart';

void main() {
  test('Range span', () {
    final range1 = DoubleSpan(0.0, 10.0);
    final range2 = DoubleSpan(-5.0, 5.0);

    expect(range1.length, equals(10.0));
    expect(range2.length, equals(10.0));
  });

  test('Range lerp', () {
    final from = DoubleSpan(0.0, 10.0);
    final to = DoubleSpan(10.0, 30.0);

    final lerp = DoubleSpan.lerp(from, to, 0.5);

    expect(lerp.min, equals(5.0));
    expect(lerp.max, equals(20.0));
  });
}
