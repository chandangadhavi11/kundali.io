import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/providers/kundli_provider.dart';
import '../../../shared/widgets/auth_required_dialog.dart';
import '../../../shared/models/chat_conversation.dart';

// Premium Cosmic Colors
class _CosmicColors {
  static const background = Color(0xFF0A0612);
  static const cardDark = Color(0xFF16101F);
  static const golden = Color(0xFFE8B931);
  static const goldenLight = Color(0xFFF5D563);
  static const textPrimary = Color(0xFFFAFAFA);
  static const textSecondary = Color(0xFF9CA3AF);
  static const accent = Color(0xFF6C5CE7);
  static const userBubble = Color(0xFF2D1F42);
  static const aiBubble = Color(0xFF16101F);
  static const success = Color(0xFF00B894);
  static const error = Color(0xFFFF6B6B);
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _entryController;
  late AnimationController _typingController;

  bool _isTyping = false;
  bool _showHistory = false;

  final List<Map<String, dynamic>> _quickActions = [
    {'label': 'My Kundli', 'icon': Icons.auto_awesome_rounded, 'action': 'kundli'},
    {'label': 'Today\'s Transit', 'icon': Icons.timeline_rounded, 'action': 'transit'},
    {'label': 'Partner Match', 'icon': Icons.favorite_rounded, 'action': 'match'},
  ];

  final List<String> _quickPrompts = [
    'What does my future hold?',
    'When will I get married?',
    'Career guidance needed',
    'Health concerns',
    'Lucky periods ahead',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeKundaliContext();
  }

  void _initializeAnimations() {
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _messageController.addListener(() {
      final hasText = _messageController.text.isNotEmpty;
      if (hasText != _isTyping) {
        setState(() => _isTyping = hasText);
      }
    });
  }

  void _initializeKundaliContext() {
    // Set up Kundali context for personalized responses
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final kundliProvider = context.read<KundliProvider>();
      final chatProvider = context.read<ChatProvider>();
      
      if (kundliProvider.primaryKundali != null) {
        chatProvider.setActiveKundali(kundliProvider.primaryKundali);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _entryController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      await AuthRequiredDialog.show(
        context,
        feature: 'AI Astrologer',
        description: 'Sign in to get personalized astrological guidance.',
      );
      return;
    }

    final chatProvider = context.read<ChatProvider>();
    final message = _messageController.text;
    _messageController.clear();
    
    await chatProvider.sendMessage(message);
    _scrollToBottom();
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

  void _handleQuickAction(String action) async {
    final chatProvider = context.read<ChatProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (!authProvider.isAuthenticated) {
      await AuthRequiredDialog.show(
        context,
        feature: 'AI Astrologer',
        description: 'Sign in to use this feature.',
      );
      return;
    }

    switch (action) {
      case 'kundli':
        final result = await chatProvider.handleMyKundliAction();
        if (result == 'no_kundali') {
          _showCreateKundliDialog();
        }
        break;
      case 'transit':
        await chatProvider.handleTodaysTransitAction();
        break;
      case 'match':
        final result = await chatProvider.handlePartnerMatchAction();
        if (result == 'no_kundali') {
          _showCreateKundliDialog();
        } else if (result == 'compatibility') {
          // Optionally navigate to compatibility screen
        }
        break;
    }
    _scrollToBottom();
  }

  void _showCreateKundliDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _CosmicColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Create Your Kundli',
          style: TextStyle(color: _CosmicColors.textPrimary),
        ),
        content: Text(
          'To get personalized insights, please create your birth chart first.',
          style: TextStyle(color: _CosmicColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later', style: TextStyle(color: _CosmicColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/kundli-input');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _CosmicColors.golden,
              foregroundColor: _CosmicColors.background,
            ),
            child: const Text('Create Now'),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _CosmicColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.key_rounded, color: _CosmicColors.golden),
            const SizedBox(width: 8),
            Text('Gemini API Key', style: TextStyle(color: _CosmicColors.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your Google Gemini API key to enable AI-powered responses.',
              style: TextStyle(color: _CosmicColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: TextStyle(color: _CosmicColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'AIza...',
                hintStyle: TextStyle(color: _CosmicColors.textSecondary.withOpacity(0.5)),
                filled: true,
                fillColor: _CosmicColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _CosmicColors.golden.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _CosmicColors.golden.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _CosmicColors.golden),
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // Open link to get API key
              },
              child: Text(
                'Get your free API key from Google AI Studio',
                style: TextStyle(
                  color: _CosmicColors.golden,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: _CosmicColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final chatProvider = context.read<ChatProvider>();
                final success = await chatProvider.setApiKey(controller.text.trim());
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('API key saved successfully!'),
                      backgroundColor: _CosmicColors.success,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _CosmicColors.golden,
              foregroundColor: _CosmicColors.background,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        return Scaffold(
          backgroundColor: _CosmicColors.background,
          body: Stack(
            children: [
              // Cosmic background
              _buildCosmicBackground(),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // Premium Header
                    _buildPremiumHeader(chatProvider),

                    // Messages area
                    Expanded(child: _buildMessagesArea(chatProvider)),

                    // Quick actions (only when few messages)
                    if (chatProvider.messages.length <= 1 && !chatProvider.isAiTyping) 
                      _buildQuickActions(),

                    // Quick prompts (only when few messages)
                    if (chatProvider.messages.length <= 1 && !chatProvider.isAiTyping) 
                      _buildQuickPrompts(),

                    // Free questions remaining indicator
                    if (!chatProvider.isPremium && chatProvider.freeQuestionsRemaining > 0)
                      _buildFreeQuestionsIndicator(chatProvider),

                    // Input area
                    _buildInputArea(chatProvider),
                  ],
                ),
              ),
              
              // Conversation history drawer
              if (_showHistory) _buildHistoryDrawer(chatProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCosmicBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [
            _CosmicColors.accent.withOpacity(0.06),
            _CosmicColors.background,
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(ChatProvider chatProvider) {
    return FadeTransition(
      opacity: _entryController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _entryController,
          curve: Curves.easeOut,
        )),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Back button
              _buildGlassButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
              ),

              const SizedBox(width: 12),

              // AI Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _CosmicColors.golden,
                      _CosmicColors.goldenLight,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _CosmicColors.golden.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: _CosmicColors.background,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              // Title and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'AI Astrologer',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: _CosmicColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _CosmicColors.golden.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            chatProvider.hasApiKey ? 'PRO' : 'DEMO',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _CosmicColors.golden,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: chatProvider.hasApiKey 
                                ? _CosmicColors.success 
                                : _CosmicColors.golden,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          chatProvider.hasApiKey 
                              ? 'Online • Ready to assist'
                              : 'Demo mode • Add API key',
                          style: TextStyle(
                            fontSize: 12,
                            color: _CosmicColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // History button
              _buildGlassButton(
                icon: Icons.history_rounded,
                onTap: () => setState(() => _showHistory = !_showHistory),
              ),
              
              const SizedBox(width: 8),

              // More options
              _buildGlassButton(
                icon: Icons.more_vert_rounded,
                onTap: () => _showOptionsMenu(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: _CosmicColors.cardDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.key_rounded, color: _CosmicColors.golden),
              title: Text('Set API Key', style: TextStyle(color: _CosmicColors.textPrimary)),
              subtitle: Text(
                'Enable AI-powered responses',
                style: TextStyle(color: _CosmicColors.textSecondary, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                _showApiKeyDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.add_circle_outline, color: _CosmicColors.textPrimary),
              title: Text('New Conversation', style: TextStyle(color: _CosmicColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                context.read<ChatProvider>().startNewConversation();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: _CosmicColors.error),
              title: Text('Clear Chat', style: TextStyle(color: _CosmicColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                context.read<ChatProvider>().clearChat();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
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
            width: 40,
            height: 40,
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
              size: 20,
              color: _CosmicColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesArea(ChatProvider chatProvider) {
    final messages = chatProvider.messages;
    final itemCount = messages.length + (chatProvider.isAiTyping ? 1 : 0);
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == messages.length && chatProvider.isAiTyping) {
          return _buildTypingIndicator();
        }

        final message = messages[index];
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _buildMessageBubble(message),
        );
      },
    );
  }

  Widget _buildMessageBubble(message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // AI Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_CosmicColors.golden, _CosmicColors.goldenLight],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: _CosmicColors.background,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
          ],

          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? _CosmicColors.userBubble : _CosmicColors.aiBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: Border.all(
                  color: isUser
                      ? _CosmicColors.accent.withOpacity(0.2)
                      : _CosmicColors.golden.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isUser ? _CosmicColors.accent : _CosmicColors.golden)
                        .withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: _CosmicColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: _CosmicColors.textSecondary.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isUser) const SizedBox(width: 42),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_CosmicColors.golden, _CosmicColors.goldenLight],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: _CosmicColors.background,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _CosmicColors.aiBubble,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(
                color: _CosmicColors.golden.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: AnimatedBuilder(
              animation: _typingController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final value = ((_typingController.value + delay) % 1.0);
                    final opacity = 0.3 + 0.7 * (value < 0.5 ? value * 2 : 2 - value * 2);
                    return Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: _CosmicColors.golden.withOpacity(opacity),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: _quickActions.map((action) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _handleQuickAction(action['action']);
              },
              child: Container(
                margin: EdgeInsets.only(
                  right: action != _quickActions.last ? 10 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _CosmicColors.golden.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _CosmicColors.golden.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        color: _CosmicColors.golden,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _CosmicColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickPrompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _messageController.text = _quickPrompts[index];
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _quickPrompts[index],
                style: TextStyle(
                  fontSize: 13,
                  color: _CosmicColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFreeQuestionsIndicator(ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.stars_rounded,
            size: 14,
            color: _CosmicColors.golden,
          ),
          const SizedBox(width: 6),
          Text(
            '${chatProvider.freeQuestionsRemaining} free questions remaining today',
            style: TextStyle(
              fontSize: 12,
              color: _CosmicColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ChatProvider chatProvider) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Attachment button
              GestureDetector(
                onTap: () => HapticFeedback.lightImpact(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.attach_file_rounded,
                    color: _CosmicColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Input field
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isTyping
                          ? _CosmicColors.golden.withOpacity(0.3)
                          : Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    enabled: !chatProvider.isLoading,
                    style: TextStyle(
                      fontSize: 15,
                      color: _CosmicColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: chatProvider.canAskQuestion 
                          ? 'Type your message...'
                          : 'Daily limit reached',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: _CosmicColors.textSecondary.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Send button
              GestureDetector(
                onTap: (_isTyping && chatProvider.canAskQuestion && !chatProvider.isLoading) 
                    ? _sendMessage 
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: (_isTyping && chatProvider.canAskQuestion)
                        ? LinearGradient(
                            colors: [
                              _CosmicColors.golden,
                              _CosmicColors.goldenLight,
                            ],
                          )
                        : null,
                    color: (_isTyping && chatProvider.canAskQuestion) 
                        ? null 
                        : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: (_isTyping && chatProvider.canAskQuestion)
                        ? [
                            BoxShadow(
                              color: _CosmicColors.golden.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: chatProvider.isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              _CosmicColors.golden,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color: (_isTyping && chatProvider.canAskQuestion)
                              ? _CosmicColors.background
                              : _CosmicColors.textSecondary.withOpacity(0.5),
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryDrawer(ChatProvider chatProvider) {
    return GestureDetector(
      onTap: () => setState(() => _showHistory = false),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {}, // Prevent closing when tapping drawer
              child: Container(
                width: 300,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: _CosmicColors.cardDark,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.history_rounded, color: _CosmicColors.golden),
                            const SizedBox(width: 12),
                            Text(
                              'Chat History',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _CosmicColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(Icons.close, color: _CosmicColors.textSecondary),
                              onPressed: () => setState(() => _showHistory = false),
                            ),
                          ],
                        ),
                      ),
                      
                      // New chat button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            chatProvider.startNewConversation();
                            setState(() => _showHistory = false);
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('New Conversation'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _CosmicColors.golden,
                            foregroundColor: _CosmicColors.background,
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Conversations list
                      Expanded(
                        child: chatProvider.allConversations.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 48,
                                      color: _CosmicColors.textSecondary.withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No conversations yet',
                                      style: TextStyle(
                                        color: _CosmicColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                itemCount: chatProvider.allConversations.length,
                                itemBuilder: (context, index) {
                                  final conversation = chatProvider.allConversations[index];
                                  final isSelected = chatProvider.currentConversation?.id == conversation.id;
                                  
                                  return _buildConversationTile(
                                    conversation,
                                    isSelected,
                                    chatProvider,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTile(
    ChatConversation conversation,
    bool isSelected,
    ChatProvider chatProvider,
  ) {
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: _CosmicColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: _CosmicColors.cardDark,
            title: Text('Delete Conversation', style: TextStyle(color: _CosmicColors.textPrimary)),
            content: Text(
              'Are you sure you want to delete this conversation?',
              style: TextStyle(color: _CosmicColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: TextStyle(color: _CosmicColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: _CosmicColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) {
        chatProvider.deleteConversation(conversation.id);
      },
      child: GestureDetector(
        onTap: () {
          chatProvider.loadConversation(conversation.id);
          setState(() => _showHistory = false);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected 
                ? _CosmicColors.golden.withOpacity(0.1) 
                : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? _CosmicColors.golden.withOpacity(0.3)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (conversation.isPinned)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.push_pin,
                        size: 14,
                        color: _CosmicColors.golden,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      conversation.title,
                      style: TextStyle(
                        color: _CosmicColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDate(conversation.updatedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: _CosmicColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                conversation.lastMessagePreview,
                style: TextStyle(
                  fontSize: 12,
                  color: _CosmicColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);
    
    if (messageDate == today) {
      return _formatTime(date);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
