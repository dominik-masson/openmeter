import '../database/local_database.dart';

class EntryDto {
  int? id;
  int? meterId;
  int count;
  int usage;
  int days;
  String? note;
  DateTime date;
  bool transmittedToProvider;
  bool isReset;
  bool isSelected = false;

  EntryDto.fromData(Entrie entry)
      : count = entry.count,
        usage = entry.usage,
        days = entry.days,
        note = entry.note,
        date = entry.date,
        transmittedToProvider = entry.transmittedToProvider,
        isReset = entry.isReset,
        id = entry.id,
        meterId = entry.meter;

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

  EntryDto.fromEntriesCompanion(EntriesCompanion companion)
      : count = companion.count.value,
        date = companion.date.value,
        usage = companion.usage.value,
        days = companion.days.value,
        isReset = companion.isReset.value,
        transmittedToProvider = companion.transmittedToProvider.value;
}
