# TabataFit 디자인 프롬프트 종합 가이드

> **디자인 컨셉**: Swiss Sport Tech
> **핵심 컬러**: `#FF3B30` (Vibrant Red) / `#121212` (Deep Black) / `#FFFFFF` (Pure White)
> **폰트**: Montserrat (Bold/Black), Noto Sans KR

---

## 📌 목차

1. [Midjourney 이미지 프롬프트](#1-midjourney-이미지-프롬프트)
2. [AI 비디오 생성 프롬프트](#2-ai-비디오-생성-프롬프트)
3. [운동별 동작 가이드 프롬프트](#3-운동별-동작-가이드-프롬프트)
4. [UI 컴포넌트 디자인 가이드](#4-ui-컴포넌트-디자인-가이드)
5. [아이콘 및 에셋 프롬프트](#5-아이콘-및-에셋-프롬프트)

---

## 1. Midjourney 이미지 프롬프트

### 🎨 공통 스타일 키워드
```
Swiss Sport Tech style, high contrast, minimalist, geometric shapes,
vibrant red (#FF3B30) and deep black (#121212), clean lines,
sharp focus, professional photography
```

### 1.1 앱 화면별 배경 이미지

| 화면 | 프롬프트 | 비고 |
|:-----|:---------|:-----|
| **온보딩 1** | `A dynamic, high-contrast photograph of a female athlete mid-sprint, silhouetted against a deep black background. Vibrant red accent lighting highlights the muscle definition. Minimalist composition, Swiss Sport Tech style, sharp focus, cinematic lighting --ar 9:16 --v 6` | 앱 첫 실행 화면 |
| **온보딩 2** | `Abstract motion blur of a runner's legs in movement, deep black background with vibrant red light trails. Swiss Sport Tech aesthetic, high contrast, minimalist, energy and speed concept --ar 9:16 --v 6` | 기능 소개 화면 |
| **온보딩 3** | `Close-up of a clenched fist with defined muscles, dramatic side lighting in vibrant red, deep black background. Power and determination concept, Swiss Sport Tech style --ar 9:16 --v 6` | 시작하기 화면 |
| **로그인/회원가입** | `Abstract geometric pattern of intersecting lines forming a dynamic upward movement, vibrant red on deep black. Swiss graphic design, minimalist, no text --ar 9:16 --v 6` | 인증 화면 배경 |
| **홈 화면** | `Bird's eye view of a minimalist black gym floor with a single red yoga mat, dramatic shadows. Swiss Sport Tech style, high contrast, clean composition --ar 16:9 --v 6` | 메인 화면 상단 |
| **타이머 화면** | `Abstract circular gradient from vibrant red to deep black, concentric rings suggesting a countdown timer. Minimalist, Swiss design, glowing effect --ar 1:1 --v 6` | 타이머 배경 |
| **완료/축하 화면** | `Explosive red particles bursting outward on a deep black background, celebrating victory. Abstract, dynamic, Swiss Sport Tech style, high energy --ar 9:16 --v 6` | 운동 완료 시 |
| **통계 화면** | `Abstract 3D visualization of data bars rising upward, vibrant red glow on deep black. Modern dashboard aesthetic, Swiss Sport Tech style --ar 16:9 --v 6` | 통계 대시보드 |

### 1.2 운동 카테고리 썸네일

| 카테고리 | 프롬프트 |
|:---------|:---------|
| **전신 운동** | `Minimalist geometric icon of a human figure in dynamic full-body exercise pose, vibrant red silhouette on deep black circle. Swiss Sport Tech poster design, vector art style --ar 1:1 --v 6` |
| **상체 운동** | `Stylized geometric illustration of muscular arms and chest, vibrant red on deep black. Minimalist icon design, Swiss Sport Tech style, clean lines --ar 1:1 --v 6` |
| **하체 운동** | `Abstract geometric representation of powerful legs in squat position, vibrant red silhouette on deep black. Swiss Sport Tech icon design --ar 1:1 --v 6` |
| **코어 운동** | `Minimalist icon of torso core muscles, geometric shapes in vibrant red on deep black background. Swiss Sport Tech style, vector illustration --ar 1:1 --v 6` |
| **유산소** | `Dynamic running figure made of geometric shapes, motion lines in vibrant red on deep black. Swiss Sport Tech poster design, minimalist --ar 1:1 --v 6` |
| **스트레칭** | `Graceful stretching figure in geometric minimalist style, vibrant red on deep black. Calm energy, Swiss Sport Tech design --ar 1:1 --v 6` |

---

## 2. AI 비디오 생성 프롬프트

### 🎬 추천 AI 비디오 도구

| 도구 | 특징 | 추천 용도 | 가격 |
|:-----|:-----|:---------|:-----|
| **Runway Gen-3 Alpha** | 고품질 모션, 일관된 캐릭터 | 운동 동작 시연 | 유료 ($15/월~) |
| **Pika Labs** | 빠른 생성, 자연스러운 움직임 | 짧은 루프 영상 | 무료/유료 |
| **Kling AI** | 사실적인 인체 움직임 | 운동 가이드 | 유료 |
| **Luma Dream Machine** | 부드러운 전환 효과 | 배경 애니메이션 | 무료/유료 |
| **Hyperhuman** | 피트니스 전용 플랫폼 | 전문 운동 영상 | 유료 |
| **HeyGen** | AI 아바타 코칭 | 설명 영상 | 유료 ($24/월~) |

### 2.1 앱 배경 루프 영상

```
[Runway Gen-3 / Pika Labs]

프롬프트: A seamless 5-second loop of abstract geometric shapes
slowly morphing and flowing across the screen. Deep black background
with subtle vibrant red accents. Minimalist, Swiss Sport Tech aesthetic,
no human figures, smooth motion, ambient atmosphere.

설정:
- 해상도: 1080x1920 (9:16)
- 길이: 5초
- 루프: Yes
```

### 2.2 휴식 시간 영상

```
[Luma Dream Machine / Pika Labs]

프롬프트: A calming animation of a white glowing circle slowly
pulsing like breathing rhythm (4 seconds inhale, 4 seconds exhale)
on a deep blue (#1a237e) gradient background. Soft, peaceful,
meditation-like atmosphere, minimalist design.

설정:
- 해상도: 1080x1920 (9:16)
- 길이: 10초
- 루프: Yes
```

---

## 3. 운동별 동작 가이드 프롬프트

### 📹 공통 촬영 스타일 설정

```
배경: 미니멀리스트 검정 스튜디오
조명: 측면에서 강한 빨간색 악센트 조명
카메라 앵글: 측면 45도 또는 정면
의상: 검정 피트니스 의류
길이: 5-10초 루프
```

### 3.1 전신 운동 (Full Body)

| 운동 | Runway/Kling 프롬프트 |
|:-----|:----------------------|
| **버피 (Burpee)** | `A professional male athlete performing a perfect burpee in a minimalist black studio. Side angle view, red accent lighting from the left. Full motion from standing to push-up to jump. High contrast, Swiss Sport Tech style, 5 second loop --ar 9:16` |
| **점핑잭 (Jumping Jack)** | `Athletic female performing jumping jacks with perfect form in a dark minimalist studio. Front view, dramatic red side lighting. Energetic, rhythmic movement, 5 second seamless loop --ar 9:16` |
| **마운틴 클라이머** | `Side view of an athlete performing mountain climbers on black floor. Red accent lighting highlights the dynamic leg movement. Fast-paced, high energy, minimalist black background, 5 second loop --ar 9:16` |
| **스케이터 점프** | `Lateral skater jumps performed by a fit athlete, black studio with red rim lighting. Dynamic side-to-side movement, powerful legs, 5 second loop --ar 9:16` |

### 3.2 하체 운동 (Lower Body)

| 운동 | Runway/Kling 프롬프트 |
|:-----|:----------------------|
| **스쿼트 (Squat)** | `A fit athlete performing a perfect bodyweight squat. Side profile view in minimalist black studio, vibrant red accent lighting. Controlled descent and powerful ascent, 5 second loop --ar 9:16` |
| **런지 (Lunge)** | `Professional trainer demonstrating alternating forward lunges. Black studio background, dramatic red side lighting. Perfect form emphasis, 5 second loop --ar 9:16` |
| **점프 스쿼트** | `Explosive jump squat performed by muscular athlete. Black background with red accent lighting from below. Power and height emphasis, slow motion effect, 5 second loop --ar 9:16` |
| **글루트 브릿지** | `Side view of glute bridge exercise on a black yoga mat. Red accent lighting highlighting hip thrust movement. Controlled motion, 5 second loop --ar 9:16` |

### 3.3 상체 운동 (Upper Body)

| 운동 | Runway/Kling 프롬프트 |
|:-----|:----------------------|
| **푸시업 (Push-up)** | `Side view of perfect push-up form in minimalist black studio. Red accent lighting on arm muscles. Controlled down and explosive up motion, 5 second loop --ar 9:16` |
| **플랭크** | `Static plank hold from side angle. Athletic body in perfect straight line, black studio, red glow highlighting core engagement. Slight breathing motion, 5 second --ar 9:16` |
| **숄더 탭** | `Plank position with alternating shoulder taps. Top-down view, black floor with red mat edges. Rhythmic movement, core stability focus, 5 second loop --ar 9:16` |
| **다이아몬드 푸시업** | `Close-grip diamond push-up showing tricep engagement. Side view, minimalist black studio, red accent on arms, 5 second loop --ar 9:16` |

### 3.4 코어 운동 (Core)

| 운동 | Runway/Kling 프롬프트 |
|:-----|:----------------------|
| **크런치 (Crunch)** | `Perfect crunch form from side angle. Athlete on black mat, red accent lighting on abs. Controlled upward motion, 5 second loop --ar 9:16` |
| **레그 레이즈** | `Lying leg raise exercise, side view. Legs moving from floor to vertical, controlled motion. Black studio, red accent lighting, 5 second loop --ar 9:16` |
| **바이시클 크런치** | `Bicycle crunch exercise from above angle. Alternating elbow to knee motion, dynamic core rotation. Black background, red glow, 5 second loop --ar 9:16` |
| **데드버그** | `Dead bug exercise from above. Opposite arm and leg extending while maintaining flat back. Black mat, red accent lighting, 5 second loop --ar 9:16` |

### 3.5 유산소 (Cardio)

| 운동 | Runway/Kling 프롬프트 |
|:-----|:----------------------|
| **하이니즈 (High Knees)** | `High knees running in place, front view. Knees driving up to hip height, arms pumping. Black studio, red side lighting, high energy, 5 second loop --ar 9:16` |
| **버트킥 (Butt Kicks)** | `Butt kicks exercise from side view. Heels kicking up to glutes while jogging. Black background, red accent lighting, 5 second loop --ar 9:16` |
| **박스 점프** | `Box jump onto black plyo box. Explosive takeoff and soft landing. Red accent lighting, powerful movement, slow motion capture, 5 second --ar 9:16` |
| **터크 점프** | `Tuck jump with knees driving to chest mid-air. Black studio, red lighting capturing peak moment. Explosive power, 5 second loop --ar 9:16` |

---

## 4. UI 컴포넌트 디자인 가이드

### 4.1 색상 시스템

```dart
// Primary Colors
static const Color primaryRed = Color(0xFFFF3B30);      // 메인 액션, 강조
static const Color deepBlack = Color(0xFF121212);       // 배경, 텍스트
static const Color pureWhite = Color(0xFFFFFFFF);       // 텍스트, 아이콘

// Secondary Colors
static const Color restBlue = Color(0xFF007AFF);        // 휴식 시간 표시
static const Color successGreen = Color(0xFF34C759);    // 완료, 성공
static const Color warningOrange = Color(0xFFFF9500);   // 경고, 주의

// Surface Colors
static const Color surfaceDark = Color(0xFF1C1C1E);     // 카드 배경
static const Color surfaceLight = Color(0xFF2C2C2E);    // 입력 필드 배경
static const Color divider = Color(0xFF3A3A3C);         // 구분선
```

### 4.2 타이포그래피

```dart
// Montserrat (영문, 숫자 - 타이머용)
Timer Display: Montserrat Black, 96px
Timer Subtitle: Montserrat Bold, 24px

// Noto Sans KR (한글)
Headline: Noto Sans KR Bold, 28px
Title: Noto Sans KR Medium, 20px
Body: Noto Sans KR Regular, 16px
Caption: Noto Sans KR Regular, 12px
```

### 4.3 버튼 스타일

| 버튼 타입 | 스타일 |
|:----------|:-------|
| **Primary (시작)** | 배경: `#FF3B30`, 텍스트: 흰색, 라운드: 12px, 높이: 56px |
| **Secondary (일시정지)** | 배경: 투명, 테두리: 흰색 2px, 텍스트: 흰색 |
| **Destructive (취소)** | 배경: 투명, 텍스트: `#FF3B30` |
| **Ghost (보조)** | 배경: `#2C2C2E`, 텍스트: 흰색, 라운드: 8px |

### 4.4 카드 컴포넌트

```
배경: #1C1C1E
라운드 코너: 16px
패딩: 16px
그림자: 0px 4px 12px rgba(0,0,0,0.3)
테두리: 없음 (호버 시 #FF3B30 1px)
```

### 4.5 타이머 UI 규격

```
원형 프로그레스:
- 크기: 280x280px
- 선 두께: 12px
- 운동 중: #FF3B30 (빨강)
- 휴식 중: #007AFF (파랑)
- 배경 트랙: #3A3A3C

중앙 시간 표시:
- 폰트: Montserrat Black
- 크기: 72-96px
- 색상: #FFFFFF
```

---

## 5. 아이콘 및 에셋 프롬프트

### 5.1 앱 아이콘

```
[Midjourney]

프롬프트: A minimalist app icon design combining a stopwatch and
upward-pointing arrow in a single geometric symbol. Vibrant red (#FF3B30)
on deep black background. Clean lines, Swiss Sport Tech style,
no text, suitable for iOS and Android app icon --ar 1:1 --v 6

변형 옵션:
1. 원형 배경 버전
2. 사각 라운드 배경 버전
3. 그라데이션 버전 (빨강 → 주황)
```

### 5.2 기능 아이콘 세트

| 아이콘 | 프롬프트 |
|:-------|:---------|
| **타이머** | `Minimalist stopwatch icon, geometric design, white on transparent. Thin lines, Swiss design style, 24x24px vector --ar 1:1` |
| **통계** | `Line graph icon trending upward, geometric minimalist style, white on transparent. Clean lines --ar 1:1` |
| **설정** | `Gear/cogwheel icon, precise geometric design, white on transparent. Swiss Sport Tech style --ar 1:1` |
| **프로필** | `Abstract human silhouette icon, geometric circles and lines, white on transparent --ar 1:1` |
| **운동 목록** | `Stacked horizontal lines with play button, list icon style, white on transparent --ar 1:1` |
| **캘린더** | `Minimalist calendar grid icon, geometric design, white on transparent --ar 1:1` |

### 5.3 운동 부위 아이콘

```
[Midjourney]

전신: `Human body silhouette icon, all muscle groups highlighted
in red, geometric minimalist style, front view --ar 1:1`

상체: `Upper body silhouette icon, chest/arms/shoulders highlighted
in red, geometric minimalist style --ar 1:1`

하체: `Lower body silhouette icon, legs/glutes highlighted in red,
geometric minimalist style --ar 1:1`

코어: `Torso silhouette icon, abdominal area highlighted in red,
geometric minimalist style --ar 1:1`
```

---

## 📎 부록: 프롬프트 작성 팁

### Midjourney 파라미터 가이드

| 파라미터 | 설명 | 예시 |
|:---------|:-----|:-----|
| `--ar` | 종횡비 | `--ar 9:16` (세로), `--ar 16:9` (가로), `--ar 1:1` (정사각) |
| `--v 6` | 버전 | 최신 버전 사용 권장 |
| `--style raw` | 스타일 | AI 개입 최소화, 원본 느낌 유지 |
| `--q 2` | 품질 | 높은 디테일 (기본값 1) |
| `--s 250` | 스타일화 | 낮을수록 프롬프트 충실 (기본값 100) |
| `--no` | 제외 요소 | `--no text, watermark, people` |

### 일관된 스타일 유지를 위한 필수 키워드

```
Swiss Sport Tech, high contrast, minimalist, geometric,
vibrant red (#FF3B30), deep black (#121212), clean lines,
professional, modern, sleek, premium quality
```

### 비디오 생성 시 주의사항

1. **루프 영상**: 시작과 끝이 자연스럽게 이어지도록 프롬프트에 `seamless loop` 명시
2. **인체 동작**: 현재 AI는 복잡한 운동 동작에서 왜곡이 발생할 수 있음 → 단순한 동작 우선
3. **길이**: 5-10초 권장 (앱 용량 최적화)
4. **해상도**: 모바일 최적화를 위해 1080p 이하 권장

---

## 🔗 리소스 링크

| 도구 | URL | 용도 |
|:-----|:----|:-----|
| Midjourney | https://midjourney.com | 이미지 생성 |
| Runway | https://runwayml.com | 비디오 생성 |
| Pika Labs | https://pika.art | 비디오 생성 |
| Kling AI | https://klingai.com | 비디오 생성 |
| Luma AI | https://lumalabs.ai | 비디오 생성 |
| HeyGen | https://heygen.com | AI 아바타 |
| Hyperhuman | https://hyperhuman.com | 피트니스 전용 |
| LottieFiles | https://lottiefiles.com | 경량 애니메이션 |
| Mixamo | https://mixamo.com | 3D 운동 애니메이션 |

---

*마지막 업데이트: 2026-01-05*
