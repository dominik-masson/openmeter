import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/model/contract_dto.dart';
import '../../../../core/provider/cost_provider.dart';
import 'select_contract_dialog.dart';

class SelectContractCard extends StatefulWidget {
  final List<ContractDto> contracts;

  const SelectContractCard({super.key, required this.contracts});

  @override
  State<SelectContractCard> createState() => _SelectContractCardState();
}

class _SelectContractCardState extends State<SelectContractCard> {
  _showSelectionDialog() async {
    return await showDialog(
      context: context,
      builder: (context) {
        return SelectContractDialog(
          contracts: widget.contracts,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final costProvider = Provider.of<CostProvider>(context);

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      'Es sind zu viele Verträge aktiv.\nWähle einen Vertrag, der zur Berechnung der Kosten genutzt werden soll.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              OutlinedButton(
                onPressed: () async {
                  int? selectedContractId = await _showSelectionDialog();

                  if (selectedContractId != null) {
                    costProvider.saveSelectedContract(selectedContractId);
                  }
                },
                child: const Text('Vertrag wählen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
