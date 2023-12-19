import 'package:flutter/material.dart';

class ConvertMeterUnit {
  String getUnitString(String unit) {
    final List<String> split = unit.split('^');

    if (split.length == 1) {
      return split.elementAt(0);
    }

    switch (split.elementAt(1)) {
      case '3':
        return '${split.elementAt(0)}\u00B3';
      default:
        return '${split.elementAt(0)}\u00B2';
    }
  }

  Widget getUnitWidget({
    required String count,
    required String unit,
    required TextStyle textStyle,
  }) {
    final List<String> split = unit.split('^');

    if (split.length == 1) {
      return Text(
        '$count ${split[0]}',
        style: textStyle,
      );
    }

    String countText = count.isEmpty ? split[0] : '$count ${split[0]}';

    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: countText,
          style: textStyle,
        ),
        WidgetSpan(
          child: Transform.translate(
            offset: const Offset(1, -4),
            child: Text(
              split[1],
              textScaler: const TextScaler.linear(0.8),
              style: textStyle,
            ),
          ),
        )
      ]),
    );
  }
}
