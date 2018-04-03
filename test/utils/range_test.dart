import 'package:test/test.dart';
import 'package:fcharts/src/utils/range.dart';

void main() {
  test('Range span', () {
    final range1 = new Range(0.0, 10.0);
    final range2 = new Range(-5.0, 5.0);

    expect(range1.span, equals(10.0));
    expect(range2.span, equals(10.0));
  });

  test('Range lerp', () {
    final from = new Range(0.0, 10.0);
    final to = new Range(10.0, 30.0);

    final lerp = Range.lerp(from, to, 0.5);

    expect(lerp.min, equals(5.0));
    expect(lerp.max, equals(20.0));
  });
}
