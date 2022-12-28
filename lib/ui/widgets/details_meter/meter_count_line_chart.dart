import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';

class LineChartSingleMeter extends StatefulWidget {
  final int meterId;

  const LineChartSingleMeter({Key? key, required this.meterId})
      : super(key: key);

  @override
  State<LineChartSingleMeter> createState() => _LineChartSingleMeterState();
}

class _LineChartSingleMeterState extends State<LineChartSingleMeter> {
  double _minX = 1;
  double _maxX = 1;
  double _minY = 1;
  double _maxY = 1;
  List<FlSpot> _spots = [];
  bool _twelveMonths = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<LocalDatabase>(context)
          .meterDao
          .watchAllEntries(widget.meterId),
      builder: (context, snapshot) {
        final data = snapshot.data ?? [];

        _spots = data.map((e) {
          return FlSpot(
            e.date.millisecondsSinceEpoch.toDouble(),
            e.count.toDouble(),
          );
        }).toList();

        if (_spots.length > 12 && _twelveMonths) {
          _spots = _spots.getRange(_spots.length - 12, _spots.length).toList();
        }

        if (_spots.isNotEmpty) {
          _minX = _spots.first.x;
          _maxX = _spots.last.x;
          _minY = _spots.first.y;
          _maxY = _spots.last.y;
        }
        if (_spots.length >= 2) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    child: TextButton(
                      onPressed: () {
                        if (_spots.length >= 12) {
                          setState(() {
                            _twelveMonths = !_twelveMonths;
                          });
                        }
                      },
                      child: Text(
                        'letzte 12 Monate',
                        style: TextStyle(
                          fontSize: 14,
                          color: _twelveMonths
                              ? Theme.of(context).primaryColorLight
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  _mainChart(context),
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _mainChart(BuildContext context) {
    final lineBarsData = [
      LineChartBarData(
        spots: _spots,
        isCurved: true,
        color: Theme.of(context).primaryColorLight,
        barWidth: 4,
        shadow: const Shadow(
          blurRadius: 0.2,
        ),
        belowBarData: BarAreaData(
          show: true,
          color: Theme.of(context).primaryColorLight.withOpacity(0.2),
        ),
      ),
    ];

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              bottom: 12,
            ),
            child: LineChart(
              swapAnimationDuration: const Duration(milliseconds: 150),
              swapAnimationCurve: Curves.linear,
              LineChartData(
                lineTouchData: _lineTouchData(context),
                // maxX: _spots.length < 12 ? _spots.length.toDouble() : 12,
                minY: _minY,
                maxY: _maxY,
                minX: _minX,
                maxX: _maxX,
                lineBarsData: lineBarsData,
                gridData: FlGridData(
                  show: false,
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    width: 0.8,
                    color: const Color(0xff37434d),
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  // topTitles: _leftTitle(),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  bottomTitles: _bottomTitle(),
                  leftTitles: _leftTitle(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  AxisTitles _leftTitle() {
    return AxisTitles(
      sideTitles: SideTitles(
          showTitles: true,
          interval: (_maxY - _minY) <= 0.0
              ? 12
              : (_maxY - _minY).ceilToDouble() / 2.345,
          reservedSize: 50,
          getTitlesWidget: (value, meta) {
            Widget text = Text(value.toStringAsFixed(0));
            return SideTitleWidget(
              axisSide: meta.axisSide,
              child: text,
            );
          }),
    );
  }

  AxisTitles _bottomTitle() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        interval: (90 * Duration.millisecondsPerDay).toDouble(),
        getTitlesWidget: (value, meta) {
          final DateTime date =
              DateTime.fromMillisecondsSinceEpoch(value.toInt());

          if (value == meta.min && !_twelveMonths) {
            return Container();
          }

          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              DateFormat('MM.yy').format(date).toString(),
              style: const TextStyle(
                  // fontSize: 12,
                  ),
            ),
          );
        },
      ),
    );
  }

  LineTouchData _lineTouchData(BuildContext context) {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Theme.of(context).primaryColor,
        getTooltipItems: (value) {
          return value.map(
            (e) {
              final DateTime date =
                  DateTime.fromMillisecondsSinceEpoch(e.x.toInt());
              final String dateFormat = DateFormat('dd.MM.yyyy').format(date);

              return LineTooltipItem(
                '$dateFormat \n ${e.y.toInt()}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ).toList();
        },
      ),
    );
  }
}
