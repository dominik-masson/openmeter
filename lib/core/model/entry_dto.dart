import '../database/local_database.dart';

class EntryDto {
  int count;
  int usage;
  int days;
  String? note;
  DateTime date;

  EntryDto.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        usage = json['usage'],
        days = json['days'],
        note = json['note'],
        date = DateTime.parse(json['date']);

  static Map<String, dynamic> entriesToJson(Entrie entry) {
    return {
      'count': entry.count,
      'days': entry.days,
      'usage': entry.usage,
      'note': entry.note,
      'date': entry.date.toString()
    };
  }
}
