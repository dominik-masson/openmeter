import 'package:flutter/material.dart';

class SelectedItemsBar extends StatelessWidget {
  final List<TextButton> buttons;

  const SelectedItemsBar({super.key, required this.buttons});

  @override
  Widget build(BuildContext context) {
    final MainAxisAlignment alignment = buttons.length < 3
        ? MainAxisAlignment.spaceAround
        : MainAxisAlignment.spaceBetween;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Card(
          elevation: 10,
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          child: SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: alignment,
              children: buttons,
            ),
          ),
        ),
      ),
    );
  }
}
