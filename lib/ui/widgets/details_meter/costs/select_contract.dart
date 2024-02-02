import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/model/contract_dto.dart';
import '../../../../core/model/provider_dto.dart';
import '../../../../core/provider/cost_provider.dart';

class SelectContract extends StatefulWidget {
  final List<ContractDto> contracts;

  const SelectContract({super.key, required this.contracts});

  @override
  State<SelectContract> createState() => _SelectContractState();
}

class _SelectContractState extends State<SelectContract> {
  int _selectedContractId = -1;

  bool _showHint = false;

  List<RadioListTile> _getRadioButtons(Function setState) {
    final List<RadioListTile> buttons = [];

    final String local = Platform.localeName;
    final formatSimpleCurrency = NumberFormat.simpleCurrency(locale: local);

    for (ContractDto contract in widget.contracts) {
      final ProviderDto? provider = contract.provider;

      buttons.add(RadioListTile(
        value: contract.id,
        groupValue: _selectedContractId,
        contentPadding: EdgeInsets.zero,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  formatSimpleCurrency.format(contract.costs.discount),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Abschlag',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  formatSimpleCurrency.format(contract.costs.basicPrice),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Grundpreis',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ],
        ),
        subtitle: provider != null
            ? Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          provider.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Anbieter',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          provider.contractNumber,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Vertragsnummer',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : null,
        onChanged: (value) {
          setState(() {
            if (_showHint) {
              _showHint = false;
            }

            return _selectedContractId = value;
          });
        },
      ));
    }

    return buttons;
  }

  _showSelectionDialog() async {
    return await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            contentPadding: EdgeInsets.zero,
            insetPadding: const EdgeInsets.only(left: 24, right: 24),
            content: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.8,
              ),
              padding: const EdgeInsets.all(8),
              width: MediaQuery.sizeOf(context).height,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: _getRadioButtons(setState),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (_showHint)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "Wähle einen Vertrag aus.",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            title: const Text('Vertrag auswählen'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Abbrechen',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (_selectedContractId == -1) {
                    setState(
                      () => _showHint = true,
                    );
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Speichern'),
              ),
            ],
          ),
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
                  await _showSelectionDialog();

                  costProvider.saveSelectedContract(_selectedContractId);

                  _selectedContractId = -1;
                  _showHint = false;
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
