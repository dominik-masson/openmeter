import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/database/local_database.dart';
import '../../../core/provider/cost_provider.dart';
import '../../../core/provider/database_settings_provider.dart';
import '../../../core/provider/entry_card_provider.dart';
import '../../../utils/convert_count.dart';
import '../../../utils/convert_meter_unit.dart';

class DetailsEntry {
  bool _stateNote = false; // if ture => write some note
  final TextEditingController _noteController = TextEditingController();
  final ConvertMeterUnit convertMeterUnit = ConvertMeterUnit();

  late Entrie _entry;
  late EntryCardProvider _entryProvider;

  DetailsEntry();

  _saveNote(BuildContext context, EntryCardProvider entryProvider) async {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    if (_noteController.text.isEmpty) {
      _stateNote = false;
      entryProvider.setStateNote(false);
    }

    final newEntry = EntriesCompanion(
      id: drift.Value(_entry.id),
      days: drift.Value(_entry.days),
      count: drift.Value(_entry.count),
      usage: drift.Value(_entry.usage),
      meter: drift.Value(_entry.meter),
      date: drift.Value(_entry.date),
      note: drift.Value(_noteController.text),
    );

    await db.entryDao.updateEntry(newEntry);

    if (context.mounted) {
      Provider.of<DatabaseSettingsProvider>(context, listen: false)
          .setHasUpdate(true);
    }
  }

  _noteWidget(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        TextFormField(
          controller: _noteController,
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

  _contractWidget({
    required BuildContext context,
    required int usage,
    required String unit,
    required Entrie entry,
    required CostProvider costProvider,
  }) {
    double usageCost = costProvider.calcUsage(usage);
    double dailyCost = usageCost / entry.days;

    final String local = Platform.localeName;
    final costFormat = NumberFormat.simpleCurrency(locale: local);

    return Column(
      children: [
        // full days
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                convertMeterUnit.getUnitWidget(
                  count: '+${ConvertCount.convertCount(usage)}',
                  unit: unit,
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: _entryProvider.getColors(
                          entry.count,
                          usage,
                        ),
                      ),
                ),
                Text(
                  'innerhalb ${entry.days} Tagen',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  '${ConvertCount.convertDouble(usageCost)} €',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),

        // Daily
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                convertMeterUnit.getUnitWidget(
                  count: _entryProvider.getDailyUsage(usage, entry.days),
                  unit: unit,
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: _entryProvider.getColors(
                          entry.count,
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
            Column(
              children: [
                Text(
                  costFormat.format(dailyCost),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
        if (_stateNote) _noteWidget(context),
      ],
    );
  }

  _noContractWidget({
    required BuildContext context,
    required int usage,
    required Entrie entry,
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
                          entry.count,
                          usage,
                        ),
                      ),
                ),
                Text(
                  'innerhalb ${entry.days} Tagen',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                convertMeterUnit.getUnitWidget(
                  count: _entryProvider.getDailyUsage(usage, entry.days),
                  unit: unit,
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: _entryProvider.getColors(
                          entry.count,
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
        if (_stateNote) _noteWidget(context),
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
    required BuildContext context,
    required int usage,
    required String unit,
    required Entrie entry,
    required EntryCardProvider entryProvider,
    required CostProvider costProvider,
    required Function setState,
  }) {
    bool contract = entryProvider.getContractData;
    _stateNote = entryProvider.getStateNote;

    return Column(
      children: [
        if (!contract)
          _noContractWidget(
            context: context,
            usage: usage,
            entry: entry,
            unit: unit,
          ),
        if (contract)
          _contractWidget(
            context: context,
            usage: usage,
            entry: entry,
            unit: unit,
            costProvider: costProvider,
          ),
      ],
    );
  }

  _extraInformation(BuildContext context, String text) {
    return Column(
      children: [
        Center(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium!),
        ),
        if (_stateNote)
          _noteWidget(
            context,
          ),
      ],
    );
  }

  getDetailsAlert({
    required BuildContext context,
    required Entrie entry,
    required int usage,
    required EntryCardProvider entryProvider,
    required CostProvider costProvider,
  }) {
    _entry = Entrie(
        id: entry.id,
        meter: entry.meter,
        count: entry.count,
        usage: entry.usage,
        date: entry.date,
        days: entry.days,
        note: entry.note,
        isReset: entry.isReset);

    if (_entry.note == null || _entry.note!.isEmpty) {
      _stateNote = false;
      entryProvider.setStateNote(false);
    } else {
      _stateNote = true;
      entryProvider.setStateNote(true);
      _noteController.text = _entry.note!;
    }

    _entryProvider = entryProvider;

    String unit = _entryProvider.getMeterUnit;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        DateFormat('dd.MM.yyyy').format(entry.date),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      convertMeterUnit.getUnitWidget(
                        count: ConvertCount.convertCount(entry.count),
                        unit: unit,
                        textStyle: Theme.of(context).textTheme.bodyMedium!,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  if (usage == -1 && !_entry.isReset)
                    _extraInformation(context, 'Erstablesung'),
                  if (_entry.isReset)
                    _extraInformation(context, 'Zurückgesetzt'),
                  if (usage != -1)
                    _information(
                      context: context,
                      usage: usage,
                      unit: unit,
                      entry: entry,
                      entryProvider: entryProvider,
                      costProvider: costProvider,
                      setState: setState,
                    ),
                ],
              ),
              actions: [
                if (!entryProvider.getStateNote && !_stateNote)
                  IconButton(
                    onPressed: () {
                      entryProvider.setStateNote(true);
                      setState(
                        () => _stateNote = true,
                      );
                    },
                    icon: const Icon(Icons.note_add),
                    tooltip: 'Notiz erstellen',
                  ),
                TextButton(
                  onPressed: () {
                    _saveNote(context, entryProvider);
                    entryProvider.setStateNote(false);
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
          },
        );
      },
    );
  }
}
