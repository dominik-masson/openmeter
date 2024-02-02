import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/local_database.dart';
import '../../../../core/enums/font_size_value.dart';
import '../../../../core/model/entry_dto.dart';
import '../../../../core/model/entry_filter.dart';
import '../../../../core/model/meter_dto.dart';
import '../../../../core/provider/cost_provider.dart';
import '../../../../core/provider/entry_provider.dart';
import '../../../../core/provider/entry_filter_provider.dart';
import '../../../../core/provider/theme_changer.dart';
import '../../../../utils/convert_count.dart';
import '../../../../utils/convert_meter_unit.dart';
import 'details_entry.dart';
import 'filter_sheet.dart';

class EntryCard extends StatelessWidget {
  final MeterDto meter;

  const EntryCard({super.key, required this.meter});

  _showDetails({
    required BuildContext context,
    required EntryDto item,
    required int usage,
    required EntryProvider entryProvider,
    required CostProvider costProvider,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => DetailsEntry(entry: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);
    final costProvider = Provider.of<CostProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeChanger>(context);
    final entryFilterProvider = Provider.of<EntryFilterProvider>(context);

    bool isLargeText =
        themeProvider.getFontSizeValue == FontSizeValue.large ? true : false;

    bool hasFilter = entryFilterProvider.getHasActiveFilters;

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Zählerstand',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const EntryFilterSheet(),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          if (hasFilter) _showHintHasFilter(context),
          StreamBuilder(
            stream: Provider.of<LocalDatabase>(context)
                .entryDao
                .watchAllEntries(meter.id!),
            builder: (context, snapshot) {
              final entry = snapshot.data?.reversed.toList();

              bool hasSelectedEntries = entryProvider.getHasSelectedEntries;

              if (entry != null && hasSelectedEntries == false) {
                entryProvider.setAllEntries(entry);
                costProvider.setEntries(entry);
              }

              List<EntryDto> entries = [];

              if (hasFilter) {
                final EntryFilterModel entryFilter =
                    entryFilterProvider.getEntryFilter;

                entries = entryProvider.getFilteredEntries(entryFilter);

                if (entries.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Es wurden keine Einträge mit den Filtern gefunden.',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  );
                }
              } else {
                entries = entryProvider.getAllEntries;
              }

              if (!meter.hasEntry) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: Text(
                    'Es wurden noch keine Messungen eingetragen!\nDrücken Sie jetzt auf das  +  um einen neuen Eintrag zu erstellen.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return SizedBox(
                height: isLargeText ? 150 : 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  primary: false,
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final item = entries.elementAt(index);

                    bool hasNote = false;

                    if (item.note != null && item.note!.isNotEmpty) {
                      hasNote = true;
                    }

                    int usage = entryProvider.getUsage(item);

                    String unit = entryProvider.getMeterUnit;

                    return GestureDetector(
                      onTap: () async {
                        if (hasSelectedEntries == false) {
                          _showDetails(
                              context: context,
                              item: item,
                              usage: usage,
                              entryProvider: entryProvider,
                              costProvider: costProvider);
                        } else {
                          entryProvider.setSelectedEntry(item);
                        }
                      },
                      onLongPress: () {
                        entryProvider.setSelectedEntry(item);
                      },
                      child: SizedBox(
                        width: isLargeText ? 300 : 240,
                        child: Card(
                          color: item.isSelected
                              ? Theme.of(context).highlightColor
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _showDateAndNote(
                                  item: item,
                                  hasNote: hasNote,
                                  context: context,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Divider(),
                                const SizedBox(
                                  height: 5,
                                ),
                                _showCountAndUsage(
                                  item: item,
                                  unit: unit,
                                  entryProvider: entryProvider,
                                  usage: usage,
                                  context: context,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _showHintHasFilter(BuildContext context) {
    final theme = Theme.of(context).textTheme.labelMedium;

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: theme!.fontSize,
                color: theme.color,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                'Einträge gefiltert',
                style: theme,
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  Widget _showDateAndNote({
    required EntryDto item,
    required bool hasNote,
    required BuildContext context,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('dd.MM.yyyy').format(item.date),
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.grey,
              ),
        ),
        Row(
          children: [
            if (hasNote)
              const Icon(
                Icons.note,
                color: Colors.grey,
              ),
            if (item.transmittedToProvider)
              const Icon(
                Icons.upload_file_rounded,
                color: Colors.grey,
              ),
            if (item.imagePath != null)
              const Icon(
                Icons.image,
                color: Colors.grey,
              ),
          ],
        ),
      ],
    );
  }

  Widget _showCountAndUsage({
    required EntryDto item,
    required String unit,
    required int usage,
    required EntryProvider entryProvider,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            ConvertMeterUnit().getUnitWidget(
              count: ConvertCount.convertCount(item.count),
              unit: unit,
              textStyle: Theme.of(context).textTheme.bodyMedium!,
            ),
            Text(
              'Zählerstand',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        if (usage != -1)
          Column(
            children: [
              ConvertMeterUnit().getUnitWidget(
                count: '+${ConvertCount.convertCount(usage)}',
                unit: unit,
                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: entryProvider.getColors(item.count, usage),
                    ),
              ),
              Text(
                'innerhalb ${item.days} Tagen',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        if (usage == -1 && !item.isReset)
          Text(
            'Erstablesung',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        if (item.isReset)
          Text(
            'Zurückgesetzt',
            style: Theme.of(context).textTheme.bodyMedium!,
          ),
      ],
    );
  }
}
