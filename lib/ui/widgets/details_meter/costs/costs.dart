import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/local_database.dart';
import '../../../../core/model/contract_dto.dart';
import '../../../../core/model/meter_dto.dart';
import '../../../../core/provider/cost_provider.dart';
import 'cost_card.dart';
import 'select_contract_card.dart';
import 'select_contract_dialog.dart';

enum CostOverviewOperator { changeContract, selectTimeSpan, removeTimeSpan }

class MainViewCosts extends StatefulWidget {
  final MeterDto meter;

  const MainViewCosts({super.key, required this.meter});

  @override
  State<MainViewCosts> createState() => _MainViewCostsState();
}

class _MainViewCostsState extends State<MainViewCosts> {
  late LocalDatabase db;
  late CostProvider _costProvider;

  int? _selectedContractId;
  DateTime? _costFrom;
  DateTime? _costUntil;

  @override
  Widget build(BuildContext context) {
    _costProvider = Provider.of<CostProvider>(context);

    db = Provider.of<LocalDatabase>(context);

    _costProvider.setMeterId(widget.meter.id ?? -1);
    _costProvider.setMeterUnit(widget.meter.unit);

    _selectedContractId = _costProvider.getSelectedContractId;
    _costFrom = _costProvider.getCostFrom;
    _costUntil = _costProvider.getCostUntil;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _selectedContractId == null
          ? _allContractFuture(db)
          : _selectedContractFuture(db, _selectedContractId!),
    );
  }

  _contractCard(ContractDto contract) {
    final costs = contract.costs;

    _costProvider.setValues(
        costs.basicPrice, costs.energyPrice, costs.discount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _headline(db),
        const SizedBox(
          height: 5,
        ),
        CostCard(contract: contract),
      ],
    );
  }

  _selectedContractFuture(LocalDatabase db, int selectedContractId) {
    return FutureBuilder(
      future: db.contractDao.getContractById(selectedContractId),
      builder: (context, snapshot) {
        final ContractDto? contract = snapshot.data;

        if (contract == null) {
          return _allContractFuture(db);
        }

        return _contractCard(contract);
      },
    );
  }

  _allContractFuture(LocalDatabase db) {
    return FutureBuilder(
      future: db.contractDao.getContractByTyp(widget.meter.typ),
      builder: (context, snapshot) {
        final List<ContractDto> contracts = snapshot.data ?? [];

        if (contracts.isEmpty) {
          return Container();
        }

        if (contracts.length == 1) {
          final int contractId = contracts.first.id!;
          _costProvider.saveSelectedContract(contractId);

          return _contractCard(contracts.first);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _headline(db),
            const SizedBox(
              height: 5,
            ),
            if (contracts.length > 1) SelectContractCard(contracts: contracts),
          ],
        );
      },
    );
  }

  PopupMenuButton _popupMenuButtons(LocalDatabase db) {
    String timeRangeText = 'Zeitraum wählen';

    if (_costFrom != null && _costUntil != null) {
      timeRangeText = 'Zeitraum ändern';
    }

    return PopupMenuButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      icon: Icon(
        Icons.more_horiz,
        color: Theme.of(context).indicatorColor,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: CostOverviewOperator.changeContract,
          child: Row(
            children: [
              const Icon(
                Icons.swap_horiz,
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                'Vertrag wechseln',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: CostOverviewOperator.selectTimeSpan,
          child: Row(
            children: [
              const Icon(
                Icons.date_range,
                size: 20,
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                timeRangeText,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        if (_costFrom != null && _costUntil != null)
          PopupMenuItem(
            value: CostOverviewOperator.removeTimeSpan,
            child: Row(
              children: [
                const Icon(
                  Icons.event_busy,
                  size: 20,
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  'Zeitraum löschen',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
      ],
      onSelected: (value) async {
        switch (value) {
          case CostOverviewOperator.changeContract:
            await _showSelectContractDialog();
            break;
          case CostOverviewOperator.selectTimeSpan:
            await _showSelectDateRange();
            break;
          case CostOverviewOperator.removeTimeSpan:
            await _costProvider.deleteTimeRange(db);
            await _resetEntries();
            break;
          default:
            log('No CostOverviewOperator found!');
            break;
        }
      },
    );
  }

  _resetEntries() async {
    final entries = await db.entryDao.getAllEntries(_costProvider.getMeterId);

    _costProvider.setEntries(entries.reversed.toList());
    _costProvider.setStateIsPredicted(false);

    setState(() {});
  }

  _showSelectDateRange() async {
    final today = DateTime.now();

    DateTimeRange? initialRange;
    if (_costFrom != null && _costUntil != null) {
      initialRange = DateTimeRange(start: _costFrom!, end: _costUntil!);
    }

    final DateTimeRange? result = await showDateRangePicker(
        context: context,
        firstDate: DateTime(today.year - 10),
        lastDate: DateTime(today.year + 10),
        currentDate: today,
        initialDateRange: initialRange);

    if (result != null) {
      await _resetEntries();

      _costProvider.saveSelectedDates(result);
    }
  }

  _showSelectContractDialog() async {
    final List<ContractDto> contracts =
        await db.contractDao.getContractByTyp(widget.meter.typ);

    if (mounted) {
      int? result = await showDialog(
        context: context,
        builder: (context) => SelectContractDialog(
            contracts: contracts, selectedContractId: _selectedContractId),
      );

      if (result != null) {
        setState(() {
          _selectedContractId = result;
        });
        _costProvider.saveSelectedContract(result);
      }
    }
  }

  _hintText() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.only(left: 24, right: 24),
        title: const Text('Informationen'),
        titleTextStyle: Theme.of(context).textTheme.headlineMedium,
        content: Container(
          padding: const EdgeInsets.all(8),
          width: MediaQuery.sizeOf(context).width,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          child: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    'Alle errechneten Werte sind nur eine grobe Schätzung der App und spiegeln nicht den tatsächlichen Verbrauch oder Kosten wieder.'),
                Divider(),
                Text(
                  'Sollte kein Zeitraum ausgewählt sein, werden die Kosten für die gesamte Zeit berechnet.',
                ),
                Divider(),
                Text(
                    'Sollte ein Zeitraum ausgewählt sein, aber die Einträge beginnen oder enden vor dem gewählten Zeitraum, '
                    'so wird der Verbrauch für die restliche Zeit anhand der vorhandenen Einträge geschätzt.'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  Widget _headline(LocalDatabase db) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Kostenübersicht',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                _hintText();
              },
            ),
            _popupMenuButtons(db),
          ],
        ),
      ],
    );
  }
}
