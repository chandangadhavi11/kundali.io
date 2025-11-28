import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/kundali_data_model.dart';
import '../../../core/providers/kundli_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/kundali_chart_painter.dart';
import 'package:intl/intl.dart';

class KundliDisplayScreen extends StatefulWidget {
  final KundaliData? kundaliData;

  const KundliDisplayScreen({super.key, this.kundaliData});

  @override
  State<KundliDisplayScreen> createState() => _KundliDisplayScreenState();
}

class _KundliDisplayScreenState extends State<KundliDisplayScreen>
    with TickerProviderStateMixin {
  // Tab controller
  late TabController _tabController;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _chartAnimationController;
  late List<AnimationController> _itemAnimationControllers;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _chartScale;
  late Animation<double> _chartFade;

  // Current chart style
  late ChartStyle _currentChartStyle;
  
  // Effective kundali data (from widget or provider)
  KundaliData? _effectiveKundaliData;

  KundaliData? get _kundaliData => _effectiveKundaliData ?? widget.kundaliData;

  @override
  void initState() {
    super.initState();
    _effectiveKundaliData = widget.kundaliData;
    _currentChartStyle = _kundaliData?.chartStyle ?? ChartStyle.northIndian;
    _tabController = TabController(length: 5, vsync: this);
    _initAnimations();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If no data passed, try to get from provider
    if (_effectiveKundaliData == null) {
      final kundliProvider = context.read<KundliProvider>();
      if (kundliProvider.savedKundalis.isNotEmpty) {
        _effectiveKundaliData = kundliProvider.savedKundalis.first;
        _currentChartStyle = _kundaliData?.chartStyle ?? ChartStyle.northIndian;
      }
    }
  }

  void _initAnimations() {
    // Main animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Chart animations
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _chartScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _chartAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _chartFade = CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeIn,
    );

    // Item animations
    _itemAnimationControllers = List.generate(
      10,
      (index) => AnimationController(
        duration: Duration(milliseconds: 300 + (index * 40)),
        vsync: this,
      ),
    );

    // Start animations
    _fadeController.forward();
    _chartAnimationController.forward();
    
    for (var controller in _itemAnimationControllers) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _chartAnimationController.dispose();
    for (var controller in _itemAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Show loading state if no data available
    if (_kundaliData == null) {
      return Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
        appBar: AppBar(
          title: const Text('Kundli'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading Kundli data...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Compact Header
            _buildCompactHeader(isDarkMode),
            
            // Tab Bar
            _buildCompactTabBar(isDarkMode),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChartTab(isDarkMode, screenWidth),
                  _buildPlanetsTab(isDarkMode),
                  _buildHousesTab(isDarkMode),
                  _buildDashaTab(isDarkMode),
                  _buildReportTab(isDarkMode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar
          Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  CupertinoIcons.arrow_left,
                  size: 20,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              // Share Button
              _buildHeaderButton(
                icon: CupertinoIcons.share,
                onTap: _shareKundali,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(width: 12),
              // Menu Button
              _buildHeaderButton(
                icon: CupertinoIcons.ellipsis,
                onTap: () => _showOptionsMenu(context, isDarkMode),
                isDarkMode: isDarkMode,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // User Info
          FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _kundaliData!.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          if (_kundaliData!.isPrimary) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.star_fill,
                                    size: 10,
                                    color: Colors.amber[700],
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Primary',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.amber[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.location,
                            size: 12,
                            color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _kundaliData!.birthPlace,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            CupertinoIcons.calendar,
                            size: 12,
                            color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateTime(_kundaliData!.birthDateTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode 
              ? Colors.white.withOpacity(0.05) 
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCompactTabBar(bool isDarkMode) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.white.withOpacity(0.05) 
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: isDarkMode ? Colors.white : AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: isDarkMode ? Colors.black : Colors.white,
        unselectedLabelColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Chart'),
          Tab(text: 'Planets'),
          Tab(text: 'Houses'),
          Tab(text: 'Dasha'),
          Tab(text: 'Report'),
        ],
      ),
    );
  }

  Widget _buildChartTab(bool isDarkMode, double screenWidth) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth > 600 ? 20 : 16),
      child: Column(
        children: [
          // Chart Style Selector
          _buildCompactChartStyleSelector(isDarkMode),
          const SizedBox(height: 20),

          // Kundali Chart
          FadeTransition(
            opacity: _chartFade,
            child: ScaleTransition(
              scale: _chartScale,
              child: Container(
                height: screenWidth > 600 ? 380 : 320,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomPaint(
                  size: Size(screenWidth - 80, screenWidth - 80),
                  painter: _currentChartStyle == ChartStyle.northIndian
                      ? NorthIndianChartPainter(
                          houses: _kundaliData!.houses,
                          planets: _kundaliData!.planetPositions,
                          ascendantSign: _kundaliData!.ascendant.sign,
                          isDarkMode: isDarkMode,
                          textStyle: Theme.of(context).textTheme.bodyMedium,
                        )
                      : SouthIndianChartPainter(
                          houses: _kundaliData!.houses,
                          planets: _kundaliData!.planetPositions,
                          ascendantSign: _kundaliData!.ascendant.sign,
                          isDarkMode: isDarkMode,
                          textStyle: Theme.of(context).textTheme.bodyMedium,
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Basic Info Cards
          _buildCompactInfoCards(isDarkMode),
          const SizedBox(height: 20),

          // Yogas and Doshas
          if (_kundaliData!.yogas.isNotEmpty ||
              _kundaliData!.doshas.isNotEmpty)
            _buildCompactYogasDoshasSection(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildCompactChartStyleSelector(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ChartStyle.values.map((style) {
          final isSelected = _currentChartStyle == style;
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentChartStyle = style;
              });
              HapticFeedback.lightImpact();
              // Animate chart change
              _chartAnimationController.reset();
              _chartAnimationController.forward();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDarkMode ? Colors.white : AppColors.primary)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                style.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? (isDarkMode ? Colors.black : Colors.white)
                      : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompactInfoCards(bool isDarkMode) {
    final cards = [
      {
        'title': 'Asc',
        'value': _kundaliData!.ascendant.formattedPosition,
        'icon': CupertinoIcons.arrow_up_circle_fill,
        'color': const Color(0xFF6B4EE6),
      },
      {
        'title': 'Moon',
        'value': _kundaliData!.moonSign,
        'icon': CupertinoIcons.moon_fill,
        'color': const Color(0xFF4ECDC4),
      },
      {
        'title': 'Sun',
        'value': _kundaliData!.sunSign,
        'icon': CupertinoIcons.sun_max_fill,
        'color': const Color(0xFFFFB347),
      },
      {
        'title': 'Naksh',
        'value': _kundaliData!.birthNakshatra,
        'icon': CupertinoIcons.star_fill,
        'color': const Color(0xFFFF6B6B),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.1,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return _buildAnimatedItem(
          index: index,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (card['color'] as Color).withOpacity(isDarkMode ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  card['icon'] as IconData,
                  color: card['color'] as Color,
                  size: 18,
                ),
                const SizedBox(height: 6),
                Text(
                  card['value'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  card['title'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactYogasDoshasSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_kundaliData!.yogas.isNotEmpty) ...[
          Text(
            'Yogas Present',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _kundaliData!.yogas.map((yoga) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF4ECDC4).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  yoga,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF4ECDC4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        if (_kundaliData!.doshas.isNotEmpty) ...[
          Text(
            'Doshas Present',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _kundaliData!.doshas.map((dosha) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFF6B6B).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  dosha,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFFFF6B6B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPlanetsTab(bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _kundaliData!.planetPositions.length,
      itemBuilder: (context, index) {
        final planet = _kundaliData!.planetPositions.values.elementAt(index);
        
        return _buildAnimatedItem(
          index: index,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getPlanetColor(planet.planet).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _getPlanetSymbol(planet.planet),
                      style: TextStyle(
                        fontSize: 18,
                        color: _getPlanetColor(planet.planet),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planet.planet,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '${planet.sign} ${planet.signDegree.toStringAsFixed(2)}°',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'H${planet.house}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            planet.nakshatra,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${planet.longitude.toStringAsFixed(2)}°',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHousesTab(bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _kundaliData!.houses.length,
      itemBuilder: (context, index) {
        final house = _kundaliData!.houses[index];
        
        return _buildAnimatedItem(
          index: index,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${house.number}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getHouseName(house.number),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            house.sign,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          if (house.planets.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '• ',
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                house.planets.join(', '),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  _getHouseIcon(house.number),
                  color: AppColors.primary.withOpacity(0.3),
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashaTab(bool isDarkMode) {
    final dashaInfo = _kundaliData!.dashaInfo;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Dasha Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _getPlanetSymbol(dashaInfo.currentMahadasha),
                      style: TextStyle(
                        fontSize: 20,
                        color: _getPlanetColor(dashaInfo.currentMahadasha),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Mahadasha',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dashaInfo.currentMahadasha,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.time,
                            size: 12,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${dashaInfo.remainingYears.toStringAsFixed(1)} years left',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Until ${_formatDate(dashaInfo.endDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Dasha Sequence
          Text(
            'Vimshottari Dasha Sequence',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          ...dashaInfo.sequence.asMap().entries.map((entry) {
            final index = entry.key;
            final period = entry.value;
            final isCurrent = period.planet == dashaInfo.currentMahadasha;

            return _buildAnimatedItem(
              index: index,
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.primary.withOpacity(0.1)
                      : (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent
                        ? AppColors.primary
                        : (isDarkMode ? Colors.white.withOpacity(0.1) : Colors.transparent),
                    width: isCurrent ? 1.5 : 1,
                  ),
                  boxShadow: [
                    if (!isCurrent)
                      BoxShadow(
                        color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getPlanetColor(period.planet).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          _getPlanetSymbol(period.planet),
                          style: TextStyle(
                            fontSize: 14,
                            color: _getPlanetColor(period.planet),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        period.planet,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      '${period.years} years',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReportTab(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompactReportSection(
            title: 'Personality Overview',
            content: 'Based on your ascendant ${_kundaliData!.ascendant.sign} and Moon sign ${_kundaliData!.moonSign}, you possess a unique blend of qualities...',
            icon: CupertinoIcons.person_crop_circle,
            color: const Color(0xFF6B4EE6),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildCompactReportSection(
            title: 'Career Insights',
            content: 'Your 10th house and planetary positions indicate strong potential in leadership roles...',
            icon: CupertinoIcons.briefcase,
            color: const Color(0xFF4ECDC4),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildCompactReportSection(
            title: 'Relationship & Marriage',
            content: 'Your 7th house analysis suggests harmonious relationships with partners who value...',
            icon: CupertinoIcons.heart_circle,
            color: const Color(0xFFFF6B6B),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildCompactReportSection(
            title: 'Health Indicators',
            content: 'Pay attention to your 6th house ruler for maintaining optimal health...',
            icon: CupertinoIcons.heart_circle_fill,
            color: const Color(0xFF4ECB71),
            isDarkMode: isDarkMode,
          ),
          if (_kundaliData!.doshas.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildCompactReportSection(
              title: 'Recommended Remedies',
              content: 'To mitigate the effects of doshas present in your chart, consider these remedies...',
              icon: CupertinoIcons.sparkles,
              color: const Color(0xFFFFB347),
              isDarkMode: isDarkMode,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactReportSection({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    final controller = _itemAnimationControllers[index.clamp(0, 9)];
    return FadeTransition(
      opacity: CurvedAnimation(parent: controller, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );
  }

  Color _getPlanetColor(String planet) {
    final colors = {
      'Sun': const Color(0xFFFFB347),
      'Moon': const Color(0xFF4ECDC4),
      'Mars': const Color(0xFFFF6B6B),
      'Mercury': const Color(0xFF4ECB71),
      'Jupiter': const Color(0xFFFFD93D),
      'Venus': const Color(0xFFFF69B4),
      'Saturn': const Color(0xFF6C757D),
      'Rahu': const Color(0xFF9B59B6),
      'Ketu': const Color(0xFF8B4513),
    };
    return colors[planet] ?? Colors.grey;
  }

  String _getPlanetSymbol(String planet) {
    final symbols = {
      'Sun': '☉',
      'Moon': '☽',
      'Mars': '♂',
      'Mercury': '☿',
      'Jupiter': '♃',
      'Venus': '♀',
      'Saturn': '♄',
      'Rahu': '⟐',
      'Ketu': '⟑',
    };
    return symbols[planet] ?? planet.substring(0, 2);
  }

  String _getHouseName(int houseNumber) {
    final names = [
      'Self', 'Wealth', 'Siblings', 'Home',
      'Children', 'Health', 'Partner', 'Transform',
      'Fortune', 'Career', 'Gains', 'Losses',
    ];
    return names[(houseNumber - 1) % 12];
  }

  IconData _getHouseIcon(int houseNumber) {
    final icons = [
      CupertinoIcons.person,
      CupertinoIcons.money_dollar,
      CupertinoIcons.person_2,
      CupertinoIcons.house,
      CupertinoIcons.heart,
      CupertinoIcons.heart_circle,
      CupertinoIcons.person_2_fill,
      CupertinoIcons.arrow_2_circlepath,
      CupertinoIcons.book,
      CupertinoIcons.briefcase,
      CupertinoIcons.person_3,
      CupertinoIcons.moon_stars,
    ];
    return icons[(houseNumber - 1) % 12];
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('d MMM y, h:mm a').format(dateTime);
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM y').format(date);
  }

  void _shareKundali() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Share functionality coming soon',
          style: TextStyle(fontSize: 13),
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuItem(
                icon: CupertinoIcons.square_arrow_down,
                title: 'Export PDF',
                onTap: () {
                  Navigator.pop(context);
                  _handleMenuAction('export');
                },
                isDarkMode: isDarkMode,
              ),
              _buildMenuItem(
                icon: CupertinoIcons.star,
                title: 'Set as Primary',
                onTap: () {
                  Navigator.pop(context);
                  _handleMenuAction('primary');
                },
                isDarkMode: isDarkMode,
              ),
              _buildMenuItem(
                icon: CupertinoIcons.doc_on_doc,
                title: 'Duplicate',
                onTap: () {
                  Navigator.pop(context);
                  _handleMenuAction('duplicate');
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'PDF export coming soon',
              style: TextStyle(fontSize: 13),
            ),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        );
        break;
      case 'primary':
        context.read<KundliProvider>().setPrimaryKundali(_kundaliData!.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Set as primary Kundali',
              style: TextStyle(fontSize: 13),
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        );
        break;
      case 'duplicate':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Duplicate functionality coming soon',
              style: TextStyle(fontSize: 13),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        );
        break;
    }
  }
}
