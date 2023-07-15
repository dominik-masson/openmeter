import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/model/room_dto.dart';
import '../../../core/provider/cost_provider.dart';
import '../../../core/provider/entry_card_provider.dart';
import '../../../core/provider/meter_provider.dart';
import '../../../core/provider/small_feature_provider.dart';
import '../../../core/provider/sort_provider.dart';
import '../../../utils/convert_meter_unit.dart';
import '../../../utils/meter_typ.dart';
import '../../screens/details_single_meter.dart';
import '../tags_screen/horizontal_tags_list.dart';

class MeterCard extends StatefulWidget {
  final MeterData meter;
  final RoomDto? room;
  final DateTime? date;
  final String count;
  final bool isSelected;

  const MeterCard({
    super.key,
    required this.meter,
    required this.room,
    required this.date,
    required this.count,
    required this.isSelected,
  });

  @override
  State<MeterCard> createState() => _MeterCardState();
}

class _MeterCardState extends State<MeterCard> {
  RoomDto? room;
  bool hasTags = false;

  @override
  void initState() {
    room = widget.room;
    super.initState();
  }

  setHasTags(bool value) {
    hasTags = value;
  }

  @override
  Widget build(BuildContext context) {
    final sortProvider = Provider.of<SortProvider>(context);
    final smallProvider = Provider.of<SmallFeatureProvider>(context);
    final meterProvider = Provider.of<MeterProvider>(context);

    bool hasSelectedItems = meterProvider.getStateHasSelectedMeters;

    String roomName = widget.room == null ? '' : widget.room!.name!;

    final entryProvider =
        Provider.of<EntryCardProvider>(context, listen: false);

    String dateText = 'none';

    if (widget.date != null) {
      dateText = DateFormat('dd.MM.yyyy').format(widget.date!);
    }

    return GestureDetector(
      onTap: () {
        if (hasSelectedItems == true) {
          meterProvider.toggleSelectedMeter(widget.meter);
        } else {
          entryProvider.setCurrentCount(widget.count);
          entryProvider.setOldDate(widget.date ?? DateTime.now());
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
            entryProvider.removeAllSelectedEntries();
            room = value as RoomDto?;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0, right: 4),
        child: Card(
          elevation: 3,
          color:
              widget.isSelected == true ? Colors.grey.withOpacity(0.5) : null,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        meterTyps[widget.meter.typ]['avatar'] as Widget,
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          widget.meter.typ,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    if (sortProvider.getSort == 'meter')
                      Text(
                        roomName,
                        style: const TextStyle(fontSize: 16),
                      ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          widget.meter.number,
                          style: const TextStyle(fontSize: 16),
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
                        ConvertMeterUnit().getUnitWidget(
                          count: widget.count,
                          unit: widget.meter.unit,
                          textStyle: const TextStyle(fontSize: 16),
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
                    Flexible(
                      child: Text(
                        widget.meter.note.toString(),
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                if (smallProvider.getShowTags)
                  HorizontalTagsList(
                    meterId: widget.meter.id,
                    setHasTags: (p0) => setHasTags(p0),
                  ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'zuletzt geändert: $dateText',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
