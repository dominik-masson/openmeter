import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/provider/reminder_provider.dart';

class MonthTile extends StatefulWidget {
  const MonthTile({super.key});

  @override
  State<MonthTile> createState() => _MonthTileState();
}

class _MonthTileState extends State<MonthTile> {
  int _selectedDay = 1;
  final _monthDays = List.generate(30, (index) => index + 1, growable: false);

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

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);

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
}
