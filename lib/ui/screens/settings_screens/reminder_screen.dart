import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/provider/reminder_provider.dart';
import '../../widgets/reminder_screen/active_reminder.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  bool _active = false;
  final DateTime _selectedTime = DateTime.now();

  _loadFromPrefs(BuildContext context, ReminderProvider reminderProvider) {
    _active = reminderProvider.isActive;
  }

  _handleSwitchState(bool value, ReminderProvider reminderProvider) async {
    setState(() {
      _active = value;
      reminderProvider.setActive(value);

      if (_selectedTime.hour == 0 && _selectedTime.minute == 0) {
        reminderProvider.setTime(TimeOfDay.now().hour, TimeOfDay.now().minute);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);

    _loadFromPrefs(context, reminderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ableseerinnerung'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_active)
              Center(
                child: Image.asset(
                  'assets/icons/notifications_disable.png',
                  width: 200,
                ),
              ),
            if (_active)
              Center(
                child: Image.asset(
                  'assets/icons/notifications_enable.png',
                  width: 200,
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            SwitchListTile(
              title: _active
                  ? Text(
                      'An',
                      style: Theme.of(context).textTheme.headlineLarge,
                    )
                  : Text(
                      'Aus',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
              subtitle: _active
                  ? null
                  : const Text(
                      'Richte eine Ableseerinnerung ein, um Benachrichtigungen zu erhalten.'),
              contentPadding: const EdgeInsets.all(0),
              value: _active,
              onChanged: (value) async {
                await _handleSwitchState(value, reminderProvider);
              },
            ),
            if (_active) const ActiveReminder(),
          ],
        ),
      ),
    );
  }
}
