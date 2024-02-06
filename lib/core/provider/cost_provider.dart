import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:openmeter/utils/log.dart';

import '../database/local_database.dart';
import '../model/entry_dto.dart';

class CostProvider extends ChangeNotifier {
  static const String boxSelectedContracts = 'selected_contracts';
  final String keyFirstDate = 'costFromDate_';
  final String keyLastDate = 'costUntilDate_';

  List<EntryDto> _entries = [];
  List<EntryDto> _cachedEntries = [];

  late Box _selectedContracts;

  int _meterId = 0;
  String _meterUnit = 'kWh';

  double _basicPrice = 0.0;
  double _energyPrice = 0.0;
  double _discount = 0.0;

  double _totalCosts = 0.0;
  double _averageMonth = 0.0;
  double _totalPaid = 0.0;
  double _difference = 0.0;
  int _months = 0;

  DateTime? _costFrom;
  DateTime? _costUntil;

  bool _isPredicted = false;
  int _averageUsage = 0;

  CostProvider() {
    _initPrefs();
  }

  _initPrefs() async {
    _selectedContracts = await Hive.openBox(boxSelectedContracts);
  }

  void setMeterId(int value) {
    _meterId = value;
  }

  int get getMeterId => _meterId;

  void saveSelectedContract(int contractId) async {
    await _selectedContracts.put(_meterId, contractId);
    notifyListeners();
  }

  int? get getSelectedContractId => _selectedContracts.get(_meterId);

  void setEntries(List<Entrie> entries) {
    _entries = entries.map((e) => EntryDto.fromData(e)).toList();
  }

  void setCachedEntries(List<Entrie> entries) {
    _cachedEntries = entries.map((e) => EntryDto.fromData(e)).toList();
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

  int _getSumOfMonthsByEntry() {
    return _entries.map((e) => '${e.date.year} ${e.date.month}').toSet().length;
  }

  int _getSumOfMonthsBySelectedDate() {
    int monthDiff = _costUntil!.month - _costFrom!.month;
    int yearDiff = _costUntil!.year - _costFrom!.year;

    return yearDiff * 12 + monthDiff;
  }

  double _getTotalAverageUsage() {
    final firstEntry = _cachedEntries.last;
    final lastEntry = _cachedEntries.first;

    int usage = lastEntry.count - firstEntry.count;
    int days = lastEntry.date.difference(firstEntry.date).inDays;

    return usage / days;
  }

  void _calcTotalCosts() {
    try {
      final EntryDto lastEntry;
      final EntryDto firstEntry;

      if (_entries.isNotEmpty) {
        lastEntry = _entries.first;
        firstEntry = _entries.last;
      } else {
        lastEntry = _cachedEntries
            .firstWhere((element) => element.date.isBefore(_costFrom!));
        firstEntry = _cachedEntries
            .firstWhere((element) => element.date.isBefore(_costUntil!));
      }

      int lastCount = lastEntry.count;
      int firstCount = firstEntry.count;

      double totalAverageUsage = _getTotalAverageUsage();

      if (_costUntil != null && _costUntil!.isAfter(lastEntry.date)) {
        int diffDays = _costUntil!.difference(lastEntry.date).inDays;
        lastCount += (totalAverageUsage * diffDays).toInt();
        _isPredicted = true;
      }

      if (_costFrom != null && _costFrom!.isBefore(firstEntry.date)) {
        int diffDays = _costFrom!.difference(firstEntry.date).inDays.abs();
        firstCount -= (totalAverageUsage * diffDays).toInt();
        _isPredicted = true;
      }

      double basicPrice = _basicPrice / 365 * _months;
      double countPrice = ((lastCount - firstCount) * _energyPrice) / 100;

      _averageUsage = lastCount - firstCount;

      _totalCosts = basicPrice + countPrice;
      _averageMonth = _totalCosts / _months;
    } catch (e) {
      _averageUsage = 0;
      _totalCosts = 0;
      _averageMonth = 0;

      log('Error while calculate total coasts: ${e.toString()}',
          name: LogNames.costProvider);
    }
  }

  void _calcTotalPaid() {
    _totalPaid = _discount * _months;
  }

  _trimEntriesByDate() {
    _entries.removeWhere((element) =>
        element.date.isAfter(_costUntil!) || element.date.isBefore(_costFrom!));
  }

  void initialCalc() {
    if (_costFrom != null && _costUntil != null) {
      _trimEntriesByDate();
      _months = _getSumOfMonthsBySelectedDate();
    } else {
      _months = _getSumOfMonthsByEntry();
    }

    _calcTotalCosts();
    _calcTotalPaid();

    _difference = _totalPaid - _totalCosts;
  }

  void saveSelectedDates(DateTimeRange dateRange) async {
    _costFrom = dateRange.start;
    _costUntil = dateRange.end;

    _selectedContracts.putAll({
      '$keyFirstDate$_meterId': _costFrom,
      '$keyLastDate$_meterId': _costUntil,
    });

    notifyListeners();
  }

  DateTime? get getCostFrom {
    _costFrom = _selectedContracts.get('$keyFirstDate$_meterId');
    return _costFrom;
  }

  DateTime? get getCostUntil {
    _costUntil = _selectedContracts.get('$keyLastDate$_meterId');
    return _costUntil;
  }

  int get getSumOfMonths => _months;

  Future<void> deleteTimeRange(LocalDatabase db) async {
    _selectedContracts.delete('$keyFirstDate$_meterId');
    _selectedContracts.delete('$keyLastDate$_meterId');

    _costFrom = null;
    _costUntil = null;

    notifyListeners();
  }

  void setStateIsPredicted(bool value) {
    _isPredicted = value;
  }

  bool get getStateIsPredicted => _isPredicted;

  int get getAverageUsage => _averageUsage;

  String get getMeterUnit => _meterUnit;

  void setMeterUnit(String value) {
    _meterUnit = value;
  }

  deleteContractFromBox(int contractId) {
    final indices = _selectedContracts.values.mapIndexed(
      (index, element) {
        if (element == contractId) {
          return index;
        }
      },
    );

    for (var index in indices) {
      if (index != null) {
        _selectedContracts.deleteAt(index);
      }
    }
  }
}
