import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/model/contract_dto.dart';
import '../../../core/provider/contract_provider.dart';
import '../../../core/provider/database_settings_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../widgets/objects_screen/contract/contract_card.dart';
import '../../widgets/utils/empty_archiv.dart';

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
      body: WillPopScope(
        onWillPop: () async {
          if (contractProvider.getHasSelectedItems == true) {
            contractProvider.removeAllSelectedItems();
            return false;
          }

          return true;
        },
        child: StreamBuilder(
          stream: db.contractDao.watchAllContracts(true),
          builder: (context, snapshot) {
            final List<ContractData>? items = snapshot.data;

            if (items != null &&
                items.length != contractProvider.getArchivedContractsLength) {
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
                      provider: contractProvider, contract: contract, db: db);
                }
              },
            );
          },
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

  _selectedAppBar(LocalDatabase db) {
    final contractProvider = Provider.of<ContractProvider>(context);
    final backupProvider =
        Provider.of<DatabaseSettingsProvider>(context, listen: false);

    int count = contractProvider.getSelectedItemsLength;

    return AppBar(
      title: Text('$count ausgewählt'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => contractProvider.removeAllSelectedItems(),
      ),
      actions: [
        IconButton(
          onPressed: () async {
            await contractProvider.unarchiveSelectedContracts(db);
            contractProvider.removeAllSelectedItems();

            if (mounted) {
              backupProvider.setHasUpdate(true);
            }
          },
          icon: const Icon(Icons.unarchive),
          tooltip: 'Archivieren',
        ),
        IconButton(
          onPressed: () {
            contractProvider.deleteAllSelectedContracts(db, true);
            backupProvider.setHasUpdate(true);
          },
          icon: const Icon(Icons.delete),
          tooltip: 'Löschen',
        ),
      ],
    );
  }
}
