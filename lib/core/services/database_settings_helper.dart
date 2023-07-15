import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../utils/log_levels.dart';
import '../database/local_database.dart';
import '../model/database_stats_dto.dart';
import '../provider/contract_provider.dart';
import '../provider/database_settings_provider.dart';
import '../provider/meter_provider.dart';
import '../provider/room_provider.dart';
import 'database_export_import.dart';

class DatabaseSettingsHelper {
  late final BuildContext context;

  DatabaseSettingsHelper(BuildContext buildContext) {
    context = buildContext;
  }

  deleteDB(BuildContext context, LocalDatabase db) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zurücksetzen?'),
        content: const Text(
            'Möchten Sie Ihre Datenbank wirklich zurücksetzen und somit alle Daten löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              db.deleteDB().then((value) {
                Provider.of<DatabaseSettingsProvider>(context, listen: false)
                    .resetStats();
                Provider.of<RoomProvider>(context, listen: false).deleteCache();
                Provider.of<ContractProvider>(context, listen: false)
                    .deleteCache();
                Provider.of<MeterProvider>(context, listen: false)
                    .resetMeterList();

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    'Datenbank wurde erfolgreich zurückgesetzt!',
                  ),
                ));
                Navigator.of(context).pop();
              });
            },
            child: const Text(
              'Zurücksetzen',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _askPermission() async {
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

  selectAutoBackupPath(DatabaseSettingsProvider provider) async {
    bool permissionGranted = await _askPermission();

    if (!permissionGranted) {
      return;
    }

    try {
      String? path = await FilePicker.platform.getDirectoryPath();

      if (path == null) {
        return;
      }

      provider.setAutoBackupDirectory(path);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Unsupported operation $e');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<bool> autoBackupExport(
      LocalDatabase db, DatabaseSettingsProvider provider) async {
    try {
      String path = provider.getAutoBackupDirectory;
      await DatabaseExportImportHelper()
          .exportAsJSON(db: db, isBackup: true, path: path);
      log('auto backup file generated',
          name: 'database settings', level: LogLevels.infoLevel);
      return true;
    } catch (err) {
      log(err.toString(),
          name: ' database settings', level: LogLevels.errorLevel);
      return false;
    }
  }

  Future<String> getDatabaseSize() async {
    final directory = await getApplicationDocumentsDirectory();
    String dbPath = p.join(directory.path, 'meter.db');

    final file = File(dbPath);

    int size = await file.length();

    switch (size.bitLength) {
      case 16:
        return '${(size / 1024).ceil()} KB';
      case 21:
        return '${(size / 1024 / 1024).ceil()} MB';
      default:
        return '0 KB';
    }
  }

  Future<DatabaseStatsDto> getDatabaseStats(LocalDatabase db) async {
    final int? sumMeters = await db.meterDao.getTableLength();
    final int? sumEntries = await db.entryDao.getTableLength();
    final int? sumContracts = await db.contractDao.getTableLength();
    final int? sumRooms = await db.roomDao.getTableLength();
    final int? sumTags = await db.tagsDao.getTableLength();

    return DatabaseStatsDto(
      sumContracts: sumContracts ?? 0,
      sumEntries: sumEntries ?? 0,
      sumMeters: sumMeters ?? 0,
      sumRooms: sumRooms ?? 0,
      sumTags: sumTags ?? 0,
    );
  }

  List<double> calcStatsPercent(
      {required int totalSum, required DatabaseStatsDto databaseStatsDto}) {
    List<double> result = [];

    double percentMeter = databaseStatsDto.sumMeters! / totalSum;
    double percentEntries = databaseStatsDto.sumEntries! / totalSum;
    double percentRooms = databaseStatsDto.sumRooms! / totalSum;
    double percentTags = databaseStatsDto.sumTags! / totalSum;
    double percentContracts = databaseStatsDto.sumContracts! / totalSum;

    result.addAll([
      percentMeter,
      percentEntries,
      percentRooms,
      percentContracts,
      percentTags
    ]);

    return result;
  }
}
