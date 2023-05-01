import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/database/local_database.dart';
import '../../core/provider/refresh_provider.dart';
import '../../core/services/torch_controller.dart';
import '../../../utils/meter_typ.dart';
import '../widgets/tags_screen/add_tags.dart';
import '../widgets/tags_screen/tag_chip.dart';

class AddScreen extends StatefulWidget {
  final MeterData? meter;
  final RoomData? room;
  final List<String> tagsId;

  const AddScreen(
      {Key? key, required this.meter, required this.room, required this.tagsId})
      : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final AddTags _addTags = AddTags();

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
  List<String> _tagsId = [];
  final List<int> _tagChecked = [];
  int _firstLoad = 0;

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

    if (widget.tagsId.isNotEmpty) {
      _tagsId = widget.tagsId;
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
    String? tagsId;

    // handle empty Note and Units
    if (_meternote.text.isEmpty) {
      _meternote.text = '';
    }
    if (_unitController.text.isEmpty) {
      _unitController.text = '';
    }

    // handle selected tags
    if (_tagsId.isNotEmpty) {
      _tagsId.sort();
      tagsId = _tagsId.join(';');
    }

    if (_formKey.currentState!.validate()) {
      final meter = MeterCompanion(
        typ: drift.Value(_meterTyp),
        number: drift.Value(_meternumber.text),
        note: drift.Value(_meternote.text),
        unit: drift.Value(_unitController.text),
        tag: drift.Value(tagsId),
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
          tag: tagsId,
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
            onPressed: _saveEntry,
            icon: const Icon(Icons.save),
          ),
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
                  _tags(context),
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

  Widget _tags(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: const Text('Tags'),
            leading: FaIcon(
              FontAwesomeIcons.tags,
              size: 20,
              color: Theme.of(context).hintColor,
            ),
            trailing: IconButton(
              onPressed: () {
                _addTags.getAddTags(context);
              },
              icon: Icon(Icons.add,
              color: Theme.of(context).iconTheme.color,
            )),
          ),
          StreamBuilder(
            stream: db.tagsDao.watchAllTags(),
            builder: (context, snapshot) {
              final List<Tag> tags = snapshot.data ?? [];

              if (tags.isEmpty) {
                return Container();
              }
              return SizedBox(
                height: 50,
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: tags.length,
                    itemBuilder: (context, index) {
                      Widget child = Container();

                      if (_tagChecked.contains(index) ||
                          _tagsId.contains(tags[index].id.toString())) {
                        child = Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TagChip(
                            delete: false,
                            checked: true,
                            tag: tags[index],
                          ),
                        );
                      } else {
                        child = Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TagChip(
                            delete: false,
                            checked: false,
                            tag: tags[index],
                          ),
                        );
                      }

                      return GestureDetector(
                        onTap: () {
                          if (_tagChecked.contains(index) ||
                              _tagsId.contains(tags[index].id.toString())) {
                            _tagsId.remove(tags[index].id.toString());
                            setState(() {
                              _tagChecked.remove(index);
                            });
                          } else {
                            _tagsId.add(tags[index].id.toString());

                            setState(() {
                              _tagChecked.add(index);
                            });
                          }
                        },
                        child: SizedBox(width: 120, child: child),
                      );
                    }),
              );
            },
          ),
          Divider(
            color: Theme.of(context).indicatorColor,
            thickness: 0.4,
          ),
        ],
      ),
    );
  }

  Widget _unitInput(BuildContext context) {
    if (_unitController.text.isEmpty) {
      _unitController.text = meterTyps[_meterTyp]['einheit'];
    }

    return TextFormField(
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        icon: FaIcon(
          FontAwesomeIcons.ruler,
          size: 16,
        ),
        label: Text('Einheit'),
        hintText: 'm^3 entspricht m\u00B3'
      ),
      controller: _unitController,
      validator: (value) {
        if (value == null || value.isEmpty) {
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

          if (_firstLoad != 2) {
            _createRoomDropDown(roomList);
            _firstLoad++;
          }

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
                value: _room?.id ?? -1,
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

        if (_firstLoad != 2) {
          _createRoomDropDown(roomList);
          _firstLoad++;
        }

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
