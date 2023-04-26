import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openmeter/ui/widgets/details_meter/details_entry.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/provider/cost_provider.dart';
import '../../../core/provider/entry_card_provider.dart';

class EntryCard extends StatelessWidget {
  final MeterData meter;
  final DetailsEntry _detailsEntry = DetailsEntry();

  EntryCard({Key? key, required this.meter}) : super(key: key);

  _deleteEntry(BuildContext context, int entryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Löschen?'),
        content: const Text('Möchten Sie Ihren Zählerstand wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<LocalDatabase>(context, listen: false)
                  .entryDao
                  .deleteEntry(entryId)
                  .then((value) {
                Navigator.of(context).pop();
              });
            },
            child: const Text(
              'Löschen',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
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

              return SizedBox(
                height: 150,
                width: double.infinity,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  primary: false,
                  itemCount: entry.length,
                  itemBuilder: (context, index) {
                    final item = entry[index];
                    Entrie reservedItem;
                    final reserved = entry.reversed.toList();

                    int usage = entryProvider.getUsage(item);

                    String unit = meter.unit;

                    return GestureDetector(
                      onTap: () async {
                        var value = await _detailsEntry.getDetailsAlert(
                          context: context,
                          entry: item,
                          meter: meter,
                          usage: usage,
                          entryProvider: entryProvider,
                          costProvider: costProvider,
                        );

                        if (value == null) {
                          entryProvider.setStateNote(false);
                        }
                      },
                      child: SizedBox(
                        width: 240,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd.MM.yyyy')
                                          .format(item.date),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        if (entry.length > 1) {
                                          reservedItem = reserved
                                              .elementAt(entry.length - 2);
                                          entryProvider
                                              .setOldDate(reservedItem.date);
                                          entryProvider.setCurrentCount(
                                              reservedItem.count.toString());
                                        } else {
                                          entryProvider.setCurrentCount('none');
                                        }
                                        _deleteEntry(context, item.id);
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          '${item.count} $unit',
                                          style: const TextStyle(fontSize: 16),
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
                                          Text(
                                            '+$usage $unit',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: entryProvider.getColors(
                                                  item.count, usage),
                                            ),
                                          ),
                                          Text(
                                            'innerhalb ${item.days} Tagen',
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    if (usage == -1)
                                      const Text(
                                        'Erstablesung',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                  ],
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
}
