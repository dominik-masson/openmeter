import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:drift/drift.dart' as drift;

import '../../../../core/database/local_database.dart';
import '../../../../core/model/entry_dto.dart';
import '../../../../core/provider/cost_provider.dart';
import '../../../../core/provider/database_settings_provider.dart';
import '../../../../core/provider/entry_card_provider.dart';
import '../../../../core/services/meter_image_helper.dart';
import '../../../../utils/convert_count.dart';
import '../../../../utils/convert_meter_unit.dart';
import '../../../../utils/custom_icons.dart';
import '../../../screens/entry/image_view.dart';

class DetailsEntry extends StatefulWidget {
  final EntryDto entry;

  const DetailsEntry({
    super.key,
    required this.entry,
  });

  @override
  State<DetailsEntry> createState() => _DetailsEntryState();
}

class _DetailsEntryState extends State<DetailsEntry> {
  final MeterImageHelper _meterImageHelper = MeterImageHelper();
  final ConvertMeterUnit convertMeterUnit = ConvertMeterUnit();

  late EntryDto _entry;
  late EntryCardProvider _entryProvider;

  final GlobalKey _iconKey = GlobalKey();

  final FocusNode _noteFocus = FocusNode();

  final TextEditingController _noteController = TextEditingController();
  final PageController _pageController = PageController();

  String? _imagePath;
  int _selectedView = 0;

  @override
  initState() {
    super.initState();
    _entry = widget.entry;
    _imagePath = _entry.imagePath;
  }

  @override
  void dispose() {
    super.dispose();

    _noteController.dispose();
    _pageController.dispose();
    _noteFocus.dispose();
  }

  _saveNote(EntryCardProvider entryProvider) async {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    final newEntry = EntriesCompanion(
      id: drift.Value(_entry.id!),
      days: drift.Value(_entry.days),
      count: drift.Value(_entry.count),
      usage: drift.Value(_entry.usage),
      meter: drift.Value(_entry.meterId!),
      date: drift.Value(_entry.date),
      note: drift.Value(_noteController.text),
      transmittedToProvider: drift.Value(_entry.transmittedToProvider),
      isReset: drift.Value(_entry.isReset),
    );

    await db.entryDao.replaceEntry(newEntry);

    if (context.mounted) {
      Provider.of<DatabaseSettingsProvider>(context, listen: false)
          .setHasUpdate(true);
    }
  }

  _noteWidget() {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        TextFormField(
          controller: _noteController,
          focusNode: _noteFocus,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: const InputDecoration(
            icon: Icon(Icons.notes),
            hintText: 'Füge eine Notiz hinzu',
            border: InputBorder.none,
          ),
        ),
      ],
    );
  }

  _transmittedToProvider() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(top: 25),
      child: Row(
        children: [
          const Icon(
            Icons.upload_file_rounded,
            color: Colors.grey,
          ),
          const SizedBox(
            width: 15,
          ),
          SizedBox(
            width: 230,
            child: Text(
              'Dieser Wert wurde an den Anbieter übermittelt.',
              overflow: TextOverflow.visible,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  _extraInformation(String text) {
    return Column(
      children: [
        Center(
          child: Text(text, style: Theme.of(context).textTheme.labelLarge!),
        ),
        _noteWidget(),
      ],
    );
  }

  _contractWidget({
    required int usage,
    required String unit,
    required CostProvider costProvider,
  }) {
    double usageCost = costProvider.calcUsage(usage);
    double dailyCost = usageCost / _entry.days;

    final String local = Platform.localeName;
    final costFormat = NumberFormat.simpleCurrency(locale: local);

    return Column(
      children: [
        // full days
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                convertMeterUnit.getUnitWidget(
                  count: '+${ConvertCount.convertCount(usage)}',
                  unit: unit,
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: _entryProvider.getColors(
                          _entry.count,
                          usage,
                        ),
                      ),
                ),
                Text(
                  costFormat.format(usageCost),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            Text(
              'innerhalb ${_entry.days} Tagen',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),

        // Daily
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                convertMeterUnit.getUnitWidget(
                  count: _entryProvider.getDailyUsage(usage, _entry.days),
                  unit: unit,
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: _entryProvider.getColors(
                          _entry.count,
                          usage,
                        ),
                      ),
                ),
                Text(
                  costFormat.format(dailyCost),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            Text(
              'pro Tag',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        if (_entry.transmittedToProvider) _transmittedToProvider(),
        _noteWidget(),
      ],
    );
  }

  _noContractWidget({
    required int usage,
    required String unit,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                convertMeterUnit.getUnitWidget(
                  count: '+${ConvertCount.convertCount(usage)}',
                  unit: unit,
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: _entryProvider.getColors(
                          _entry.count,
                          usage,
                        ),
                      ),
                ),
                Text(
                  'innerhalb ${_entry.days} Tagen',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                convertMeterUnit.getUnitWidget(
                  count: _entryProvider.getDailyUsage(usage, _entry.days),
                  unit: unit,
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: _entryProvider.getColors(
                          _entry.count,
                          usage,
                        ),
                      ),
                ),
                Text(
                  'pro Tag',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ],
        ),
        if (_entry.transmittedToProvider) _transmittedToProvider(),
        _noteWidget(),
        const SizedBox(
          height: 25,
        ),
        Text(
          'Für mehr Information füge einen Vertrag hinzu.',
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  _information({
    required int usage,
    required String unit,
    required CostProvider costProvider,
  }) {
    bool contract = _entryProvider.getContractData;

    return Column(
      children: [
        if (!contract)
          _noContractWidget(
            usage: usage,
            unit: unit,
          ),
        if (contract)
          _contractWidget(
            usage: usage,
            unit: unit,
            costProvider: costProvider,
          ),
      ],
    );
  }

  _mainInformation({
    required int usage,
    required String unit,
    required CostProvider costProvider,
  }) {
    return Column(
      children: [
        if (usage == -1 && !_entry.isReset) _extraInformation('Erstablesung'),
        if (_entry.isReset)
          _extraInformation('Dieser Zähler wurde Zurückgesetzt.'),
        if (_entry.transmittedToProvider && (_entry.isReset || usage == -1))
          _transmittedToProvider(),
        const SizedBox(
          height: 5,
        ),
        if (usage != -1)
          _information(
            usage: usage,
            unit: unit,
            costProvider: costProvider,
          ),
      ],
    );
  }

  _imageView({
    required EntryDto entry,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(
          builder: (context) =>
              ImageView(image: File(_imagePath!), entry: _entry),
        ))
            .then((value) async {
          bool deleteImage = value ?? false;

          if (deleteImage) {
            await _deleteImage();
          }
        });
      },
      child: Image.file(
        File(_imagePath!),
      ),
    );
  }

  _showAddImagePopup({
    required Offset offset,
  }) {
    final db = Provider.of<LocalDatabase>(context, listen: false);
    final databaseSettingsProvider =
        Provider.of<DatabaseSettingsProvider>(context, listen: false);

    return showMenu(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      position: RelativeRect.fromLTRB(0, offset.dy, 0, 0),
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
                await _meterImageHelper.selectAndSaveImage(ImageSource.camera);

            databaseSettingsProvider.toggleInAppActionState();

            _entry.imagePath = imagePath;
            await db.entryDao.updateEntry(_entry.id!,
                EntriesCompanion(imagePath: drift.Value(imagePath)));

            setState(() {
              _imagePath = imagePath;

              if (_imagePath != null) {
                _selectedView = 1;
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
                await _meterImageHelper.selectAndSaveImage(ImageSource.gallery);

            databaseSettingsProvider.toggleInAppActionState();

            _entry.imagePath = imagePath;
            await db.entryDao.updateEntry(_entry.id!,
                EntriesCompanion(imagePath: drift.Value(imagePath)));

            setState(() {
              _imagePath = imagePath;

              if (_imagePath != null) {
                _selectedView = 1;
                _pageController.nextPage(
                    duration: Durations.short1, curve: Curves.linear);
              }
            });
          },
        ),
      ],
    );
  }

  _deleteImage() async {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    const EntriesCompanion entry =
        EntriesCompanion(imagePath: drift.Value(null));

    await db.entryDao.updateEntry(_entry.id!, entry);

    setState(() {
      _selectedView = 0;
      _imagePath = null;
    });
  }

  _imagePopUpMenu() {
    final databaseSettingsProvider =
        Provider.of<DatabaseSettingsProvider>(context, listen: false);

    return PopupMenuButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      tooltip: 'Teilen oder löschen von dem Bild',
      icon: Icon(
        CustomIcons.photoedit,
        color: Theme.of(context).hintColor,
      ),
      onSelected: (value) async {
        if (value == 0) {
          bool success =
              await _meterImageHelper.saveImageToGallery(File(_imagePath!));

          if (mounted) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Bild wurde in der Galerie gespeichert!',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Bild konnte nicht in die Galerie gespeichert werden!',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        }
        if (value == 1) {
          databaseSettingsProvider.toggleInAppActionState();

          await Share.shareXFiles([XFile(_imagePath!)]);

          databaseSettingsProvider.toggleInAppActionState();
        }
        if (value == 2) {
          await _meterImageHelper.deleteImage(_imagePath!);

          await _deleteImage();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Row(
            children: [
              const Icon(
                Icons.save_alt,
                size: 20,
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                'Bild in die Galerie speichern',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              const Icon(
                Icons.share,
                size: 20,
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                'Bild teilen',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _entryProvider = Provider.of<EntryCardProvider>(context);
    final costProvider = Provider.of<CostProvider>(context, listen: false);

    if (_entry.note == null || _entry.note!.isEmpty) {
      _entryProvider.setStateNote(false);
    } else {
      _entryProvider.setStateNote(true);
      _noteController.text = _entry.note!;
    }

    String unit = _entryProvider.getMeterUnit;
    int usage = _entryProvider.getUsage(_entry);

    return AlertDialog(
      content: SizedBox(
        // height: 500,
        width: MediaQuery.sizeOf(context).height * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  DateFormat('dd.MM.yyyy').format(_entry.date),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                convertMeterUnit.getUnitWidget(
                  count: ConvertCount.convertCount(_entry.count),
                  unit: unit,
                  textStyle: Theme.of(context).textTheme.bodyMedium!,
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            const Divider(),
            SizedBox(
              height:
                  _entry.transmittedToProvider && !_entry.isReset ? 270 : 200,
              child: PageView(
                controller: _pageController,
                onPageChanged: (value) {
                  if (_noteFocus.hasFocus) {
                    _noteFocus.unfocus();
                  }

                  setState(
                    () => _selectedView = value,
                  );
                },
                children: [
                  _mainInformation(
                    usage: usage,
                    unit: unit,
                    costProvider: costProvider,
                  ),
                  if (_imagePath != null) _imageView(entry: _entry),
                ],
              ),
            ),
            if (_imagePath != null)
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 8.0),
                child: AnimatedSmoothIndicator(
                  activeIndex: _selectedView,
                  count: 2,
                  effect: WormEffect(
                    activeDotColor: Theme.of(context).primaryColor,
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        if (_imagePath == null)
          IconButton(
            key: _iconKey,
            onPressed: () async {
              if (_noteFocus.hasFocus) {
                _noteFocus.unfocus();
                await Future.delayed(const Duration(milliseconds: 250));
              }

              RenderBox renderBox =
                  _iconKey.currentContext?.findRenderObject() as RenderBox;

              Offset offset = renderBox.localToGlobal(Offset.zero);

              _showAddImagePopup(offset: offset);
            },
            icon: Icon(
              CustomIcons.photoadd,
              color: Theme.of(context).hintColor,
            ),
            tooltip: 'Füge ein Bild hinzu',
          ),
        if (_selectedView == 1) _imagePopUpMenu(),
        TextButton(
          onPressed: () {
            _saveNote(_entryProvider);
            _entryProvider.setStateNote(false);
            Navigator.of(context).pop(true);
          },
          child: Text(
            'Okay',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ),
      ],
    );
  }
}
