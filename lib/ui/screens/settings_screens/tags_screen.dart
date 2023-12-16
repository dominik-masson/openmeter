import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/enums/tag_chip_state.dart';
import '../../../core/model/tag_dto.dart';
import '../../../core/provider/small_feature_provider.dart';
import '../../widgets/tags/add_tags.dart';
import '../../widgets/tags/tag_chip.dart';

class TagsScreen extends StatefulWidget {
  const TagsScreen({
    super.key,
  });

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  final _addTags = AddTags();
  bool _showTags = true;

  @override
  void dispose() {
    _addTags.dispose();
    super.dispose();
  }

  Widget _noTags() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          children: [
            Text(
              'Es sind keine Tags vorhanden!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Text(
              'Drücke jetzt auf das + um einen neuen Tag zu erstellen!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context);
    final smallProvider =
        Provider.of<SmallFeatureProvider>(context, listen: false);

    _showTags = smallProvider.getShowTags;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Tags'),
        actions: [
          IconButton(
            onPressed: () {
              _addTags.getAddTags(context);
            },
            icon: const Icon(Icons.add),
            tooltip: 'Tag erstellen',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/icons/tag.png',
                  width: 200,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              SwitchListTile(
                title: const Text('Tags anzeigen'),
                subtitle: const Text(
                    'Ermöglicht das anzeigen eines Tags auf der Startseite.'),
                secondary: _showTags
                    ? FaIcon(
                        FontAwesomeIcons.eye,
                        color: Theme.of(context).indicatorColor,
                      )
                    : FaIcon(
                        FontAwesomeIcons.eyeSlash,
                        color: Theme.of(context).indicatorColor,
                      ),
                value: _showTags,
                onChanged: (value) {
                  setState(() {
                    _showTags = value;
                  });
                  smallProvider.setShowTags(_showTags);
                },
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                'Aktuelle Tags:',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              StreamBuilder(
                stream: db.tagsDao.watchAllTags(),
                builder: (context, snapshot) {
                  final List<Tag> tags = snapshot.data ?? [];

                  if (tags.isEmpty) {
                    return _noTags();
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: MediaQuery.of(context).size.width /
                          (MediaQuery.of(context).size.height / 4),
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: tags.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: TagChip(
                          tag: TagDto.fromData(tags[index]),
                          state: TagChipState.delete,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
