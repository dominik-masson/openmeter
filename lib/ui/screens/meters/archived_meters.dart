import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/model/meter_with_room.dart';
import '../../../core/provider/database_settings_provider.dart';
import '../../../core/provider/meter_provider.dart';
import '../../widgets/meter/meter_card_list.dart';

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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
              ),
            ),
      body: WillPopScope(
          onWillPop: () async {
            if (hasSelectedItems) {
              meterProvider.removeAllSelectedMeters();
              return false;
            } else {
              Navigator.of(context).pushReplacementNamed('/');
              return true;
            }
          },
          child: MeterCardList(stream: stream, isHomescreen: false)),
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
          icon: const Icon(Icons.unarchive),
          onPressed: () {
            backup.setHasUpdate(true);
            meterProvider.updateStateArchived(db, false);
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
}
