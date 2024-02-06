import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/model/contract_dto.dart';
import '../../../core/provider/contract_provider.dart';
import '../../../core/provider/cost_provider.dart';
import '../../../core/provider/database_settings_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../widgets/objects_screen/contract/contract_card.dart';
import '../../widgets/utils/empty_archiv.dart';
import '../../widgets/utils/selected_items_bar.dart';

class ArchiveContract extends StatefulWidget {
  const ArchiveContract({super.key});

  @override
  State<ArchiveContract> createState() => _ArchiveContractState();
}

class _ArchiveContractState extends State<ArchiveContract> {
  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context);
    final contractProvider = Provider.of<ContractProvider>(context);

    bool hasSelectedItems = contractProvider.getHasSelectedItems;

    return Scaffold(
      appBar: hasSelectedItems
          ? _selectedAppBar(db)
          : AppBar(
              title: const Text('Archivierte Verträge'),
            ),
      body: PopScope(
        canPop: !contractProvider.getHasSelectedItems,
        onPopInvoked: (bool didPop) async {
          if (contractProvider.getHasSelectedItems == true) {
            contractProvider.removeAllSelectedItems(true);
          }
        },
        child: Stack(
          children: [
            StreamBuilder(
              stream: db.contractDao.watchAllContracts(true),
              builder: (context, snapshot) {
                final List<ContractData>? items = snapshot.data;

                if (items != null &&
                    items.length !=
                        contractProvider.getArchivedContractsLength) {
                  contractProvider.convertData(
                      data: items, db: db, isArchived: true);
                }

                final List<ContractDto> contracts =
                    contractProvider.getArchivedContracts;

                if (contracts.isEmpty &&
                    snapshot.connectionState == ConnectionState.active) {
                  return const EmptyArchiv(
                      titel: 'Es wurden noch keine Verträge archiviert.');
                }

                return ListView.builder(
                  itemCount: contracts.length,
                  itemBuilder: (context, index) {
                    final contract = contracts.elementAt(index);

                    if (hasSelectedItems) {
                      return ContractCard(
                        contractDto: contract,
                      );
                    } else {
                      return _slideCard(
                          provider: contractProvider,
                          contract: contract,
                          db: db);
                    }
                  },
                );
              },
            ),
            if (hasSelectedItems) _selectedItemsBar(db),
          ],
        ),
      ),
    );
  }

  _slideCard(
      {required ContractDto contract,
      required ContractProvider provider,
      required LocalDatabase db}) {
    final autoBackup =
        Provider.of<DatabaseSettingsProvider>(context, listen: false);

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              provider.deleteSingleContract(contract: contract, db: db);

              if (context.mounted) {
                autoBackup.setHasUpdate(true);
              }
            },
            icon: Icons.delete,
            label: 'Löschen',
            backgroundColor: CustomColors.red,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
        ],
      ),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              await provider.unarchiveSingleContract(db, contract);

              if (context.mounted) {
                autoBackup.setHasUpdate(true);
              }
            },
            icon: Icons.unarchive,
            label: 'Wiederherstellen',
            foregroundColor: Colors.white,
            backgroundColor: CustomColors.blue,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
        ],
      ),
      child: ContractCard(contractDto: contract),
    );
  }

  _selectedItemsBar(LocalDatabase db) {
    final contractProvider = Provider.of<ContractProvider>(context);
    final backupProvider =
        Provider.of<DatabaseSettingsProvider>(context, listen: false);

    final buttonStyle = ButtonStyle(
      foregroundColor: MaterialStateProperty.all(
        Theme.of(context).textTheme.bodyLarge!.color,
      ),
    );

    final buttons = [
      TextButton(
        onPressed: () async {
          await contractProvider.unarchiveSelectedContracts(db);
          contractProvider.removeAllSelectedItems(true);

          if (mounted) {
            backupProvider.setHasUpdate(true);
          }
        },
        style: buttonStyle,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.unarchive_outlined,
              size: 28,
            ),
            SizedBox(
              height: 5,
            ),
            Text('Wiederherstellen'),
          ],
        ),
      ),
      TextButton(
        onPressed: () {
          final costProvider =
              Provider.of<CostProvider>(context, listen: false);
          contractProvider.deleteAllSelectedContracts(
              db: db, isArchiv: true, costProvider: costProvider);
          backupProvider.setHasUpdate(true);
        },
        style: buttonStyle,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_outline,
              size: 28,
            ),
            SizedBox(
              height: 5,
            ),
            Text('Löschen'),
          ],
        ),
      ),
    ];

    return SelectedItemsBar(buttons: buttons);
  }

  _selectedAppBar(LocalDatabase db) {
    final contractProvider = Provider.of<ContractProvider>(context);

    int count = contractProvider.getSelectedItemsLength;

    return AppBar(
      title: Text('$count ausgewählt'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => contractProvider.removeAllSelectedItems(true),
      ),
    );
  }
}
