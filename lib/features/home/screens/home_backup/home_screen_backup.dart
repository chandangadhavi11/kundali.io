import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/horoscope_provider.dart';
import '../../../../core/providers/panchang_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/modern_feature_card.dart';
import '../../../../shared/widgets/custom_icons.dart';
import '../../../../shared/widgets/modern_horoscope_card.dart';
import '../../../../shared/widgets/modern_panchang_card.dart';
import '../../../../shared/widgets/modern_app_header.dart';
import '../../../../shared/widgets/modern_greeting_section.dart';

// Responsive breakpoints
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1800;
}

// Screen size helper
enum ScreenSize { mobile, tablet, desktop, largeDesktop }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late List<Animation<Offset>> _slideAnimations;

  // Desktop sidebar state
  bool _isSidebarCollapsed = false;
  final double _sidebarExpandedWidth = 280;
  final double _sidebarCollapsedWidth = 72;

  // Carousel state
  final PageController _carouselPageController = PageController(
    viewportFraction: 0.85,
  );
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    // Load data after the first frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _initAnimations() {
    // Fade animation for the header
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Slide animations for cards
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimations = List.generate(
      8, // Increased for more cards
      (index) =>
          Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _slideController,
              curve: Interval(
                index * 0.05,
                math.min(0.6 + index * 0.05, 1.0),
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _carouselPageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final horoscopeProvider = context.read<HoroscopeProvider>();
    final panchangProvider = context.read<PanchangProvider>();

    await Future.wait([
      horoscopeProvider.fetchDailyHoroscopes(),
      panchangProvider.fetchPanchang(DateTime.now()),
    ]);
  }

  // Get screen size based on width
  ScreenSize _getScreenSize(double width) {
    if (width < ResponsiveBreakpoints.mobile) return ScreenSize.mobile;
    if (width < ResponsiveBreakpoints.tablet) return ScreenSize.tablet;
    if (width < ResponsiveBreakpoints.desktop) return ScreenSize.desktop;
    return ScreenSize.largeDesktop;
  }

  // Get responsive grid column count
  int _getGridColumns(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 1;
      case ScreenSize.tablet:
        return 2;
      case ScreenSize.desktop:
        return 3;
      case ScreenSize.largeDesktop:
        return 4;
    }
  }

  // Get responsive padding
  EdgeInsets _getResponsivePadding(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return const EdgeInsets.all(12.0);
      case ScreenSize.tablet:
        return const EdgeInsets.all(20.0);
      case ScreenSize.desktop:
        return const EdgeInsets.all(24.0);
      case ScreenSize.largeDesktop:
        return const EdgeInsets.all(32.0);
    }
  }

  // Get responsive spacing
  double _getResponsiveSpacing(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 12.0;
      case ScreenSize.tablet:
        return 16.0;
      case ScreenSize.desktop:
        return 20.0;
      case ScreenSize.largeDesktop:
        return 24.0;
    }
  }

  // Get responsive font scale
  double _getFontScale(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 0.9;
      case ScreenSize.tablet:
        return 1.0;
      case ScreenSize.desktop:
        return 1.1;
      case ScreenSize.largeDesktop:
        return 1.2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final screenSize = _getScreenSize(screenWidth);
        final isDesktop =
            screenSize == ScreenSize.desktop ||
            screenSize == ScreenSize.largeDesktop;
        final isMobile = screenSize == ScreenSize.mobile;
        final isLandscape = screenWidth > screenHeight;

        // Adjust layout for landscape mobile
        final effectiveScreenSize =
            isMobile && isLandscape ? ScreenSize.tablet : screenSize;

        return Scaffold(
          body: Row(
            children: [
              // Desktop Sidebar (only shown on desktop)
              if (isDesktop) _buildDesktopSidebar(context),

              // Main Content Area
              Expanded(
                child: _buildMainContent(
                  context,
                  effectiveScreenSize,
                  screenWidth,
                  isLandscape,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build collapsible sidebar for desktop
  Widget _buildDesktopSidebar(BuildContext context) {
    final sidebarWidth =
        _isSidebarCollapsed ? _sidebarCollapsedWidth : _sidebarExpandedWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: sidebarWidth,
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Sidebar Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!_isSidebarCollapsed)
                  Text(
                    'Menu',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    _isSidebarCollapsed ? Icons.menu_open : Icons.menu,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSidebarCollapsed = !_isSidebarCollapsed;
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Sidebar Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSidebarItem(
                  context,
                  icon: Icons.home,
                  label: 'Home',
                  isSelected: true,
                  onTap: () {},
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.stars_rounded,
                  label: 'Generate Kundli',
                  onTap: () => context.push('/kundli/input'),
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.favorite,
                  label: 'Compatibility',
                  onTap: () => context.push('/compatibility'),
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.auto_awesome,
                  label: 'Horoscope',
                  onTap: () => context.go('/horoscope'),
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Panchang',
                  onTap: () => context.go('/panchang'),
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.chat_bubble,
                  label: 'AI Astrologer',
                  onTap: () => context.go('/chat'),
                  badge: 'NEW',
                ),
                const Divider(height: 32),
                _buildSidebarItem(
                  context,
                  icon: Icons.person,
                  label: 'Profile',
                  onTap: () => context.go('/profile'),
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () => context.push('/settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
    String? badge,
  }) {
    return Tooltip(
      message: _isSidebarCollapsed ? label : '',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Theme.of(context).primaryColor : null,
          ),
          title:
              !_isSidebarCollapsed
                  ? Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w600 : null,
                            color:
                                isSelected
                                    ? Theme.of(context).primaryColor
                                    : null,
                          ),
                        ),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  )
                  : null,
          onTap: onTap,
          contentPadding: EdgeInsets.symmetric(
            horizontal: _isSidebarCollapsed ? 16 : 20,
            vertical: 4,
          ),
        ),
      ),
    );
  }

  // Build main content area
  Widget _buildMainContent(
    BuildContext context,
    ScreenSize screenSize,
    double screenWidth,
    bool isLandscape,
  ) {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();
    final horoscopeProvider = context.watch<HoroscopeProvider>();
    final panchangProvider = context.watch<PanchangProvider>();

    final user = authProvider.currentUser;
    final isGuest = user == null;
    final userName = isGuest ? 'Guest' : user.name.split(' ').first;
    final userSign = isGuest ? 'Aries' : user.zodiacSign;

    final padding = _getResponsivePadding(screenSize);
    final spacing = _getResponsiveSpacing(screenSize);
    final fontScale = _getFontScale(screenSize);
    final gridColumns = _getGridColumns(screenSize);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // Responsive App Bar
            SliverAppBar(
              floating: true,
              backgroundColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[900]
                      : Colors.white,
              elevation: 0,
              expandedHeight: screenSize == ScreenSize.mobile ? null : 80,
              title: ModernAppHeader(
                appName: l10n?.appName ?? 'Kundali App',
                onNotificationTap: () {
                  // TODO: Show notifications
                },
                notificationCount: 3,
              ),
            ),

            // Content with responsive padding
            SliverPadding(
              padding: padding,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Responsive Greeting Section
                  _buildResponsiveGreeting(
                    userName,
                    userSign,
                    isGuest,
                    screenSize,
                    fontScale,
                  ),
                  SizedBox(height: spacing * 1.5),

                  // Responsive Carousel for mobile/tablet or Grid for desktop
                  if (screenSize == ScreenSize.mobile ||
                      (screenSize == ScreenSize.tablet && !isLandscape))
                    _buildCarouselSection(
                      context,
                      horoscopeProvider,
                      panchangProvider,
                      userSign,
                      screenSize,
                    )
                  else
                    _buildGridSection(
                      context,
                      horoscopeProvider,
                      panchangProvider,
                      userSign,
                      screenSize,
                    ),

                  SizedBox(height: spacing * 2),

                  // Quick Actions Header
                  _buildSectionHeader(context, 'Quick Actions', fontScale),
                  SizedBox(height: spacing),

                  // Responsive Feature Grid
                  _buildResponsiveFeatureGrid(
                    context,
                    l10n,
                    gridColumns,
                    spacing,
                    screenSize,
                  ),

                  SizedBox(height: spacing * 2),

                  // Premium Banner (responsive)
                  if (!isGuest && !user.isPremium)
                    _buildResponsivePremiumBanner(
                      context,
                      screenSize,
                      fontScale,
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build responsive greeting section
  Widget _buildResponsiveGreeting(
    String userName,
    String userSign,
    bool isGuest,
    ScreenSize screenSize,
    double fontScale,
  ) {
    return Transform.scale(
      scale: fontScale,
      alignment: Alignment.centerLeft,
      child: ModernGreetingSection(
        userName: userName,
        userSign: userSign,
        isGuest: isGuest,
      ),
    );
  }

  // Build carousel section for mobile/tablet
  Widget _buildCarouselSection(
    BuildContext context,
    HoroscopeProvider horoscopeProvider,
    PanchangProvider panchangProvider,
    String userSign,
    ScreenSize screenSize,
  ) {
    final cards = <Widget>[];

    if (!horoscopeProvider.isLoading &&
        horoscopeProvider.dailyHoroscopes[userSign] != null) {
      cards.add(
        ModernHoroscopeCard(
          sign: userSign,
          horoscope: horoscopeProvider.dailyHoroscopes[userSign]!,
          onTap: () => context.go('/horoscope'),
        ),
      );
    }

    if (!panchangProvider.isLoading &&
        panchangProvider.currentPanchang != null) {
      cards.add(
        ModernPanchangCard(
          panchang: panchangProvider.currentPanchang!,
          onTap: () => context.go('/panchang'),
        ),
      );
    }

    if (cards.isEmpty) return const SizedBox.shrink();

    final cardHeight = screenSize == ScreenSize.mobile ? 200.0 : 240.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Today\'s Insights', 1.0),
        const SizedBox(height: 16),
        SizedBox(
          height: cardHeight,
          child: PageView.builder(
            controller: _carouselPageController,
            onPageChanged: (index) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
            itemCount: cards.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _carouselPageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_carouselPageController.position.haveDimensions) {
                    value = _carouselPageController.page! - index;
                    value = (1 - (value.abs() * 0.1)).clamp(0.0, 1.0);
                  }
                  return Center(
                    child: SizedBox(
                      height: Curves.easeOut.transform(value) * cardHeight,
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: cards[index],
                ),
              );
            },
          ),
        ),
        // Page indicators
        if (cards.length > 1)
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  cards.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentCarouselIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          _currentCarouselIndex == index
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Build grid section for desktop
  Widget _buildGridSection(
    BuildContext context,
    HoroscopeProvider horoscopeProvider,
    PanchangProvider panchangProvider,
    String userSign,
    ScreenSize screenSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Today\'s Insights', 1.0),
        const SizedBox(height: 16),
        Row(
          children: [
            if (!horoscopeProvider.isLoading &&
                horoscopeProvider.dailyHoroscopes[userSign] != null)
              Expanded(
                child: ModernHoroscopeCard(
                  sign: userSign,
                  horoscope: horoscopeProvider.dailyHoroscopes[userSign]!,
                  onTap: () => context.go('/horoscope'),
                ),
              ),
            if (!horoscopeProvider.isLoading &&
                horoscopeProvider.dailyHoroscopes[userSign] != null &&
                !panchangProvider.isLoading &&
                panchangProvider.currentPanchang != null)
              const SizedBox(width: 16),
            if (!panchangProvider.isLoading &&
                panchangProvider.currentPanchang != null)
              Expanded(
                child: ModernPanchangCard(
                  panchang: panchangProvider.currentPanchang!,
                  onTap: () => context.go('/panchang'),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // Build section header
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    double fontScale,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              fontSize:
                  Theme.of(context).textTheme.titleLarge!.fontSize! * fontScale,
            ),
          ),
        ],
      ),
    );
  }

  // Build responsive feature grid
  Widget _buildResponsiveFeatureGrid(
    BuildContext context,
    AppLocalizations? l10n,
    int columns,
    double spacing,
    ScreenSize screenSize,
  ) {
    final features = [
      {
        'icon': CustomIcons.kundliIcon(),
        'title': l10n?.generateKundli ?? 'Generate Kundli',
        'subtitle': 'Create birth chart',
        'primaryColor': const Color(0xFFFF6B6B),
        'secondaryColor': const Color(0xFFFFE0E0),
        'onTap': () {
          print('Generate Kundli button tapped!');
          context.push('/kundli/input');
        },
      },
      {
        'icon': CustomIcons.compatibilityIcon(),
        'title': l10n?.kundliMatching ?? 'Kundli Matching',
        'subtitle': 'Check compatibility',
        'primaryColor': const Color(0xFF6C5CE7),
        'secondaryColor': const Color(0xFFE8E5FF),
        'onTap': () => context.push('/compatibility'),
        'badge': 'POPULAR',
      },
      {
        'icon': CustomIcons.aiChatIcon(),
        'title': 'AI Astrologer',
        'subtitle': 'Ask questions',
        'primaryColor': const Color(0xFF00B894),
        'secondaryColor': const Color(0xFFD1F2EB),
        'onTap': () => context.go('/chat'),
        'isNew': true,
      },
      {
        'icon': CustomIcons.festivalIcon(),
        'title': 'Festivals',
        'subtitle': 'Upcoming events',
        'primaryColor': const Color(0xFFFDAB3D),
        'secondaryColor': const Color(0xFFFFF4E0),
        'onTap': () => context.go('/panchang'),
      },
    ];

    // Calculate responsive aspect ratio
    double aspectRatio;
    switch (screenSize) {
      case ScreenSize.mobile:
        aspectRatio = 1.8; // Wider cards on mobile
      case ScreenSize.tablet:
        aspectRatio = 1.4;
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        aspectRatio = 1.2;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return SlideTransition(
          position: _slideAnimations[index % _slideAnimations.length],
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ModernFeatureCard(
              icon: feature['icon'] as Widget,
              title: feature['title'] as String,
              subtitle: feature['subtitle'] as String,
              primaryColor: feature['primaryColor'] as Color,
              secondaryColor: feature['secondaryColor'] as Color,
              onTap: feature['onTap'] as VoidCallback,
              badge: feature['badge'] as String?,
              isNew: feature['isNew'] as bool? ?? false,
            ),
          ),
        );
      },
    );
  }

  // Build responsive premium banner
  Widget _buildResponsivePremiumBanner(
    BuildContext context,
    ScreenSize screenSize,
    double fontScale,
  ) {
    final isCompact = screenSize == ScreenSize.mobile;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.go('/subscription');
          },
          borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 12.0 : 20.0),
            child:
                isCompact
                    ? Column(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 32 * fontScale,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upgrade to Premium',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                Theme.of(
                                  context,
                                ).textTheme.titleMedium!.fontSize! *
                                fontScale,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Unlimited AI questions & more',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontSize:
                                Theme.of(
                                  context,
                                ).textTheme.bodySmall!.fontSize! *
                                fontScale,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                    : Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 40 * fontScale,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upgrade to Premium',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      Theme.of(
                                        context,
                                      ).textTheme.headlineSmall!.fontSize! *
                                      fontScale,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Get unlimited AI questions, detailed reports, and exclusive features',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                  fontSize:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyMedium!.fontSize! *
                                      fontScale,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                          size: 20 * fontScale,
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
