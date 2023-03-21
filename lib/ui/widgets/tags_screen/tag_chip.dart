import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';

class TagChip extends StatelessWidget {
  final Tag tag;
  final bool delete;
  final bool checked;

  const TagChip({
    Key? key,
    required this.tag,
    required this.delete,
    required this.checked,
  }) : super(key: key);

  void _deleteTag(LocalDatabase db, List<MeterData> meterList) {
    for (MeterData meter in meterList) {
      String oldIds = meter.tag!;
      List<String> oldIdsList = oldIds.split(';');
      oldIdsList.removeWhere((element) => element.contains(tag.id.toString()));
      String? newIds = oldIdsList.join(';');

      if (newIds.isEmpty) {
        newIds = null;
      }

      MeterData newMeter = MeterData(
          id: meter.id,
          typ: meter.typ,
          note: meter.note,
          number: meter.number,
          unit: meter.unit,
          tag: newIds);
      db.meterDao.updateMeter(newMeter);
    }

    db.tagsDao.deleteTag(tag.id);
  }

  Future _deleteDialog(BuildContext context, List<MeterData> meterList) {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Löschen?'),
          content: const Text('Möchten Sie den Tag wirklich löschen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                _deleteTag(db, meterList);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Löschen',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    return FutureBuilder(
      future: db.meterDao.getMeterByTag(tag.id.toString()),
      builder: (context, snapshot) {
        final List<MeterData> meterList = snapshot.data ?? [];

        if (delete) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(tag.color),
                width: 3,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tag.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                IconButton(
                  onPressed: () => _deleteDialog(context, meterList),
                  icon: Icon(
                    Icons.cancel,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          );
        } else {
          if (checked) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(tag.color),
                  width: 3,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    tag.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container(
              width: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(tag.color),
                  width: 2.5,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tag.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }
        }
      },
    );

    //   if (delete) {
    //     return Chip(
    //       label: Text(tag.name),
    //       backgroundColor: Color(tag.color),
    //       onDeleted: () => _deleteDialog(context),
    //     );
    //   } else {
    //     if (checked) {
    //       return Chip(
    //         label: Text(tag.name),
    //         backgroundColor: Color(tag.color),
    //         avatar: const Icon(
    //           Icons.check,
    //           color: Colors.white,
    //         ),
    //       );
    //     } else {
    //       return Chip(
    //         label: Text(tag.name),
    //         backgroundColor: Color(tag.color),
    //       );
    //     }
    //   }
  }
}
