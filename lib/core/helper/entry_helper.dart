import 'package:drift/drift.dart';

import '../database/local_database.dart';
import '../model/entry_dto.dart';

class EntryHelper {
  Future updateNewEntryUsage(
      {required EntryDto nextEntry,
      required EntryDto prevEntry,
      required LocalDatabase db}) async {
    if (!nextEntry.isReset) {
      int usage = nextEntry.count - prevEntry.count;
      int days = nextEntry.date.difference(prevEntry.date).inDays;

      EntriesCompanion newEntry =
          EntriesCompanion(usage: Value(usage), days: Value(days));

      await db.entryDao.updateEntry(nextEntry.id!, newEntry);
    }
  }
}
