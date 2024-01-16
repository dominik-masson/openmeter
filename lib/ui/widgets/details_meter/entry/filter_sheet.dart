import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openmeter/utils/custom_colors.dart';
import 'package:provider/provider.dart';

import '../../../../core/enums/entry_filters.dart';
import '../../../../core/provider/entry_card_provider.dart';

class EntryFilterSheet extends StatefulWidget {
  const EntryFilterSheet({super.key});

  @override
  State<EntryFilterSheet> createState() => _EntryFilterSheetState();
}

class _EntryFilterSheetState extends State<EntryFilterSheet> {
  Set<EntryFilters?> _selectedFilters = {};

  DateTime? _startDate;
  DateTime? _endDate;

  bool _startDateFilterState = false;
  bool _endDateFilterState = false;
  bool _showStartDateHint = false;
  bool _showEndDateHint = false;

  final BoxDecoration _hintBoxDecoration = BoxDecoration(
    border: Border.all(
      color: CustomColors.rosa,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(16),
  );

  Future<DateTime?> _showDatePicker(DateTime? initialDate) async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 20),
      lastDate: now,
      initialDate: initialDate ?? now,
    );

    return selectedDate;
  }

  _openBottomSheet() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(20),
            height: MediaQuery.sizeOf(context).height * 0.47,
            width: MediaQuery.sizeOf(context).width,
            child: _sheetContent(),
          ),
        );
      },
    ).then((value) {
      _showStartDateHint = false;
      _showEndDateHint = false;
    });
  }

  _clearFilters(Function setState, EntryCardProvider provider) {
    provider.resetFilters();
    _startDate = null;
    _endDate = null;
    _startDateFilterState = false;
    _endDateFilterState = false;
    _showEndDateHint = false;
    _showStartDateHint = false;

    setState(() {
      _selectedFilters.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _openBottomSheet,
      icon: const Icon(Icons.filter_list),
      tooltip: 'Einträge filtern',
    );
  }

  Widget _sheetContent() {
    final entryProvider = Provider.of<EntryCardProvider>(context);

    return StatefulBuilder(
      builder: (context, setState) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Einträge filtern',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              IconButton(
                onPressed: () => _clearFilters(setState, entryProvider),
                icon: const Icon(Icons.replay),
                tooltip: 'Filter zurücksetzen',
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton(
              segments: const [
                ButtonSegment(
                  value: EntryFilters.note,
                  label: Text('Notiz'),
                  tooltip: 'Filtern nach Einträgen mit einer Notiz',
                ),
                ButtonSegment(
                  value: EntryFilters.transmitted,
                  label: Text('Übermittelt'),
                  tooltip: 'Filtern nach übermittelt Einträgen',
                ),
              ],
              emptySelectionAllowed: true,
              multiSelectionEnabled: true,
              showSelectedIcon: false,
              selected: _selectedFilters,
              onSelectionChanged: (newSelected) {
                setState(() {
                  _selectedFilters = newSelected;
                });

                entryProvider.setActiveFilters(
                    _selectedFilters, _startDate, _endDate);
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton(
              segments: const [
                ButtonSegment(
                  value: EntryFilters.photo,
                  label: Text('Bilder'),
                  tooltip: 'Filtern nach Einträgen mit einem Bild',
                ),
                ButtonSegment(
                  value: EntryFilters.reset,
                  label: Text('Zurückgesetzt'),
                  tooltip: 'Filtern nach Einträgen die zurückgesetzt worden',
                ),
              ],
              emptySelectionAllowed: true,
              multiSelectionEnabled: true,
              showSelectedIcon: false,
              selected: _selectedFilters,
              onSelectionChanged: (newSelected) {
                setState(() {
                  _selectedFilters = newSelected;
                });

                entryProvider.setActiveFilters(
                    _selectedFilters, _startDate, _endDate);
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          _createDateTile(provider: entryProvider),
        ],
      ),
    );
  }

  _createDateTile({
    required EntryCardProvider provider,
  }) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Row(
            children: [
              Container(
                decoration: _showStartDateHint ? _hintBoxDecoration : null,
                width: MediaQuery.sizeOf(context).width * 0.7,
                child: ListTile(
                  onTap: () async {
                    _startDate = await _showDatePicker(_startDate);

                    setState(
                      () {
                        _startDate;
                        _showStartDateHint = false;
                      },
                    );

                    if (_startDateFilterState) {
                      provider.setActiveFilters(
                          _selectedFilters, _startDate, _endDate);
                    }
                  },
                  title:
                      Text('Von', style: Theme.of(context).textTheme.bodyLarge),
                  subtitle: Text(
                    _startDate == null
                        ? 'Datum wählen'
                        : DateFormat('dd.MM.yyyy').format(_startDate!),
                  ),
                  subtitleTextStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(
                          color: _showStartDateHint ? CustomColors.rosa : null),
                ),
              ),
              const SizedBox(
                height: 30,
                child: VerticalDivider(),
              ),
              Switch(
                value: _startDateFilterState,
                onChanged: (value) {
                  if (_startDate == null) {
                    setState(() => _showStartDateHint = true);
                    return;
                  }

                  setState(
                    () => _startDateFilterState = value,
                  );

                  if (value) {
                    _selectedFilters.add(EntryFilters.dateBegin);
                  } else {
                    _selectedFilters.remove(EntryFilters.dateBegin);
                  }

                  provider.setActiveFilters(
                      _selectedFilters, _startDate, _endDate);
                },
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Container(
                decoration: _showEndDateHint ? _hintBoxDecoration : null,
                width: MediaQuery.sizeOf(context).width * 0.7,
                child: ListTile(
                  onTap: () async {
                    _endDate = await _showDatePicker(_endDate);

                    setState(
                      () {
                        _endDate;
                        _showEndDateHint = false;
                      },
                    );

                    if (_endDateFilterState) {
                      provider.setActiveFilters(
                          _selectedFilters, _startDate, _endDate);
                    }
                  },
                  title:
                      Text('Bis', style: Theme.of(context).textTheme.bodyLarge),
                  subtitle: Text(
                    _endDate == null
                        ? 'Datum wählen'
                        : DateFormat('dd.MM.yyyy').format(_endDate!),
                  ),
                  subtitleTextStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(
                          color: _showEndDateHint ? CustomColors.rosa : null),
                ),
              ),
              const SizedBox(
                height: 30,
                child: VerticalDivider(),
              ),
              Switch(
                value: _endDateFilterState,
                onChanged: (value) {
                  if (_endDate == null) {
                    setState(() => _showEndDateHint = true);
                    return;
                  }

                  setState(
                    () => _endDateFilterState = value,
                  );

                  if (value) {
                    _selectedFilters.add(EntryFilters.dateEnd);
                  } else {
                    _selectedFilters.remove(EntryFilters.dateEnd);
                  }

                  provider.setActiveFilters(
                      _selectedFilters, _startDate, _endDate);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
