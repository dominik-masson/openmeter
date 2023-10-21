import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/custom_colors.dart';
import '../enums/font_size_value.dart';

class ThemeChanger extends ChangeNotifier {
  late SharedPreferences _pref;

  final String keyTheme = 'theme';
  final String keyNight = 'night';
  final String keyDynamicColor = 'dynamic_color';
  final String keyFontSize = 'font_size';

  ThemeMode _themeMode = ThemeMode.system;
  bool _nightMode = false;
  bool _useDynamicColor = false;
  ColorScheme? _dynamicLight;
  ColorScheme? _dynamicDark;
  double _fontSize = 16;
  FontSizeValue _fontSizeValue = FontSizeValue.normal;

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

    _themeMode = ThemeMode.values
        .firstWhere((element) => element.name == _pref.getString(keyTheme));

    _nightMode = _pref.getBool(keyNight) ?? false;
    _useDynamicColor = _pref.getBool(keyDynamicColor) ?? false;

    _fontSizeValue = FontSizeValue.values
        .firstWhere((element) => element.name == _pref.getString(keyFontSize));
    _getFontSizeByValue();

    notifyListeners();
  }

  _saveTheme() async {
    await _initPrefs();
    _pref.setString(keyTheme, _themeMode.name);
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

  void setUseDynamicColor(bool value, ColorScheme? light, ColorScheme? dark) {
    _useDynamicColor = value;
    _pref.setBool(keyDynamicColor, value);

    setDynamicColors(light, dark);

    notifyListeners();
  }

  bool get getUseDynamicColor => _useDynamicColor;

  void setDynamicColors(ColorScheme? light, ColorScheme? dark) {
    _dynamicDark = dark;
    _dynamicLight = light;
  }

  void _getFontSizeByValue() {
    switch (_fontSizeValue) {
      case FontSizeValue.small:
        _fontSize = 12;
        break;
      case FontSizeValue.normal:
        _fontSize = 16;
        break;
      default:
        _fontSize = 20;
    }
  }

  void setFontSize(FontSizeValue value) async {
    _fontSizeValue = value;

    await _pref.setString(keyFontSize, _fontSizeValue.name);
    _getFontSizeByValue();

    notifyListeners();
  }

  FontSizeValue get getFontSizeValue => _fontSizeValue;

  _getTextTheme() {
    return TextTheme(
      bodySmall: TextStyle(fontSize: _fontSize - 2),
      bodyMedium: TextStyle(fontSize: _fontSize),
      bodyLarge: TextStyle(fontSize: _fontSize + 2),
      headlineSmall:
          TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold),
      headlineMedium:
          TextStyle(fontSize: _fontSize + 2, fontWeight: FontWeight.bold),
      headlineLarge:
          TextStyle(fontSize: _fontSize + 4, fontWeight: FontWeight.bold),
      labelSmall: TextStyle(fontSize: _fontSize - 4, color: Colors.grey),
      labelMedium: TextStyle(
        fontSize: _fontSize - 2,
        color: Colors.grey,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: TextStyle(
        fontSize: _fontSize,
        color: Colors.grey,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  getLightTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: CustomColors.primaryColor,
      brightness: Brightness.light,
    );

    ThemeData light = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      primaryColor:
          _useDynamicColor ? _dynamicLight?.primary : CustomColors.primaryColor,
      primaryColorLight: CustomColors.primaryColorLight2,
      colorScheme: _useDynamicColor ? _dynamicLight : scheme,
      textTheme: _getTextTheme(),
      floatingActionButtonTheme: _useDynamicColor
          ? null
          : const FloatingActionButtonThemeData(
              backgroundColor: CustomColors.primaryColorLight),
      highlightColor: Colors.white60,
    );

    return light;
  }

  getDarkTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: CustomColors.primaryColor,
      brightness: Brightness.dark,
    );

    ThemeData dark = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: _useDynamicColor ? _dynamicDark : scheme,
      primaryColor:
          _useDynamicColor ? _dynamicDark?.primary : CustomColors.primaryColor,
      primaryColorLight: CustomColors.primaryColorDark,
      scaffoldBackgroundColor: CustomColors.darkColor,
      appBarTheme: const AppBarTheme(
        color: CustomColors.darkColor,
      ),
      textTheme: _getTextTheme(),
    );

    return dark;
  }

  getNightTheme() {
    final scheme = ColorScheme.fromSeed(
        seedColor: CustomColors.primaryColor, brightness: Brightness.dark);

    ThemeData night = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: _useDynamicColor ? _dynamicDark : scheme,
      primaryColor:
          _useDynamicColor ? _dynamicDark?.primary : CustomColors.primaryColor,
      primaryColorLight: CustomColors.primaryColorDark,
      scaffoldBackgroundColor: CustomColors.nightColor,
      appBarTheme: const AppBarTheme(
        color: CustomColors.nightColor,
      ),
      textTheme: _getTextTheme(),
    );

    return night;
  }
}
