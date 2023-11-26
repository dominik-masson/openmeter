import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/enums/font_size_value.dart';
import '../../../core/model/database_stats_dto.dart';
import '../../../core/provider/database_settings_provider.dart';
import '../../../core/provider/theme_changer.dart';
import '../../../core/services/database_settings_helper.dart';

class DatabaseStats extends StatefulWidget {
  final DatabaseSettingsHelper databaseSettingsHelper;

  const DatabaseStats({super.key, required this.databaseSettingsHelper});

  @override
  State<DatabaseStats> createState() => _DatabaseStatsState();
}

class _DatabaseStatsState extends State<DatabaseStats> {
  DatabaseStatsDto? _databaseStatsDto;

  bool _firstInit = true;
  int _itemCounts = 0;
  String _fullSize = '0 KB';
  String _dbSize = '0 KB';
  String _imageSize = '0 KB';
  List<double> _itemValues = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  bool _isLargeText = false;

  final List<Color> _itemColors = const [
    Color(0xffC26DBC),
    Color(0xff603F8B),
    Color(0xff189AB4),
    Color(0xff025492),
    Color(0xffF67B50),
    Color(0xffF4B183),
  ];

  final List<String> _itemNames = const [
    'Zähler',
    'Einträge',
    'Räume',
    'Verträge',
    'Tags',
    'Bilder'
  ];

  _getDatabaseSize(DatabaseSettingsHelper databaseHelper,
      DatabaseSettingsProvider provider) async {
    String fullSize = await databaseHelper.getFullSize();
    String dbSize = await databaseHelper.getDatabaseSize();
    String imageSize = await databaseHelper.getImagesSize();

    if (fullSize != _fullSize || _dbSize != dbSize || _imageSize != imageSize) {
      provider.saveDatabaseStats(
          dbSize: dbSize, imageSize: imageSize, fullSize: fullSize);
    }

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
    _itemCounts = _databaseStatsDto!.sumMeters +
        _databaseStatsDto!.sumEntries +
        _databaseStatsDto!.sumTags +
        _databaseStatsDto!.sumContracts +
        _databaseStatsDto!.sumRooms +
        _databaseStatsDto!.sumImages;
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context);
    final provider = Provider.of<DatabaseSettingsProvider>(context);

    DatabaseSettingsHelper databaseHelper = widget.databaseSettingsHelper;

    final themeProvider = Provider.of<ThemeChanger>(context);

    _isLargeText =
        themeProvider.getFontSizeValue == FontSizeValue.large ? true : false;

    _imageSize = provider.imageSize;
    _dbSize = provider.databaseSize;
    _fullSize = provider.statsSize;

    _getDatabaseSize(databaseHelper, provider);
    _getDatabaseStats(db, databaseHelper);

    return FutureBuilder(
      future: databaseHelper.getDatabaseStats(db),
      builder: (context, snapshot) {
        _databaseStatsDto = snapshot.data;

        if (_databaseStatsDto != null && provider.getStateHasReset == false) {
          _calcItemCounts();

          _itemValues = databaseHelper.calcStatsPercent(
              totalSum: _itemCounts, databaseStatsDto: _databaseStatsDto!);

          provider.setItemStatsValues(_itemValues);
          provider.setItemCount(_itemCounts);
        } else {
          if (provider.getStateHasReset) {
            _databaseStatsDto = null;
            provider.setStateHasReset(false);
          }

          _itemValues = provider.getItemStatsValues;
          _itemCounts = provider.getItemStatsCount;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Speicherbelegung',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      _memoryUsage(),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
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

  _memoryUsage() {
    return Column(
      children: [
        Text(
          _fullSize,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(
          height: 2,
        ),
        Row(
          children: [
            Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.database,
                  size: 12,
                ),
                const SizedBox(
                  width: 3,
                ),
                Text(
                  _dbSize,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(
              width: 15,
            ),
            Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.image,
                  size: 12,
                ),
                const SizedBox(
                  width: 3,
                ),
                Text(
                  _imageSize,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  List<PieChartSectionData> _sections() {
    List<PieChartSectionData> result = [];

    if (_itemValues.isEmpty) {
      return result;
    }

    for (int i = 0; i < 6; i++) {
      if (_itemValues.elementAt(i).isNaN) {
        result.add(
          PieChartSectionData(
            color: Colors.grey.withOpacity(0.3),
            value: 100,
            showTitle: false,
          ),
        );
        break;
      } else {
        result.add(
          PieChartSectionData(
            color: _itemColors.elementAt(i),
            value: _itemValues.elementAt(i),
            showTitle: false,
          ),
        );
      }
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
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
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
                centerSpaceRadius: 25,
              ),
            ),
          ),
        ),
        Expanded(
          flex: _isLargeText ? 2 : 1,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _itemColors.length,
            itemBuilder: (context, index) {
              int count = 0;

              if (_itemValues.isEmpty) {
                return Container();
              }

              if (!_itemValues.elementAt(index).isInfinite &&
                  !_itemValues.elementAt(index).isNaN) {
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
