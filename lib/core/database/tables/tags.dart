import 'package:drift/drift.dart';

import 'meter.dart';

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text()();

  TextColumn get name => text()();

  IntColumn get color => integer()();
}

class MeterWithTags extends Table {
  IntColumn get meterId =>
      integer().references(Meter, #id, onDelete: KeyAction.cascade)();

  TextColumn get tagId => text()();

  @override
  Set<Column<Object>>? get primaryKey => {meterId, tagId};
}
