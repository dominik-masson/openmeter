import 'dart:io';

import 'package:intl/intl.dart';

class ConvertCount {
  static String convertCount(int count) {
    final locale = Platform.localeName;
    return NumberFormat.decimalPattern(locale).format(count);
  }

  static String convertDouble(double count) {
    final locale = Platform.localeName;

    final String converted = NumberFormat.decimalPattern(locale).format(count);
    final List<String> convertedList = converted.split('');

    convertedList.removeLast();

    return convertedList.join();
  }

  static int convertString(String count) {
    List<String> split = count.split('.');

    return int.parse(split.join());
  }
}
