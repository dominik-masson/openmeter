import 'package:flutter/cupertino.dart';

import 'package:shared_preferences/shared_preferences.dart';

class StatsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  final String _keyListTags = 'selected_tags';
  final String _keyHandleTags = 'handle_tags';
  List<String?> _meterTypsList = [];

  List<String> _tagsIds = [];
  int _handleTags = 1;

  StatsProvider() {
    _loadFromPrefs();
  }

  List<String?> get getMeterTyps => _meterTypsList;

  void setMeterTyps(List<String?> items){
    _meterTypsList = items;
    notifyListeners();
  }

  _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();

    _tagsIds = _prefs.getStringList(_keyListTags) ?? [];
    _handleTags = _prefs.getInt(_keyHandleTags) ?? 1;

    notifyListeners();
  }

  List<String> get getTagsIdList => _tagsIds;

  int get getHandleTags => _handleTags;

  void setTagsIdList(List<String> list) {
    _tagsIds = list;

    _prefs.setStringList(_keyListTags, _tagsIds);

    notifyListeners();
  }

  void setHandleTags(int num) {
    _handleTags = num;

    _prefs.setInt(_keyHandleTags, _handleTags);

    notifyListeners();
  }

}
