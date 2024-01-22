import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/helper/chart_helper.dart';
import '../../../../../core/model/entry_monthly_sums.dart';
import '../../../../../core/model/meter_dto.dart';
import '../../../../../core/provider/chart_provider.dart';
import '../../../../../utils/convert_count.dart';
import '../../../../../utils/convert_meter_unit.dart';

class YearBarChart extends StatelessWidget {
  final ChartHelper _helper = ChartHelper();
  final ConvertMeterUnit _convertMeterUnit = ConvertMeterUnit();

  final List<EntryMonthlySums> data;
  final MeterDto meter;

  YearBarChart({super.key, required this.data, required this.meter});

  List<BarChartGroupData> _barGroups(Color color, Map<int, int> data) {
    final List<BarChartGroupData> barGroups = [];

    data.forEach((key, value) {
      barGroups.add(
        BarChartGroupData(
          x: key,
          barRods: [
            BarChartRodData(
              toY: value.toDouble(),
              color: color,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    });

    return barGroups;
  }

  AxisTitles _bottomTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: 0.5,
        getTitlesWidget: (value, meta) {
          return SideTitleWidget(
            axisSide: meta.axisSide,
            child: Text(
              value.toStringAsFixed(0),
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

  BarTouchData _barTouchData(Color color, ChartProvider chartProvider) {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: color,
        fitInsideHorizontally: true,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          String text =
              ' ${ConvertCount.convertCount(rod.toY.toInt())} ${_convertMeterUnit.getUnitString(meter.unit)}';

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

  FlBorderData _borderData(Color color) {
    return FlBorderData(
      show: true,
      border: Border.all(
        color: color,
        width: 0.1,
      ),
    );
  }

  FlGridData _gridData() {
    return const FlGridData(show: false);
  }

  @override
  Widget build(BuildContext context) {
    final chartProvider = Provider.of<ChartProvider>(context);

    Map<int, int> finalData = _helper.splitListInYears(data);

    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 10),
          child: _convertMeterUnit.getUnitWidget(
            count: '',
            unit: meter.unit,
            textStyle: Theme.of(context).textTheme.bodySmall!,
          ),
        ),
        SizedBox(
          height: 200,
          width: 380,
          child: BarChart(
            BarChartData(
              barGroups: _barGroups(primaryColor, finalData),
              titlesData: _titlesData(),
              barTouchData: _barTouchData(primaryColor, chartProvider),
              borderData: _borderData(Theme.of(context).hintColor),
              gridData: _gridData(),
            ),
          ),
        ),
      ],
    );
  }
}
