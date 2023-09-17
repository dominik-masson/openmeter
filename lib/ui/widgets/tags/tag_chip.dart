import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/enums/tag_chip_state.dart';
import '../../../core/model/tag_dto.dart';
import '../../../core/provider/database_settings_provider.dart';

class TagChip extends StatelessWidget {
  final TagDto tag;

  final TagChipState state;

  const TagChip({
    Key? key,
    required this.tag,
    required this.state,
  }) : super(key: key);

  Future _deleteDialog(BuildContext context, LocalDatabase db) {
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
                db.tagsDao.deleteTag(tag.uuid!);
                Provider.of<DatabaseSettingsProvider>(context, listen: false)
                    .setHasUpdate(true);
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

  Widget _checkedTag(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(tag.color),
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check,
            color: Colors.white,
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            tag.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deleteTag(BuildContext context, LocalDatabase db) {
    return Container(
      decoration: BoxDecoration(
        color: Color(tag.color),
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              tag.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _deleteDialog(context, db),
            icon: const Icon(
              Icons.cancel,
              color: Colors.white,
            ),
            tooltip: 'Tag löschen',
          ),
        ],
      ),
    );
  }

  Widget _simpleTag() {
    return Container(
      decoration: BoxDecoration(
        color: Color(tag.color),
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            tag.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    switch (state) {
      case TagChipState.delete:
        return _deleteTag(context, db);
      case TagChipState.checked:
        return _checkedTag(context);
      default:
        return _simpleTag();
    }
  }
}
