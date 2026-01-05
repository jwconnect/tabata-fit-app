# Flutter 타바타 운동 앱 설계 및 기능 정의

## 1. 프로젝트 개요

### 앱 이름
**TabataFit** - 타바타 운동 트레이닝 앱

### 목표
- 사용자가 효율적으로 타바타 운동을 수행할 수 있도록 지원
- 직관적인 UI와 강력한 기능을 결합
- 운동 진행 상황을 추적하고 동기부여 제공

### 타겟 사용자
- 시간이 없는 바쁜 직장인
- 집에서 운동하고 싶은 초보자
- 체지방 감소를 원하는 피트니스 애호가
- 고강도 운동을 선호하는 사람

## 2. 핵심 기능

### 2.1 타이머 (Timer)
**설명**: 타바타 운동의 핵심 기능

**기능 상세**:
- 20초 운동 / 10초 휴식 자동 계산
- 8세트 자동 진행
- 세트 간 30초 휴식 옵션
- 음성 알림 (준비, 운동 시작, 휴식, 세트 완료)
- 음향 효과 (다양한 비프음, 벨 소리)
- 백그라운드 작동 (화면 꺼짐 상태에서도 작동)
- 일시 정지 / 재개 기능
- 운동 중 화면 밝기 자동 유지

**UI 요소**:
- 큼직한 시간 표시 (가독성 우선)
- 현재 세트 표시 (1/8)
- 운동/휴식 상태 색상 구분 (빨강/파랑)
- 진행 상황 원형 프로그레스 바
- 시작/일시정지/재개 버튼

### 2.2 운동 선택 (Workout Selection)
**설명**: 다양한 타바타 운동 프로그램 제공

**기능 상세**:
- 기본 운동 세트 (스쿼트, 버피, 점프 잭 등)
- 운동 난이도별 분류 (초보자, 중급자, 고급자)
- 운동별 설명 및 이미지/영상 가이드
- 운동 조합 커스터마이징
- 즐겨찾기 기능
- 운동 검색 기능

**운동 데이터 구조**:
```
운동 {
  id: String,
  name: String,
  description: String,
  imageUrl: String,
  videoUrl: String,
  difficulty: Enum(BEGINNER, INTERMEDIATE, ADVANCED),
  muscleGroups: List<String>,
  instructions: List<String>,
  tips: List<String>
}
```

### 2.3 운동 기록 (Workout History)
**설명**: 사용자의 운동 이력 저장 및 관리

**기능 상세**:
- 운동 완료 기록 자동 저장
- 날짜별 운동 이력 조회
- 운동 시간, 세트 수, 소모 칼로리 기록
- 주간/월간 통계
- 운동 기록 삭제 기능

**기록 데이터 구조**:
```
운동기록 {
  id: String,
  date: DateTime,
  workoutName: String,
  exercises: List<String>,
  duration: Duration,
  sets: Int,
  calories: Double,
  notes: String
}
```

### 2.4 통계 및 분석 (Statistics)
**설명**: 운동 진행도 및 성과 분석

**기능 상세**:
- 총 운동 시간
- 총 운동 횟수
- 평균 칼로리 소모량
- 주간 운동 차트
- 월간 운동 차트
- 가장 자주 하는 운동
- 운동 스트릭 (연속 운동 일수)

**차트 유형**:
- 막대 차트: 주간/월간 운동 시간
- 원형 차트: 운동 유형별 비율
- 라인 차트: 시간대별 칼로리 소모 추이

### 2.5 맞춤 프로그램 (Custom Programs)
**설명**: 사용자 수준별 맞춤형 운동 프로그램

**기능 상세**:
- 초보자 프로그램 (주 3회, 낮은 강도)
- 중급자 프로그램 (주 4회, 중간 강도)
- 고급자 프로그램 (주 5회, 높은 강도)
- 체지방 감소 프로그램 (고강도, 짧은 휴식)
- 근력 증진 프로그램 (무거운 운동, 긴 휴식)
- 커스텀 프로그램 생성

### 2.6 알림 및 리마인더 (Notifications)
**설명**: 사용자 운동 동기부여

**기능 상세**:
- 일일 운동 알림
- 운동 시간 설정 가능
- 주간 목표 달성 알림
- 운동 스트릭 유지 알림
- 푸시 알림 활성화/비활성화

### 2.7 설정 (Settings)
**설명**: 앱 개인화 설정

**기능 상세**:
- 음성 알림 음량 조절
- 음향 효과 선택
- 화면 밝기 설정
- 언어 선택 (한국어, 영어 등)
- 테마 선택 (라이트/다크 모드)
- 단위 설정 (kg/lb, cm/inch)
- 개인 정보 (이름, 나이, 성별, 체중)

### 2.8 커뮤니티 (Community)
**설명**: 사용자 간 상호작용 및 동기부여

**기능 상세**:
- 운동 완료 공유
- 친구 추가 및 팔로우
- 친구 운동 기록 조회
- 주간 챌린지
- 리더보드 (전체 사용자 순위)
- 댓글 및 응원 메시지

## 3. 기술 스택

### 프론트엔드
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider / Riverpod
- **Database**: SQLite (로컬), Firebase (클라우드)
- **UI Components**: Material Design 3
- **Charts**: fl_chart
- **Video Player**: video_player

### 백엔드 (선택사항)
- **Framework**: Firebase
- **Authentication**: Firebase Auth
- **Database**: Firestore
- **Storage**: Firebase Storage
- **Functions**: Cloud Functions

### 개발 도구
- **IDE**: Android Studio / VS Code
- **Version Control**: Git
- **Testing**: Flutter test, integration_test

## 4. 앱 구조 (Navigation)

### 화면 구성

```
TabBar Navigation (하단 탭)
├── 홈 (Home)
│   ├── 오늘의 운동 요약
│   ├── 빠른 시작 버튼
│   └── 최근 운동 기록
├── 운동 (Workout)
│   ├── 운동 선택
│   ├── 타이머 화면
│   └── 운동 완료 화면
├── 통계 (Statistics)
│   ├── 주간 통계
│   ├── 월간 통계
│   └── 상세 분석
├── 커뮤니티 (Community)
│   ├── 친구 목록
│   ├── 챌린지
│   └── 리더보드
└── 설정 (Settings)
    ├── 개인 정보
    ├── 알림 설정
    ├── 앱 설정
    └── 정보
```

## 5. 데이터 모델

### User 모델
```dart
class User {
  String id;
  String name;
  int age;
  String gender;
  double weight;
  double height;
  String level; // BEGINNER, INTERMEDIATE, ADVANCED
  DateTime createdAt;
  DateTime updatedAt;
}
```

### Workout 모델
```dart
class Workout {
  String id;
  String name;
  String description;
  String imageUrl;
  String videoUrl;
  String difficulty;
  List<String> muscleGroups;
  List<String> instructions;
  List<String> tips;
}
```

### WorkoutSession 모델
```dart
class WorkoutSession {
  String id;
  String userId;
  List<String> exercises;
  DateTime startTime;
  DateTime endTime;
  int sets;
  double caloriesBurned;
  String notes;
}
```

## 6. 디자인 시스템

### 색상 팔레트
- **Primary**: #FF5722 (Deep Orange) - 에너지, 활동성
- **Secondary**: #2196F3 (Blue) - 신뢰, 안정성
- **Accent**: #4CAF50 (Green) - 성공, 완료
- **Background**: #FFFFFF (White) / #121212 (Dark)
- **Surface**: #F5F5F5 (Light Gray) / #1E1E1E (Dark Gray)
- **Error**: #F44336 (Red) - 경고, 오류

### 타이포그래피
- **Headline**: Roboto Bold, 28sp
- **Title**: Roboto Medium, 20sp
- **Body**: Roboto Regular, 16sp
- **Caption**: Roboto Regular, 12sp

### 간격 (Spacing)
- **xs**: 4dp
- **sm**: 8dp
- **md**: 16dp
- **lg**: 24dp
- **xl**: 32dp

## 7. 개발 일정

### Phase 1: 기본 기능 (1-2주)
- 프로젝트 설정
- 기본 UI 구현
- 타이머 기능 구현
- 로컬 데이터베이스 설정

### Phase 2: 운동 기능 (1주)
- 운동 선택 화면
- 운동 가이드 (이미지/영상)
- 운동 기록 저장

### Phase 3: 통계 및 분석 (1주)
- 통계 화면 구현
- 차트 표시
- 데이터 분석

### Phase 4: 고급 기능 (1-2주)
- 커뮤니티 기능
- 알림 시스템
- 설정 화면

### Phase 5: 테스트 및 최적화 (1주)
- 버그 수정
- 성능 최적화
- 사용자 테스트

## 8. 예상 파일 구조

```
lib/
├── main.dart
├── models/
│   ├── user.dart
│   ├── workout.dart
│   ├── workout_session.dart
│   └── statistics.dart
├── screens/
│   ├── home_screen.dart
│   ├── workout_screen.dart
│   ├── timer_screen.dart
│   ├── statistics_screen.dart
│   ├── community_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── timer_widget.dart
│   ├── workout_card.dart
│   ├── statistics_chart.dart
│   └── custom_widgets.dart
├── services/
│   ├── database_service.dart
│   ├── notification_service.dart
│   ├── analytics_service.dart
│   └── auth_service.dart
├── providers/
│   ├── user_provider.dart
│   ├── workout_provider.dart
│   ├── statistics_provider.dart
│   └── timer_provider.dart
├── utils/
│   ├── constants.dart
│   ├── theme.dart
│   └── helpers.dart
└── assets/
    ├── images/
    ├── videos/
    ├── sounds/
    └── fonts/
```

## 9. 주요 기술 고려사항

### 성능
- 타이머 정확도 (±100ms 이내)
- 백그라운드 작동 최적화
- 메모리 사용 최소화

### 사용성
- 터치 타겟 최소 48x48dp
- 명확한 시각적 피드백
- 직관적인 네비게이션

### 접근성
- 음성 알림 (시각 장애인)
- 높은 명도 대비 (색맹)
- 텍스트 크기 조절

### 보안
- 사용자 데이터 암호화
- 로컬 데이터베이스 보안
- 인증 토큰 관리

