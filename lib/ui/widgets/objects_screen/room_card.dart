import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/database/local_database.dart';
import '../../../core/model/room_dto.dart';
import '../../../core/provider/contract_provider.dart';
import '../../../core/provider/room_provider.dart';
import '../../screens/details_room.dart';
import '../../../utils/meter_typ.dart';

class RoomCard extends StatefulWidget {
  const RoomCard({Key? key}) : super(key: key);

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  int _pageIndex = 0;
  final _pageController = PageController(initialPage: 0, keepPage: true);

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<LocalDatabase>(context);
    final roomProvider = Provider.of<RoomProvider>(context);
    final contractProvider = Provider.of<ContractProvider>(context);

    return StreamBuilder(
      stream: data.roomDao.watchAllRooms(),
      builder: (context, snapshot) {
        final List<RoomData> item = snapshot.data ?? [];

        if (item.isEmpty) {
          return const Center(
            child: Text(
              'Es wurden noch keine Zimmer erstellt. \n Drücke jetzt auf das Plus um ein Zimmer zu erstellen.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (item.length != roomProvider.getAllRoomsLength) {
          roomProvider.convertData(item);
        }

        final second = roomProvider.getSecondRooms;
        final first = roomProvider.getFirstRooms;

        return Column(
          children: [
            SizedBox(
              height: first.length == 1 && second.isEmpty ? 170 : 320,
              child: PageView.builder(
                controller: _pageController,
                physics: const AlwaysScrollableScrollPhysics(),
                onPageChanged: (value) {
                  setState(() {
                    _pageIndex = value;
                  });
                },
                itemCount: first.length,
                itemBuilder: (context, index) {
                  RoomDto room1 = first.elementAt(index);
                  RoomDto? room2;

                  if (index < second.length) {
                    room2 = second.elementAt(index);
                  }

                  return Column(
                    children: [
                      _roomCard(
                        room: room1,
                        data: data,
                        provider: roomProvider,
                        contractProvider: contractProvider,
                      ),
                      if (room2 != null)
                        _roomCard(
                          room: room2,
                          data: data,
                          provider: roomProvider,
                          contractProvider: contractProvider,
                        ),
                    ],
                  );
                },
              ),
            ),
            AnimatedSmoothIndicator(
              activeIndex: _pageIndex,
              count: first.length,
              effect: WormEffect(
                activeDotColor: Theme.of(context).primaryColorLight,
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _numberCounter(
      BuildContext context, RoomDto room, LocalDatabase db) {
    return FutureBuilder(
      future: db.roomDao.getNumberCounts(room.uuid),
      builder: (context, snapshot) {
        room.sumMeter = snapshot.data;
        return Text('${room.sumMeter} Zähler');
      },
    );
  }

  Widget _getMeterTyps(BuildContext context, String room, LocalDatabase data) {
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

            List<Widget> widget = [];

            for (var items in item) {
              widget.add(Row(
                children: [
                  meterTyps[items]['avatar'],
                  const SizedBox(
                    width: 2.5,
                  ),
                ],
              ));
            }

            return Row(children: widget);
          },
        );
      },
    );
  }

  Widget _roomCard(
      {required RoomDto room,
      required LocalDatabase data,
      required RoomProvider provider,
      required ContractProvider contractProvider}) {
    return GestureDetector(
      onLongPress: () {
        if (contractProvider.getHasSelectedItems == false) {
          provider.toggleSelectedRooms(room);
        }
      },
      onTap: () {
        if (contractProvider.getHasSelectedItems == false) {
          if (provider.getStateHasSelected == true) {
            provider.toggleSelectedRooms(room);
          } else {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => DetailsRoom(
                  roomData: room,
                ),
              ),
            )
                .then((value) {
              setState(() {});
            });
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.only(left: 8, right: 8),
        height: 158,
        child: Card(
          color: room.isSelected! ? Colors.grey.withOpacity(0.5) : null,
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
                  padding: const EdgeInsets.only(left: 15.0, bottom: 8),
                  child: Row(
                    children: [
                      _getMeterTyps(context, room.uuid, data),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
