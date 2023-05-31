import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/model/database_stats_dto.dart';
import '../../../core/provider/database_settings_provider.dart';
import '../../../core/services/database_settings_helper.dart';

class DatabaseStats extends StatefulWidget {
  final DatabaseSettingsHelper databaseSettingsHelper;

  const DatabaseStats({Key? key, required this.databaseSettingsHelper})
      : super(key: key);

  @override
  State<DatabaseStats> createState() => _DatabaseStatsState();
}

class _DatabaseStatsState extends State<DatabaseStats> {
  DatabaseStatsDto? _databaseStatsDto;

  bool _firstInit = true;
  int _itemCounts = 0;
  String _databaseSize = '0 KB';
  List<double> _itemValues = [0.0, 0.0, 0.0, 0.0, 0.0];

  final List<Color> _itemColors = const [
    Color(0xffC26DBC),
    Color(0xff603F8B),
    Color(0xff189AB4),
    Color(0xff025492),
    Color(0xffF67B50),
  ];

  final List<String> _itemNames = const [
    'Zähler',
    'Einträge',
    'Räume',
    'Verträge',
    'Tags'
  ];

  _getDatabaseSize(DatabaseSettingsHelper databaseHelper) async {
    _databaseSize = await databaseHelper.getDatabaseSize();

    if (_firstInit == true) {
      setState(() {});
    }
  }

  _getDatabaseStats(
      LocalDatabase db, DatabaseSettingsHelper databaseHelper) async {
    _databaseStatsDto = await databaseHelper.getDatabaseStats(db);

    if (_firstInit == true) {
      setState(() {
        _firstInit = false;
      });
    }
  }

  _calcItemCounts() {
    _itemCounts = _databaseStatsDto!.sumMeters! +
        _databaseStatsDto!.sumEntries! +
        _databaseStatsDto!.sumTags! +
        _databaseStatsDto!.sumContracts! +
        _databaseStatsDto!.sumRooms!;
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context);
    final provider = Provider.of<DatabaseSettingsProvider>(context);

    DatabaseSettingsHelper databaseHelper = widget.databaseSettingsHelper;

    _getDatabaseSize(databaseHelper);
    _getDatabaseStats(db, databaseHelper);

    return FutureBuilder(
      future: databaseHelper.getDatabaseStats(db),
      builder: (context, snapshot) {
        _databaseStatsDto = snapshot.data;

        if (_databaseStatsDto != null) {
          _calcItemCounts();

          _itemValues = databaseHelper.calcStatsPercent(
              totalSum: _itemCounts, databaseStatsDto: _databaseStatsDto!);

          provider.setItemStatsValues(_itemValues);
          provider.setItemCount(_itemCounts);
        } else {
          _itemValues = provider.getItemStatsValues;
          _itemCounts = provider.getItemStatsCount;
        }

        return Container(
          height: 225,
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Speicherbelegung',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        _databaseSize,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  _chart(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _sections() {
    List<PieChartSectionData> result = [];

    for (int i = 0; i < 5; i++) {
      result.add(
        PieChartSectionData(
          color: _itemColors.elementAt(i),
          value: _itemValues.elementAt(i),
          showTitle: false,
          // title: (_itemValues.elementAt(i) * _itemCounts).toStringAsFixed(0),
        ),
      );
    }

    return result;
  }

  _indicator(String text, Color color) {
    return Row(
      children: [
        Container(
          height: 16,
          width: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(text),
      ],
    );
  }

  _chart() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sections: _sections(),
                sectionsSpace: 0,
                centerSpaceRadius: 15,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _itemColors.length,
            itemBuilder: (context, index) {
              int count = 0;

              if (!_itemValues.elementAt(index).isInfinite) {
                count = (_itemCounts * _itemValues.elementAt(index)).toInt();
              }

              return Column(
                children: [
                  _indicator(
                    '${_itemNames.elementAt(index)} ($count)',
                    _itemColors.elementAt(index),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
