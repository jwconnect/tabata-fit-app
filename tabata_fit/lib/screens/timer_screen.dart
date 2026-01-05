import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';

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
        return '정리 운동';
      default:
        return '';
    }
  }

  Color _getIntervalColor(IntervalType type) {
    switch (type) {
      case IntervalType.prepare:
        return Colors.yellow.shade700;
      case IntervalType.work:
        return Colors.red.shade700;
      case IntervalType.rest:
        return Colors.blue.shade700;
      case IntervalType.cooldown:
        return Colors.green.shade700;
      default:
        return Colors.grey;
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
        final totalTime = timerProvider.totalTime;
        final progress = timerProvider.progress;

        return Scaffold(
          appBar: AppBar(
            title: const Text('타바타 타이머'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                // 전체 시간 표시
                Text(
                  '전체 남은 시간: ${_formatTime(totalTime)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),

                // 타이머 영역
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 15,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getIntervalColor(intervalType),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getIntervalText(intervalType),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: _getIntervalColor(intervalType),
                          ),
                        ),
                        Text(
                          _formatTime(currentTime),
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 80,
                            color: _getIntervalColor(intervalType),
                          ),
                        ),
                        if (currentSet > 0)
                          Text(
                            '세트: $currentSet / ${TimerProvider.defaultSets}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ],
                ),

                // 컨트롤 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (state == TimerState.initial || state == TimerState.finished)
                      ElevatedButton.icon(
                        onPressed: timerProvider.startTimer,
                        icon: const Icon(Icons.play_arrow, size: 30),
                        label: const Text('시작', style: TextStyle(fontSize: 24)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                      ),
                    if (state == TimerState.running)
                      ElevatedButton.icon(
                        onPressed: timerProvider.pauseTimer,
                        icon: const Icon(Icons.pause, size: 30),
                        label: const Text('일시정지', style: TextStyle(fontSize: 24)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                      ),
                    if (state == TimerState.paused)
                      ElevatedButton.icon(
                        onPressed: timerProvider.resumeTimer,
                        icon: const Icon(Icons.play_arrow, size: 30),
                        label: const Text('재개', style: TextStyle(fontSize: 24)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                      ),
                    const SizedBox(width: 20),
                    if (state != TimerState.initial)
                      ElevatedButton.icon(
                        onPressed: timerProvider.resetTimer,
                        icon: const Icon(Icons.stop, size: 30),
                        label: const Text('정지', style: TextStyle(fontSize: 24)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                      ),
                  ],
                ),
                if (state == TimerState.finished)
                  const Text(
                    '운동 완료!',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
