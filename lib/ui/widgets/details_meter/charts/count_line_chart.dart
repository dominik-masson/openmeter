import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/local_database.dart';
import '../../../../core/model/entry_dto.dart';
import '../../../../core/model/entry_monthly_sums.dart';
import '../../../../core/model/meter_dto.dart';
import '../../../../core/helper/chart_helper.dart';
import '../../../../core/provider/chart_provider.dart';
import '../../../../core/provider/entry_filter_provider.dart';
import '../../../../utils/convert_count.dart';
import '../../../../utils/convert_meter_unit.dart';
import 'no_entry.dart';

class CountLineChart extends StatefulWidget {
  final MeterDto meter;

  const CountLineChart({super.key, required this.meter});

  @override
  State<CountLineChart> createState() => _CountLineChartState();
}

class _CountLineChartState extends State<CountLineChart> {
  bool _twelveMonths = true;
  final ChartHelper _helper = ChartHelper();
  final ConvertMeterUnit _convertMeterUnit = ConvertMeterUnit();

  List<LineChartBarData> _lineData(List<EntryMonthlySums> entries) {
    List<FlSpot> spots = entries.map((e) {
      final date = DateTime(e.year, e.month, e.day ?? 1);

      return FlSpot(
        date.millisecondsSinceEpoch.toDouble(),
        e.count?.toDouble() ?? 0,
      );
    }).toList();

    return [
      LineChartBarData(
        spots: spots,
        isCurved: true,
        color: Theme.of(context).primaryColor,
        barWidth: 4,
        shadow: const Shadow(
          blurRadius: 0.2,
        ),
        belowBarData: BarAreaData(
          show: true,
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
    ];
  }

  AxisTitles _bottomTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          final DateTime date =
              DateTime.fromMillisecondsSinceEpoch(value.toInt());

          if (value == meta.min && !_twelveMonths ||
              value == meta.max ||
              value == meta.min) {
            return Container();
          }

          return Padding(
            padding: const EdgeInsets.only(top: 8, right: 8.0),
            child: Text(
              DateFormat('MM.yy').format(date).toString(),
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
          if (value == meta.max || value == meta.min) {
            return Container();
          }

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
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: _bottomTitles(),
      leftTitles: _leftTitles(),
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

  LineTouchData _touchData() {
    final chartProvider = Provider.of<ChartProvider>(context);

    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Theme.of(context).primaryColor,
        fitInsideHorizontally: true,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((e) {
            final DateTime date =
                DateTime.fromMillisecondsSinceEpoch(e.x.toInt());
            final String dateFormat = DateFormat('dd.MM.yyyy').format(date);

            return LineTooltipItem(
              '$dateFormat \n ${ConvertCount.convertCount(e.y.toInt())}  ${_convertMeterUnit.getUnitString(widget.meter.unit)}',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList();
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

  _mainChart(List<EntryMonthlySums> entries) {
    return SizedBox(
      height: 200,
      width: 380,
      child: LineChart(
        LineChartData(
          lineBarsData: _lineData(entries),
          titlesData: _titlesData(),
          borderData: _borderData(),
          gridData: _gridData(),
          lineTouchData: _touchData(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context);
    final entryProvider = Provider.of<EntryFilterProvider>(context);

    bool isEmpty = false;
    bool hasActiveFilters = entryProvider.hasChartFilter;

    return StreamBuilder(
      stream: db.entryDao.watchAllEntries(widget.meter.id!),
      builder: (context, snapshot) {
        List<Entrie> data = snapshot.data ?? [];
        List<EntryDto> entries = data.map((e) => EntryDto.fromData(e)).toList();

        List<EntryMonthlySums> finalEntries = [];

        if (entries.isEmpty) {
          return Container();
        }

        if (hasActiveFilters) {
          entries = entryProvider.getFilteredEntriesForChart(entries);
        }

        if (_twelveMonths && entries.length > 12) {
          finalEntries = _helper.getLastMonths(entries);
        } else {
          finalEntries = _helper.convertEntryList(entries);
        }

        if (finalEntries.isEmpty || finalEntries.length == 1) {
          isEmpty = true;
        }

        return SizedBox(
          height: 300,
          width: 400,
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Zählerstand',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      TextButton(
                        onPressed: () {
                          if (finalEntries.length >= 12) {
                            setState(() {
                              _twelveMonths = !_twelveMonths;
                            });
                          }
                        },
                        child: Text(
                          'letzte 12 Monate',
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: _twelveMonths
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (isEmpty)
                  NoEntry().getNoData(
                      'Es sind keine oder zu wenige Einträge vorhanden'),
                if (!isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 5),
                    child: _convertMeterUnit.getUnitWidget(
                      count: '',
                      unit: widget.meter.unit,
                      textStyle: Theme.of(context).textTheme.bodySmall!,
                    ),
                  ),
                if (!isEmpty) _mainChart(finalEntries),
              ],
            ),
          ),
        );
      },
    );
  }
}
