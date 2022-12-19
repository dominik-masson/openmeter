import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../core/database/local_database.dart';
import '../../core/database/models/meter_with_room.dart';
import '../screens/details_single_meter.dart';
import '../utils/meter_typ.dart';
import 'empty_data.dart';

class MeterCard extends StatefulWidget {
  const MeterCard({Key? key}) : super(key: key);

  @override
  State<MeterCard> createState() => _MeterCardState();
}

class _MeterCardState extends State<MeterCard> {



  @override
  initState() {
    // _firstInit = true;
    super.initState();
  }


  Future<bool> _deleteMeter(BuildContext context, int meterId) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sind Sie sich sicher?'),
            content: const Text('Möchten Sie diesen Zähler wirklich löschen?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<LocalDatabase>(context, listen: false)
                      .meterDao
                      .deleteMeter(meterId);
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'Löschen',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<LocalDatabase>(context);

    return StreamBuilder<List<MeterWithRoom>>(
        stream: data.meterDao.watchAllMeterWithRooms(),
        builder: (context, snapshot) {
          final meters = snapshot.data;

          // print(snapshot.connectionState);
          // print(meters);

          if (meters == null || meters.isEmpty) {
            return const EmptyData();
          }

          return Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8),
            child: GroupedListView(
              stickyHeaderBackgroundColor: Theme.of(context).canvasColor,
              floatingHeader: false,
              elements: meters,
              groupBy: (element) {
                if (element.room != null) {
                  return element.room!.name;
                } else {
                  return '';
                }
              },
              groupSeparatorBuilder: (element) => Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 2),
                child: Text(
                  element,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              itemBuilder: (context, element) {
                final meterItem = element.meter;
                return StreamBuilder(
                  stream: data.meterDao.getNewestEntry(meterItem.id),
                  builder: (context, snapshot2) {
                    final entry = snapshot2.data?[0];
                    final String date;
                    final String count;

                    // print(snapshot2.data);
                    if (entry == null) {
                      date = 'none';
                      count = 'none';
                    } else {
                      date = DateFormat('dd.MM.yyyy').format(entry.date);
                      count = entry.count.toString();
                    }

                    return _card(context, meterItem, entry, element.room, date, count);
                  },
                );
              },
            ),
          );
        });
  }

  Widget _card(BuildContext context, MeterData meterItem, Entrie? entry, RoomData? room,
      String date, String count) {
    return Dismissible(
      key: Key('${meterItem.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _deleteMeter(context, meterItem.id);
      },
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.all(50),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DetailsSingleMeter(meter: meterItem, room: room,),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4),
          child: Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      meterTyps[meterItem.typ]['avatar'] as Widget,
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        meterItem.typ,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            meterItem.number,
                          ),
                          const Text(
                            "Zählernummer",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        children: [
                          Text(
                            '$count ${meterTyps[meterItem.typ]['einheit']}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const Text(
                            "Zählerstand",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        meterItem.note.toString(),
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'zuletzt geändert: $date',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
