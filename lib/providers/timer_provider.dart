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
  String? _workoutName; // 운동 프로그램 이름
  List<String> _exercises = [];
  int _currentExerciseIndex = 0;
  bool _hasRecordedSession = false; // 세션 기록 여부 추적

  TimerState get state => _state;
  String? get firstExerciseName => _firstExerciseName;
  String? get workoutName => _workoutName; // 운동 프로그램 이름
  List<String> get exercises => _exercises;
  bool get hasRecordedSession => _hasRecordedSession;

  /// 세션 기록 완료 표시 (외부에서 기록 후 호출)
  void markSessionRecorded() {
    _hasRecordedSession = true;
  }

  /// 사운드/진동 음소거 상태
  bool get isMuted => _soundService.isMuted;

  /// 사운드/진동 토글
  void toggleMute() {
    _soundService.setMuted(!_soundService.isMuted);
    notifyListeners();
  }

  /// 사운드 설정
  void setMuted(bool muted) {
    _soundService.setMuted(muted);
    notifyListeners();
  }

  /// 진동 활성화 상태
  bool get isVibrationEnabled => _soundService.isVibrationEnabled;

  /// 진동 설정
  void setVibrationEnabled(bool enabled) {
    _soundService.setVibrationEnabled(enabled);
    notifyListeners();
  }

  /// 현재 표시 중인 동기부여 멘트 (화면에 표시)
  String? get currentDisplayMessage => _soundService.currentDisplayMessage;

  /// 표시 멘트 초기화 (일정 시간 후 호출)
  void clearDisplayMessage() {
    _soundService.clearDisplayMessage();
    notifyListeners();
  }

  /// 멘트 표시 후 자동 제거 예약 (5초 후)
  void _scheduleMessageClear() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_soundService.currentDisplayMessage != null) {
        _soundService.clearDisplayMessage();
        notifyListeners();
      }
    });
  }

  /// 현재 운동 이름 (운동 중일 때) - 순환 반복
  String? get currentExerciseName {
    if (_exercises.isEmpty) return _firstExerciseName;
    // 운동 목록을 순환 (1,2,3,4,1,2,3,4...)
    final index = _currentExerciseIndex % _exercises.length;
    return _exercises[index];
  }

  /// 다음 운동 이름 (휴식 중일 때 표시) - 순환 반복
  String? get nextExerciseName {
    if (_exercises.isEmpty) return _firstExerciseName;
    // 다음 세트가 마지막 세트를 초과하면 null (정리운동으로 전환)
    if (_currentSet >= _sets) return null;
    // 다음 운동 인덱스도 순환
    final nextIndex = (_currentExerciseIndex + 1) % _exercises.length;
    return _exercises[nextIndex];
  }

  /// 총 운동 종류 개수
  int get exerciseCount => _exercises.length;

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
    String? workoutName,
    List<String>? exercises,
  }) {
    _workTime = workTime ?? _workTime;
    _restTime = restTime ?? _restTime;
    _sets = sets ?? _sets;
    _prepareTime = prepareTime ?? _prepareTime;
    _cooldownTime = cooldownTime ?? _cooldownTime;
    _firstExerciseName = firstExerciseName;
    _workoutName = workoutName;
    _exercises = exercises ?? [];
    _currentExerciseIndex = 0;
    _state = TimerState.ready;
    _currentSet = 0;
    _currentTime = _prepareTime;
    _totalTime = _prepareTime + (_workTime + _restTime) * _sets + _cooldownTime;
    _hasRecordedSession = false; // 새 세션 시작 시 리셋
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
    final firstExercise =
        _firstExerciseName ?? (_exercises.isNotEmpty ? _exercises[0] : null);
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
    // 마지막 5초는 강한 카운트다운 사운드 (5, 4, 3, 2, 1) - critical 우선순위
    if (_currentTime <= 5 && _currentTime > 0) {
      _soundService.playCountdown(_currentTime);
    }
    // 10초 남았을 때 - 음성 격려 + 화면 팁 (운동 중만)
    else if (_currentTime == 10 && _intervalType == IntervalType.work) {
      _soundService.playFinalPushEncouragement(); // 음성: "마지막이에요!" 등
      _soundService.showWorkDisplayTip(); // 화면: 자세 팁
      notifyListeners();
      _scheduleMessageClear();
    }
    // 운동 중간에 음성 격려 (운동 시간의 2/3 지점)
    else if (_intervalType == IntervalType.work &&
        _currentTime == (_workTime * 2 ~/ 3) &&
        _workTime >= 15) {
      _soundService.playWorkVoiceEncouragement(); // 음성만: "좋아요!" 등
    }
    // 운동 시작 직후 화면에 팁 표시 (운동 시간 - 3초 지점)
    else if (_intervalType == IntervalType.work &&
        _currentTime == (_workTime - 3) &&
        _workTime >= 10) {
      _soundService.showWorkDisplayTip(); // 화면만: 자세 팁
      notifyListeners();
      _scheduleMessageClear();
    }
    // 휴식 시작 직후 화면에 팁 표시 (휴식 시간 - 2초 지점)
    else if (_intervalType == IntervalType.rest &&
        _currentTime == (_restTime - 2) &&
        _restTime >= 8) {
      _soundService.showRestDisplayTip(); // 화면만: 호흡/준비 안내
      notifyListeners();
      _scheduleMessageClear();
    }
    // 휴식 중간에 음성 안내 (휴식 시간의 절반 지점)
    else if (_intervalType == IntervalType.rest &&
        _currentTime == (_restTime ~/ 2) &&
        _restTime >= 8) {
      _soundService.playRestVoiceGuide(); // 음성만: "호흡을 가다듬으세요" 등
    }
    // 정리운동 중 음성 + 화면 안내 (매 5초마다)
    else if (_intervalType == IntervalType.cooldown && _currentTime > 5) {
      // 시작 직후 또는 매 5초마다 화면 팁 표시
      if (_currentTime == _cooldownTime - 2 || _currentTime % 5 == 0) {
        _soundService.showCooldownDisplayTip(); // 화면: 스트레칭 안내
        notifyListeners();
        _scheduleMessageClear();
      }
      // 매 7초마다 음성 안내 (화면 팁과 겹치지 않게)
      if (_currentTime % 7 == 0) {
        _soundService.playCooldownVoiceGuide(); // 음성: 부드러운 안내
      }
    }
    // 준비/운동 중에는 틱 사운드 (6초 이상일 때만) - low 우선순위
    else if (_currentTime > 5 &&
        (_intervalType == IntervalType.prepare ||
            _intervalType == IntervalType.work)) {
      // 중요 멘트 재생 중이면 숫자 TTS 생략 (햅틱만)
      if (_soundService.isSpeaking) {
        _soundService.playTickHapticOnly();
      } else {
        _soundService.playTick(_currentTime);
      }
    }
  }

  void pauseTimer() {
    if (_state != TimerState.running) return;
    _timer?.cancel();
    _soundService.stop(); // TTS 중지
    _state = TimerState.paused;
    notifyListeners();
  }

  void resumeTimer() {
    if (_state != TimerState.paused) return;
    startTimer();
  }

  /// 정리운동 건너뛰고 운동 완료 처리
  void finishWorkout() {
    _timer?.cancel();
    _state = TimerState.finished;
    _intervalType = IntervalType.cooldown;
    _currentTime = 0;
    _soundService.playFinish();
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _soundService.stop(); // TTS 중지
    _state = TimerState.initial;
    _intervalType = IntervalType.prepare;
    _currentSet = 0;
    _currentExerciseIndex = 0;
    _currentTime = _prepareTime;
    _totalTime = _prepareTime + (_workTime + _restTime) * _sets + _cooldownTime;
    _hasRecordedSession = false; // 리셋 시 플래그 초기화
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
        // 다음 세트로 증가
        _currentSet++;
        _currentExerciseIndex++;

        // 모든 세트 완료 체크 (마지막 세트 운동 후 휴식이 끝났을 때)
        if (_currentSet > _sets) {
          _intervalType = IntervalType.cooldown;
          _currentTime = _cooldownTime;
          _soundService.playCooldownStart();
        } else {
          _intervalType = IntervalType.work;
          _currentTime = _workTime;
          // 운동 시작 + 운동명 안내
          final nextExercise = currentExerciseName;
          if (nextExercise != null) {
            _soundService.playWorkStartWithExercise(nextExercise);
          } else {
            _soundService.playWorkStart();
          }
          // 세트 후반부에 음성 응원 추가
          if (_currentSet > _sets ~/ 2) {
            Future.delayed(const Duration(milliseconds: 1500), () {
              _soundService.playWorkVoiceEncouragement();
            });
          }
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
