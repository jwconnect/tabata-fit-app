import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('통계')),
      body: Consumer<StatisticsProvider>(
        builder: (context, statsProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 요약 카드들
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.fitness_center,
                        title: '총 운동',
                        value: '${statsProvider.totalWorkouts}회',
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.timer,
                        title: '총 시간',
                        value: statsProvider.formatDuration(
                          statsProvider.totalDuration,
                        ),
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.local_fire_department,
                        title: '소모 칼로리',
                        value:
                            '${statsProvider.totalCalories.toStringAsFixed(0)} kcal',
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.emoji_events,
                        title: '연속 운동',
                        value: '${statsProvider.currentStreak}일',
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 주간 차트
                const Text(
                  '이번 주 운동',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildWeeklyChart(statsProvider),

                const SizedBox(height: 24),

                // 최근 운동 기록
                const Text(
                  '최근 기록',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (statsProvider.sessions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '아직 운동 기록이 없습니다.\n첫 운동을 시작해보세요!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...statsProvider.sessions.reversed
                      .take(5)
                      .map(
                        (session) => _buildSessionCard(session, statsProvider),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(StatisticsProvider statsProvider) {
    final weeklyStats = statsProvider.weeklyStats;
    final maxValue = weeklyStats.values.fold(0, (a, b) => a > b ? a : b);
    final days = ['월', '화', '수', '목', '금', '토', '일'];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final dayIndex = index + 1;
              final value = weeklyStats[dayIndex] ?? 0;
              final height = maxValue > 0 ? (value / maxValue) * 100 : 0.0;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (value > 0)
                    Text(
                      '${value ~/ 60}분',
                      style: const TextStyle(fontSize: 10),
                    ),
                  const SizedBox(height: 4),
                  Container(
                    width: 30,
                    height: height > 0 ? height : 4,
                    decoration: BoxDecoration(
                      color: value > 0
                          ? Colors.deepOrange
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days[index],
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard(session, StatisticsProvider statsProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.deepOrange,
          child: Icon(Icons.fitness_center, color: Colors.white),
        ),
        title: Text(session.workoutName),
        subtitle: Text(
          '${session.date.month}/${session.date.day} - ${statsProvider.formatDuration(session.duration)}',
        ),
        trailing: Text(
          '${session.sets}세트',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
      ),
    );
  }
}
