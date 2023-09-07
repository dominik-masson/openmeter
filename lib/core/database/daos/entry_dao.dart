import 'package:drift/drift.dart';

import '../local_database.dart';
import '../tables/entries.dart';
import '../tables/meter.dart';

part 'entry_dao.g.dart';

@DriftAccessor(tables: [Meter, Entries])
class EntryDao extends DatabaseAccessor<LocalDatabase> with _$EntryDaoMixin {
  final LocalDatabase db;

  EntryDao(this.db) : super(db);

  Future<int> createEntry(EntriesCompanion entry) async {
    return await db.into(db.entries).insert(entry);
  }

  Future<int> deleteEntry(int entryId) async {
    return await (delete(db.entries)..where((tbl) => tbl.id.equals(entryId)))
        .go();
  }

  Future<bool> updateEntry(EntriesCompanion newEntry) async {
    return await update(db.entries).replace(newEntry);
  }

  Future<List<Entrie>> getLastEntry(int meterId) async {
    return await (db.select(db.entries)
          ..where((tbl) => tbl.meter.equals(meterId))
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.count, mode: OrderingMode.desc)
          ]))
        .get();
  }

  Stream<List<Entrie>> watchAllEntries(int meterId) {
    return (select(db.entries)
          ..where((tbl) => tbl.meter.equals(meterId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.date)]))
        .watch();
  }

  Future<List<Entrie>> getAllEntries(int meterId) async {
    return (select(db.entries)
          ..where((tbl) => tbl.meter.equals(meterId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.date)]))
        .get();
  }

  Stream<Entrie> getNewestEntry(int meterId) {
    return (select(db.entries)
          ..where((tbl) => tbl.meter.equals(meterId))
          ..orderBy([
            ((tbl) => OrderingTerm(
                  expression: tbl.date,
                  mode: OrderingMode.desc,
                ))
          ])
          ..limit(1))
        .watchSingle();
  }

  Future<int?> getTableLength() async {
    var count = db.entries.id.count();

    return await (db.selectOnly(db.entries)..addColumns([count]))
        .map((row) => row.read(count))
        .getSingleOrNull();
  }
}
