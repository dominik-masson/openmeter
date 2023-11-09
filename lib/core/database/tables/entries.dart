import 'package:drift/drift.dart';

import 'meter.dart';

class Entries extends Table {
  IntColumn get id => integer().autoIncrement()(); // default primary key
  IntColumn get meter =>
      integer().references(Meter, #id, onDelete: KeyAction.cascade)();
  IntColumn get count => integer()();
  IntColumn get usage => integer()();
  DateTimeColumn get date => dateTime()();
  IntColumn get days => integer()();
  TextColumn get note => text().nullable()();
  BoolColumn get isReset => boolean().withDefault(const Constant(false))();
  BoolColumn get transmittedToProvider =>
      boolean().withDefault(const Constant(false))();
}
