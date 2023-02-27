import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';

class SmallFeatureProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  final String _keyAwake = 'state_display_awake';
  final String _keyTorch = 'state_aktive_torch';

  bool _displayAwake = false;
  bool _aktiveTorch = false;

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

    _aktiveTorch = _prefs.getBool(_keyTorch) ?? false;

    notifyListeners();
  }

  bool get stateAwake => _displayAwake;
  bool get stateTorch => _aktiveTorch;

  void setAwake(bool state) {
    _displayAwake = state;
    _prefs.setBool(_keyAwake, state);

    Wakelock.toggle(enable: _displayAwake);

    notifyListeners();
  }

  void setTorch(bool state){
    _aktiveTorch = state;

    _prefs.setBool(_keyTorch, _aktiveTorch);

    notifyListeners();
  }
}
