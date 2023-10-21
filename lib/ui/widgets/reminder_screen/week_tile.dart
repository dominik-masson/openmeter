import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/provider/reminder_provider.dart';

class WeekTile extends StatefulWidget {
  const WeekTile({super.key});

  @override
  State<WeekTile> createState() => _WeekTileState();
}

class _WeekTileState extends State<WeekTile> {
  String _selectedWeek = 'Montag';

  final weekDays = [
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
    'Samstag',
    'Sonntag'
  ];

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

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);

    if (reminderProvider.weekDay != 0) {
      _selectedWeek = weekDays.elementAt(reminderProvider.weekDay);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wochentag',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        ListTile(
          title: Text(
            _selectedWeek,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: const Text('Wähle den Wochentag der Benachrichtigung.'),
          leading: const FaIcon(FontAwesomeIcons.calendarDay),
          onTap: () => _weekDaysDialog(context, reminderProvider),
        ),
      ],
    );
  }
}
