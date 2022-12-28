import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/database/local_database.dart';
import '../utils/room_typ.dart';
import '../widgets/homescreen/meter_card.dart';

class DetailsRoom extends StatefulWidget {
  final RoomData roomData;

  const DetailsRoom({Key? key, required this.roomData}) : super(key: key);

  @override
  State<DetailsRoom> createState() => _DetailsRoomState();
}

class _DetailsRoomState extends State<DetailsRoom> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  bool _update = false;
  String _roomTyp = 'Sonstiges';
  late RoomData _currentRoom;
  final MeterCard _meterCard = const MeterCard();

  @override
  void initState() {
    _currentRoom = widget.roomData;
    _name.text = _currentRoom.name;
    _roomTyp = _currentRoom.typ;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_name.text),
        actions: [
          !_update
              ? IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _update = true;
                    });
                  },
                )
              : IconButton(
                  onPressed: () {
                    _updateRoom(context);
                    setState(() {
                      _update = false;
                      _name.text = _currentRoom.name;
                    });
                  },
                  icon: const Icon(Icons.save),
                )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dropDownMenu(context),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  readOnly: !_update,
                  controller: _name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte geben Sie einen Zimmernamen an';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    label: Text('Zimmername'),
                    icon: Icon(Icons.abc),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  'Zähler',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                _listMeters(_currentRoom.id),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listMeters(int roomId) {
    final db = Provider.of<LocalDatabase>(context, listen: false);
    return FutureBuilder(
      future: db.roomDao.getMeterInRooms(roomId),
      builder: (context, snapshot) {
        final meterData = snapshot.data;
        return FutureBuilder(
          future: meterData,
          builder: (context, snapshot) {
            final meter = snapshot.data ?? [];
            if (meter.isEmpty) {
              return Container();
            }
            return ListView.builder(
              // physics:  const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: meter.length,
              itemBuilder: (context, index) {
                final data = meter[index];
                return FutureBuilder(
                  future: data,
                  builder: (context, snapshot) {
                    final meter = snapshot.data;

                    if (meter == null) {
                      return Container();
                    }

                    return StreamBuilder(
                      stream: db.meterDao.getNewestEntry(meter.id),
                      builder: (context, snapshot) {
                        final entry = snapshot.data?[0];
                        final String date;
                        final String count;

                        if (entry == null) {
                          date = 'none';
                          count = 'none';
                        } else {
                          date = DateFormat('dd.MM.yyyy').format(entry.date);
                          count = entry.count.toString();
                        }

                        return _meterCard.getCard(
                            context: context,
                            meter: meter,
                            room: _currentRoom,
                            date: date,
                            count: count);
                      },
                    );
                  },
                );
              },
            );
          },
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

  _updateRoom(
    BuildContext context,
  ) async {
    final db = Provider.of<LocalDatabase>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      final updateRoom =
          RoomData(id: widget.roomData.id, typ: _roomTyp, name: _name.text);
      _currentRoom = updateRoom;
      await db.roomDao.updateRoom(updateRoom).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Änderung wurde gespeichert!',
          ),
        ));
      });
    }
  }
}
