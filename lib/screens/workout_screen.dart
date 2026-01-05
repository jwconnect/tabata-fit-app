import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout.dart';
import 'workout_detail_screen.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('운동 선택')),
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, child) {
          return Column(
            children: [
              // 난이도 필터
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(context, '전체', 'ALL', workoutProvider),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        '초보자',
                        'BEGINNER',
                        workoutProvider,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        '중급자',
                        'INTERMEDIATE',
                        workoutProvider,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        '고급자',
                        'ADVANCED',
                        workoutProvider,
                      ),
                    ],
                  ),
                ),
              ),
              // 운동 목록
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: workoutProvider.workouts.length,
                  itemBuilder: (context, index) {
                    final workout = workoutProvider.workouts[index];
                    return _buildWorkoutCard(context, workout);
                  },
                ),
              ),
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
  ) {
    final isSelected = provider.selectedDifficulty == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        provider.setDifficulty(value);
      },
      selectedColor: Colors.deepOrange.shade100,
      checkmarkColor: Colors.deepOrange,
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => _openWorkoutDetail(context, workout),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      workout.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildDifficultyBadge(workout.difficulty),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                workout.description,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: workout.muscleGroups
                    .map(
                      (muscle) => Chip(
                        label: Text(
                          muscle,
                          style: const TextStyle(fontSize: 12),
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => _openWorkoutDetail(context, workout),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('상세 정보'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openWorkoutDetail(context, workout),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('시작'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    String label;

    switch (difficulty) {
      case 'BEGINNER':
        color = Colors.green;
        label = '초보';
        break;
      case 'INTERMEDIATE':
        color = Colors.orange;
        label = '중급';
        break;
      case 'ADVANCED':
        color = Colors.red;
        label = '고급';
        break;
      default:
        color = Colors.grey;
        label = difficulty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
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
