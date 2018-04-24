import 'package:fcharts_example/data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:fcharts/fcharts.dart';

/// A city in the world.
@immutable
class City {
  const City(this.name, this.coolness);

  /// The name of the city.
  final String name;

  /// How cool this city is, this is how we measure the city in the chart.
  final Level coolness;
}

/// Our city data.
final cities = [
  new City("District X", Level.Not),
  new City("Gotham", Level.Kinda),
  new City("Mos Eisley", Level.Quite),
  new City("Palo Alto", Level.Very),
];

class SimpleLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new LineChart.single(
      chartPadding: new EdgeInsets.fromLTRB(60.0, 10.0, 10.0, 20.0),
      line: new Line<City, String, Level>(
        data: cities,
        xFn: (city) => city.name,
        yFn: (city) => city.coolness,
        yAxis: new ChartAxis(
          tickLabelFn: (coolness) =>
              coolness.toString().replaceFirst("Level\.", ""),
        ),
        marker: const MarkerOptions(
          paint: const PaintOptions(color: Colors.blue)
        ),
        stroke: const PaintOptions.stroke(color: Colors.blue),
      ),
    );
  }
}
