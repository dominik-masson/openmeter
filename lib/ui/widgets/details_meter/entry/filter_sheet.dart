import 'package:flutter/material.dart';
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
            height: MediaQuery.sizeOf(context).height * 0.35,
            width: MediaQuery.sizeOf(context).width,
            child: _sheetContent(),
          ),
        );
      },
    );
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
                onPressed: () {
                  entryProvider.resetFilters();
                  setState(
                    () {
                      _selectedFilters.clear();
                    },
                  );
                },
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

                entryProvider.setActiveFilters(_selectedFilters);
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

                entryProvider.setActiveFilters(_selectedFilters);
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
                  value: EntryFilters.time,
                  label: Text('Zeitraum'),
                  enabled: false,
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

                entryProvider.setActiveFilters(_selectedFilters);
              },
            ),
          ),
        ],
      ),
    );
  }
}
