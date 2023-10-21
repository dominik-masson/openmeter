import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../utils/log.dart';

class LocalNotificationHelper {
  late final FlutterLocalNotificationsPlugin _localNotification;
  final String _notificationTitle = 'Ableseerinnerung';
  final String _notificationBody =
      'Heute sollen die Zähler wieder abgelesen werden!';

  LocalNotificationHelper() {
    _localNotification = FlutterLocalNotificationsPlugin();
    _initTimeZone();
    _initLocalNotification();
  }

  Future<void> _initTimeZone() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
  }

  Future<void> _initLocalNotification() async {
    const androidSetting =
        AndroidInitializationSettings('@mipmap/ic_launcher_monochrome');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSetting,
    );

    await _localNotification.initialize(initializationSettings);
  }

  /*
    request notification permission
     for android 13 and higher
   */
  void requestPermission() {
    if (Platform.isAndroid) {
      _localNotification
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  NotificationDetails _notificationDetails() {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'reminder',
      'Ableseerinnerung',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      color: Color(0x00000000),
      icon: '@drawable/ic_stat_logo',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    return notificationDetails;
  }

  tz.TZDateTime _convertTime(int hour, int minute) {
    final tz.TZDateTime timeNow = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduleDate = tz.TZDateTime(
      tz.local,
      timeNow.year,
      timeNow.month,
      timeNow.day,
      hour,
      minute,
    );

    log('Set schedule date: $scheduleDate', name: LogNames.readingReminder);

    return scheduleDate;
  }

  void dailyReminder(int hour, int minute) async {
    await _localNotification.zonedSchedule(
      0,
      _notificationTitle,
      _notificationBody,
      _convertTime(hour, minute),
      _notificationDetails(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  tz.TZDateTime _convertTimeWeekly(int hour, int minute, int day) {
    tz.TZDateTime scheduleDate = _convertTime(hour, minute);

    while (!(scheduleDate.weekday == day)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }

    log('Set weekly schedule date: $scheduleDate', name: LogNames.readingReminder);

    return scheduleDate;
  }

  void weeklyReminder(int hour, int minute, int day) async {
    await _localNotification.zonedSchedule(
      0,
      _notificationTitle,
      _notificationBody,
      _convertTimeWeekly(hour, minute, day),
      _notificationDetails(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  tz.TZDateTime _convertTimeMonthly(int hour, int minute, int day) {
    tz.TZDateTime scheduleDate = _convertTime(hour, minute);

    while (scheduleDate.day != day) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }

    log('Set monthly schedule date: $scheduleDate', name: LogNames.readingReminder);

    return scheduleDate;
  }

  void monthlyReminder(int hour, int minute, int day) async {
    await _localNotification.zonedSchedule(
      0,
      _notificationTitle,
      _notificationBody,
      _convertTimeMonthly(hour, minute, day),
      _notificationDetails(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  void testNotification() async {
    await _localNotification.show(1, 'Test Ableseerinnerung',
        'Dies ist ein Test!', _notificationDetails());
  }

  void removeReminder() {
    _localNotification.cancelAll();
  }
}
