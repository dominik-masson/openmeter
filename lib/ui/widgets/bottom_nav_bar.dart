import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/database/local_database.dart';
import '../../core/provider/database_settings_provider.dart';
import '../../core/services/database_settings_helper.dart';
import '../../utils/custom_icons.dart';
import '../screens/homescreen.dart';
import '../screens/objects.dart';
import '../screens/stats_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  final List _screen = const [
    HomeScreen(),
    // StatsScreen(),
    ObjectsScreen(),
  ];

  late DatabaseSettingsProvider databaseSettingsProvider;
  late DatabaseSettingsHelper databaseSettingsHelper;
  late LocalDatabase db;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    log(state.toString(), name: 'AppLifecycleState');

    if (databaseSettingsProvider.checkIfAutoBackupIsPossible() &&
        state == AppLifecycleState.paused) {
      await databaseSettingsHelper
          .autoBackupExport(db, databaseSettingsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    databaseSettingsProvider = Provider.of<DatabaseSettingsProvider>(context);

    databaseSettingsHelper = DatabaseSettingsHelper(context);

    db = Provider.of<LocalDatabase>(context);

    return Scaffold(
      body: _screen[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).bottomAppBarTheme.color,
        currentIndex: _currentIndex,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(CustomIcons.voltmeter), label: 'Zähler'),
          // BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Statistik'),
          BottomNavigationBarItem(icon: Icon(Icons.widgets), label: 'Objekte'),
        ],
      ),
    );
  }
}
