import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/timer_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/main_screen.dart';
import 'utils/app_theme.dart';
import 'services/ad_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const TabataFitApp(),
    ),
  );
}

class TabataFitApp extends StatefulWidget {
  const TabataFitApp({super.key});

  @override
  State<TabataFitApp> createState() => _TabataFitAppState();
}

class _TabataFitAppState extends State<TabataFitApp> {
  @override
  void initState() {
    super.initState();
    // 앱 시작 시 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 저장된 운동 기록 로드
      context.read<StatisticsProvider>().init();
      // 광고 서비스 초기화
      AdService().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'TabataFit',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          // 항상 다크 모드 사용 (프리미엄 디자인)
          themeMode: ThemeMode.dark,
          home: const MainScreen(),
        );
      },
    );
  }
}
