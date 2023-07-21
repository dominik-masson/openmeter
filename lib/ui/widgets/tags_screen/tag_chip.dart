import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/enums/tag_chip_state.dart';
import '../../../core/provider/database_settings_provider.dart';

class TagChip extends StatelessWidget {
  final Tag tag;

  // final bool delete;
  // final bool checked;
  final TagChipState state;

  const TagChip({
    Key? key,
    required this.tag,
    required this.state,
    // required this.delete,
    // required this.checked,
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
                db.tagsDao.deleteTag(tag.uuid);
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
  }

  Widget _deleteTag(BuildContext context, LocalDatabase db) {
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
            onPressed: () => _deleteDialog(context, db),
            icon: Icon(
              Icons.cancel,
              color: Theme.of(context).hintColor,
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
