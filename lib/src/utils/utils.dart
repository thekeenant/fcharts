/// A generic typedef for a function that takes one type and returns another.
typedef F UnaryFunction<E, F>(E argument);


List<double> generateContinuousTicks(int count) {
  // TODO
  return null;
}

List<double> generateCategoricalTicks(int count) {
  final categoryWidth = 1 / count;
  return new List.generate(count, (i) => i * categoryWidth + categoryWidth / 2);
}