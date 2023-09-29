import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/provider/contract_provider.dart';
import '../../core/provider/details_contract_provider.dart';
import '../../core/provider/room_provider.dart';
import '../widgets/objects_screen/room/add_room.dart';
import '../widgets/objects_screen/contract/contract_card.dart';
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

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final contractProvider = Provider.of<ContractProvider>(context);

    final detailsProvider = Provider.of<DetailsContractProvider>(context);

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
                Tooltip(
                  message: 'Vertrag erstellen',
                  child: ListTile(
                    title: const Text(
                      'Meine Verträge',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: const Icon(Icons.add),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddContract(contract: null),
                      ),
                    ).then((value) => detailsProvider.setCurrentProvider(null)),
                  ),
                ),
                const ContractCard(),
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
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddContract(
                  contract: contractProvider.getSingleSelectedContract(),
                ),
              )).then((value) => detailsProvider.setCurrentProvider(null));
            },
            icon: const Icon(Icons.edit),
          ),
        IconButton(
          onPressed: () {
            if (roomProvider.getStateHasSelected == true) {
              roomProvider.deleteAllSelectedRooms(context);
            }

            if (contractProvider.getHasSelectedItems == true) {
              contractProvider.deleteAllSelectedContracts(context);
            }
          },
          icon: const Icon(Icons.delete),
          tooltip: 'Löschen',
        ),
      ],
    );
  }
}
