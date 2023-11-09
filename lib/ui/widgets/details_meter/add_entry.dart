import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/database/local_database.dart';
import '../../../core/provider/database_settings_provider.dart';
import '../../../core/provider/entry_card_provider.dart';
import '../../../core/provider/torch_provider.dart';
import '../../../core/services/torch_controller.dart';
import '../../../utils/convert_count.dart';

class AddEntry extends StatefulWidget {
  final MeterData meter;

  const AddEntry({super.key, required this.meter});

  @override
  State<AddEntry> createState() => _AddEntryState();
}

class _AddEntryState extends State<AddEntry> {
  final TextEditingController _datecontroller = TextEditingController();
  final TextEditingController _countercontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate = DateTime.now();

  final TorchController _torchController = TorchController();
  bool _stateTorch = false;
  bool _isReset = false;
  bool _isTransmitted = false;

  @override
  void dispose() {
    super.dispose();
    _datecontroller.dispose();
    _countercontroller.dispose();
  }

  void _showDatePicker() async {
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

  _saveEntry(
      TorchProvider torchProvider, EntryCardProvider entryProvider) async {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    String currentCount = entryProvider.getCurrentCount;
    DateTime oldDate = entryProvider.getOldDate;

    if (_formKey.currentState!.validate()) {
      late EntriesCompanion entry;

      if (_isReset) {
        int count = 0;

        if (_countercontroller.text.isNotEmpty) {
          count = int.parse(_countercontroller.text);
        }

        entry = EntriesCompanion(
          meter: drift.Value(widget.meter.id),
          date: drift.Value(_selectedDate!),
          count: drift.Value(count),
          usage: const drift.Value(-1),
          days: const drift.Value(-1),
          isReset: const drift.Value(true),
          transmittedToProvider: drift.Value(_isTransmitted),
        );
      } else {
        entry = EntriesCompanion(
          meter: drift.Value(widget.meter.id),
          date: drift.Value(_selectedDate!),
          count: drift.Value(int.parse(_countercontroller.text)),
          usage: drift.Value(_calcUsage(currentCount)),
          days: drift.Value(_calcDays(_selectedDate!, oldDate)),
          transmittedToProvider: drift.Value(_isTransmitted),
        );
      }

      Provider.of<DatabaseSettingsProvider>(context, listen: false)
          .setHasUpdate(true);

      await db.entryDao.createEntry(entry).then((value) {
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

  _showBottomModel(
    EntryCardProvider entryProvider,
    TorchProvider torchProvider,
  ) {
    _torchController.setStateTorch(torchProvider.getStateIsTorchOn);

    bool isTorchOn = _torchController.stateTorch;

    if (torchProvider.stateTorch && !_torchController.stateTorch) {
      _torchController.getTorch();
      _stateTorch = true;
      isTorchOn = true;
    }

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
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                height: 450,
                padding: const EdgeInsets.only(left: 25, right: 25),
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
                              Text(
                                'Neuer Zählerstand',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(
                                        () {
                                          _isReset = !_isReset;
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.restart_alt,
                                      color: _isReset
                                          ? Theme.of(context).primaryColor
                                          : null,
                                    ),
                                    tooltip: 'Zähler zurücksetzen',
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      bool torch =
                                          await _torchController.getTorch();
                                      setState(() {
                                        if (torch) {
                                          isTorchOn = !isTorchOn;
                                          torchProvider.setIsTorchOn(isTorchOn);
                                        }
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
                            onTap: () => _showDatePicker(),
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
                              if ((value == null || value.isEmpty) &&
                                  !_isReset) {
                                return 'Bitte geben sie den Zählerstand an!';
                              }
                              if (value == null ||
                                  (value.isNotEmpty && int.parse(value) < 0)) {
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
                            height: 20,
                          ),
                          SwitchListTile(
                            value: _isTransmitted,
                            onChanged: (value) {
                              setState(
                                () => _isTransmitted = value,
                              );
                            },
                            title: const Text('An Anbieter gemeldet'),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: FloatingActionButton.extended(
                              onPressed: () =>
                                  _saveEntry(torchProvider, entryProvider),
                              label: const Text('Speichern'),
                            ),
                          ),
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

      _resetFields();
    });
  }

  _resetFields() {
    _isReset = false;
    _selectedDate = DateTime.now();
    _countercontroller.clear();
    _stateTorch = false;
    _isTransmitted = false;
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryCardProvider>(context);
    final torchProvider = Provider.of<TorchProvider>(context);

    return IconButton(
      onPressed: () {
        _showBottomModel(entryProvider, torchProvider);
      },
      icon: const Icon(Icons.add),
      tooltip: 'Eintrag erstellen',
    );
  }
}
