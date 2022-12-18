
import 'package:drift/drift.dart';

import '../local_database.dart';
import '../tables/entries.dart';
import '../tables/meter.dart';

part 'entry_dao.g.dart';

@DriftAccessor(tables: [Meter, Entries])
class EntryDao extends DatabaseAccessor<LocalDatabase> with _$EntryDaoMixin{
  final LocalDatabase db;

  EntryDao(this.db) : super(db);

  Future<int> createEntry(EntriesCompanion entry) async {
    return await db.into(db.entries).insert(entry);
  }

}