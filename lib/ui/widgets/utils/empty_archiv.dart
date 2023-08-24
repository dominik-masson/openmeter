import 'package:flutter/material.dart';

class EmptyArchiv extends StatelessWidget {
  const EmptyArchiv({super.key});

  @override
  Widget build(BuildContext context) {
    return  Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/empty_archiv.png',
            width: 150,
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Es wurden noch keine Zähler archiviert.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
