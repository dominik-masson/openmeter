import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TorchProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  final String _keyTorch = 'state_aktive_torch';
  final String _keyTorchOn = 'is_torch_on';

  bool _aktiveTorch = false;
  bool _isTorchOn = false;

  TorchProvider() {
    _loadFromPrefs();
  }

  _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();

    _aktiveTorch = _prefs.getBool(_keyTorch) ?? false;
    _isTorchOn = _prefs.getBool(_keyTorchOn) ?? false;

    notifyListeners();
  }

  bool get stateTorch => _aktiveTorch;

  void setTorch(bool state) {
    _aktiveTorch = state;

    _prefs.setBool(_keyTorch, _aktiveTorch);

    notifyListeners();
  }

  bool get getStateIsTorchOn => _isTorchOn;

  void setIsTorchOn(bool value) {
    _isTorchOn = value;

    _prefs.setBool(_keyTorchOn, _isTorchOn);

    notifyListeners();
  }
}
