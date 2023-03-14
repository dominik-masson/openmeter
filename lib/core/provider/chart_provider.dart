import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChartProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  final String keyLineChart = 'show_line_chart';
  final String keyBarYear = 'count_bar_year';

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
    _barYear = _prefs.getInt(keyBarYear) ?? DateTime.now().year;

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
    _prefs.setInt(keyBarYear, _barYear);
    notifyListeners();
  }
}
