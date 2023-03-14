import '../database/local_database.dart';

class ChartHelper {
  ChartHelper();

  Map<int, int> getSumInMonths(List<Entrie> entries) {
    Map<int, int> result = {};
    for (int i = 0; i < entries.length;) {
      result.addAll({entries[i].date.millisecondsSinceEpoch: entries[i].count});

      for (int j = i + 1; j < entries.length; j++) {

        if (entries[i].date.month == entries[j].date.month &&
            entries[i].date.year == entries[j].date.year) {
          int count = entries[j].count + entries[j].usage;
          result.update(
              entries[i].date.millisecondsSinceEpoch, (value) => value = count);
          i++;
        }
      }
      i++;
    }

    return result;
  }

  getLastMonths(List<Entrie> entries) {
    List<Entrie> newEntries = [];

    for (int i = 0; i < entries.length;) {
      newEntries.add(entries[i]);

      for (int j = i + 1; j < entries.length; j++) {
        if (entries[i].date.month == entries[j].date.month &&
            entries[i].date.year == entries[j].date.year) {
          int count = entries[j].count + entries[j].usage;
          int usage = entries[j].usage + entries[i].usage;

          newEntries.removeAt(j - 1);
          newEntries.add(Entrie(
              id: entries[j].id,
              meter: entries[j].meter,
              count: count,
              usage: usage,
              date: entries[j].date,
              days: entries[j].days));

          i++;
        }
      }
      i++;
    }

    return newEntries;
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
