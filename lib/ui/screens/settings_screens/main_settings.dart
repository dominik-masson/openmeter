import 'package:flutter/material.dart';

import '../../widgets/settings_screen/database_settings.dart';
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
            children: const [
              ThemeTitle(),
              Divider(thickness: 0.5),
              DatabaseExportImport(),
            ],
          ),
        ),
      ),
    );
  }
}
