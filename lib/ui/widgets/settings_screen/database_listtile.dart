import 'package:flutter/material.dart';

class DatabaseSettings extends StatelessWidget {
  const DatabaseSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title:  Text(
        'Daten und Speicher',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      leading: const Icon(Icons.data_usage),
      // subtitle: const Text(
      //     'Erstelle ein Backup deiner Datenbank oder importiere eine vorhandene Datenbank.'),
      onTap: () => Navigator.of(context).pushNamed('database_export_import'),
    );
  }
}
