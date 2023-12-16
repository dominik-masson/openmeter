import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;

import '../database/local_database.dart';
import '../model/meter_with_room.dart';
import '../model/room_dto.dart';

class MeterProvider extends ChangeNotifier {
  List<MeterWithRoom> _meters = [];
  int _selectedLength = 0;
  bool _hasSelectedItems = false;
  bool _hasUpdate = false;
  int _archivMetersLength = 0;

  late SharedPreferences _prefs;
  final String keyArchivLength = 'archiv-length';

  MeterProvider() {
    _loadFromPrefs();
  }

  _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();

    _archivMetersLength = _prefs.getInt(keyArchivLength) ?? 0;

    notifyListeners();
  }

  get getAllMeters => _meters;

  bool get getStateHasSelectedMeters => _hasSelectedItems;

  int get getCountSelectedMeters => _selectedLength;

  int get getAllMetersLength => _meters.length;

  bool get getStateHasUpdate => _hasUpdate;

  int get getArchivMetersLength => _archivMetersLength;

  void setAllMeters(List<MeterWithRoom> meters) {
    _meters.clear();

    _meters = meters;
  }

  void setSelectedMetersLength(int value) {
    _selectedLength = value;
  }

  void toggleSelectedMeter(MeterData meter) {
    int index = _meters.indexWhere((element) => element.meter.id == meter.id);

    if (index >= 0) {
      _meters.elementAt(index).isSelected =
          !_meters.elementAt(index).isSelected;

      _hasSelectedItems = true;

      int count = 0;

      for (MeterWithRoom data in _meters) {
        if (data.isSelected == true) {
          count++;
        }
      }

      setSelectedMetersLength(count);

      if (_selectedLength == 0) {
        _hasSelectedItems = false;
      }

      notifyListeners();
    }
  }

  void removeAllSelectedMeters({bool notify = true}) {
    for (MeterWithRoom meter in _meters) {
      if (meter.isSelected == true) {
        meter.isSelected = false;
      }
    }

    setSelectedMetersLength(0);
    _hasSelectedItems = false;

    if (notify == true) {
      notifyListeners();
    }
  }

  void deleteSelectedMeters(LocalDatabase db) {
    for (var meter in _meters) {
      if (meter.isSelected) {
        db.meterDao.deleteMeter(meter.meter.id);
      }
    }

    _meters.removeWhere((element) => element.isSelected == true);
    _hasSelectedItems = false;

    notifyListeners();
  }

  deleteSingleMeter(LocalDatabase db, int meterId, RoomDto? room) async {
    if (room != null) {
      db.roomDao.deleteMeter(meterId);
    }

    db.meterDao.deleteMeter(meterId);

    _meters.removeWhere((element) => element.meter.id == meterId);

    // notifyListeners();
  }

  resetMeterList() {
    _meters.clear();
    notifyListeners();
  }

  void setStateHasUpdate(bool value) {
    _hasUpdate = value;

    if (_hasUpdate == true) {
      notifyListeners();
    }
  }

  void updateStateArchived(LocalDatabase db, bool value) {
    int count = 0;

    for (MeterWithRoom meter in _meters) {
      if (meter.isSelected) {
        db.meterDao.updateArchived(meter.meter.id, value);
        count++;
      }
    }

    setArchivMetersLength(_archivMetersLength + count);

    _hasSelectedItems = false;
    notifyListeners();
  }

  void setArchivMetersLength(int value) {
    _archivMetersLength = value;

    _prefs.setInt(keyArchivLength, value);
  }

  void resetSelectedMeters(LocalDatabase db) async {
    for (MeterWithRoom meter in _meters) {
      if (meter.isSelected) {
        final EntriesCompanion entry = EntriesCompanion(
          meter: drift.Value(meter.meter.id),
          date: drift.Value(DateTime.now()),
          count: const drift.Value(0),
          usage: const drift.Value(-1),
          days: const drift.Value(-1),
          isReset: const drift.Value(true),
        );

        await db.entryDao.createEntry(entry);
      }
    }

    removeAllSelectedMeters(notify: true);
  }
}
