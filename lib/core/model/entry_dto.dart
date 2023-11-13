import '../database/local_database.dart';

class EntryDto {
  int count;
  int usage;
  int days;
  String? note;
  DateTime date;
  bool transmittedToProvider;
  bool isReset;

  EntryDto.fromData(Entrie entry)
      : count = entry.count,
        usage = entry.usage,
        days = entry.days,
        note = entry.note,
        date = entry.date,
        transmittedToProvider = entry.transmittedToProvider,
        isReset = entry.isReset;

  EntryDto.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        usage = json['usage'],
        days = json['days'],
        note = json['note'],
        date = DateTime.parse(json['date']),
        transmittedToProvider = json['transmittedToProvider'],
        isReset = json['isReset'];

  static Map<String, dynamic> entriesToJson(Entrie entry) {
    return {
      'count': entry.count,
      'days': entry.days,
      'usage': entry.usage,
      'note': entry.note,
      'date': entry.date.toString(),
      'transmittedToProvider': entry.transmittedToProvider,
      'isReset': entry.isReset,
    };
  }
}
