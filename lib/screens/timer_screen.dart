import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/timer_provider.dart';

import '../models/exercise.dart';
import '../utils/app_theme.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  String? _currentVideoPath;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  void _initializeVideo(String? exerciseName) {
    if (exerciseName == null) return;

    final videoPath = ExerciseAssets.getVideoPathByName(exerciseName);
    if (videoPath.isEmpty) return;

    // 같은 비디오면 재초기화하지 않음
    if (videoPath == _currentVideoPath && _isVideoInitialized) return;

    _currentVideoPath = videoPath;
    _videoController?.removeListener(_onVideoUpdate);
    _videoController?.dispose();
    _isVideoInitialized = false;

    // 단일 비디오 컨트롤러 사용 (블러 배경과 메인 비디오 공유)
    _videoController = VideoPlayerController.asset(videoPath);
    _videoController!.addListener(_onVideoUpdate);
    _videoController!.initialize().then((_) {
      if (mounted && _videoController != null) {
        _videoController!.setLooping(true);
        _videoController!.setVolume(0);
        _videoController!.play();
        setState(() {
          _isVideoInitialized = true;
        });
      }
    });
  }

  void _onVideoUpdate() {
    // 재생 상태 변경시에만 UI 갱신 (초기화 완료, 재생 시작/정지 등)
    if (mounted && _videoController != null) {
      final isPlaying = _videoController!.value.isPlaying;
      final isInitialized = _videoController!.value.isInitialized;
      // 상태 변경이 있을 때만 setState 호출
      if (isInitialized && !_isVideoInitialized) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    }
  }

  void _disposeVideo() {
    _videoController?.removeListener(_onVideoUpdate);
    _videoController?.dispose();
    _videoController = null;
    _isVideoInitialized = false;
    _currentVideoPath = null;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _videoController?.removeListener(_onVideoUpdate);
    _videoController?.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  String _getIntervalText(IntervalType type) {
    switch (type) {
      case IntervalType.prepare:
        return '준비';
      case IntervalType.work:
        return '운동';
      case IntervalType.rest:
        return '휴식';
      case IntervalType.cooldown:
        return '정리';
      default:
        return '';
    }
  }

  String _getIntervalSubtext(IntervalType type) {
    switch (type) {
      case IntervalType.prepare:
        return 'GET READY';
      case IntervalType.work:
        return 'WORK OUT';
      case IntervalType.rest:
        return 'TAKE A REST';
      case IntervalType.cooldown:
        return 'COOL DOWN';
      default:
        return '';
    }
  }

  Color _getIntervalColor(IntervalType type) {
    switch (type) {
      case IntervalType.prepare:
        return AppColors.prepareYellow;
      case IntervalType.work:
        return AppColors.workRed;
      case IntervalType.rest:
        return AppColors.restBlue;
      case IntervalType.cooldown:
        return AppColors.cooldownGreen;
      default:
        return AppColors.primaryRed;
    }
  }

  IconData _getIntervalIcon(IntervalType type) {
    switch (type) {
      case IntervalType.prepare:
        return Icons.hourglass_bottom_rounded;
      case IntervalType.work:
        return Icons.fitness_center_rounded;
      case IntervalType.rest:
        return Icons.self_improvement_rounded;
      case IntervalType.cooldown:
        return Icons.air_rounded;
      default:
        return Icons.timer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        final state = timerProvider.state;
        final intervalType = timerProvider.intervalType;
        final currentTime = timerProvider.currentTime;
        final currentSet = timerProvider.currentSet;
        final totalSets = timerProvider.sets;
        final progress = timerProvider.progress;
        final intervalColor = _getIntervalColor(intervalType);

        // 운동 중일 때 펄스 애니메이션 활성화
        if (state == TimerState.running && intervalType == IntervalType.work) {
          if (!_pulseController.isAnimating) {
            _pulseController.repeat(reverse: true);
          }
        } else {
          if (_pulseController.isAnimating) {
            _pulseController.stop();
            _pulseController.value = 0;
          }
        }

        // 운동/준비 시간에 비디오 초기화
        final isWorkOrPrepare =
            intervalType == IntervalType.prepare ||
            intervalType == IntervalType.work;
        if (isWorkOrPrepare && state == TimerState.running) {
          final exerciseName = intervalType == IntervalType.prepare
              ? timerProvider.firstExerciseName
              : timerProvider.currentExerciseName;
          _initializeVideo(exerciseName);
        } else if (intervalType == IntervalType.rest) {
          // 휴식 시간에는 다음 운동 비디오 미리 로드
          _initializeVideo(
            timerProvider.nextExerciseName ?? timerProvider.currentExerciseName,
          );
        } else if (intervalType == IntervalType.cooldown ||
            state == TimerState.finished) {
          if (_videoController != null) {
            _disposeVideo();
          }
        }

        // 운동/준비 시간에는 전체화면 비디오 UI
        final showFullScreenVideo =
            (intervalType == IntervalType.prepare ||
                intervalType == IntervalType.work ||
                intervalType == IntervalType.rest) &&
            state != TimerState.finished;

        return Scaffold(
          backgroundColor: AppColors.deepBlack,
          body: Stack(
            children: [
              // 전체 화면 비디오 배경
              if (showFullScreenVideo &&
                  _isVideoInitialized &&
                  _videoController != null &&
                  _videoController!.value.isInitialized) ...[
                // 1. 그라데이션 배경
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          intervalColor.withOpacity(0.4),
                          AppColors.deepBlack,
                        ],
                      ),
                    ),
                  ),
                ),
                // 2. 메인 비디오 (원본 비율)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: intervalColor.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        ),
                      ),
                    ),
                  ),
                ),
              ] else if (showFullScreenVideo)
                // 비디오 로딩 중 배경
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.5,
                            colors: [
                              intervalColor.withOpacity(0.3),
                              AppColors.deepBlack,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                // 기본 배경 (완료/정리 시간)
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.2,
                          colors: [
                            intervalColor.withOpacity(
                              _glowAnimation.value * 0.3,
                            ),
                            AppColors.deepBlack,
                          ],
                        ),
                      ),
                    );
                  },
                ),

              // 비디오 위 오버레이 (어둡게)
              if (showFullScreenVideo)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.0, 0.2, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),

              // 메인 UI
              Builder(
                builder: (context) {
                  // 반응형 레이아웃 값 계산
                  final screenSize = MediaQuery.of(context).size;
                  final shortestSide = screenSize.shortestSide;
                  final baseUnit = shortestSide / 100;

                  final bottomPadding = (baseUnit * 5).clamp(16.0, 40.0);
                  final spacingLarge = (baseUnit * 8).clamp(30.0, 60.0);
                  final spacingMedium = (baseUnit * 6).clamp(24.0, 50.0);

                  return SafeArea(
                    child: Column(
                      children: [
                        // 상단 바
                        _buildTopBar(timerProvider),

                        // 중앙 콘텐츠 영역
                        Expanded(
                          child: Center(
                            child: SingleChildScrollView(
                              child: showFullScreenVideo
                                  ? _buildFullScreenVideoOverlay(
                                      timerProvider,
                                      intervalType,
                                      intervalColor,
                                      currentTime,
                                      progress,
                                      currentSet,
                                      totalSets,
                                      state,
                                    )
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // 기존 UI (정리운동/완료)
                                        _buildIntervalBadge(
                                          intervalType,
                                          intervalColor,
                                        ),
                                        SizedBox(height: spacingLarge),
                                        _buildMainTimer(
                                          currentTime,
                                          progress,
                                          intervalColor,
                                          state,
                                        ),
                                        SizedBox(height: spacingMedium),
                                        if (currentSet > 0)
                                          _buildSetIndicator(
                                            currentSet,
                                            totalSets,
                                            intervalColor,
                                          ),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                        // 완료 메시지
                        if (state == TimerState.finished)
                          _buildCompletionCard(context, timerProvider),

                        // 컨트롤 버튼
                        _buildControlButtons(timerProvider, state),

                        SizedBox(height: bottomPadding),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 전체화면 비디오 오버레이 UI - 해상도 반응형
  Widget _buildFullScreenVideoOverlay(
    TimerProvider timerProvider,
    IntervalType intervalType,
    Color intervalColor,
    int currentTime,
    double progress,
    int currentSet,
    int totalSets,
    TimerState state,
  ) {
    final exerciseName = intervalType == IntervalType.prepare
        ? timerProvider.firstExerciseName
        : (intervalType == IntervalType.rest
              ? timerProvider.nextExerciseName
              : timerProvider.currentExerciseName);

    // 화면 크기 기반 반응형 계산
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final isLandscape = screenWidth > screenHeight;
    final shortestSide = screenSize.shortestSide;

    // 기준 크기 계산 (화면의 가로/세로 중 작은 값 기준)
    final baseUnit = shortestSide / 100;

    // 반응형 크기 계산
    final timerSize = isLandscape
        ? (screenHeight * 0.28).clamp(100.0, 180.0)
        : (screenHeight * 0.18).clamp(100.0, 200.0);
    final progressSize = timerSize * 0.88;
    final timerFontSize = timerSize * 0.38;
    final strokeWidth = (timerSize * 0.03).clamp(2.0, 6.0);

    // 뱃지 및 텍스트 크기
    final badgePaddingH = (baseUnit * 4).clamp(12.0, 24.0);
    final badgePaddingV = (baseUnit * 2).clamp(6.0, 12.0);
    final badgeIconSize = (baseUnit * 4).clamp(14.0, 24.0);
    final badgeFontSize = (baseUnit * 3.2).clamp(12.0, 18.0);
    final subtextFontSize = (baseUnit * 2.2).clamp(9.0, 13.0);

    // 간격
    final spacingSmall = (baseUnit * 1).clamp(4.0, 8.0);
    final spacingMedium = (baseUnit * 2.5).clamp(8.0, 20.0);
    final spacingLarge = (baseUnit * 3).clamp(12.0, 24.0);

    // 운동 이름 영역
    final exerciseIconSize = (baseUnit * 3.5).clamp(14.0, 22.0);
    final exerciseFontSize = (baseUnit * 3).clamp(12.0, 18.0);
    final exercisePaddingH = (baseUnit * 3).clamp(10.0, 20.0);
    final exercisePaddingV = (baseUnit * 1.5).clamp(5.0, 12.0);

    // 세트 표시
    final setIndicatorWidth = (baseUnit * 4).clamp(12.0, 28.0);
    final setIndicatorHeight = (baseUnit * 1).clamp(4.0, 8.0);
    final setFontSize = (baseUnit * 2.8).clamp(10.0, 16.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 상단: 인터벌 타입 뱃지
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: badgePaddingH,
            vertical: badgePaddingV,
          ),
          decoration: BoxDecoration(
            color: intervalColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: intervalColor.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIntervalIcon(intervalType),
                color: Colors.white,
                size: badgeIconSize,
              ),
              SizedBox(width: spacingSmall),
              Text(
                _getIntervalText(intervalType),
                style: TextStyle(
                  fontSize: badgeFontSize,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spacingSmall),

        // 서브텍스트
        Text(
          _getIntervalSubtext(intervalType),
          style: TextStyle(
            fontSize: subtextFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 3,
          ),
        ),
        SizedBox(height: spacingLarge),

        // 중앙: 카운트다운
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final scale =
                state == TimerState.running && intervalType == IntervalType.work
                ? _pulseAnimation.value
                : 1.0;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: timerSize,
                height: timerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                  border: Border.all(color: intervalColor, width: strokeWidth),
                  boxShadow: [
                    BoxShadow(
                      color: intervalColor.withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 원형 프로그레스
                    SizedBox(
                      width: progressSize,
                      height: progressSize,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: strokeWidth,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          intervalColor,
                        ),
                      ),
                    ),
                    // 시간 표시
                    Text(
                      '$currentTime',
                      style: TextStyle(
                        fontSize: timerFontSize,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: intervalColor.withOpacity(0.8),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        SizedBox(height: spacingMedium),

        // 운동 이름
        if (exerciseName != null)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: exercisePaddingH,
              vertical: exercisePaddingV,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fitness_center,
                  color: intervalColor,
                  size: exerciseIconSize,
                ),
                SizedBox(width: spacingSmall),
                Flexible(
                  child: Text(
                    intervalType == IntervalType.rest
                        ? '다음: $exerciseName'
                        : exerciseName,
                    style: TextStyle(
                      fontSize: exerciseFontSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: spacingMedium),

        // 세트 표시
        if (currentSet > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(totalSets, (index) {
                final isCompleted = index < currentSet;
                final isCurrent = index == currentSet - 1;
                return Container(
                  width: isCurrent
                      ? setIndicatorWidth * 1.3
                      : setIndicatorWidth,
                  height: setIndicatorHeight,
                  margin: EdgeInsets.symmetric(horizontal: spacingSmall * 0.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(setIndicatorHeight / 2),
                    color: isCompleted
                        ? intervalColor
                        : Colors.white.withOpacity(0.2),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: intervalColor.withOpacity(0.6),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                );
              }),
            ],
          ),
        SizedBox(height: spacingSmall),
        Text(
          'SET $currentSet / $totalSets',
          style: TextStyle(
            fontSize: setFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(TimerProvider timerProvider) {
    // 반응형 크기 계산
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    final baseUnit = shortestSide / 100;

    final horizontalPadding = (baseUnit * 3).clamp(12.0, 24.0);
    final verticalPadding = (baseUnit * 2.5).clamp(8.0, 16.0);
    final closeButtonPadding = (baseUnit * 2.5).clamp(8.0, 14.0);
    final closeIconSize = (baseUnit * 4.5).clamp(18.0, 26.0);
    final timeIconSize = (baseUnit * 3.5).clamp(14.0, 22.0);
    final timeFontSize = (baseUnit * 2.8).clamp(11.0, 16.0);
    final timePaddingH = (baseUnit * 3).clamp(10.0, 20.0);
    final timePaddingV = (baseUnit * 2).clamp(6.0, 12.0);
    final spacerWidth = closeButtonPadding * 2 + closeIconSize;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(closeButtonPadding),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(closeButtonPadding),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Icon(
                Icons.close,
                color: AppColors.textSecondary,
                size: closeIconSize,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: timePaddingH,
              vertical: timePaddingV,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(timePaddingV * 2),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppColors.textMuted,
                  size: timeIconSize,
                ),
                SizedBox(width: baseUnit * 1.5),
                Text(
                  _formatTime(timerProvider.totalTime),
                  style: TextStyle(
                    fontSize: timeFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: spacerWidth),
        ],
      ),
    );
  }

  Widget _buildIntervalBadge(IntervalType type, Color color) {
    // 반응형 크기 계산
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    final baseUnit = shortestSide / 100;

    final paddingH = (baseUnit * 5).clamp(16.0, 30.0);
    final paddingV = (baseUnit * 2.8).clamp(10.0, 18.0);
    final iconSize = (baseUnit * 5).clamp(20.0, 32.0);
    final fontSize = (baseUnit * 4.5).clamp(16.0, 26.0);
    final subtextFontSize = (baseUnit * 2.5).clamp(10.0, 14.0);
    final spacing = (baseUnit * 2.5).clamp(8.0, 16.0);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: paddingH,
            vertical: paddingV,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: color.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getIntervalIcon(type), color: color, size: iconSize),
              SizedBox(width: spacing),
              Text(
                _getIntervalText(type),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing * 0.5),
        Text(
          _getIntervalSubtext(type),
          style: TextStyle(
            fontSize: subtextFontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildMainTimer(
    int currentTime,
    double progress,
    Color color,
    TimerState state,
  ) {
    // 반응형 크기 계산
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    final isLandscape = screenSize.width > screenSize.height;

    // 타이머 크기 계산 (화면 크기에 비례)
    final timerSize = isLandscape
        ? (screenSize.height * 0.45).clamp(200.0, 350.0)
        : (shortestSide * 0.7).clamp(200.0, 350.0);
    final ringSize = timerSize * 0.93;
    final innerSize = timerSize * 0.77;
    final strokeWidth = (timerSize * 0.047).clamp(8.0, 16.0);
    final fontSize = (timerSize * 0.21).clamp(40.0, 72.0);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = state == TimerState.running ? _pulseAnimation.value : 1.0;
        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: timerSize,
            height: timerSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 외부 글로우 링
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      width: timerSize,
                      height: timerSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(_glowAnimation.value),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // 배경 링
                CustomPaint(
                  size: Size(ringSize, ringSize),
                  painter: _TimerRingPainter(
                    progress: 1,
                    color: AppColors.surfaceDark,
                    strokeWidth: strokeWidth,
                  ),
                ),

                // 진행 링
                CustomPaint(
                  size: Size(ringSize, ringSize),
                  painter: _TimerRingPainter(
                    progress: progress,
                    color: color,
                    strokeWidth: strokeWidth,
                    hasShadow: true,
                  ),
                ),

                // 내부 원
                Container(
                  width: innerSize,
                  height: innerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [AppColors.cardDark, AppColors.deepBlack],
                    ),
                    border: Border.all(color: AppColors.glassBorder, width: 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 시간 표시
                      Text(
                        _formatTime(currentTime),
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w700,
                          color: color,
                          letterSpacing: -2,
                          height: 1,
                          shadows: [
                            Shadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSetIndicator(int currentSet, int totalSets, Color color) {
    // 반응형 크기 계산
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    final baseUnit = shortestSide / 100;

    final labelFontSize = (baseUnit * 2.5).clamp(10.0, 14.0);
    final indicatorWidth = (baseUnit * 5).clamp(18.0, 36.0);
    final indicatorHeight = (baseUnit * 1.6).clamp(6.0, 10.0);
    final indicatorMargin = (baseUnit * 0.6).clamp(2.0, 4.0);
    final countFontSize = (baseUnit * 3.5).clamp(14.0, 22.0);
    final spacing = (baseUnit * 2).clamp(6.0, 14.0);

    return Column(
      children: [
        Text(
          'SET',
          style: TextStyle(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 3,
          ),
        ),
        SizedBox(height: spacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSets, (index) {
            final isCompleted = index < currentSet;
            final isCurrent = index == currentSet - 1;
            return Container(
              width: isCurrent ? indicatorWidth * 1.3 : indicatorWidth,
              height: indicatorHeight,
              margin: EdgeInsets.symmetric(horizontal: indicatorMargin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(indicatorHeight / 2),
                color: isCompleted ? color : AppColors.surfaceDark,
                boxShadow: isCurrent
                    ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                    : null,
              ),
            );
          }),
        ),
        SizedBox(height: spacing * 1.5),
        Text(
          '$currentSet / $totalSets',
          style: TextStyle(
            fontSize: countFontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionCard(
    BuildContext context,
    TimerProvider timerProvider,
  ) {
    // 반응형 크기 계산
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    final baseUnit = shortestSide / 100;

    final marginH = (baseUnit * 6).clamp(20.0, 40.0);
    final marginV = (baseUnit * 4).clamp(12.0, 24.0);
    final padding = (baseUnit * 5).clamp(16.0, 28.0);
    final iconContainerPadding = (baseUnit * 3).clamp(12.0, 20.0);
    final iconSize = (baseUnit * 8).clamp(28.0, 48.0);
    final titleFontSize = (baseUnit * 5).clamp(20.0, 30.0);
    final subtitleFontSize = (baseUnit * 3).clamp(12.0, 18.0);
    final spacing = (baseUnit * 3).clamp(10.0, 20.0);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentGreen.withOpacity(0.2),
            AppColors.accentGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(padding),
        border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGreen.withOpacity(0.2),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(iconContainerPadding),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              color: AppColors.accentGreen,
              size: iconSize,
            ),
          ),
          SizedBox(height: spacing),
          Text(
            '운동 완료!',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w800,
              color: AppColors.accentGreen,
            ),
          ),
          SizedBox(height: spacing * 0.5),
          Text(
            '오늘도 멋지게 해냈어요 💪',
            style: TextStyle(
              fontSize: subtitleFontSize,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(TimerProvider timerProvider, TimerState state) {
    // 반응형 크기 계산
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    final baseUnit = shortestSide / 100;

    final horizontalPadding = (baseUnit * 6).clamp(16.0, 40.0);
    final buttonHeight = (baseUnit * 12).clamp(48.0, 72.0);
    final stopButtonSize = (baseUnit * 12).clamp(48.0, 72.0);
    final iconSize = (buttonHeight * 0.45).clamp(20.0, 34.0);
    final fontSize = (baseUnit * 3.5).clamp(14.0, 20.0);
    final spacing = (baseUnit * 3).clamp(10.0, 20.0);

    if (state == TimerState.initial ||
        state == TimerState.ready ||
        state == TimerState.finished) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: _buildGradientButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            timerProvider.startTimer();
          },
          icon: Icons.play_arrow_rounded,
          label: state == TimerState.finished ? '다시 시작' : '시작하기',
          gradient: AppGradients.greenGradient,
          glowColor: AppColors.accentGreen,
          height: buttonHeight,
          iconSize: iconSize,
          fontSize: fontSize,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          // 메인 버튼 (일시정지/재개)
          Expanded(
            child: state == TimerState.running
                ? _buildGradientButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      timerProvider.pauseTimer();
                    },
                    icon: Icons.pause_rounded,
                    label: '일시정지',
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentOrange,
                        AppColors.accentOrange.withOpacity(0.8),
                      ],
                    ),
                    glowColor: AppColors.accentOrange,
                    height: buttonHeight,
                    iconSize: iconSize,
                    fontSize: fontSize,
                  )
                : _buildGradientButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      timerProvider.resumeTimer();
                    },
                    icon: Icons.play_arrow_rounded,
                    label: '계속하기',
                    gradient: AppGradients.greenGradient,
                    glowColor: AppColors.accentGreen,
                    height: buttonHeight,
                    iconSize: iconSize,
                    fontSize: fontSize,
                  ),
          ),
          SizedBox(width: spacing),
          // 정지 버튼
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              timerProvider.resetTimer();
            },
            child: Container(
              width: stopButtonSize,
              height: stopButtonSize,
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(stopButtonSize * 0.3),
                border: Border.all(
                  color: AppColors.advancedRed.withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.stop_rounded,
                color: AppColors.advancedRed,
                size: iconSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required Color glowColor,
    required double height,
    required double iconSize,
    required double fontSize,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(height * 0.3),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: iconSize),
            SizedBox(width: iconSize * 0.35),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 커스텀 타이머 링 페인터
class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool hasShadow;

  _TimerRingPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 12,
    this.hasShadow = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (hasShadow) {
      final shadowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..strokeWidth = strokeWidth + 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        shadowPaint,
      );
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
