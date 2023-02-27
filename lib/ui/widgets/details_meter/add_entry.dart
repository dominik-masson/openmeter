import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/database/local_database.dart';
import '../../../core/provider/small_feature_provider.dart';
import '../../../core/services/torch_controller.dart';

class AddEntry {
  final TextEditingController _datecontroller = TextEditingController();
  final TextEditingController _countercontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate = DateTime.now();

  final MeterData meter;
  final String countString;

  final TorchController _torchController = TorchController();
  bool _stateTorch = false;

  AddEntry({required this.meter, required this.countString});

  void dispose() {
    _datecontroller.dispose();
    _countercontroller.dispose();
  }

  void _showDatePicker(BuildContext context) async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 10),
      lastDate: DateTime.now(),
      locale: const Locale('de', ''),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }

      _selectedDate = pickedDate;
      _datecontroller.text = DateFormat('dd.MM.yyyy').format(_selectedDate!);
    });
  }

  _saveEntry(BuildContext context, SmallFeatureProvider torchProvider) async {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      final entry = EntriesCompanion(
        meter: drift.Value(meter.id),
        date: drift.Value(_selectedDate!),
        count: drift.Value(int.parse(_countercontroller.text)),
        usage: drift.Value(_calcUsage()),
      );

      await db.entryDao.createEntry(entry).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eintrag wird hinzugefügt!'),
          ),
        );

        if (_torchController.stateTorch && torchProvider.stateTorch) {
          _torchController.getTorch();
          _stateTorch = false;
        }

        Navigator.pop(context, true);
        _countercontroller.clear();
        _selectedDate = DateTime.now();
      });
    }
  }

  _calcUsage() {
    final int count;

    if (countString == 'none') {
      count = 0;
    } else {
      count = int.parse(countString);
    }

    final countController = int.parse(_countercontroller.text);

    return countController - count;
  }

  showBottomModel(BuildContext context) {
    final torchProvider =
        Provider.of<SmallFeatureProvider>(context, listen: false);

    if (torchProvider.stateTorch && !_torchController.stateTorch) {
      _torchController.getTorch();
      _stateTorch = true;
    }

    bool isTorchOn = _torchController.stateTorch;

    return showModalBottomSheet(
      backgroundColor: Theme.of(context).bottomAppBarTheme.color,
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
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                height: 400,
                padding: const EdgeInsets.all(25),
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Neuer Zählerstand',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isTorchOn = !isTorchOn;
                                  });
                                  _torchController.getTorch();
                                },
                                icon: isTorchOn
                                    ? const Icon(
                                        Icons.flashlight_on,
                                        // color: darkMode
                                        //     ? Colors.white
                                        //     : Colors.black,
                                      )
                                    : const Icon(
                                        Icons.flashlight_off,
                                        // color: darkMode ? Colors.white : Colors.black,
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            readOnly: true,
                            textInputAction: TextInputAction.next,
                            controller: _datecontroller
                              ..text = _selectedDate != null
                                  ? DateFormat('dd.MM.yyyy')
                                      .format(_selectedDate!)
                                  : '',
                            onTap: () => _showDatePicker(context),
                            decoration: const InputDecoration(
                                icon: Icon(Icons.date_range),
                                label: Text('Datum')),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Bitte geben sie den Zählerstand an!';
                              }
                              if (int.parse(value) < 0) {
                                return 'Bitte gebe eine positive Zahl an!';
                              }
                              return null;
                            },
                            controller: _countercontroller,
                            decoration: const InputDecoration(
                                icon: Icon(Icons.onetwothree),
                                label: Text('Zählerstand')),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _saveEntry(context, torchProvider),
                                icon: const Icon(Icons.check),
                                label: const Text('Speichern'),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((value) {
      if (_torchController.stateTorch && _stateTorch) {
        _torchController.getTorch();
      }
    });
  }
}
