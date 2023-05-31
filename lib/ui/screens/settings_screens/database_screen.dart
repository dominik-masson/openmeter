import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/provider/database_settings_provider.dart';
import '../../../core/services/database_settings_helper.dart';
import '../../widgets/settings_screen/database_stats.dart';

class DatabaseExportImport extends StatefulWidget {
  const DatabaseExportImport({Key? key}) : super(key: key);

  @override
  State<DatabaseExportImport> createState() => _DatabaseExportImportState();
}

class _DatabaseExportImportState extends State<DatabaseExportImport> {
  late DatabaseSettingsHelper _databaseHelper;

  bool autoBackupState = false;
  String autoBackupDirectory = '';

  @override
  void initState() {
    _databaseHelper = DatabaseSettingsHelper(context);
    super.initState();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center(
            //   child: Image.asset(
            //     'assets/icons/database_icon.png',
            //     width: 150,
            //   ),
            // ),
            // const SizedBox(
            //   height: 50,
            // ),
            // _databaseInformationWidget(),
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
              onTap: () => _databaseHelper.exportDB(db),
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
              onTap: () => _databaseHelper.importDB(db),
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
                'Setze die Daten zurück, um alle bisherigen Daten zu löschen.',
              ),
              onTap: () => _databaseHelper.deleteDB(db),
            ),
            const Divider(),
            _autoBackupWidget(provider),
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
