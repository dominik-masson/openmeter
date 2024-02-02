import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openmeter/utils/custom_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/model/contract_dto.dart';
import '../../../../core/provider/cost_provider.dart';

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
                  ]),
                ],
              ),
              TableRow(
                children: [
                  Column(
                    children: [
                      Text(
                        diff.isNegative ? 'Nachzahlung' : 'Erstattet',
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        _costFormat.format(diff.abs()),
                      ),
                    ],
                  ),
                ],
              ),
            ],
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

    _costProvider.initialCalc();

    _labelStyle = Theme.of(context).textTheme.labelSmall!;
    _bodyStyle = Theme.of(context).textTheme.bodyMedium!;

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _tableTotalCosts(),
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
