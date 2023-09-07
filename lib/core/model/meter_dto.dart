import '../database/local_database.dart';

class MeterDto {
  int? id;
  String typ;
  String number;
  String unit;
  String note;
  String? room;
  bool isArchived;
  List<dynamic>? tags;
  bool isSelected;

  MeterDto.fromData(MeterData data)
      : typ = data.typ,
        number = data.number,
        unit = data.unit,
        note = data.note,
        isArchived = data.isArchived,
        isSelected = false,
        id = data.id;

  MeterDto.fromJson(Map<String, dynamic> json)
      : typ = json['typ'],
        number = json['number'],
        unit = json['unit'],
        note = json['note'],
        room = json['room'],
        tags = json['tags'],
        isArchived = json['isArchived'],
        isSelected = false;

  MeterData toMeterData() {
    return MeterData(
      unit: unit,
      typ: typ,
      number: number,
      note: note,
      isArchived: isArchived,
      id: id!,
    );
  }
}
