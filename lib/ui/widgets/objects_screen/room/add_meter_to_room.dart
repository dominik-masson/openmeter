import 'package:flutter/material.dart';
import 'package:openmeter/ui/widgets/tags/horizontal_tags_list.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/local_database.dart';
import '../../../../core/model/meter_with_room.dart';
import '../../../../core/model/room_dto.dart';
import '../../../../core/provider/room_provider.dart';
import '../../../../utils/meter_typ.dart';
import '../../meter/meter_circle_avatar.dart';

class AddMeterToRoom extends StatefulWidget {
  final RoomDto room;

  const AddMeterToRoom({
    super.key,
    required this.room,
  });

  @override
  State<AddMeterToRoom> createState() => _AddMeterToRoomState();
}

class _AddMeterToRoomState extends State<AddMeterToRoom> {
  final TextEditingController _searchController = TextEditingController();
  List<MeterWithRoom> _meters = [];
  late RoomDto room;

  final List<int> _selectedItemsWithoutExists = [];
  final List<int> _selectedItemsWithExists = [];

  String _searchText = '';
  List<MeterWithRoom> _searchMeters = [];

  @override
  void initState() {
    super.initState();
    room = widget.room;
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _selectedItemsWithoutExists.clear();
    _selectedItemsWithExists.clear();
  }

  _handleSelected(int meterId, bool isInARoom) {
    if (isInARoom == true) {
      if (_selectedItemsWithExists.contains(meterId)) {
        _selectedItemsWithExists.remove(meterId);
      } else {
        _selectedItemsWithExists.add(meterId);
      }
    } else {
      if (_selectedItemsWithoutExists.contains(meterId)) {
        _selectedItemsWithoutExists.remove(meterId);
      } else {
        _selectedItemsWithoutExists.add(meterId);
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context);
    final provider = Provider.of<RoomProvider>(context);

    provider.loadAllMeterWithRoom(db);

    _meters = provider.getAllMetersWithRoom;

    bool hasSelectedItems = false;

    if (_selectedItemsWithoutExists.isNotEmpty ||
        _selectedItemsWithExists.isNotEmpty) {
      hasSelectedItems = true;
    }

    if (_searchText.isNotEmpty) {
      _searchMeters = provider.searchForMeter(_searchText);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Zähler zuordnen'),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop([false, 0]);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 100,
        child: FloatingActionButton(
          onPressed: hasSelectedItems == true
              ? () {
                  provider
                      .saveSelectedMeters(
                        withRooms: _selectedItemsWithExists,
                        withOutRooms: _selectedItemsWithoutExists,
                        roomId: room.uuid,
                        db: db,
                        currentLength: room.sumMeter ?? 0,
                      )
                      .then(
                          (value) => Navigator.of(context).pop([true, value]));
                }
              : null,
          child: const Text('Fertig'),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop([false, 0]);
          return true;
        },
        child: Column(
          children: [
            _searchWidget(),
            const SizedBox(
              height: 10,
            ),
            _searchText.isNotEmpty ? _searchList(db) : _meterList(db),
          ],
        ),
      ),
    );
  }

  Widget _getSelectedIcon(
      {required bool isInCurrentRoom, required int meterId}) {
    if (isInCurrentRoom) {
      return const Icon(
        Icons.check_circle,
        color: Colors.grey,
      );
    }

    if (_selectedItemsWithExists.contains(meterId) ||
        _selectedItemsWithoutExists.contains(meterId)) {
      return Icon(
        Icons.check_circle,
        color: Theme.of(context).primaryColor,
      );
    }

    return const Icon(Icons.radio_button_unchecked);
  }

  Widget _meterCardCompact(LocalDatabase db, MeterWithRoom data) {
    final avatarData = meterTyps
        .firstWhere((element) => element.meterTyp == data.meter.typ)
        .avatar;

    bool isInCurrentRoom = false;
    bool isInARoom = false;

    final roomData = data.room;

    if (roomData != null && roomData.id == room.id) {
      isInCurrentRoom = true;
    }

    if (roomData != null && roomData.id != room.id) {
      isInARoom = true;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ListTile(
        onTap: isInCurrentRoom == true
            ? null
            : () => _handleSelected(data.meter.id, isInARoom),
        leading: MeterCircleAvatar(
          color: avatarData.color,
          icon: avatarData.icon,
        ),
        trailing: _getSelectedIcon(
            isInCurrentRoom: isInCurrentRoom, meterId: data.meter.id),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Text(
                      data.meter.number,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Zählernummer',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
                if (data.meter.note.isNotEmpty)
                  SizedBox(
                    width: 100,
                    child: Column(
                      children: [
                        Text(
                          data.meter.note,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Notiz',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            HorizontalTagsList(meterId: data.meter.id),
            if (isInARoom)
              Text(
                'Bereits im ${roomData?.name}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }

  Widget _meterList(LocalDatabase db) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.825,
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        itemCount: _meters.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              _meterCardCompact(db, _meters.elementAt(index)),
              if (index == _meters.length - 1)
                const SizedBox(
                  height: 50,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _searchList(LocalDatabase db) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.825,
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        itemCount: _searchMeters.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              _meterCardCompact(db, _searchMeters.elementAt(index)),
              if (index == _searchMeters.length - 1)
                const SizedBox(
                  height: 50,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _searchWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: SearchBar(
        controller: _searchController,
        padding: const MaterialStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 16.0),
        ),
        leading: const Icon(Icons.search),
        trailing: [
          if (_searchText.isNotEmpty)
            IconButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchText = '';
                });
              },
              icon: const Icon(Icons.clear),
            )
        ],
        hintText: 'Nummer oder Typ suchen',
        onChanged: (value) => setState(() {
          _searchText = value;
        }),
      ),
    );
  }
}
