import 'package:flutter/material.dart';

import '../database/local_database.dart';
import '../model/meter_with_room.dart';
import '../model/room_dto.dart';

class MeterProvider extends ChangeNotifier {
  List<MeterWithRoom> _meters = [];
  int _selectedLength = 0;
  bool _hasSelectedItems = false;

  get getAllMeters => _meters;

  bool get getStateHasSelectedMeters => _hasSelectedItems;

  int get getCountSelectedMeters => _selectedLength;

  int get getAllMetersLength => _meters.length;

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

  void removeAllSelectedMeters() {
    for (MeterWithRoom meter in _meters) {
      if (meter.isSelected == true) {
        meter.isSelected = false;
      }
    }

    setSelectedMetersLength(0);
    _hasSelectedItems = false;

    notifyListeners();
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

  resetMeterList(){
    _meters.clear();
    notifyListeners();
  }
}
