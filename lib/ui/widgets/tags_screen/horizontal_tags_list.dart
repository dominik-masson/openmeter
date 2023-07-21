import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/enums/tag_chip_state.dart';
import 'tag_chip.dart';

class HorizontalTagsList extends StatelessWidget {
  final int meterId;
  final Function(bool)? setHasTags;
  final Function(List<Tag>)? setTags;

  const HorizontalTagsList(
      {super.key, required this.meterId, this.setHasTags, this.setTags});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context);

    return StreamBuilder(
      stream: db.tagsDao.watchTagsForMeter(meterId),
      builder: (context, snapshot) {
        final tags = snapshot.data ?? [];

        if (tags.isEmpty) {
          return Container();
        }

        if (setHasTags != null) {
          setHasTags!(true);
        }

        if(setTags != null){
          setTags!(tags);
        }

        return Container(
          alignment: Alignment.centerLeft,
          height: 30,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final Tag tag = tags.elementAt(index);

              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: 70,
                  child: TagChip(
                    tag: tag,
                    state: TagChipState.simple,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
