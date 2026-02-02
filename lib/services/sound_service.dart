import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 타이머 사운드 서비스 (TTS + 시스템 사운드 + 햅틱)
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final FlutterTts _tts = FlutterTts();

  bool _isInitialized = false;
  bool _isMuted = false;
  bool _isSpeaking = false;

  bool get isMuted => _isMuted;

  // 동기부여 멘트 리스트
  static const List<String> _motivationMessages = [
    '자신의 페이스에 맞게 운동하세요',
    '영상에 의존하지 말고 자신의 몸에 집중하세요',
    '무리하지 말고 꾸준히 하는게 중요해요',
  ];
  int _motivationIndex = 0;

  Future<void> init() async {
    if (_isInitialized) return;

    // TTS 설정
    await _tts.setLanguage('ko-KR'); // 한국어
    await _tts.setSpeechRate(0.5); // 속도 (0.0 ~ 1.0)
    await _tts.setVolume(1.0); // 볼륨
    await _tts.setPitch(1.0); // 피치

    // 음성 완료 콜백
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _isInitialized = true;
  }

  void setMuted(bool muted) {
    _isMuted = muted;
    if (muted) {
      _tts.stop();
    }
  }

  /// 숫자 카운트다운 음성 (20, 19, 18...)
  Future<void> speakCount(int seconds) async {
    if (_isMuted) return;

    await _tts.speak('$seconds');
    await HapticFeedback.selectionClick();
  }

  /// 카운트다운 틱 사운드 (1초마다) - 음성 + 햅틱
  Future<void> playTick(int seconds) async {
    if (_isMuted) return;

    // 숫자 음성 재생
    await _tts.speak('$seconds');
    await HapticFeedback.selectionClick();
  }

  /// 마지막 5초 카운트다운 (더 강조)
  Future<void> playCountdown(int seconds) async {
    if (_isMuted) return;

    // 5, 4, 3, 2, 1 카운트다운
    await _tts.setSpeechRate(0.45); // 조금 느리게
    await _tts.setPitch(1.1); // 약간 높은 톤으로 긴장감
    await _tts.speak('$seconds');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await HapticFeedback.heavyImpact();
  }

  /// 10초 남았을 때 알림
  Future<void> playTenSecondsWarning() async {
    if (_isMuted || _isSpeaking) return;

    _isSpeaking = true;
    await _tts.setSpeechRate(0.55);
    await _tts.speak('10초 남았습니다');
    await _tts.setSpeechRate(0.5);
    await HapticFeedback.mediumImpact();
  }

  /// 힘내라 응원 멘트
  Future<void> playEncouragement() async {
    if (_isMuted || _isSpeaking) return;

    _isSpeaking = true;
    await _tts.setSpeechRate(0.55);
    await _tts.setPitch(1.15); // 밝은 톤
    await _tts.speak('힘내세요!');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await HapticFeedback.lightImpact();
  }

  /// 동기부여 멘트 (자신의 페이스에 맞게)
  Future<void> playMotivation() async {
    if (_isMuted || _isSpeaking) return;

    _isSpeaking = true;
    final message = _motivationMessages[_motivationIndex];
    _motivationIndex = (_motivationIndex + 1) % _motivationMessages.length;

    await _tts.setSpeechRate(0.48); // 차분하게
    await _tts.setPitch(0.95); // 약간 낮은 톤으로 안정감
    await _tts.speak(message);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  /// 운동 시작 사운드
  Future<void> playWorkStart() async {
    if (_isMuted) return;

    _isSpeaking = true;
    await _tts.setSpeechRate(0.55);
    await _tts.setPitch(1.1); // 활기찬 톤
    await _tts.speak('운동 시작!');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// 운동 시작 + 운동명 안내
  Future<void> playWorkStartWithExercise(String exerciseName) async {
    if (_isMuted) return;

    _isSpeaking = true;
    await _tts.setSpeechRate(0.52);
    await _tts.setPitch(1.1);
    await _tts.speak('$exerciseName 시작!');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// 휴식 시작 사운드
  Future<void> playRestStart() async {
    if (_isMuted) return;

    _isSpeaking = true;
    await _tts.setSpeechRate(0.48); // 차분하게
    await _tts.setPitch(0.95);
    await _tts.speak('휴식');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await HapticFeedback.mediumImpact();
  }

  /// 휴식 시작 + 다음 운동 안내
  Future<void> playRestStartWithNext(String? nextExerciseName) async {
    if (_isMuted) return;

    _isSpeaking = true;
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(0.95);
    if (nextExerciseName != null) {
      await _tts.speak('휴식. 다음은 $nextExerciseName');
    } else {
      await _tts.speak('휴식');
    }
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await HapticFeedback.mediumImpact();
  }

  // 호흡 안내 멘트 리스트
  static const List<String> _breathingMessages = [
    '깊게 숨을 들이쉬고 천천히 내쉬세요',
    '코로 들이쉬고 입으로 내쉬세요',
    '호흡을 가다듬으세요',
    '심호흡으로 회복하세요',
  ];
  int _breathingIndex = 0;

  /// 휴식 중 호흡 안내
  Future<void> playBreathingGuide() async {
    if (_isMuted || _isSpeaking) return;

    _isSpeaking = true;
    final message = _breathingMessages[_breathingIndex];
    _breathingIndex = (_breathingIndex + 1) % _breathingMessages.length;

    await _tts.setSpeechRate(0.42); // 아주 차분하게
    await _tts.setPitch(0.9); // 낮은 톤으로 편안함
    await _tts.speak(message);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  /// 운동 완료 사운드
  Future<void> playFinish() async {
    if (_isMuted) return;

    _isSpeaking = true;
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.1); // 밝은 톤
    await _tts.speak('운동 완료! 정말 수고하셨습니다');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
  }

  /// 정리운동 시작
  Future<void> playCooldownStart() async {
    if (_isMuted) return;

    _isSpeaking = true;
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(0.95);
    await _tts.speak('정리운동. 천천히 마무리하세요');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await HapticFeedback.mediumImpact();
  }

  /// 준비 시작 사운드
  Future<void> playPrepare() async {
    if (_isMuted) return;

    _isSpeaking = true;
    await _tts.setSpeechRate(0.5);
    await _tts.speak('준비하세요');
    await HapticFeedback.lightImpact();
  }

  /// 준비 + 첫 운동 안내
  Future<void> playPrepareWithExercise(String exerciseName) async {
    if (_isMuted) return;

    _isSpeaking = true;
    await _tts.setSpeechRate(0.48);
    await _tts.speak('준비하세요. 첫 운동은 $exerciseName입니다');
    await HapticFeedback.lightImpact();
  }

  /// 다음 운동 안내
  Future<void> speakNextExercise(String exerciseName) async {
    if (_isMuted) return;

    await _tts.speak('다음 운동, $exerciseName');
  }

  /// 세트 안내
  Future<void> speakSet(int currentSet, int totalSets) async {
    if (_isMuted) return;

    await _tts.speak('$currentSet 세트');
  }

  void dispose() {
    _tts.stop();
  }
}
