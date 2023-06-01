import 'package:flutter/material.dart';

import '../../utils/convert_count.dart';
import '../database/local_database.dart';

class EntryCardProvider extends ChangeNotifier {
  String _count = 'none';
  DateTime _oldDate = DateTime.now();
  bool _contractData = false;
  bool _setStateNote = false;

  String get getCurrentCount => _count;

  DateTime get getOldDate => _oldDate;

  bool get getContractData => _contractData;

  bool get getStateNote => _setStateNote;


  void setCurrentCount(String count) {
    _count = count;
    notifyListeners();
  }

  void setOldDate(DateTime date) {
    _oldDate = date;
    notifyListeners();
  }

  // check if contract data is presents
  void setContractData(bool value) {
    _contractData = value;
    // notifyListeners(); => throws error
  }

  void setStateNote(bool value) {
    _setStateNote = value;
    notifyListeners();
  }

  int getUsage(Entrie entry) {
    if (entry.usage == entry.count && entry.days == 0) {
      return -1;
    }

    return entry.usage;
  }

  getColors(int count, int usage) {
    if (usage == -1) {
      return;
    }

    double percent = 100 / count * usage;

    if (percent < 2.3) {
      return Colors.green;
    } else if (percent < 5) {
      return Colors.orange;
    } else {
      return Colors.redAccent;
    }
  }

  String getDailyUsage(int usage, int days) {
    double div = usage / days;

    return ConvertCount.convertDouble(div);
  }

}
