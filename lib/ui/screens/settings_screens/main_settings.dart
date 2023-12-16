import 'package:flutter/material.dart';

import '../../widgets/settings_screen/active_torch.dart';
import '../../widgets/settings_screen/desing_tile.dart';
import '../../widgets/settings_screen/tags_tile.dart';
import '../../widgets/settings_screen/database_listtile.dart';
import '../../widgets/settings_screen/reading_reminder.dart';

class MainSettings extends StatelessWidget {
  const MainSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DesignTile(),
              DatabaseSettings(),
              Divider(),
              ReadingReminder(),
              TagsTile(),
              ActiveTorch(),
            ],
          ),
        ),
      ),
    );
  }
}
