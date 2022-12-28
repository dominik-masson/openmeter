import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;

import '../../core/database/local_database.dart';
import '../utils/room_typ.dart';
import '../widgets/objects_screen/add_room.dart';
import '../widgets/objects_screen/contract_card.dart';
import '../widgets/objects_screen/room_card.dart';
import 'add_contract.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objekte'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('settings');
              },
              icon: const Icon(Icons.settings)),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                title: const Text(
                  'Meine Zimmer',
                  style: TextStyle(fontSize: 18),
                ),
                trailing: const Icon(Icons.add),
                onTap: () => _addRoom.getAddRoom(context),
              ),
              const RoomCard(),
              ListTile(
                title: const Text(
                  'Meine Verträge',
                  style: TextStyle(fontSize: 18),
                ),
                trailing: const Icon(Icons.add),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddContract(contract: null),
                  ),
                ),
              ),
              const ContractCard(),
            ],
          ),
        ),
      ),
    );
  }
}
