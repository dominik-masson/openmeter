import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/provider/reminder_provider.dart';
import '../../widgets/reminder_screen/active_reminder.dart';

enum RepeatValues { daily, weekly, monthly }

final weekDays = [
  'Montag',
  'Dienstag',
  'Mittwoch',
  'Donnerstag',
  'Freitag',
  'Samstag',
  'Sonntag'
];

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({Key? key}) : super(key: key);

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  bool _active = false;
  final DateTime _dateTimeNow = DateTime.now();
  late final ActiveReminder _activeReminder;

  RepeatValues _selectedRepeat = RepeatValues.daily;
  String _selectedWeek = 'Montag';
  DateTime _selectedTime = DateTime.now();
  int _selectedDay = 1;

  @override
  void initState() {
    super.initState();
    _activeReminder = ActiveReminder(
      selectedRepeat: _selectedRepeat,
      selectedWeek: _selectedWeek,
      selectedTime: _selectedTime,
      selectedDay: _selectedDay,
    );
  }

  _loadFromPrefs(BuildContext context, ReminderProvider reminderProvider) {
    _active = reminderProvider.isActive;
    _selectedRepeat = reminderProvider.repeatInterval;
    _selectedWeek = weekDays.elementAt(reminderProvider.weekDay);
    _selectedTime = DateTime(
      _dateTimeNow.year,
      _dateTimeNow.month,
      _dateTimeNow.day,
      reminderProvider.timeHour,
      reminderProvider.timeMinute,
    );
    _selectedDay = reminderProvider.monthDay;
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
              title: _active ? const Text('An') : const Text('Aus'),
              subtitle: _active
                  ? null
                  : const Text(
                      'Richte eine Ableseerinnerung ein, um Benachrichtigungen zu erhalten.'),
              contentPadding: const EdgeInsets.all(0),
              value: _active,
              onChanged: (value) {
                setState(
                  () {
                    _active = value;
                    reminderProvider.setActive(value);

                    if (_selectedTime.hour == 0 && _selectedTime.minute == 0) {
                      reminderProvider.setTime(
                          TimeOfDay.now().hour, TimeOfDay.now().minute);
                    }
                  },
                );
              },
            ),
            if (_active)
              _activeReminder.activeWidget(context, reminderProvider),
          ],
        ),
      ),
    );
  }
}
