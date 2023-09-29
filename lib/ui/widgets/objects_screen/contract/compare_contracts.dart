import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/local_database.dart';
import '../../../../core/enums/compare_costs_menu.dart';
import '../../../../core/model/compare_costs.dart';
import '../../../../core/model/contract_costs.dart';
import '../../../../core/model/contract_dto.dart';
import '../../../../core/provider/contract_provider.dart';
import '../../../../core/provider/database_settings_provider.dart';
import '../../../../core/provider/details_contract_provider.dart';
import '../../../../core/services/calc_compare_values.dart';
import '../../../../core/services/compare_cost_helper.dart';
import '../../../../utils/meter_typ.dart';

class CompareContracts extends StatefulWidget {
  final ContractDto contract;

  const CompareContracts({super.key, required this.contract});

  @override
  State<CompareContracts> createState() => _CompareContractsState();
}

class _CompareContractsState extends State<CompareContracts> {
  final TextStyle textStyle = const TextStyle(fontSize: 16);
  late final ContractDto contract;

  final String local = Platform.localeName;

  @override
  void initState() {
    contract = widget.contract;
    super.initState();
  }

  _createTableRows({
    required String title,
    required double newValue,
    required double difference,
    double padding = 0,
  }) {
    final formatSimpleCurrency = NumberFormat.simpleCurrency(locale: local);

    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: EdgeInsets.only(bottom: 5, top: padding),
            child: Text(
              title,
              style: textStyle,
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: EdgeInsets.only(bottom: 5, top: padding),
            child: Text(
              formatSimpleCurrency.format(newValue),
              style: textStyle,
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: EdgeInsets.only(bottom: 5, top: padding),
            child: Text(
              formatSimpleCurrency.format(difference),
              style: textStyle,
            ),
          ),
        ),
      ],
    );
  }

  _createTable(
      {required ContractCosts compareValues,
      required CompareCosts compareContract,
      required CalcCompareValues compareValuesHelper}) {
    final costs = compareContract.costs;

    final formatDecimal =
        NumberFormat.decimalPatternDigits(locale: local, decimalDigits: 2);

    return Table(
      columnWidths: const {
        0: FractionColumnWidth(0.4),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
      },
      children: [
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  'Verbrauch',
                  style: textStyle,
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  '${compareContract.usage} ${meterTyps[widget.contract.meterTyp]['einheit']}',
                  style: textStyle,
                ),
              ),
            ),
            const TableCell(
              child: Text(''),
            ),
          ],
        ),
        TableRow(
          children: [
            const TableCell(
              child: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  '',
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'Neue Kosten',
                  style: textStyle,
                ),
              ),
            ),
            TableCell(
              child: Text(
                'Ersparnisse',
                style: textStyle,
              ),
            ),
          ],
        ),
        _createTableRows(
          title: 'Grundpreis',
          difference: compareValues.basicPrice,
          newValue: costs.basicPrice,
        ),
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'Arbeitspreis',
                  style: textStyle,
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '${formatDecimal.format(costs.energyPrice)} Cent',
                  style: textStyle,
                ),
              ),
            ),
            TableCell(
              child: Text(
                '${formatDecimal.format(compareValues.energyPrice)} Cent',
                style: textStyle,
              ),
            ),
          ],
        ),
        _createTableRows(
          title: 'Bonus',
          difference: compareValues.bonus?.toDouble() ?? 0.0,
          newValue: costs.bonus?.toDouble() ?? 0.0,
        ),
        _createTableRows(
            title: 'pro Monat',
            difference: compareValues.total! / 12,
            newValue: compareContract.costs.total! / 12,
            padding: 10),
      ],
    );
  }

  _popupMenu(CompareCosts compareContract, DetailsContractProvider provider) {
    final db = Provider.of<LocalDatabase>(context, listen: false);
    final contractProvider =
        Provider.of<ContractProvider>(context, listen: false);
    final helper = CompareCostHelper();

    return PopupMenuButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      onSelected: (value) async {
        switch (value) {
          case CompareCostsMenu.save:
            helper.saveCompare(
              compare: compareContract,
              db: db,
              provider: provider,
              contractProvider: contractProvider,
            );
            break;
          case CompareCostsMenu.delete:
            helper.deleteCompare(
              compare: compareContract,
              db: db,
              provider: provider,
              contractProvider: contractProvider,
            );
            break;
          case CompareCostsMenu.newContract:
            helper
                .createNewContract(
                    compare: compareContract,
                    db: db,
                    contractProvider: contractProvider,
                    provider: provider,
                    currentContract: widget.contract)
                .then((value) {
              if (value) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    'Neuer Vertrag wurde erstellt!',
                  ),
                ));
              }
            });
            break;
          default:
            'No PopUpMenuButton';
            break;
        }

        Provider.of<DatabaseSettingsProvider>(context, listen: false)
            .setHasUpdate(true);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: CompareCostsMenu.newContract,
          child: Row(
            children: [
              const Icon(
                Icons.add,
                size: 20,
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                'Neuer Vertrag',
                style: textStyle,
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: CompareCostsMenu.save,
          child: Row(
            children: [
              const Icon(
                Icons.push_pin,
                size: 20,
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                'Zwischenspeichern',
                style: textStyle,
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: CompareCostsMenu.delete,
          child: Row(
            children: [
              const Icon(
                Icons.delete,
                size: 20,
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                'Löschen',
                style: textStyle,
              ),
            ],
          ),
        ),
      ],
      icon: const Icon(
        Icons.more_horiz,
        color: Colors.white70,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DetailsContractProvider>(context);

    final CompareCosts? compareContract = provider.getCompareContract;

    final compareValuesHelper = CalcCompareValues(
        compareCost: compareContract!, currentCost: widget.contract);

    final ContractCosts compareValues = compareValuesHelper.compareCosts();

    compareContract.costs.total = compareValuesHelper.getCompareTotal();

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
                    'Kosten Vergleichen',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _popupMenu(compareContract, provider),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              _createTable(
                compareContract: compareContract,
                compareValues: compareValues,
                compareValuesHelper: compareValuesHelper,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
