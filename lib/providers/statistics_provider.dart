import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_session.dart';

class StatisticsProvider with ChangeNotifier {
  static const String _storageKey = 'workout_sessions';
  final List<WorkoutSession> _sessions = [];
  bool _isInitialized = false;

  List<WorkoutSession> get sessions => List.unmodifiable(_sessions);

  int get totalWorkouts => _sessions.length;

  /// 앱 시작 시 저장된 데이터 로드
  Future<void> init() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        _sessions.clear();
        _sessions.addAll(
          jsonList.map((j) => WorkoutSession.fromJson(j)).toList(),
        );
        notifyListeners();
      } catch (e) {
        debugPrint('운동 기록 로드 실패: $e');
      }
    }

    _isInitialized = true;
  }

  /// 데이터를 SharedPreferences에 저장
  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  int get totalDuration {
    return _sessions.fold(0, (sum, session) => sum + session.duration);
  }

  double get totalCalories {
    return _sessions.fold(0.0, (sum, session) => sum + session.calories);
  }

  int get currentStreak {
    if (_sessions.isEmpty) return 0;

    final sortedSessions = List<WorkoutSession>.from(_sessions)
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime checkDate = DateTime.now();
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

    for (var session in sortedSessions) {
      final sessionDate = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );

      if (sessionDate == checkDate ||
          sessionDate == checkDate.subtract(const Duration(days: 1))) {
        if (sessionDate != checkDate) {
          checkDate = sessionDate;
        }
        streak++;
      } else if (sessionDate.isBefore(
        checkDate.subtract(const Duration(days: 1)),
      )) {
        break;
      }
    }

    return streak;
  }

  List<WorkoutSession> get todaySessions {
    final today = DateTime.now();
    return _sessions
        .where(
          (s) =>
              s.date.year == today.year &&
              s.date.month == today.month &&
              s.date.day == today.day,
        )
        .toList();
  }

  List<WorkoutSession> get thisWeekSessions {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );

    return _sessions.where((s) => s.date.isAfter(startOfWeek)).toList();
  }

  Map<int, int> get weeklyStats {
    final Map<int, int> stats = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

    for (var session in thisWeekSessions) {
      final weekday = session.date.weekday;
      stats[weekday] = (stats[weekday] ?? 0) + session.duration;
    }

    return stats;
  }

  Future<void> addSession(WorkoutSession session) async {
    _sessions.add(session);
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> removeSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
    await _saveToStorage();
    notifyListeners();
  }

  String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours시간 $minutes분';
    }
    return '$minutes분';
  }
}
