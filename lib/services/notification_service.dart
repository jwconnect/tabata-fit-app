import 'dart:io';
import 'dart:ui' show Color;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// 로컬 알림 서비스 - 매일 운동 리마인더
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // 알림 ID
  static const int _dailyReminderId = 1;

  // 동기부여 메시지 목록
  static const List<String> _motivationMessages = [
    '오늘도 4분만 투자해볼까요? 💪',
    '건강한 하루의 시작! 타바타 운동으로 에너지 충전하세요',
    '꾸준함이 실력입니다. 오늘도 함께해요!',
    '잠깐의 운동이 하루를 바꿉니다 🔥',
    '오늘 운동 아직 안 하셨죠? 지금 시작해보세요!',
    '4분이면 충분해요. 같이 땀 흘려볼까요?',
    '연속 기록을 이어가세요! 오늘도 파이팅 💯',
  ];

  Future<void> init() async {
    if (_isInitialized) return;

    // 타임존 초기화
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    // Android 설정
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    debugPrint('NotificationService 초기화 완료');
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('알림 탭됨: ${response.payload}');
    // 앱이 열리면 자동으로 홈 화면으로 이동
  }

  /// 알림 권한 요청
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    } else if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final result = await androidPlugin?.requestNotificationsPermission();
      return result ?? false;
    }
    return false;
  }

  /// 매일 알림 예약
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    // 기존 알림 취소
    await cancelDailyReminder();

    // 랜덤 메시지 선택
    final message = _motivationMessages[
        DateTime.now().millisecondsSinceEpoch % _motivationMessages.length];

    // 알림 상세 설정
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      '운동 리마인더',
      channelDescription: '매일 운동을 잊지 않도록 알려드립니다',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFF3B30),
      enableLights: true,
      ledColor: Color(0xFFFF3B30),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 다음 알림 시간 계산
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // 이미 지난 시간이면 다음 날로 설정
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id: _dailyReminderId,
      title: '타바타 운동 시간이에요! 🏋️',
      body: message,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 반복
      payload: 'daily_reminder',
    );

    debugPrint('매일 알림 예약됨: $hour:$minute');
  }

  /// 매일 알림 취소
  Future<void> cancelDailyReminder() async {
    await _notifications.cancel(id: _dailyReminderId);
    debugPrint('매일 알림 취소됨');
  }

  /// 테스트 알림 즉시 발송
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      '테스트 알림',
      channelDescription: '알림 테스트용',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id: 0,
      title: '타바타 운동 시간이에요! 🏋️',
      body: '오늘도 4분만 투자해볼까요? 💪',
      notificationDetails: notificationDetails,
    );
  }

  /// 예약된 알림 목록 확인
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
