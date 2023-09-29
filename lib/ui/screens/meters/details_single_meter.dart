import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/database/local_database.dart';

import '../../../core/model/room_dto.dart';
import '../../../core/provider/chart_provider.dart';
import '../../../core/provider/database_settings_provider.dart';
import '../../../core/provider/entry_card_provider.dart';
import '../../widgets/details_meter/add_entry.dart';
import '../../widgets/details_meter/charts/count_line_chart.dart';
import '../../widgets/details_meter/charts/usage_line_chart.dart';
import '../../widgets/details_meter/cost_card.dart';
import '../../widgets/details_meter/entry_card.dart';
import '../../widgets/details_meter/charts/usage_bar_chart.dart';
import '../../widgets/tags/horizontal_tags_list.dart';
import 'add_meter.dart';

class DetailsSingleMeter extends StatefulWidget {
  final MeterData meter;
  final RoomDto? room;
  final bool hasTags;

  const DetailsSingleMeter(
      {Key? key,
      required this.meter,
      required this.room,
      required this.hasTags})
      : super(key: key);

  @override
  State<DetailsSingleMeter> createState() => _DetailsSingleMeterState();
}

class _DetailsSingleMeterState extends State<DetailsSingleMeter> {
  String _meterName = '';
  String _roomName = '';
  late MeterData _meter;
  late RoomDto? _room;

  int _activeChartWidget = 0;

  late final AddEntry _addEntry;

  List<Tag> _tags = [];
  bool _updateTags = false;

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

  getTags(List<Tag> tags) {
    _tags = tags;
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

  Future _getTagsById(LocalDatabase db) async {
    _tags = await db.tagsDao.getTagsForMeter(_meter.id);
    setState(() {
      _updateTags = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryCardProvider>(context);
    final chartProvider = Provider.of<ChartProvider>(context);
    final db = Provider.of<LocalDatabase>(context);

    bool hasSelectedEntries = entryProvider.getHasSelectedEntries;

    if (_updateTags == true) {
      _getTagsById(db);
    }

    return Scaffold(
      appBar: hasSelectedEntries
          ? _selectedAppBar(entryProvider)
          : _unselectedAppBar(entryProvider),
      body: WillPopScope(
        onWillPop: () async {
          if (hasSelectedEntries) {
            entryProvider.removeAllSelectedEntries();

            return false;
          }

          Navigator.of(context).pop(_room);
          return true;
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Zählernummer
              _meterInformationWidget(),
              const Divider(),
              if (widget.hasTags)
                HorizontalTagsList(
                  meterId: _meter.id,
                  setTags: (tags) => getTags(tags),
                  setHasTags: null,
                ),
              EntryCard(meter: widget.meter),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    height: 340,
                    child: PageView(
                      onPageChanged: (value) {
                        setState(() {
                          _activeChartWidget = value;
                        });
                      },
                      children: [
                        if (!chartProvider.getLineChart)
                          UsageBarChart(
                            meter: _meter,
                          ),
                        if (chartProvider.getLineChart)
                          UsageLineChart(meter: _meter),
                        CountLineChart(
                          meter: _meter,
                        ),
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
      ),
    );
  }

  AppBar _unselectedAppBar(EntryCardProvider entryProvider) {
    return AppBar(
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
          tooltip: 'Eintrag erstellen',
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddScreen(
                    meter: _meter,
                    room: _room,
                    tags: _tags,
                  ),
                )).then((value) {
              if (value == null) {
                return;
              }

              _meter = value[0] as MeterData;
              _room = value[1] as RoomDto?;
              _updateTags = value[2] as bool;

              entryProvider.setMeterUnit(_meter.unit);

              setState(
                () {
                  _meterName = _meter.number;
                  _roomName = _room?.name ?? '';
                },
              );
            });
          },
          icon: const Icon(Icons.edit),
          tooltip: 'Zähler bearbeiten',
        ),
      ],
    );
  }

  AppBar _selectedAppBar(EntryCardProvider entryProvider) {
    return AppBar(
      title: Text('${entryProvider.getSelectedEntriesLength} ausgewählt'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          entryProvider.removeAllSelectedEntries();
        },
      ),
      actions: [
        IconButton(
          onPressed: () {
            entryProvider.deleteAllSelectedEntries(context);
            Provider.of<DatabaseSettingsProvider>(context, listen: false)
                .setHasUpdate(true);
          },
          icon: const Icon(Icons.delete),
          tooltip: 'Einträge löschen',
        ),
      ],
    );
  }
}
