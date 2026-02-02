import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sound_service.dart';

enum TimerState { initial, ready, running, paused, finished }

enum IntervalType { prepare, work, rest, cooldown }

class TimerProvider with ChangeNotifier {
  final SoundService _soundService = SoundService();
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
  String? _firstExerciseName;
  List<String> _exercises = [];
  int _currentExerciseIndex = 0;

  TimerState get state => _state;
  String? get firstExerciseName => _firstExerciseName;
  List<String> get exercises => _exercises;

  /// 사운드/진동 음소거 상태
  bool get isMuted => _soundService.isMuted;

  /// 사운드/진동 토글
  void toggleMute() {
    _soundService.setMuted(!_soundService.isMuted);
    notifyListeners();
  }

  /// 사운드/진동 설정
  void setMuted(bool muted) {
    _soundService.setMuted(muted);
    notifyListeners();
  }

  /// 현재 운동 이름 (운동 중일 때)
  String? get currentExerciseName {
    if (_exercises.isEmpty) return _firstExerciseName;
    if (_currentExerciseIndex >= _exercises.length) return _exercises.last;
    return _exercises[_currentExerciseIndex];
  }

  /// 다음 운동 이름 (휴식 중일 때 표시)
  String? get nextExerciseName {
    if (_exercises.isEmpty) return _firstExerciseName;
    final nextIndex = _currentExerciseIndex + 1;
    if (nextIndex >= _exercises.length) return null;
    return _exercises[nextIndex];
  }

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
    String? firstExerciseName,
    List<String>? exercises,
  }) {
    _workTime = workTime ?? _workTime;
    _restTime = restTime ?? _restTime;
    _sets = sets ?? _sets;
    _prepareTime = prepareTime ?? _prepareTime;
    _cooldownTime = cooldownTime ?? _cooldownTime;
    _firstExerciseName = firstExerciseName;
    _exercises = exercises ?? [];
    _currentExerciseIndex = 0;
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
    _soundService.init();

    // 준비 시작 시 첫 운동명 안내
    final firstExercise = _firstExerciseName ?? (_exercises.isNotEmpty ? _exercises[0] : null);
    if (firstExercise != null) {
      _soundService.playPrepareWithExercise(firstExercise);
    } else {
      _soundService.playPrepare();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTime <= 0) {
        _moveToNextInterval();
      } else {
        _currentTime--;
        _totalTime--;

        // 카운트다운 사운드 재생
        _playTickSound();
      }

      notifyListeners();
    });
    notifyListeners();
  }

  void _playTickSound() {
    // 마지막 5초는 강한 카운트다운 사운드 (5, 4, 3, 2, 1)
    if (_currentTime <= 5 && _currentTime > 0) {
      _soundService.playCountdown(_currentTime);
    }
    // 10초 남았을 때 알림 (운동 중만)
    else if (_currentTime == 10 && _intervalType == IntervalType.work) {
      _soundService.playTenSecondsWarning();
    }
    // 휴식 중간에 호흡 안내 (휴식 시간의 절반 지점)
    else if (_intervalType == IntervalType.rest &&
        _currentTime == (_restTime ~/ 2) &&
        _restTime >= 8) {
      _soundService.playBreathingGuide();
    }
    // 운동 중 중간에 동기부여 멘트 (운동 시간의 절반 지점)
    else if (_intervalType == IntervalType.work &&
        _currentTime == (_workTime ~/ 2) &&
        _workTime >= 15) {
      _soundService.playMotivation();
    }
    // 준비/운동 중에는 틱 사운드 (6초 이상일 때만)
    else if (_currentTime > 5 &&
        (_intervalType == IntervalType.prepare ||
            _intervalType == IntervalType.work)) {
      _soundService.playTick(_currentTime);
    }
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
    _currentExerciseIndex = 0;
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
        // 운동 시작 + 운동명 안내
        final exerciseName = currentExerciseName;
        if (exerciseName != null) {
          _soundService.playWorkStartWithExercise(exerciseName);
        } else {
          _soundService.playWorkStart();
        }
        break;
      case IntervalType.work:
        if (_currentSet < _sets) {
          _intervalType = IntervalType.rest;
          _currentTime = _restTime;
          // 휴식 시작 + 다음 운동 안내
          _soundService.playRestStartWithNext(nextExerciseName);
        } else {
          _intervalType = IntervalType.cooldown;
          _currentTime = _cooldownTime;
          _soundService.playCooldownStart(); // 정리운동 시작 사운드
        }
        break;
      case IntervalType.rest:
        _intervalType = IntervalType.work;
        _currentSet++;
        _currentExerciseIndex++;
        _currentTime = _workTime;
        // 운동 시작 + 운동명 안내 + 힘내라 응원
        final nextExercise = currentExerciseName;
        if (nextExercise != null) {
          _soundService.playWorkStartWithExercise(nextExercise);
        } else {
          _soundService.playWorkStart();
        }
        // 세트 후반부에 응원 멘트 추가
        if (_currentSet > _sets ~/ 2) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            _soundService.playEncouragement();
          });
        }
        break;
      case IntervalType.cooldown:
        _timer?.cancel();
        _state = TimerState.finished;
        _currentTime = 0;
        _soundService.playFinish(); // 완료 사운드
        break;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
