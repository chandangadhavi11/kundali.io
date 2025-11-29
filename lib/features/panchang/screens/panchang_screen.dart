import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../../core/providers/panchang_provider.dart';
import '../widgets/month_calendar_view.dart';
import '../widgets/day_detail_view.dart';
import '../widgets/festivals_index_view.dart';
import '../widgets/muhurat_finder_view.dart';
import '../widgets/reminders_view.dart';

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
}

class PanchangScreen extends StatefulWidget {
  const PanchangScreen({super.key});

  @override
  State<PanchangScreen> createState() => _PanchangScreenState();
}

class _PanchangScreenState extends State<PanchangScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _entryController;

  DateTime _selectedDate = DateTime.now();
  final String _selectedRegion = 'North India';
  String _selectedFilter = 'All';
  int _selectedTabIndex = 0;

  final List<String> _tabs = ['Calendar', 'Festivals', 'Muhurat', 'Reminders'];
  final List<IconData> _tabIcons = [
    Icons.calendar_month_rounded,
    Icons.celebration_rounded,
    Icons.access_time_filled_rounded,
    Icons.notifications_active_rounded,
  ];

  final List<String> _filters = ['All', 'Festivals', 'Fasts', 'Personal'];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadData();
  }

  void _initControllers() {
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  Future<void> _loadData() async {
    final panchangProvider = context.read<PanchangProvider>();
    await panchangProvider.fetchPanchang(_selectedDate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _CosmicColors.background,
      body: Stack(
        children: [
          // Cosmic background gradient
          _buildCosmicBackground(),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Premium Header
                _buildPremiumHeader(),

                const SizedBox(height: 8),

                // Tab Bar
                _buildCosmicTabBar(),

                const SizedBox(height: 12),

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
        ],
      ),
      floatingActionButton: _selectedTabIndex == 0 ? _buildCosmicFAB() : null,
    );
  }

  Widget _buildCosmicBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.2,
          colors: [
            _CosmicColors.accent.withOpacity(0.08),
            _CosmicColors.background,
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return FadeTransition(
      opacity: _entryController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _entryController,
          curve: Curves.easeOut,
        )),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              // Top row with back button, title and today button
              Row(
                children: [
                  // Back button
                  _buildGlassButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                    size: 40,
                  ),

                  const SizedBox(width: 12),

                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Panchang',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: _CosmicColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _CosmicColors.golden,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Hindu Calendar & Muhurat',
                          style: TextStyle(
                            fontSize: 12,
                            color: _CosmicColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Today button
                  _buildTodayButton(),
                ],
              ),

              const SizedBox(height: 12),

              // Filter chips row (only for Calendar tab)
              if (_selectedTabIndex == 0) _buildFilterChips(),

              const SizedBox(height: 8),

              // Region selector
              _buildRegionSelector(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 36,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: size * 0.5,
              color: _CosmicColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayButton() {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedDate = DateTime.now();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isToday
              ? LinearGradient(
                  colors: [
                    _CosmicColors.golden,
                    _CosmicColors.goldenLight,
                  ],
                )
              : null,
          color: !isToday ? Colors.white.withOpacity(0.08) : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isToday
                ? Colors.transparent
                : _CosmicColors.golden.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.today_rounded,
              size: 14,
              color: isToday
                  ? _CosmicColors.background
                  : _CosmicColors.golden,
            ),
            const SizedBox(width: 6),
            Text(
              'Today',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isToday
                    ? _CosmicColors.background
                    : _CosmicColors.golden,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          _CosmicColors.golden.withOpacity(0.2),
                          _CosmicColors.golden.withOpacity(0.1),
                        ],
                      )
                    : null,
                color: !isSelected ? Colors.white.withOpacity(0.05) : null,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? _CosmicColors.golden.withOpacity(0.5)
                      : Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: _CosmicColors.golden,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    filter,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? _CosmicColors.golden
                          : _CosmicColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegionSelector() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _CosmicColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: _CosmicColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _selectedRegion,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _CosmicColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: _CosmicColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCosmicTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 44,
      decoration: BoxDecoration(
        color: _CosmicColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _CosmicColors.golden,
              _CosmicColors.goldenLight,
            ],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: _CosmicColors.background,
        unselectedLabelColor: _CosmicColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        tabs: List.generate(
          _tabs.length,
          (index) => Tab(
            height: 36,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_tabIcons[index], size: 14),
                  const SizedBox(width: 4),
                  Text(_tabs[index]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCosmicFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _CosmicColors.golden.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          _showDayDetail(_selectedDate);
        },
        backgroundColor: _CosmicColors.golden,
        foregroundColor: _CosmicColors.background,
        elevation: 0,
        icon: const Icon(Icons.calendar_today_rounded, size: 18),
        label: Text(
          DateFormat('MMM dd').format(_selectedDate),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
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
