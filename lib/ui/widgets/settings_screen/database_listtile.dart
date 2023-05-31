import 'package:flutter/material.dart';

class DatabaseSettings extends StatelessWidget {
  const DatabaseSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text(
        'Daten und Speicher',
        style: TextStyle(fontSize: 18),
      ),
      leading: const Icon(Icons.data_usage),
      subtitle: const Text(
          'Erstelle ein Backup deiner Datenbank oder importiere eine vorhandene Datenbank.'),
      onTap: () => Navigator.of(context).pushNamed('database_export_import'),
    );
  }
}