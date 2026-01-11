import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../utils/app_theme.dart';
import 'workout_detail_screen.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, child) {
          return CustomScrollView(
            slivers: [
              // 세련된 앱바
              SliverAppBar(
                expandedHeight: 140,
                floating: false,
                pinned: true,
                backgroundColor: isDark ? AppColors.darkGray : Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    '운동 프로그램',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 20,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.darkGray, AppColors.deepBlack]
                            : [Colors.white, AppColors.lightGray],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),

              // 난이도 필터
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          context,
                          '전체',
                          'ALL',
                          workoutProvider,
                          isDark,
                        ),
                        const SizedBox(width: 10),
                        _buildFilterChip(
                          context,
                          '초보자',
                          'BEGINNER',
                          workoutProvider,
                          isDark,
                        ),
                        const SizedBox(width: 10),
                        _buildFilterChip(
                          context,
                          '중급자',
                          'INTERMEDIATE',
                          workoutProvider,
                          isDark,
                        ),
                        const SizedBox(width: 10),
                        _buildFilterChip(
                          context,
                          '고급자',
                          'ADVANCED',
                          workoutProvider,
                          isDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 운동 목록
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final workout = workoutProvider.workouts[index];
                    return _buildWorkoutCard(context, workout, isDark);
                  }, childCount: workoutProvider.workouts.length),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String value,
    WorkoutProvider provider,
    bool isDark,
  ) {
    final isSelected = provider.selectedDifficulty == value;

    Color chipColor;
    if (value == 'BEGINNER') {
      chipColor = AppColors.beginnerGreen;
    } else if (value == 'INTERMEDIATE') {
      chipColor = AppColors.intermediateOrange;
    } else if (value == 'ADVANCED') {
      chipColor = AppColors.advancedRed;
    } else {
      chipColor = AppColors.primaryRed;
    }

    return GestureDetector(
      onTap: () => provider.setDifficulty(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor
              : (isDark ? AppColors.mediumGray : Colors.grey[200]),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey[400] : Colors.grey[700]),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Workout workout, bool isDark) {
    // 프로그램 이미지 또는 첫 번째 운동 이미지 가져오기
    String imagePath = ExerciseAssets.getProgramImagePath(workout.id);
    if (imagePath.isEmpty) {
      imagePath = ExerciseAssets.getFirstExerciseImage(workout.instructions);
    }
    final hasImage = imagePath.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGray : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openWorkoutDetail(context, workout),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 썸네일 이미지
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      hasImage
                          ? Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderImage(workout);
                              },
                            )
                          : _buildPlaceholderImage(workout),
                      // 그라데이션 오버레이
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                      // 난이도 배지
                      Positioned(
                        top: 16,
                        right: 16,
                        child: _buildDifficultyBadge(workout.difficulty),
                      ),
                      // 운동 시간 표시
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: _buildTimeIndicator(workout.difficulty),
                      ),
                    ],
                  ),
                ),
              ),
              // 운동 정보
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목과 화살표
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            workout.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.primaryRed,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      workout.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 운동 동작 태그
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: workout.instructions
                          .take(4)
                          .map(
                            (exercise) => _buildExerciseTag(exercise, isDark),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseTag(String exercise, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.mediumGray
            : AppColors.primaryRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        exercise,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.grey[300] : AppColors.primaryRed,
        ),
      ),
    );
  }

  Widget _buildTimeIndicator(String difficulty) {
    int minutes;
    int sets;

    switch (difficulty) {
      case 'BEGINNER':
        minutes = 6;
        sets = 6;
        break;
      case 'INTERMEDIATE':
        minutes = 8;
        sets = 8;
        break;
      case 'ADVANCED':
        minutes = 10;
        sets = 10;
        break;
      default:
        minutes = 8;
        sets = 8;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            '약 $minutes분',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            width: 1,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: Colors.white38,
          ),
          Text(
            '$sets세트',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(Workout workout) {
    Color bgColor;
    IconData icon;

    switch (workout.difficulty) {
      case 'BEGINNER':
        bgColor = AppColors.beginnerGreen;
        break;
      case 'INTERMEDIATE':
        bgColor = AppColors.intermediateOrange;
        break;
      case 'ADVANCED':
        bgColor = AppColors.advancedRed;
        break;
      default:
        bgColor = Colors.grey;
    }

    if (workout.id.contains('cardio')) {
      icon = Icons.directions_run_rounded;
    } else if (workout.id.contains('core')) {
      icon = Icons.accessibility_new_rounded;
    } else if (workout.id.contains('lower')) {
      icon = Icons.airline_seat_legroom_extra_rounded;
    } else {
      icon = Icons.fitness_center_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor.withOpacity(0.8), bgColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // 배경 패턴
          Positioned.fill(
            child: CustomPaint(painter: _CirclePatternPainter(bgColor)),
          ),
          // 중앙 아이콘
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    String label;
    IconData icon;

    switch (difficulty) {
      case 'BEGINNER':
        color = AppColors.beginnerGreen;
        label = '초보자';
        icon = Icons.eco_rounded;
        break;
      case 'INTERMEDIATE':
        color = AppColors.intermediateOrange;
        label = '중급자';
        icon = Icons.local_fire_department_rounded;
        break;
      case 'ADVANCED':
        color = AppColors.advancedRed;
        label = '고급자';
        icon = Icons.whatshot_rounded;
        break;
      default:
        color = Colors.grey;
        label = difficulty;
        icon = Icons.fitness_center;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _openWorkoutDetail(BuildContext context, Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutDetailScreen(workout: workout),
      ),
    );
  }
}

class _CirclePatternPainter extends CustomPainter {
  final Color baseColor;

  _CirclePatternPainter(this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // 원형 패턴
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.2),
      size.width * 0.15,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.3),
      size.width * 0.2,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.8),
      size.width * 0.1,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
