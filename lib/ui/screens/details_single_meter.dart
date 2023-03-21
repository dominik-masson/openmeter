import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/database/local_database.dart';

import '../../core/provider/chart_provider.dart';
import '../../core/provider/entry_card_provider.dart';
import '../widgets/details_meter/add_entry.dart';
import '../widgets/details_meter/charts/count_line_chart.dart';
import '../widgets/details_meter/charts/usage_line_chart.dart';
import '../widgets/details_meter/cost_card.dart';
import '../widgets/details_meter/entry_card.dart';
import '../widgets/details_meter/charts/count_bar_chart.dart';
import 'add_meter.dart';

class DetailsSingleMeter extends StatefulWidget {
  final MeterData meter;
  final RoomData? room;
  final List<String> tagsId;

  const DetailsSingleMeter({Key? key, required this.meter, required this.room, required this.tagsId})
      : super(key: key);

  @override
  State<DetailsSingleMeter> createState() => _DetailsSingleMeterState();
}

class _DetailsSingleMeterState extends State<DetailsSingleMeter> {
  String _meterName = '';
  String _roomName = '';
  late MeterData _meter;
  late RoomData? _room;

  int _activeChartWidget = 0;

  late final AddEntry _addEntry;

  @override
  void initState() {
    _meterName = widget.meter.number;
    _meter = widget.meter;
    _room = widget.room;
    _roomName = widget.room?.name ?? '';
    _addEntry = AddEntry(meter: _meter);
    super.initState();
  }

  @override
  void dispose() {
    _addEntry.dispose();
    super.dispose();
  }

  Widget _meterInformationWidget() {
    return Padding(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryCardProvider>(context);
    final chartProvider = Provider.of<ChartProvider>(context);

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
            onPressed: () {
              _addEntry.showBottomModel(context, entryProvider);
            },
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
                      tagsId: widget.tagsId,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Zählernummer
            _meterInformationWidget(),
            const Divider(),
            EntryCard(meter: widget.meter),
            const SizedBox(
              height: 10,
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 340,
                      enableInfiniteScroll: false,
                      viewportFraction: 1,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _activeChartWidget = index;
                        });
                      },
                    ),
                    items: [
                      if (!chartProvider.getLineChart)
                        CountBarChart(
                          meter: _meter,
                        ),
                      if (chartProvider.getLineChart)
                        CountLineChart(
                          meter: _meter,
                        ),
                      UsageLineChart(meter: _meter),
                    ],
                  ),
                ),
                AnimatedSmoothIndicator(
                  activeIndex: _activeChartWidget,
                  count: 2,
                  effect: WormEffect(
                    activeDotColor: Theme.of(context).primaryColorLight,
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),
              ],
            ),

            CostBar(meter: _meter),
          ],
        ),
      ),
    );
  }
}
