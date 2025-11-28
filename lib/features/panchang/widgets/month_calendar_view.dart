import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
  late AnimationController _monthChangeController;
  late AnimationController _dateAnimationController;
  late Animation<double> _monthFadeAnimation;
  late List<Animation<double>> _dateScaleAnimations;

  DateTime _currentMonth = DateTime.now();
  DateTime? _hoveredDate;

  final List<String> _weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
    _pageController = PageController(
      initialPage: 12, // Start at current month in middle
    );

    _monthChangeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _dateAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _monthFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _monthChangeController, curve: Curves.easeInOut),
    );

    _dateScaleAnimations = List.generate(
      42, // Max days in calendar grid
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _dateAnimationController,
          curve: Interval(
            index * 0.01,
            0.3 + index * 0.01,
            curve: Curves.easeOutBack,
          ),
        ),
      ),
    );

    _monthChangeController.forward();
    _dateAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _monthChangeController.dispose();
    _dateAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Month selector
        _buildMonthSelector(isDarkMode),

        // Week days header
        _buildWeekDaysHeader(isDarkMode),

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
              _monthChangeController.forward(from: 0);
              _dateAnimationController.forward(from: 0);
            },
            itemBuilder: (context, index) {
              final month = DateTime(
                DateTime.now().year,
                DateTime.now().month + index - 12,
              );
              return _buildCalendarGrid(month, isDarkMode);
            },
          ),
        ),

        // Legend
        _buildLegend(isDarkMode),
      ],
    );
  }

  Widget _buildMonthSelector(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? Colors.grey[800]?.withOpacity(0.5)
                        : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                color: isDarkMode ? Colors.white : Colors.grey[700],
                size: 20,
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _monthFadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _monthFadeAnimation.value,
                child: Column(
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(_currentMonth),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.grey[900],
                      ),
                    ),
                    Text(
                      _getHinduMonth(_currentMonth),
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFFFDAB3D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          IconButton(
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? Colors.grey[800]?.withOpacity(0.5)
                        : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: isDarkMode ? Colors.white : Colors.grey[700],
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaysHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            _weekDays.map((day) {
              final isWeekend = day == 'S';
              return Container(
                width: 40,
                height: 30,
                alignment: Alignment.center,
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        isWeekend
                            ? Colors.orange
                            : (isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600]),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(DateTime month, bool isDarkMode) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
    final daysInMonth = lastDay.day;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
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

        return AnimatedBuilder(
          animation: _dateScaleAnimations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _dateScaleAnimations[index].value,
              child: _buildDateCell(date, day, isSelected, isToday, isDarkMode),
            );
          },
        );
      },
    );
  }

  Widget _buildDateCell(
    DateTime date,
    int day,
    bool isSelected,
    bool isToday,
    bool isDarkMode,
  ) {
    final hasFestival = _hasFestival(date);
    final hasFast = _hasFast(date);
    final hasReminder = _hasReminder(date);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onDateSelected(date);
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showDateOptions(date);
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredDate = date),
        onExit: (_) => setState(() => _hoveredDate = null),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? const LinearGradient(
                      colors: [Color(0xFFFDAB3D), Color(0xFFFF8E53)],
                    )
                    : null,
            color:
                !isSelected
                    ? (isToday
                        ? const Color(0xFFFDAB3D).withOpacity(0.1)
                        : (_hoveredDate == date
                            ? (isDarkMode
                                ? Colors.grey[800]?.withOpacity(0.5)
                                : Colors.grey[100])
                            : Colors.transparent))
                    : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isToday ? const Color(0xFFFDAB3D) : Colors.transparent,
              width: isToday ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              // Date number
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected || isToday
                                ? FontWeight.w600
                                : FontWeight.w500,
                        color:
                            isSelected
                                ? Colors.white
                                : (isDarkMode
                                    ? Colors.white
                                    : Colors.grey[900]),
                      ),
                    ),
                    if (_getTithi(date).isNotEmpty)
                      Text(
                        _getTithi(date),
                        style: TextStyle(
                          fontSize: 8,
                          color:
                              isSelected
                                  ? Colors.white.withOpacity(0.9)
                                  : const Color(0xFF6C5CE7),
                        ),
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
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6B6B),
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (hasFast)
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00B894),
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (hasReminder)
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6C5CE7),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem('Festival', const Color(0xFFFF6B6B), isDarkMode),
          _buildLegendItem('Fast', const Color(0xFF00B894), isDarkMode),
          _buildLegendItem('Reminder', const Color(0xFF6C5CE7), isDarkMode),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getHinduMonth(DateTime date) {
    // Mock Hindu month names
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
    // Mock tithi calculation
    final tithis = ['', 'Ekadashi', '', 'Purnima', '', 'Amavasya', ''];
    return tithis[date.day % 7];
  }

  bool _hasFestival(DateTime date) {
    // Mock festival check
    return date.day % 7 == 0;
  }

  bool _hasFast(DateTime date) {
    // Mock fast check
    return date.day % 11 == 0;
  }

  bool _hasReminder(DateTime date) {
    // Mock reminder check
    return date.day % 15 == 0;
  }

  void _showDateOptions(DateTime date) {
    // Show date options menu
  }
}
