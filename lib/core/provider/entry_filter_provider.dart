import 'package:flutter/material.dart';

import '../enums/entry_filters.dart';
import '../helper/filter_entry.dart';
import '../model/entry_dto.dart';
import '../model/entry_filter.dart';

class EntryFilterProvider extends ChangeNotifier {
  Set<EntryFilters?> _activeFilters = {};
  DateTime? _filterByDateBegin;
  DateTime? _filterByDateEnd;

  void setActiveFilters(
      Set<EntryFilters?> filters, DateTime? begin, DateTime? end) async {
    _activeFilters = filters;
    _filterByDateBegin = begin;
    _filterByDateEnd = end;

    notifyListeners();
  }

  get getActiveFilters => _activeFilters;

  bool get getHasActiveFilters => _activeFilters.isNotEmpty;

  DateTime? get filterByDateBegin => _filterByDateBegin;

  DateTime? get filterByDateEnd => _filterByDateEnd;

  EntryFilterModel get getEntryFilter => EntryFilterModel(
        _activeFilters,
        _filterByDateBegin,
        _filterByDateEnd,
      );

  resetFilters({bool notify = true}) {
    _activeFilters.clear();
    _filterByDateEnd = null;
    _filterByDateBegin = null;

    if (notify) {
      notifyListeners();
    }
  }

  List<EntryDto> getFilteredEntriesForChart(List<EntryDto> entries) {
    final Set<EntryFilters> filter = {};

    if (_activeFilters.contains(EntryFilters.dateBegin)) {
      filter.add(EntryFilters.dateBegin);
    }

    if (_activeFilters.contains(EntryFilters.dateEnd)) {
      filter.add(EntryFilters.dateEnd);
    }

    if (filter.isEmpty) {
      return entries;
    }

    final filterHelper = FilterEntry(entries, filter);

    return filterHelper.getFilteredList(_filterByDateBegin, _filterByDateEnd);
  }

  bool get hasChartFilter =>
      _activeFilters.contains(EntryFilters.dateBegin) ||
      _activeFilters.contains(EntryFilters.dateEnd);
}
