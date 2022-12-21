import 'package:flutter/material.dart';

import '../widgets/meter_card_list.dart';
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
                      builder: (context) => const AddScreen(meter: null, room: null,),
                    ));
              },
              icon: const Icon(Icons.add)),
          IconButton(onPressed: () {
            Navigator.of(context).pushNamed('settings');
          }, icon: const Icon(Icons.settings))
        ],
      ),
      body:
        const MeterCardList(),
    );
  }
}
