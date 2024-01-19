import '../model/entry_dto.dart';
import '../model/entry_monthly_sums.dart';

class ChartHelper {
  ChartHelper();

  List<EntryMonthlySums> getSumInMonths(List<EntryDto> entries) {
    List<EntryMonthlySums> result = [];

    for (int i = 0; i < entries.length;) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
          entries[i].date.millisecondsSinceEpoch);

      if (entries[i].usage == -1) {
        result.add(EntryMonthlySums(
          usage: 0,
          month: date.month,
          year: date.year,
          day: entries[i].date.day,
          count: entries[i].count,
        ));
      } else {
        result.add(EntryMonthlySums(
          usage: entries[i].usage,
          month: date.month,
          year: date.year,
          day: date.day,
          count: entries[i].count,
        ));
      }

      for (int j = i + 1; j < entries.length; j++) {
        if (entries[i].date.month == entries[j].date.month &&
            entries[i].date.year == entries[j].date.year) {
          int index = result.indexWhere((element) =>
              element.year == entries[j].date.year &&
              element.month == entries[j].date.month);

          result.elementAt(index).usage += entries[j].usage;
          result.elementAt(index).day = entries[j].date.day;
          result.elementAt(index).count = entries[j].count;

          i++;
        }
      }
      i++;
    }

    return result;
  }

  List<EntryMonthlySums> getLastMonths(List<EntryDto> entries) {
    List<EntryMonthlySums> sumOfMonths = getSumInMonths(entries);

    DateTime now = DateTime.now();
    DateTime border = DateTime(now.year, now.month - 12);

    return sumOfMonths.where((element) {
      DateTime elementDate =
          DateTime(element.year, element.month, element.day ?? 1);

      if (elementDate.isAfter(border)) {
        return true;
      } else {
        return false;
      }
    }).toList();
  }

  List<EntryMonthlySums> convertEntryList(List<EntryDto> entries) {
    return entries
        .map((e) => EntryMonthlySums(
            usage: e.usage,
            month: e.date.month,
            year: e.date.year,
            day: e.date.day,
            count: e.count))
        .toList();
  }

  String getTitleMonths(int month) {
    switch (month) {
      case 1:
        return 'JAN';
      case 2:
        return 'FEB';
      case 3:
        return 'MAR';
      case 4:
        return 'APR';
      case 5:
        return 'MAI';
      case 6:
        return 'JUN';
      case 7:
        return 'JUL';
      case 8:
        return 'AUG';
      case 9:
        return 'SEP';
      case 10:
        return 'OKT';
      case 11:
        return 'NOV';
      default:
        return 'DEZ';
    }
  }
}
