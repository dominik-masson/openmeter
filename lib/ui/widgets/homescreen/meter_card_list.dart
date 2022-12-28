import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../../core/database/local_database.dart';
import '../../../core/database/models/meter_with_room.dart';

import '../../../core/provider/sort_provider.dart';
import '../empty_data.dart';
import 'meter_card.dart';

class MeterCardList extends StatefulWidget {
  const MeterCardList({Key? key}) : super(key: key);

  @override
  State<MeterCardList> createState() => _MeterCardListState();
}

class _MeterCardListState extends State<MeterCardList> {
  final MeterCard _meterCard = const MeterCard();

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
    final data = Provider.of<LocalDatabase>(context);
    final sortProvider = Provider.of<SortProvider>(context);
    final sortBy = sortProvider.getSort;
    final orderBy = sortProvider.getOrder;

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
                return StreamBuilder(
                  stream: data.meterDao.getNewestEntry(meterItem.id),
                  builder: (context, snapshot2) {
                    final entryList = snapshot2.data;

                    if (entryList == null || entryList.isEmpty) {
                      return Container();
                    }

                    final entry = entryList[0];
                    final String date;
                    final String count;

                    if (entry == null) {
                      date = 'none';
                      count = 'none';
                    } else {
                      date = DateFormat('dd.MM.yyyy').format(entry.date);
                      count = entry.count.toString();
                    }

                    return _meterCard.getCard(
                        context: context,
                        meter: meterItem,
                        room: element.room,
                        date: date,
                        count: count);
                  },
                );
              },
            ),
          );
        });
  }
}
