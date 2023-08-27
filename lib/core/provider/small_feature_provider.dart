import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';

class SmallFeatureProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  final String _keyAwake = 'state_display_awake';
  final String _keyTorch = 'state_aktive_torch';
  final String _keyShowTags = 'state_show_tags';

  bool _displayAwake = false;
  bool _showTags = true;

  SmallFeatureProvider() {
    _loadFromPrefs();
  }

  _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();

    _displayAwake = _prefs.getBool(_keyAwake) ?? false;
    Wakelock.toggle(enable: _displayAwake);

    _showTags = _prefs.getBool(_keyShowTags) ?? true;

    notifyListeners();
  }

  bool get stateAwake => _displayAwake;

  void setAwake(bool state) {
    _displayAwake = state;
    _prefs.setBool(_keyAwake, state);

    Wakelock.toggle(enable: _displayAwake);

    notifyListeners();
  }

  bool get getShowTags => _showTags;

  void setShowTags(bool value) {
    _showTags = value;

    _prefs.setBool(_keyShowTags, _showTags);

    notifyListeners();
  }
}
