import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:provider/provider.dart';

import '../../core/database/local_database.dart';
import '../utils/meter_typ.dart';


class AddScreen extends StatefulWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _meternumber = TextEditingController();
  final TextEditingController _meternote = TextEditingController();
  final TextEditingController _metervalue = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _meterTyp = '';
  int _roomId = -1;

  @override
  void dispose() {
    super.dispose();
    _meternumber.dispose();
    _meternote.dispose();
    _metervalue.dispose();
  }

  Future<void> _saveEntry() async {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    if (_meternote.text.isEmpty) {
      _meternote.text = '';
    }

    if (_formKey.currentState!.validate()) {
      final meter = MeterCompanion(
        typ: drift.Value(_meterTyp),
        number: drift.Value(_meternumber.text),
        note: drift.Value(_meternote.text),
      );

      int meterId = await db.meterDao.createMeter(meter);

      final entry = EntriesCompanion(
        count: drift.Value(int.parse(_metervalue.text)),
        date: drift.Value(DateTime.now()),
        meter: drift.Value(meterId),
      );

      if(_roomId != -1){
        final room = MeterInRoomCompanion(
          meterId: drift.Value(meterId),
          roomId: drift.Value(_roomId),
        );

        await db.roomDao.createMeterInRoom(room);
      }

      await db.meterDao.createEntry(entry).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Zähler wird erstellt!',
          ),
        ));
        Navigator.of(context).pop();

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neuer Zähler'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(25),
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(
                children: [
                  _dropdownMeterTyp(context),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte gebe eine Zählernummer ein!';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    controller: _meternumber,
                    decoration: const InputDecoration(
                        label: Text('Zählernummer'),
                        icon: Icon(Icons.onetwothree_outlined)),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    controller: _meternote,
                    decoration: const InputDecoration(
                        label: Text('Notiz'),
                        icon: Icon(Icons.drive_file_rename_outline)),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte gebe den aktuellen Zählerstand ein!';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    controller: _metervalue,
                    decoration: const InputDecoration(
                        label: Text('Aktueller Zählerstand'),
                        icon: Icon(Icons.assessment_outlined)),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  _dropDownRoom(context),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveEntry,
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
      ),
    );
  }

  Widget _dropdownMeterTyp(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: DropdownButtonFormField(
        validator: (value) {
          if (value == null) {
            return 'Bitte wähle einen Zählertyp!';
          }
          return null;
        },
        // value: _meterTyp,
        isExpanded: true,
        decoration: const InputDecoration(
          label: Text('Zählertyp'),
          icon: Icon(Icons.gas_meter_outlined),
          contentPadding: EdgeInsets.all(0.0),
          isDense: true,
        ),
        items: meterTyps.entries.map((e) {
          return DropdownMenuItem(
            value: e.key,
            child: Row(
              children: [
                e.value['avatar'],
                const SizedBox(
                  width: 20,
                ),
                Text(e.key),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _meterTyp = value!;
          });
        },
      ),
    );
  }

  Widget _dropDownRoom(BuildContext context) {
    final data = Provider.of<LocalDatabase>(context);
    return StreamBuilder(
      stream: data.roomDao.watchAllRooms(),
      builder: (context, snapshot) {
        final roomList = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: DropdownButtonFormField(
            isExpanded: true,
            // value: _room,
            decoration: const InputDecoration(
              label: Text(
                'Zimmer',
              ),
              icon: Icon(Icons.bedroom_parent_outlined),
            ),
            items: roomList.map((e) {
              return DropdownMenuItem(
                value: e.id,
                child: Text('${e.typ}: ${e.name}'),
              );
            }).toList(),
            onChanged: (value) {
              _roomId = int.parse(value.toString());
            },
          ),
        );
      },
    );
  }
}
