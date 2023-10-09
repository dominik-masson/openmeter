import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/model/contract_dto.dart';
import '../../../../utils/convert_meter_unit.dart';
import 'add_costs.dart';

class CostCard extends StatelessWidget {
  final ContractDto contract;
  final String local = Platform.localeName;
  final ConvertMeterUnit _convertMeterUnit = ConvertMeterUnit();

  CostCard({super.key, required this.contract});

  _openBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(10),
            height: 500,
            width: double.infinity,
            child: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Vergleichsdaten erstellen',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  AddCosts(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatSimpleCurrency = NumberFormat.simpleCurrency(locale: local);

    final formatDecimal =
        NumberFormat.decimalPatternDigits(locale: local, decimalDigits: 2);

    const TextStyle textStyle = TextStyle(fontSize: 16);

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kostenübersicht',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _openBottomSheet(context),
                    icon: const Icon(
                      Icons.compare_arrows,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Table(
                children: [
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Grundpreis',
                          style: textStyle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          formatSimpleCurrency
                              .format(contract.costs.basicPrice),
                          style: textStyle,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Arbeitspreis',
                          style: textStyle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          '${formatDecimal.format(contract.costs.energyPrice)} Cent/${_convertMeterUnit.getUnitString(contract.unit)}',
                          style: textStyle,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Abschlag',
                          style: textStyle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          formatSimpleCurrency.format(contract.costs.discount),
                          style: textStyle,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Bonus',
                          style: textStyle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          formatSimpleCurrency.format(contract.costs.bonus),
                          style: textStyle,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Notiz',
                          style: textStyle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          contract.note ?? '',
                          style: textStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
