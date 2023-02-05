import 'package:flutter/material.dart';

import '../../core/database/local_database.dart';

import '../widgets/details_meter/add_entry.dart';
import '../widgets/details_meter/cost_card.dart';
import '../widgets/details_meter/entry_card.dart';
import '../widgets/details_meter/meter_count_line_chart.dart';
import 'add_meter.dart';

class DetailsSingleMeter extends StatefulWidget {
  final MeterData meter;
  final RoomData? room;
  final String count;

  const DetailsSingleMeter({Key? key, required this.meter, required this.room, required this.count})
      : super(key: key);

  @override
  State<DetailsSingleMeter> createState() => _DetailsSingleMeterState();
}

class _DetailsSingleMeterState extends State<DetailsSingleMeter> {

  String _meterName = '';
  String _roomName = '';
  late MeterData _meter;
  late RoomData? _room;

  late final AddEntry _addEntry;

  @override
  void initState() {
    _meterName = widget.meter.number;
    _meter = widget.meter;
    _room = widget.room;
    _roomName = widget.room?.name ?? '';
    _addEntry = AddEntry(meter: _meter, countString: widget.count);
    super.initState();
  }

  @override
  void dispose() {
    _addEntry.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_meterName),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop(_room);
          },
        ),
        actions: [
          IconButton(
            onPressed: () => _addEntry.showBottomModel(context),
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddScreen(
                      meter: _meter,
                      room: _room,
                    ),
                  )).then((value) {
                if (value == null) {
                  return;
                }

                _meter = value[0] as MeterData;
                _room = value[1] as RoomData?;

                setState(
                  () {
                    _meterName = _meter.number;
                    _roomName = _room?.name ?? '';
                  },
                );
              });
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Zählernummer
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _meter.note,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    _roomName,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            EntryCard(meter: widget.meter),
            const SizedBox(
              height: 10,
            ),
            LineChartSingleMeter(
              meterId: widget.meter.id,
            ),

            CostBar(meter: _meter),
          ],
        ),
      ),
    );
  }
}
