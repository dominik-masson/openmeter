import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/enums/font_size_value.dart';
import '../../../core/provider/theme_changer.dart';

class FontSizeTile extends StatefulWidget {
  const FontSizeTile({super.key});

  @override
  State<FontSizeTile> createState() => _FontSizeTileState();
}

class _FontSizeTileState extends State<FontSizeTile> {
  FontSizeValue _selectedFontSize = FontSizeValue.normal;

  _showDialog(ThemeChanger provider) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Schriftgröße auswählen',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile(
                    contentPadding: EdgeInsets.zero,
                    value: FontSizeValue.small,
                    groupValue: _selectedFontSize,
                    title: const Text('Klein'),
                    onChanged: (value) {
                      setState(
                        () {
                          _selectedFontSize = value!;
                        },
                      );

                      provider.setFontSize(_selectedFontSize);

                      Navigator.of(context).pop();
                    },
                  ),
                  RadioListTile(
                    contentPadding: EdgeInsets.zero,
                    value: FontSizeValue.normal,
                    groupValue: _selectedFontSize,
                    title: const Text('Normal'),
                    onChanged: (value) {
                      setState(
                        () {
                          _selectedFontSize = value!;
                        },
                      );

                      provider.setFontSize(_selectedFontSize);
                      Navigator.of(context).pop();
                    },
                  ),
                  RadioListTile(
                    contentPadding: EdgeInsets.zero,
                    value: FontSizeValue.large,
                    groupValue: _selectedFontSize,
                    title: const Text('Groß'),
                    onChanged: (value) {
                      setState(
                        () {
                          _selectedFontSize = value!;
                        },
                      );

                      provider.setFontSize(_selectedFontSize);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  _getFontSizeValueText() {
    switch (_selectedFontSize) {
      case FontSizeValue.small:
        return 'Klein';
      case FontSizeValue.normal:
        return 'Normal';
      default:
        return 'Groß';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChanger = Provider.of<ThemeChanger>(context);

    _selectedFontSize = themeChanger.getFontSizeValue;

    return ListTile(
      onTap: () => _showDialog(themeChanger),
      title: Text(
        'Schriftgröße',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Text(_getFontSizeValueText()),
    );
  }
}
