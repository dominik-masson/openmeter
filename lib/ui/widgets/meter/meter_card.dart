import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openmeter/core/enums/current_screen.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/model/meter_dto.dart';
import '../../../core/model/meter_typ.dart';
import '../../../core/model/room_dto.dart';
import '../../../core/provider/cost_provider.dart';
import '../../../core/provider/entry_card_provider.dart';
import '../../../core/provider/meter_provider.dart';
import '../../../core/provider/room_provider.dart';
import '../../../core/provider/small_feature_provider.dart';
import '../../../core/provider/sort_provider.dart';
import '../../../utils/convert_meter_unit.dart';
import '../../../utils/meter_typ.dart';
import '../../screens/meters/details_single_meter.dart';
import '../tags/horizontal_tags_list.dart';
import 'meter_circle_avatar.dart';

class MeterCard extends StatefulWidget {
  final MeterDto meter;
  final RoomDto? room;
  final DateTime? date;
  final String count;
  final bool isSelected;
  final Function? refreshState;
  final CurrentScreen currentScreen;

  const MeterCard({
    super.key,
    required this.meter,
    required this.room,
    required this.date,
    required this.count,
    required this.isSelected,
    this.refreshState,
    required this.currentScreen,
  });

  @override
  State<MeterCard> createState() => _MeterCardState();
}

class _MeterCardState extends State<MeterCard> {
  RoomDto? room;
  bool hasTags = false;

  late MeterData _meterData;

  @override
  void initState() {
    room = widget.room;

    _meterData = widget.meter.toMeterData();
    super.initState();
  }

  setHasTags(bool value) {
    hasTags = value;
  }

  _meterInformation() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(),
        1: FlexColumnWidth(),
        2: FixedColumnWidth(100),
      },
      children: [
        TableRow(
          children: [
            Column(
              children: [
                Text(
                  widget.meter.number,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  "Zählernummer",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            Column(
              children: [
                if (widget.count != 'none')
                  ConvertMeterUnit().getUnitWidget(
                    count: widget.count,
                    unit: widget.meter.unit,
                    textStyle: Theme.of(context).textTheme.bodyMedium!,
                  ),
                if (widget.count == 'none')
                  Text(
                    "Kein Eintrag",
                    style: Theme.of(context).textTheme.bodyMedium!,
                    textAlign: TextAlign.center,
                  ),
                Text(
                  "Zählerstand",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  widget.meter.note.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(fontSize: 14),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  _handleOnTapFromMeterCardList({
    required bool hasSelectedItems,
    required MeterProvider meterProvider,
    required EntryCardProvider entryProvider,
  }) {
    if (hasSelectedItems == true) {
      meterProvider.toggleSelectedMeter(_meterData);
    } else {
      entryProvider.setCurrentCount(widget.count);
      entryProvider.setOldDate(widget.date ?? DateTime.now());
      entryProvider.setHasEntries(widget.meter.hasEntry);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            entryProvider.setMeterUnit(widget.meter.unit);

            return DetailsSingleMeter(
              meter: widget.meter,
              room: widget.room,
              hasTags: hasTags,
            );
          },
        ),
      ).then((value) {
        Provider.of<CostProvider>(context, listen: false).resetValues();
        Provider.of<RoomProvider>(context, listen: false).setHasUpdate(true);
        entryProvider.removeAllSelectedEntries();
        room = value as RoomDto?;
      });
    }
  }

  _handleOnTapFromDetailsRoom({
    required RoomProvider roomProvider,
    required EntryCardProvider entryProvider,
  }) {
    if (roomProvider.getHasSelectedMeters) {
      roomProvider.toggleSelectedMeters(MeterDto.fromData(_meterData, false));
    } else {
      entryProvider.setCurrentCount(widget.count);
      entryProvider.setOldDate(widget.date ?? DateTime.now());

      room = roomProvider.getCurrentRoom;

      entryProvider.setHasEntries(widget.meter.hasEntry);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            entryProvider.setMeterUnit(widget.meter.unit);

            return DetailsSingleMeter(
              meter: widget.meter,
              room: room,
              hasTags: hasTags,
            );
          },
        ),
      ).then((value) {
        Provider.of<CostProvider>(context, listen: false).resetValues();

        entryProvider.removeAllSelectedEntries();

        final newRoom = value as RoomDto?;

        if (newRoom == null || room?.id != newRoom.id) {
          final roomProvider =
              Provider.of<RoomProvider>(context, listen: false);
          roomProvider.setHasUpdate(true);
          roomProvider.setMeterCount(-1);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortProvider = Provider.of<SortProvider>(context);
    final smallProvider = Provider.of<SmallFeatureProvider>(context);
    final meterProvider = Provider.of<MeterProvider>(context);
    final roomProvider = Provider.of<RoomProvider>(context);

    bool hasSelectedItems = meterProvider.getStateHasSelectedMeters;

    String roomName = widget.room == null ? '' : widget.room!.name;

    final entryProvider =
        Provider.of<EntryCardProvider>(context, listen: false);

    String dateText = 'none';

    if (widget.date != null) {
      dateText = DateFormat('dd.MM.yyyy').format(widget.date!);
    }

    final CustomAvatar avatarData = meterTyps
        .firstWhere((element) => element.meterTyp == widget.meter.typ)
        .avatar;

    return GestureDetector(
      onTap: () {
        switch (widget.currentScreen) {
          case CurrentScreen.homescreen:
            _handleOnTapFromMeterCardList(
              hasSelectedItems: hasSelectedItems,
              meterProvider: meterProvider,
              entryProvider: entryProvider,
            );
            break;
          case CurrentScreen.detailsRoom:
            _handleOnTapFromDetailsRoom(
              roomProvider: roomProvider,
              entryProvider: entryProvider,
            );
            break;
          default:
            null;
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0, right: 4),
        child: Card(
          elevation: 3,
          color: widget.isSelected == true
              ? Theme.of(context).highlightColor
              : null,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        MeterCircleAvatar(
                          color: avatarData.color,
                          icon: avatarData.icon,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          widget.meter.typ,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    if (sortProvider.getSort == 'meter')
                      Text(
                        roomName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                _meterInformation(),
                const SizedBox(
                  height: 10,
                ),
                if (smallProvider.getShowTags)
                  HorizontalTagsList(
                    meterId: widget.meter.id!,
                    setHasTags: (p0) => setHasTags(p0),
                  ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'zuletzt geändert: $dateText',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
