import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseSettingsProvider extends ChangeNotifier {
  bool _autoBackupState = false;
  String _autoBackupDirectory = '';
  bool _hasUpdate = false;

  late SharedPreferences _prefs;
  final keyAutoBackupDir = 'auto-backup-dir';
  final keyAutoBackupState = 'auto-backup-state';

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

    notifyListeners();
  }

  bool get getAutoBackupState => _autoBackupState;

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
    notifyListeners();
  }

  bool checkIfAutoBackupIsPossible() {
    return _autoBackupState && _autoBackupDirectory.isNotEmpty && _hasUpdate;
  }
}
