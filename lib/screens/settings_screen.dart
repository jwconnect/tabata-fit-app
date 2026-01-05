import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            children: [
              const _SectionHeader(title: '알림'),
              SwitchListTile(
                title: const Text('소리'),
                subtitle: const Text('운동 시작/종료 알림음'),
                value: settingsProvider.soundEnabled,
                onChanged: (value) => settingsProvider.setSoundEnabled(value),
                secondary: const Icon(Icons.volume_up),
              ),
              SwitchListTile(
                title: const Text('진동'),
                subtitle: const Text('운동 시작/종료 진동'),
                value: settingsProvider.vibrationEnabled,
                onChanged: (value) =>
                    settingsProvider.setVibrationEnabled(value),
                secondary: const Icon(Icons.vibration),
              ),
              const Divider(),

              const _SectionHeader(title: '화면'),
              SwitchListTile(
                title: const Text('다크 모드'),
                subtitle: const Text('어두운 테마 사용'),
                value: settingsProvider.darkMode,
                onChanged: (value) => settingsProvider.setDarkMode(value),
                secondary: const Icon(Icons.dark_mode),
              ),
              const Divider(),

              const _SectionHeader(title: '앱 정보'),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('버전'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('오픈소스 라이선스'),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'TabataFit',
                    applicationVersion: '1.0.0',
                  );
                },
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('도움말'),
                onTap: () {
                  _showHelpDialog(context);
                },
                trailing: const Icon(Icons.chevron_right),
              ),
              const Divider(),

              const _SectionHeader(title: '타바타 운동이란?'),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '타바타 운동은 일본의 운동생리학자 타바타 이즈미 박사가 개발한 '
                  '고강도 인터벌 트레이닝(HIIT)입니다.\n\n'
                  '기본 프로토콜:\n'
                  '• 20초 운동 (최대 강도)\n'
                  '• 10초 휴식\n'
                  '• 8세트 반복\n'
                  '• 총 4분\n\n'
                  '짧은 시간에 높은 효과를 얻을 수 있어 바쁜 현대인에게 적합합니다.',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('도움말'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('빠른 시작', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('홈 화면에서 "빠른 시작" 버튼을 눌러 기본 타바타 운동을 시작할 수 있습니다.'),
              SizedBox(height: 16),
              Text('운동 선택', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('운동 탭에서 난이도별로 다양한 운동 프로그램을 선택할 수 있습니다.'),
              SizedBox(height: 16),
              Text('통계', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('통계 탭에서 운동 기록과 진행 상황을 확인할 수 있습니다.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
