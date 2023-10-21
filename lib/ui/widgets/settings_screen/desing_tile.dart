import 'package:flutter/material.dart';

class DesignTile extends StatelessWidget {
  const DesignTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        'Darstellung',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      leading: const Icon(Icons.brightness_6),
      onTap: () => Navigator.of(context).pushNamed('design_settings'),
    );
  }
}
