import 'package:flutter/material.dart';

import 'custom_icons.dart';

Map<String, dynamic> meterTyps = {
  'Stromzähler': {
    'einheit': 'kWh',
    'anbieter': 'Stromanbieter',
    'avatar': {
      'icon': CustomIcons.power_plug,
      'color': Colors.green,
    },
  },
  'Photovoltaikanlage': {
    'einheit': 'kWh',
    'anbieter': '',
    'avatar': {
      'icon': CustomIcons.power_plug,
      'color': Colors.orange,
    },
  },
  'Solarthermieanlage': {
    'einheit': 'kWh',
    'anbieter': '',
    'avatar': {
      'icon': CustomIcons.sun,
      'color': Colors.yellow,
    },
  },
  'Kaltwasserzähler': {
    'einheit': 'l',
    'anbieter': 'Wassergebühren',
    'avatar': {
      'icon': CustomIcons.water,
      'color': Colors.blue,
    },
  },
  'Warmwasserzähler': {
    'einheit': 'l',
    'anbieter': 'Wassergebühren',
    'avatar': {
      'icon': CustomIcons.water,
      'color': Colors.red,
    },
  },
  'Heizung': {
    'einheit': 'kWh',
    'anbieter': 'Heizungsgebühren',
    'avatar': {
      'icon': CustomIcons.heater,
      'color': Colors.orange,
    },
  },
  'Gaszähler': {
    'einheit': 'kWh',
    'anbieter': 'Heizungsgebühren',
    'avatar': {
      'icon': CustomIcons.flamme,
      'color': Colors.blueGrey,
    },
  },
};
