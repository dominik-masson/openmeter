import '../model/entry_dto.dart';

class UsageHelper {
  double getTotalAverageUsage(EntryDto firstEntry, EntryDto lastEntry) {
    int usage = lastEntry.count - firstEntry.count;
    int days = lastEntry.date.difference(firstEntry.date).inDays;

    return usage / days;
  }

  int getSumOfMonthsByEntry(List<EntryDto> entries) {
    return entries.map((e) => '${e.date.year} ${e.date.month}').toSet().length;
  }
}
