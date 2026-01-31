import 'dart:math' as math;
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
    _videoController?.dispose();
    _isVideoInitialized = false;

    _videoController = VideoPlayerController.asset(videoPath)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
          _videoController?.setLooping(true);
          _videoController?.setVolume(0);
          _videoController?.play();
        }
      });
  }

  void _disposeVideo() {
    _videoController?.dispose();
    _videoController = null;
    _isVideoInitialized = false;
    _currentVideoPath = null;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
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
                  _videoController != null)
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                )
              else if (showFullScreenVideo)
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
              SafeArea(
                child: Column(
                  children: [
                    // 상단 바
                    _buildTopBar(timerProvider),

                    const Spacer(flex: 1),

                    // 전체화면 비디오 모드 UI (운동/준비/휴식)
                    if (showFullScreenVideo)
                      _buildFullScreenVideoOverlay(
                        timerProvider,
                        intervalType,
                        intervalColor,
                        currentTime,
                        progress,
                        currentSet,
                        totalSets,
                        state,
                      )
                    else ...[
                      // 기존 UI (정리운동/완료)
                      _buildIntervalBadge(intervalType, intervalColor),
                      const SizedBox(height: 50),
                      _buildMainTimer(
                        currentTime,
                        progress,
                        intervalColor,
                        state,
                      ),
                      const SizedBox(height: 40),
                      if (currentSet > 0)
                        _buildSetIndicator(
                          currentSet,
                          totalSets,
                          intervalColor,
                        ),
                    ],

                    const Spacer(flex: 1),

                    // 완료 메시지
                    if (state == TimerState.finished)
                      _buildCompletionCard(context, timerProvider),

                    // 컨트롤 버튼
                    _buildControlButtons(timerProvider, state),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 전체화면 비디오 오버레이 UI
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

    return Column(
      children: [
        // 상단: 인터벌 타입 뱃지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: intervalColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: intervalColor.withOpacity(0.5),
                blurRadius: 25,
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
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                _getIntervalText(intervalType),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 서브텍스트
        Text(
          _getIntervalSubtext(intervalType),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 40),

        // 중앙: 대형 카운트다운
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
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                  border: Border.all(color: intervalColor, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: intervalColor.withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 원형 프로그레스
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
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
                        fontSize: 72,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: intervalColor.withOpacity(0.8),
                            blurRadius: 30,
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
        const SizedBox(height: 30),

        // 운동 이름
        if (exerciseName != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fitness_center, color: intervalColor, size: 22),
                const SizedBox(width: 10),
                Text(
                  intervalType == IntervalType.rest
                      ? '다음: $exerciseName'
                      : exerciseName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),

        // 세트 표시
        if (currentSet > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(totalSets, (index) {
                final isCompleted = index < currentSet;
                final isCurrent = index == currentSet - 1;
                return Container(
                  width: isCurrent ? 28 : 20,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: isCompleted
                        ? intervalColor
                        : Colors.white.withOpacity(0.2),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: intervalColor.withOpacity(0.6),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                );
              }),
            ],
          ),
        const SizedBox(height: 8),
        Text(
          'SET $currentSet / $totalSets',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(TimerProvider timerProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Icon(
                Icons.close,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule,
                  color: AppColors.textMuted,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(timerProvider.totalTime),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 46),
        ],
      ),
    );
  }

  Widget _buildIntervalBadge(IntervalType type, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
              Icon(_getIntervalIcon(type), color: color, size: 26),
              const SizedBox(width: 12),
              Text(
                _getIntervalText(type),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getIntervalSubtext(type),
          style: TextStyle(
            fontSize: 12,
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
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = state == TimerState.running ? _pulseAnimation.value : 1.0;
        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 외부 글로우 링
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 300,
                      height: 300,
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
                  size: const Size(280, 280),
                  painter: _TimerRingPainter(
                    progress: 1,
                    color: AppColors.surfaceDark,
                    strokeWidth: 14,
                  ),
                ),

                // 진행 링
                CustomPaint(
                  size: const Size(280, 280),
                  painter: _TimerRingPainter(
                    progress: progress,
                    color: color,
                    strokeWidth: 14,
                    hasShadow: true,
                  ),
                ),

                // 내부 원
                Container(
                  width: 230,
                  height: 230,
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
                          fontSize: 64,
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
    return Column(
      children: [
        Text(
          'SET',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSets, (index) {
            final isCompleted = index < currentSet;
            final isCurrent = index == currentSet - 1;
            return Container(
              width: isCurrent ? 32 : 24,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isCompleted ? color : AppColors.surfaceDark,
                boxShadow: isCurrent
                    ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                    : null,
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Text(
          '$currentSet / $totalSets',
          style: TextStyle(
            fontSize: 18,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentGreen.withOpacity(0.2),
            AppColors.accentGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.accentGreen,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '운동 완료!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.accentGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '오늘도 멋지게 해냈어요 💪',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(TimerProvider timerProvider, TimerState state) {
    if (state == TimerState.initial ||
        state == TimerState.ready ||
        state == TimerState.finished) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: _buildGradientButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            timerProvider.startTimer();
          },
          icon: Icons.play_arrow_rounded,
          label: state == TimerState.finished ? '다시 시작' : '시작하기',
          gradient: AppGradients.greenGradient,
          glowColor: AppColors.accentGreen,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
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
                  ),
          ),
          const SizedBox(width: 16),
          // 정지 버튼
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              timerProvider.resetTimer();
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.advancedRed.withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.stop_rounded,
                color: AppColors.advancedRed,
                size: 30,
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
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
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
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
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
