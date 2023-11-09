import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openmeter/ui/widgets/details_meter/details_entry.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/enums/font_size_value.dart';
import '../../../core/provider/cost_provider.dart';
import '../../../core/provider/entry_card_provider.dart';
import '../../../core/provider/theme_changer.dart';
import '../../../utils/convert_count.dart';
import '../../../utils/convert_meter_unit.dart';

class EntryCard extends StatelessWidget {
  final MeterData meter;
  final DetailsEntry _detailsEntry = DetailsEntry();

  EntryCard({super.key, required this.meter});

  _showDetails({
    required BuildContext context,
    required Entrie item,
    required int usage,
    required EntryCardProvider entryProvider,
    required CostProvider costProvider,
  }) async {
    var value = await _detailsEntry.getDetailsAlert(
      context: context,
      entry: item,
      usage: usage,
      entryProvider: entryProvider,
      costProvider: costProvider,
    );

    if (value == null) {
      entryProvider.setStateNote(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryCardProvider>(context);
    final costProvider = Provider.of<CostProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeChanger>(context);

    bool isLargeText =
        themeProvider.getFontSizeValue == FontSizeValue.large ? true : false;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zählerstand',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          StreamBuilder(
            stream: Provider.of<LocalDatabase>(context)
                .entryDao
                .watchAllEntries(meter.id),
            builder: (context, snapshot) {
              final entry = snapshot.data?.reversed.toList();

              bool hasSelectedEntries = entryProvider.getHasSelectedEntries;

              if (entry == null || entry.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Es wurden noch keine Messungen eingetragen!',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Colors.grey),
                    ),
                  ),
                );
              }

              if (hasSelectedEntries == false) {
                entryProvider.setAllEntries(entry);
              }

              Map<Entrie, bool> entries = entryProvider.getAllEntries;

              return SizedBox(
                height: isLargeText ? 150 : 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  primary: false,
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final item = entries.keys.elementAt(index);
                    bool isSelected = entries.values.elementAt(index);
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
                          color: isSelected
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

  Widget _showDateAndNote({
    required Entrie item,
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
            const SizedBox(
              width: 10,
            ),
            if (item.transmittedToProvider)
              const Icon(
                Icons.upload_file_rounded,
                color: Colors.grey,
              ),
          ],
        ),
      ],
    );
  }

  Widget _showCountAndUsage({
    required Entrie item,
    required String unit,
    required int usage,
    required EntryCardProvider entryProvider,
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
