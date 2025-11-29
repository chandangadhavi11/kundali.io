import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

// Premium Cosmic Colors
class _CosmicColors {
  static const background = Color(0xFF0A0612);
  static const cardDark = Color(0xFF16101F);
  static const cardLight = Color(0xFF1E1528);
  static const golden = Color(0xFFE8B931);
  static const goldenLight = Color(0xFFF5D563);
  static const textPrimary = Color(0xFFFAFAFA);
  static const textSecondary = Color(0xFF9CA3AF);
  static const accent = Color(0xFF6C5CE7);
  static const festival = Color(0xFFFF6B6B);
  static const fast = Color(0xFF00B894);
  static const reminder = Color(0xFF6C5CE7);
}

class MonthCalendarView extends StatefulWidget {
  final DateTime selectedDate;
  final String selectedFilter;
  final Function(DateTime) onDateSelected;

  const MonthCalendarView({
    super.key,
    required this.selectedDate,
    required this.selectedFilter,
    required this.onDateSelected,
  });

  @override
  State<MonthCalendarView> createState() => _MonthCalendarViewState();
}

class _MonthCalendarViewState extends State<MonthCalendarView>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;

  DateTime _currentMonth = DateTime.now();

  final List<String> _weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
    _pageController = PageController(initialPage: 12);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Month selector
        _buildMonthSelector(),

        // Week days header
        _buildWeekDaysHeader(),

        // Calendar grid
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentMonth = DateTime(
                  DateTime.now().year,
                  DateTime.now().month + index - 12,
                );
              });
              _fadeController.forward(from: 0);
            },
            itemBuilder: (context, index) {
              final month = DateTime(
                DateTime.now().year,
                DateTime.now().month + index - 12,
              );
              return _buildCalendarGrid(month);
            },
          ),
        ),

        // Legend
        _buildLegend(),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavigationButton(
            icon: Icons.chevron_left_rounded,
            onTap: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),

          FadeTransition(
            opacity: _fadeController,
            child: Column(
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_currentMonth),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: _CosmicColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getHinduMonth(_currentMonth),
                  style: TextStyle(
                    fontSize: 12,
                    color: _CosmicColors.golden,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          _buildNavigationButton(
            icon: Icons.chevron_right_rounded,
            onTap: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: _CosmicColors.textPrimary,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildWeekDaysHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _weekDays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final isWeekend = index == 0 || index == 6;

          return Expanded(
            child: Container(
              height: 32,
              alignment: Alignment.center,
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isWeekend
                      ? _CosmicColors.golden
                      : _CosmicColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
    final daysInMonth = lastDay.day;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 1.0,
        ),
        itemCount: 42,
        itemBuilder: (context, index) {
          if (index < startWeekday || index >= startWeekday + daysInMonth) {
            return const SizedBox.shrink();
          }

          final day = index - startWeekday + 1;
          final date = DateTime(month.year, month.month, day);
          final isSelected = DateUtils.isSameDay(date, widget.selectedDate);
          final isToday = DateUtils.isSameDay(date, DateTime.now());

          return _buildDateCell(date, day, isSelected, isToday);
        },
      ),
    );
  }

  Widget _buildDateCell(
    DateTime date,
    int day,
    bool isSelected,
    bool isToday,
  ) {
    final hasFestival = _hasFestival(date);
    final hasFast = _hasFast(date);
    final hasReminder = _hasReminder(date);
    final tithi = _getTithi(date);
    final isWeekend = date.weekday == DateTime.sunday || date.weekday == DateTime.saturday;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onDateSelected(date);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _CosmicColors.golden,
                    _CosmicColors.goldenLight,
                  ],
                )
              : null,
          color: !isSelected
              ? (isToday
                  ? _CosmicColors.golden.withOpacity(0.12)
                  : Colors.white.withOpacity(0.03))
              : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isToday && !isSelected
                ? _CosmicColors.golden.withOpacity(0.5)
                : Colors.transparent,
            width: isToday ? 1.5 : 0,
          ),
        ),
        child: Stack(
          children: [
            // Date content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected || isToday
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? _CosmicColors.background
                          : (isWeekend
                              ? _CosmicColors.golden.withOpacity(0.9)
                              : _CosmicColors.textPrimary),
                    ),
                  ),
                  if (tithi.isNotEmpty)
                    Text(
                      tithi,
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? _CosmicColors.background.withOpacity(0.7)
                            : _CosmicColors.accent.withOpacity(0.8),
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Event indicators
            if (hasFestival || hasFast || hasReminder)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasFestival)
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _CosmicColors.background.withOpacity(0.6)
                              : _CosmicColors.festival,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (hasFast)
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _CosmicColors.background.withOpacity(0.6)
                              : _CosmicColors.fast,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (hasReminder)
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _CosmicColors.background.withOpacity(0.6)
                              : _CosmicColors.reminder,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Festival', _CosmicColors.festival),
              _buildLegendItem('Fast', _CosmicColors.fast),
              _buildLegendItem('Reminder', _CosmicColors.reminder),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _CosmicColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _getHinduMonth(DateTime date) {
    final months = [
      'Chaitra',
      'Vaisakha',
      'Jyeshtha',
      'Ashadha',
      'Shravana',
      'Bhadrapada',
      'Ashwin',
      'Kartika',
      'Margashirsha',
      'Pausha',
      'Magha',
      'Phalguna',
    ];
    return months[date.month - 1];
  }

  String _getTithi(DateTime date) {
    final tithis = ['', 'Ekadashi', '', 'Purnima', '', 'Amavasya', ''];
    return tithis[date.day % 7];
  }

  bool _hasFestival(DateTime date) {
    return date.day % 7 == 0;
  }

  bool _hasFast(DateTime date) {
    return date.day % 11 == 0;
  }

  bool _hasReminder(DateTime date) {
    return date.day % 15 == 0;
  }
}
