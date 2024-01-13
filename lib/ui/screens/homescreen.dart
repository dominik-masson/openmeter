import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/database/local_database.dart';
import '../../core/provider/database_settings_provider.dart';
import '../../core/provider/meter_provider.dart';

import '../widgets/meter/meter_card_list.dart';
import '../widgets/meter/sort_meter_cards.dart';
import '../widgets/utils/selected_items_bar.dart';
import 'meters/add_meter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final meterProvider = Provider.of<MeterProvider>(context);
    final db = Provider.of<LocalDatabase>(context, listen: false);
    final autoBackup =
        Provider.of<DatabaseSettingsProvider>(context, listen: false);

    bool hasSelectedItems = meterProvider.getStateHasSelectedMeters;

    return Scaffold(
      appBar: hasSelectedItems == true
          ? _selectedAppBar(meterProvider, db, autoBackup)
          : _unselectedAppBar(meterProvider),
      body: PopScope(
        onPopInvoked: (bool didPop) async {
          if (hasSelectedItems) {
            meterProvider.removeAllSelectedMeters();
          }
        },
        canPop: !hasSelectedItems,
        child: Stack(
          children: [
            MeterCardList(
                stream: db.meterDao.watchAllMeterWithRooms(false),
                isHomescreen: true),
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
          meterProvider.resetSelectedMeters(db);
        },
        style: buttonStyle,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restart_alt,
              size: 28,
            ),
            SizedBox(
              height: 5,
            ),
            Text('Zurücksetzen'),
          ],
        ),
      ),
      TextButton(
        onPressed: () {
          backup.setHasUpdate(true);
          meterProvider.updateStateArchived(db, true);
        },
        style: buttonStyle,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.archive_outlined,
              size: 28,
            ),
            SizedBox(
              height: 5,
            ),
            Text('Archivieren'),
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

    return SelectedItemsBar(
      buttons: buttons,
    );
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

  AppBar _unselectedAppBar(MeterProvider provider) {
    return AppBar(
      title: const Text('OpenMeter'),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddScreen(
                    meter: null,
                    room: null,
                  ),
                ));
          },
          icon: const Icon(Icons.add),
          tooltip: 'Zähler erstellen',
        ),
        IconButton(
          onPressed: () {
            SortMeterCards().getFilter(context: context);
          },
          icon: const Icon(Icons.filter_list),
          tooltip: 'Sortieren',
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed('settings');
            // .then((value) => provider.setStateHasUpdate(true));
          },
          icon: const Icon(Icons.settings),
          tooltip: 'Einstellungen',
        ),
      ],
    );
  }
}
