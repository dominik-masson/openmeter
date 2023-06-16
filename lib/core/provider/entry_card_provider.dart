import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/convert_count.dart';
import '../database/local_database.dart';

class EntryCardProvider extends ChangeNotifier {
  final Map<Entrie, bool> _entries = {};
  int _selectedEntriesLength = 0;

  bool _hasSelectedEntries = false;
  String _count = 'none';
  DateTime _oldDate = DateTime.now();
  bool _contractData = false;
  bool _setStateNote = false;
  String _unit = '';

  String get getCurrentCount => _count;

  DateTime get getOldDate => _oldDate;

  bool get getContractData => _contractData;

  bool get getStateNote => _setStateNote;

  bool get getHasSelectedEntries => _hasSelectedEntries;

  int get getSelectedEntriesLength => _selectedEntriesLength;

  Map<Entrie, bool> get getAllEntries => _entries;

  String get getMeterUnit => _unit;

  void setMeterUnit(String value) {
    _unit = value;
  }

  void setAllEntries(List<Entrie> entry) {
    _entries.removeWhere((key, value) => value == false || value == true);

    for (Entrie item in entry) {
      _entries.addAll({item: false});
    }
  }

  void setSelectedEntriesLength(int value) {
    _selectedEntriesLength = value;
  }

  void setSelectedEntry(Entrie entry) {
    _entries.update(entry, (value) => value = !value);
    _hasSelectedEntries = true;

    int count = 0;
    _entries.forEach((key, value) {
      if (value == true) {
        count += 1;
      }
    });
    _selectedEntriesLength = count;

    if (_selectedEntriesLength == 0) {
      _hasSelectedEntries = false;
    }

    notifyListeners();
  }

  void deleteAllSelectedEntries(BuildContext context) {
    Entrie newLastEntry = _entries.keys.elementAt(1);

    setCurrentCount(newLastEntry.count.toString());
    setOldDate(newLastEntry.date);

    _entries.forEach((key, value) {
      if (value == true) {
        Provider.of<LocalDatabase>(context, listen: false)
            .entryDao
            .deleteEntry(key.id);
      }
    });

    _entries.removeWhere((key, value) => value == true);

    _hasSelectedEntries = false;

    notifyListeners();
  }

  void removeAllSelectedEntries() {
    _hasSelectedEntries = false;

    _entries.forEach((key, value) {
      if (value == true) value = false;
    });

    notifyListeners();
  }

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
