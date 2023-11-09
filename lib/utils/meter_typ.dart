import 'package:flutter/material.dart';

import '../core/model/meter_typ.dart';
import 'custom_icons.dart';

final List<MeterTyp> meterTyps = [
  MeterTyp(
    meterTyp: 'Stromzähler',
    unit: 'kwh',
    providerTitle: 'Stromanbieter',
    avatar: CustomAvatar(
      color: Colors.green,
      icon: CustomIcons.power_plug,
    ),
  ),
  MeterTyp(
    meterTyp: 'Photovoltaikanlage',
    unit: 'kwh',
    providerTitle: '',
    avatar: CustomAvatar(
      color: Colors.orange,
      icon: CustomIcons.power_plug,
    ),
  ),
  MeterTyp(
    meterTyp: 'Solarthermieanlage',
    unit: 'kwh',
    providerTitle: '',
    avatar: CustomAvatar(
      color: Colors.yellow,
      icon: CustomIcons.sun,
    ),
  ),
  MeterTyp(
    meterTyp: 'Kaltwasserzähler',
    unit: 'l',
    providerTitle: 'Wassergebühren',
    avatar: CustomAvatar(
      color: Colors.blue,
      icon: CustomIcons.water,
    ),
  ),
  MeterTyp(
    meterTyp: 'Warmwasserzähler',
    unit: 'l',
    providerTitle: 'Wassergebühren',
    avatar: CustomAvatar(
      color: Colors.red,
      icon: CustomIcons.water,
    ),
  ),
  MeterTyp(
    meterTyp: 'Heizung',
    unit: 'kWh',
    providerTitle: 'Heizungsgebühren',
    avatar: CustomAvatar(
      color: Colors.orange,
      icon: CustomIcons.heater,
    ),
  ),
  MeterTyp(
    meterTyp: 'Gaszähler',
    unit: 'kWh',
    providerTitle: 'Heizungsgebühren',
    avatar: CustomAvatar(
      color: Colors.blueGrey,
      icon: CustomIcons.flamme,
    ),
  ),
];
