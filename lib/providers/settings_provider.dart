import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/sound_service.dart';

class SettingsProvider with ChangeNotifier {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkMode = false;
  String _language = 'ko';

  // 알림 설정
  bool _reminderEnabled = false;
  int _reminderHour = 9; // 기본 오전 9시
  int _reminderMinute = 0;

  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get darkMode => _darkMode;
  String get language => _language;

  // 알림 관련 getter
  bool get reminderEnabled => _reminderEnabled;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;
  TimeOfDay get reminderTime => TimeOfDay(hour: _reminderHour, minute: _reminderMinute);
  String get reminderTimeString {
    final period = _reminderHour < 12 ? '오전' : '오후';
    final hour = _reminderHour > 12 ? _reminderHour - 12 : (_reminderHour == 0 ? 12 : _reminderHour);
    final minute = _reminderMinute.toString().padLeft(2, '0');
    return '$period $hour:$minute';
  }

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    _darkMode = prefs.getBool('darkMode') ?? false;
    _language = prefs.getString('language') ?? 'ko';

    // 알림 설정 로드
    _reminderEnabled = prefs.getBool('reminderEnabled') ?? false;
    _reminderHour = prefs.getInt('reminderHour') ?? 9;
    _reminderMinute = prefs.getInt('reminderMinute') ?? 0;

    // 알림이 활성화되어 있으면 다시 예약
    if (_reminderEnabled) {
      await NotificationService().init();
      await NotificationService().scheduleDailyReminder(
        hour: _reminderHour,
        minute: _reminderMinute,
      );
    }

    // SoundService에 사운드/진동 설정 동기화
    SoundService().setMuted(!_soundEnabled);
    SoundService().setVibrationEnabled(_vibrationEnabled);

    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', value);
    // SoundService에 사운드 설정 동기화
    SoundService().setMuted(!value);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibrationEnabled', value);
    // SoundService에 진동 설정 동기화
    SoundService().setVibrationEnabled(value);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
    notifyListeners();
  }

  /// 알림 활성화/비활성화
  Future<void> setReminderEnabled(bool value) async {
    _reminderEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminderEnabled', value);

    final notificationService = NotificationService();
    await notificationService.init();

    if (value) {
      // 권한 요청
      final granted = await notificationService.requestPermission();
      if (granted) {
        await notificationService.scheduleDailyReminder(
          hour: _reminderHour,
          minute: _reminderMinute,
        );
      } else {
        // 권한 거부 시 비활성화
        _reminderEnabled = false;
        await prefs.setBool('reminderEnabled', false);
      }
    } else {
      await notificationService.cancelDailyReminder();
    }

    notifyListeners();
  }

  /// 알림 시간 설정
  Future<void> setReminderTime(int hour, int minute) async {
    _reminderHour = hour;
    _reminderMinute = minute;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminderHour', hour);
    await prefs.setInt('reminderMinute', minute);

    // 알림이 활성화되어 있으면 새 시간으로 다시 예약
    if (_reminderEnabled) {
      final notificationService = NotificationService();
      await notificationService.init();
      await notificationService.scheduleDailyReminder(
        hour: hour,
        minute: minute,
      );
    }

    notifyListeners();
  }

  /// 테스트 알림 발송
  Future<void> sendTestNotification() async {
    final notificationService = NotificationService();
    await notificationService.init();
    await notificationService.requestPermission();
    await notificationService.showTestNotification();
  }
}
