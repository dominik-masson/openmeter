class MeterDto {
  String typ;
  String number;
  String unit;
  String note;
  String? room;
  List<dynamic>? tags;

  MeterDto.fromJson(Map<String, dynamic> json)
      : typ = json['typ'],
        number = json['number'],
        unit = json['unit'],
        note = json['note'],
        room = json['room'],
        tags = json['tags'];
}
