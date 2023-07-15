import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/database/local_database.dart';
import '../../core/model/room_dto.dart';
import '../../core/provider/database_settings_provider.dart';
import '../../core/provider/room_provider.dart';
import '../../utils/room_typ.dart';
import '../widgets/homescreen/meter_card.dart';
import '../widgets/objects_screen/add_meter_to_room.dart';

class DetailsRoom extends StatefulWidget {
  final RoomDto roomData;

  const DetailsRoom({Key? key, required this.roomData}) : super(key: key);

  @override
  State<DetailsRoom> createState() => _DetailsRoomState();
}

class _DetailsRoomState extends State<DetailsRoom> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  bool _update = false;
  String _roomTyp = 'Sonstiges';
  late RoomDto _currentRoom;

  @override
  void initState() {
    _currentRoom = widget.roomData;
    _name.text = _currentRoom.name!;
    _roomTyp = _currentRoom.typ!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);

    final db = Provider.of<LocalDatabase>(context, listen: false);
    final autoBackUp =
        Provider.of<DatabaseSettingsProvider>(context, listen: false);

    int meterCount = roomProvider.getMeterCount;

    if (meterCount != 0) {
      _currentRoom.sumMeter = _currentRoom.sumMeter! + meterCount;
      roomProvider.setMeterCount(0);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_name.text),
        actions: [
          _update == false
              ? IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _update = true;
                    });
                  },
                )
              : IconButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_roomTyp == _currentRoom.typ &&
                          _name.text == _currentRoom.name) {
                        setState(() {
                          _update = false;
                        });
                        return;
                      }

                      if (_name.text.isEmpty) {
                        _name.text = _roomTyp;
                      }

                      final updateRoom = RoomData(
                          id: widget.roomData.id!,
                          uuid: widget.roomData.uuid!,
                          typ: _roomTyp,
                          name: _name.text);

                      _currentRoom = await roomProvider.updateRoom(
                          db: db,
                          roomData: updateRoom,
                          backupState: autoBackUp);
                    }

                    setState(() {
                      _update = false;
                      _name.text = _currentRoom.name!;
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
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Bitte geben Sie einen Zimmernamen an';
                  //   }
                  //   return null;
                  // },
                  decoration: const InputDecoration(
                    label: Text('Zimmername'),
                    icon: Icon(Icons.abc),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  '${_currentRoom.sumMeter ?? 0} Zähler',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Neue Zähler zuordnen'),
                  dense: true,
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                      builder: (context) => AddMeterToRoom(room: _currentRoom),
                    ))
                        .then((value) {
                      if (value == true) {
                        setState(() {});
                      }
                    });
                  },
                ),
                _listMeters(_currentRoom.uuid!, roomProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listMeters(String roomId, RoomProvider provider) {
    final db = Provider.of<LocalDatabase>(context);

    return FutureBuilder(
      future: db.roomDao.getMeterInRooms(roomId),
      builder: (context, meter) {
        if (meter.data == null) {
          return Container();
        }

        return ListView.builder(
          itemCount: meter.data!.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final data = meter.data![index];

            return StreamBuilder(
              stream: db.entryDao.getNewestEntry(data.id),
              builder: (context, snapshot) {
                final entry = snapshot.data?[0];
                final DateTime? date;
                final String count;

                if (entry == null) {
                  date = null;
                  count = 'none';
                } else {
                  date = entry.date;
                  count = entry.count.toString();
                }

                return MeterCard(
                  meter: data,
                  room: _currentRoom,
                  date: date,
                  count: count,
                  isSelected: false,
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
      child: IgnorePointer(
        ignoring: !_update,
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
      ),
    );
  }
}
