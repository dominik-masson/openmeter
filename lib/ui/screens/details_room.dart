import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:openmeter/utils/custom_icons.dart';
import 'package:provider/provider.dart';

import '../../core/database/local_database.dart';
import '../../core/enums/current_screen.dart';
import '../../core/model/meter_dto.dart';
import '../../core/model/room_dto.dart';
import '../../core/provider/database_settings_provider.dart';
import '../../core/provider/room_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/room_typ.dart';
import '../widgets/meter/meter_card.dart';
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

  final FocusNode _roomTypsFocus = FocusNode();

  @override
  void initState() {
    _currentRoom = widget.roomData;
    _name.text = _currentRoom.name;
    _roomTyp = _currentRoom.typ;
    super.initState();
  }

  _updateRoom({
    required DatabaseSettingsProvider autoBackUp,
    required RoomProvider roomProvider,
    required LocalDatabase db,
  }) async {
    if (_formKey.currentState!.validate()) {
      if (_roomTyp == _currentRoom.typ && _name.text == _currentRoom.name) {
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
          uuid: widget.roomData.uuid,
          typ: _roomTyp,
          name: _name.text);

      _currentRoom = await roomProvider.updateRoom(
          db: db, roomData: updateRoom, backupState: autoBackUp);
    }

    setState(() {
      _update = false;
      _name.text = _currentRoom.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);

    final db = Provider.of<LocalDatabase>(context, listen: false);
    final autoBackUp =
        Provider.of<DatabaseSettingsProvider>(context, listen: false);

    roomProvider.loadAllMeterWithRoom(db);

    int meterCount = roomProvider.getMeterCount;

    if (meterCount != _currentRoom.sumMeter && roomProvider.getHasUpdate) {
      _currentRoom.sumMeter = meterCount + _currentRoom.sumMeter!;
      roomProvider.setMeterCount(0);
      roomProvider.setHasUpdate(false);
    }

    bool hasSelectedMeters = roomProvider.getHasSelectedMeters;

    if (!_update) {
      _roomTypsFocus.unfocus();
    }

    return Scaffold(
      appBar: hasSelectedMeters
          ? _selectedAppBar(roomProvider, db)
          : _nonSelectedAppBar(
              db: db, roomProvider: roomProvider, autoBackUp: autoBackUp),
      body: WillPopScope(
        onWillPop: () async {
          if (hasSelectedMeters) {
            roomProvider.removeAllSelectedMetersInRoom();
            return false;
          }

          return true;
        },
        child: SingleChildScrollView(
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
                    decoration: InputDecoration(
                      label: const Text('Zimmername'),
                      icon: const Icon(Icons.abc),
                      enabled: _update,
                      labelStyle: _update
                          ? TextStyle(
                              color: Theme.of(context)
                                  .inputDecorationTheme
                                  .focusColor)
                          : TextStyle(color: Theme.of(context).indicatorColor),
                    ),
                    style: TextStyle(color: Theme.of(context).indicatorColor),
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
                        builder: (context) =>
                            AddMeterToRoom(room: _currentRoom),
                      ))
                          .then((value) {
                        if (value[0] == true) {
                          _currentRoom.sumMeter = value[1];

                          setState(() {});
                        }
                      });
                    },
                  ),
                  _listMeters(
                    _currentRoom.uuid,
                    roomProvider,
                    hasSelectedMeters,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _selectedAppBar(RoomProvider roomProvider, LocalDatabase db) {
    return AppBar(
      title: Text('${roomProvider.getSelectedMetersLength} ausgewählt'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          roomProvider.removeAllSelectedMetersInRoom();
        },
      ),
      actions: [
        IconButton(
          onPressed: () {
            Provider.of<DatabaseSettingsProvider>(context, listen: false)
                .setHasUpdate(true);

            roomProvider.deleteAllSelectedMetersInRoom(db);
          },
          icon: const Icon(Icons.playlist_remove),
        ),
      ],
    );
  }

  AppBar _nonSelectedAppBar({
    required LocalDatabase db,
    required RoomProvider roomProvider,
    required DatabaseSettingsProvider autoBackUp,
  }) {
    return AppBar(
      title: Text(_name.text),
      actions: [
        _update == false
            ? IconButton(
                tooltip: 'Raum bearbeiten',
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _update = true;
                  });
                },
              )
            : IconButton(
                onPressed: () => _updateRoom(
                  autoBackUp: autoBackUp,
                  roomProvider: roomProvider,
                  db: db,
                ),
                icon: const Icon(Icons.save),
                tooltip: 'Änderung speichern',
              )
      ],
    );
  }

  Widget _listMeters(
      String roomId, RoomProvider provider, bool hasSelectedMeters) {
    final db = Provider.of<LocalDatabase>(context);

    return FutureBuilder(
      future: db.roomDao.getMeterInRooms(roomId),
      builder: (context, meter) {
        final meterData = meter.data ?? [];

        if (meterData.length != provider.getMeterInRoomLength ||
            provider.getHasUpdate) {
          provider.setMeterInRoom(meterData);
          provider.setHasUpdate(false);
        }

        final meters = provider.getMeterInRoom;

        return ListView.builder(
          itemCount: meters.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final data = meters[index];

            return StreamBuilder(
              stream: db.entryDao.getNewestEntry(data.id!),
              builder: (context, snapshot) {
                final entry = snapshot.data;
                final DateTime? date;
                final String count;

                if (entry == null) {
                  date = null;
                  count = 'none';
                } else {
                  date = entry.date;
                  count = entry.count.toString();
                }

                return GestureDetector(
                  onLongPress: () {
                    provider.toggleSelectedMeters(data);
                  },
                  child: hasSelectedMeters
                      ? _meterCardWithoutSlide(
                          data: data,
                          date: date,
                          count: count,
                        )
                      : _meterCardWithSlide(
                          count: count,
                          data: data,
                          date: date,
                          db: db,
                          provider: provider,
                        ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _meterCardWithSlide({
    required LocalDatabase db,
    required RoomProvider provider,
    required MeterDto data,
    required DateTime? date,
    required String count,
  }) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              await db.roomDao.deleteMeter(data.id!);
              setState(() {
                _currentRoom.sumMeter = _currentRoom.sumMeter! - 1;
                provider.setMeterCount(_currentRoom.sumMeter!);
              });
            },
            icon: Icons.playlist_remove,
            label: 'Entfernen',
            foregroundColor: Colors.white,
            backgroundColor: CustomColors.red,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
        ],
      ),
      child: MeterCard(
        meter: data.toMeterData(),
        room: _currentRoom,
        date: date,
        count: count,
        isSelected: false,
        currentScreen: CurrentScreen.detailsRoom,
      ),
    );
  }

  Widget _meterCardWithoutSlide({
    required MeterDto data,
    required DateTime? date,
    required String count,
  }) {
    return MeterCard(
      meter: data.toMeterData(),
      room: _currentRoom,
      date: date,
      count: count,
      isSelected: data.isSelected,
      currentScreen: CurrentScreen.detailsRoom,
    );
  }

  Widget _dropDownMenu(BuildContext context) {
    bool hasFocus = _roomTypsFocus.hasFocus;

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IgnorePointer(
        ignoring: !_update,
        child: DropdownButtonFormField(
          focusNode: _roomTypsFocus,
          value: _roomTyp,
          isExpanded: true,
          decoration: InputDecoration(
            enabled: _update,
            label: const Text(
              'Zimmertyp',
            ),
            icon: const Icon(Icons.bedroom_parent_outlined),
            labelStyle: _update
                ? TextStyle(
                    color: Theme.of(context).inputDecorationTheme.focusColor)
                : TextStyle(color: Theme.of(context).indicatorColor),
            border: InputBorder.none,
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
