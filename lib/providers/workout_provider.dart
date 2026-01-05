import 'package:flutter/material.dart';
import '../models/workout.dart';

class WorkoutProvider with ChangeNotifier {
  final List<Workout> _workouts = List.from(defaultWorkouts);
  String _selectedDifficulty = 'ALL';

  List<Workout> get workouts {
    if (_selectedDifficulty == 'ALL') {
      return _workouts;
    }
    return _workouts.where((w) => w.difficulty == _selectedDifficulty).toList();
  }

  List<Workout> get allWorkouts => _workouts;

  String get selectedDifficulty => _selectedDifficulty;

  void setDifficulty(String difficulty) {
    _selectedDifficulty = difficulty;
    notifyListeners();
  }

  Workout? getWorkoutById(String id) {
    try {
      return _workouts.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }
}
