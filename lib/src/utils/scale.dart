import 'package:meta/meta.dart';
import 'dart:math' as math;

class Scales {
  static const  LinearScale linear = const LinearScale._();

  static const LogScale log = const LogScale(math.e);

  static const  LogScale log2 = const LogScale(2.0);

  static const  LogScale log10 = const LogScale(10.0);
}

@immutable
abstract class Scale {
  double apply(double value);

  double invert(double value);
}

@immutable
class LinearScale implements Scale {
  const LinearScale._();

  @override
  double apply(double value) => value;

  @override
  double invert(double value) => value;
}

@immutable
class LogScale implements Scale {
  const LogScale(this.base);

  final double base;

  // TODO: check precision of this...
  @override
  double apply(double value) => value == 0 ? 0.0 : math.log(value) / math.log(base);

  @override
  double invert(double value) => value == 0 ? 0.0 : math.pow(base, value).toDouble();
}