import 'package:flutter/material.dart';

import '../../widgets/settings_screen/database_settings.dart';
import '../../widgets/settings_screen/display_awake.dart';
import '../../widgets/settings_screen/reading_reminder.dart';
import '../../widgets/settings_screen/theme_title.dart';

class MainSettings extends StatelessWidget {
  const MainSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Funktionen',
                style: TextStyle(
                    color: Theme.of(context).primaryColorLight, fontSize: 16),
              ),
              const SizedBox(
                height: 10,
              ),
              const ReadingReminder(),
              const SizedBox(height: 5,),
              const DisplayAwake(),
              const Divider(thickness: 0.5),
              const ThemeTitle(),
              const Divider(thickness: 0.5),
              const DatabaseExportImport(),
            ],
          ),
        ),
      ),
    );
  }
}
