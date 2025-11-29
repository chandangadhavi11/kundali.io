import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../widgets/astrologers_marketplace_view.dart';
import '../../widgets/chat_history_view.dart';

// Responsive breakpoints
class ChatHubBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1800;
}

// Screen size categories
enum ScreenSize { mobile, tablet, desktop, largeDesktop }

// Chat hub layout modes
enum ChatHubLayout {
  single, // Mobile - single view
  drawer, // Tablet portrait - drawer list
  split, // Tablet landscape - split view
  desktop, // Desktop - full split with sidebar
}

class ModernChatHomeScreen extends StatefulWidget {
  const ModernChatHomeScreen({super.key});

  @override
  State<ModernChatHomeScreen> createState() => _ModernChatHomeScreenState();
}

class _ModernChatHomeScreenState extends State<ModernChatHomeScreen>
    with TickerProviderStateMixin {
  // Tab and animation controllers
  late TabController _tabController;
  late AnimationController _headerController;
  late AnimationController _floatingController;
  late AnimationController _searchAnimationController;
  late AnimationController _listAnimationController;
  late AnimationController _swipeController;

  // Animations
  late Animation<double> _headerAnimation;
  late Animation<double> _floatingAnimation;
  // ignore: unused_field
  late Animation<double> _searchAnimation;
  late Animation<double> _listAnimation;
  // ignore: unused_field
  late Animation<double> _swipeAnimation;

  // State
  int _currentTab = 0;
  String? _selectedChatId;
  bool _isSearching = false;
  bool _showChatView = false;
  ChatHubLayout _currentLayout = ChatHubLayout.single;

  // Search and filter
  final TextEditingController _searchTextController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';

  // Data
  final List<ChatItem> _chatItems = [];
  final List<String> _filters = ['all', 'ai', 'experts', 'unread', 'starred'];

  final List<String> _tabs = ['AI Assistant', 'Astrologers', 'History'];
  final List<IconData> _tabIcons = [
    Icons.psychology_rounded,
    Icons.support_agent_rounded,
    Icons.history_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadChatItems();
  }

  void _initControllers() {
    // Tab controller
    _tabController = TabController(length: 3, vsync: this);

    // Animation controllers
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Initialize animations
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );

    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.elasticOut),
    );

    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _listAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _listAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _swipeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _swipeController, curve: Curves.easeOutCubic),
    );

    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _floatingController.forward();
      _listAnimationController.forward();
    });

    // Tab listener
    _tabController.addListener(() {
      if (_tabController.index != _currentTab) {
        setState(() {
          _currentTab = _tabController.index;
        });
      }
    });
  }

  void _loadChatItems() {
    // Simulate loading chat items
    _chatItems.addAll([
      ChatItem(
        id: '1',
        title: 'AI Assistant',
        lastMessage: 'Your horoscope for today shows...',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        type: ChatType.ai,
        unreadCount: 2,
        isStarred: true,
      ),
      ChatItem(
        id: '2',
        title: 'Astrologer Sharma',
        lastMessage: 'Based on your birth chart...',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        type: ChatType.expert,
        unreadCount: 0,
        isStarred: false,
      ),
      ChatItem(
        id: '3',
        title: 'Marriage Consultation',
        lastMessage: 'The planetary positions suggest...',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: ChatType.ai,
        unreadCount: 0,
        isStarred: true,
      ),
      ChatItem(
        id: '4',
        title: 'Career Guidance',
        lastMessage: 'Jupiter transit indicates growth...',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: ChatType.expert,
        unreadCount: 5,
        isStarred: false,
      ),
    ]);
  }

  ScreenSize _getScreenSize(double width) {
    if (width < ChatHubBreakpoints.mobile) return ScreenSize.mobile;
    if (width < ChatHubBreakpoints.tablet) return ScreenSize.tablet;
    if (width < ChatHubBreakpoints.desktop) return ScreenSize.desktop;
    return ScreenSize.largeDesktop;
  }

  ChatHubLayout _getChatHubLayout(double width, double height) {
    final screenSize = _getScreenSize(width);
    final isLandscape = width > height;

    if (screenSize == ScreenSize.mobile) {
      return ChatHubLayout.single;
    } else if (screenSize == ScreenSize.tablet) {
      return isLandscape ? ChatHubLayout.split : ChatHubLayout.drawer;
    } else {
      return ChatHubLayout.desktop;
    }
  }

  List<ChatItem> get _filteredChatItems {
    var items = _chatItems;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      items =
          items.where((item) {
            return item.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                item.lastMessage.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();
    }

    // Apply category filter
    switch (_selectedFilter) {
      case 'ai':
        items = items.where((item) => item.type == ChatType.ai).toList();
        break;
      case 'experts':
        items = items.where((item) => item.type == ChatType.expert).toList();
        break;
      case 'unread':
        items = items.where((item) => item.unreadCount > 0).toList();
        break;
      case 'starred':
        items = items.where((item) => item.isStarred).toList();
        break;
    }

    return items;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerController.dispose();
    _floatingController.dispose();
    _searchAnimationController.dispose();
    _listAnimationController.dispose();
    _swipeController.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final screenSize = _getScreenSize(screenWidth);
        final chatHubLayout = _getChatHubLayout(screenWidth, screenHeight);

        // Update layout state
        if (_currentLayout != chatHubLayout) {
          _currentLayout = chatHubLayout;
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: _buildResponsiveLayout(
            context,
            screenSize,
            chatHubLayout,
            screenWidth,
          ),
          floatingActionButton: _buildResponsiveFAB(context, screenSize),
        );
      },
    );
  }

  Widget _buildResponsiveLayout(
    BuildContext context,
    ScreenSize screenSize,
    ChatHubLayout layout,
    double screenWidth,
  ) {
    switch (layout) {
      case ChatHubLayout.single:
        return _buildMobileLayout(context, screenSize);
      case ChatHubLayout.drawer:
        return _buildTabletDrawerLayout(context, screenSize);
      case ChatHubLayout.split:
        return _buildTabletSplitLayout(context, screenSize);
      case ChatHubLayout.desktop:
        return _buildDesktopLayout(context, screenSize);
    }
  }

  // Mobile layout - single view with navigation
  Widget _buildMobileLayout(BuildContext context, ScreenSize screenSize) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_showChatView && _selectedChatId != null) {
      return _buildChatView(context, screenSize, showBackButton: true);
    }

    return SafeArea(
      child: Column(
        children: [
          // Header
          _buildMobileHeader(context, isDarkMode),

          // Search bar
          _buildSearchBar(context, screenSize),

          // Filter chips
          _buildFilterChips(context, screenSize),

          // Tab bar
          _buildTabBar(context, isDarkMode, screenSize),

          // Content
          Expanded(
            child:
                _currentTab == 0
                    ? _buildChatList(context, screenSize)
                    : (_currentTab == 1
                        ? const AstrologersMarketplaceView()
                        : const ChatHistoryView()),
          ),
        ],
      ),
    );
  }

  // Tablet drawer layout - drawer list with chat view
  Widget _buildTabletDrawerLayout(BuildContext context, ScreenSize screenSize) {
    // final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Drawer/List
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _showChatView ? 80 : 320,
          child: _buildChatDrawer(
            context,
            screenSize,
            collapsed: _showChatView,
          ),
        ),

        // Chat view
        Expanded(
          child:
              _selectedChatId != null
                  ? _buildChatView(context, screenSize, showBackButton: false)
                  : _buildEmptyState(context, screenSize),
        ),
      ],
    );
  }

  // Tablet split layout - side by side
  Widget _buildTabletSplitLayout(BuildContext context, ScreenSize screenSize) {
    return Row(
      children: [
        // Chat list
        SizedBox(width: 380, child: _buildChatListPanel(context, screenSize)),

        // Divider
        Container(width: 1, color: Theme.of(context).dividerColor),

        // Chat view
        Expanded(
          child:
              _selectedChatId != null
                  ? _buildChatView(context, screenSize, showBackButton: false)
                  : _buildEmptyState(context, screenSize),
        ),
      ],
    );
  }

  // Desktop layout - full featured
  Widget _buildDesktopLayout(BuildContext context, ScreenSize screenSize) {
    return Row(
      children: [
        // Sidebar with filters
        SizedBox(width: 280, child: _buildDesktopSidebar(context, screenSize)),

        // Chat list
        SizedBox(width: 400, child: _buildChatListPanel(context, screenSize)),

        // Chat view
        Expanded(
          child:
              _selectedChatId != null
                  ? _buildChatView(context, screenSize, showBackButton: false)
                  : _buildEmptyState(context, screenSize),
        ),
      ],
    );
  }

  // Build mobile header
  Widget _buildMobileHeader(BuildContext context, bool isDarkMode) {
    // final authProvider = context.watch<AuthProvider>();
    // final user = authProvider.currentUser;

    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -20 * (1 - _headerAnimation.value)),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Consultations',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'AI & Expert Guidance',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildWalletButton(isDarkMode),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Build search bar
  Widget _buildSearchBar(BuildContext context, ScreenSize screenSize) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isCompact = screenSize == ScreenSize.mobile;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isSearching ? 60 : 50,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 24,
        vertical: 8,
      ),
      child: TextField(
        controller: _searchTextController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        onTap: () {
          setState(() {
            _isSearching = true;
          });
          _searchAnimationController.forward();
        },
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _isSearching
                  ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchQuery = '';
                      });
                      _searchTextController.clear();
                      _searchAnimationController.reverse();
                    },
                  )
                  : null,
          filled: true,
          fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isCompact ? 12 : 16,
            vertical: isCompact ? 8 : 12,
          ),
        ),
      ),
    );
  }

  // Build filter chips
  Widget _buildFilterChips(BuildContext context, ScreenSize screenSize) {
    final isCompact = screenSize == ScreenSize.mobile;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isCompact ? 40 : 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 24),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.capitalize()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? filter : 'all';
                });
                HapticFeedback.lightImpact();
              },
              backgroundColor: Colors.transparent,
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              side: BorderSide(
                color:
                    isSelected
                        ? AppColors.primary
                        : Colors.grey.withOpacity(0.3),
              ),
            ),
          );
        },
      ),
    );
  }

  // Build tab bar
  Widget _buildTabBar(
    BuildContext context,
    bool isDarkMode,
    ScreenSize screenSize,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            isDarkMode ? Colors.grey[900]?.withOpacity(0.5) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        tabs: List.generate(
          _tabs.length,
          (index) => Tab(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_tabIcons[index], size: 18),
                if (screenSize != ScreenSize.mobile) ...[
                  const SizedBox(width: 6),
                  Text(_tabs[index]),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build chat list
  Widget _buildChatList(BuildContext context, ScreenSize screenSize) {
    final filteredItems = _filteredChatItems;

    if (filteredItems.isEmpty) {
      return _buildEmptyState(context, screenSize);
    }

    return AnimatedBuilder(
      animation: _listAnimation,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            final delay = index * 0.1;

            return FadeTransition(
              opacity: _listAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, 0.2 + delay),
                  end: Offset.zero,
                ).animate(_listAnimation),
                child: _buildChatListItem(context, item, screenSize),
              ),
            );
          },
        );
      },
    );
  }

  // Build chat list item with swipe gestures
  Widget _buildChatListItem(
    BuildContext context,
    ChatItem item,
    ScreenSize screenSize,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isCompact = screenSize == ScreenSize.mobile;
    final isDesktop =
        screenSize == ScreenSize.desktop ||
        screenSize == ScreenSize.largeDesktop;

    Widget listTile = MouseRegion(
      onEnter: isDesktop ? (_) => setState(() {}) : null,
      onExit: isDesktop ? (_) => setState(() {}) : null,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedChatId = item.id;
            if (isCompact) {
              _showChatView = true;
            }
          });
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          decoration: BoxDecoration(
            color:
                _selectedChatId == item.id
                    ? AppColors.primary.withOpacity(0.1)
                    : (isDarkMode ? Colors.grey[900] : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  _selectedChatId == item.id
                      ? AppColors.primary.withOpacity(0.3)
                      : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: isCompact ? 48 : 56,
                height: isCompact ? 48 : 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        item.type == ChatType.ai
                            ? [const Color(0xFF6C5CE7), const Color(0xFF8B7EFF)]
                            : [
                              const Color(0xFFFF6B94),
                              const Color(0xFFFF8E53),
                            ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.type == ChatType.ai
                      ? Icons.psychology_rounded
                      : Icons.person_rounded,
                  color: Colors.white,
                  size: isCompact ? 24 : 28,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: isCompact ? 15 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.isStarred)
                          Icon(Icons.star, size: 16, color: Colors.amber),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.lastMessage,
                      style: TextStyle(
                        fontSize: isCompact ? 13 : 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: isCompact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _formatTimestamp(item.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (item.unreadCount > 0) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${item.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Add swipe gestures for mobile
    if (isCompact) {
      return Dismissible(
        key: Key(item.id),
        direction: DismissDirection.horizontal,
        background: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        secondaryBackground: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.archive, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          HapticFeedback.mediumImpact();
          return await _showConfirmDialog(
            context,
            direction == DismissDirection.startToEnd ? 'Delete' : 'Archive',
          );
        },
        child: listTile,
      );
    }

    return listTile;
  }

  // Build chat list panel (for tablet/desktop)
  Widget _buildChatListPanel(BuildContext context, ScreenSize screenSize) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        border: Border(
          right: BorderSide(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Consultations',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSearchBar(context, screenSize),
              ],
            ),
          ),
          // Filter chips
          _buildFilterChips(context, screenSize),
          const SizedBox(height: 8),
          // Chat list
          Expanded(child: _buildChatList(context, screenSize)),
        ],
      ),
    );
  }

  // Build chat drawer (collapsible)
  Widget _buildChatDrawer(
    BuildContext context,
    ScreenSize screenSize, {
    bool collapsed = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (collapsed) {
      return Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
          border: Border(
            right: BorderSide(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                setState(() {
                  _showChatView = false;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredChatItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredChatItems[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: IconButton(
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:
                                item.type == ChatType.ai
                                    ? [
                                      const Color(0xFF6C5CE7),
                                      const Color(0xFF8B7EFF),
                                    ]
                                    : [
                                      const Color(0xFFFF6B94),
                                      const Color(0xFFFF8E53),
                                    ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.type == ChatType.ai
                              ? Icons.psychology_rounded
                              : Icons.person_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedChatId = item.id;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return _buildChatListPanel(context, screenSize);
  }

  // Build desktop sidebar
  Widget _buildDesktopSidebar(BuildContext context, ScreenSize screenSize) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.stars_rounded, color: AppColors.primary, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Chat Hub',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          // Navigation
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSidebarItem(
                  context,
                  'All Chats',
                  Icons.chat_bubble_outline,
                  'all',
                ),
                _buildSidebarItem(
                  context,
                  'AI Assistant',
                  Icons.psychology_rounded,
                  'ai',
                ),
                _buildSidebarItem(
                  context,
                  'Astrologers',
                  Icons.support_agent_rounded,
                  'experts',
                ),
                _buildSidebarItem(
                  context,
                  'Unread',
                  Icons.mark_chat_unread,
                  'unread',
                ),
                _buildSidebarItem(
                  context,
                  'Starred',
                  Icons.star_outline,
                  'starred',
                ),
              ],
            ),
          ),
          // User section
          Container(
            padding: const EdgeInsets.all(16),
            child: _buildWalletButton(isDarkMode),
          ),
        ],
      ),
    );
  }

  // Build sidebar item
  Widget _buildSidebarItem(
    BuildContext context,
    String title,
    IconData icon,
    String filter,
  ) {
    final isSelected = _selectedFilter == filter;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? AppColors.primary : null),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primary : null,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          setState(() {
            _selectedFilter = filter;
          });
        },
      ),
    );
  }

  // Build chat view
  Widget _buildChatView(
    BuildContext context,
    ScreenSize screenSize, {
    bool showBackButton = false,
  }) {
    final selectedChat = _chatItems.firstWhere(
      (item) => item.id == _selectedChatId,
      orElse: () => _chatItems.first,
    );

    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _showChatView = false;
                    });
                  },
                ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        selectedChat.type == ChatType.ai
                            ? [const Color(0xFF6C5CE7), const Color(0xFF8B7EFF)]
                            : [
                              const Color(0xFFFF6B94),
                              const Color(0xFFFF8E53),
                            ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  selectedChat.type == ChatType.ai
                      ? Icons.psychology_rounded
                      : Icons.person_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedChat.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      selectedChat.type == ChatType.ai
                          ? 'AI Assistant'
                          : 'Expert',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
        ),
        // Chat content
        Expanded(child: Center(child: Text('Chat with ${selectedChat.title}'))),
      ],
    );
  }

  // Build empty state
  Widget _buildEmptyState(BuildContext context, ScreenSize screenSize) {
    final isCompact = screenSize == ScreenSize.mobile;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: isCompact ? 80 : 120,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No chats found'
                : 'Select a conversation',
            style: TextStyle(
              fontSize: isCompact ? 18 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search'
                : 'Choose a chat to start messaging',
            style: TextStyle(
              fontSize: isCompact ? 14 : 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Build responsive FAB
  Widget? _buildResponsiveFAB(BuildContext context, ScreenSize screenSize) {
    if (_currentTab != 0) return null;

    final isCompact = screenSize == ScreenSize.mobile;

    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _floatingAnimation.value,
          child:
              isCompact
                  ? FloatingActionButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Start new chat
                    },
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.edit_rounded, color: Colors.white),
                  )
                  : FloatingActionButton.extended(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Start new chat
                    },
                    backgroundColor: AppColors.primary,
                    label: const Text(
                      'New Chat',
                      style: TextStyle(color: Colors.white),
                    ),
                    icon: const Icon(Icons.edit_rounded, color: Colors.white),
                  ),
        );
      },
    );
  }

  // Build wallet button
  Widget _buildWalletButton(bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showWalletSheet();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_balance_wallet_rounded,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            const Text(
              '₹ 500',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Future<bool?> _showConfirmDialog(BuildContext context, String action) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$action Chat'),
          content: Text(
            'Are you sure you want to ${action.toLowerCase()} this chat?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        );
      },
    );
  }

  void _showWalletSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WalletBottomSheet(),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// Chat item model
class ChatItem {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime timestamp;
  final ChatType type;
  final int unreadCount;
  final bool isStarred;

  ChatItem({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    required this.type,
    this.unreadCount = 0,
    this.isStarred = false,
  });
}

// Chat type enum
enum ChatType { ai, expert }

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

// Wallet bottom sheet (keeping existing implementation)
class WalletBottomSheet extends StatelessWidget {
  const WalletBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.6,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: const Center(child: Text('Wallet implementation')),
    );
  }
}
