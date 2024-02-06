import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/database/local_database.dart';
import '../../../../core/model/entry_dto.dart';
import '../../../../core/model/meter_dto.dart';
import '../../../../core/provider/database_settings_provider.dart';
import '../../../../core/provider/entry_provider.dart';
import '../../../../core/provider/torch_provider.dart';
import '../../../../core/helper/meter_image_helper.dart';
import '../../../../core/helper/torch_controller.dart';
import '../../../../utils/convert_count.dart';
import '../../../../utils/custom_icons.dart';

class AddEntry extends StatefulWidget {
  final MeterDto meter;

  const AddEntry({super.key, required this.meter});

  @override
  State<AddEntry> createState() => _AddEntryState();
}

class _AddEntryState extends State<AddEntry> {
  final MeterImageHelper _imageHelper = MeterImageHelper();

  final _formKey = GlobalKey<FormState>();
  final FocusNode _countFocus = FocusNode();

  final _iconKey = GlobalKey();

  final TextEditingController _datecontroller = TextEditingController();
  final TextEditingController _countercontroller = TextEditingController();
  final TorchController _torchController = TorchController();
  final PageController _pageController = PageController();

  DateTime? _selectedDate = DateTime.now();
  bool _stateTorch = false;
  bool _isReset = false;
  bool _isTransmitted = false;

  int _selectedWidgetView = 0;
  String? _imagePath;
  bool _saved = false;

  @override
  void dispose() {
    super.dispose();
    _datecontroller.dispose();
    _countercontroller.dispose();
    _countFocus.dispose();
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

  _saveEntry(TorchProvider torchProvider, EntryProvider entryProvider) async {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    EntryDto? newestEntry = entryProvider.getNewestEntry;

    String currentCount = 'none';
    DateTime? oldDate;

    if (newestEntry != null) {
      currentCount = newestEntry.count.toString();
      oldDate = newestEntry.date;
    }

    if (_formKey.currentState!.validate()) {
      late EntriesCompanion entry;

      if (oldDate != null && _selectedDate!.isBefore(oldDate)) {
        int count = int.parse(_countercontroller.text);
        String usageCount = '0';
        DateTime date = DateTime.now();

        final prevEntry = entryProvider.getPrevEntry(_selectedDate!);

        if (prevEntry != null) {
          usageCount = prevEntry.count.toString();
          date = prevEntry.date;
        } else {
          usageCount = 'none';
          date = _selectedDate!;
        }

        entry = EntriesCompanion(
          meter: drift.Value(widget.meter.id!),
          date: drift.Value(_selectedDate!),
          count: drift.Value(count),
          usage: drift.Value(_isReset ? -1 : _calcUsage(usageCount)),
          days: drift.Value(_isReset ? -1 : _calcDays(_selectedDate!, date)),
          isReset: drift.Value(_isReset),
          transmittedToProvider: drift.Value(_isTransmitted),
          imagePath: drift.Value(_imagePath),
        );

        await entryProvider.saveNewMiddleEntry(
            EntryDto.fromEntriesCompanion(entry), db);
      } else {
        entry = EntriesCompanion(
          meter: drift.Value(widget.meter.id!),
          date: drift.Value(_selectedDate!),
          count: drift.Value(_countercontroller.text.isEmpty
              ? 0
              : int.parse(_countercontroller.text)),
          usage: drift.Value(_isReset ? -1 : _calcUsage(currentCount)),
          days: drift.Value(_isReset || oldDate == null
              ? -1
              : _calcDays(_selectedDate!, oldDate)),
          isReset: drift.Value(_isReset),
          transmittedToProvider: drift.Value(_isTransmitted),
          imagePath: drift.Value(_imagePath),
        );

        entryProvider.setCurrentCount(_countercontroller.text);
        entryProvider.setOldDate(_selectedDate!);
      }

      await db.entryDao.createEntry(entry).then((value) {
        if (_torchController.stateTorch && torchProvider.stateTorch) {
          _torchController.getTorch();
          _stateTorch = false;
        }

        _saved = true;

        Provider.of<DatabaseSettingsProvider>(context, listen: false)
            .setHasUpdate(true);

        entryProvider.setHasEntries(true);

        Navigator.pop(context, true);

        _countercontroller.clear();
        _selectedDate = DateTime.now();
      });
    }
  }

  _switchTiles(Function setState) {
    return Column(
      children: [
        SwitchListTile(
          value: _isTransmitted,
          onChanged: (value) {
            setState(
              () => _isTransmitted = value,
            );
          },
          title: const Text('An Anbieter gemeldet'),
        ),
        SwitchListTile(
          value: _isReset,
          onChanged: (value) {
            setState(
              () => _isReset = value,
            );
          },
          title: const Text('Zähler zurücksetzen'),
        ),
      ],
    );
  }

  _showAddImagePopupMenu(Offset offset, Function setState) {
    final databaseSettingsProvider =
        Provider.of<DatabaseSettingsProvider>(context, listen: false);

    double left = offset.dx;
    double top = offset.dy; // MediaQuery.sizeOf(context).height * 0.44;

    return showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(
                Icons.camera_alt,
                size: 20,
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                'Bild aufnehmen',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          onTap: () async {
            databaseSettingsProvider.toggleInAppActionState();

            String? imagePath =
                await _imageHelper.selectAndSaveImage(ImageSource.camera);

            databaseSettingsProvider.toggleInAppActionState();

            setState(() {
              _imagePath = imagePath;

              if (_imagePath != null) {
                _selectedWidgetView = 1;
                _pageController.nextPage(
                    duration: Durations.short1, curve: Curves.linear);
              }
            });
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(
                Icons.photo_library,
                size: 20,
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                'Bild aus der Galerie wählen',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          onTap: () async {
            databaseSettingsProvider.toggleInAppActionState();

            String? imagePath =
                await _imageHelper.selectAndSaveImage(ImageSource.gallery);

            databaseSettingsProvider.toggleInAppActionState();

            setState(() {
              _imagePath = imagePath;

              if (_imagePath != null) {
                _selectedWidgetView = 1;
                _pageController.nextPage(
                    duration: Durations.short1, curve: Curves.linear);
              }
            });
          },
        ),
        if (_imagePath != null)
          PopupMenuItem(
            child: Row(
              children: [
                const Icon(
                  Icons.delete,
                  size: 20,
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  'Bild löschen',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            onTap: () async {
              await _imageHelper.deleteImage(_imagePath!);
              setState(() {
                _imagePath = null;
                _selectedWidgetView = 0;
              });
            },
          ),
      ],
    );
  }

  _topBar(
    TorchProvider torchProvider,
    Function setState,
  ) {
    bool isTorchOn = _torchController.stateTorch;

    if (torchProvider.stateTorch && !_torchController.stateTorch) {
      _torchController.getTorch();
      _stateTorch = true;
      isTorchOn = true;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Neuer Zählerstand',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Row(
          children: [
            IconButton(
              onPressed: () async {
                bool torch = await _torchController.getTorch();
                setState(() {
                  if (torch) {
                    isTorchOn = !isTorchOn;
                    torchProvider.setIsTorchOn(isTorchOn);
                  }
                });
              },
              tooltip: isTorchOn
                  ? 'Schalte die Taschenlampe aus'
                  : 'Schalte die Taschenlampe an',
              icon: isTorchOn
                  ? const Icon(
                      Icons.flashlight_on,
                    )
                  : const Icon(
                      Icons.flashlight_off,
                    ),
            ),
            IconButton(
              key: _iconKey,
              tooltip: _imagePath == null
                  ? 'Füge ein Bild hinzu'
                  : 'Füge ein neues Bild hinzu oder lösche das aktuelle',
              icon: _imagePath == null
                  ? const Icon(
                      CustomIcons.photoadd,
                      size: 26,
                    )
                  : const Icon(
                      CustomIcons.photoedit,
                      size: 26,
                    ),
              onPressed: () async {
                if (_countFocus.hasFocus) {
                  _countFocus.unfocus();
                  await Future.delayed(const Duration(milliseconds: 250));
                }

                RenderBox renderBox =
                    _iconKey.currentContext?.findRenderObject() as RenderBox;

                Offset offset = renderBox.localToGlobal(Offset.zero);

                _showAddImagePopupMenu(offset, setState);
              },
            ),
          ],
        ),
      ],
    );
  }

  _addView(Function setState) {
    return Column(
      children: [
        TextFormField(
          readOnly: true,
          textInputAction: TextInputAction.next,
          controller: _datecontroller
            ..text = _selectedDate != null
                ? DateFormat('dd.MM.yyyy').format(_selectedDate!)
                : '',
          onTap: () => _showDatePicker(),
          decoration: const InputDecoration(
              icon: Icon(Icons.date_range), label: Text('Datum')),
        ),
        const SizedBox(
          height: 10,
        ),
        TextFormField(
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null) {
                return 'Bitte geben sie den Zählerstand an!';
              }
              if (value.isEmpty && !_isReset) {
                return 'Bitte geben sie den Zählerstand an!';
              }
              if (value.contains(',') || value.contains('.')) {
                return 'Bitte nutze keine Sonderzeichen!';
              }
              if (value.isNotEmpty && int.parse(value) < 0) {
                return 'Bitte gebe eine positive Zahl an!';
              }

              return null;
            },
            controller: _countercontroller,
            focusNode: _countFocus,
            decoration: const InputDecoration(
              icon: Icon(Icons.onetwothree),
              label: Text('Zählerstand'),
            )),
        const SizedBox(
          height: 20,
        ),
        const Divider(),
        _switchTiles(setState),
      ],
    );
  }

  _imageView() {
    return Image.file(
      File(_imagePath!),
      height: 150,
    );
  }

  _mainView(Function setState) {
    return Column(
      children: [
        SizedBox(
          height: 325,
          child: PageView(
            controller: _pageController,
            onPageChanged: (value) {
              setState(() => _selectedWidgetView = value);
            },
            children: [
              _addView(setState),
              if (_imagePath != null) _imageView(),
            ],
          ),
        ),
        if (_imagePath != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: AnimatedSmoothIndicator(
              activeIndex: _selectedWidgetView,
              count: 2,
              effect: WormEffect(
                activeDotColor: Theme.of(context).primaryColor,
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),
          ),
      ],
    );
  }

  _showBottomModel(
    EntryProvider entryProvider,
    TorchProvider torchProvider,
  ) {
    _torchController.setStateTorch(torchProvider.getStateIsTorchOn);

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
                height: 500,
                padding: const EdgeInsets.only(left: 25, right: 25),
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _topBar(torchProvider, setState),
                          const SizedBox(
                            height: 15,
                          ),
                          _mainView(setState),
                          const SizedBox(
                            height: 20,
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

  _resetFields() async {
    _isReset = false;
    _selectedDate = DateTime.now();
    _countercontroller.clear();
    _stateTorch = false;
    _isTransmitted = false;
    _selectedWidgetView = 0;

    if (_imagePath != null && !_saved) {
      await _imageHelper.deleteImage(_imagePath!);
    }

    _imagePath = null;
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);
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
