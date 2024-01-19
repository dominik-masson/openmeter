import '../enums/entry_filters.dart';

class EntryFilterModel {
  Set<EntryFilters?> activeFilters = {};
  DateTime? filterByDateBegin;
  DateTime? filterByDateEnd;

  EntryFilterModel(
      this.activeFilters, this.filterByDateBegin, this.filterByDateEnd);
}
