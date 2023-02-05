import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../utils/meter_typ.dart';

class EntryCard extends StatelessWidget {
  final MeterData meter;

  const EntryCard({Key? key, required this.meter}) : super(key: key);

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
                    return SizedBox(
                      width: 180,
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
                                    DateFormat('dd.MM.yyyy').format(item.date),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _deleteEntry(context, item.id),
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
                              Text(
                                '${item.count} ${meterTyps[meter.typ]['einheit']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Text(
                                'Zählerstand',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
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
