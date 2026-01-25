import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/statistics_provider.dart';
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

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
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

        return Scaffold(
          backgroundColor: AppColors.deepBlack,
          body: Stack(
            children: [
              // 배경 그라데이션 효과
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          intervalColor.withOpacity(_glowAnimation.value * 0.3),
                          AppColors.deepBlack,
                        ],
                      ),
                    ),
                  );
                },
              ),

              SafeArea(
                child: Column(
                  children: [
                    // 상단 바
                    _buildTopBar(timerProvider),

                    const Spacer(flex: 1),

                    // 인터벌 상태 배지
                    _buildIntervalBadge(intervalType, intervalColor),
                    const SizedBox(height: 50),

                    // 메인 타이머
                    _buildMainTimer(
                      currentTime,
                      progress,
                      intervalColor,
                      state,
                    ),
                    const SizedBox(height: 40),

                    // 세트 인디케이터
                    if (currentSet > 0)
                      _buildSetIndicator(currentSet, totalSets, intervalColor),

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
