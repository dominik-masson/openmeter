import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/provider/cost_provider.dart';
import '../../../core/provider/database_settings_provider.dart';
import '../../../core/provider/entry_card_provider.dart';
import '../../../core/provider/small_feature_provider.dart';
import '../../../core/provider/sort_provider.dart';
import '../../../utils/convert_meter_unit.dart';
import '../../screens/details_single_meter.dart';
import '../../../utils/meter_typ.dart';
import '../tags_screen/tag_chip.dart';

class MeterCard {
  MeterCard();

  Future<bool> _deleteMeter(
      BuildContext context, int meterId, RoomData? room) async {
    final db = Provider.of<LocalDatabase>(context, listen: false);
    final autoBackUp =
        Provider.of<DatabaseSettingsProvider>(context, listen: false);

    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Löschen?'),
            content: const Text('Möchten Sie diesen Zähler wirklich löschen?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () {
                  if (room != null) {
                    db.roomDao.deleteMeter(meterId);
                  }

                  db.meterDao.deleteMeter(meterId);

                  autoBackUp.setHasUpdate(true);
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'Löschen',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget getCard({
    required BuildContext context,
    required MeterData meter,
    RoomData? room,
    required DateTime? date,
    required String count,
    required List<String> tags,
  }) {
    final db = Provider.of<LocalDatabase>(context, listen: false);
    final sortProvider = Provider.of<SortProvider>(context);
    final smallProvider = Provider.of<SmallFeatureProvider>(context);

    String roomName = room == null ? '' : room.name;

    final entryProvider =
        Provider.of<EntryCardProvider>(context, listen: false);

    String dateText = 'none';

    if (date != null) {
      dateText = DateFormat('dd.MM.yyyy').format(date);
    }

    return Dismissible(
      key: Key('${meter.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _deleteMeter(context, meter.id, room);
      },
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.all(50),
        decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          entryProvider.setCurrentCount(count);
          entryProvider.setOldDate(date ?? DateTime.now());
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                entryProvider.setMeterUnit(meter.unit);

                return DetailsSingleMeter(
                  meter: meter,
                  room: room,
                  tagsId: tags,
                );
              },
            ),
          ).then((value) {
            Provider.of<CostProvider>(context, listen: false).resetValues();
            entryProvider.removeAllSelectedEntries();
            room = value as RoomData?;
          });
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4),
          child: Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          meterTyps[meter.typ]['avatar'] as Widget,
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            meter.typ,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      if (sortProvider.getSort == 'meter')
                        Text(
                          roomName,
                          style: const TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            meter.number,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Text(
                            "Zählernummer",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        children: [
                          ConvertMeterUnit().getUnitWidget(
                            count: count,
                            unit: meter.unit,
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          const Text(
                            "Zählerstand",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Flexible(
                        child: Text(
                          meter.note.toString(),
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (tags.isNotEmpty && smallProvider.getShowTags)
                    Container(
                      alignment: Alignment.centerLeft,
                      height: 30,
                      child: ListView.builder(
                        itemCount: tags.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => FutureBuilder(
                            future:
                                db.tagsDao.getSingleTag(int.parse(tags[index])),
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: SizedBox(
                                    width: 70,
                                    child: TagChip(
                                      tag: snapshot.data!,
                                      checked: false,
                                      delete: false,
                                    ),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            }),
                      ),
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'zuletzt geändert: $dateText',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
