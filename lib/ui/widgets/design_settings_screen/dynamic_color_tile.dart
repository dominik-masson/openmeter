import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/provider/theme_changer.dart';

class DynamicColorTile extends StatefulWidget {
  const DynamicColorTile({super.key});

  @override
  State<DynamicColorTile> createState() => _DynamicColorTileState();
}

class _DynamicColorTileState extends State<DynamicColorTile> {
  bool _useDynamic = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeChanger>(context);

    _useDynamic = provider.getUseDynamicColor;

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return SwitchListTile(
          value: _useDynamic,
          title: Text(
            'Dynamische Farben',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          onChanged: (value) {
            setState(() {
              _useDynamic = value;

              provider.setUseDynamicColor(value, lightDynamic, darkDynamic);
            });
          },
        );
      },
    );
  }
}
