import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/local_database.dart';
import '../../../../core/model/entry_monthly_sums.dart';
import '../../../../core/model/meter_dto.dart';
import '../../../../core/provider/chart_provider.dart';
import '../../../../core/helper/chart_helper.dart';
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
  bool _twelveMonths = true;

  final ChartHelper _helper = ChartHelper();
  final ConvertMeterUnit _convertMeterUnit = ConvertMeterUnit();

  AxisTitles _bottomTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
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

    bool isEmpty = false;

    return StreamBuilder(
      stream: db.entryDao.watchAllEntries(widget.meter.id!),
      builder: (context, snapshot) {
        final List<Entrie>? entries = snapshot.data;
        List<EntryMonthlySums> sumMonths = [];
        List<Entrie> finalEntries = [];

        if (entries == null || entries.isEmpty) {
          return Container();
        }

        if (_twelveMonths && entries.length > 12) {
          // List<Entrie> newEntries = _helper.getLastMonths(entries);
          finalEntries =
              entries.getRange(entries.length - 12, entries.length).toList();
        } else {
          finalEntries = entries;
        }

        if (finalEntries.isEmpty || finalEntries.length == 1) {
          isEmpty = true;
        } else {
          sumMonths = _helper.getSumInMonths(finalEntries);
        }

        return SizedBox(
          height: 280,
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
                      const Text(
                        'Verbrauch',
                        style: TextStyle(fontSize: 16),
                      ),
                      Row(
                        children: [
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: _twelveMonths
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                  ),
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
                    ],
                  ),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
