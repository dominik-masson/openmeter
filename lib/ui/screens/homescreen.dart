import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/database/local_database.dart';
import '../../core/provider/database_settings_provider.dart';
import '../../core/provider/meter_provider.dart';

import '../widgets/meter/meter_card_list.dart';
import '../widgets/meter/sort_meter_cards.dart';
import 'add_meter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
      body: WillPopScope(
        onWillPop: () async {
          if (hasSelectedItems) {
            meterProvider.removeAllSelectedMeters();
            return false;
          }

          return true;
        },
        child: MeterCardList(
            stream: db.meterDao.watchAllMeterWithRooms(), isHomescreen: true),
      ),
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
      actions: [
        IconButton(
          icon: const Icon(Icons.archive),
          onPressed: () {
            backup.setHasUpdate(true);
            meterProvider.updateStateArchived(db, true);
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            meterProvider.deleteSelectedMeters(db);
          },
        ),
      ],
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
        ),
        IconButton(
          onPressed: () {
            SortMeterCards().getFilter(context: context);
          },
          icon: const Icon(Icons.filter_list),
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed('settings').then((value) => provider.setStateHasUpdate(true));
          },
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }
}
