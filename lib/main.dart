import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/database/local_database.dart';
import 'core/provider/theme_changer.dart';
import 'ui/screens/add_contract.dart';
import 'ui/screens/add_meter.dart';

import 'ui/screens/settings_screens/main_settings.dart';
import 'ui/widgets/bottom_nav_bar.dart';

void main() {
  runApp(
    Provider<LocalDatabase>(
      create: (context) => LocalDatabase(),
      child: const MyApp(),
      dispose: (context, db) => db.close(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeChanger>.value(value: ThemeChanger()),
      ],
      child: Consumer<ThemeChanger>(
        builder: (context, themeChanger, child) {
          return MaterialApp(
            title: 'OpenMeter',
            debugShowCheckedModeBanner: false,
            theme: light,
            darkTheme: themeChanger.getNightMode ? night : dark,
            themeMode: themeChanger.getThemeMode,
            initialRoute: '/',
            routes: {
              '/': (_) => const BottomNavBar(),
              // 'add_meter': (_) => AddScreen(),
              'add_contract': (_) => const AddContract(),
              'settings': (_) => const MainSettings(),
              // 'details_single_meter': (_) => DetailsSingleMeter(),
            },
          );
        },
      ),
    );
  }
}
