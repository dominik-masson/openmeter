import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;

import '../../core/database/local_database.dart';
import '../utils/room_typ.dart';
import '../widgets/contract_card.dart';
import '../widgets/room_card.dart';
import 'add_contract.dart';

class ObjectsScreen extends StatefulWidget {
  const ObjectsScreen({Key? key}) : super(key: key);

  @override
  State<ObjectsScreen> createState() => _ObjectsScreenState();
}

class _ObjectsScreenState extends State<ObjectsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _roomTyp = 'Sonstiges';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  _saveRoom() async {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      final room = RoomCompanion(
        typ: drift.Value(_roomTyp),
        name: drift.Value(_nameController.text),
      );

      await db.roomDao.createRoom(room).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Raum wird erstellt!',
          ),
        ));
        Navigator.of(context).pop();
        _roomTyp = 'Sonstiges';
        _nameController.clear();
      });
    }
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
                onTap: () {
                  // Navigator.of(context).pushNamed('add_room');
                  _showBottonSheet(context);
                },
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

  Future _showBottonSheet(BuildContext context) {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            height: 400,
            padding: const EdgeInsets.all(25),
            child: Center(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    const Text(
                      'Neues Zimmer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    _dropDownMenu(context),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bitte geben Sie einen Zimmernamen an';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          icon: Icon(Icons.abc), label: Text('Zimmername')),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveRoom,
                          icon: const Icon(Icons.check),
                          label: const Text('Speichern'),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _dropDownMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: DropdownButtonFormField(
        value: _roomTyp,
        isExpanded: true,
        decoration: const InputDecoration(
          label: Text(
            'Zimmertyp',
          ),
          icon: Icon(Icons.bedroom_parent_outlined),
        ),
        items: roomTyps.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Row(
              children: [
                Text(e.toString()),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          _roomTyp = value.toString();
        },
      ),
    );
  }
}
