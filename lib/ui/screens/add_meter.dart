import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/database/local_database.dart';
import '../../core/provider/entry_card_provider.dart';
import '../../core/provider/refresh_provider.dart';
import '../../core/services/torch_controller.dart';
import '../../../utils/meter_typ.dart';

class AddScreen extends StatefulWidget {
  final MeterData? meter;
  final RoomData? room;

  const AddScreen({Key? key, required this.meter, required this.room})
      : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _meternumber = TextEditingController();
  final TextEditingController _meternote = TextEditingController();
  final TextEditingController _metervalue = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _meterTyp = 'Stromzähler';
  int _roomId = -2; // -2: not selected, -1: no part of room
  String _pageTitle = 'Neuer Zähler';
  bool _updateMeter = false;
  RoomData? _room;

  final List<DropdownMenuItem> _roomList = [
    const DropdownMenuItem(
      value: -1,
      child: Text('Keinem Zimmer zugeordnet'),
    ),
  ];

  final TorchController _torchController = TorchController();

  @override
  void initState() {
    if (widget.meter == null) {
      return;
    } else {
      _setController();
    }

    if (widget.room != null) {
      _room = widget.room!;
    } else {
      _roomId = -1;
    }

    super.initState();
  }

  @override
  void dispose() {
    _meternumber.dispose();
    _meternote.dispose();
    _metervalue.dispose();
    super.dispose();
  }


  /*
    init values when meter is to be updated
   */
  void _setController() {
    _pageTitle = widget.meter!.number;
    _meternumber.text = widget.meter!.number;
    _meternote.text = widget.meter!.note;
    _meterTyp = widget.meter!.typ;
    _updateMeter = true;
    _unitController.text = widget.meter!.unit;
  }

  Future<void> _saveEntry() async {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    if (_meternote.text.isEmpty) {
      _meternote.text = '';
    }
    if(_unitController.text.isEmpty){
      _unitController.text = '';
    }

    if (_formKey.currentState!.validate()) {
      final meter = MeterCompanion(
        typ: drift.Value(_meterTyp),
        number: drift.Value(_meternumber.text),
        note: drift.Value(_meternote.text),
        unit: drift.Value(_unitController.text),
      );

      if (!_updateMeter) {
        int meterId = await db.meterDao.createMeter(meter);

        if (_roomId != -2 || _roomId != -1) {
          final room = MeterInRoomCompanion(
            meterId: drift.Value(meterId),
            roomId: drift.Value(_roomId),
          );

          await db.roomDao.createMeterInRoom(room);
        }

        final entry = EntriesCompanion(
          count: drift.Value(int.parse(_metervalue.text)),
          date: drift.Value(DateTime.now()),
          meter: drift.Value(meterId),
          usage: const drift.Value(-1),
          days: const drift.Value(-1),
        );

        await db.entryDao.createEntry(entry).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              'Zähler wird erstellt!',
            ),
          ));
          Navigator.of(context).pop();
        });
      } else {
        Provider.of<RefreshProvider>(context, listen: false).setRefresh(true);

        MeterData meterData = MeterData(
          typ: _meterTyp,
          note: _meternote.text,
          number: _meternumber.text,
          id: widget.meter!.id,
          unit: _unitController.text,
        );

        if (_roomId != -2) {
          if (_roomId == -1) {
            await db.roomDao.deleteMeter(widget.meter!.id);
          } else {
            await db.roomDao.deleteMeter(widget.meter!.id);
            final roomWithMeter = MeterInRoomCompanion(
              meterId: drift.Value(widget.meter!.id),
              roomId: drift.Value(_roomId),
            );

            await db.roomDao.createMeterInRoom(roomWithMeter);
          }
        }

        await db.meterDao.updateMeter(meterData).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              'Zähler wird aktualisiert!',
            ),
          ));
          Navigator.of(context).pop([meterData, _room]);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTorchOn = _torchController.stateTorch;

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isTorchOn = !isTorchOn;
              });
              _torchController.getTorch();
            },
            icon: isTorchOn
                ? const Icon(
                    Icons.flashlight_on,
                    // color: darkMode ? Colors.white : Colors.black,
                  )
                : const Icon(
                    Icons.flashlight_off,
                    // color: darkMode ? Colors.white : Colors.black,
                  ),
          ),
        ],
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
                  _unitInput(context),
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
                  if (!_updateMeter)
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
                        // icon: Icon(Icons.assessment_outlined),
                        icon: FaIcon(
                          FontAwesomeIcons.chartSimple,
                          size: 16,
                        ),
                      ),
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

  Widget _unitInput(BuildContext context) {
    if(_unitController.text.isEmpty){
      _unitController.text = meterTyps[_meterTyp]['einheit'];
    }

    return TextFormField(
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        icon: FaIcon(FontAwesomeIcons.ruler, size: 16,),
        label: Text('Einheit'),
      ),
      controller: _unitController,
      validator: (value) {
        if(value == null ||value.isEmpty){
          return 'Bitte geben Sie eine Einheit an!';
        }
        return null;
      },
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
          // contentPadding: EdgeInsets.all(0.0),
          isDense: true,
        ),
        value: _meterTyp,
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
          _meterTyp = value!;
          _unitController.text = meterTyps[_meterTyp]['einheit'];
        },
      ),
    );
  }

  void _createRoomDropDown(List<RoomData> rooms) {
    _roomList.addAll(rooms.map((e) {
      return DropdownMenuItem(
        value: e.id,
        child: Text('${e.typ}: ${e.name}'),
      );
    }));
  }

  Widget _dropDownRoom(BuildContext context) {
    final data = Provider.of<LocalDatabase>(context);
    if (_updateMeter) {
      return StreamBuilder(
        stream: data.roomDao.watchAllRooms(),
        builder: (context, snapshot) {
          final roomList = snapshot.data ?? [];

          _createRoomDropDown(roomList);

          if (_roomList.length != 1) {
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: DropdownButtonFormField(
                isExpanded: true,
                decoration: const InputDecoration(
                  label: Text(
                    'Zimmer',
                  ),
                  // icon: Icon(Icons.bedroom_parent_outlined),
                  icon: FaIcon(
                    FontAwesomeIcons.bed,
                    size: 16,
                  ),
                ),
                items: _roomList,
                value: widget.room?.id ?? -1,
                onChanged: (value) {
                  _roomId = int.parse(value.toString());

                  if (value >= 0) {
                    for (RoomData rd in roomList) {
                      if (rd.id == value) {
                        _room = rd;
                        break;
                      }
                    }
                  } else {
                    _room = null;
                  }
                },
              ),
            );
          }
          return Container();
        },
      );
    }

    return StreamBuilder(
      stream: data.roomDao.watchAllRooms(),
      builder: (context, snapshot) {
        final roomList = snapshot.data ?? [];

        _createRoomDropDown(roomList);

        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: DropdownButtonFormField(
            isExpanded: true,
            decoration: const InputDecoration(
              label: Text(
                'Zimmer',
              ),
              // icon: Icon(Icons.bedroom_parent_outlined),
              icon: FaIcon(
                FontAwesomeIcons.bed,
                size: 16,
              ),
            ),
            value: _roomId == -2 ? -1 : _roomId,
            items: _roomList,
            onChanged: (value) {
              _roomId = int.parse(value.toString());
            },
          ),
        );
      },
    );
  }
}
