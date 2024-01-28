import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/entry_monthly_sums.dart';

class ChartProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  final String keyLineChart = 'show_line_chart';

  bool _lineChart = false;
  int _barYear = DateTime.now().year;
  bool _focusDiagram = false;
  double _averageUsage = 0.0;

  ChartProvider() {
    _loadFromPrefs();
  }

  _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();

    _lineChart = _prefs.getBool(keyLineChart) ?? false;

    notifyListeners();
  }

  bool get getLineChart => _lineChart;

  int get getBarYear => _barYear;

  void setLineChart(bool value) {
    _lineChart = value;
    _prefs.setBool(keyLineChart, _lineChart);
    notifyListeners();
  }

  void setBarYear(int year) {
    _barYear = year;
    notifyListeners();
  }

  bool get getFocusDiagram => _focusDiagram;

  void setFocusDiagram(bool value) {
    _focusDiagram = value;

    notifyListeners();
  }

  double get averageUsage => _averageUsage;

  calcAverageCountUsage(
      {required List<EntryMonthlySums> entries, required int length}) {
    double usage = 0.0;

    for (var entry in entries) {
      if (entry.usage != -1) {
        usage += entry.usage;
      }
    }

    _averageUsage = usage / length;
  }
}
