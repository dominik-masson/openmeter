import 'package:flutter/material.dart';
import 'package:openmeter/core/database/local_database.dart';
import 'package:openmeter/core/provider/stats_provider.dart';
import 'package:provider/provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<String?> meterTyps = [];
  bool first = true;

  _loadData(LocalDatabase db, StatsProvider statsProvider) async {
    meterTyps = await db.meterDao.getAllMeterTyps();

    if (meterTyps.isNotEmpty) {
      statsProvider.setMeterTyps(meterTyps);
      first = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context);
    final statsProvider = Provider.of<StatsProvider>(context);

    if (first) {
      _loadData(db, statsProvider);
    }
    // db.meterDao.getAllMeterTyps().then((value) => print(value));
    print(meterTyps);

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
        child: Container(),
      ),
    );
  }
}
