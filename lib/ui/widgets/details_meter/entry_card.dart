import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openmeter/ui/widgets/details_meter/details_entry.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/provider/cost_provider.dart';
import '../../../core/provider/entry_card_provider.dart';
import '../../../utils/convert_count.dart';
import '../../../utils/convert_meter_unit.dart';

class EntryCard extends StatelessWidget {
  final MeterData meter;
  final DetailsEntry _detailsEntry = DetailsEntry();

  EntryCard({Key? key, required this.meter}) : super(key: key);

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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Zählerstand',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          StreamBuilder(
            stream: Provider.of<LocalDatabase>(context)
                .entryDao
                .watchAllEntries(meter.id),
            builder: (context, snapshot) {
              final entry = snapshot.data?.reversed.toList();

              bool hasSelectedEntries = entryProvider.getHasSelectedEntries;

              if (entry == null || entry.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Es wurden noch keine Messungen eingetragen!',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                );
              }

              if (hasSelectedEntries == false) {
                entryProvider.setAllEntries(entry);
              }

              Map<Entrie, bool> entries = entryProvider.getAllEntries;

              return SizedBox(
                height: 120,
                width: double.infinity,
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
                        width: 240,
                        child: Card(
                          color:
                              isSelected ? Theme.of(context).hoverColor : null,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _showDateAndNote(item: item, hasNote: hasNote),
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

  Widget _showDateAndNote({required Entrie item, required bool hasNote}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('dd.MM.yyyy').format(item.date),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        if (hasNote)
          const Icon(
            Icons.note,
            color: Colors.grey,
          ),
        // IconButton(
        //   onPressed: () {
        //     if (entry.length > 1) {
        //       reservedItem = reserved
        //           .elementAt(entry.length - 2);
        //       entryProvider
        //           .setOldDate(reservedItem.date);
        //       entryProvider.setCurrentCount(
        //           reservedItem.count.toString());
        //     } else {
        //       entryProvider.setCurrentCount('none');
        //     }
        //     _deleteEntry(context, item.id);
        //   },
        //   icon: const Icon(
        //     Icons.delete,
        //     color: Colors.grey,
        //   ),
        // ),
      ],
    );
  }

  Widget _showCountAndUsage({
    required Entrie item,
    required String unit,
    required int usage,
    required EntryCardProvider entryProvider,
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
              textStyle: const TextStyle(fontSize: 16),
            ),
            const Text(
              'Zählerstand',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        if (usage != -1)
          Column(
            children: [
              ConvertMeterUnit().getUnitWidget(
                count: '+${ConvertCount.convertCount(usage)}',
                unit: unit,
                textStyle: TextStyle(
                  fontSize: 16,
                  color: entryProvider.getColors(item.count, usage),
                ),
              ),
              Text(
                'innerhalb ${item.days} Tagen',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        if (usage == -1)
          const Text(
            'Erstablesung',
            style: TextStyle(fontSize: 16),
          ),
      ],
    );
  }
}
