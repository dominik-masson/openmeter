import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/database/local_database.dart';
import '../../core/provider/contract_provider.dart';
import '../../core/provider/database_settings_provider.dart';
import '../../core/provider/details_contract_provider.dart';
import '../../core/provider/room_provider.dart';
import '../widgets/objects_screen/room/add_room.dart';
import '../widgets/objects_screen/contract/contract_grid_view.dart';
import '../widgets/objects_screen/room/room_card.dart';
import 'contract/add_contract.dart';

class ObjectsScreen extends StatefulWidget {
  const ObjectsScreen({Key? key}) : super(key: key);

  @override
  State<ObjectsScreen> createState() => _ObjectsScreenState();
}

class _ObjectsScreenState extends State<ObjectsScreen> {
  final AddRoom _addRoom = AddRoom();

  @override
  void dispose() {
    _addRoom.dispose();
    super.dispose();
  }

  _contractListTile(ContractProvider contractProvider) {
    final detailsProvider = Provider.of<DetailsContractProvider>(context);

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Meine Verträge',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (contractProvider.getHasSelectedItems) {
                    contractProvider.removeAllSelectedItems();
                  }
                  Navigator.of(context).pushNamed('archive_contract');
                },
                icon: const Icon(Icons.archive_outlined),
                tooltip: 'Archivierte Verträge anzeigen',
              ),
              IconButton(
                onPressed: () => Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => const AddContract(contract: null),
                      ),
                    )
                    .then((value) => detailsProvider.setCurrentProvider(null)),
                icon: const Icon(Icons.add),
                tooltip: 'Vertrag erstellen',
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final contractProvider = Provider.of<ContractProvider>(context);

    return Scaffold(
      appBar: roomProvider.getStateHasSelected == true ||
              contractProvider.getHasSelectedItems == true
          ? _hasSelectedItems(
              roomProvider: roomProvider,
              contractProvider: contractProvider,
              context: context)
          : _noSelectedItems(),
      body: WillPopScope(
        onWillPop: () async {
          if (roomProvider.getStateHasSelected == true) {
            roomProvider.removeAllSelected();
            return false;
          }

          if (contractProvider.getHasSelectedItems == true) {
            contractProvider.removeAllSelectedItems();
            return false;
          }

          return true;
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Tooltip(
                  message: 'Raum erstellen',
                  child: ListTile(
                    title: const Text(
                      'Meine Zimmer',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: const Icon(Icons.add),
                    onTap: () => _addRoom.getAddRoom(context),
                  ),
                ),
                const RoomCard(),
                _contractListTile(contractProvider),
                const ContractGridView(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _noSelectedItems() {
    return AppBar(
      title: const Text('Objekte'),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed('settings');
          },
          icon: const Icon(Icons.settings),
          tooltip: 'Einstellungen',
        ),
      ],
    );
  }

  AppBar _hasSelectedItems(
      {required RoomProvider roomProvider,
      required BuildContext context,
      required ContractProvider contractProvider}) {
    int count = roomProvider.getSelectedRoomsLength +
        contractProvider.getSelectedItemsLength;

    final detailsProvider = Provider.of<DetailsContractProvider>(context);
    final db = Provider.of<LocalDatabase>(context, listen: false);

    return AppBar(
      title: Text('$count ausgewählt'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          if (roomProvider.getStateHasSelected == true) {
            roomProvider.removeAllSelected();
          }

          if (contractProvider.getHasSelectedItems == true) {
            contractProvider.removeAllSelectedItems();
          }
        },
      ),
      actions: [
        if (contractProvider.getSelectedItemsLength == 1)
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                    builder: (context) => AddContract(
                      contract: contractProvider.getSingleSelectedContract(),
                    ),
                  ))
                  .then((value) => detailsProvider.setCurrentProvider(null));
            },
            icon: const Icon(Icons.edit),
            tooltip: 'Bearbeiten',
          ),
        if (contractProvider.getHasSelectedItems &&
            !roomProvider.getHasSelectedMeters)
          IconButton(
            onPressed: () async {
              await contractProvider.archiveAllSelectedContract(db);
              contractProvider.removeAllSelectedItems();

              if (mounted) {
                Provider.of<DatabaseSettingsProvider>(context, listen: false)
                    .setHasUpdate(true);
              }
            },
            icon: const Icon(Icons.archive),
            tooltip: 'Archivieren',
          ),
        IconButton(
          onPressed: () {
            if (roomProvider.getStateHasSelected == true) {
              roomProvider.deleteAllSelectedRooms(context);
            }

            if (contractProvider.getHasSelectedItems == true) {
              contractProvider.deleteAllSelectedContracts(db, false);
              Provider.of<DatabaseSettingsProvider>(context, listen: false)
                  .setHasUpdate(true);
            }
          },
          icon: const Icon(Icons.delete),
          tooltip: 'Löschen',
        ),
      ],
    );
  }
}
