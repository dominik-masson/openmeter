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
import '../widgets/utils/selected_items_bar.dart';
import 'contract/add_contract.dart';

class ObjectsScreen extends StatefulWidget {
  const ObjectsScreen({super.key});

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
          Text(
            'Meine Verträge',
            style: Theme.of(context).textTheme.headlineMedium,
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
              roomProvider: roomProvider, contractProvider: contractProvider)
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
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Tooltip(
                      message: 'Raum erstellen',
                      child: ListTile(
                        title: Text(
                          'Meine Zimmer',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        trailing: const Icon(Icons.add),
                        onTap: () => _addRoom.getAddRoom(context),
                      ),
                    ),
                    const RoomCard(),
                    _contractListTile(contractProvider),
                    const ContractGridView(),
                    if (contractProvider.getHasSelectedItems)
                      const SizedBox(
                        height: 100,
                      ),
                  ],
                ),
              ),
            ),
            if (roomProvider.getStateHasSelected) _selectedRooms(roomProvider),
            if (contractProvider.getHasSelectedItems)
              _selectedContract(contractProvider),
          ],
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

  _selectedRooms(RoomProvider roomProvider) {
    final buttonStyle = ButtonStyle(
      foregroundColor: MaterialStateProperty.all(
        Theme.of(context).textTheme.bodyLarge!.color,
      ),
    );

    final buttons = [
      TextButton(
        onPressed: () {
          roomProvider.deleteAllSelectedRooms(context);
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

  _selectedContract(ContractProvider contractProvider) {
    final detailsProvider = Provider.of<DetailsContractProvider>(context);
    final db = Provider.of<LocalDatabase>(context, listen: false);

    final buttonStyle = ButtonStyle(
      foregroundColor: MaterialStateProperty.all(
        Theme.of(context).textTheme.bodyLarge!.color,
      ),
    );

    final buttons = [
      if (contractProvider.getSelectedItemsLength == 1)
        TextButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(
                  builder: (context) => AddContract(
                    contract: contractProvider.getSingleSelectedContract(),
                  ),
                ))
                .then((value) => detailsProvider.setCurrentProvider(null));
          },
          style: buttonStyle,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit_outlined,
                size: 28,
              ),
              SizedBox(
                height: 5,
              ),
              Text('Bearbeiten'),
            ],
          ),
        ),
      TextButton(
        onPressed: () async {
          await contractProvider.archiveAllSelectedContract(db);
          contractProvider.removeAllSelectedItems();

          if (mounted) {
            Provider.of<DatabaseSettingsProvider>(context, listen: false)
                .setHasUpdate(true);
          }
        },
        style: buttonStyle,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.archive_outlined,
              size: 28,
            ),
            SizedBox(
              height: 5,
            ),
            Text('Archivieren'),
          ],
        ),
      ),
      TextButton(
        onPressed: () {
          contractProvider.deleteAllSelectedContracts(db, false);
          Provider.of<DatabaseSettingsProvider>(context, listen: false)
              .setHasUpdate(true);
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

  AppBar _hasSelectedItems(
      {required RoomProvider roomProvider,
      required ContractProvider contractProvider}) {
    int count = roomProvider.getSelectedRoomsLength +
        contractProvider.getSelectedItemsLength;

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
    );
  }
}
