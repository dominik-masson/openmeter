import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/provider/database_settings_provider.dart';
import '../../../core/services/database_export_import.dart';
import '../../../core/services/database_settings_helper.dart';
import '../../widgets/settings_screen/database_stats.dart';

class DatabaseExportImport extends StatefulWidget {
  const DatabaseExportImport({Key? key}) : super(key: key);

  @override
  State<DatabaseExportImport> createState() => _DatabaseExportImportState();
}

class _DatabaseExportImportState extends State<DatabaseExportImport> {
  late DatabaseSettingsHelper _databaseHelper;
  bool _loadData = false;
  final _exportImportHelper = DatabaseExportImportHelper();

  bool autoBackupState = false;
  String autoBackupDirectory = '';

  @override
  void initState() {
    _databaseHelper = DatabaseSettingsHelper(context);
    super.initState();
  }

  void _handleExport(
      LocalDatabase db, DatabaseSettingsProvider provider) async {
    provider.setHasUpdate(false);

    bool permissionGranted = await _exportImportHelper.askPermission();

    if (!permissionGranted) {
      provider.setHasUpdate(true);
      return;
    }

    String? path = await FilePicker.platform.getDirectoryPath();

    if (path == null) {
      provider.setHasUpdate(true);
      return;
    }

    bool success = await _exportImportHelper.exportAsJSON(
        db: db, isBackup: false, path: path);

    if (success == false) {
      provider.setHasUpdate(true);
    }
  }

  void _handleImport(
      LocalDatabase db, DatabaseSettingsProvider provider) async {
    provider.setHasUpdate(false);

    bool permissionGranted = await _exportImportHelper.askPermission();

    if (!permissionGranted) {
      provider.setHasUpdate(true);
      return;
    }

    await FilePicker.platform.clearTemporaryFiles();

    FilePickerResult? path = await FilePicker.platform.pickFiles();

    if (path == null) {
      provider.setHasUpdate(true);
      return;
    }

    setState(() {
      _loadData = true;
    });

    bool success =
        await _exportImportHelper.importFromJson(db, path.files.single.path!);

    if (success == false) {
      provider.setHasUpdate(true);
    }

    setState(() {
      _loadData = false;
    });

    provider.resetStats();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context);
    final provider = Provider.of<DatabaseSettingsProvider>(context);

    autoBackupState = provider.getAutoBackupState;
    autoBackupDirectory = provider.getAutoBackupDirectory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daten und Speicher'),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DatabaseStats(databaseSettingsHelper: _databaseHelper),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.cloud_upload),
                  title: const Text(
                    'Daten exportieren',
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: const Text(
                    'Erstelle und speichere ein Backup deiner Daten.',
                  ),
                  onTap: () => _handleExport(db, provider),
                ),
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_download),
                  title: const Text(
                    'Daten importieren',
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: const Text(
                    'Importiere deine gespeicherten Daten.',
                  ),
                  onTap: () => _handleImport(db, provider),
                ),
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  leading: const Icon(Icons.replay),
                  title: const Text(
                    'Daten zurücksetzen',
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: const Text(
                    'Lösche alle gespeicherten Daten.',
                  ),
                  onTap: () => _databaseHelper.deleteDB(context, db),
                ),
                const Divider(),
                _autoBackupWidget(provider),
              ],
            ),
            if (_loadData == true)
              Container(
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                child: const SizedBox(
                  height: 80,
                  width: 80,
                  child: CircularProgressIndicator(strokeWidth: 8),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _autoBackupWidget(DatabaseSettingsProvider provider) {
    toastEmptyDirectory() {
      return ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Es muss zuerst ein Backup Ordner ausgewählt werden!'),
        ),
      );
    }

    return Column(
      children: [
        // toggle backup state
        SwitchListTile(
          title: const Text(
            'Automatisches Backup',
            style: TextStyle(fontSize: 18),
          ),
          subtitle: const Text(
              'Erstellt automatisch ein Backup der Datenbank sobald die App geschlossen wird.'),
          secondary: const Icon(Icons.settings_backup_restore),
          value: autoBackupState,
          onChanged: (bool value) {
            if (autoBackupDirectory.isEmpty) {
              toastEmptyDirectory();
              return;
            }
            setState(() {
              autoBackupState = value;
              provider.setAutoBackupState(autoBackupState);
            });
          },
        ),
        // Get backup directory
        ListTile(
          leading: const Icon(Icons.drive_folder_upload),
          title: const Text(
            'Ordner für Datensicherung wählen',
            style: TextStyle(fontSize: 18),
          ),
          subtitle: autoBackupDirectory.isEmpty
              ? const Text('Es wurde noch kein Verzeichnis ausgewählt')
              : Text(autoBackupDirectory),
          onTap: () => _databaseHelper.selectAutoBackupPath(provider),
        ),
      ],
    );
  }
}
