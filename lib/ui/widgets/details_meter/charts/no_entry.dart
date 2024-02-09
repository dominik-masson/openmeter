import 'package:flutter/material.dart';

class NoEntry extends StatelessWidget {
  final String text;
  final bool showHintText;
  const NoEntry({super.key, required this.text, this.showHintText = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/icons/no_data.png',
          width: 100,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 10,
        ),
        if (showHintText)
          const Text(
            'Drücke jetzt auf das Plus um neue Einträge zu erstellen!',
            style: TextStyle(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
