import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/provider/contract_provider.dart';
import '../../../core/provider/database_settings_provider.dart';
import '../../../core/provider/design_provider.dart';
import '../../../core/provider/meter_provider.dart';
import '../../../core/provider/room_provider.dart';
import '../../../core/services/database_settings_helper.dart';
import '../../../utils/custom_icons.dart';
import '../../../utils/log.dart';
import '../../screens/homescreen.dart';
import '../../screens/objects.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

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

    log(state.toString(), name: LogNames.appLifecycle);

    if (databaseSettingsProvider.checkIfAutoBackupIsPossible() &&
        state == AppLifecycleState.paused) {
      await databaseSettingsHelper.autoBackupExport(
          db, databaseSettingsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    databaseSettingsProvider = Provider.of<DatabaseSettingsProvider>(context);

    databaseSettingsHelper = DatabaseSettingsHelper(context);

    db = Provider.of<LocalDatabase>(context);

    final roomProvider = Provider.of<RoomProvider>(context);
    final meterProvider = Provider.of<MeterProvider>(context);
    final contractProvider = Provider.of<ContractProvider>(context);
    final designProvider = Provider.of<DesignProvider>(context);

    bool compactNavBar = designProvider.getStateCompactNavBar;

    bool hasSelectedItems = false;

    if(meterProvider.getStateHasSelectedMeters || roomProvider.getStateHasSelected || contractProvider.getHasSelectedItems){
      hasSelectedItems = true;
    }

    return Scaffold(
      body: _screen[_currentIndex],
      bottomNavigationBar: hasSelectedItems ? null : NavigationBar(
        height: MediaQuery.of(context).size.height * 0.09,
        labelBehavior: compactNavBar
            ? NavigationDestinationLabelBehavior.alwaysHide
            : NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) {
          if (roomProvider.getStateHasSelected) {
            roomProvider.removeAllSelected();
          }
          if (contractProvider.getHasSelectedItems) {
            contractProvider.removeAllSelectedItems();
          }
          if (meterProvider.getStateHasSelectedMeters) {
            meterProvider.removeAllSelectedMeters();
          }

          setState(() {
            _currentIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(CustomIcons.voltmeter),
            label: 'Zähler',
          ),
          NavigationDestination(
            icon: Icon(Icons.widgets),
            label: 'Objekte',
          ),
        ],
      ),
    );
  }
}
