import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/panchang_provider.dart';
import '../widgets/month_calendar_view.dart';
import '../widgets/day_detail_view.dart';
import '../widgets/festivals_index_view.dart';
import '../widgets/muhurat_finder_view.dart';
import '../widgets/reminders_view.dart';

class PanchangScreen extends StatefulWidget {
  const PanchangScreen({super.key});

  @override
  State<PanchangScreen> createState() => _PanchangScreenState();
}

class _PanchangScreenState extends State<PanchangScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerController;
  late AnimationController _fabController;
  late Animation<double> _headerAnimation;
  late Animation<double> _fabScaleAnimation;

  DateTime _selectedDate = DateTime.now();
  final String _selectedRegion = 'North India';
  String _selectedFilter = 'All';

  final List<String> _tabs = ['Calendar', 'Festivals', 'Muhurat', 'Reminders'];
  final List<IconData> _tabIcons = [
    Icons.calendar_month_rounded,
    Icons.celebration_rounded,
    Icons.access_time_filled_rounded,
    Icons.notifications_active_rounded,
  ];

  final List<String> _filters = [
    'All',
    'Festivals',
    'Fasts',
    'Personal',
    'Region',
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadData();
  }

  void _initControllers() {
    _tabController = TabController(length: 4, vsync: this);

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _fabController.forward();
    });
  }

  Future<void> _loadData() async {
    final panchangProvider = context.read<PanchangProvider>();
    await panchangProvider.fetchPanchang(_selectedDate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[950] : Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            AnimatedBuilder(
              animation: _headerAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -20 * (1 - _headerAnimation.value)),
                  child: Opacity(
                    opacity: _headerAnimation.value,
                    child: _buildHeader(isDarkMode),
                  ),
                );
              },
            ),

            // Tab Bar
            _buildTabBar(isDarkMode),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  MonthCalendarView(
                    selectedDate: _selectedDate,
                    selectedFilter: _selectedFilter,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                      _showDayDetail(date);
                    },
                  ),
                  const FestivalsIndexView(),
                  const MuhuratFinderView(),
                  const RemindersView(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(isDarkMode),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Back button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode
                            ? Colors.grey[800]?.withOpacity(0.5)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isDarkMode
                              ? Colors.grey[700]!.withOpacity(0.3)
                              : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: isDarkMode ? Colors.white : Colors.grey[800],
                  ),
                ),
              ),

              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Panchang',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.grey[900],
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Hindu Calendar & Muhurat',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Today button
              _buildTodayButton(isDarkMode),
            ],
          ),

          const SizedBox(height: 12),

          // Filter chips
          if (_tabController.index == 0) _buildFilterChips(isDarkMode),

          // Region selector
          _buildRegionSelector(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildTodayButton(bool isDarkMode) {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedDate = DateTime.now();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient:
              isToday
                  ? const LinearGradient(
                    colors: [Color(0xFFFDAB3D), Color(0xFFFF8E53)],
                  )
                  : null,
          color:
              !isToday
                  ? (isDarkMode ? Colors.grey[800] : Colors.grey[200])
                  : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.today_rounded,
              size: 16,
              color:
                  isToday
                      ? Colors.white
                      : (isDarkMode ? Colors.white : Colors.grey[700]),
            ),
            const SizedBox(width: 6),
            Text(
              'Today',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    isToday
                        ? Colors.white
                        : (isDarkMode ? Colors.white : Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDarkMode) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor:
                  isDarkMode
                      ? Colors.grey[800]?.withOpacity(0.5)
                      : Colors.grey[100],
              selectedColor: const Color(0xFFFDAB3D).withOpacity(0.2),
              checkmarkColor: const Color(0xFFFDAB3D),
              labelStyle: TextStyle(
                fontSize: 12,
                color:
                    isSelected
                        ? const Color(0xFFFDAB3D)
                        : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color:
                      isSelected
                          ? const Color(0xFFFDAB3D).withOpacity(0.3)
                          : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegionSelector(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900]?.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDarkMode
                  ? Colors.grey[800]!.withOpacity(0.5)
                  : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            size: 16,
            color: const Color(0xFF6C5CE7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _selectedRegion,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.grey[900],
              ),
            ),
          ),
          Icon(
            Icons.arrow_drop_down_rounded,
            size: 20,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color:
            isDarkMode ? Colors.grey[900]?.withOpacity(0.5) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFDAB3D), Color(0xFFFF8E53)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: List.generate(
          _tabs.length,
          (index) => Tab(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_tabIcons[index], size: 18),
                const SizedBox(width: 6),
                Text(_tabs[index]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(bool isDarkMode) {
    if (_tabController.index != 0) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _fabScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabScaleAnimation.value,
          child: FloatingActionButton.extended(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showDayDetail(_selectedDate);
            },
            backgroundColor: const Color(0xFFFDAB3D),
            icon: const Icon(Icons.calendar_today_rounded, size: 20),
            label: Text(
              DateFormat('MMM dd').format(_selectedDate),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  void _showDayDetail(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DayDetailView(date: date),
    );
  }
}


