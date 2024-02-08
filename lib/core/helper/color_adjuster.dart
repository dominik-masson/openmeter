import 'package:flutter/material.dart';

class ColorAdjuster {
  Color makeDark(Color color, [int percent = 80]) {
    assert(1 <= percent && percent <= 100);

    var f = 1 - percent / 100;

    return Color.fromARGB(color.alpha, (color.red * f).round(),
        (color.green * f).round(), (color.blue * f).round());
  }

  Color makeLight(Color color, [int percent = 80]) {
    assert(1 <= percent && percent <= 100);

    var p = percent / 100;

    return Color.fromARGB(
        color.alpha,
        color.red + ((255 - color.red) * p).round(),
        color.green + ((255 - color.green) * p).round(),
        color.blue + ((255 - color.blue) * p).round());
  }
}
