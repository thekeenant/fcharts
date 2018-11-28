import 'package:fcharts/fcharts.dart';
import 'package:fcharts_example/data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// A city in the world.
@immutable
class City {
  const City(this.name, this.coolness, this.size);

  /// The name of the city.
  final String name;

  /// How cool this city is, this is how we measure the city in the chart.
  final Level coolness;

  /// How big the city is on a scale from 1 to 10.
  final int size;
}

/// Our city data.
const cities = [
  const City("District X", Level.Not, 7),
  const City("Gotham", Level.Kinda, 8),
  const City("Mos Eisley", Level.Quite, 4),
  const City("Palo Alto", Level.Very, 5),
];

class CityLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // set x-axis here so that both lines can use it
    final xAxis = new ChartAxis<String>();

    return new AspectRatio(
      aspectRatio: 4 / 3,
      child: new LineChart(
        chartPadding: new EdgeInsets.fromLTRB(60.0, 20.0, 30.0, 30.0),
        lines: [
          // coolness line
          new Line<City, String, Level>(
            data: cities,
            xFn: (city) => city.name,
            yFn: (city) => city.coolness,
            xAxis: xAxis,
            yAxis: new ChartAxis(
              tickLabelFn: (coolness) => coolness.toString().split("\.")[1],
              tickLabelerStyle: new TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              paint: const PaintOptions.stroke(color: Colors.blue),
            ),
            marker: const MarkerOptions(
              paint: const PaintOptions.fill(color: Colors.blue),
            ),
            stroke: const PaintOptions.stroke(color: Colors.blue),
            legend: new LegendItem(
              paint: const PaintOptions.fill(color: Colors.blue),
              text: 'Coolness',
            ),
          ),

          // size line
          new Line<City, String, int>(
            data: cities,
            xFn: (city) => city.name,
            yFn: (city) => city.size,
            xAxis: xAxis,
            yAxis: new ChartAxis(
              span: new IntSpan(0, 10),
              opposite: true,
              tickGenerator: IntervalTickGenerator.byN(1),
              paint: const PaintOptions.stroke(color: Colors.green),
              tickLabelerStyle: new TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            marker: const MarkerOptions(
              paint: const PaintOptions.fill(color: Colors.green),
              shape: MarkerShapes.square,
            ),
            stroke: const PaintOptions.stroke(color: Colors.green),
            legend: new LegendItem(
              paint: const PaintOptions.fill(color: Colors.green),
              text: 'Size',
            ),
          ),
        ],
      ),
    );
  }
}
