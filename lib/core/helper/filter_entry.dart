import '../enums/entry_filters.dart';
import '../model/entry_dto.dart';

class FilterEntry {
  List<EntryDto> _entries = [];
  Set<EntryFilters?> _activeFilters = {};

  FilterEntry(List<EntryDto> entries, Set<EntryFilters?> activeFilters) {
    _entries = entries;
    _activeFilters = activeFilters;
  }

  List<EntryDto> getFilteredList(DateTime? filterBegin, DateTime? filterEnd) {
    List<EntryDto> result = _entries;

    for (EntryFilters? filter in _activeFilters) {
      if (filter == EntryFilters.note) {
        result.removeWhere(
            (element) => element.note == null || element.note!.isEmpty);
      }
      if (filter == EntryFilters.transmitted) {
        result.removeWhere((element) => !element.transmittedToProvider);
      }
      if (filter == EntryFilters.photo) {
        result.removeWhere((element) => element.imagePath == null);
      }
      if (filter == EntryFilters.reset) {
        result.removeWhere((element) => !element.isReset);
      }
    }

    if (_activeFilters.contains(EntryFilters.dateBegin) ||
        _activeFilters.contains(EntryFilters.dateEnd)) {
      result = _handleTimeRange(result, filterBegin, filterEnd);
    }

    result.sort(
      (a, b) => b.date.compareTo(a.date),
    );

    return result;
  }

  List<EntryDto> _handleTimeRange(
      List<EntryDto> listToFilter, DateTime? filterBegin, DateTime? filterEnd) {
    if (filterBegin != null &&
        filterEnd != null &&
        _activeFilters.contains(EntryFilters.dateBegin) &&
        _activeFilters.contains(EntryFilters.dateEnd)) {
      return listToFilter
          .where((element) =>
              element.date.isBefore(filterEnd) &&
              element.date.isAfter(filterBegin))
          .toList();
    } else if (filterBegin != null &&
        _activeFilters.contains(EntryFilters.dateBegin)) {
      return listToFilter
          .where((element) => element.date.isAfter(filterBegin))
          .toList();
    } else if (filterEnd != null &&
        _activeFilters.contains(EntryFilters.dateEnd)) {
      return listToFilter
          .where((element) => element.date.isBefore(filterEnd))
          .toList();
    } else {
      return listToFilter;
    }
  }
}
