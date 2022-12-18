import 'package:drift/drift.dart';

extension ReloadLocalDatabase on GeneratedDatabase {
  void reload() {
    markTablesUpdated(allTables);
  }
}
