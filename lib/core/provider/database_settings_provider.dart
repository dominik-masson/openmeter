import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseSettingsProvider extends ChangeNotifier {
  bool _autoBackupState = false;
  String _autoBackupDirectory = '';
  bool _hasUpdate = false;
  List<double> _itemStats = [];
  int _itemCount = 0;
  bool _hasReset = false;

  late SharedPreferences _prefs;
  final keyAutoBackupDir = 'auto-backup-dir';
  final keyAutoBackupState = 'auto-backup-state';
  final keyStatsItems = 'database-stats';
  final keyStatsItemCounts = 'database-item-counts';

  DatabaseSettingsProvider() {
    _loadFromPrefs();
  }

  _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();

    _autoBackupDirectory = _prefs.getString(keyAutoBackupDir) ?? '';
    _autoBackupState = _prefs.getBool(keyAutoBackupState) ?? false;

    _itemStats = _prefs
            .getStringList(keyStatsItems)
            ?.map((e) => double.parse(e))
            .toList() ??
        [];
    _itemCount = _prefs.getInt(keyStatsItemCounts) ?? 0;

    notifyListeners();
  }

  bool get getAutoBackupState => _autoBackupState;

  List<double> get getItemStatsValues => _itemStats;

  int get getItemStatsCount => _itemCount;

  bool get getStateHasReset => _hasReset;

  void setAutoBackupState(bool value) {
    _autoBackupState = value;

    _prefs.setBool(keyAutoBackupState, _autoBackupState);

    notifyListeners();
  }

  String get getAutoBackupDirectory => _autoBackupDirectory;

  void setAutoBackupDirectory(String value) {
    _autoBackupDirectory = value;

    _prefs.setString(keyAutoBackupDir, _autoBackupDirectory);

    notifyListeners();
  }

  void setHasUpdate(bool value) {
    _hasUpdate = value;

    log(value.toString(), name: 'state update');

    notifyListeners();
  }

  bool checkIfAutoBackupIsPossible() {
    return _autoBackupState && _autoBackupDirectory.isNotEmpty && _hasUpdate;
  }

  void setStateHasReset(bool value) {
    _hasReset = value;
    notifyListeners();
  }

  void setItemStatsValues(List<double> values) {
    _itemStats = values;

    final List<String> newList = _itemStats.map((e) => e.toString()).toList();

    _prefs.setStringList(keyStatsItems, newList);
  }

  void setItemCount(int value) {
    _itemCount = value;

    _prefs.setInt(keyStatsItemCounts, _itemCount);
  }

  void resetStats(){

    _itemStats = [0, 0, 0, 0, 0];
    _itemCount = 0;

    setStateHasReset(true);
  }
}
