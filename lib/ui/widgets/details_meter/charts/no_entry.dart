import 'package:flutter/material.dart';

class NoEntry {
  NoEntry();

  Widget getNoData(String text) {

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
          textAlign:TextAlign.center,
        ),
        const SizedBox(
          height: 10,
        ),
        const Text(
          'Drücke jetzt auf das Plus um neue Einträge zu erstellen!',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
