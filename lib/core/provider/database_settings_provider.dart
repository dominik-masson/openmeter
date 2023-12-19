import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/log.dart';

class DatabaseSettingsProvider extends ChangeNotifier {
  bool _autoBackupState = false;
  String _autoBackupDirectory = '';
  bool _hasUpdate = false;
  List<double> _itemStats = [];
  int _itemCount = 0;
  bool _hasReset = false;
  bool _clearBackupFiles = false;
  String _databaseSize = '0 KB';
  String _imageSize = '0 KB';
  String _fullSize = '0 KB';
  bool _inAppAction = false;

  late SharedPreferences _prefs;
  final keyAutoBackupDir = 'auto-backup-dir';
  final keyAutoBackupState = 'auto-backup-state';
  final keyStatsItems = 'database-stats';
  final keyStatsItemCounts = 'database-item-counts';
  final keyClearBackupFiles = 'auto-backup-clear-state';
  final keyDatabaseFullSize = 'database-stats-full-size';
  final keyDatabaseSize = 'database-stats-database-size';
  final keyImageSize = 'database-stats-image-size';

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

    _clearBackupFiles = _prefs.getBool(keyClearBackupFiles) ?? false;

    _databaseSize = _prefs.getString(keyDatabaseSize) ?? '0 KB';
    _fullSize = _prefs.getString(keyDatabaseFullSize) ?? '0 KB';
    _imageSize = _prefs.getString(keyImageSize) ?? '0 KB';

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

    log('has update: $value', name: LogNames.databaseSettingsProvider);

    notifyListeners();
  }

  bool checkIfAutoBackupIsPossible() {
    return _autoBackupState &&
        _autoBackupDirectory.isNotEmpty &&
        _hasUpdate &&
        !_inAppAction;
  }

  void toggleInAppActionState() {
    _inAppAction = !_inAppAction;
  }

  void setStateHasReset(bool value) {
    _hasReset = value;
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

  void resetStats() {
    _itemStats = [0, 0, 0, 0, 0, 0];
    _itemCount = 0;

    setStateHasReset(true);

    notifyListeners();
  }

  void setClearBackupFilesState(bool value) {
    _clearBackupFiles = value;

    _prefs.setBool(keyClearBackupFiles, value);
  }

  bool get getClearBackupFilesState => _clearBackupFiles;

  void saveDatabaseStats(
      {required String dbSize,
      required String imageSize,
      required String fullSize}) {
    _imageSize = imageSize;
    _fullSize = fullSize;
    _databaseSize = dbSize;

    _prefs.setString(keyDatabaseFullSize, fullSize);
    _prefs.setString(keyImageSize, imageSize);
    _prefs.setString(keyDatabaseSize, dbSize);

    notifyListeners();
  }

  String get imageSize => _imageSize;

  String get statsSize => _fullSize;

  String get databaseSize => _databaseSize;
}
