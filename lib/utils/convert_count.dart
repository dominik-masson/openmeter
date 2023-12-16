import 'dart:io';

import 'package:intl/intl.dart';

class ConvertCount {
  static String convertCount(int count) {
    final locale = Platform.localeName;
    return NumberFormat.decimalPattern(locale).format(count);
  }

  static String convertDouble(double count) {
    final locale = Platform.localeName;

    return NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: 2)
        .format(count);
  }

  static int convertString(String count) {
    var reg = RegExp(r'\D');

    List<String> split = count.split(reg);

    return int.parse(split.join());
  }
}
