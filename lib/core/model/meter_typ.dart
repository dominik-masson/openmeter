import 'package:flutter/material.dart';

class MeterTyp {
  final String meterTyp;
  final String unit;
  final String providerTitle;
  final CustomAvatar avatar;

  MeterTyp(
      {required this.meterTyp,
      required this.unit,
      required this.providerTitle,
      required this.avatar});
}

class CustomAvatar {
  final IconData icon;
  final Color color;

  CustomAvatar({required this.icon, required this.color});
}
