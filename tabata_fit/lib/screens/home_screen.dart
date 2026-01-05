import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import 'timer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TabataFit'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                '오늘의 운동 요약',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                '클래식 타바타 (20초 운동 / 10초 휴식 x 8세트)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  // 타이머 설정 초기화 및 화면 이동
                  Provider.of<TimerProvider>(context, listen: false).setTimerSettings(
                    workTime: 20,
                    restTime: 10,
                    sets: 8,
                    prepareTime: 10,
                    cooldownTime: 30,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TimerScreen()),
                  );
                },
                icon: const Icon(Icons.timer, size: 30),
                label: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Text(
                    '빠른 시작',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
              const SizedBox(height: 40),
              // TODO: 운동 선택, 통계, 커뮤니티, 설정 버튼 추가 예정
            ],
          ),
        ),
      ),
    );
  }
}
