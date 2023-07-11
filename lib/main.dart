import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/database/local_database.dart';
import 'core/provider/chart_provider.dart';
import 'core/provider/contract_provider.dart';
import 'core/provider/cost_provider.dart';
import 'core/provider/database_settings_provider.dart';
import 'core/provider/entry_card_provider.dart';
import 'core/provider/meter_provider.dart';
import 'core/provider/room_provider.dart';
import 'core/provider/small_feature_provider.dart';
import 'core/provider/refresh_provider.dart';
import 'core/provider/reminder_provider.dart';
import 'core/provider/sort_provider.dart';
import 'core/provider/stats_provider.dart';
import 'core/provider/theme_changer.dart';

import 'ui/screens/settings_screens/main_settings.dart';
import 'ui/screens/settings_screens/reminder_screen.dart';
import 'ui/screens/settings_screens/tags_screen.dart';
import 'ui/widgets/bottom_nav_bar.dart';
import 'ui/screens/settings_screens/database_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

  _cacheImages(BuildContext context) {
    // reminder images
    precacheImage(
        const AssetImage('assets/icons/notifications_disable.png'), context);
    precacheImage(
        const AssetImage('assets/icons/notifications_enable.png'), context);

    // chart image
    precacheImage(const AssetImage('assets/icons/no_data.png'), context);

    // Settings screens
    precacheImage(const AssetImage('assets/icons/database_icon.png'), context);
    precacheImage(const AssetImage('assets/icons/tag.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    _cacheImages(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeChanger>.value(value: ThemeChanger()),
        ChangeNotifierProvider<CostProvider>.value(value: CostProvider()),
        ChangeNotifierProvider<SortProvider>.value(value: SortProvider()),
        ChangeNotifierProvider<RefreshProvider>.value(value: RefreshProvider()),
        ChangeNotifierProvider<ReminderProvider>.value(
            value: ReminderProvider()),
        ChangeNotifierProvider<SmallFeatureProvider>.value(
            value: SmallFeatureProvider()),
        ChangeNotifierProvider<EntryCardProvider>.value(
            value: EntryCardProvider()),
        ChangeNotifierProvider<ChartProvider>.value(value: ChartProvider()),
        ChangeNotifierProvider<StatsProvider>.value(value: StatsProvider()),
        ChangeNotifierProvider<DatabaseSettingsProvider>.value(value: DatabaseSettingsProvider()),
        ChangeNotifierProvider<RoomProvider>.value(value: RoomProvider()),
        ChangeNotifierProvider<ContractProvider>.value(value: ContractProvider()),
        ChangeNotifierProvider<MeterProvider>.value(value: MeterProvider()),
      ],
      child: Consumer<ThemeChanger>(
        builder: (context, themeChanger, child) {
          return MaterialApp(
            localizationsDelegates: const [
              GlobalWidgetsLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('de', ''),
              Locale('en', ''),
            ],
            title: 'OpenMeter',
            debugShowCheckedModeBanner: false,
            theme: light,
            darkTheme: themeChanger.getNightMode ? night : dark,
            themeMode: themeChanger.getThemeMode,
            initialRoute: '/',
            routes: {
              '/': (_) => const BottomNavBar(),
              // 'add_meter': (_) => AddScreen(),
              // 'add_contract': (_) => const AddContract(),
              'settings': (_) => const MainSettings(),
              // 'details_single_meter': (_) => DetailsSingleMeter(),
              'reminder': (_) => const ReminderScreen(),
              'database_export_import': (_) => const DatabaseExportImport(),
              'tags_screen': (_) => const TagsScreen(),
            },
          );
        },
      ),
    );
  }
}
