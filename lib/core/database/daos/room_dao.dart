import 'package:drift/drift.dart';

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

  Future<int> deleteRoom(int roomId) async {
    await (db.delete(db.meterInRoom)..where((tbl) => tbl.roomId.equals(roomId))).go();
    return await (db.delete(db.room)..where((tbl) => tbl.id.equals(roomId))).go();
}

  Stream<List<RoomData>> watchAllRooms() {
    return select(db.room).watch();
  }

  Future<int> createMeterInRoom(MeterInRoomCompanion entity) async {
    return await db.into(db.meterInRoom).insert(entity);
  }

  Future<int?> getNumberCounts(int roomId) {
    final countExp = db.meterInRoom.roomId
        .count(filter: db.meterInRoom.roomId.equals(roomId));

    final query = selectOnly(db.meterInRoom)..addColumns([countExp]);

    return query.map((row) => row.read(countExp)).getSingle();
  }

  Future<Future<List<String>>> getTypOfMeter(int roomId) async {
    const query =
        'SELECT meter.typ as typ FROM meter INNER JOIN meter_in_room ON meter_id = meter.id WHERE room_id = ?';

    return customSelect(query,
            variables: [Variable.withInt(roomId)],
            readsFrom: {meter, meterInRoom})
        .map((r) => r.read<String>('typ'))
        .get();
  }
}
