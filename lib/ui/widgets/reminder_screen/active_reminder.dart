import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/provider/reminder_provider.dart';
import '../../screens/settings_screens/reminder_screen.dart';

class ActiveReminder {
  RepeatValues? _selectedRepeat = RepeatValues.daily;
  String _selectedWeek = 'Montag';
  String _lableRepeatTyp = 'Wöchentlich';
  String _lableTime = '18:00';
  DateTime _selectedTime = DateTime.now();
  int _selectedDay = 1;
  final DateFormat _timeFormat = DateFormat("HH:mm");
  final DateTime _dateTimeNow = DateTime.now();

  final _monthDays = List.generate(30, (index) => index + 1, growable: false);

  ActiveReminder({
    required RepeatValues selectedRepeat,
    required String selectedWeek,
    required DateTime selectedTime,
    required int selectedDay,
  }) {
    _selectedRepeat = selectedRepeat;
    _selectedWeek = selectedWeek;
    _selectedTime = selectedTime;
    _selectedDay = selectedDay;
  }

  /*
    Dialog Widget for repeat interval
   */
  _repeat(BuildContext context, ReminderProvider provider) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile(
                    value: RepeatValues.daily,
                    groupValue: _selectedRepeat,
                    title: const Text('Täglich'),
                    onChanged: (RepeatValues? value) {
                      setState(() {
                        _selectedRepeat = value;
                      });
                      provider.setRepeat(RepeatValues.daily);
                      Navigator.of(context).pop();
                    },
                  ),
                  RadioListTile(
                    value: RepeatValues.weekly,
                    groupValue: _selectedRepeat,
                    title: const Text('Wöchentlich'),
                    onChanged: (RepeatValues? value) {
                      setState(() {
                        _selectedRepeat = value;
                      });
                      provider.setRepeat(RepeatValues.weekly);
                      Navigator.of(context).pop();
                    },
                  ),
                  RadioListTile(
                    value: RepeatValues.monthly,
                    groupValue: _selectedRepeat,
                    title: const Text('Monatlich'),
                    onChanged: (RepeatValues? value) {
                      setState(() {
                        _selectedRepeat = value;
                      });
                      provider.setRepeat(RepeatValues.monthly);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /*
    Dialog Widget to select weekday, if repeat is weekly
   */
  _weekDaysDialog(BuildContext context, ReminderProvider provider) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: weekDays.map((e) {
                  return RadioListTile(
                    value: e,
                    groupValue: _selectedWeek,
                    title: Text(e),
                    onChanged: (value) {
                      setState(() {
                        _selectedWeek = value!;
                      });
                      provider.setWeekDay(weekDays.indexOf(e));
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  _weekTile(BuildContext context, ReminderProvider reminderProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wochentag',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ListTile(
          title: Text(_selectedWeek),
          subtitle: const Text('Wähle den Wochentag der Benachrichtigung.'),
          leading: const FaIcon(FontAwesomeIcons.calendarDay),
          onTap: () => _weekDaysDialog(context, reminderProvider),
        ),
      ],
    );
  }

  _monthDaysDialog(BuildContext context, ReminderProvider provider) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _monthDays.map((e) {
                    return RadioListTile(
                      value: e,
                      groupValue: _selectedDay,
                      title: Text('$e'),
                      onChanged: (value) {
                        setState(() {
                          _selectedDay = value!;
                        });
                        provider.setMonthDay(_selectedDay);
                        Navigator.of(context).pop();
                      },
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  _monthTile(BuildContext context, ReminderProvider reminderProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tag im Monat',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ListTile(
          title: Text('$_selectedDay'),
          subtitle: const Text('Wähle den Tag des Monats der Benachrichtigung'),
          leading: const FaIcon(FontAwesomeIcons.solidCalendarDays),
          onTap: () => _monthDaysDialog(context, reminderProvider),
        ),
      ],
    );
  }

  String _getRepeatTyp() {
    switch (_selectedRepeat) {
      case RepeatValues.daily:
        return 'Täglich';
      case RepeatValues.weekly:
        return 'Wöchentlich';
      default:
        return 'Monatlich';
    }
  }

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

  _testButton(ReminderProvider reminderProvider){
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Center(
          child: ElevatedButton(
            onPressed: () => reminderProvider.testNotification(),
            child: const Text('Test Notification'),
          ),
        ),
      ],
    );
  }

  activeWidget(BuildContext context, ReminderProvider reminderProvider) {
    _lableRepeatTyp = _getRepeatTyp();
    // _lableTime = '${_selectedTime.hour}:${_selectedTime.minute} Uhr';
    _lableTime = _timeFormat.format(_selectedTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        const Divider(
          thickness: 0.5,
        ),
        const Text(
          'Wiederholung',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ListTile(
          title: Text(_lableRepeatTyp),
          subtitle:
              const Text('Wähle zwischen täglich, wöchentlich und monatlich'),
          leading: const FaIcon(FontAwesomeIcons.rotate),
          onTap: () => _repeat(context, reminderProvider),
        ),
        const SizedBox(
          height: 5,
        ),
        if (_selectedRepeat == RepeatValues.weekly)
          _weekTile(context, reminderProvider),
        if (_selectedRepeat == RepeatValues.monthly)
          _monthTile(context, reminderProvider),
        const SizedBox(
          height: 5,
        ),
        const Text(
          'Uhrzeit',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ListTile(
          title: Text(_lableTime),
          subtitle: const Text('Wähle die Uhrzeit der Benachrichtigung.'),
          leading: const FaIcon(FontAwesomeIcons.clock),
          onTap: () => _timePicker(context, reminderProvider),
        ),
        // _testButton(reminderProvider),
      ],
    );
  }
}
