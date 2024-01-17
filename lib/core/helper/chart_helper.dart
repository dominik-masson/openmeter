import '../database/local_database.dart';
import '../model/entry_monthly_sums.dart';

class ChartHelper {
  ChartHelper();

  List<EntryMonthlySums> getSumInMonths(List<Entrie> entries) {
    List<EntryMonthlySums> result = [];

    for (int i = 0; i < entries.length;) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
          entries[i].date.millisecondsSinceEpoch);

      if (entries[i].usage == -1) {
        result.add(
            EntryMonthlySums(usage: 0, month: date.month, year: date.year));
      } else {
        result.add(EntryMonthlySums(
            usage: entries[i].usage, month: date.month, year: date.year));
      }

      for (int j = i + 1; j < entries.length; j++) {
        if (entries[i].date.month == entries[j].date.month &&
            entries[i].date.year == entries[j].date.year) {
          int index = result.indexWhere((element) =>
              element.year == entries[j].date.year &&
              element.month == entries[j].date.month);

          result.elementAt(index).usage += entries[j].usage;

          // int hasDate = 0;

          // result.forEach((key, value) {
          //   DateTime date = DateTime.fromMillisecondsSinceEpoch(key);
          //
          //   if (date.month == entries[j].date.month &&
          //       date.year == entries[j].date.year) {
          //     hasDate = key;
          //   }
          // });
          //
          // if (hasDate != 0) {
          //   result.update(hasDate, (value) => value += entries[j].usage);
          // }

          i++;
        }
      }
      i++;
    }

    return result;
  }

  // getLastMonths(List<Entrie> entries) {
  //   List<Entrie> newEntries = [];
  //
  //   for (int i = 0; i < entries.length;) {
  //     newEntries.add(entries[i]);
  //
  //     for (int j = i + 1; j < entries.length; j++) {
  //       if (entries[i].date.month == entries[j].date.month &&
  //           entries[i].date.year == entries[j].date.year) {
  //         int count = entries[j].count + entries[i].usage;
  //         int usage = entries[j].usage + entries[i].usage;
  //
  //         print(newEntries);
  //         print(j - 1);
  //
  //         newEntries.add(Entrie(
  //             id: entries[j].id,
  //             meter: entries[j].meter,
  //             count: count,
  //             usage: usage,
  //             date: entries[j].date,
  //             days: entries[j].days));
  //
  //         newEntries.removeAt(j - 1);
  //
  //         i++;
  //       }
  //     }
  //     i++;
  //   }
  //
  //   return newEntries;
  // }

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
