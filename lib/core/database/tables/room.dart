
import 'package:drift/drift.dart';

import 'meter.dart';

class Room extends Table{
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get typ => text()();
}

class MeterInRoom extends Table{
  IntColumn get meterId => integer().references(Meter, #id, onDelete: KeyAction.cascade)();
  IntColumn get roomId => integer().references(Room, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {meterId, roomId};
}