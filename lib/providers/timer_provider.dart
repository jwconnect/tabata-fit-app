import 'dart:async';
import 'package:flutter/material.dart';

enum TimerState { initial, ready, running, paused, finished }

enum IntervalType { prepare, work, rest, cooldown }

class TimerProvider with ChangeNotifier {
  static const int defaultWorkTime = 20;
  static const int defaultRestTime = 10;
  static const int defaultSets = 8;
  static const int defaultPrepareTime = 10;
  static const int defaultCooldownTime = 30;

  Timer? _timer;
  TimerState _state = TimerState.initial;
  IntervalType _intervalType = IntervalType.prepare;

  int _workTime = defaultWorkTime;
  int _restTime = defaultRestTime;
  int _sets = defaultSets;
  int _prepareTime = defaultPrepareTime;
  int _cooldownTime = defaultCooldownTime;

  int _currentSet = 0;
  int _currentTime = 0;
  int _totalTime = 0;

  TimerState get state => _state;
  IntervalType get intervalType => _intervalType;
  int get currentSet => _currentSet;
  int get currentTime => _currentTime;
  int get totalTime => _totalTime;
  int get sets => _sets;

  double get progress {
    if (_state == TimerState.initial || _state == TimerState.finished)
      return 0.0;

    int totalIntervalTime = 0;
    int currentIntervalTime = 0;

    switch (_intervalType) {
      case IntervalType.prepare:
        totalIntervalTime = _prepareTime;
        currentIntervalTime = _prepareTime - _currentTime;
        break;
      case IntervalType.work:
        totalIntervalTime = _workTime;
        currentIntervalTime = _workTime - _currentTime;
        break;
      case IntervalType.rest:
        totalIntervalTime = _restTime;
        currentIntervalTime = _restTime - _currentTime;
        break;
      case IntervalType.cooldown:
        totalIntervalTime = _cooldownTime;
        currentIntervalTime = _cooldownTime - _currentTime;
        break;
    }

    return currentIntervalTime / totalIntervalTime;
  }

  void setTimerSettings({
    int? workTime,
    int? restTime,
    int? sets,
    int? prepareTime,
    int? cooldownTime,
  }) {
    _workTime = workTime ?? _workTime;
    _restTime = restTime ?? _restTime;
    _sets = sets ?? _sets;
    _prepareTime = prepareTime ?? _prepareTime;
    _cooldownTime = cooldownTime ?? _cooldownTime;
    _state = TimerState.ready;
    _currentSet = 0;
    _currentTime = _prepareTime;
    _totalTime = _prepareTime + (_workTime + _restTime) * _sets + _cooldownTime;
    notifyListeners();
  }

  void startTimer() {
    if (_state == TimerState.running) return;

    if (_state == TimerState.initial || _state == TimerState.finished) {
      setTimerSettings(); // 기본 설정으로 초기화
      _state = TimerState.ready;
    }

    _state = TimerState.running;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentTime--;
      _totalTime--;

      if (_currentTime < 0) {
        _moveToNextInterval();
      }

      notifyListeners();
    });
    notifyListeners();
  }

  void pauseTimer() {
    if (_state != TimerState.running) return;
    _timer?.cancel();
    _state = TimerState.paused;
    notifyListeners();
  }

  void resumeTimer() {
    if (_state != TimerState.paused) return;
    startTimer();
  }

  void resetTimer() {
    _timer?.cancel();
    _state = TimerState.initial;
    _intervalType = IntervalType.prepare;
    _currentSet = 0;
    _currentTime = _prepareTime;
    _totalTime = _prepareTime + (_workTime + _restTime) * _sets + _cooldownTime;
    notifyListeners();
  }

  void _moveToNextInterval() {
    switch (_intervalType) {
      case IntervalType.prepare:
        _intervalType = IntervalType.work;
        _currentSet = 1;
        _currentTime = _workTime;
        break;
      case IntervalType.work:
        if (_currentSet < _sets) {
          _intervalType = IntervalType.rest;
          _currentTime = _restTime;
        } else {
          _intervalType = IntervalType.cooldown;
          _currentTime = _cooldownTime;
        }
        break;
      case IntervalType.rest:
        _intervalType = IntervalType.work;
        _currentSet++;
        _currentTime = _workTime;
        break;
      case IntervalType.cooldown:
        _timer?.cancel();
        _state = TimerState.finished;
        _currentTime = 0;
        break;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
