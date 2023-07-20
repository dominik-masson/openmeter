import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../database/local_database.dart';
import '../model/meter_with_room.dart';
import '../model/room_dto.dart';
import 'database_settings_provider.dart';

class RoomProvider extends ChangeNotifier {
  String _cacheDir = '';
  final String _fileName = 'rooms.json';
  List<RoomDto> _rooms = [];
  final List<RoomDto> _firstRooms = [];
  final List<RoomDto> _secondRooms = [];
  bool _hasSelected = false;
  int _selectedItemsLength = 0;

  List<MeterWithRoom> _meters = [];
  bool _firstInit = true;
  int _meterCount = 0;

  bool _hasUpdate = false;

  RoomProvider() {
    _loadFromCache();
  }

  int get getAllRoomsLength => _rooms.length;

  List<RoomDto> get getFirstRooms => _firstRooms;

  List<RoomDto> get getSecondRooms => _secondRooms;

  bool get getStateHasSelected => _hasSelected;

  int get getSelectedRoomsLength => _selectedItemsLength;

  List<MeterWithRoom> get getMetersWithRoom => _meters;

  int get getMeterCount => _meterCount;

  bool get getHasUpdate => _hasUpdate;

  setHasUpdate(bool value) {
    _hasUpdate = value;

    if (_hasUpdate == true) {
      notifyListeners();
    }
  }

  Future<void> _getDir() async {
    Directory dir = await getTemporaryDirectory();

    _cacheDir = dir.path;
  }

  convertData(List<RoomData> data) {
    _rooms = data.map((e) => RoomDto.fromData(e)).toList();
    createCacheFile(_rooms);
    splitRooms();
  }

  createCacheFile(List<RoomDto> items) {
    File file = File('$_cacheDir/$_fileName');
    log('create file to path: $_cacheDir/$_fileName ', name: 'Room Provider');

    List<Map<String, dynamic>> jsonList =
        items.map((room) => room.toJson()).toList();
    var json = jsonEncode(jsonList);

    file.writeAsStringSync(json, flush: true, mode: FileMode.write);
  }

  splitRooms() {
    _secondRooms.clear();
    _firstRooms.clear();

    for (int i = 0; i < _rooms.length; i++) {
      if (i % 2 == 0) {
        _firstRooms.add(_rooms.elementAt(i));
      } else {
        _secondRooms.add(_rooms.elementAt(i));
      }
    }
  }

  _loadFromCache() async {
    await _getDir();

    File file = File('$_cacheDir/$_fileName');

    if (file.existsSync()) {
      try {
        log('load room data from json', name: 'Room Provider');

        List<dynamic> json = jsonDecode(file.readAsStringSync());

        _rooms.clear();

        _rooms = json.map((e) => RoomDto.fromJson(e)).toList();

        _rooms.sort((a, b) => a.name.compareTo(b.name));

        splitRooms();
      } catch (err) {
        log('ERROR: $err', name: 'Room Provider');
      }
    } else {
      log('there is no file', name: 'Room Provider');
    }
  }

  deleteCache() async {
    File file = File('$_cacheDir/$_fileName');

    if (file.existsSync()) {
      log('delete room cache', name: 'Room Provider');
      file.deleteSync();
    }
  }

  toggleSelectedRooms(RoomDto room) {
    int index = _rooms.indexWhere((element) => element.id == room.id);

    if (index >= 0) {
      _rooms.elementAt(index).isSelected = !_rooms.elementAt(index).isSelected!;

      int count = 0;

      for (var element in _rooms) {
        if (element.isSelected!) {
          count++;
        }
      }

      _selectedItemsLength = count;

      if (count == 0) {
        _hasSelected = false;
      } else {
        _hasSelected = true;
      }

      splitRooms();

      log('change state for room ${room.name}', name: 'Room Provider');

      notifyListeners();
    } else {
      log('no room found', name: 'Room Provider');
    }
  }

  removeAllSelected() {
    for (RoomDto room in _rooms) {
      if (room.isSelected == true) {
        room.isSelected = false;
      }
    }

    _hasSelected = false;
    _selectedItemsLength = 0;

    splitRooms();

    log('remove all selected rooms from list', name: 'Room Provider');

    notifyListeners();
  }

  deleteAllSelectedRooms(BuildContext context) {
    Provider.of<DatabaseSettingsProvider>(context, listen: false)
        .setHasUpdate(true);

    for (var element in _rooms) {
      if (element.isSelected == true) {
        Provider.of<LocalDatabase>(context, listen: false)
            .roomDao
            .deleteRoom(element.uuid);
      }
    }

    _rooms.removeWhere((element) => element.isSelected == true);
    _hasSelected = false;

    createCacheFile(_rooms);
    splitRooms();

    log('delete all selected rooms', name: 'Room Provider');

    notifyListeners();
  }

  void loadAllMeterWithRoom(LocalDatabase db) {
    log('get all meters', name: 'Add meter to room');

    db.meterDao.watchAllMeterWithRooms().listen((event) {
      _meters = event;
    }).onData((data) {
      _meters = data;
      if (_firstInit == true) {
        _firstInit = false;
        notifyListeners();
      }
    });

    log('got all meters', name: 'Add meter to room');
  }

  void setMeterCount(int value) {
    _meterCount = value;
  }

  void calcMeterCount(LocalDatabase db, String roomId) async {
    _meterCount = await db.roomDao.getNumberCounts(roomId) ?? 0;
  }

  Future<void> saveSelectedMeters({
    required List<int> withRooms,
    required List<int> withOutRooms,
    required String roomId,
    required LocalDatabase db,
  }) async {
    for (int meterId in withOutRooms) {
      final MeterInRoomCompanion data = MeterInRoomCompanion(
        meterId: Value(meterId),
        roomId: Value(roomId),
      );

      try {
        log('try to insert meter with id $meterId to room with id $roomId',
            name: 'Room Provider');

        int id = await db.roomDao.createMeterInRoom(data);

        log('successful create meter in room with new id $id',
            name: 'Room Provider');
      } catch (err) {
        log('error while insert meter in room: $err', name: 'Room Provider');
      }
    }

    for (int meterId in withRooms) {
      try {
        final MeterInRoomCompanion data = MeterInRoomCompanion(
          roomId: Value(roomId),
          meterId: Value(meterId),
        );

        log('try to insert meter with id $meterId to room with uuid $roomId',
            name: 'Room Provider');

        int id = await db.roomDao.updateMeterInRoom(data);

        log('successful create meter in room with new id $id',
            name: 'Room Provider');
      } catch (err) {
        log('error while delete current meterId $meterId from MeterWithRoom: $err ',
            name: 'Room Provider');
      }
    }

    int count = withRooms.length + withOutRooms.length;
    setMeterCount(count);
  }

  List<MeterWithRoom> searchForMeter(String value) {
    List<MeterWithRoom> searchItems = [];

    for (MeterWithRoom data in _meters) {
      if (data.meter.number.toLowerCase().contains(value.toLowerCase())) {
        searchItems.add(data);
      }
      if (data.meter.typ.toLowerCase().contains(value.toLowerCase())) {
        searchItems.add(data);
      }
    }

    return searchItems;
  }

  Future<RoomDto> updateRoom({
    required LocalDatabase db,
    required RoomData roomData,
    required DatabaseSettingsProvider backupState,
  }) async {
    await db.roomDao.updateRoom(roomData);
    backupState.setHasUpdate(true);

    int index = _rooms.indexWhere((element) => element.id == roomData.id);

    RoomDto dto = RoomDto.fromData(roomData);

    int? countMeter = _rooms.elementAt(index).sumMeter;

    _rooms[index] = dto;
    _rooms[index].sumMeter = countMeter;

    splitRooms();

    return dto;
  }
}
