import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../ui/screens/settings_screens/reminder_screen.dart';
import '../enums/notifications_repeat_values.dart';
import '../services/local_notification_helper.dart';

class ReminderProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  final String keyActive = 'reminder_state';
  final String keyRepeat = 'repeat_interval';
  final String keyWeekDay = 'repeat_week_day_new';
  final String keyHour = 'time_hour';
  final String keyMinute = 'time_minute';
  final String keyMonthDay = 'month_day';
  final String keyFirstOn = 'first_reminder_on';
  late final LocalNotificationHelper _localNotificationHelper;

  bool _isActive = false;
  bool _firstReminderOn = false;
  RepeatValues _repeatInterval = RepeatValues.daily;
  int _weekDay = 0;
  int _minute = 0;
  int _hour = 0;
  int _monthDay = 1;

  ReminderProvider() {
    _localNotificationHelper = LocalNotificationHelper();
    _loadFromPrefs();
  }

  bool get isActive => _isActive;

  RepeatValues get repeatInterval => _repeatInterval;

  int get weekDay => _weekDay;

  int get timeHour => _hour;

  int get timeMinute => _minute;

  int get monthDay => _monthDay;

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();

    _isActive = _prefs.getBool(keyActive) ?? false;

    var repeatVal = _prefs.getString(keyRepeat);
    switch (repeatVal) {
      case 'daily':
        _repeatInterval = RepeatValues.daily;
        break;
      case 'weekly':
        _repeatInterval = RepeatValues.weekly;
        break;
      default:
        _repeatInterval = RepeatValues.monthly;
        break;
    }

    _weekDay = _prefs.getInt(keyWeekDay) ?? 0;

    _hour = _prefs.getInt(keyHour) ?? 0;
    _minute = _prefs.getInt(keyMinute) ?? 0;

    _monthDay = _prefs.getInt(keyMonthDay) ?? 1;

    notifyListeners();
  }

  void _displayNotification() async {
    // daily reminder
    if (_repeatInterval == RepeatValues.daily) {
      _localNotificationHelper.dailyReminder(_hour, _minute);
    }

    // weekly reminders
    if (_repeatInterval == RepeatValues.weekly) {
      _localNotificationHelper.weeklyReminder(_hour, _minute, _weekDay + 1);
    }

    // monthly reminder
    if (_repeatInterval == RepeatValues.monthly) {
      _localNotificationHelper.monthlyReminder(_hour, _minute, _monthDay);
    }
  }

  void testNotification() async {
    _localNotificationHelper.testNotification();
  }

  void setActive(bool state) {
    _isActive = state;
    _prefs.setBool(keyActive, _isActive);

    if (!_firstReminderOn) {
      _prefs.setBool(keyFirstOn, true);
      _firstReminderOn = true;
      _localNotificationHelper.requestPermission();
    }

    if (!_isActive) {
      _localNotificationHelper.removeReminder();
    } else {
      _displayNotification();
    }

    notifyListeners();
  }

  void setRepeat(RepeatValues interval) {
    _repeatInterval = interval;
    _prefs.setString(keyRepeat, _repeatInterval.name);
    _displayNotification();
    notifyListeners();
  }

  void setWeekDay(int day) {
    _weekDay = day;
    _prefs.setInt(keyWeekDay, _weekDay);
    _displayNotification();
    notifyListeners();
  }

  void setTime(int hour, int minute) {
    _hour = hour;
    _minute = minute;

    _prefs.setInt(keyHour, _hour);
    _prefs.setInt(keyMinute, _minute);

    _displayNotification();
    notifyListeners();
  }

  void setMonthDay(int day) {
    _monthDay = day;
    _prefs.setInt(keyMonthDay, _monthDay);
    _displayNotification();
    notifyListeners();
  }
}
