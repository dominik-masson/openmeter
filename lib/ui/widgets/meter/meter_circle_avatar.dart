import 'package:flutter/material.dart';

class MeterCircleAvatar extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double? size;

  const MeterCircleAvatar({
    super.key,
    required this.icon,
    required this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      maxRadius: size,
      backgroundColor: color,
      child: Icon(
        icon,
        color: Colors.white,
        size: size,
      ),
    );
  }
}
