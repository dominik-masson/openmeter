import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openmeter/utils/convert_count.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/database/local_database.dart';
import '../../../core/provider/database_settings_provider.dart';
import '../../../core/provider/entry_card_provider.dart';
import '../../../core/provider/torch_provider.dart';
import '../../../core/services/torch_controller.dart';

class AddEntry {
  final TextEditingController _datecontroller = TextEditingController();
  final TextEditingController _countercontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate = DateTime.now();

  final MeterData meter;

  final TorchController _torchController = TorchController();
  bool _stateTorch = false;

  AddEntry({required this.meter});

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

  _saveEntry(BuildContext context, TorchProvider torchProvider,
      EntryCardProvider entryProvider) async {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    String currentCount = entryProvider.getCurrentCount;
    DateTime oldDate = entryProvider.getOldDate;

    if (_formKey.currentState!.validate()) {
      final entry = EntriesCompanion(
        meter: drift.Value(meter.id),
        date: drift.Value(_selectedDate!),
        count: drift.Value(int.parse(_countercontroller.text)),
        usage: drift.Value(_calcUsage(currentCount)),
        days: drift.Value(_calcDays(_selectedDate!, oldDate)),
      );

      Provider.of<DatabaseSettingsProvider>(context, listen: false)
          .setHasUpdate(true);

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

        entryProvider.setCurrentCount(_countercontroller.text);
        entryProvider.setOldDate(_selectedDate!);
        Navigator.pop(context, true);
        _countercontroller.clear();
        _selectedDate = DateTime.now();
      });
    }
  }

  int _calcUsage(String currentCount) {
    int count = 0;

    if (currentCount == 'none') {
      return -1;
    } else {
      count = ConvertCount.convertString(currentCount);
    }

    final countController = int.parse(_countercontroller.text);

    return countController - count;
  }

  int _calcDays(DateTime newDate, DateTime oldDate) {
    return newDate.difference(oldDate).inDays;
  }

  showBottomModel(
    BuildContext context,
    EntryCardProvider entryProvider,
  ) {
    final torchProvider = Provider.of<TorchProvider>(context, listen: false);

    _torchController.setStateTorch(torchProvider.getStateIsTorchOn);

    bool isTorchOn = _torchController.stateTorch;

    if (torchProvider.stateTorch && !_torchController.stateTorch) {
      _torchController.getTorch();
      _stateTorch = true;
      isTorchOn = true;
    }

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
                                onPressed: () async {
                                  await _torchController.getTorch();
                                  setState(() {
                                    isTorchOn = !isTorchOn;
                                    torchProvider.setIsTorchOn(isTorchOn);
                                  });
                                },
                                icon: isTorchOn
                                    ? const Icon(
                                        Icons.flashlight_on,
                                      )
                                    : const Icon(
                                        Icons.flashlight_off,
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
                                onPressed: () => _saveEntry(
                                    context, torchProvider, entryProvider),
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
