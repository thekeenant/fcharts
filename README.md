# fcharts 
[![Build Status](https://travis-ci.org/thekeenant/fcharts.svg?branch=master)](https://travis-ci.org/thekeenant/fcharts)
[![Pub Status](https://img.shields.io/pub/v/fcharts.svg)](https://pub.dartlang.org/packages/fcharts)

A **work-in-progress** chart library for [Flutter](https://flutter.io). Until version `1.0.0` the API is subject to change
drastically. Needless to say, fcharts is _not_ production ready.

The goal of this project is to allow for creating beautiful, responsive charts using a simple 
and intuitive API.

Inspired by 
[Mikkel Ravn's tutorial](https://medium.com/flutter-io/zero-to-one-with-flutter-43b13fd7b354) 
on Flutter widgets and animations. If you have used [Recharts](https://recharts.org) (ReactJS 
library) you will find the high level API to be somewhat familiar.

## Demo

![Bar chart demo](https://i.imgur.com/D1Rd7jk.gif) ![Touch demo](https://i.imgur.com/pvHhenr.gif)

## Example Usage



```dart
class SimpleLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // X value -> Y value
    final data = [
      ["A", "✔"],
      ["B", "❓"],
      ["C", "✖"],
      ["D", "❓"],
      ["E", "✖"],
      ["F", "✖"],
      ["G", "✔"],
    ];

    return new LineChart(
      lines: [
        new Line<List<String>, String, String>(
          data: data,
          xFn: (datum) => datum[0],
          yFn: (datum) => datum[1],
        ),
      ],
      chartPadding: new EdgeInsets.fromLTRB(30.0, 10.0, 10.0, 30.0),
    );
  }
}
```