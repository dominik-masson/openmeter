import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/database/local_database.dart';
import '../screens/details_room.dart';
import '../utils/meter_typ.dart';

class RoomCard extends StatefulWidget {
  const RoomCard({Key? key}) : super(key: key);

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  Future<bool> _deleteRoom(BuildContext context, int roomId) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Löschen?'),
            content: const Text('Möchten Sie dieses Zimmer wirklich löschen?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<LocalDatabase>(context, listen: false)
                      .roomDao
                      .deleteRoom(roomId);
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
    return StreamBuilder(
      stream: data.roomDao.watchAllRooms(),
      builder: (context, snapshot) {
        final item = snapshot.data ?? [];
        if (item.isEmpty) {
          return const Center(
            child: Text(
              'Es wurden noch keine Zimmer erstellt. \n Drücke jetzt auf das Plus um ein Zimmer zu erstellen.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          semanticChildCount: item.length < 3 ? 0 : 3,
          shrinkWrap: true,
          itemCount: item.length,
          itemBuilder: (context, index) {
            final room = item[index];
            return Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: Dismissible(
                key: Key('${room.id}'),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await _deleteRoom(context, room.id);
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
                      builder: (context) => DetailsRoom(
                        roomData: room,
                      ),
                    ));
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    room.typ,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Text(
                                    'Zimmertyp',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    room.name,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Text(
                                    'Zimmername',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: _numberCounter(context, room, data),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 15.0, bottom: 8),
                            child: Row(
                              children: [
                                _getMeterTyps(context, room.id, data),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _numberCounter(
      BuildContext context, RoomData room, LocalDatabase data) {
    return FutureBuilder(
      future: data.roomDao.getNumberCounts(room.id),
      builder: (context, snapshot) {
        return Text('${snapshot.data.toString()} Zähler');
      },
    );
  }

  Widget _getMeterTyps(BuildContext context, int room, LocalDatabase data) {
    return FutureBuilder(
      future: data.roomDao.getTypOfMeter(room),
      builder: (context, snapshot) {
        final meter = snapshot.data;
        return FutureBuilder(
          future: meter,
          builder: (context, snapshot) {
            final item = snapshot.data;

            if (item == null || item.isEmpty) {
              return Container();
            }

            return Row(
              children: [
                for (var items in item) meterTyps[items]['avatar'],
              ],
            );
          },
        );
      },
    );
  }
}
