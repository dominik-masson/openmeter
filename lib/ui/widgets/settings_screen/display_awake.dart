import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/provider/small_feature_provider.dart';

class DisplayAwake extends StatefulWidget {
  const DisplayAwake({Key? key}) : super(key: key);

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
      title: const Text('Bildschirmsperre'),
      subtitle: const Text('Verhindert die automatische Bildschirmsperre.'),
      secondary: const FaIcon(
        FontAwesomeIcons.display,
        size: 18,
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
