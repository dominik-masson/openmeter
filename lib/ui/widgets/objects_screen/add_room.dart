import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/database/local_database.dart';
import '../../../core/provider/database_settings_provider.dart';
import '../../../utils/room_typ.dart';

class AddRoom {
  final _formKey = GlobalKey<FormState>();
  String _roomTyp = 'Sonstiges';
  final TextEditingController _nameController = TextEditingController();

  AddRoom();

  void dispose() {
    _nameController.dispose();
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

  _saveRoom(BuildContext context) async {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      if (_nameController.text.isEmpty) {
        _nameController.text = _roomTyp;
      }

      Provider.of<DatabaseSettingsProvider>(context, listen: false)
          .setHasUpdate(true);

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

  Future getAddRoom(BuildContext context) {
    return showModalBottomSheet(
      backgroundColor: Theme.of(context).bottomAppBarTheme.color,
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
                          onPressed: () => _saveRoom(context),
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
}
