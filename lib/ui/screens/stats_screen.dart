import 'package:flutter/material.dart';
import 'package:openmeter/ui/widgets/stats_screen/meter_typs_widget.dart';

import '../widgets/stats_screen/tag_widget.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiken'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('settings');
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TagWidget(),
            MeterTypsWidget(),
          ],
        ),
      ),
    );
  }
}
