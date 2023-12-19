import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:openmeter/core/model/meter_dto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:drift/drift.dart' as drift;

import '../../utils/log.dart';
import '../database/local_database.dart';
import '../model/contract_dto.dart';
import '../model/entry_dto.dart';
import '../model/meter_with_room.dart';
import '../model/provider_dto.dart';
import '../model/room_dto.dart';
import '../provider/meter_provider.dart';
import 'meter_image_helper.dart';

class DatabaseExportImportHelper {
  final MeterImageHelper _meterImageHelper = MeterImageHelper();

  List<MeterWithRoom> _metersWithRoom = [];
  List<RoomDto> _rooms = [];
  List<ContractDto> _contracts = [];
  final Map<int, List<Entrie>> _entries = {};
  List<Tag> _tags = [];
  List<MeterWithTag> _meterWithTags = [];

  final RegExp clearBackupSearchPattern =
      RegExp(r'meter_(\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2})');

  final RegExp getDateInMeterPattern = RegExp(r'meter_(\d{4}_\d{2}_\d{2})');

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
    _contracts = await db.contractDao.getAllContractsDto();
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
      'date': entry.date.toString(),
      'transmittedToProvider': entry.transmittedToProvider,
      'isReset': entry.isReset,
      'imagePath': entry.imagePath,
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
      'isArchived': meter.isArchived,
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

  /// delete all backup files except the latest two
  Future<void> clearLastBackupFiles(String path) async {
    Directory dir = Directory(path);
    List<FileSystemEntity> files = dir.listSync();

    files.sort((a, b) => a.uri.path.compareTo(b.uri.path));
    files.removeWhere((element) =>
        element is! File ||
        clearBackupSearchPattern.firstMatch(element.path) == null);

    DateTime now = DateTime.now();
    String formattedNow = DateFormat('yyyy_MM_dd').format(now);

    Map<String, List<FileSystemEntity>> filesByDate = {};

    // Sort all files with the same date
    for (FileSystemEntity file in files) {
      Match? match = getDateInMeterPattern.firstMatch(file.path);

      if (match != null) {
        String? dateKey = match.group(1);

        filesByDate.putIfAbsent(dateKey ?? '', () => []);
        filesByDate[dateKey]!.add(file);
      }
    }

    // Delete all files, except the last one, from the lists
    // If the key is today's date, the entire list is deleted
    filesByDate.forEach((key, value) {
      if (value.length > 1) {
        int subList = (key == formattedNow) ? 0 : 1;

        if (key == formattedNow) {
          for (var element in value) {
            try {
              element.deleteSync(recursive: true);

              log('$element wurde erfolgreich gelöscht',
                  name: LogNames.databaseExportImport);
            } catch (e) {
              log(e.toString(), name: LogNames.databaseExportImport);
            }
          }

          value.clear();
        } else {
          for (int i = 0; i < value.length - subList; i++) {
            try {
              value.elementAt(i).deleteSync(recursive: true);

              log('${value[i]} wurde erfolgreich gelöscht',
                  name: LogNames.databaseExportImport);
            } catch (e) {
              log(e.toString(), name: LogNames.databaseExportImport);
            }

            value.removeAt(i);
          }
        }
      }
    });

    List<List<FileSystemEntity>> fileValues = filesByDate.values.toList();

    fileValues.removeWhere((element) => element.isEmpty);

    // Delete all files except for the oldest two
    for (int i = 0; i < fileValues.length - 1; i++) {
      final value = fileValues.elementAt(i);

      if (value.isNotEmpty) {
        try {
          value.elementAt(0).deleteSync(recursive: true);

          log('${value[0]} wurde erfolgreich gelöscht',
              name: LogNames.databaseExportImport);
        } catch (e) {
          log(e.toString(), name: LogNames.databaseExportImport);
        }
      }
    }
  }

  Future _handleExportImages(
      File dbFile, String fileName, String exportPath) async {
    try {
      final encoder = ZipFileEncoder();

      final newPath = p.join(exportPath, '${fileName.split('.')[0]}.zip');

      encoder.create(newPath);
      encoder.addFile(dbFile);

      encoder.addDirectory(await _meterImageHelper.getDir());

      encoder.close();

      dbFile.deleteSync();

      log('Successfully export db as zip file!',
          name: LogNames.databaseExportImport);
    } catch (e) {
      log('Error while export db as zip file: $e',
          name: LogNames.databaseExportImport);
    }
  }

  Future<bool> exportAsJSON(
      {required LocalDatabase db,
      required bool isAutoBackup,
      required String path,
      required bool clearBackupFiles}) async {
    await _getData(db);

    String jsonResult = convertToJson();

    try {
      String newPath = '';

      String fileName = '';

      if (isAutoBackup) {
        DateTime date = DateTime.now();
        String formattedDate = DateFormat('yyyy_MM_dd_HH_mm_ss').format(date);

        fileName = 'meter_$formattedDate.json';

        newPath = p.join(path, fileName);

        if (clearBackupFiles) {
          await clearLastBackupFiles(path);
        }
      } else {
        fileName = 'meter.json';
        newPath = p.join(path, fileName);
      }

      final hasImages = await _meterImageHelper.imagesExists();

      if (hasImages) {
        final dir = await getApplicationCacheDirectory();

        newPath = p.join(dir.path, fileName);
      }

      File file = File(newPath);

      if (await file.exists()) {
        file.deleteSync();
      }

      file.writeAsStringSync(jsonResult, flush: true, mode: FileMode.write);

      if (hasImages) {
        await _handleExportImages(file, fileName, path);
      }

      return true;
    } on PlatformException catch (e) {
      log('Error Unsupported operation: ${e.toString()}',
          name: 'Export as JSON');

      return false;
    } catch (e) {
      log('Error: ${e.toString()}', name: 'Export as JSON');
      return false;
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

        providerId = await db.contractDao.createProvider(
          ProviderCompanion(
            name: drift.Value(provider.name),
            contractNumber: drift.Value(provider.contractNumber),
            notice: drift.Value(provider.notice!),
            validFrom: drift.Value(provider.validFrom),
            validUntil: drift.Value(provider.validUntil),
            renewal: drift.Value(provider.renewal),
            canceled: drift.Value(provider.canceled),
            canceledDate: drift.Value(provider.canceledDate),
          ),
        );
      }

      ContractCompanion contractCompanion = ContractCompanion(
          provider: drift.Value(providerId),
          note: drift.Value(contract.note!),
          meterTyp: drift.Value(contract.meterTyp),
          energyPrice: drift.Value(contract.costs.energyPrice),
          discount: drift.Value(contract.costs.discount ?? 0),
          bonus: drift.Value(contract.costs.bonus),
          basicPrice: drift.Value(contract.costs.basicPrice),
          unit: drift.Value(contract.unit));

      int contractId = await db.contractDao.createContract(contractCompanion);

      if (contract.compareCosts != null) {
        final compareCosts = contract.compareCosts!;
        compareCosts.parentId = contractId;

        await db.costCompareDao
            .createCompareCost(compareCosts.toCostCompareCompanion());
      }
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
    return sum of archived meters
   */
  Future<int> _insertMeterIntoDatabase(
      LocalDatabase db, Map<MeterDto, List<EntryDto>> meters) async {
    int countArchiv = 0;

    for (var meter in meters.entries) {
      var meterDto = meter.key;
      List<EntryDto> entries = meter.value;

      if (meterDto.isArchived) {
        countArchiv++;
      }

      final MeterCompanion meterCompanion = MeterCompanion(
          typ: drift.Value(meterDto.typ),
          note: drift.Value(meterDto.note),
          number: drift.Value(meterDto.number),
          unit: drift.Value(meterDto.unit),
          isArchived: drift.Value(meterDto.isArchived));

      int meterId = await db.meterDao.createMeter(meterCompanion);

      for (EntryDto entry in entries) {
        final EntriesCompanion entriesCompanion = EntriesCompanion(
          note: drift.Value(entry.note),
          meter: drift.Value(meterId),
          days: drift.Value(entry.days),
          date: drift.Value(entry.date),
          count: drift.Value(entry.count),
          usage: drift.Value(entry.usage),
          transmittedToProvider: drift.Value(entry.transmittedToProvider),
          isReset: drift.Value(entry.isReset),
          imagePath: drift.Value(entry.imagePath),
        );

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

    return countArchiv;
  }

  _handleImportZip(String path) async {
    final inputStream = InputFileStream(path);
    final zipData = ZipDecoder().decodeBuffer(inputStream);

    final saveImagePath = await _meterImageHelper.getDir();

    for (var file in zipData.files) {
      if (file.isFile) {
        final fileName = file.name;

        if (fileName.endsWith('.jpg')) {
          final fileNameArray = fileName.split('/');

          final outputStream =
              OutputFileStream('${saveImagePath.path}/${fileNameArray[1]}');

          file.writeContent(outputStream);

          outputStream.close();
        }
        if (fileName.endsWith('.json')) {
          final cacheDir = await getApplicationCacheDirectory();

          final outputStream = OutputFileStream('${cacheDir.path}/meter.json');

          file.writeContent(outputStream);

          outputStream.close();
        }
      }
    }
  }

  Future<bool> importFromJson(
      {required LocalDatabase db,
      required String path,
      required MeterProvider meterProvider}) async {
    _clearAllLists();

    File? file;

    if (path.endsWith('.zip')) {
      await _handleImportZip(path);

      final cacheDir = await getApplicationCacheDirectory();

      file = File('${cacheDir.path}/meter.json');
    } else {
      file = File(path);
    }

    if (file.existsSync()) {
      try {
        Map<String, dynamic> json = jsonDecode(file.readAsStringSync());

        List roomJson = json['rooms'];
        _rooms = roomJson.map((e) => RoomDto.fromJson(e)).toList();

        List tagsJson = json['tags'];
        List<TagsCompanion> finalTags =
            tagsJson.map((e) => _tagsToData(e)).toList();

        List contractsJson = json['contracts'];
        _contracts = contractsJson.map((e) => ContractDto.fromJson(e)).toList();

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
        int countArchiv = await _insertMeterIntoDatabase(db, meters);

        meterProvider.setArchivMetersLength(countArchiv);
        meterProvider.setStateHasUpdate(true);

        return true;
      } on PlatformException catch (e) {
        log('Error Unsupported operation: ${e.toString()}',
            name: 'Import from JSON');

        return false;
      } catch (e) {
        log('Error: ${e.toString()}', name: 'Import from JSON');
        return false;
      }
    }
    return false;
  }
}
