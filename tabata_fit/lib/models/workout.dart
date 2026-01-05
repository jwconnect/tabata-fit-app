class Workout {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String videoUrl;
  final String difficulty; // BEGINNER, INTERMEDIATE, ADVANCED
  final List<String> muscleGroups;
  final List<String> instructions;
  final List<String> tips;

  Workout({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl = '',
    this.videoUrl = '',
    this.difficulty = 'BEGINNER',
    this.muscleGroups = const [],
    this.instructions = const [],
    this.tips = const [],
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      difficulty: json['difficulty'] ?? 'BEGINNER',
      muscleGroups: List<String>.from(json['muscleGroups'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      tips: List<String>.from(json['tips'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'difficulty': difficulty,
      'muscleGroups': muscleGroups,
      'instructions': instructions,
      'tips': tips,
    };
  }
}

// 기본 타바타 운동 세트
final List<Workout> defaultWorkouts = [
  Workout(
    id: 'tabata_classic',
    name: '클래식 타바타',
    description: '20초 운동, 10초 휴식, 8세트의 오리지널 타바타 프로토콜입니다.',
    difficulty: 'ADVANCED',
    muscleGroups: ['전신'],
    instructions: ['버피', '스쿼트', '푸시업', '마운틴 클라이머'],
    tips: ['최대 강도로 수행하세요.', '자세가 무너지지 않도록 주의하세요.'],
  ),
  Workout(
    id: 'tabata_beginner',
    name: '초보자 타바타',
    description: '낮은 충격의 운동으로 구성된 초보자를 위한 타바타입니다.',
    difficulty: 'BEGINNER',
    muscleGroups: ['전신'],
    instructions: ['제자리 걷기', '무릎 올리기', '벽 푸시업', '플랭크'],
    tips: ['자신의 페이스에 맞춰 진행하세요.', '휴식 시간을 늘려도 좋습니다.'],
  ),
];
