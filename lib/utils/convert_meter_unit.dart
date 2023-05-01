import 'package:flutter/material.dart';

class ConvertMeterUnit {
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

    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: '$count ${split[0]}',
          style: textStyle,
        ),
        WidgetSpan(
          child: Transform.translate(
            offset: const Offset(1, -4),
            child: Text(
              split[1],
              textScaleFactor: 0.8,
              style: textStyle,
            ),
          ),
        )
      ]),
    );
  }
}
