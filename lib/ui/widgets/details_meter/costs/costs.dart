import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/local_database.dart';
import '../../../../core/model/contract_dto.dart';
import '../../../../core/model/meter_dto.dart';
import '../../../../core/provider/cost_provider.dart';
import 'cost_card.dart';
import 'select_contract.dart';

class MainViewCosts extends StatefulWidget {
  final MeterDto meter;

  const MainViewCosts({super.key, required this.meter});

  @override
  State<MainViewCosts> createState() => _MainViewCostsState();
}

class _MainViewCostsState extends State<MainViewCosts> {
  @override
  Widget build(BuildContext context) {
    final costProvider = Provider.of<CostProvider>(context);
    final db = Provider.of<LocalDatabase>(context);

    costProvider.setMeterId(widget.meter.id ?? -1);

    int? selectedContractId = costProvider.getSelectedContract;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: selectedContractId == null
          ? _allContractFuture(db)
          : _selectedContractFuture(db, selectedContractId, costProvider),
    );
  }

  _selectedContractFuture(
      LocalDatabase db, int selectedContractId, CostProvider costProvider) {
    return FutureBuilder(
      future: db.contractDao.getContractById(selectedContractId),
      builder: (context, snapshot) {
        final ContractDto? contract = snapshot.data;

        if (contract == null) {
          return _allContractFuture(db);
        }

        final costs = contract.costs;

        costProvider.setValues(
            costs.basicPrice, costs.energyPrice, costs.discount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _headline(),
            const SizedBox(
              height: 5,
            ),
            CostCard(contract: contract),
          ],
        );
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _headline(),
            const SizedBox(
              height: 5,
            ),
            if (contracts.length > 1) SelectContract(contracts: contracts),
          ],
        );
      },
    );
  }

  Widget _headline() {
    return Column(
      children: [
        Text(
          'Kostenübersicht',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}
