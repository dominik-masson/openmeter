import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/provider/design_provider.dart';

class CompactNavBarSettings extends StatefulWidget {
  const CompactNavBarSettings({super.key});

  @override
  State<CompactNavBarSettings> createState() => _CompactNavBarSettingsState();
}

class _CompactNavBarSettingsState extends State<CompactNavBarSettings> {
  bool _compactNavBar = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignProvider>(context);

    _compactNavBar = provider.getStateCompactNavBar;

    return SwitchListTile(
      value: _compactNavBar,
      title: Text(
        'Kompakte Navigationsleiste',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      onChanged: (value) {
        setState(() {
          provider.setStateCompactNavBar(value);
          _compactNavBar = value;
        });
      },
    );
  }
}
