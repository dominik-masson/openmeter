import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/model/contract_dto.dart';
import '../../../core/model/provider_dto.dart';
import '../../../core/provider/details_contract_provider.dart';
import '../../../utils/meter_typ.dart';
import '../../widgets/objects_screen/contract/compare_contracts.dart';
import '../../widgets/objects_screen/contract/cost_card.dart';
import '../../widgets/objects_screen/contract/provider_card.dart';
import 'add_contract.dart';

class DetailsContract extends StatefulWidget {
  final ContractDto contract;

  const DetailsContract({super.key, required this.contract});

  @override
  State<DetailsContract> createState() => _DetailsContractState();
}

class _DetailsContractState extends State<DetailsContract> {
  late ContractDto _currentContract;
  ProviderDto? _currentProvider;

  @override
  void initState() {
    _currentContract = widget.contract;
    _currentProvider = _currentContract.provider;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DetailsContractProvider>(context);

    if (_currentContract.compareCosts != null) {
      provider.setCompareContract(_currentContract.compareCosts, false);
    }

    _currentProvider = provider.getCurrentProvider;

    if (_currentProvider != null && _currentContract.provider == null) {
      _currentContract.provider = _currentProvider;
    }

    final meterTyp = meterTyps
        .firstWhere((element) => element.meterTyp == _currentContract.meterTyp);

    return Scaffold(
      appBar: AppBar(
        title: Text(meterTyp.providerTitle),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => AddContract(
                    contract: _currentContract,
                  ),
                ),
              )
                  .then((value) {
                setState(() {
                  if (value != null) {
                    _currentContract = value;
                    _currentProvider = _currentContract.provider;

                    _currentContract.compareCosts = provider.getCompareContract;

                    provider.setCurrentProvider(_currentProvider);
                    provider.setUnit(_currentContract.unit);
                  }
                });
              });
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CostCard(contract: _currentContract),
                  if (provider.getCompareContract != null)
                    const SizedBox(
                      height: 10,
                    ),
                  if (provider.getCompareContract != null)
                    const CompareContracts(),
                  const SizedBox(
                    height: 10,
                  ),
                  ProviderCard(
                    provider: _currentProvider,
                    contract: _currentContract,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
