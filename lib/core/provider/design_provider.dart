import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DesignProvider extends ChangeNotifier {
  late SharedPreferences _pref;

  static const String keyCompactNavBar = 'compact_navigation_bar';

  bool _compactNavBar = false;

  DesignProvider() {
    _loadFormPrefs();
  }

  _initPrefs() async {
    _pref = await SharedPreferences.getInstance();
  }

  _loadFormPrefs() async {
    await _initPrefs();

    _compactNavBar = _pref.getBool(keyCompactNavBar) ?? false;

    notifyListeners();
  }

  void setStateCompactNavBar(bool value){
    _compactNavBar = value;

    _pref.setBool(keyCompactNavBar, value);

    notifyListeners();
  }

  get getStateCompactNavBar => _compactNavBar;
}
