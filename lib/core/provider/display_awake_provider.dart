import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';

class DisplayAwakeProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  final String _keyAwake = 'state_display_awake';
  bool _awake = false;

  DisplayAwakeProvider() {
    _loadFromPrefs();
  }

  _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();

    _awake = _prefs.getBool(_keyAwake) ?? false;

    notifyListeners();
  }

  bool get stateAwake => _awake;

  void setAwake(bool state) {
    _awake = state;
    _prefs.setBool(_keyAwake, state);

    Wakelock.toggle(enable: _awake);

    notifyListeners();
  }
}
