import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/provider/reminder_provider.dart';

class TimePickerTile extends StatefulWidget {
  const TimePickerTile({super.key});

  @override
  State<TimePickerTile> createState() => _TimePickerTileState();
}

class _TimePickerTileState extends State<TimePickerTile> {
  String _lableTime = '18:00';

  DateTime _selectedTime = DateTime.now();

  final DateFormat _timeFormat = DateFormat("HH:mm");

  final DateTime _dateTimeNow = DateTime.now();

  _timePicker(BuildContext context, ReminderProvider provider) {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        final Widget mediaQueryWrapper = MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
        return Localizations.override(
          context: context,
          locale: const Locale('de', ''),
          child: mediaQueryWrapper,
        );
      },
    ).then((pickedTime) {
      if (pickedTime == null) {
        return;
      }
      _selectedTime = DateTime(_dateTimeNow.year, _dateTimeNow.month,
          _dateTimeNow.day, pickedTime.hour, pickedTime.minute);
      provider.setTime(_selectedTime.hour, _selectedTime.minute);
    });
  }

  _loadFromPrefs(ReminderProvider reminderProvider) {
    _selectedTime = DateTime(
      _dateTimeNow.year,
      _dateTimeNow.month,
      _dateTimeNow.day,
      reminderProvider.timeHour,
      reminderProvider.timeMinute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);

    _loadFromPrefs(reminderProvider);

    _lableTime = _timeFormat.format(_selectedTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          'Uhrzeit',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        ListTile(
          title: Text(_lableTime, style: Theme.of(context).textTheme.bodyLarge,),
          subtitle: const Text('Wähle die Uhrzeit der Benachrichtigung.'),
          leading: const FaIcon(FontAwesomeIcons.clock),
          onTap: () => _timePicker(context, reminderProvider),
        ),
      ],
    );
  }
}
