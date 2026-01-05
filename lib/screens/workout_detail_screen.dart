import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../providers/timer_provider.dart';
import '../utils/app_theme.dart';
import 'timer_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 헤더 이미지 영역
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getDifficultyColor(workout.difficulty),
                      _getDifficultyColor(workout.difficulty).withOpacity(0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    // 배경 패턴
                    Positioned.fill(
                      child: CustomPaint(painter: _PatternPainter()),
                    ),
                    // 아이콘
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getWorkoutIcon(workout.id),
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDifficultyBadge(workout.difficulty),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 콘텐츠
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.deepBlack : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 운동 제목
                      Text(
                        workout.name,
                        style: AppTextStyles.headline1.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        workout.description,
                        style: AppTextStyles.body1.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 운동 정보 카드
                      _buildInfoCard(isDark),
                      const SizedBox(height: 28),

                      // 타겟 부위
                      _buildSectionTitle('타겟 부위', isDark),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: workout.muscleGroups
                            .map((muscle) => _buildMuscleChip(muscle, isDark))
                            .toList(),
                      ),
                      const SizedBox(height: 28),

                      // 운동 동작
                      _buildSectionTitle('운동 동작', isDark),
                      const SizedBox(height: 12),
                      ...workout.instructions.asMap().entries.map(
                        (entry) => _buildExerciseItem(
                          entry.key + 1,
                          entry.value,
                          isDark,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 운동 팁
                      if (workout.tips.isNotEmpty) ...[
                        _buildSectionTitle('운동 팁', isDark),
                        const SizedBox(height: 12),
                        _buildTipsCard(isDark),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, isDark),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primaryRed,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTextStyles.headline3.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(bool isDark) {
    int workTime = 20;
    int restTime = 10;
    int sets = 8;

    if (workout.difficulty == 'BEGINNER') {
      workTime = 20;
      restTime = 15;
      sets = 6;
    } else if (workout.difficulty == 'INTERMEDIATE') {
      workTime = 20;
      restTime = 10;
      sets = 8;
    } else if (workout.difficulty == 'ADVANCED') {
      workTime = 25;
      restTime = 10;
      sets = 10;
    }

    final totalTime = 10 + (workTime + restTime) * sets + 30;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark ? AppGradients.cardGradient : null,
        color: isDark ? null : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.grey[800]!) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(Icons.schedule, '${totalTime ~/ 60}분', '총 시간', isDark),
          _buildDivider(isDark),
          _buildInfoItem(Icons.repeat, '$sets', '세트', isDark),
          _buildDivider(isDark),
          _buildInfoItem(Icons.fitness_center, '${workTime}초', '운동', isDark),
          _buildDivider(isDark),
          _buildInfoItem(Icons.pause_circle, '${restTime}초', '휴식', isDark),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 40,
      width: 1,
      color: isDark ? Colors.grey[700] : Colors.grey[300],
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String value,
    String label,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryRed, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMuscleChip(String muscle, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        muscle,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildExerciseItem(int index, String exercise, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGray : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppGradients.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              exercise,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Icon(
            Icons.play_circle_outline,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accentYellow.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentYellow.withOpacity(0.3)),
      ),
      child: Column(
        children: workout.tips
            .map(
              (tip) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: AppColors.accentYellow,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGray : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: AppGradients.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryRed.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _startWorkout(context),
              borderRadius: BorderRadius.circular(16),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '운동 시작',
                      style: TextStyle(
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
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    String label;
    switch (difficulty) {
      case 'BEGINNER':
        label = '초보자';
        break;
      case 'INTERMEDIATE':
        label = '중급자';
        break;
      case 'ADVANCED':
        label = '고급자';
        break;
      default:
        label = difficulty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'BEGINNER':
        return AppColors.beginnerGreen;
      case 'INTERMEDIATE':
        return AppColors.intermediateOrange;
      case 'ADVANCED':
        return AppColors.advancedRed;
      default:
        return Colors.grey;
    }
  }

  IconData _getWorkoutIcon(String workoutId) {
    if (workoutId.contains('cardio')) {
      return Icons.directions_run;
    } else if (workoutId.contains('core')) {
      return Icons.accessibility_new;
    } else if (workoutId.contains('lower')) {
      return Icons.directions_walk;
    } else {
      return Icons.fitness_center;
    }
  }

  void _startWorkout(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);

    int workTime = 20;
    int restTime = 10;
    int sets = 8;

    if (workout.difficulty == 'BEGINNER') {
      workTime = 20;
      restTime = 15;
      sets = 6;
    } else if (workout.difficulty == 'INTERMEDIATE') {
      workTime = 20;
      restTime = 10;
      sets = 8;
    } else if (workout.difficulty == 'ADVANCED') {
      workTime = 25;
      restTime = 10;
      sets = 10;
    }

    timerProvider.setTimerSettings(
      workTime: workTime,
      restTime: restTime,
      sets: sets,
      prepareTime: 10,
      cooldownTime: 30,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TimerScreen()),
    );
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // 기하학적 패턴 그리기
    for (var i = 0; i < 6; i++) {
      for (var j = 0; j < 8; j++) {
        if ((i + j) % 2 == 0) {
          canvas.drawCircle(
            Offset(i * size.width / 5, j * size.height / 7),
            20,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
