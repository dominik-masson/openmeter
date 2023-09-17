import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/enums/tag_chip_state.dart';
import '../../../core/model/tag_dto.dart';
import '../../../core/provider/stats_provider.dart';
import '../tags/add_tags.dart';
import '../tags/tag_chip.dart';

class TagWidget extends StatefulWidget {
  const TagWidget({Key? key}) : super(key: key);

  @override
  State<TagWidget> createState() => _TagWidgetState();
}

class _TagWidgetState extends State<TagWidget> {
  final AddTags _addTags = AddTags();
  List<String> _tagsChecked = [];
  int _handleTags = 1;
  bool _emptyTags = false;
  bool _firstStart = true;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context);
    final statsProvider = Provider.of<StatsProvider>(context, listen: false);

    _handleTags = statsProvider.getHandleTags;
    _tagsChecked = statsProvider.getTagsIdList;

    return StreamBuilder(
      stream: db.tagsDao.watchAllTags(),
      builder: (context, snapshot) {
        final List<Tag> listTags = snapshot.data ?? [];

        if (listTags.isEmpty) {
          if (_firstStart) {
            _firstStart = false;
          }
          _emptyTags = true;
        } else {
          _emptyTags = false;
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ExpansionTile(
            title: const Text(
              'Tags',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: FaIcon(
              FontAwesomeIcons.tags,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
            tilePadding: const EdgeInsets.all(0),
            textColor: Theme.of(context).textTheme.bodyMedium!.color,
            iconColor: Theme.of(context).textTheme.bodyMedium!.color,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(0),

                title: const Text(
                  'Aktuelle Tags',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).indicatorColor,
                  ),
                  onPressed: () {
                    _addTags.getAddTags(context);
                  },
                ),
              ),
              SizedBox(
                height: 30,
                child: ListView.builder(
                  itemCount: listTags.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    Widget child = Container();

                    if (_tagsChecked.contains(listTags[index].id.toString())) {
                      child = TagChip(
                        tag: TagDto.fromData(listTags[index]),
                        state: TagChipState.checked,
                      );
                    } else {
                      child = TagChip(
                        tag: TagDto.fromData(listTags[index]),
                        state: TagChipState.simple,
                      );
                    }

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_tagsChecked.contains(listTags[index].id.toString())) {
                            _tagsChecked.remove(listTags[index].id.toString());
                          } else {
                            _tagsChecked.add(listTags[index].id.toString());
                          }
                        });

                        statsProvider.setTagsIdList(_tagsChecked);
                      },
                      child: Container(
                        padding: const EdgeInsets.only(right: 8),
                        width: 120,
                        child: child,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              if (!_emptyTags)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: DropdownButtonFormField(
                    value: _handleTags,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.calculate),
                      label: Text('Ausgewählte Tags sollen '),
                      border: InputBorder.none,
                    ),
                    isExpanded: true,
                    itemHeight: 60,
                    items: const [
                      DropdownMenuItem(
                          value: 1, child: Text('einberechnet werden')),
                      DropdownMenuItem(
                          value: 2, child: Text('nicht einberechnet werden')),
                    ],
                    onChanged: (int? value) {
                      _handleTags = value ?? 1;
                      statsProvider.setHandleTags(_handleTags);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
