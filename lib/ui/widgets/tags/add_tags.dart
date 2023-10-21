import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

import '../../../core/database/local_database.dart';
import '../../../core/provider/database_settings_provider.dart';

class AddTags {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _pickedIndex = 0;

  final List<Color> _listColors = const [
    Color(0xff344C11),
    Color(0xff828D00),
    Color(0xffAEC670),
    Color(0xff37745B),
    Color(0xff217074),
    Color(0xff2F70AF),
    Color(0xff00457E),
    Color(0xff02315E),
    Color(0xffD7A3B6),
    Color(0xff806491),
    Color(0xff54387F),
    Color(0xffFAAB01),
    Color(0xffE48716),
    Color(0xffF5704A),
    Color(0xffA9612B),
    Color(0xff432D2D),
    Color(0xffF46060),
    Color(0xffBC0000),
  ];

  AddTags();

  void dispose() {
    _nameController.dispose();
  }

  _saveTag(BuildContext context) async {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      final int pickedColor = _listColors[_pickedIndex].value;

      final tag = TagsCompanion(
          name: drift.Value(_nameController.text),
          color: drift.Value(pickedColor),
          uuid: drift.Value(const Uuid().v1()));

      await db.tagsDao.createTag(tag).then((value) {
        Provider.of<DatabaseSettingsProvider>(context, listen: false)
            .setHasUpdate(true);

        _nameController.clear();
        _pickedIndex = 0;

        Navigator.of(context).pop();
      });
    }
  }

  getAddTags(BuildContext context) {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Form(
              key: _formKey,
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  padding: const EdgeInsets.all(25),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Neuer Tag',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bitte gebe einen Namen ein!';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              icon: Icon(Icons.note), label: Text('Name')),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'Farbe wählen',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                          ),
                          shrinkWrap: true,
                          itemCount: _listColors.length,
                          itemBuilder: (context, index) {
                            Widget child = Container();

                            if (index == _pickedIndex) {
                              child = const Icon(
                                Icons.check,
                                color: Colors.white,
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.all(2),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _pickedIndex = index);
                                },
                                child: CircleAvatar(
                                  backgroundColor: _listColors[index],
                                  child: child,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: FloatingActionButton.extended(
                            onPressed: () => _saveTag(context),
                            label: const Text('Speichern'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
