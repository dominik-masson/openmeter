import '../database/local_database.dart';

class RoomDto {
  int? id;
  String uuid;
  String name;
  String typ;
  bool? isSelected;
  int? sumMeter;

  RoomDto.fromData(RoomData data)
      : id = data.id,
        uuid = data.uuid,
        name = data.name,
        typ = data.typ,
        isSelected = false;

  RoomDto.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        uuid = json['uuid'],
        name = json['name'],
        typ = json['typ'],
        isSelected = json['isSelected'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'typ': typ,
      'isSelected': isSelected,
    };
  }
}
