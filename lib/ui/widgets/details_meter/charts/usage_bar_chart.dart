import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/local_database.dart';
import '../../../../core/model/entry_dto.dart';
import '../../../../core/model/entry_monthly_sums.dart';
import '../../../../core/model/meter_dto.dart';
import '../../../../core/provider/chart_provider.dart';
import '../../../../core/helper/chart_helper.dart';
import '../../../../core/provider/entry_filter_provider.dart';
import '../../../../utils/convert_count.dart';
import '../../../../utils/convert_meter_unit.dart';
import 'no_entry.dart';

class UsageBarChart extends StatefulWidget {
  final MeterDto meter;

  const UsageBarChart({super.key, required this.meter});

  @override
  State<UsageBarChart> createState() => _UsageBarChartState();
}

class _UsageBarChartState extends State<UsageBarChart> {
  final NoEntry _noData = NoEntry();
  bool _showOnlyLastTwelveMonths = true;

  final ChartHelper _helper = ChartHelper();
  final ConvertMeterUnit _convertMeterUnit = ConvertMeterUnit();

  AxisTitles _bottomTitles() {
    int handleBottomTiles = 0;

    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          handleBottomTiles++;
          if (handleBottomTiles % 3 != 0 && !_showOnlyLastTwelveMonths) {
            return Container();
          }

          DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
          String title = _helper.getTitleMonths(date.month);
          return SideTitleWidget(
            axisSide: meta.axisSide,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }

  AxisTitles _leftTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 50,
        getTitlesWidget: (value, meta) {
          // if(value == meta.max){
          //   return Container();
          // }

          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              meta.formattedValue,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }

  FlTitlesData _titlesData() {
    return FlTitlesData(
      show: true,
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: _bottomTitles(),
      leftTitles: _leftTitles(),
    );
  }

  List<BarChartGroupData> _barData(List<EntryMonthlySums> data) {
    List<BarChartGroupData> barData = [];

    for (EntryMonthlySums entry in data) {
      DateTime date = DateTime(entry.year, entry.month);
      final key = date.millisecondsSinceEpoch;

      barData.add(
        BarChartGroupData(
          x: key,
          barRods: [
            BarChartRodData(
              toY: entry.usage.toDouble(),
              color: Theme.of(context).primaryColor,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }
    return barData;
  }

  BarTouchData _barTouchData() {
    final chartProvider = Provider.of<ChartProvider>(context);

    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Theme.of(context).primaryColor,
        fitInsideHorizontally: true,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          DateTime date = DateTime.fromMillisecondsSinceEpoch(group.x.toInt());

          String formatDate = DateFormat('MM.yyyy').format(date);

          String text =
              '$formatDate \n  ${ConvertCount.convertCount(rod.toY.toInt())} ${_convertMeterUnit.getUnitString(widget.meter.unit)}';

          return BarTooltipItem(
            text,
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          );
        },
      ),
      touchCallback: (event, touchResponse) {
        if (event is FlLongPressStart ||
            event is FlTapDownEvent ||
            event is FlPanStartEvent) {
          chartProvider.setFocusDiagram(true);
        }
        if (event is FlLongPressEnd ||
            event is FlTapUpEvent ||
            event is FlPanEndEvent) {
          chartProvider.setFocusDiagram(false);
        }
      },
    );
  }

  FlBorderData _borderData() {
    return FlBorderData(
      show: true,
      border: Border.all(
        color: Theme.of(context).hintColor,
        width: 0.1,
      ),
    );
  }

  FlGridData _gridData() {
    return const FlGridData(show: false);
  }

  Widget _monthlyChart(List<EntryMonthlySums> data) {
    return SizedBox(
      height: 200,
      width: 380,
      child: BarChart(
        BarChartData(
          barGroups: _barData(data),
          titlesData: _titlesData(),
          barTouchData: _barTouchData(),
          borderData: _borderData(),
          gridData: _gridData(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context);
    final chartProvider = Provider.of<ChartProvider>(context);
    final entryFilterProvider = Provider.of<EntryFilterProvider>(context);

    bool isEmpty = false;
    bool hasActiveFilters = entryFilterProvider.hasChartFilter;

    final textTheme = Theme.of(context).textTheme.bodySmall!;

    return StreamBuilder(
      stream: db.entryDao.watchAllEntries(widget.meter.id!),
      builder: (context, snapshot) {
        List<Entrie> data = snapshot.data ?? [];
        List<EntryDto> entries = data.map((e) => EntryDto.fromData(e)).toList();

        List<EntryMonthlySums> sumMonths = [];

        if (entries.isEmpty) {
          return Container();
        }

        if (hasActiveFilters) {
          entries = entryFilterProvider.getFilteredEntriesForChart(entries);
        }

        if (_showOnlyLastTwelveMonths) {
          sumMonths = _helper.getLastMonths(entries);
        } else {
          final cache = _helper.getSumInMonths(entries);
          sumMonths = cache.skip(cache.length - 24).toList();
        }

        if (sumMonths.isEmpty) {
          isEmpty = true;
        } else {
          chartProvider.calcAverageCountUsage(
              entries: sumMonths,
              length: !_showOnlyLastTwelveMonths ? entries.length : 12);
        }

        return SizedBox(
          height: 300,
          width: 400,
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 4,
                        right: 8,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Verbrauch',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.functions,
                                size: textTheme.fontSize! + 2,
                                color: textTheme.color!,
                              ),
                              Text(
                                '${chartProvider.averageUsage.toStringAsFixed(2)} ${_convertMeterUnit.getUnitString(widget.meter.unit)}',
                                style: textTheme,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        chartProvider.setLineChart(true);
                      },
                      icon: Icon(Icons.stacked_line_chart,
                          color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                if (!isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 10),
                    child: _convertMeterUnit.getUnitWidget(
                      count: '',
                      unit: widget.meter.unit,
                      textStyle: Theme.of(context).textTheme.bodySmall!,
                    ),
                  ),
                if (!isEmpty) _monthlyChart(sumMonths),
                if (isEmpty)
                  _noData.getNoData(
                      'Es sind keine oder zu wenige Einträge vorhanden'),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FilterChip(
                    label: const Text('letzte 12 Monate'),
                    selected: _showOnlyLastTwelveMonths,
                    showCheckmark: false,
                    labelStyle: textTheme,
                    onSelected: (value) {
                      if (entries.length > 12) {
                        setState(() {
                          _showOnlyLastTwelveMonths = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
