import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: const MeterCardList(),
    );
  }
}
