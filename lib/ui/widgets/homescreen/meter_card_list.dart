import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../../core/database/local_database.dart';
import '../../../core/model/meter_with_room.dart';

import '../../../core/model/room_dto.dart';
import '../../../core/provider/database_settings_provider.dart';
import '../../../core/provider/meter_provider.dart';
import '../../../core/provider/sort_provider.dart';
import '../../../utils/convert_count.dart';
import '../../../utils/custom_colors.dart';
import '../empty_data.dart';
import 'meter_card.dart';

class MeterCardList extends StatefulWidget {
  const MeterCardList({Key? key}) : super(key: key);

  @override
  State<MeterCardList> createState() => _MeterCardListState();
}

class _MeterCardListState extends State<MeterCardList> {
  _groupBy(String sortBy, MeterWithRoom element) {
    dynamic sortedElement;

    switch (sortBy) {
      case 'room':
        if (element.room != null) {
          sortedElement = element.room!.name;
        } else {
          sortedElement = '';
        }
        break;
      case 'meter':
        sortedElement = element.meter.typ;
        break;
      default:
        sortedElement = 'room';
    }

    return sortedElement;
  }

  GroupedListOrder _orderBy(String order) {
    if (order == 'asc') {
      return GroupedListOrder.ASC;
    } else if (order == 'desc') {
      return GroupedListOrder.DESC;
    } else {
      return GroupedListOrder.ASC;
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context);
    final sortProvider = Provider.of<SortProvider>(context);
    final sortBy = sortProvider.getSort;
    final orderBy = sortProvider.getOrder;
    final meterProvider = Provider.of<MeterProvider>(context);

    bool hasSelectedItems = meterProvider.getStateHasSelectedMeters;
    bool hasUpdate = meterProvider.getStateHasUpdate;

    return StreamBuilder(
        stream: db.meterDao.watchAllMeterWithRooms(),
        builder: (context, snapshot) {
          final data = snapshot.data ?? [];

          if (data.length != meterProvider.getAllMetersLength ||
              hasUpdate == true) {
            meterProvider.setAllMeters(data);
            meterProvider.setStateHasUpdate(false);
          }

          List<MeterWithRoom> meters = meterProvider.getAllMeters;

          if (meters.isEmpty) {
            return const EmptyData();
          }

          return Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8),
            child: GroupedListView(
              stickyHeaderBackgroundColor: Theme.of(context).canvasColor,
              floatingHeader: false,
              elements: meters,
              groupBy: (element) {
                return _groupBy(sortBy, element);
              },
              order: _orderBy(orderBy),
              groupSeparatorBuilder: (element) => Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 2),
                child: Text(
                  element,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              itemBuilder: (context, element) {
                final meterItem = element.meter;

                final RoomDto? room = element.room == null
                    ? null
                    : RoomDto.fromData(element.room!);


                return StreamBuilder(
                  stream: db.entryDao.getNewestEntry(meterItem.id),
                  builder: (context, snapshot2) {
                    final entryList = snapshot2.data;

                    final DateTime? date;
                    final String count;
                    final Entrie entry;

                    if (entryList == null || entryList.isEmpty) {
                      date = null;
                      count = 'none';
                    } else {
                      entry = entryList[0];

                      date = entry.date;

                      count = ConvertCount.convertCount(entry.count);
                    }

                    return GestureDetector(
                      onLongPress: () {
                        meterProvider.toggleSelectedMeter(meterItem);
                      },
                      child: hasSelectedItems == true
                          ? _cardWithoutSlide(
                              db: db,
                              meterItem: meterItem,
                              room: room,
                              date: date,
                              count: count,
                              isSelected: element.isSelected)
                          : _cardWithSlide(
                              meterProvider: meterProvider,
                              db: db,
                              meterItem: meterItem,
                              room: room,
                              date: date,
                              count: count,
                              isSelected: element.isSelected),
                    );
                  },
                );
              },
            ),
          );
        });
  }

  Widget _cardWithSlide({
    required LocalDatabase db,
    required MeterData meterItem,
    required RoomDto? room,
    required DateTime? date,
    required String count,
    required bool isSelected,
    required MeterProvider meterProvider,
  }) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              meterProvider.deleteSingleMeter(db, meterItem.id, room);
              Provider.of<DatabaseSettingsProvider>(context, listen: false)
                  .setHasUpdate(true);
            },
            icon: Icons.delete,
            label: 'Löschen',
            backgroundColor: CustomColors.red,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
        ],
      ),
      child: MeterCard(
        meter: meterItem,
        room: room,
        date: date,
        count: count,
        isSelected: isSelected,
      ),
    );
  }

  Widget _cardWithoutSlide({
    required LocalDatabase db,
    required MeterData meterItem,
    required RoomDto? room,
    required DateTime? date,
    required String count,
    required bool isSelected,
  }) {
    return MeterCard(
      meter: meterItem,
      room: room,
      date: date,
      count: count,
      isSelected: isSelected,
    );
  }
}
