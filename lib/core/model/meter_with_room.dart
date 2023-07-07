import 'package:openmeter/core/database/local_database.dart';

class MeterWithRoom {
  final MeterData meter;
  final RoomData? room;

  MeterWithRoom({required this.meter, required this.room});
}
