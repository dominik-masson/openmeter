import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChartProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  final String keyLineChart = 'show_line_chart';

  bool _lineChart = false;
  int _barYear = DateTime.now().year;

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
}
