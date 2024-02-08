import 'package:drift/drift.dart';

import '../../model/meter_dto.dart';
import '../../model/room_dto.dart';
import '../local_database.dart';
import '../tables/meter.dart';
import '../tables/room.dart';

part 'room_dao.g.dart';

@DriftAccessor(tables: [Room, Meter, MeterInRoom])
class RoomDao extends DatabaseAccessor<LocalDatabase> with _$RoomDaoMixin {
  final LocalDatabase db;

  RoomDao(this.db) : super(db);

  Future<int> createRoom(RoomCompanion room) async {
    return await db.into(db.room).insert(room);
  }

  Future<int> deleteRoom(String roomId) async {
    await (db.delete(db.meterInRoom)..where((tbl) => tbl.roomId.equals(roomId)))
        .go();
    return await (db.delete(db.room)..where((tbl) => tbl.uuid.equals(roomId)))
        .go();
  }

  Future<int> deleteMeter(int meterId) async {
    return await (db.delete(db.meterInRoom)
          ..where((tbl) => tbl.meterId.equals(meterId)))
        .go();
  }

  Future updateRoom(RoomData room) async {
    return update(db.room).replace(room);
  }

  Stream<List<RoomData>> watchAllRooms() {
    return (select(db.room)
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.name)]))
        .watch();
  }

  Future<List<RoomDto>> getAllRooms() async {
    return await (select(db.room)
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.name)]))
        .map((r) => RoomDto.fromData(r))
        .get();
  }

  Future<int> createMeterInRoom(MeterInRoomCompanion entity) async {
    return await db.into(db.meterInRoom).insert(entity);
  }

  updateMeterInRoom(MeterInRoomCompanion entity) async {
    return await (update(db.meterInRoom)
          ..where((tbl) => tbl.meterId.equals(entity.meterId.value)))
        .write(entity);
  }

  Future<int?> getNumberCounts(String roomId) {
    final countExp = db.meterInRoom.roomId
        .count(filter: db.meterInRoom.roomId.equals(roomId));

    final query = selectOnly(db.meterInRoom)..addColumns([countExp]);

    return query.map((row) => row.read(countExp)).getSingle();
  }

  Future<Future<List<String>>> getTypOfMeter(String roomId) async {
    const query =
        'SELECT meter.typ as typ FROM meter INNER JOIN meter_in_room ON meter_id = meter.id WHERE room_id = ? ORDER BY typ';

    return customSelect(query,
            variables: [Variable.withString(roomId)],
            readsFrom: {meter, meterInRoom})
        .map((r) => r.read<String>('typ'))
        .get();
  }

  Future<List<MeterDto>> getMeterInRooms(String roomId) async {
    final query = select(db.meter).join([
      leftOuterJoin(
        db.meterInRoom,
        db.meterInRoom.meterId.equalsExp(db.meter.id),
      ),
    ])
      ..where(db.meterInRoom.roomId.equals(roomId))
      ..orderBy([OrderingTerm.asc(meter.number)]);

    return await query
        .map((r) => MeterDto.fromData(r.readTable(db.meter), false))
        .get();
  }

  Future<int?> getTableLength() async {
    var count = db.room.id.count();

    return await (db.selectOnly(db.room)..addColumns([count]))
        .map((row) => row.read(count))
        .getSingleOrNull();
  }
}
