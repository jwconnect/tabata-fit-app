import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return CustomScrollView(
            slivers: [
              // 세련된 앱바
              SliverAppBar(
                expandedHeight: 140,
                floating: false,
                pinned: true,
                backgroundColor: isDark ? AppColors.darkGray : Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    '설정',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 20,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.darkGray, AppColors.deepBlack]
                            : [Colors.white, AppColors.lightGray],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 알림 섹션
                    _buildSectionHeader(
                      '알림',
                      Icons.notifications_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsCard(
                      isDark,
                      children: [
                        _buildSwitchTile(
                          icon: Icons.volume_up_rounded,
                          iconColor: AppColors.accentBlue,
                          title: '소리',
                          subtitle: '운동 시작/종료 알림음',
                          value: settingsProvider.soundEnabled,
                          onChanged: (value) =>
                              settingsProvider.setSoundEnabled(value),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildSwitchTile(
                          icon: Icons.vibration_rounded,
                          iconColor: AppColors.accentOrange,
                          title: '진동',
                          subtitle: '운동 시작/종료 진동',
                          value: settingsProvider.vibrationEnabled,
                          onChanged: (value) =>
                              settingsProvider.setVibrationEnabled(value),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildSwitchTile(
                          icon: Icons.alarm_rounded,
                          iconColor: AppColors.accentGreen,
                          title: '매일 알림',
                          subtitle: '운동 시간을 잊지 않도록 알려드려요',
                          value: settingsProvider.reminderEnabled,
                          onChanged: (value) =>
                              settingsProvider.setReminderEnabled(value),
                          isDark: isDark,
                        ),
                        if (settingsProvider.reminderEnabled) ...[
                          _buildDivider(isDark),
                          _buildTimeTile(
                            context: context,
                            icon: Icons.access_time_rounded,
                            iconColor: AppColors.accentGreen,
                            title: '알림 시간',
                            timeString: settingsProvider.reminderTimeString,
                            isDark: isDark,
                            onTap: () => _showTimePicker(context, settingsProvider, isDark),
                          ),
                          _buildDivider(isDark),
                          _buildActionTile(
                            icon: Icons.send_rounded,
                            iconColor: AppColors.accentBlue,
                            title: '테스트 알림 보내기',
                            isDark: isDark,
                            onTap: () async {
                              await settingsProvider.sendTestNotification();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('테스트 알림을 보냈습니다!'),
                                    backgroundColor: AppColors.accentGreen,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 화면 섹션
                    _buildSectionHeader('화면', Icons.palette_rounded, isDark),
                    const SizedBox(height: 12),
                    _buildSettingsCard(
                      isDark,
                      children: [
                        _buildSwitchTile(
                          icon: Icons.dark_mode_rounded,
                          iconColor: AppColors.primaryRed,
                          title: '다크 모드',
                          subtitle: '어두운 테마 사용',
                          value: settingsProvider.darkMode,
                          onChanged: (value) =>
                              settingsProvider.setDarkMode(value),
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 앱 정보 섹션
                    _buildSectionHeader('앱 정보', Icons.info_rounded, isDark),
                    const SizedBox(height: 12),
                    _buildSettingsCard(
                      isDark,
                      children: [
                        _buildInfoTile(
                          icon: Icons.verified_rounded,
                          iconColor: AppColors.accentGreen,
                          title: '버전',
                          trailing: Text(
                            '1.0.0',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontSize: 15,
                            ),
                          ),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildNavigationTile(
                          icon: Icons.description_rounded,
                          iconColor: AppColors.accentBlue,
                          title: '오픈소스 라이선스',
                          isDark: isDark,
                          onTap: () {
                            showLicensePage(
                              context: context,
                              applicationName: 'TabataFit',
                              applicationVersion: '1.0.0',
                            );
                          },
                        ),
                        _buildDivider(isDark),
                        _buildNavigationTile(
                          icon: Icons.help_rounded,
                          iconColor: AppColors.accentYellow,
                          title: '도움말',
                          isDark: isDark,
                          onTap: () => _showHelpDialog(context, isDark),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 타바타 소개
                    _buildSectionHeader(
                      '타바타 운동이란?',
                      Icons.fitness_center_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(isDark),

                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryRed, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(bool isDark, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGray : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 56,
      color: isDark ? Colors.grey[800] : Colors.grey[200],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryRed,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget trailing,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String timeString,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  timeString,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimePicker(
    BuildContext context,
    SettingsProvider settingsProvider,
    bool isDark,
  ) {
    showTimePicker(
      context: context,
      initialTime: settingsProvider.reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryRed,
              onPrimary: Colors.white,
              surface: isDark ? AppColors.darkGray : Colors.white,
              onSurface: isDark ? Colors.white : Colors.black87,
            ),
            dialogBackgroundColor: isDark ? AppColors.darkGray : Colors.white,
          ),
          child: child!,
        );
      },
    ).then((selectedTime) {
      if (selectedTime != null) {
        settingsProvider.setReminderTime(
          selectedTime.hour,
          selectedTime.minute,
        );
      }
    });
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryRed.withOpacity(isDark ? 0.2 : 0.08),
            AppColors.primaryRedDark.withOpacity(isDark ? 0.1 : 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryRed.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.timer_rounded,
                  color: AppColors.primaryRed,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '기본 프로토콜',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '타바타 운동은 일본의 운동생리학자 타바타 이즈미 박사가 개발한 고강도 인터벌 트레이닝(HIIT)입니다.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          _buildProtocolItem(
            Icons.fitness_center_rounded,
            '20초 운동 (최대 강도)',
            isDark,
          ),
          _buildProtocolItem(Icons.pause_circle_rounded, '10초 휴식', isDark),
          _buildProtocolItem(Icons.repeat_rounded, '8세트 반복', isDark),
          _buildProtocolItem(Icons.timer_rounded, '총 4분', isDark),
          const SizedBox(height: 12),
          Text(
            '짧은 시간에 높은 효과를 얻을 수 있어 바쁜 현대인에게 적합합니다.',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolItem(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryRed),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkGray : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '도움말',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildHelpItem(
              Icons.flash_on_rounded,
              '빠른 시작',
              '홈 화면에서 "빠른 시작" 버튼을 눌러 기본 타바타 운동을 시작할 수 있습니다.',
              isDark,
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              Icons.fitness_center_rounded,
              '운동 선택',
              '운동 탭에서 난이도별로 다양한 운동 프로그램을 선택할 수 있습니다.',
              isDark,
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              Icons.bar_chart_rounded,
              '통계',
              '통계 탭에서 운동 기록과 진행 상황을 확인할 수 있습니다.',
              isDark,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(
    IconData icon,
    String title,
    String description,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryRed.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryRed, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
