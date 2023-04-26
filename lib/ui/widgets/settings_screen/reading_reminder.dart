import 'package:flutter/material.dart';

class ReadingReminder extends StatelessWidget {
  const ReadingReminder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text(
        'Ableseerinnerung',
        style: TextStyle(fontSize: 18),
      ),
      leading: const Icon(Icons.notifications),
      subtitle: const Text('Stelle eine Ableseerinnerung ein um automatische Benachrichtigungen zu erhalten'),
      onTap: () {
        Navigator.of(context).pushNamed('reminder');
      },
    );
  }
}
