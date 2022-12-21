import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/database/local_database.dart';
import '../screens/details_single_meter.dart';
import '../utils/meter_typ.dart';

class MeterCard {
  const MeterCard();

  Future<bool> _deleteMeter(
      BuildContext context, int meterId, RoomData? room) async {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Löschen?'),
            content: const Text('Möchten Sie diesen Zähler wirklich löschen?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () {
                  if (room != null) {
                    db.roomDao.deleteMeter(meterId);
                  }

                  db.meterDao.deleteMeter(meterId);
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

  Widget getCard(
      {required BuildContext context,
      required MeterData meter,
      RoomData? room,
      required String date,
      required String count}) {
    return Dismissible(
      key: Key('${meter.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _deleteMeter(context, meter.id, room);
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
            builder: (context) => DetailsSingleMeter(
              meter: meter,
              room: room,
            ),
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
                      meterTyps[meter.typ]['avatar'] as Widget,
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        meter.typ,
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
                            meter.number,
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
                            '$count ${meterTyps[meter.typ]['einheit']}',
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
                        meter.note.toString(),
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
