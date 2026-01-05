import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../utils/app_theme.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

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
        return Colors.grey;
    }
  }

  IconData _getIntervalIcon(IntervalType type) {
    switch (type) {
      case IntervalType.prepare:
        return Icons.timer;
      case IntervalType.work:
        return Icons.fitness_center;
      case IntervalType.rest:
        return Icons.self_improvement;
      case IntervalType.cooldown:
        return Icons.air;
      default:
        return Icons.timer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        final state = timerProvider.state;
        final intervalType = timerProvider.intervalType;
        final currentTime = timerProvider.currentTime;
        final currentSet = timerProvider.currentSet;
        final totalTime = timerProvider.totalTime;
        final progress = timerProvider.progress;
        final intervalColor = _getIntervalColor(intervalType);

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  intervalColor.withOpacity(0.15),
                  isDark ? AppColors.deepBlack : Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // 상단 바
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '전체 ${_formatTime(totalTime)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 인터벌 상태 표시
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: intervalColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getIntervalIcon(intervalType),
                          color: intervalColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getIntervalText(intervalType),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: intervalColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 타이머 원형 표시
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // 배경 원
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 12,
                          backgroundColor: isDark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? Colors.grey[800]! : Colors.grey[200]!,
                          ),
                        ),
                      ),
                      // 진행 원
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          strokeCap: StrokeCap.round,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            intervalColor,
                          ),
                        ),
                      ),
                      // 시간 표시
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(currentTime),
                            style: AppTextStyles.timerLarge.copyWith(
                              color: intervalColor,
                            ),
                          ),
                          if (currentSet > 0)
                            Text(
                              '세트 $currentSet / ${TimerProvider.defaultSets}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // 완료 메시지
                  if (state == TimerState.finished)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.accentGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.celebration,
                            color: AppColors.accentGreen,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '운동 완료!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentGreen,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // 컨트롤 버튼
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    child: _buildControlButtons(
                      context,
                      timerProvider,
                      state,
                      isDark,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButtons(
    BuildContext context,
    TimerProvider timerProvider,
    TimerState state,
    bool isDark,
  ) {
    if (state == TimerState.initial ||
        state == TimerState.ready ||
        state == TimerState.finished) {
      return _buildPrimaryButton(
        onPressed: timerProvider.startTimer,
        icon: Icons.play_arrow_rounded,
        label: state == TimerState.finished ? '다시 시작' : '시작',
        color: AppColors.accentGreen,
      );
    }

    return Row(
      children: [
        if (state == TimerState.running)
          Expanded(
            child: _buildPrimaryButton(
              onPressed: timerProvider.pauseTimer,
              icon: Icons.pause_rounded,
              label: '일시정지',
              color: AppColors.intermediateOrange,
            ),
          )
        else if (state == TimerState.paused)
          Expanded(
            child: _buildPrimaryButton(
              onPressed: timerProvider.resumeTimer,
              icon: Icons.play_arrow_rounded,
              label: '재개',
              color: AppColors.accentGreen,
            ),
          ),
        const SizedBox(width: 16),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkGray : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: timerProvider.resetTimer,
            icon: Icon(
              Icons.stop_rounded,
              color: AppColors.advancedRed,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
