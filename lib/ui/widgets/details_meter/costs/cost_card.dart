import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/model/contract_dto.dart';
import '../../../../core/provider/cost_provider.dart';
import '../../../../utils/convert_meter_unit.dart';
import '../../../../utils/custom_icons.dart';

class CostCard extends StatefulWidget {
  final ContractDto contract;

  const CostCard({super.key, required this.contract});

  @override
  State<CostCard> createState() => _CostCardState();
}

class _CostCardState extends State<CostCard> {
  late NumberFormat _costFormat;
  late CostProvider _costProvider;

  late TextStyle _labelStyle;
  late TextStyle _bodyStyle;

  DateTime? _costFrom;
  DateTime? _costUntil;

  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  _tableTotalCosts() {
    return Column(
      children: [
        Text(
          'Verbraucht',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Table(
          children: [
            TableRow(
              children: [
                Column(
                  children: [
                    Text(
                      _costFormat.format(_costProvider.getTotalCosts),
                      overflow: TextOverflow.ellipsis,
                      style: _bodyStyle,
                    ),
                    Text(
                      "Gesamt",
                      style: _labelStyle,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      _costFormat.format(_costProvider.getAverageMonth),
                      overflow: TextOverflow.ellipsis,
                      style: _bodyStyle,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CustomIcons.empty_set,
                          size: _labelStyle.fontSize!,
                          color: _labelStyle.color!,
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        Text(
                          "Monat",
                          style: _labelStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  _tablePredictedTotalCosts() {
    return Column(
      children: [
        Text(
          'Geschätzter Verbrauch',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Table(
          children: [
            TableRow(children: [
              Column(
                children: [
                  ConvertMeterUnit().getUnitWidget(
                    count: _costProvider.getAverageUsage.toString(),
                    unit: _costProvider.getMeterUnit,
                    textStyle: Theme.of(context).textTheme.bodyMedium!,
                  ),
                  Text(
                    "Gesamt Verbrauch",
                    style: _labelStyle,
                  ),
                ],
              ),
              Container(),
            ]),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: [
                      Text(
                        _costFormat.format(_costProvider.getTotalCosts),
                        overflow: TextOverflow.ellipsis,
                        style: _bodyStyle,
                      ),
                      Text(
                        "Gesamt Kosten",
                        style: _labelStyle,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: [
                      Text(
                        _costFormat.format(_costProvider.getAverageMonth),
                        overflow: TextOverflow.ellipsis,
                        style: _bodyStyle,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CustomIcons.empty_set,
                            size: _labelStyle.fontSize!,
                            color: _labelStyle.color!,
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Monat",
                            style: _labelStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  _tableTotalPaid() {
    double diff = _costProvider.getDifference;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            'Rechnung',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Table(
            children: [
              TableRow(
                children: [
                  const Column(children: [
                    Text(
                      'Bezahlter Abschlag',
                    ),
                  ]),
                  Column(children: [
                    Text(
                      _costFormat.format(_costProvider.getTotalPaid),
                    ),
                    Text(
                      '${_costFormat.format(widget.contract.costs.discount)} x ${_costProvider.getSumOfMonths} Monate',
                      style: _labelStyle,
                    ),
                  ]),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: [
                        Text(
                          diff.isNegative
                              ? 'mögliche Nachzahlung'
                              : 'mögliche Erstattung',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: [
                        Text(
                          _costFormat.format(diff.abs()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  _tableSelectedTimeRange() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            'Zeitraum',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Table(
            children: [
              TableRow(
                children: [
                  Column(children: [
                    Text(
                      _dateFormat.format(_costFrom!),
                    ),
                    Text(
                      'Von',
                      style: _labelStyle,
                    ),
                  ]),
                  Column(children: [
                    Text(
                      _dateFormat.format(_costUntil!),
                    ),
                    Text(
                      'Bis',
                      style: _labelStyle,
                    ),
                  ]),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _costProvider = Provider.of<CostProvider>(context);

    final String local = Platform.localeName;
    _costFormat = NumberFormat.simpleCurrency(locale: local);

    _costFrom = _costProvider.getCostFrom;
    _costUntil = _costProvider.getCostUntil;

    _costProvider.initialCalc();

    _labelStyle = Theme.of(context).textTheme.labelSmall!;
    _bodyStyle = Theme.of(context).textTheme.bodyMedium!;

    bool isPredicted = _costProvider.getStateIsPredicted;

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (_costFrom != null && _costUntil != null)
                _tableSelectedTimeRange(),
              isPredicted ? _tablePredictedTotalCosts() : _tableTotalCosts(),
              const SizedBox(
                height: 15,
              ),
              _tableTotalPaid(),
            ],
          ),
        ),
      ),
    );
  }
}
