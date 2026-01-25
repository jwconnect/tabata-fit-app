import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../utils/app_theme.dart';
import 'workout_detail_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, child) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 프리미엄 헤더
              SliverToBoxAdapter(child: _buildHeader(workoutProvider)),

              // 운동 목록
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final workout = workoutProvider.workouts[index];
                    return _buildWorkoutCard(context, workout, index);
                  }, childCount: workoutProvider.workouts.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(WorkoutProvider provider) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타이틀
          const Text(
            '운동 프로그램',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${provider.workouts.length}개의 프로그램',
            style: TextStyle(fontSize: 15, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),

          // 난이도 필터
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterChip('전체', 'ALL', provider),
                const SizedBox(width: 10),
                _buildFilterChip(
                  '초보자',
                  'BEGINNER',
                  provider,
                  color: AppColors.beginnerGreen,
                ),
                const SizedBox(width: 10),
                _buildFilterChip(
                  '중급자',
                  'INTERMEDIATE',
                  provider,
                  color: AppColors.intermediateOrange,
                ),
                const SizedBox(width: 10),
                _buildFilterChip(
                  '고급자',
                  'ADVANCED',
                  provider,
                  color: AppColors.advancedRed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    WorkoutProvider provider, {
    Color? color,
  }) {
    final isSelected = provider.selectedDifficulty == value;
    final chipColor = color ?? AppColors.primaryRed;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        provider.setDifficulty(value);
      },
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [chipColor, chipColor.withOpacity(0.8)])
              : null,
          color: isSelected ? null : AppColors.cardDark,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.glassBorder,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != 'ALL') ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : chipColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Workout workout, int index) {
    // 프로그램 이미지 또는 첫 번째 운동 이미지 가져오기
    String imagePath = ExerciseAssets.getProgramImagePath(workout.id);
    if (imagePath.isEmpty) {
      imagePath = ExerciseAssets.getFirstExerciseImage(workout.instructions);
    }
    final hasImage = imagePath.isNotEmpty;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _openWorkoutDetail(context, workout),
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 썸네일 이미지
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
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
                              Colors.black.withOpacity(0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // 난이도 배지
                      Positioned(
                        top: 16,
                        right: 16,
                        child: _buildDifficultyBadge(workout.difficulty),
                      ),
                      // 운동 정보 오버레이
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            _buildInfoChip(
                              Icons.timer_outlined,
                              _getWorkoutDuration(workout.difficulty),
                            ),
                            const SizedBox(width: 10),
                            _buildInfoChip(
                              Icons.repeat,
                              '${_getWorkoutSets(workout.difficulty)}세트',
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryRed,
                                shape: BoxShape.circle,
                                boxShadow: AppShadows.glow,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
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
                    Text(
                      workout.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      workout.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    // 근육 그룹 태그
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: workout.muscleGroups
                          .take(3)
                          .map((muscle) => _buildMuscleTag(muscle))
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

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleTag(String muscle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Text(
        muscle,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
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
        bgColor = AppColors.primaryRed;
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
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 48, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    final badgePath = ExerciseAssets.getDifficultyBadgePath(difficulty);

    Color glowColor;
    String label;
    switch (difficulty) {
      case 'BEGINNER':
        glowColor = AppColors.beginnerGreen;
        label = '초보자';
        break;
      case 'INTERMEDIATE':
        glowColor = AppColors.intermediateOrange;
        label = '중급자';
        break;
      case 'ADVANCED':
        glowColor = AppColors.advancedRed;
        label = '고급자';
        break;
      default:
        glowColor = Colors.white;
        label = difficulty;
    }

    if (badgePath.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: glowColor.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Image.asset(
          badgePath,
          height: 28,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildTextBadge(label, glowColor);
          },
        ),
      );
    }

    return _buildTextBadge(label, glowColor);
  }

  Widget _buildTextBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getWorkoutDuration(String difficulty) {
    switch (difficulty) {
      case 'BEGINNER':
        return '약 6분';
      case 'INTERMEDIATE':
        return '약 8분';
      case 'ADVANCED':
        return '약 10분';
      default:
        return '약 8분';
    }
  }

  int _getWorkoutSets(String difficulty) {
    switch (difficulty) {
      case 'BEGINNER':
        return 6;
      case 'INTERMEDIATE':
        return 8;
      case 'ADVANCED':
        return 10;
      default:
        return 8;
    }
  }

  void _openWorkoutDetail(BuildContext context, Workout workout) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            WorkoutDetailScreen(workout: workout),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
