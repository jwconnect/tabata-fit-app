import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 프리미엄 다크 테마 색상 시스템
/// 세련된 스포츠 앱을 위한 현대적인 색상 팔레트
class AppColors {
  // Primary Brand Colors - 네온 레드/코럴 계열
  static const Color primaryRed = Color(0xFFFF4757);
  static const Color primaryRedDark = Color(0xFFE84350);
  static const Color primaryRedLight = Color(0xFFFF6B7A);

  // Premium Dark Backgrounds - 깊이감 있는 다크 계열
  static const Color deepBlack = Color(0xFF0A0A0F);
  static const Color darkGray = Color(0xFF12121A);
  static const Color mediumGray = Color(0xFF1A1A25);
  static const Color cardDark = Color(0xFF1E1E2A);
  static const Color surfaceDark = Color(0xFF252535);

  // Light Theme Colors (유지용)
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Accent Colors - 네온 감성
  static const Color accentCyan = Color(0xFF00D4FF);
  static const Color accentBlue = Color(0xFF5B8DEF);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentOrange = Color(0xFFFF9F43);
  static const Color accentYellow = Color(0xFFFFD93D);
  static const Color accentPurple = Color(0xFFB388FF);

  // Difficulty Colors - 그라데이션 친화적
  static const Color beginnerGreen = Color(0xFF00E676);
  static const Color intermediateOrange = Color(0xFFFF9F43);
  static const Color advancedRed = Color(0xFFFF4757);

  // Timer State Colors - 선명한 상태 색상
  static const Color prepareYellow = Color(0xFFFFD93D);
  static const Color workRed = Color(0xFFFF4757);
  static const Color restBlue = Color(0xFF00D4FF);
  static const Color cooldownGreen = Color(0xFF00E676);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color textMuted = Color(0xFF6B6B80);

  // Glass Effect Colors
  static const Color glassDark = Color(0x40000000);
  static const Color glassLight = Color(0x15FFFFFF);
  static const Color glassBorder = Color(0x20FFFFFF);
}

/// 프리미엄 그라데이션 컬렉션
class AppGradients {
  // Primary Brand Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF4757), Color(0xFFFF6B81)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Premium Red Gradient
  static const LinearGradient premiumRed = LinearGradient(
    colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark Background Gradient
  static const LinearGradient darkBackground = LinearGradient(
    colors: [Color(0xFF0A0A0F), Color(0xFF12121A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Card Gradient
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1E2A), Color(0xFF151520)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glow Gradient for highlights
  static const LinearGradient glowGradient = LinearGradient(
    colors: [Color(0x40FF4757), Color(0x00FF4757)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Cyan Accent Gradient
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF5B8DEF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Green Success Gradient
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00C853)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass Card Gradient
  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x15FFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shimmer Gradient for loading
  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [Color(0xFF1E1E2A), Color(0xFF2A2A3A), Color(0xFF1E1E2A)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );
}

/// 프리미엄 텍스트 스타일
class AppTextStyles {
  // Display - Hero Text
  static const TextStyle display = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    height: 1.1,
    color: AppColors.textPrimary,
  );

  // Headlines
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // Body Text
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textSecondary,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // Labels & Captions
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: AppColors.textMuted,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: AppColors.textMuted,
  );

  // Buttons
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppColors.textPrimary,
  );

  // Timer Display
  static const TextStyle timerLarge = TextStyle(
    fontSize: 80,
    fontWeight: FontWeight.w700,
    letterSpacing: -3,
    height: 1.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle timerMedium = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w600,
    letterSpacing: -2,
    color: AppColors.textPrimary,
  );

  // Stats Numbers
  static const TextStyle statNumber = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: AppColors.textPrimary,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textMuted,
  );
}

/// 앱 그림자 스타일
class AppShadows {
  static List<BoxShadow> get small => [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get large => [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get glow => [
    BoxShadow(
      color: AppColors.primaryRed.withOpacity(0.4),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> glowColor(Color color) => [
    BoxShadow(color: color.withOpacity(0.4), blurRadius: 20, spreadRadius: 0),
  ];
}

/// 앱 테마
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryRed,
      scaffoldBackgroundColor: AppColors.lightGray,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryRed,
        secondary: AppColors.accentBlue,
        surface: AppColors.pureWhite,
        error: AppColors.advancedRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.pureWhite,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.pureWhite,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: AppColors.pureWhite,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.pureWhite,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryRed,
      scaffoldBackgroundColor: AppColors.deepBlack,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryRed,
        secondary: AppColors.accentCyan,
        surface: AppColors.cardDark,
        error: AppColors.advancedRed,
        onPrimary: AppColors.pureWhite,
        onSecondary: AppColors.pureWhite,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: AppColors.pureWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryRed,
          textStyle: AppTextStyles.button,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 24),
      dividerTheme: const DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// 반복적으로 사용되는 데코레이션
class AppDecorations {
  /// 글래스모피즘 카드 데코레이션
  static BoxDecoration get glassCard => BoxDecoration(
    gradient: AppGradients.glassGradient,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.glassBorder, width: 1),
  );

  /// 프리미엄 카드 데코레이션
  static BoxDecoration get premiumCard => BoxDecoration(
    gradient: AppGradients.cardGradient,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.glassBorder, width: 1),
    boxShadow: AppShadows.medium,
  );

  /// 그라데이션 버튼 데코레이션
  static BoxDecoration get gradientButton => BoxDecoration(
    gradient: AppGradients.primaryGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: AppShadows.glow,
  );

  /// 서브틀 카드 (테두리만)
  static BoxDecoration get subtleCard => BoxDecoration(
    color: AppColors.cardDark,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.glassBorder, width: 1),
  );
}

/// 애니메이션 설정
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;
}
