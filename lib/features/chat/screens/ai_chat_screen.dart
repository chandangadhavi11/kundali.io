import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/auth_required_dialog.dart';

// Responsive breakpoints
class ChatBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1800;
}

// Screen size categories
enum ScreenSize { mobile, tablet, desktop, largeDesktop }

// Chat layout modes
enum ChatLayout {
  single, // Mobile - single column
  compact, // Tablet portrait - compact sidebar
  expanded, // Tablet landscape - expanded sidebar
  desktop, // Desktop - full sidebar and features
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // Animation controllers
  late AnimationController _sendButtonController;
  late AnimationController _typingIndicatorController;
  late AnimationController _messageAnimationController;
  late AnimationController _sidebarController;

  // Animations - these will be used in full implementation
  // ignore: unused_field
  late Animation<double> _sendButtonAnimation;
  // ignore: unused_field
  late Animation<double> _typingIndicatorAnimation;
  // ignore: unused_field
  late Animation<double> _messageAnimation;
  // ignore: unused_field
  late Animation<double> _sidebarAnimation;

  // State
  bool _isTyping = false;
  // ignore: unused_field
  bool _isAiTyping = false;
  final bool _isSidebarExpanded = true;
  bool _isKeyboardVisible = false;
  ChatLayout _currentLayout = ChatLayout.single;
  String? _selectedChatId;

  // Data
  final List<ChatMessage> _messages = [];
  List<ChatHistory> _chatHistory = [];
  final List<String> _selectedContextChips = [];

  // Quick actions and context
  final List<String> _contextChips = [
    'My Kundli',
    'Today\'s Transit',
    'Partner Match',
    'Career',
    'Health',
    'Relationships',
    'Finance',
  ];

  final List<String> _quickPrompts = [
    'What does my future hold?',
    'When will I get married?',
    'Career guidance needed',
    'Health concerns',
    'Financial advice',
    'Relationship compatibility',
    'Lucky periods',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeChat();
    _setupKeyboardListener();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _sendButtonController.dispose();
    _typingIndicatorController.dispose();
    _messageAnimationController.dispose();
    _sidebarController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    // Send button animation
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sendButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.elasticOut),
    );

    // Typing indicator animation
    _typingIndicatorController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _typingIndicatorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _typingIndicatorController,
        curve: Curves.easeInOut,
      ),
    );

    // Message animation
    _messageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _messageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _messageAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Sidebar animation
    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _sidebarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sidebarController, curve: Curves.easeOutCubic),
    );

    // Message controller listener
    _messageController.addListener(() {
      if (_messageController.text.isNotEmpty && !_isTyping) {
        _sendButtonController.forward();
        setState(() => _isTyping = true);
      } else if (_messageController.text.isEmpty && _isTyping) {
        _sendButtonController.reverse();
        setState(() => _isTyping = false);
      }
    });
  }

  void _initializeChat() {
    // Add welcome message
    _messages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            'Hello! I\'m your AI Astrology Assistant. I can help you understand your birth chart, provide personalized predictions, and answer any astrological questions you may have. How can I assist you today?',
        isUser: false,
        timestamp: DateTime.now(),
        type: MessageType.text,
      ),
    );

    // Load chat history
    _loadChatHistory();

    // Start animations
    _messageAnimationController.forward();
    _sidebarController.forward();
  }

  void _setupKeyboardListener() {
    _focusNode.addListener(() {
      setState(() {
        _isKeyboardVisible = _focusNode.hasFocus;
      });
    });
  }

  void _loadChatHistory() {
    // Simulate loading chat history
    _chatHistory = [
      ChatHistory(
        id: '1',
        title: 'Marriage Prediction',
        lastMessage: 'Based on your chart...',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 0,
      ),
      ChatHistory(
        id: '2',
        title: 'Career Guidance',
        lastMessage: 'The next 3 months...',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 2,
      ),
      ChatHistory(
        id: '3',
        title: 'Health Analysis',
        lastMessage: 'Your health houses...',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        unreadCount: 0,
      ),
    ];
  }

  ScreenSize _getScreenSize(double width) {
    if (width < ChatBreakpoints.mobile) return ScreenSize.mobile;
    if (width < ChatBreakpoints.tablet) return ScreenSize.tablet;
    if (width < ChatBreakpoints.desktop) return ScreenSize.desktop;
    return ScreenSize.largeDesktop;
  }

  ChatLayout _getChatLayout(double width, double height) {
    final screenSize = _getScreenSize(width);
    final isLandscape = width > height;

    if (screenSize == ScreenSize.mobile) {
      return ChatLayout.single;
    } else if (screenSize == ScreenSize.tablet) {
      return isLandscape ? ChatLayout.expanded : ChatLayout.compact;
    } else {
      return ChatLayout.desktop;
    }
  }

  double _getMaxMessageWidth(double screenWidth, ScreenSize screenSize) {
    // Maintain readable line lengths (45-75 characters)
    // Assuming average character width of 8-10px
    switch (screenSize) {
      case ScreenSize.mobile:
        return screenWidth * 0.85; // Max 85% of screen
      case ScreenSize.tablet:
        return math.min(screenWidth * 0.7, 600); // Max 600px
      case ScreenSize.desktop:
        return math.min(screenWidth * 0.5, 750); // Max 750px (75 chars)
      case ScreenSize.largeDesktop:
        return math.min(screenWidth * 0.4, 800); // Max 800px
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    // Check if user is authenticated
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      await AuthRequiredDialog.show(
        context,
        feature: 'AI Astrologer',
        description:
            'Sign in to get personalized astrological guidance from our AI assistant.',
      );
      return;
    }

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _messageController.text,
      isUser: true,
      timestamp: DateTime.now(),
      contextChips: List.from(_selectedContextChips),
      type: MessageType.text,
    );

    setState(() {
      _messages.add(message);
      _selectedContextChips.clear();
      _isAiTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();
    _messageAnimationController.forward(from: 0);

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text:
                  'Based on your birth chart and current planetary positions, I can see interesting developments ahead. The conjunction of Jupiter with your natal Moon suggests a period of emotional growth and potential opportunities in your personal relationships...',
              isUser: false,
              timestamp: DateTime.now(),
              type: MessageType.text,
            ),
          );
          _isAiTyping = false;
        });
        _scrollToBottom();
        _messageAnimationController.forward(from: 0);
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final screenSize = _getScreenSize(screenWidth);
        final chatLayout = _getChatLayout(screenWidth, screenHeight);

        // Update layout state
        if (_currentLayout != chatLayout) {
          _currentLayout = chatLayout;
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: _buildResponsiveLayout(
            context,
            screenSize,
            chatLayout,
            screenWidth,
          ),
        );
      },
    );
  }

  Widget _buildResponsiveLayout(
    BuildContext context,
    ScreenSize screenSize,
    ChatLayout layout,
    double screenWidth,
  ) {
    switch (layout) {
      case ChatLayout.single:
        return _buildMobileLayout(context, screenSize, screenWidth);
      case ChatLayout.compact:
        return _buildTabletCompactLayout(context, screenSize, screenWidth);
      case ChatLayout.expanded:
        return _buildTabletExpandedLayout(context, screenSize, screenWidth);
      case ChatLayout.desktop:
        return _buildDesktopLayout(context, screenSize, screenWidth);
    }
  }

  // Mobile layout - single column
  Widget _buildMobileLayout(
    BuildContext context,
    ScreenSize screenSize,
    double screenWidth,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        children: [
          // Header
          _buildMobileHeader(context, isDarkMode),

          // Messages area
          Expanded(child: _buildMessagesArea(context, screenSize, screenWidth)),

          // Context chips (when starting)
          if (_messages.length <= 1 && !_isKeyboardVisible)
            _buildContextChips(context, screenSize),

          // Quick prompts (when starting)
          if (_messages.length <= 1 && !_isKeyboardVisible)
            _buildQuickPrompts(context, screenSize),

          // Input area
          _buildInputArea(context, screenSize, screenWidth),
        ],
      ),
    );
  }

  // Tablet compact layout - with collapsible sidebar
  Widget _buildTabletCompactLayout(
    BuildContext context,
    ScreenSize screenSize,
    double screenWidth,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Collapsible sidebar
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isSidebarExpanded ? 280 : 72,
          child: _buildSidebar(context, screenSize, compact: true),
        ),

        // Main chat area
        Expanded(
          child: Column(
            children: [
              // Header
              _buildTabletHeader(context, isDarkMode),

              // Messages
              Expanded(
                child: _buildMessagesArea(context, screenSize, screenWidth),
              ),

              // Input area
              _buildInputArea(context, screenSize, screenWidth),
            ],
          ),
        ),
      ],
    );
  }

  // Tablet expanded layout - with expanded sidebar
  Widget _buildTabletExpandedLayout(
    BuildContext context,
    ScreenSize screenSize,
    double screenWidth,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Sidebar
        SizedBox(
          width: 320,
          child: _buildSidebar(context, screenSize, compact: false),
        ),

        // Main chat area
        Expanded(
          child: Column(
            children: [
              // Header with features
              _buildExpandedHeader(context, isDarkMode),

              // Messages
              Expanded(
                child: _buildMessagesArea(context, screenSize, screenWidth),
              ),

              // Context bar
              if (_messages.length <= 2) _buildContextBar(context, screenSize),

              // Input area
              _buildInputArea(context, screenSize, screenWidth),
            ],
          ),
        ),
      ],
    );
  }

  // Desktop layout - full featured
  Widget _buildDesktopLayout(
    BuildContext context,
    ScreenSize screenSize,
    double screenWidth,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Sidebar with chat history
        SizedBox(
          width: 360,
          child: _buildSidebar(context, screenSize, compact: false),
        ),

        // Main chat area
        Expanded(
          child: Column(
            children: [
              // Header with AI info
              _buildDesktopHeader(context, isDarkMode),

              // Messages with side features
              Expanded(
                child: Row(
                  children: [
                    // Messages area
                    Expanded(
                      child: _buildMessagesArea(
                        context,
                        screenSize,
                        screenWidth,
                      ),
                    ),

                    // Right panel with suggestions
                    if (screenWidth > 1400)
                      SizedBox(
                        width: 280,
                        child: _buildSuggestionsPanel(context, isDarkMode),
                      ),
                  ],
                ),
              ),

              // Input area with attachments
              _buildInputArea(context, screenSize, screenWidth),
            ],
          ),
        ),
      ],
    );
  }

  // Stub methods - implement as needed
  Widget _buildMobileHeader(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Text('AI Chat'),
        ],
      ),
    );
  }

  Widget _buildTabletHeader(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Text('AI Chat - Tablet'),
    );
  }

  Widget _buildExpandedHeader(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Text('AI Chat - Expanded'),
    );
  }

  Widget _buildDesktopHeader(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Text('AI Chat - Desktop'),
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    ScreenSize screenSize, {
    bool compact = false,
  }) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Chat History',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                final chat = _chatHistory[index];
                final isSelected = _selectedChatId == chat.id;
                return ListTile(
                  selected: isSelected,
                  title: Text(chat.title),
                  subtitle: Text(chat.lastMessage),
                  onTap: () {
                    setState(() {
                      _selectedChatId = chat.id;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesArea(
    BuildContext context,
    ScreenSize screenSize,
    double screenWidth,
  ) {
    final maxWidth = _getMaxMessageWidth(screenWidth, screenSize);
    return ListView.builder(
      controller: _scrollController,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return Align(
          alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: msg.isUser ? AppColors.primary : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                color: msg.isUser ? Colors.white : Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContextChips(BuildContext context, ScreenSize screenSize) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _contextChips.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(label: Text(_contextChips[index])),
          );
        },
      ),
    );
  }

  Widget _buildQuickPrompts(BuildContext context, ScreenSize screenSize) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickPrompts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(_quickPrompts[index]),
              onPressed: () {
                _messageController.text = _quickPrompts[index];
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildContextBar(BuildContext context, ScreenSize screenSize) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        children: _contextChips.map((chip) => Chip(label: Text(chip))).toList(),
      ),
    );
  }

  Widget _buildSuggestionsPanel(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suggestions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _quickPrompts.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(_quickPrompts[index]),
                    onTap: () {
                      _messageController.text = _quickPrompts[index];
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

  Widget _buildInputArea(
    BuildContext context,
    ScreenSize screenSize,
    double screenWidth,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (screenSize != ScreenSize.mobile || !_isKeyboardVisible)
            IconButton(icon: const Icon(Icons.attach_file), onPressed: () {}),
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isTyping ? _sendMessage : null,
            color: _isTyping ? AppColors.primary : Colors.grey,
          ),
        ],
      ),
    );
  }
}

// Chat message model
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String> contextChips;
  final MessageType type;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.contextChips = const [],
    this.type = MessageType.text,
  });
}

// Message type enum
enum MessageType { text, image, file, voice, location, chart }

// Chat history model
class ChatHistory {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;

  ChatHistory({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
  });
}
