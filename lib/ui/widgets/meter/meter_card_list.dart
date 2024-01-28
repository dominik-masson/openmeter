import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:openmeter/core/provider/entry_provider.dart';
import 'package:provider/provider.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../../core/database/local_database.dart';
import '../../../core/enums/current_screen.dart';
import '../../../core/model/meter_dto.dart';
import '../../../core/model/meter_with_room.dart';

import '../../../core/model/room_dto.dart';
import '../../../core/provider/database_settings_provider.dart';
import '../../../core/provider/meter_provider.dart';
import '../../../core/provider/sort_provider.dart';
import '../../../utils/convert_count.dart';
import '../../../utils/custom_colors.dart';
import '../utils/empty_archiv.dart';
import '../utils/empty_data.dart';
import 'meter_card.dart';

class MeterCardList extends StatefulWidget {
  final Stream<List<MeterWithRoom>> stream;
  final bool isHomescreen;

  const MeterCardList(
      {super.key, required this.stream, required this.isHomescreen});

  @override
  State<MeterCardList> createState() => _MeterCardListState();
}

class _MeterCardListState extends State<MeterCardList> {
  bool isHomescreen = true;
  int _archivLength = 0;

  @override
  initState() {
    super.initState();
    isHomescreen = widget.isHomescreen;
  }

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
    final meterProvider = Provider.of<MeterProvider>(context);
    final databaseSettingsProvider =
        Provider.of<DatabaseSettingsProvider>(context, listen: false);
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);

    final sortBy = sortProvider.getSort;
    final orderBy = sortProvider.getOrder;

    bool hasSelectedItems = meterProvider.getStateHasSelectedMeters;
    bool hasUpdate = meterProvider.getStateHasUpdate;

    return StreamBuilder(
        stream: widget.stream,
        builder: (context, snapshot) {
          final data = snapshot.data ?? [];

          if (data.length != meterProvider.getAllMetersLength ||
              hasUpdate == true) {
            meterProvider.setAllMeters(data);
            meterProvider.setStateHasUpdate(false);
          }

          List<MeterWithRoom> meters = meterProvider.getAllMeters;

          if (isHomescreen == false) {
            meterProvider.setArchivMetersLength(meters.length);
          }

          if (meters.isEmpty) {
            if (isHomescreen) {
              return const EmptyData();
            } else {
              return const EmptyArchiv(
                  titel: 'Es wurden noch keine Zähler archiviert.');
            }
          }

          _archivLength = meterProvider.getArchivMetersLength;

          return ListView(
            children: [
              Padding(
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
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  shrinkWrap: true,
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

                        if (entryList == null) {
                          date = null;
                          count = 'none';
                        } else {
                          date = entryList.date;

                          count = ConvertCount.convertCount(entryList.count);
                        }

                        return GestureDetector(
                          onLongPress: () {
                            meterProvider.toggleSelectedMeter(meterItem);
                          },
                          child: hasSelectedItems == true
                              ? _cardWithoutSlide(
                                  db: db,
                                  meterItem: MeterDto.fromData(meterItem,
                                      entryList == null ? false : true),
                                  room: room,
                                  date: date,
                                  count: count,
                                  isSelected: element.isSelected,
                                  hasSelectedItems: hasSelectedItems,
                                  entryProvider: entryProvider,
                                  meterProvider: meterProvider,
                                )
                              : _cardWithSlide(
                                  meterProvider: meterProvider,
                                  db: db,
                                  meterItem: MeterDto.fromData(meterItem,
                                      entryList == null ? false : true),
                                  room: room,
                                  date: date,
                                  count: count,
                                  isSelected: element.isSelected,
                                  databaseSettingsProvider:
                                      databaseSettingsProvider,
                                  entryProvider: entryProvider,
                                  hasSelectedItems: hasSelectedItems,
                                ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              if (isHomescreen)
                TextButton(
                  onPressed: () {
                    if (hasSelectedItems) {
                      meterProvider.removeAllSelectedMeters(notify: false);
                    }
                    Navigator.of(context).pushReplacementNamed('archive');
                  },
                  child: Text(
                    'Archivierte Zähler ($_archivLength)',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              if (hasSelectedItems)
                const SizedBox(
                  height: 90,
                ),
            ],
          );
        });
  }

  Widget _cardWithSlide({
    required LocalDatabase db,
    required MeterDto meterItem,
    required RoomDto? room,
    required DateTime? date,
    required String count,
    required bool isSelected,
    required MeterProvider meterProvider,
    required DatabaseSettingsProvider databaseSettingsProvider,
    required bool hasSelectedItems,
    required EntryProvider entryProvider,
  }) {
    String label = isHomescreen ? 'Archivieren' : 'Wiederherstellen';
    IconData icon = isHomescreen ? Icons.archive : Icons.unarchive;

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              meterProvider.deleteSingleMeter(db, meterItem.id!, room);

              databaseSettingsProvider.setHasUpdate(true);
            },
            icon: Icons.delete,
            label: 'Löschen',
            backgroundColor: CustomColors.red,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
        ],
      ),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              await db.meterDao.updateArchived(meterItem.id!, isHomescreen);
              meterProvider.setArchivMetersLength(_archivLength + 1);
              databaseSettingsProvider.setHasUpdate(true);
            },
            icon: icon,
            label: label,
            foregroundColor: Colors.white,
            backgroundColor: CustomColors.blue,
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
        currentScreen: CurrentScreen.homescreen,
      ),
    );
  }

  Widget _cardWithoutSlide({
    required LocalDatabase db,
    required MeterDto meterItem,
    required RoomDto? room,
    required DateTime? date,
    required String count,
    required bool isSelected,
    required bool hasSelectedItems,
    required EntryProvider entryProvider,
    required MeterProvider meterProvider,
  }) {
    return MeterCard(
      meter: meterItem,
      room: room,
      date: date,
      count: count,
      isSelected: isSelected,
      currentScreen: CurrentScreen.homescreen,
    );
  }
}
