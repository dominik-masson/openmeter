import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SortProvider extends ChangeNotifier {
  late SharedPreferences _pref;
  final String keyFilter = 'sort';
  final String keyOrder = 'order';

  String _sort = 'room';
  String _order = 'asc';

  String get getSort => _sort;

  String get getOrder => _order;

  SortProvider(){
    _loadFromPrefs();
  }

  Future<void> _initPrefs() async {
    _pref = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    _sort =  _pref.getString(keyFilter) ?? 'room';
    _order = _pref.getString(keyOrder) ?? 'asc';
    notifyListeners();
  }

  setSort(String sort) {
    _sort = sort;
    _saveSort();
    notifyListeners();
  }

  _saveSort() async {
    await _initPrefs();
    _pref.setString(keyFilter, _sort);
  }

  setOrder(String order){
    _order = order;
    _saveOrder();
    notifyListeners();
  }

  _saveOrder() async {
    await _initPrefs();
    _pref.setString(keyOrder, _order);
  }
}
