import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _sectionAnimations;

  // Settings values
  String _selectedLanguage = 'English';
  String _selectedRegion = 'North India';
  String _chartStyle = 'North Indian';
  bool _dailyHoroscope = true;
  bool _panchangAlerts = true;
  bool _festivalReminders = true;
  bool _dashaChange = false;
  final String _quietHoursStart = '10:00 PM';
  final String _quietHoursEnd = '7:00 AM';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _sectionAnimations = List.generate(
      8,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[950] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.grey[800]?.withOpacity(0.5)
                      : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language & Region
            AnimatedBuilder(
              animation: _sectionAnimations[0],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - _sectionAnimations[0].value)),
                  child: Opacity(
                    opacity: _sectionAnimations[0].value,
                    child: _buildSection('Language & Region', [
                      _buildDropdownSetting(
                        'Language',
                        Icons.language_rounded,
                        _selectedLanguage,
                        ['English', 'Hindi', 'Tamil', 'Telugu', 'Bengali'],
                        (value) => setState(() => _selectedLanguage = value!),
                        isDarkMode,
                      ),
                      _buildDropdownSetting(
                        'Region',
                        Icons.location_on_rounded,
                        _selectedRegion,
                        [
                          'North India',
                          'South India',
                          'East India',
                          'West India',
                        ],
                        (value) => setState(() => _selectedRegion = value!),
                        isDarkMode,
                      ),
                      _buildDropdownSetting(
                        'Chart Style',
                        Icons.grid_view_rounded,
                        _chartStyle,
                        ['North Indian', 'South Indian', 'East Indian'],
                        (value) => setState(() => _chartStyle = value!),
                        isDarkMode,
                      ),
                    ], isDarkMode),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Notifications
            AnimatedBuilder(
              animation: _sectionAnimations[1],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - _sectionAnimations[1].value)),
                  child: Opacity(
                    opacity: _sectionAnimations[1].value,
                    child: _buildSection('Notifications', [
                      _buildSwitchSetting(
                        'Daily Horoscope',
                        Icons.stars_rounded,
                        _dailyHoroscope,
                        (value) => setState(() => _dailyHoroscope = value),
                        isDarkMode,
                      ),
                      _buildSwitchSetting(
                        'Panchang Alerts',
                        Icons.calendar_today_rounded,
                        _panchangAlerts,
                        (value) => setState(() => _panchangAlerts = value),
                        isDarkMode,
                      ),
                      _buildSwitchSetting(
                        'Festival Reminders',
                        Icons.celebration_rounded,
                        _festivalReminders,
                        (value) => setState(() => _festivalReminders = value),
                        isDarkMode,
                      ),
                      _buildSwitchSetting(
                        'Dasha Change Alerts',
                        Icons.change_circle_rounded,
                        _dashaChange,
                        (value) => setState(() => _dashaChange = value),
                        isDarkMode,
                      ),
                      _buildTimeSetting(
                        'Quiet Hours',
                        Icons.do_not_disturb_rounded,
                        '$_quietHoursStart - $_quietHoursEnd',
                        () => _showQuietHoursDialog(),
                        isDarkMode,
                      ),
                    ], isDarkMode),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Appearance
            AnimatedBuilder(
              animation: _sectionAnimations[2],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - _sectionAnimations[2].value)),
                  child: Opacity(
                    opacity: _sectionAnimations[2].value,
                    child: _buildSection('Appearance', [
                      _buildThemeSetting(themeProvider, isDarkMode),
                    ], isDarkMode),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Data & Privacy
            AnimatedBuilder(
              animation: _sectionAnimations[3],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - _sectionAnimations[3].value)),
                  child: Opacity(
                    opacity: _sectionAnimations[3].value,
                    child: _buildSection('Data & Privacy', [
                      _buildActionSetting(
                        'Export Data',
                        Icons.download_rounded,
                        () => _exportData(),
                        isDarkMode,
                      ),
                      _buildActionSetting(
                        'Delete Account',
                        Icons.delete_forever_rounded,
                        () => _showDeleteAccountDialog(),
                        isDarkMode,
                        isDestructive: true,
                      ),
                      _buildActionSetting(
                        'Clear Cache',
                        Icons.cleaning_services_rounded,
                        () => _clearCache(),
                        isDarkMode,
                      ),
                    ], isDarkMode),
                  ),
                );
              },
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color:
                isDarkMode ? Colors.grey[900]?.withOpacity(0.5) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isDarkMode
                      ? Colors.grey[800]!.withOpacity(0.5)
                      : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Column(
            children:
                items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == items.length - 1;

                  return Column(
                    children: [
                      item,
                      if (!isLast)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(
                            height: 1,
                            color:
                                isDarkMode
                                    ? Colors.grey[800]!.withOpacity(0.5)
                                    : Colors.grey[200]!,
                          ),
                        ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownSetting(
    String title,
    IconData icon,
    String value,
    List<String> options,
    Function(String?) onChanged,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF6C5CE7), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.grey[900],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.grey[800]?.withOpacity(0.5)
                      : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton<String>(
              value: value,
              items:
                  options.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode ? Colors.white : Colors.grey[900],
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: onChanged,
              underline: const SizedBox(),
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                size: 20,
              ),
              isDense: true,
              dropdownColor: isDarkMode ? Colors.grey[850] : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF00B894).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF00B894), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.grey[900],
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00B894),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSetting(
    String title,
    IconData icon,
    String value,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFDAB3D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFFDAB3D), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.grey[900],
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSetting(
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDarkMode, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (isDestructive
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFF3498DB))
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color:
                    isDestructive
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFF3498DB),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color:
                      isDestructive
                          ? const Color(0xFFFF6B6B)
                          : (isDarkMode ? Colors.white : Colors.grey[900]),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSetting(ThemeProvider themeProvider, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.palette_rounded,
              color: Color(0xFF6C5CE7),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Theme',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.grey[800]?.withOpacity(0.5)
                      : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _buildThemeOption('Light', ThemeMode.light, themeProvider),
                _buildThemeOption('Dark', ThemeMode.dark, themeProvider),
                _buildThemeOption('System', ThemeMode.system, themeProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    String label,
    ThemeMode mode,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.themeMode == mode;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        themeProvider.setThemeMode(mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF6C5CE7).withOpacity(0.2)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color:
                isSelected
                    ? const Color(0xFF6C5CE7)
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  void _showQuietHoursDialog() {
    // Show quiet hours picker
  }

  void _exportData() {
    // Export user data
  }

  void _showDeleteAccountDialog() {
    // Show delete account confirmation
  }

  void _clearCache() {
    // Clear app cache
  }
}
