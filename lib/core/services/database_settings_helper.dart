import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/log_levels.dart';
import '../database/local_database.dart';
import '../provider/database_settings_provider.dart';

class DatabaseSettingsHelper {
  String? _selectedPath;
  FilePickerResult? _selectedDB;

  final _filePicker = FilePicker.platform;

  late final BuildContext context;

  DatabaseSettingsHelper(BuildContext buildContext) {
    context = buildContext;
  }

  _resetState() {
    _selectedPath = null;
    _selectedDB = null;
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

  exportDB(LocalDatabase db) async {
    _resetState();
    bool permissionGranted = await _askPermission();

    if (!permissionGranted) {
      return;
    }

    try {
      String? path = await FilePicker.platform.getDirectoryPath();

      if (path == null) {
        return;
      }

      _selectedPath = path;

      await db.exportInto(_selectedPath!, false).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Backup wurde erstellt!',
          ),
        ));
      });
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

  importDB(LocalDatabase db) async {
    _resetState();
    _selectedDB = await _filePicker.pickFiles();

    if (_selectedDB == null) {
      return;
    }

    await db.importDB(_selectedDB!.files.single.path!).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Backup wird wiederhergestellt!',
        ),
      ));
    });
  }

  deleteDB(LocalDatabase db) async {
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
      await db.exportInto(path, true);
      log('auto backup file generated', name:'database settings', level: LogLevels.infoLevel);
      return true;
    } catch (err) {
      log(err.toString(), name: ' database settings', level: LogLevels.errorLevel);
      return false;
    }
  }
}
