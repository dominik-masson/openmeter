import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/provider/torch_provider.dart';

class ActiveTorch extends StatefulWidget {
  const ActiveTorch({super.key});

  @override
  State<ActiveTorch> createState() => _ActiveTorchState();
}

class _ActiveTorchState extends State<ActiveTorch> {
  bool _activeTorch = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TorchProvider>(context);

    _activeTorch = provider.stateTorch;

    return SwitchListTile(
      title: Text(
        'Taschenlampe',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: const Text(
          'Die Taschenlampe wird bei der Ablesung automatisch eingeschaltet.'),
      secondary: _activeTorch == false
          ? const Icon(Icons.flashlight_off)
          : const Icon(Icons.flashlight_on),
      value: _activeTorch,
      onChanged: (value) {
        setState(() {
          _activeTorch = value;
          provider.setTorch(_activeTorch);
        });
      },
    );
  }
}
