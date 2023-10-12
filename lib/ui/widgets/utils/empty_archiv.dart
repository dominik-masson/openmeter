import 'package:flutter/material.dart';

class EmptyArchiv extends StatelessWidget {
  final String titel;

  const EmptyArchiv({super.key, required this.titel});

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
          Text(
            titel,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
