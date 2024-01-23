import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/database/local_database.dart';
import '../../../../../core/model/entry_dto.dart';
import '../../../../../core/model/entry_monthly_sums.dart';
import '../../../../../core/model/meter_dto.dart';
import '../../../../../core/provider/chart_provider.dart';
import '../../../../../core/helper/chart_helper.dart';
import '../../../../../core/provider/entry_filter_provider.dart';
import '../../../../../utils/convert_meter_unit.dart';
import '../no_entry.dart';
import 'simple_bar.dart';
import 'year_bar.dart';

class UsageBarCard extends StatefulWidget {
  final MeterDto meter;

  const UsageBarCard({super.key, required this.meter});

  @override
  State<UsageBarCard> createState() => _UsageBarCardState();
}

class _UsageBarCardState extends State<UsageBarCard> {
  final ChartHelper _helper = ChartHelper();
  final ConvertMeterUnit _convertMeterUnit = ConvertMeterUnit();

  bool _showOnlyLastTwelveMonths = true;
  bool _compareYears = false;

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

        final totalSumMonths = _helper.getSumInMonths(entries);

        if (entries.isEmpty) {
          return Container();
        }

        if (hasActiveFilters) {
          entries = entryFilterProvider.getFilteredEntriesForChart(entries);
          _compareYears = false;
        }

        if (_showOnlyLastTwelveMonths) {
          sumMonths = _helper.getLastMonths(entries);
        } else {
          sumMonths = totalSumMonths;
        }

        if (sumMonths.isEmpty) {
          isEmpty = true;
        } else {
          final totalMonths = _compareYears ? totalSumMonths : sumMonths;

          final totalEntries = _compareYears
              ? entries.length
              : (!_showOnlyLastTwelveMonths ? entries.length : 12);

          chartProvider.calcAverageCountUsage(
              entries: totalMonths, length: totalEntries);
        }

        return SizedBox(
          height: 200,
          width: 400,
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headline(chartProvider: chartProvider, textTheme: textTheme),
                const SizedBox(
                  height: 15,
                ),
                if (!isEmpty && !_compareYears)
                  SimpleUsageBarChart(
                      data: sumMonths,
                      meter: widget.meter,
                      showTwelveMonths: _showOnlyLastTwelveMonths),
                if (!isEmpty && _compareYears)
                  YearBarChart(
                      data: _helper.getSumInMonths(entries),
                      meter: widget.meter),
                if (isEmpty)
                  const NoEntry(
                      text: 'Es sind keine oder zu wenige Einträge vorhanden'),
                const SizedBox(
                  height: 20,
                ),
                _filterActions(
                    textTheme: textTheme,
                    entriesLength: entries.length,
                    hasFilters: hasActiveFilters),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _headline(
      {required ChartProvider chartProvider, required TextStyle textTheme}) {
    return Row(
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
    );
  }

  Widget _filterActions(
      {required TextStyle textTheme,
      required int entriesLength,
      bool hasFilters = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        children: [
          FilterChip(
            label: const Text('12 Monate'),
            selected: _showOnlyLastTwelveMonths,
            showCheckmark: false,
            labelStyle: textTheme,
            onSelected: (value) {
              if (entriesLength > 12 && !_compareYears) {
                setState(() {
                  _showOnlyLastTwelveMonths = value;
                });
              }
            },
          ),
          const SizedBox(
            width: 8,
          ),
          FilterChip(
            label: const Text('Jahresvergleich'),
            selected: _compareYears,
            showCheckmark: false,
            labelStyle: textTheme,
            onSelected: (value) {
              if (entriesLength > 12 && !hasFilters) {
                setState(() {
                  _compareYears = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
