import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/database/local_database.dart';
import '../../../../core/enums/font_size_value.dart';
import '../../../../core/model/room_dto.dart';
import '../../../../core/provider/contract_provider.dart';
import '../../../../core/provider/room_provider.dart';
import '../../../../core/provider/theme_changer.dart';
import '../../../screens/rooms/details_room.dart';
import '../../../../utils/meter_typ.dart';
import '../../meter/meter_circle_avatar.dart';

class RoomCard extends StatefulWidget {
  const RoomCard({super.key});

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
    final themeProvider = Provider.of<ThemeChanger>(context);

    return StreamBuilder(
      stream: data.roomDao.watchAllRooms(),
      builder: (context, snapshot) {
        final List<RoomData> item = snapshot.data ?? [];

        if (item.isEmpty) {
          return Center(
            child: Text(
              'Es wurden noch keine Zimmer erstellt. \n Drücke jetzt auf das Plus um ein Zimmer zu erstellen.',
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          );
        }

        if (item.length != roomProvider.getAllRoomsLength) {
          roomProvider.convertData(item);
        }

        final second = roomProvider.getSecondRooms;
        final first = roomProvider.getFirstRooms;

        bool isLargeText = themeProvider.getFontSizeValue == FontSizeValue.large
            ? true
            : false;

        double height = 180;

        if (first.length == 1 && second.isEmpty) {
          if (isLargeText) {
            height = 180;
          } else {
            height = 170;
          }
        } else {
          if (isLargeText) {
            height = 390;
          } else {
            height = 350;
          }
        }

        return Column(
          children: [
            SizedBox(
              height: height,
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
                        isLargeText: isLargeText,
                      ),
                      if (room2 != null)
                        _roomCard(
                          room: room2,
                          data: data,
                          provider: roomProvider,
                          contractProvider: contractProvider,
                          isLargeText: isLargeText,
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
                activeDotColor: Theme.of(context).primaryColor,
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _numberCounter(BuildContext context, RoomDto room, LocalDatabase db) {
    return FutureBuilder(
      future: db.roomDao.getNumberCounts(room.uuid),
      builder: (context, snapshot) {
        room.sumMeter = snapshot.data;
        return Text(
          '${room.sumMeter} Zähler',
          style: Theme.of(context).textTheme.bodyMedium,
        );
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
              final avatarData = meterTyps
                  .firstWhere((element) => element.meterTyp == items)
                  .avatar;

              widget.add(Row(
                children: [
                  MeterCircleAvatar(
                    color: avatarData.color,
                    icon: avatarData.icon,
                  ),
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
      required ContractProvider contractProvider,
      required bool isLargeText}) {
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
        height: isLargeText ? 190 : 170,
        child: Card(
          color: room.isSelected! ? Theme.of(context).highlightColor : null,
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
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Zimmertyp',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          room.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Zimmername',
                          style: Theme.of(context).textTheme.labelMedium,
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
