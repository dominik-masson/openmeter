import 'package:flutter/material.dart';
import 'package:openmeter/core/database/local_database.dart';
import 'package:provider/provider.dart';

import '../../core/provider/meter_provider.dart';
import '../widgets/homescreen/sort_meter_cards.dart';
import '../widgets/homescreen/meter_card_list.dart';
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

    bool hasSelectedItems = meterProvider.getStateHasSelectedMeters;

    return Scaffold(
      appBar: hasSelectedItems == true
          ? _selectedAppBar(meterProvider, db)
          : _unselectedAppBar(),
      body: WillPopScope(onWillPop: () async {
        if(hasSelectedItems){
          meterProvider.removeAllSelectedMeters();
          return false;
        }

        return true;
      }, child: const MeterCardList()),
    );
  }

  AppBar _selectedAppBar(MeterProvider meterProvider, LocalDatabase db) {
    return AppBar(
      title: Text('${meterProvider.getCountSelectedMeters} ausgewählt'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => meterProvider.removeAllSelectedMeters(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            meterProvider.deleteSelectedMeters(db);
          },
        ),
      ],
    );
  }

  AppBar _unselectedAppBar() {
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
                    tagsId: [],
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
            Navigator.of(context).pushNamed('settings');
          },
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }
}
