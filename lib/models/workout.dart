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
    id: 'tabata_beginner',
    name: '초보자 타바타',
    description: '낮은 충격의 운동으로 구성된 초보자를 위한 타바타입니다.',
    difficulty: 'BEGINNER',
    muscleGroups: ['전신'],
    instructions: ['제자리 걷기', '무릎 올리기', '벽 푸시업', '플랭크'],
    tips: ['자신의 페이스에 맞춰 진행하세요.', '휴식 시간을 늘려도 좋습니다.'],
  ),
  Workout(
    id: 'tabata_lower_body',
    name: '하체 집중 타바타',
    description: '하체 근력 강화를 위한 타바타 운동입니다.',
    difficulty: 'BEGINNER',
    muscleGroups: ['하체', '엉덩이'],
    instructions: ['스쿼트', '런지', '카프레이즈', '글루트 브릿지'],
    tips: ['무릎이 발끝을 넘지 않도록 주의하세요.'],
  ),
  Workout(
    id: 'tabata_intermediate',
    name: '중급자 타바타',
    description: '기본기를 익힌 분들을 위한 중강도 타바타입니다.',
    difficulty: 'INTERMEDIATE',
    muscleGroups: ['전신'],
    instructions: ['점프 스쿼트', '푸시업', '런지', '플랭크 잭'],
    tips: ['호흡을 일정하게 유지하세요.', '폼을 유지하면서 속도를 높이세요.'],
  ),
  Workout(
    id: 'tabata_cardio',
    name: '유산소 타바타',
    description: '심폐 지구력 향상을 위한 유산소 중심 타바타입니다.',
    difficulty: 'INTERMEDIATE',
    muscleGroups: ['전신', '심폐'],
    instructions: ['하이니', '버피', '점핑잭', '마운틴 클라이머'],
    tips: ['심박수를 높게 유지하세요.', '숨이 차더라도 멈추지 마세요.'],
  ),
  Workout(
    id: 'tabata_core',
    name: '코어 강화 타바타',
    description: '복부와 코어 근육 강화를 위한 타바타입니다.',
    difficulty: 'INTERMEDIATE',
    muscleGroups: ['복부', '코어'],
    instructions: ['플랭크', '크런치', '레그레이즈', '러시안 트위스트'],
    tips: ['허리가 바닥에서 뜨지 않도록 주의하세요.'],
  ),
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
    id: 'tabata_extreme',
    name: '익스트림 타바타',
    description: '최고 강도의 전신 타바타 운동입니다. 상급자 전용!',
    difficulty: 'ADVANCED',
    muscleGroups: ['전신'],
    instructions: ['버피', '점프 런지', '다이아몬드 푸시업', '터크 점프'],
    tips: ['충분한 워밍업 후 시작하세요.', '무리하지 마세요.'],
  ),
];
