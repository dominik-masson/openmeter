import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/enums/notifications_repeat_values.dart';
import '../../../core/provider/reminder_provider.dart';
import 'month_tile.dart';
import 'repeat_dialog_widgets.dart';
import 'time_picker_tile.dart';
import 'week_tile.dart';

class ActiveReminder extends StatefulWidget {
  const ActiveReminder({super.key});

  @override
  State<ActiveReminder> createState() => _ActiveReminderState();
}

class _ActiveReminderState extends State<ActiveReminder> {
  RepeatValues? _selectedRepeat = RepeatValues.daily;

  String _lableRepeatTyp = 'Wöchentlich';

  final RepeatDialogWidget _dialogWidgets = RepeatDialogWidget();

  _loadFromPrefs(ReminderProvider reminderProvider) {
    _selectedRepeat = reminderProvider.repeatInterval;
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

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);

    _loadFromPrefs(reminderProvider);

    _lableRepeatTyp = _getRepeatTyp();

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
          onTap: () => _dialogWidgets.repeat(context, reminderProvider),
        ),
        const SizedBox(
          height: 5,
        ),
        if (_selectedRepeat == RepeatValues.weekly) const WeekTile(),
        if (_selectedRepeat == RepeatValues.monthly) const MonthTile(),
        const SizedBox(
          height: 5,
        ),
        const TimePickerTile(),
      ],
    );
  }
}
