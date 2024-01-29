import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/model/meter_with_room.dart';
import '../../../core/provider/database_settings_provider.dart';
import '../../../core/provider/meter_provider.dart';
import '../../widgets/meter/meter_card_list.dart';
import '../../widgets/utils/selected_items_bar.dart';

class ArchivedMeters extends StatefulWidget {
  const ArchivedMeters({super.key});

  @override
  State<ArchivedMeters> createState() => _ArchivedMetersState();
}

class _ArchivedMetersState extends State<ArchivedMeters> {
  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context);
    final meterProvider = Provider.of<MeterProvider>(context);
    final autoBackup =
        Provider.of<DatabaseSettingsProvider>(context, listen: false);

    Stream<List<MeterWithRoom>> stream =
        db.meterDao.watchAllMeterWithRooms(true);

    bool hasSelectedItems = meterProvider.getStateHasSelectedMeters;

    return Scaffold(
      appBar: hasSelectedItems == true
          ? _selectedAppBar(meterProvider, db, autoBackup)
          : AppBar(
              title: const Text('Archivierte Zähler'),
            ),
      body: PopScope(
        canPop: !hasSelectedItems,
        onPopInvoked: (didPop) {
          if (hasSelectedItems) {
            meterProvider.removeAllSelectedMeters();
          }
        },
        child: Stack(
          children: [
            MeterCardList(stream: stream, isHomescreen: false),
            if (hasSelectedItems) _selectedItems(meterProvider, db, autoBackup),
          ],
        ),
      ),
    );
  }

  _selectedItems(
    MeterProvider meterProvider,
    LocalDatabase db,
    DatabaseSettingsProvider backup,
  ) {
    final buttonStyle = ButtonStyle(
      foregroundColor: MaterialStateProperty.all(
        Theme.of(context).textTheme.bodyLarge!.color,
      ),
    );

    final buttons = [
      TextButton(
        onPressed: () {
          backup.setHasUpdate(true);
          meterProvider.updateStateArchived(db, false);
        },
        style: buttonStyle,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.unarchive_outlined,
              size: 28,
            ),
            SizedBox(
              height: 5,
            ),
            Text('Wiederherstellen'),
          ],
        ),
      ),
      TextButton(
        onPressed: () {
          meterProvider.deleteSelectedMeters(db);
        },
        style: buttonStyle,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_outline,
              size: 28,
            ),
            SizedBox(
              height: 5,
            ),
            Text('Löschen'),
          ],
        ),
      ),
    ];

    return SelectedItemsBar(buttons: buttons);
  }

  AppBar _selectedAppBar(MeterProvider meterProvider, LocalDatabase db,
      DatabaseSettingsProvider backup) {
    return AppBar(
      title: Text('${meterProvider.getCountSelectedMeters} ausgewählt'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => meterProvider.removeAllSelectedMeters(),
      ),
    );
  }
}
