import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';

class DatabaseExportImport extends StatefulWidget {
  const DatabaseExportImport({Key? key}) : super(key: key);

  @override
  State<DatabaseExportImport> createState() => _DatabaseExportImportState();
}

class _DatabaseExportImportState extends State<DatabaseExportImport> {
  String? _selectedPath;
  FilePickerResult? _selectedDB;

  final _filePicker = FilePicker.platform;

  _exportDB(LocalDatabase db) async {
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

      setState(() {
        _selectedPath = path;
      });

      await db.exportInto(_selectedPath!).then((value) {
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

  _importDB(LocalDatabase db) async {
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

 _deleteDB(LocalDatabase db) async {
   showDialog(
     context: context,
     builder: (context) => AlertDialog(
       title: const Text('Zurücksetzen?'),
       content: const Text('Möchten Sie Ihre Datenbank wirklich zurücksetzen und somit alle Daten löschen?'),
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

  _resetState() {
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedPath = null;
      _selectedDB = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datenbank',
          style: TextStyle(
              color: Theme.of(context).primaryColorLight, fontSize: 16),
        ),
        const SizedBox(
          height: 10,
        ),
        ListTile(
          leading: const Icon(Icons.cloud_upload),
          title: const Text(
            'Datenbank exportieren',
            style: TextStyle(fontSize: 18),
          ),
          subtitle: const Text(
            'Erstelle und speichere ein Backup deiner Daten.',
          ),
          onTap: () => _exportDB(db),
        ),
        ListTile(
          leading: const Icon(Icons.cloud_download),
          title: const Text(
            'Datenbank importieren',
            style: TextStyle(fontSize: 18),
          ),
          subtitle: const Text(
            'Importiere die Datenbank, um die Daten wiederherzustellen.',
          ),
          onTap: () => _importDB(db),
        ),
        ListTile(
          leading: const Icon(Icons.replay),
          title: const Text(
            'Datenbank zurücksetzen',
            style: TextStyle(fontSize: 18),
          ),
          subtitle: const Text(
            'Setze die Datenbank zurück, um alle bisherigen Daten zu löschen.',
          ),
          onTap: () => _deleteDB(db),
        ),
      ],
    );
  }
}
