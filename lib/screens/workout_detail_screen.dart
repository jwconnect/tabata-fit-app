import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../providers/timer_provider.dart';
import '../utils/app_theme.dart';
import 'timer_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  void _openFullScreenVideo(String exerciseName) {
    final videoPath = ExerciseAssets.getVideoPathByName(exerciseName);
    if (videoPath.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _FullScreenVideoPlayer(
          videoPath: videoPath,
          exerciseName: exerciseName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final workout = widget.workout;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 헤더 이미지 영역
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeaderBackground(),
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

  /// 헤더 배경 위젯 (프로그램 이미지 또는 첫 번째 운동 이미지)
  Widget _buildHeaderBackground() {
    // 프로그램 이미지 또는 첫 번째 운동 이미지 가져오기
    String imagePath = ExerciseAssets.getProgramImagePath(widget.workout.id);
    if (imagePath.isEmpty) {
      imagePath = ExerciseAssets.getFirstExerciseImage(
        widget.workout.instructions,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 배경 이미지 또는 그라데이션
        if (imagePath.isNotEmpty)
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildGradientBackground();
            },
          )
        else
          _buildGradientBackground(),

        // 그라데이션 오버레이 (하단 어둡게)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
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
          bottom: 60,
          left: 0,
          right: 0,
          child: Center(
            child: _buildDifficultyBadge(widget.workout.difficulty),
          ),
        ),
      ],
    );
  }

  /// 이미지가 없을 때 표시할 그라데이션 배경
  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getDifficultyColor(widget.workout.difficulty),
            _getDifficultyColor(widget.workout.difficulty).withOpacity(0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // 배경 패턴
          Positioned.fill(child: CustomPaint(painter: _PatternPainter())),
          // 아이콘
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getWorkoutIcon(widget.workout.id),
                size: 64,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
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

    if (widget.workout.difficulty == 'BEGINNER') {
      workTime = 20;
      restTime = 15;
      sets = 6;
    } else if (widget.workout.difficulty == 'INTERMEDIATE') {
      workTime = 20;
      restTime = 10;
      sets = 8;
    } else if (widget.workout.difficulty == 'ADVANCED') {
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
    final imagePath = ExerciseAssets.getImagePathByName(exercise);
    final hasImage = imagePath.isNotEmpty;
    final videoPath = ExerciseAssets.getVideoPathByName(exercise);
    final hasVideo = videoPath.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 운동 이미지 (비디오가 있으면 재생 버튼 오버레이)
          if (hasImage)
            GestureDetector(
              onTap: hasVideo ? () => _openFullScreenVideo(exercise) : null,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: _getDifficultyColor(
                              widget.workout.difficulty,
                            ).withOpacity(0.2),
                            child: Center(
                              child: Icon(
                                Icons.fitness_center,
                                size: 48,
                                color: _getDifficultyColor(
                                  widget.workout.difficulty,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // 비디오가 있으면 재생 버튼 오버레이
                      if (hasVideo)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryRed,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryRed.withOpacity(
                                      0.5,
                                    ),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          // 운동 정보
          Padding(
            padding: const EdgeInsets.all(16),
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
                if (hasVideo)
                  Icon(Icons.videocam, color: AppColors.primaryRed, size: 24)
                else
                  Icon(
                    Icons.image,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                    size: 24,
                  ),
              ],
            ),
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
        children: widget.workout.tips
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
    final badgePath = ExerciseAssets.getDifficultyBadgePath(difficulty);

    // 난이도별 글로우 색상
    Color glowColor;
    switch (difficulty) {
      case 'BEGINNER':
        glowColor = AppColors.beginnerGreen;
        break;
      case 'INTERMEDIATE':
        glowColor = AppColors.intermediateOrange;
        break;
      case 'ADVANCED':
        glowColor = AppColors.advancedRed;
        break;
      default:
        glowColor = Colors.white;
    }

    if (badgePath.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: glowColor.withOpacity(0.6), width: 2),
          boxShadow: [
            // 외부 글로우
            BoxShadow(
              color: glowColor.withOpacity(0.7),
              blurRadius: 16,
              spreadRadius: 2,
            ),
            // 내부 그림자
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Image.asset(
          badgePath,
          height: 36,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackBadge(difficulty);
          },
        ),
      );
    }

    return _buildFallbackBadge(difficulty);
  }

  Widget _buildFallbackBadge(String difficulty) {
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

    if (widget.workout.difficulty == 'BEGINNER') {
      workTime = 20;
      restTime = 15;
      sets = 6;
    } else if (widget.workout.difficulty == 'INTERMEDIATE') {
      workTime = 20;
      restTime = 10;
      sets = 8;
    } else if (widget.workout.difficulty == 'ADVANCED') {
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

/// 전체 화면 비디오 플레이어
class _FullScreenVideoPlayer extends StatefulWidget {
  final String videoPath;
  final String exerciseName;

  const _FullScreenVideoPlayer({
    required this.videoPath,
    required this.exerciseName,
  });

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.setLooping(true);
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 배경 그라데이션
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Colors.grey.shade900, Colors.black],
                ),
              ),
            ),

            // 비디오 플레이어
            if (_isInitialized)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: AppColors.primaryRed),
              ),

            // 상단 헤더
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.exerciseName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 재생/일시정지 버튼 (중앙)
            if (_isInitialized && !_controller.value.isPlaying)
              Center(
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryRed.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),

            // 하단 프로그레스 바
            if (_isInitialized)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: AppColors.primaryRed,
                    bufferedColor: Colors.white24,
                    backgroundColor: Colors.white12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
