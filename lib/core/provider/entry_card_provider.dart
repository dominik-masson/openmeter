import 'package:collection/collection.dart';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/convert_count.dart';
import '../database/local_database.dart';
import '../enums/entry_filters.dart';
import '../model/entry_dto.dart';
import '../services/entry_serivce.dart';
import '../services/meter_image_helper.dart';

class EntryCardProvider extends ChangeNotifier {
  final EntryService entryService = EntryService();
  final MeterImageHelper _meterImageHelper = MeterImageHelper();

  List<EntryDto> _entries = [];
  int _selectedEntriesLength = 0;

  bool _hasSelectedEntries = false;
  String _count = 'none';
  DateTime _oldDate = DateTime.now();
  bool _contractData = false;
  bool _setStateNote = false;
  String _unit = '';
  bool _hasEntries = true;
  String _meterNumber = '';
  Set<EntryFilters?> _activeFilters = {};

  String get getCurrentCount => _count;

  DateTime get getOldDate => _oldDate;

  bool get getContractData => _contractData;

  bool get getStateNote => _setStateNote;

  bool get getHasSelectedEntries => _hasSelectedEntries;

  int get getSelectedEntriesLength => _selectedEntriesLength;

  List<EntryDto> get getAllEntries => _entries;

  String get getMeterUnit => _unit;

  String get getMeterNumber => _meterNumber;

  void setMeterNumber(String value) {
    _meterNumber = value;
  }

  void setMeterUnit(String value) {
    _unit = value;
  }

  void setAllEntries(List<Entrie> entry) {
    _entries = entry.map((element) => EntryDto.fromData(element)).toList();
  }

  void setSelectedEntriesLength(int value) {
    _selectedEntriesLength = value;
  }

  void setSelectedEntry(EntryDto entry) {
    int index = _entries.indexWhere((element) => element.id! == entry.id);

    if (index >= 0) {
      _entries.elementAt(index).isSelected =
          !_entries.elementAt(index).isSelected;
    }

    _hasSelectedEntries = true;

    int count = 0;

    for (EntryDto entry in _entries) {
      if (entry.isSelected) {
        count++;
      }
    }

    _selectedEntriesLength = count;

    if (_selectedEntriesLength == 0) {
      _hasSelectedEntries = false;
    }

    notifyListeners();
  }

  _updateFirstEntry(LocalDatabase db) async {
    final firstEntry = _entries.lastOrNull;

    if (firstEntry != null) {
      await db.entryDao.replaceEntry(EntriesCompanion(
        note: Value(firstEntry.note),
        usage: const Value(-1),
        count: Value(firstEntry.count),
        date: Value(firstEntry.date),
        days: Value(firstEntry.days),
        id: Value(firstEntry.id!),
        meter: Value(firstEntry.meterId!),
        isReset: Value(firstEntry.isReset),
        transmittedToProvider: Value(firstEntry.transmittedToProvider),
      ));
    }
  }

  void deleteAllSelectedEntries(BuildContext context) async {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    EntryDto newLastEntry = _entries.first;

    setCurrentCount(newLastEntry.count.toString());
    setOldDate(newLastEntry.date);

    for (EntryDto entry in _entries) {
      if (entry.isSelected) {
        db.entryDao.deleteEntry(entry.id!);

        if (entry.imagePath != null) {
          await _meterImageHelper.deleteImage(entry.imagePath!);
        }
      }
    }

    int firstSelectedIndex =
        _entries.indexWhere((element) => element.isSelected);

    int lastSelectedIndex =
        _entries.lastIndexWhere((element) => element.isSelected);

    if (firstSelectedIndex > 0 && (lastSelectedIndex + 1) < _entries.length) {
      EntryDto newEntry = _entries.elementAt(firstSelectedIndex - 1);
      EntryDto lastEntry = _entries.elementAt(lastSelectedIndex + 1);

      await entryService.updateNewEntryUsage(
        nextEntry: newEntry,
        prevEntry: lastEntry,
        db: db,
      );
    }

    _entries.removeWhere((element) => element.isSelected);

    _hasSelectedEntries = false;

    await _updateFirstEntry(db);

    if (_entries.isNotEmpty) {
      _hasEntries = true;
    } else {
      _hasEntries = false;
    }

    notifyListeners();
  }

  void removeAllSelectedEntries() {
    _hasSelectedEntries = false;

    for (var element in _entries) {
      element.isSelected = false;
    }

    notifyListeners();
  }

  void setCurrentCount(String count) {
    _count = count;
    notifyListeners();
  }

  void setOldDate(DateTime date) {
    _oldDate = date;
    notifyListeners();
  }

  // check if contract data is presents
  void setContractData(bool value) {
    _contractData = value;
    // notifyListeners(); => throws error
  }

  void setStateNote(bool value) {
    _setStateNote = value;
    // notifyListeners();
  }

  int getUsage(EntryDto entry) {
    if (entry.usage == entry.count && entry.days == 0) {
      return -1;
    }

    return entry.usage;
  }

  getColors(int count, int usage) {
    if (usage <= 0) {
      return;
    }

    double percent = 100 / count * usage;

    if (percent < 2.3) {
      return Colors.green;
    } else if (percent < 5) {
      return Colors.orange;
    } else {
      return Colors.redAccent;
    }
  }

  String getDailyUsage(int usage, int days) {
    double div = usage / days;

    return ConvertCount.convertDouble(div);
  }

  saveNewMiddleEntry(EntryDto newEntry, LocalDatabase db) async {
    EntryDto nextEntry =
        _entries.lastWhere((element) => element.date.isAfter(newEntry.date));

    await entryService.updateNewEntryUsage(
        nextEntry: nextEntry, prevEntry: newEntry, db: db);
  }

  EntryDto? getPrevEntry(DateTime newDate) {
    return _entries.firstWhereOrNull(
      (element) => element.date.isBefore(newDate),
    );
  }

  EntryDto? get getNewestEntry => _entries.firstOrNull;

  bool get getHasEntries => _hasEntries;

  void setHasEntries(bool value) {
    _hasEntries = value;
    notifyListeners();
  }

  get getActiveFilters => _activeFilters;

  void setActiveFilters(Set<EntryFilters?> filters) async {
    _activeFilters = filters;
    notifyListeners();
  }

  getFilteredEntries() {
    if (_activeFilters.isEmpty) {
      return _entries;
    }

    List<EntryDto> result = [];

    for (EntryFilters? filter in _activeFilters) {
      if (filter == EntryFilters.note) {
        result.addAll(_entries.where(
            (element) => element.note != null && element.note!.isNotEmpty));
      }
      if (filter == EntryFilters.transmitted) {
        result
            .addAll(_entries.where((element) => element.transmittedToProvider));
      }
      if (filter == EntryFilters.photo) {
        result.addAll(_entries.where((element) => element.imagePath != null));
      }
      if (filter == EntryFilters.reset) {
        result.addAll(_entries.where((element) => element.isReset));
      }
    }

    result.sort(
      (a, b) => b.date.compareTo(a.date),
    );

    return result;
  }

  resetFilters({bool notify = true}) {
    _activeFilters.clear();

    if (notify) {
      notifyListeners();
    }
  }

  bool get getHasActiveFilters => _activeFilters.isNotEmpty;
}
