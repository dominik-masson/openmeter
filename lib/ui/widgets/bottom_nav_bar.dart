import 'package:flutter/material.dart';

import '../screens/homescreen.dart';
import '../screens/objects.dart';
import '../utils/custom_icons.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List _screen = const [
    HomeScreen(),
    ObjectsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screen[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).bottomAppBarTheme.color,
        currentIndex: _currentIndex,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(CustomIcons.voltmeter), label: 'Zähler'),
          BottomNavigationBarItem(icon: Icon(Icons.widgets), label: 'Objekte')
        ],
      ),
    );
  }
}
