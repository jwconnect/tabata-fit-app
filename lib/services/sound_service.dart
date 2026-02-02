import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// TTS 음성 우선순위
enum TTSPriority {
  low, // 숫자 카운트 (19, 18, 17...)
  normal, // 호흡 안내, 동기부여 멘트
  high, // 운동/휴식 시작, 10초 경고
  critical, // 5-4-3-2-1 카운트다운, 운동 완료
}

/// 타이머 사운드 서비스 (TTS + 시스템 사운드 + 햅틱)
/// 우선순위 기반으로 중요 멘트가 끊기지 않도록 관리
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final FlutterTts _tts = FlutterTts();

  bool _isInitialized = false;
  bool _isMuted = false;
  bool _isVibrationEnabled = true; // 진동 활성화 상태
  bool _isSpeaking = false;
  TTSPriority _currentPriority = TTSPriority.low;

  // 현재 재생 중인 음성의 우선순위
  TTSPriority get currentPriority => _currentPriority;
  bool get isSpeaking => _isSpeaking;

  bool get isMuted => _isMuted;
  bool get isVibrationEnabled => _isVibrationEnabled;

  /// 진동 활성화/비활성화 설정
  void setVibrationEnabled(bool enabled) {
    _isVibrationEnabled = enabled;
  }

  // 현재 표시 중인 동기부여 멘트 (UI에서 사용)
  String? _currentDisplayMessage;
  String? get currentDisplayMessage => _currentDisplayMessage;

  /// 현재 표시 멘트 초기화
  void clearDisplayMessage() {
    _currentDisplayMessage = null;
  }

  // ===== 운동 중 멘트 (음성 전용 - 짧고 강렬하게) =====
  static const List<String> _workVoiceMessages = [
    '좋아요!',
    '잘하고 있어요!',
    '그 자세 유지!',
    '끝까지!',
    '포기하지 마세요!',
    '할 수 있어요!',
    '파이팅!',
    '조금만 더!',
  ];
  int _workVoiceIndex = 0;

  // ===== 운동 중 멘트 (화면 전용 - 자세/팁 안내) =====
  static const List<String> _workDisplayMessages = [
    '속도보다 정확한 자세가 중요해요',
    '코어에 힘을 주세요',
    '호흡을 멈추지 마세요',
    '힘들면 동작을 작게 해도 괜찮아요',
    '자신의 페이스를 유지하세요',
    '무릎이 발끝을 넘지 않게 주의하세요',
    '허리를 곧게 펴세요',
    '시선은 정면을 향하세요',
  ];
  int _workDisplayIndex = 0;

  // ===== 휴식 중 멘트 (음성 전용 - 회복 안내) =====
  static const List<String> _restVoiceMessages = [
    '잘했어요',
    '잠깐 쉬세요',
    '호흡을 가다듬으세요',
    '수분 섭취하세요',
  ];
  int _restVoiceIndex = 0;

  // ===== 휴식 중 멘트 (화면 전용 - 호흡/준비 안내) =====
  static const List<String> _restDisplayMessages = [
    '코로 깊게 들이쉬고 입으로 내쉬세요',
    '심박수를 안정시키세요',
    '다음 동작을 머릿속으로 준비하세요',
    '어깨와 목의 긴장을 풀어주세요',
    '물 한 모금 마셔도 좋아요',
    '깊은 호흡으로 산소를 공급하세요',
  ];
  int _restDisplayIndex = 0;

  // ===== 마지막 10초 격려 (음성 전용) =====
  static const List<String> _finalPushMessages = [
    '마지막이에요!',
    '거의 다 왔어요!',
    '끝까지 힘내세요!',
    '조금만 버텨요!',
  ];
  int _finalPushIndex = 0;

  // ===== 정리운동 멘트 (화면 전용 - 스트레칭/마무리 안내) =====
  static const List<String> _cooldownDisplayMessages = [
    '심호흡으로 심박수를 낮추세요',
    '어깨를 천천히 돌려주세요',
    '목을 좌우로 스트레칭하세요',
    '팔을 위로 뻗어 기지개를 켜세요',
    '허벅지 앞쪽을 스트레칭하세요',
    '종아리를 늘려주세요',
    '수고하셨습니다! 물 드세요',
  ];
  int _cooldownDisplayIndex = 0;

  Future<void> init() async {
    if (_isInitialized) return;

    // TTS 설정
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    // 음성 완료 콜백
    _tts.setCompletionHandler(() {
      _resetSpeakingState();
    });

    // 취소 콜백
    _tts.setCancelHandler(() {
      _resetSpeakingState();
    });

    // 에러 콜백
    _tts.setErrorHandler((msg) {
      _resetSpeakingState();
    });

    _isInitialized = true;
  }

  /// TTS 상태 리셋 헬퍼
  void _resetSpeakingState() {
    _isSpeaking = false;
    _currentPriority = TTSPriority.low;
  }

  /// 방어적 타임아웃으로 TTS 상태 리셋 (콜백 실패 대비)
  void _scheduleDefensiveReset(TTSPriority priority) {
    Future.delayed(const Duration(seconds: 8), () {
      // 같은 우선순위로 여전히 speaking 상태면 강제 리셋
      if (_isSpeaking && _currentPriority == priority) {
        _resetSpeakingState();
      }
    });
  }

  void setMuted(bool muted) {
    _isMuted = muted;
    if (muted) {
      _tts.stop();
      _isSpeaking = false;
      _currentPriority = TTSPriority.low;
    }
  }

  /// 우선순위 체크 - 현재 재생 중인 음성보다 우선순위가 높은지 확인
  bool _canSpeak(TTSPriority priority) {
    if (_isMuted) return false;
    if (!_isSpeaking) return true;

    // 현재 재생 중인 음성보다 우선순위가 높으면 중단하고 재생
    return priority.index > _currentPriority.index;
  }

  /// 현재 음성 중단 (더 높은 우선순위 음성을 위해)
  Future<void> _stopIfNeeded(TTSPriority newPriority) async {
    if (_isSpeaking && newPriority.index > _currentPriority.index) {
      await _tts.stop();
      _isSpeaking = false;
    }
  }

  /// 일반 숫자 카운트 음성 (19, 18, 17... - 가장 낮은 우선순위)
  /// 중요 멘트 재생 중이면 생략
  Future<void> playTick(int seconds) async {
    if (!_canSpeak(TTSPriority.low)) return;

    // 중요 멘트 재생 중이면 틱 소리 생략
    if (_isSpeaking && _currentPriority.index >= TTSPriority.normal.index) {
      // 햅틱만 재생
      await _vibrateSelectionClick();
      return;
    }

    _isSpeaking = true;
    _currentPriority = TTSPriority.low;

    await _tts.setVolume(0.6); // 낮은 볼륨
    await _tts.setSpeechRate(0.6); // 빠르게
    await _tts.setPitch(0.95);
    await _tts.speak('$seconds');
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _vibrateSelectionClick();
  }

  /// 마지막 5초 카운트다운 (critical 우선순위 - 절대 끊기지 않음)
  Future<void> playCountdown(int seconds) async {
    // 진동은 음소거와 무관하게 항상 실행
    await _vibrateHeavyImpact();

    if (_isMuted) return;

    await _stopIfNeeded(TTSPriority.critical);

    _isSpeaking = true;
    _currentPriority = TTSPriority.critical;

    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.1);
    await _tts.speak('$seconds');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  /// 10초 남았을 때 알림 (high 우선순위)
  Future<void> playTenSecondsWarning() async {
    if (!_canSpeak(TTSPriority.high)) return;
    await _stopIfNeeded(TTSPriority.high);

    _isSpeaking = true;
    _currentPriority = TTSPriority.high;

    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.55);
    await _tts.speak('10초 남았습니다');
    await _tts.setSpeechRate(0.5);
    await _vibrateMediumImpact();
  }

  /// 운동 중 음성 격려 (normal 우선순위) - 음성만
  Future<void> playWorkVoiceEncouragement() async {
    if (!_canSpeak(TTSPriority.normal)) return;
    await _stopIfNeeded(TTSPriority.normal);

    _isSpeaking = true;
    _currentPriority = TTSPriority.normal;
    _scheduleDefensiveReset(TTSPriority.normal);

    final message = _workVoiceMessages[_workVoiceIndex];
    _workVoiceIndex = (_workVoiceIndex + 1) % _workVoiceMessages.length;

    // 음성만 - 화면 표시 안함
    await _tts.setVolume(0.9);
    await _tts.setSpeechRate(0.55);
    await _tts.setPitch(1.1);
    await _tts.speak(message);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }

  /// 운동 중 화면 팁 표시 (화면만 - 음성 없음)
  void showWorkDisplayTip() {
    final message = _workDisplayMessages[_workDisplayIndex];
    _workDisplayIndex = (_workDisplayIndex + 1) % _workDisplayMessages.length;
    _currentDisplayMessage = message;
  }

  /// 마지막 10초 격려 (음성만)
  Future<void> playFinalPushEncouragement() async {
    if (!_canSpeak(TTSPriority.normal)) return;
    await _stopIfNeeded(TTSPriority.normal);

    _isSpeaking = true;
    _currentPriority = TTSPriority.normal;

    final message = _finalPushMessages[_finalPushIndex];
    _finalPushIndex = (_finalPushIndex + 1) % _finalPushMessages.length;

    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.15);
    await _tts.speak(message);
    await _tts.setPitch(1.0);
  }

  /// 운동 시작 사운드 (high 우선순위)
  Future<void> playWorkStart() async {
    // 진동은 음소거와 무관하게 항상 실행
    await _vibrateHeavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await _vibrateHeavyImpact();

    if (_isMuted) return;

    await _stopIfNeeded(TTSPriority.high);

    _isSpeaking = true;
    _currentPriority = TTSPriority.high;

    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.55);
    await _tts.setPitch(1.1);
    await _tts.speak('운동 시작!');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  /// 운동 시작 + 운동명 안내 (high 우선순위)
  Future<void> playWorkStartWithExercise(String exerciseName) async {
    // 진동은 음소거와 무관하게 항상 실행
    await _vibrateHeavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await _vibrateHeavyImpact();

    if (_isMuted) return;

    await _stopIfNeeded(TTSPriority.high);

    _isSpeaking = true;
    _currentPriority = TTSPriority.high;

    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.52);
    await _tts.setPitch(1.1);
    await _tts.speak('$exerciseName 시작!');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  /// 휴식 시작 사운드 (high 우선순위)
  Future<void> playRestStart() async {
    // 진동은 음소거와 무관하게 항상 실행
    await _vibrateMediumImpact();

    if (_isMuted) return;

    await _stopIfNeeded(TTSPriority.high);

    _isSpeaking = true;
    _currentPriority = TTSPriority.high;

    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(0.95);
    await _tts.speak('휴식');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  /// 휴식 시작 + 다음 운동 안내 (high 우선순위)
  Future<void> playRestStartWithNext(String? nextExerciseName) async {
    // 진동은 음소거와 무관하게 항상 실행
    await _vibrateMediumImpact();

    if (_isMuted) return;

    await _stopIfNeeded(TTSPriority.high);

    _isSpeaking = true;
    _currentPriority = TTSPriority.high;

    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(0.95);
    if (nextExerciseName != null) {
      await _tts.speak('휴식. 다음은 $nextExerciseName');
    } else {
      await _tts.speak('휴식');
    }
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  /// 휴식 중 음성 안내 (normal 우선순위) - 음성만
  Future<void> playRestVoiceGuide() async {
    if (!_canSpeak(TTSPriority.normal)) return;
    await _stopIfNeeded(TTSPriority.normal);

    _isSpeaking = true;
    _currentPriority = TTSPriority.normal;
    _scheduleDefensiveReset(TTSPriority.normal);

    final message = _restVoiceMessages[_restVoiceIndex];
    _restVoiceIndex = (_restVoiceIndex + 1) % _restVoiceMessages.length;

    // 음성만 - 화면 표시 안함
    await _tts.setVolume(0.85);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(0.95);
    await _tts.speak(message);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }

  /// 휴식 중 화면 안내 표시 (화면만 - 음성 없음)
  void showRestDisplayTip() {
    final message = _restDisplayMessages[_restDisplayIndex];
    _restDisplayIndex = (_restDisplayIndex + 1) % _restDisplayMessages.length;
    _currentDisplayMessage = message;
  }

  /// 정리운동 중 화면 안내 표시 (화면만 - 음성 없음)
  void showCooldownDisplayTip() {
    final message = _cooldownDisplayMessages[_cooldownDisplayIndex];
    _cooldownDisplayIndex =
        (_cooldownDisplayIndex + 1) % _cooldownDisplayMessages.length;
    _currentDisplayMessage = message;
  }

  /// 운동 완료 사운드 (critical 우선순위)
  Future<void> playFinish() async {
    // 진동은 음소거와 무관하게 항상 실행
    await _vibrateHeavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await _vibrateHeavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await _vibrateHeavyImpact();

    if (_isMuted) return;

    await _stopIfNeeded(TTSPriority.critical);

    _isSpeaking = true;
    _currentPriority = TTSPriority.critical;

    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.1);
    await _tts.speak('운동 완료! 정말 수고하셨습니다');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  /// 정리운동 시작 (high 우선순위)
  Future<void> playCooldownStart() async {
    // 진동은 음소거와 무관하게 항상 실행
    await _vibrateMediumImpact();

    if (_isMuted) return;

    await _stopIfNeeded(TTSPriority.high);

    _isSpeaking = true;
    _currentPriority = TTSPriority.high;

    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(0.95);
    await _tts.speak('정리운동. 천천히 마무리하세요');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  /// 준비 시작 사운드 (high 우선순위)
  Future<void> playPrepare() async {
    // 진동은 음소거와 무관하게 항상 실행
    await _vibrateLightImpact();

    if (_isMuted) return;

    await _stopIfNeeded(TTSPriority.high);

    _isSpeaking = true;
    _currentPriority = TTSPriority.high;

    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.speak('준비하세요');
  }

  /// 준비 + 첫 운동 안내 (high 우선순위)
  Future<void> playPrepareWithExercise(String exerciseName) async {
    // 진동은 음소거와 무관하게 항상 실행
    await _vibrateLightImpact();

    if (_isMuted) return;

    await _stopIfNeeded(TTSPriority.high);

    _isSpeaking = true;
    _currentPriority = TTSPriority.high;

    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.48);
    await _tts.speak('준비하세요. 첫 운동은 $exerciseName입니다');
  }

  /// 다음 운동 안내 (normal 우선순위)
  Future<void> speakNextExercise(String exerciseName) async {
    if (!_canSpeak(TTSPriority.normal)) return;
    await _stopIfNeeded(TTSPriority.normal);

    _isSpeaking = true;
    _currentPriority = TTSPriority.normal;

    await _tts.setVolume(0.9);
    await _tts.speak('다음 운동, $exerciseName');
    await _tts.setVolume(1.0);
  }

  /// 세트 안내 (normal 우선순위)
  Future<void> speakSet(int currentSet, int totalSets) async {
    if (!_canSpeak(TTSPriority.normal)) return;
    await _stopIfNeeded(TTSPriority.normal);

    _isSpeaking = true;
    _currentPriority = TTSPriority.normal;

    await _tts.setVolume(0.9);
    await _tts.speak('$currentSet 세트');
    await _tts.setVolume(1.0);
  }

  /// 숫자 카운트 비활성화용 (햅틱만 재생)
  Future<void> playTickHapticOnly() async {
    if (!_isVibrationEnabled) return; // 진동 설정만 체크 (음소거와 무관)
    await _vibrateSelectionClick();
  }

  // 진동 헬퍼 메서드들 - 진동 설정 체크
  Future<void> _vibrateLightImpact() async {
    if (_isVibrationEnabled) await HapticFeedback.lightImpact();
  }

  Future<void> _vibrateMediumImpact() async {
    if (_isVibrationEnabled) await HapticFeedback.mediumImpact();
  }

  Future<void> _vibrateHeavyImpact() async {
    if (_isVibrationEnabled) await HapticFeedback.heavyImpact();
  }

  Future<void> _vibrateSelectionClick() async {
    if (_isVibrationEnabled) await HapticFeedback.selectionClick();
  }

  /// TTS 즉시 중지 (타이머 중단/리셋 시 호출)
  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
    _currentPriority = TTSPriority.low;
    _currentDisplayMessage = null;
  }

  void dispose() {
    _tts.stop();
    _isSpeaking = false;
    _currentPriority = TTSPriority.low;
  }
}
