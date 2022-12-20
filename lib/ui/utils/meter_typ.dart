import 'package:flutter/material.dart';

import 'custom_icons.dart';

Map<String, dynamic> meterTyps = {
  'Stromzähler': {
    'einheit': 'kWh',
    'anbieter': 'Stromanbieter',
    'avatar': const CircleAvatar(
      backgroundColor: Colors.green,
      child: Icon(
        CustomIcons.power_plug,
        color: Colors.white,
      ),
    )
  },
  'Photovoltaikanlage': {
    'einheit': 'kWh',
    'anbieter': '',
    'avatar': const CircleAvatar(
      backgroundColor: Colors.orange,
      child: Icon(
        CustomIcons.power_plug,
        color: Colors.white,
      ),
    ),
  },
  'Solarthermieanlage': {
    'einheit': 'kWh',
    'anbieter': '',
    'avatar': const CircleAvatar(
      backgroundColor: Colors.yellow,
      child: Icon(
        CustomIcons.sun,
        color: Colors.white,
      ),
    ),
  },
  'Kaltwasserzähler': {
    'einheit': 'l',
    'anbieter': 'Wassergebühren',
    'avatar': const CircleAvatar(
      backgroundColor: Colors.blue,
      child: Icon(
        CustomIcons.water,
        color: Colors.white,
      ),
    ),
  },
  'Warmwasserzähler': {
    'einheit': 'l',
    'anbieter': 'Wassergebühren',
    'avatar': const CircleAvatar(
      backgroundColor: Colors.red,
      child: Icon(
        CustomIcons.water,
        color: Colors.white,
      ),
    ),
  },
  'Heizung': {
    'einheit': 'Einheit',
    'anbieter': 'Heizungsgebühren',
    'avatar': const CircleAvatar(
      backgroundColor: Colors.orange,
      child: Icon(
        CustomIcons.heater,
        color: Colors.white,
      ),
    ),
  },
  'Gaszähler': {
    'einheit': 'kWh',
    'anbieter': 'Heizungsgebühren',
    'avatar': const CircleAvatar(
      backgroundColor: Colors.blueGrey,
      child: Icon(
        CustomIcons.flamme,
        color: Colors.white,
      ),
    ),
  },
};
