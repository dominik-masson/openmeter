import 'package:flutter/material.dart';
import '../../../core/enums/notifications_repeat_values.dart';
import '../../../core/provider/reminder_provider.dart';

class RepeatDialogWidget {
  RepeatValues? _selectedRepeat = RepeatValues.daily;

  repeat(BuildContext context, ReminderProvider provider) {
    _selectedRepeat = provider.repeatInterval;

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
}
