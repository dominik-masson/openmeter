import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

import '../database/local_database.dart';
import '../model/entry_dto.dart';

class CostProvider extends ChangeNotifier {
  static const String boxSelectedContracts = 'selected_contracts';
  final String keyFirstDate = 'costFromDate';
  final String keyLastDate = 'costUntilDate';

  List<EntryDto> _entries = [];

  late Box _selectedContracts;

  int _meterId = 0;

  double _basicPrice = 0.0;
  double _energyPrice = 0.0;
  double _discount = 0.0;

  double _totalCosts = 0.0;
  double _averageMonth = 0.0;
  double _totalPaid = 0.0;
  double _difference = 0.0;
  int _months = 0;

  CostProvider() {
    _initPrefs();
  }

  _initPrefs() async {
    _selectedContracts = await Hive.openBox(boxSelectedContracts);
  }

  void setMeterId(int value) {
    _meterId = value;
  }

  void saveSelectedContract(int contractId) async {
    await _selectedContracts.put(_meterId, contractId);
    notifyListeners();
  }

  int? get getSelectedContract => _selectedContracts.get(_meterId);

  void setEntries(List<Entrie> entries) {
    _entries = entries.map((e) => EntryDto.fromData(e)).toList();
  }

  void setValues(double basicPrice, double energyPrice, double discount) {
    _basicPrice = basicPrice; // Grundpreis
    _energyPrice = energyPrice; // Arbeitspreis
    _discount = discount; // Abschlag
  }

  void resetValues() {
    _basicPrice = 0;
    _energyPrice = 0;
    _discount = 0;
  }

  double calcUsage(int usage) {
    return (usage * _energyPrice) / 100;
  }

  double get getTotalCosts => _totalCosts;

  double get getAverageMonth => _averageMonth;

  double get getTotalPaid => _totalPaid;

  double get getDifference => _difference;

  void _getSumOfMonths() {
    _months =
        _entries.map((e) => '${e.date.year} ${e.date.month}').toSet().length;
  }

  void _calcTotalCosts() {
    final entry = _entries.first;

    double basicPrice = _basicPrice / 365 * _months;
    double countPrice = (entry.count * _energyPrice) / 100;

    _totalCosts = basicPrice + countPrice;

    _averageMonth = _totalCosts / _months;
  }

  void _calcTotalPaid() {
    _totalPaid = _discount * _months;
  }

  void initialCalc() {
    _getSumOfMonths();
    _calcTotalCosts();
    _calcTotalPaid();

    _difference = _totalPaid - _totalCosts;
  }
}
