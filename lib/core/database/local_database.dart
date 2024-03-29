import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'daos/contract_dao.dart';
import 'daos/cost_compare_dao.dart';
import 'daos/entry_dao.dart';
import 'daos/meter_dao.dart';
import 'daos/room_dao.dart';
import 'daos/tags_dao.dart';
import 'tables/contract.dart';
import 'tables/cost_compare.dart';
import 'tables/entries.dart';
import 'tables/meter.dart';
import 'tables/room.dart';
import 'tables/tags.dart';

part 'local_database.g.dart';

// create => dart run

@DriftDatabase(tables: [
  Meter,
  Entries,
  Room,
  MeterInRoom,
  Contract,
  Provider,
  Tags,
  MeterWithTags,
  CostCompare
], daos: [
  MeterDao,
  EntryDao,
  RoomDao,
  ContractDao,
  TagsDao,
  CostCompareDao
])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(meter, meter.isArchived);
          }
          if (from < 3) {
            await m.addColumn(provider, provider.canceled);
            await m.addColumn(provider, provider.renewal);
          }
          if (from < 4) {
            await m.addColumn(provider, provider.canceledDate);
          }
          if (from < 5) {
            await m.addColumn(entries, entries.isReset);
          }
          if (from < 6) {
            await m.addColumn(entries, entries.transmittedToProvider);
          }
          if (from < 7) {
            await m.addColumn(entries, entries.imagePath);
          }
        },
      );

  Future<void> exportInto(String path, bool isBackup) async {
    String newPath = '';
    DateTime date = DateTime.now();

    String formattedDate = DateFormat('yyyy_mm_dd_hh_mm_ss').format(date);

    if (isBackup) {
      newPath = p.join(path, 'meter_$formattedDate.db');
    } else {
      newPath = p.join(path, 'meter.db');
    }

    final File file = await File(newPath).create(recursive: true);

    if (file.existsSync()) {
      file.deleteSync();
    }

    await customStatement('VACUUM INTO ?', [newPath]);
  }

  Future<void> importDB(String path) async {
    final newDB = sqlite3.open(path);
    final appDir = await getApplicationDocumentsDirectory();
    final File file = File(p.join(appDir.path, 'meter.db'));

    if (file.existsSync()) {
      file.deleteSync();
    }

    // file.copy(path);
    newDB.execute('VACUUM INTO ?', [file.path]);

    // https://github.com/simolus3/drift/issues/376
  }

  Future<void> deleteDB() async {
    const statement = 'PRAGMA foreign_keys = OFF';
    await customStatement(statement);
    try {
      transaction(() async {
        for (final table in allTables) {
          await delete(table).go();
        }
      });
    } finally {
      await customStatement(statement);
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'meter.db'));

    // if (!await file.exists()) {
    //   final blob = await rootBundle.load(p.join(dbFolder.path, 'meter.db'));
    //   final buffer = blob.buffer;
    //   await file.writeAsBytes(
    //       buffer.asUint8List(blob.offsetInBytes, blob.lengthInBytes));
    // }

    return NativeDatabase.createInBackground(file);
  });
}
