import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _primaryColor = Color(0xff32A287);
const _darkColor = Color(0xff121B22);
const _nightColor = Color(0xff000000);

bool _materialDesign = true;

ThemeData light = ThemeData(
  brightness: Brightness.light,
  useMaterial3: _materialDesign,
  colorSchemeSeed: _primaryColor,
  primaryColorLight: _primaryColor,
  iconTheme: const IconThemeData(
    color: Color(0xffffffff),
  ),
);

ThemeData dark = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: _materialDesign,
  colorSchemeSeed: _primaryColor,
  primaryColorLight: _primaryColor,
  backgroundColor: _darkColor,
  scaffoldBackgroundColor: _darkColor,
  appBarTheme: const AppBarTheme(
    color: _darkColor,
  ),
  bottomAppBarTheme: const BottomAppBarTheme(
    color: _darkColor,
  ),
);

ThemeData night = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: _materialDesign,
  colorSchemeSeed: _primaryColor,
  primaryColorLight: _primaryColor,
  backgroundColor: _nightColor,
  scaffoldBackgroundColor: _nightColor,
  appBarTheme: const AppBarTheme(
    color: _nightColor,
  ),
  bottomAppBarTheme: const BottomAppBarTheme(
    color: _nightColor,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
);

class ThemeChanger extends ChangeNotifier {
  late SharedPreferences _pref;
  final String keyTheme = 'theme';
  final String keyNight = 'night';

  ThemeMode _themeMode = ThemeMode.system;
  bool _nightMode = false;

  ThemeMode get getThemeMode => _themeMode;

  bool get getNightMode => _nightMode;

  ThemeChanger() {
    _loadFormPrefs();
  }

  setTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    _saveTheme();
    notifyListeners();
  }

  _initPrefs() async {
    _pref = await SharedPreferences.getInstance();
  }

  _loadFormPrefs() async {
    await _initPrefs();
    var mode = _pref.getString(keyTheme);

    switch (mode) {
      case 'ThemeMode.dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'ThemeMode.light':
        _themeMode = ThemeMode.light;
        break;
      default:
        _themeMode = ThemeMode.system;
    }

    _nightMode = _pref.getBool(keyNight) ?? false;

    notifyListeners();
  }

  _saveTheme() async {
    await _initPrefs();
    _pref.setString(keyTheme, _themeMode.toString());
  }

  _saveNight() async {
    await _initPrefs();
    _pref.setBool(keyNight, _nightMode);
  }

  toggleNightMode(bool mode) {
    _nightMode = mode;
    _saveNight();
    notifyListeners();
  }
}
