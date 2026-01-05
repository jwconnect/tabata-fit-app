class WorkoutSession {
  final String id;
  final DateTime date;
  final String workoutId;
  final String workoutName;
  final int duration; // 초
  final int sets;
  final double calories;

  WorkoutSession({
    required this.id,
    required this.date,
    required this.workoutId,
    required this.workoutName,
    required this.duration,
    required this.sets,
    this.calories = 0.0,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'],
      date: DateTime.parse(json['date']),
      workoutId: json['workoutId'],
      workoutName: json['workoutName'],
      duration: json['duration'],
      sets: json['sets'],
      calories: json['calories'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'workoutId': workoutId,
      'workoutName': workoutName,
      'duration': duration,
      'sets': sets,
      'calories': calories,
    };
  }
}
