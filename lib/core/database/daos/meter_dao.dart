import 'package:drift/drift.dart';

import '../local_database.dart';
import '../models/meter_with_room.dart';
import '../tables/entries.dart';
import '../tables/meter.dart';
import '../tables/room.dart';

part 'meter_dao.g.dart';

class EntryWithMeter {
  final Meter meter;
  final Entries entries;

  EntryWithMeter(this.meter, this.entries);
}

@DriftAccessor(tables: [Meter, Entries, MeterInRoom, Room])
class MeterDao extends DatabaseAccessor<LocalDatabase> with _$MeterDaoMixin {
  final LocalDatabase db;

  MeterDao(this.db) : super(db);

  Future<int> createMeter(MeterCompanion meter) async {
    return await db.into(db.meter).insert(meter);
  }

  Future<int> createEntry(EntriesCompanion entry) async {
    return await db.into(db.entries).insert(entry);
  }

  Future<int> deleteMeter(int meterId) async {
    batch((batch) =>
        batch.deleteWhere(db.entries, (tbl) => tbl.meter.equals(meterId)));
    return await (db.delete(db.meter)..where((tbl) => tbl.id.equals(meterId)))
        .go();
  }

  Future<List<MeterData>> getAllMeter() async {
    return await select(db.meter).get();
  }

  Stream<List<MeterData>> watchAllMeter() {
    return select(db.meter).watch();
  }

  Stream<List<Entrie>> watchAllEntries(int meterId) {
    return (select(db.entries)
          ..where((tbl) => tbl.meter.equals(meterId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.date)]))
        .watch();
  }

  Stream<List<Entrie>> getNewestEntry(int meterId) {
    return (select(db.entries)
          ..where((tbl) => tbl.meter.equals(meterId))
          ..orderBy([
            ((tbl) => OrderingTerm(
                  expression: tbl.date,
                  mode: OrderingMode.desc,
                ))
          ])
          ..limit(1))
        .watch();
  }

  Future<MeterData> getSingleMeter(int meterId) {
    return (select(db.meter)..where((tbl) => tbl.id.equals(meterId)))
        .getSingle();
  }

  Future<int> deleteEntry(int entryId) async {
    return await (delete(db.entries)..where((tbl) => tbl.id.equals(entryId)))
        .go();
  }

  Stream<List<MeterWithRoom>> watchAllMeterWithRooms() {
    // const query =
    // 'SELECT meter.id as meterId, meter.typ as meterTyp, meter.note as meterNote, meter.number as meterNumber, '
    // 'room.name as roomName, room.typ as roomTyp'
    // 'SELECT *'
    // 'FROM meter'
    // 'LEFT JOIN meter_in_room ON meter.id = meter_in_room.meter_id'
    // 'LEFT JOIN room ON room_id = room.id';

    // return select(db.meter).join([
    //   leftOuterJoin(meterInRoom, meter.id.equalsExp(meterInRoom.meterId)),
    //   leftOuterJoin(room, meterInRoom.roomId.equalsExp(room.id)),
    // ]).watch().map((event) {
    //   return event.map((e) => MeterWithRoom(
    //     meter: e.rawData.data,
    //     room: e.rawData.data
    //   ));
    // });

    final query = select(db.meter).join([
      leftOuterJoin(
        db.meterInRoom,
        meter.id.equalsExp(meterInRoom.meterId),
        // useColumns: false,
      ),
      leftOuterJoin(
        db.room,
        meterInRoom.roomId.equalsExp(room.id),
        // useColumns: false,
      ),
    ]);

    return query.watch().map(
      (rows) {
        return rows.map((row) {
          return MeterWithRoom(
              meter: row.readTable(db.meter), room: row.readTableOrNull(db.room));
        }).toList();
      },
    );
  }
}
