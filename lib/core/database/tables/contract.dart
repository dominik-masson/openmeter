import 'package:drift/drift.dart';

class Contract extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get meterTyp => text()();

  IntColumn get provider => integer()
      .references(Provider, #id, onDelete: KeyAction.setNull)
      .nullable()();

  RealColumn get basicPrice => real()();

  RealColumn get energyPrice => real()();

  RealColumn get discount => real()();

  IntColumn get bonus => integer().nullable()();

  TextColumn get note => text()();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

class Provider extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get contractNumber => text()();

  IntColumn get notice => integer().nullable()();

  DateTimeColumn get validFrom => dateTime()();

  DateTimeColumn get validUntil => dateTime()();

  IntColumn get renewal => integer().nullable()();

  BoolColumn get canceled => boolean().nullable()();

  DateTimeColumn get canceledDate => dateTime().nullable()();
}
