/// 개별 운동 동작 모델
class Exercise {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String videoUrl;
  final String difficulty; // BEGINNER, INTERMEDIATE, ADVANCED
  final List<String> muscleGroups;
  final List<String> instructions;

  const Exercise({
    required this.id,
    required this.name,
    this.description = '',
    this.imageUrl = '',
    this.videoUrl = '',
    this.difficulty = 'BEGINNER',
    this.muscleGroups = const [],
    this.instructions = const [],
  });
}

/// 운동 이미지 경로 매핑
/// ai_prompt_guide.md의 파일명 규칙에 따라 매핑
class ExerciseAssets {
  static const String _basePath = 'assets/images/exercises/';

  /// 운동 ID를 이미지 경로로 변환
  static String getImagePath(String exerciseId) {
    return _exerciseImages[exerciseId] ?? '';
  }

  /// 운동 이름(한글)을 이미지 경로로 변환
  static String getImagePathByName(String exerciseName) {
    return _exerciseNameToImage[exerciseName] ?? '';
  }

  /// 운동 ID → 이미지 경로 매핑
  static const Map<String, String> _exerciseImages = {
    // 초보자 운동
    'marching': '${_basePath}img_exercise_marching.png',
    'high_knees': '${_basePath}img_exercise_high_knees.png',
    'wall_pushup': '${_basePath}img_exercise_wall_pushup.png',
    'plank_basic': '${_basePath}img_exercise_plank_basic.png',
    'squat_basic': '${_basePath}img_exercise_squat_basic.png',
    'lunge_basic': '${_basePath}img_exercise_lunge_basic.png',
    'calf_raise': '${_basePath}img_exercise_calf_raise.png',
    'glute_bridge': '${_basePath}img_exercise_glute_bridge.png',

    // 중급자 운동
    'jump_squat': '${_basePath}img_exercise_jump_squat.png',
    'pushup': '${_basePath}img_exercise_pushup.png',
    'plank_jack': '${_basePath}img_exercise_plank_jack.png',
    'high_knees_adv': '${_basePath}img_exercise_high_knees_adv.png',
    'jumping_jack': '${_basePath}img_exercise_jumping_jack.png',
    'mountain_climber': '${_basePath}img_exercise_mountain_climber.png',
    'crunch': '${_basePath}img_exercise_crunch.png',
    'leg_raise': '${_basePath}img_exercise_leg_raise.png',
    'russian_twist': '${_basePath}img_exercise_russian_twist.png',

    // 고급자 운동
    'burpee': '${_basePath}img_exercise_burpee.png',
    'jump_lunge': '${_basePath}img_exercise_jump_lunge.png',
    'diamond_pushup': '${_basePath}img_exercise_diamond_pushup.png',
    'tuck_jump': '${_basePath}img_exercise_tuck_jump.png',
  };

  /// 운동 이름(한글) → 이미지 경로 매핑
  static const Map<String, String> _exerciseNameToImage = {
    // 초보자 운동
    '제자리 걷기': '${_basePath}img_exercise_marching.png',
    '무릎 올리기': '${_basePath}img_exercise_high_knees.png',
    '벽 푸시업': '${_basePath}img_exercise_wall_pushup.png',
    '플랭크': '${_basePath}img_exercise_plank_basic.png',
    '플랭크 (기본)': '${_basePath}img_exercise_plank_basic.png',
    '스쿼트': '${_basePath}img_exercise_squat_basic.png',
    '스쿼트 (기본)': '${_basePath}img_exercise_squat_basic.png',
    '런지': '${_basePath}img_exercise_lunge_basic.png',
    '런지 (기본)': '${_basePath}img_exercise_lunge_basic.png',
    '카프레이즈': '${_basePath}img_exercise_calf_raise.png',
    '글루트 브릿지': '${_basePath}img_exercise_glute_bridge.png',

    // 중급자 운동
    '점프 스쿼트': '${_basePath}img_exercise_jump_squat.png',
    '푸시업': '${_basePath}img_exercise_pushup.png',
    '플랭크 잭': '${_basePath}img_exercise_plank_jack.png',
    '하이니': '${_basePath}img_exercise_high_knees_adv.png',
    '하이니 (High Knees)': '${_basePath}img_exercise_high_knees_adv.png',
    '점핑잭': '${_basePath}img_exercise_jumping_jack.png',
    '마운틴 클라이머': '${_basePath}img_exercise_mountain_climber.png',
    '크런치': '${_basePath}img_exercise_crunch.png',
    '레그레이즈': '${_basePath}img_exercise_leg_raise.png',
    '러시안 트위스트': '${_basePath}img_exercise_russian_twist.png',

    // 고급자 운동
    '버피': '${_basePath}img_exercise_burpee.png',
    '점프 런지': '${_basePath}img_exercise_jump_lunge.png',
    '다이아몬드 푸시업': '${_basePath}img_exercise_diamond_pushup.png',
    '터크 점프': '${_basePath}img_exercise_tuck_jump.png',
  };

  /// 프로그램 ID → 대표 이미지 경로 매핑
  static const String _programBasePath = 'assets/images/programs/';
  static const Map<String, String> _programImages = {
    // 초보자
    'tabata_beginner': '${_programBasePath}img_program_beginner.png',
    'tabata_lower_body': '${_programBasePath}img_program_lower_body.png',
    // 중급자
    'tabata_intermediate': '${_programBasePath}img_program_intermediate.png',
    'tabata_cardio': '${_programBasePath}img_program_cardio.png',
    'tabata_core': '${_programBasePath}img_program_core.png',
    'tabata_upper_body': '${_programBasePath}img_program_upper_body.png',
    // 고급자
    'tabata_classic': '${_programBasePath}img_program_classic.png',
    'tabata_extreme': '${_programBasePath}img_program_extreme.png',
    'tabata_hiit': '${_programBasePath}img_program_hiit.png',
  };

  /// 프로그램 ID를 이미지 경로로 변환
  static String getProgramImagePath(String programId) {
    return _programImages[programId] ?? '';
  }

  /// 프로그램의 첫 번째 운동 이미지 가져오기 (대체용)
  static String getFirstExerciseImage(List<String> exerciseNames) {
    for (final name in exerciseNames) {
      final imagePath = _exerciseNameToImage[name];
      if (imagePath != null && imagePath.isNotEmpty) {
        return imagePath;
      }
    }
    return '';
  }

  /// 카테고리 아이콘 경로
  static const String _iconBasePath = 'assets/images/icons/';

  /// 카테고리 ID → 아이콘 경로 매핑
  static const Map<String, String> _categoryIcons = {
    'fullbody': '${_iconBasePath}ic_category_fullbody.png',
    'upperbody': '${_iconBasePath}ic_category_upper_body.png',
    'lowerbody': '${_iconBasePath}ic_category_lowerbody.png',
    'core': '${_iconBasePath}ic_category_core.png',
    'cardio': '${_iconBasePath}ic_category_cardio.png',
    'hiit': '${_iconBasePath}ic_category_hiit.png',
  };

  /// 근육 그룹 이름 → 카테고리 ID 매핑
  /// 다양한 근육 그룹 명칭을 6개 카테고리로 매핑
  static const Map<String, String> _muscleToCategory = {
    // 전신 (fullbody)
    '전신': 'fullbody',
    '상하체': 'fullbody',
    '전체': 'fullbody',

    // 상체 (upperbody)
    '상체': 'upperbody',
    '팔': 'upperbody',
    '어깨': 'upperbody',
    '가슴': 'upperbody',
    '등근육': 'upperbody',

    // 하체 (lowerbody)
    '하체': 'lowerbody',
    '엉덩이': 'lowerbody',
    '허벅지': 'lowerbody',
    '종아리': 'lowerbody',
    '다리': 'lowerbody',
    '둔근': 'lowerbody',
    '대퇴': 'lowerbody',

    // 코어 (core)
    '복부': 'core',
    '코어': 'core',
    '복근': 'core',
    '허리': 'core',
    '옆구리': 'core',
    '등': 'core',
    '척추': 'core',

    // 유산소 (cardio)
    '심폐': 'cardio',
    '유산소': 'cardio',
    '지구력': 'cardio',
    '심장': 'cardio',
    '폐활량': 'cardio',

    // HIIT
    'HIIT': 'hiit',
    '고강도': 'hiit',
    '인터벌': 'hiit',
  };

  /// 카테고리 아이콘 경로 가져오기
  static String getCategoryIconPath(String categoryId) {
    return _categoryIcons[categoryId] ?? '';
  }

  /// 근육 그룹에서 카테고리 아이콘 경로 가져오기
  static String getCategoryIconByMuscle(List<String> muscleGroups) {
    for (final muscle in muscleGroups) {
      final categoryId = _muscleToCategory[muscle];
      if (categoryId != null) {
        return _categoryIcons[categoryId] ?? '';
      }
    }
    // 기본값: 전신
    return _categoryIcons['fullbody'] ?? '';
  }

  /// UI 배경 이미지 경로
  static const Map<String, String> uiBackgrounds = {
    'splash': 'assets/images/ui/bg_splash.png',
    'home': 'assets/images/ui/bg_home_pattern.png',
    'statistics': 'assets/images/ui/bg_statistics.png',
    'onboarding1': 'assets/images/ui/bg_onboarding_01.png',
    'onboarding2': 'assets/images/ui/bg_onboarding_02.png',
  };

  /// 탭바 아이콘 경로
  static const Map<String, String> tabIcons = {
    'home': '${_iconBasePath}ic_tab_home.png',
    'workout': '${_iconBasePath}ic_tab_workout.png',
    'stats': '${_iconBasePath}ic_tab_stats.png',
    'settings': '${_iconBasePath}ic_tab_settings.png',
  };

  /// 앱 런처 아이콘 경로
  static const String launcherIcon = '${_iconBasePath}ic_launcher.png';

  /// 운동 비디오 경로
  static const String _videoBasePath = 'assets/videos/';

  /// 운동 ID → 비디오 경로 매핑
  static const Map<String, String> _exerciseVideos = {
    // 초보자 운동
    'squat_basic': '${_videoBasePath}squat.mp4',
    'squat': '${_videoBasePath}squat.mp4',
    'marching': '${_videoBasePath}walk.mp4',
    'high_knees': '${_videoBasePath}high_knees.mp4',
    'wall_pushup': '${_videoBasePath}wall_pushup.mp4',
    'plank_basic': '${_videoBasePath}flank.mp4',
    'lunge_basic': '${_videoBasePath}lunge.mp4',
    'calf_raise': '${_videoBasePath}caff_raise.mp4',
    'glute_bridge': '${_videoBasePath}glute_bridge.mp4',
    // 중급자 운동
    'jump_squat': '${_videoBasePath}jump_squat.mp4',
    'pushup': '${_videoBasePath}pushup.mp4',
    'plank_jack': '${_videoBasePath}plank_jack.mp4',
    'jumping_jack': '${_videoBasePath}jumping_jack.mp4',
    'mountain_climber': '${_videoBasePath}mountain_climber.mp4',
    'crunch': '${_videoBasePath}crunch.mp4',
    'leg_raise': '${_videoBasePath}leg_raise.mp4',
    'russian_twist': '${_videoBasePath}russian_twist.mp4',
  };

  /// 운동 이름(한글) → 비디오 경로 매핑
  static const Map<String, String> _exerciseNameToVideo = {
    // 초보자 운동
    '스쿼트': '${_videoBasePath}squat.mp4',
    '스쿼트 (기본)': '${_videoBasePath}squat.mp4',
    '제자리 걷기': '${_videoBasePath}walk.mp4',
    '무릎 올리기': '${_videoBasePath}high_knees.mp4',
    '벽 푸시업': '${_videoBasePath}wall_pushup.mp4',
    '플랭크': '${_videoBasePath}flank.mp4',
    '플랭크 (기본)': '${_videoBasePath}flank.mp4',
    '런지': '${_videoBasePath}lunge.mp4',
    '런지 (기본)': '${_videoBasePath}lunge.mp4',
    '카프레이즈': '${_videoBasePath}caff_raise.mp4',
    '글루트 브릿지': '${_videoBasePath}glute_bridge.mp4',
    // 중급자 운동
    '점프 스쿼트': '${_videoBasePath}jump_squat.mp4',
    '푸시업': '${_videoBasePath}pushup.mp4',
    '플랭크 잭': '${_videoBasePath}plank_jack.mp4',
    '점핑잭': '${_videoBasePath}jumping_jack.mp4',
    '마운틴 클라이머': '${_videoBasePath}mountain_climber.mp4',
    '크런치': '${_videoBasePath}crunch.mp4',
    '레그레이즈': '${_videoBasePath}leg_raise.mp4',
    '러시안 트위스트': '${_videoBasePath}russian_twist.mp4',
  };

  /// 운동 ID를 비디오 경로로 변환
  static String getVideoPath(String exerciseId) {
    return _exerciseVideos[exerciseId] ?? '';
  }

  /// 운동 이름(한글)을 비디오 경로로 변환
  static String getVideoPathByName(String exerciseName) {
    return _exerciseNameToVideo[exerciseName] ?? '';
  }

  /// 난이도 배지 이미지 경로 (GIF 애니메이션)
  static const String _badgeBasePath = 'assets/images/badge/';
  static const Map<String, String> _difficultyBadges = {
    'BEGINNER': '${_badgeBasePath}badge_beginner.gif',
    'INTERMEDIATE': '${_badgeBasePath}badge_intermediate.gif',
    'ADVANCED': '${_badgeBasePath}badge_advanced.gif',
  };

  /// 난이도에 해당하는 배지 이미지 경로 가져오기
  static String getDifficultyBadgePath(String difficulty) {
    return _difficultyBadges[difficulty] ?? '';
  }
}
