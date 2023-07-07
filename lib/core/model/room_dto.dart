import '../database/local_database.dart';

class RoomDto {
  int? id;
  String? name;
  String? typ;
  bool? isSelected;
  int? sumMeter;

  RoomDto.fromData(RoomData data)
      : id = data.id,
        name = data.name,
        typ = data.typ,
        isSelected = false;

  RoomDto.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        typ = json['typ'],
        isSelected = json['isSelected'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'typ': typ,
      'isSelected': isSelected,
    };
  }
}
