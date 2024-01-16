import 'dart:io';

import 'package:flutter/material.dart';
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
import '../../../../core/helper/calc_compare_values.dart';
import '../../../../core/helper/compare_cost_helper.dart';
import '../../../../utils/convert_meter_unit.dart';
import 'add_costs.dart';

class CompareContracts extends StatefulWidget {
  const CompareContracts({super.key});

  @override
  State<CompareContracts> createState() => _CompareContractsState();
}

class _CompareContractsState extends State<CompareContracts> {
  late ContractDto contract;

  final String local = Platform.localeName;

  final ConvertMeterUnit _convertMeterUnit = ConvertMeterUnit();

  String _unit = '';

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
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: EdgeInsets.only(bottom: 5, top: padding),
            child: Text(
              formatSimpleCurrency.format(newValue),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: EdgeInsets.only(bottom: 5, top: padding),
            child: Text(
              formatSimpleCurrency.format(difference),
              style: Theme.of(context).textTheme.bodyMedium,
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
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  '${compareContract.usage} ${_convertMeterUnit.getUnitString(_unit)}',
                  style: Theme.of(context).textTheme.bodyMedium,
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
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            TableCell(
              child: Text(
                'Ersparnisse',
                style: Theme.of(context).textTheme.bodyMedium,
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
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '${formatDecimal.format(costs.energyPrice)} Cent',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            TableCell(
              child: Text(
                '${formatDecimal.format(compareValues.energyPrice)} Cent',
                style: Theme.of(context).textTheme.bodyMedium,
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
                    'Vergleichsdaten bearbeiten',
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

  _popupMenu(CompareCosts compareContract, DetailsContractProvider provider,
      BuildContext context) {
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
              isArchived: contract.isArchived,
            );
            break;
          case CompareCostsMenu.delete:
            helper.deleteCompare(
              compare: compareContract,
              db: db,
              provider: provider,
              contractProvider: contractProvider,
              isArchived: contract.isArchived,
            );
            break;
          case CompareCostsMenu.newContract:
            helper
                .createNewContract(
                    compare: compareContract,
                    db: db,
                    contractProvider: contractProvider,
                    provider: provider,
                    currentContract: contract)
                .then((value) {
              if (value) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    'Neuer Vertrag wurde erstellt!',
                  ),
                  behavior: SnackBarBehavior.floating,
                ));
              }
            });
            break;
          case CompareCostsMenu.edit:
            _openBottomSheet(context);
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
                style: Theme.of(context).textTheme.bodyMedium,
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
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: CompareCostsMenu.edit,
          child: Row(
            children: [
              const Icon(
                Icons.edit,
                size: 20,
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                'Bearbeiten',
                style: Theme.of(context).textTheme.bodyMedium,
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
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
      icon: Icon(
        Icons.more_horiz,
        color: Theme.of(context).iconTheme.color!.withAlpha(175),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DetailsContractProvider>(context);

    CompareCosts? compareContract = provider.getCompareContract;

    contract = provider.getCurrentContract;

    if (!identical(compareContract, contract.compareCosts) &&
        contract.compareCosts != null) {
      compareContract = contract.compareCosts;
      provider.setCompareContract(compareContract, false);
    }

    _unit = provider.getUnit;

    if (_unit.isEmpty) {
      _unit = contract.unit;
    }

    final compareValuesHelper =
        CalcCompareValues(compareCost: compareContract!, currentCost: contract);

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
                  Text(
                    'Kosten Vergleichen',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  _popupMenu(compareContract, provider, context),
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
