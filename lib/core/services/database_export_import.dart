import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:openmeter/core/model/meter_dto.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:drift/drift.dart' as drift;

import '../database/local_database.dart';
import '../model/contract_dto.dart';
import '../model/entry_dto.dart';
import '../model/meter_with_room.dart';
import '../model/provider_dto.dart';
import '../model/room_dto.dart';

class DatabaseExportImportHelper {
  List<MeterWithRoom> _metersWithRoom = [];
  List<RoomDto> _rooms = [];
  List<ContractDto> _contracts = [];
  final Map<int, List<Entrie>> _entries = {};
  List<Tag> _tags = [];
  List<MeterWithTag> _meterWithTags = [];

  Future<bool> askPermission() async {
    var status = await Permission.manageExternalStorage.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      }
    }
    return false;
  }

  _getData(LocalDatabase db) async {
    _metersWithRoom = await db.meterDao.getAllMeterWithRooms();
    _rooms = await db.roomDao.getAllRooms();
    _contracts = await db.contractDao.getAllContractsWithProvider();
    _tags = await db.tagsDao.getAllTags();
    _meterWithTags = await db.tagsDao.getAllMeterWithTags();

    for (MeterWithRoom meterWithRoom in _metersWithRoom) {
      final meter = meterWithRoom.meter;

      List<Entrie> entries = await db.entryDao.getAllEntries(meter.id);

      _entries.addAll({meter.id: entries});
    }
  }

  Map<String, dynamic> _tagsToJson(Tag tag) {
    return {'uuid': tag.uuid, 'name': tag.name, 'color': tag.color};
  }

  TagsCompanion _tagsToData(Map<String, dynamic> json) {
    return TagsCompanion(
        uuid: drift.Value(json['uuid']),
        name: drift.Value(json['name']),
        color: drift.Value(json['color']));
  }

  Map<String, dynamic> _entriesToJson(Entrie entry) {
    return {
      'count': entry.count,
      'days': entry.days,
      'usage': entry.usage,
      'note': entry.note,
      'date': entry.date.toString()
    };
  }

  Map<String, dynamic> _meterToJson(
      MeterWithRoom meterWithRoom, List<Entrie> entries) {
    final meter = meterWithRoom.meter;
    final room = meterWithRoom.room;

    List tags = [];

    for (var e in _meterWithTags) {
      if (e.meterId == meter.id) {
        tags.add(e.tagId);
      }
    }

    return {
      'typ': meter.typ,
      'number': meter.number,
      'unit': meter.unit,
      'note': meter.note,
      'room': room?.uuid,
      'entries': entries.map((e) => _entriesToJson(e)).toList(),
      'tags': tags,
    };
  }

  /*
    converts all data into json format
   */
  String convertToJson() {
    List<Map<String, dynamic>> jsonRoomList =
        _rooms.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> jsonContracts =
        _contracts.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> jsonTags =
        _tags.map((e) => _tagsToJson(e)).toList();
    List<Map<String, dynamic>> finalMeter = [];

    for (MeterWithRoom data in _metersWithRoom) {
      List<Entrie>? meterEntries = _entries[data.meter.id];

      finalMeter.add(_meterToJson(data, meterEntries!));
    }

    Map<String, List> result = {
      'tags': jsonTags,
      'rooms': jsonRoomList,
      'meters': finalMeter,
      'contracts': jsonContracts,
    };

    return jsonEncode(result);
  }

  exportAsJSON(
      {required LocalDatabase db,
      required bool isBackup,
      required String path}) async {
    await _getData(db);

    String jsonResult = convertToJson();

    try {
      String newPath = '';

      if (isBackup) {
        DateTime date = DateTime.now();
        String formattedDate = DateFormat('yyyy_mm_dd_hh_mm_ss').format(date);

        newPath = p.join(path, 'meter_$formattedDate.json');
      }else{
        newPath = p.join(path, 'meter.json');
      }

      File file = File(newPath);

      file.writeAsStringSync(jsonResult, flush: true, mode: FileMode.write);
    } on PlatformException catch (e) {
      log('Error Unsupported operation: ${e.toString()}',
          name: 'Export as JSON');
    } catch (e) {
      log('Error: ${e.toString()}', name: 'Export as JSON');
    }
  }

  void _clearAllLists() {
    _rooms.clear();
    _contracts.clear();
    _metersWithRoom.clear();
    _tags.clear();
    _entries.clear();
  }

  _insertContractIntoDatabase(LocalDatabase db) async {
    for (ContractDto contract in _contracts) {
      int? providerId;

      if (contract.provider != null) {
        final ProviderDto provider = contract.provider!;

        providerId = await db.contractDao.createProvider(ProviderCompanion(
            name: drift.Value(provider.name!),
            contractNumber: drift.Value(provider.contractNumber!),
            notice: drift.Value(provider.notice!),
            validFrom: drift.Value(provider.validFrom!),
            validUntil: drift.Value(provider.validUntil!)));
      }

      ContractCompanion contractCompanion = ContractCompanion(
          provider: drift.Value(providerId),
          note: drift.Value(contract.note!),
          meterTyp: drift.Value(contract.meterTyp!),
          energyPrice: drift.Value(contract.energyPrice!),
          discount: drift.Value(contract.discount!),
          bonus: drift.Value(contract.bonus!),
          basicPrice: drift.Value(contract.basicPrice!));

      await db.contractDao.createContract(contractCompanion);
    }
  }

  _insertTagsIntoDatabase(LocalDatabase db, List<TagsCompanion> tags) async {
    for (TagsCompanion tag in tags) {
      await db.tagsDao.createTag(tag);
    }
  }

  _insertRoomIntoDatabase(LocalDatabase db) async {
    for (RoomDto room in _rooms) {
      final RoomCompanion comp = RoomCompanion(
          name: drift.Value(room.name),
          typ: drift.Value(room.typ),
          uuid: drift.Value(room.uuid));

      await db.roomDao.createRoom(comp);
    }
  }

  /*
    first adds a meter
    then the entries
    after that it is checked if the meter has tags, if so they are added to the MeterWithTag
    at the end it will be checked if a meter is assigned to a room, if yes a MeterInRoom will be inserted
   */
  _insertMeterIntoDatabase(
      LocalDatabase db, Map<MeterDto, List<EntryDto>> meters) async {
    for (var meter in meters.entries) {
      var meterDto = meter.key;
      List<EntryDto> entries = meter.value;

      final MeterCompanion meterCompanion = MeterCompanion(
          typ: drift.Value(meterDto.typ),
          note: drift.Value(meterDto.note),
          number: drift.Value(meterDto.number),
          unit: drift.Value(meterDto.unit));

      int meterId = await db.meterDao.createMeter(meterCompanion);

      for (EntryDto entry in entries) {
        final EntriesCompanion entriesCompanion = EntriesCompanion(
            note: drift.Value(entry.note),
            meter: drift.Value(meterId),
            days: drift.Value(entry.days),
            date: drift.Value(entry.date),
            count: drift.Value(entry.count),
            usage: drift.Value(entry.usage));

        await db.entryDao.createEntry(entriesCompanion);
      }

      List? tags = meterDto.tags;

      if (tags != null) {
        for (String tag in tags) {
          final MeterWithTagsCompanion meterWithTag = MeterWithTagsCompanion(
              meterId: drift.Value(meterId), tagId: drift.Value(tag));

          await db.tagsDao.createMeterWithTag(meterWithTag);
        }
      }

      String? room = meterDto.room;

      if (room != null) {
        final MeterInRoomCompanion meterInRoom = MeterInRoomCompanion(
            meterId: drift.Value(meterId), roomId: drift.Value(room));

        await db.roomDao.createMeterInRoom(meterInRoom);
      }
    }
  }

  importFromJson(LocalDatabase db, String path) async {
    _clearAllLists();

    try {
      File file = File(path);

      if (file.existsSync()) {
        try {
          Map<String, dynamic> json = jsonDecode(file.readAsStringSync());

          List roomJson = json['rooms'];
          _rooms = roomJson.map((e) => RoomDto.fromJson(e)).toList();

          List tagsJson = json['tags'];
          List<TagsCompanion> finalTags =
              tagsJson.map((e) => _tagsToData(e)).toList();

          List contractsJson = json['contracts'];
          _contracts =
              contractsJson.map((e) => ContractDto.fromJson(e)).toList();

          List meterJson = json['meters'];

          Map<MeterDto, List<EntryDto>> meters = {};

          for (dynamic meter in meterJson) {
            final meterDto = MeterDto.fromJson(meter);
            final List entries = meter['entries'];

            final List<EntryDto> entriesDto =
                entries.map((e) => EntryDto.fromJson(e)).toList();

            meters.addAll({meterDto: entriesDto});
          }

          await _insertContractIntoDatabase(db);
          await _insertTagsIntoDatabase(db, finalTags);
          await _insertRoomIntoDatabase(db);
          await _insertMeterIntoDatabase(db, meters);
        } catch (e) {
          log(e.toString(), name: 'Import from JSON');
        }
      }
    } on PlatformException catch (e) {
      log('Error Unsupported operation: ${e.toString()}',
          name: 'Export as JSON');
    } catch (e) {
      log('Error: ${e.toString()}', name: 'Export as JSON');
    }
  }
}
