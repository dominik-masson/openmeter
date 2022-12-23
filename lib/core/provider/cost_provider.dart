import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CostProvider extends ChangeNotifier {
  late SharedPreferences _pref;
  final String keyFirstDate = 'costFromDate';
  final String keyLastDate = 'costUntilDate';
  int _firstDate = 0;
  int _lastDate = 0;
  int _sumMonth = 0;
  int _lastCount = 0;
  int _firstCount = 0;
  double _basicPrice = 0.0;
  double _energyPrice = 0.0;
  double _discount = 0.0;
  double _finalCost = 0.0;
  double _finalPayedDiscount = 0.0;

  int get getFirstDate => _firstDate;

  int get getLastDate => _lastDate;

  CostProvider() {
    _loadFromPref();
  }

  _initPrefs() async {
    _pref = await SharedPreferences.getInstance();
  }

  saveFistDate(int firstDate) async {
    _firstDate = firstDate;
    await _initPrefs();
    _pref.setInt(keyFirstDate, _firstDate);
  }

  saveLastDate(int lastDate) async {
    _lastDate = lastDate;
    await _initPrefs();
    _pref.setInt(keyLastDate, _lastDate);
  }

  setSumMont(int month) {
    _sumMonth = month;
  }

  _loadFromPref() async {
    await _initPrefs();

    _firstDate = _pref.getInt(keyFirstDate) ?? 0;
    _lastDate = _pref.getInt(keyLastDate) ?? 0;

    notifyListeners();
  }

  setCount(int firstCount, int lastCount) {
    _firstCount = firstCount;
    _lastCount = lastCount;
  }

  setValues(double basicPrice, double energyPrice, double discount) {
    _basicPrice = basicPrice; // Grundpreis
    _energyPrice = energyPrice; // Arbteispreis
    _discount = discount; // Abschlag
  }

  calcCost() {
    int count = _lastCount - _firstCount;
    double wastageNet = _energyPrice * count / 100;
    double wastage = wastageNet + _basicPrice;
    double tax = wastageNet * 0.19;

    _finalCost = wastage + tax;
    return _finalCost.toStringAsFixed(2);
  }

  calcPayedDiscount() {
    _finalPayedDiscount = _sumMonth * _discount;
    return _finalPayedDiscount.toStringAsFixed(2);
  }

  double calcRest() {
    return _finalPayedDiscount - _finalCost;
  }

  void resetValues() {
    _firstCount = 0;
    _lastCount = 0;
    _basicPrice = 0;
    _energyPrice = 0;
    _discount = 0;
    _finalPayedDiscount = 0;
    _finalCost = 0;
  }
}
