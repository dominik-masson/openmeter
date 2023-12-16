import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/provider/theme_changer.dart';

class ThemeTitle extends StatefulWidget {
  const ThemeTitle({super.key});

  @override
  State<ThemeTitle> createState() => _ThemeTitleState();
}

class _ThemeTitleState extends State<ThemeTitle> {
  dynamic _selectedRadio;
  bool _night = false;

  ThemeMode _themeMode = ThemeMode.system;

  final _dark = ThemeMode.dark;
  final _light = ThemeMode.light;
  final _system = ThemeMode.system;

  _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Dunkel';
      case ThemeMode.light:
        return 'Hell';
      case ThemeMode.system:
        return 'System';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChanger = Provider.of<ThemeChanger>(context, listen: false);
    _night = themeChanger.getNightMode;

    _themeMode = themeChanger.getThemeMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            'Design',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(_getThemeModeText(_themeMode)),
          onTap: () =>
              _themeDialog(context, themeChanger).then((value) => setState(
                    () {
                      _themeMode = value as ThemeMode;
                    },
                  )),
        ),
        SwitchListTile(
          title: Text(
            'Schwarzer Hintergrund',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          // subtitle: const Text('Nur möglich, wenn das dunkle Design ausgewählt ist'),
          value: _night,
          onChanged: (value) {
            if (themeChanger.getThemeMode == ThemeMode.dark ||
                MediaQuery.of(context).platformBrightness == Brightness.dark &&
                    themeChanger.getThemeMode == ThemeMode.system) {
              setState(() {
                _night = value;
              });
              themeChanger.toggleNightMode(_night);
            }
          },
        ),
      ],
    );
  }

  Future<void> _themeDialog(BuildContext context, ThemeChanger themeChanger) {
    _selectedRadio = themeChanger.getThemeMode;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Design auswählen',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    onTap: () {
                      setState(
                        () => _selectedRadio = _system,
                      );
                      themeChanger.setTheme(_system);
                      Navigator.of(context).pop(_system);
                    },
                    title: const Text('System'),
                    contentPadding: const EdgeInsets.all(0),
                    leading: Radio(
                      // activeColor: Theme.of(context).primaryColor,
                      value: _system,
                      groupValue: _selectedRadio,
                      onChanged: (value) {
                        setState(
                          () => _selectedRadio = value,
                        );
                        themeChanger.setTheme(value as ThemeMode);
                        Navigator.of(context).pop(value);
                      },
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      setState(
                        () => _selectedRadio = _light,
                      );
                      themeChanger.setTheme(_light);
                      Navigator.of(context).pop(_light);
                    },
                    title: const Text('Hell'),
                    contentPadding: const EdgeInsets.all(0),
                    leading: Radio(
                      // activeColor: Theme.of(context).primaryColor,
                      value: _light,
                      groupValue: _selectedRadio,
                      onChanged: (value) {
                        setState(
                          () => _selectedRadio = value,
                        );
                        themeChanger.setTheme(value as ThemeMode);
                        Navigator.of(context).pop(value);
                      },
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      setState(
                        () => _selectedRadio = _dark,
                      );
                      themeChanger.setTheme(_dark);
                      Navigator.of(context).pop(_dark);
                    },
                    contentPadding: const EdgeInsets.all(0),
                    title: const Text('Dunkle'),
                    leading: Radio(
                      // activeColor: Theme.of(context).canvasColor,
                      value: _dark,
                      groupValue: _selectedRadio,
                      onChanged: (value) {
                        setState(
                          () => _selectedRadio = value,
                        );
                        themeChanger.setTheme(value as ThemeMode);
                        Navigator.of(context).pop(value);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
