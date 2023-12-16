import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/provider/small_feature_provider.dart';

class DisplayAwake extends StatefulWidget {
  const DisplayAwake({super.key});

  @override
  State<DisplayAwake> createState() => _DisplayAwakeState();
}

class _DisplayAwakeState extends State<DisplayAwake> {
  bool _awake = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SmallFeatureProvider>(context);

    _awake = provider.stateAwake;

    return SwitchListTile(
      title: Text(
        'Bildschirmsperre verhindern',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      value: _awake,
      onChanged: (value) {
        setState(() {
          _awake = value;
          provider.setAwake(_awake);
        });
      },
    );
  }
}
