import 'package:drift/drift.dart';

import 'meter.dart';

class Entries extends Table{
  IntColumn get id => integer().autoIncrement()();  // default primary key
  IntColumn get meter => integer().references(Meter, #id, onDelete: KeyAction.cascade)();
  IntColumn get count => integer()();
  DateTimeColumn get date => dateTime()();
}