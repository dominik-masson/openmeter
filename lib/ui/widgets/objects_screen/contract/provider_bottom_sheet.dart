import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/local_database.dart';
import '../../../../core/model/contract_dto.dart';
import '../../../../core/model/provider_dto.dart';
import '../../../../core/provider/contract_provider.dart';
import '../../../../core/provider/database_settings_provider.dart';
import '../../../../core/provider/details_contract_provider.dart';
import '../../../../core/services/provider_helper.dart';
import 'add_provider.dart';

class ProviderBottomSheet extends StatefulWidget {
  final bool createProvider;
  final ContractDto contract;

  const ProviderBottomSheet(
      {super.key, required this.createProvider, required this.contract});

  @override
  State<ProviderBottomSheet> createState() => _ProviderBottomSheetState();
}

class _ProviderBottomSheetState extends State<ProviderBottomSheet> {
  ProviderDto? _currentProvider;
  final ProviderHelper _helper = ProviderHelper();

  _showButtons({
    required LocalDatabase db,
    required DetailsContractProvider provider,
    required ContractProvider contractProvider,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () async {
            if (_currentProvider != null) {
              provider.setRemoveCanceledDateState(true, true);

              _currentProvider = await _helper.removeCanceledState(
                  db: db, provider: _currentProvider!);

              contractProvider.updateProvider(
                db: db,
                provider: _currentProvider!,
                contractId: widget.contract.id!,
                isArchiv: false,
              );

              _setAutoUpdateHasUpdate();

              setState(() {
                provider.setCurrentProvider(_currentProvider);
              });
            }
          },
          child: const Text('Kündigung entfernen'),
        ),
        const SizedBox(
          width: 10,
        ),
        ElevatedButton(
          onPressed: () async {
            provider.setDeleteProviderState(true, true);

            if (_currentProvider != null) {
              await _helper.deleteProvider(
                db: db,
                provider: _currentProvider!,
                contractProvider: contractProvider,
                contractId: widget.contract.id!,
              );

              _setAutoUpdateHasUpdate();

              setState(() {
                provider.setCurrentProvider(null);
              });

              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
          },
          child: const Text('Details entfernen'),
        ),
      ],
    );
  }

  _setAutoUpdateHasUpdate() {
    Provider.of<DatabaseSettingsProvider>(context, listen: false)
        .setHasUpdate(true);
  }

  Widget _makeDismissible({required Widget child}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: GestureDetector(
        child: child,
      ),
    );
  }

  void handleOnSave(
      ProviderDto? newProvider, DetailsContractProvider provider) async {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    final ContractProvider contractProvider =
        Provider.of<ContractProvider>(context, listen: false);

    if (widget.createProvider) {
      _currentProvider = await _helper.createProvider(
        db: db,
        provider: newProvider!,
        contractId: widget.contract.id!,
      );
    } else {
      _currentProvider =
          await _helper.updateProvider(db: db, provider: newProvider!);
    }

    contractProvider.updateProvider(
      db: db,
      provider: _currentProvider!,
      contractId: widget.contract.id!,
      isArchiv: false,
    );

    provider.setCurrentProvider(_currentProvider);

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _addProvider() {
    final headlineText = _currentProvider != null
        ? 'Vertragsdetails ändern'
        : 'Vertragsdetails erstellen';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headlineText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: AddProvider(
              showCanceledButton: false,
              provider: _currentProvider,
              textSize: 16,
              onSave: handleOnSave,
              createProvider: widget.createProvider,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DetailsContractProvider>(context);
    final LocalDatabase db = Provider.of<LocalDatabase>(context, listen: false);
    final ContractProvider contractProvider =
        Provider.of<ContractProvider>(context, listen: false);

    _currentProvider = provider.getCurrentProvider;

    return _makeDismissible(
      child: DraggableScrollableSheet(
        initialChildSize: widget.createProvider ? 0.8 : 0.25,
        minChildSize: 0.2,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).cardColor,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  Container(
                    height: 5,
                    width: 30,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).highlightColor,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  _showButtons(
                    db: db,
                    contractProvider: contractProvider,
                    provider: provider,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 15,
                  ),
                  _addProvider(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
