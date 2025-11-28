import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class AiAssistantView extends StatefulWidget {
  const AiAssistantView({super.key});

  @override
  State<AiAssistantView> createState() => _AiAssistantViewState();
}

class _AiAssistantViewState extends State<AiAssistantView>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonAnimation;

  bool _isTyping = false;
  final List<ChatMessage> _messages = [];
  final List<String> _selectedContextChips = [];

  final List<String> _contextChips = [
    'My Kundli',
    'Today\'s Transit',
    'Partner Match',
    'Career',
    'Health',
  ];

  final List<String> _quickPrompts = [
    'What does my future hold?',
    'When will I get married?',
    'Career guidance needed',
    'Health concerns',
    'Financial advice',
  ];

  @override
  void initState() {
    super.initState();

    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _sendButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.elasticOut),
    );

    _messageController.addListener(() {
      if (_messageController.text.isNotEmpty && !_isTyping) {
        _sendButtonController.forward();
        setState(() => _isTyping = true);
      } else if (_messageController.text.isEmpty && _isTyping) {
        _sendButtonController.reverse();
        setState(() => _isTyping = false);
      }
    });

    // Add welcome message
    _messages.add(
      ChatMessage(
        text:
            'Hello! I\'m your AI Astrology Assistant. How can I help you today?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = ChatMessage(
      text: _messageController.text,
      isUser: true,
      timestamp: DateTime.now(),
      contextChips: List.from(_selectedContextChips),
    );

    setState(() {
      _messages.add(message);
      _selectedContextChips.clear();
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text:
                  'Based on your birth chart and current planetary positions, I can see interesting developments ahead...',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Context chips
        if (_messages.length == 1) _buildContextChips(isDarkMode),

        // Messages
        Expanded(
          child:
              _messages.isEmpty
                  ? _buildEmptyState(isDarkMode)
                  : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessage(_messages[index], isDarkMode);
                    },
                  ),
        ),

        // Quick prompts
        if (_messages.length == 1) _buildQuickPrompts(isDarkMode),

        // Input area
        _buildInputArea(isDarkMode),
      ],
    );
  }

  Widget _buildContextChips(bool isDarkMode) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _contextChips.length,
        itemBuilder: (context, index) {
          final chip = _contextChips[index];
          final isSelected = _selectedContextChips.contains(chip);

          return Padding(
            padding: EdgeInsets.only(
              right: index < _contextChips.length - 1 ? 8 : 0,
            ),
            child: FilterChip(
              label: Text(chip),
              selected: isSelected,
              onSelected: (selected) {
                HapticFeedback.lightImpact();
                setState(() {
                  if (selected) {
                    _selectedContextChips.add(chip);
                  } else {
                    _selectedContextChips.remove(chip);
                  }
                });
              },
              backgroundColor:
                  isDarkMode
                      ? Colors.grey[800]?.withOpacity(0.5)
                      : Colors.grey[100],
              selectedColor: const Color(0xFF6C5CE7).withOpacity(0.2),
              checkmarkColor: const Color(0xFF6C5CE7),
              labelStyle: TextStyle(
                fontSize: 12,
                color:
                    isSelected
                        ? const Color(0xFF6C5CE7)
                        : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color:
                      isSelected
                          ? const Color(0xFF6C5CE7).withOpacity(0.3)
                          : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C5CE7).withOpacity(0.2),
                  const Color(0xFF8B7EFF).withOpacity(0.2),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_rounded,
              size: 40,
              color: Color(0xFF6C5CE7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ask me anything',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'I can help with your astrological queries',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message, bool isDarkMode) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 16,
        left: isUser ? 40 : 0,
        right: isUser ? 0 : 40,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF8B7EFF)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.contextChips.isNotEmpty) ...[
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children:
                        message.contextChips.map((chip) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C5CE7).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              chip,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6C5CE7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 4),
                ],
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient:
                        isUser
                            ? const LinearGradient(
                              colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
                            )
                            : null,
                    color:
                        !isUser
                            ? (isDarkMode
                                ? Colors.grey[850]?.withOpacity(0.7)
                                : Colors.white)
                            : null,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isUser ? 16 : 4),
                      topRight: Radius.circular(isUser ? 4 : 16),
                      bottomLeft: const Radius.circular(16),
                      bottomRight: const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isUser ? const Color(0xFF00B894) : Colors.black)
                            .withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isUser
                              ? Colors.white
                              : (isDarkMode ? Colors.white : Colors.grey[900]),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isUser) ...[
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                        },
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color:
                              isDarkMode ? Colors.grey[600] : Colors.grey[400],
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                        },
                        icon: Icon(
                          Icons.share_rounded,
                          size: 16,
                          color:
                              isDarkMode ? Colors.grey[600] : Colors.grey[400],
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDarkMode ? Colors.grey[600] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFFF6B94).withOpacity(0.2),
              child: const Icon(
                Icons.person_rounded,
                size: 20,
                color: Color(0xFFFF6B94),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickPrompts(bool isDarkMode) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickPrompts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < _quickPrompts.length - 1 ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _messageController.text = _quickPrompts[index];
                _focusNode.requestFocus();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? Colors.grey[850]?.withOpacity(0.5)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00B894).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _quickPrompts[index],
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Attach button
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showAttachmentOptions();
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFF6C5CE7),
                  size: 20,
                ),
              ),
            ),

            // Input field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? Colors.grey[850]?.withOpacity(0.5)
                          : Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask your question...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // Send button
            AnimatedBuilder(
              animation: _sendButtonAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + 0.2 * _sendButtonAnimation.value,
                  child: Transform.rotate(
                    angle: _sendButtonAnimation.value * 2 * math.pi,
                    child: IconButton(
                      onPressed: _isTyping ? _sendMessage : null,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient:
                              _isTyping
                                  ? const LinearGradient(
                                    colors: [
                                      Color(0xFF00B894),
                                      Color(0xFF00CEC9),
                                    ],
                                  )
                                  : null,
                          color:
                              !_isTyping
                                  ? (isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[300])
                                  : null,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.send_rounded,
                          color:
                              _isTyping
                                  ? Colors.white
                                  : (isDarkMode
                                      ? Colors.grey[600]
                                      : Colors.grey[500]),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAttachmentOption(
                'Attach Kundli',
                Icons.stars_rounded,
                const Color(0xFF6C5CE7),
                isDarkMode,
              ),
              const SizedBox(height: 12),
              _buildAttachmentOption(
                'Partner Chart',
                Icons.people_rounded,
                const Color(0xFFFF6B94),
                isDarkMode,
              ),
              const SizedBox(height: 12),
              _buildAttachmentOption(
                'Birth Details',
                Icons.cake_rounded,
                const Color(0xFF00B894),
                isDarkMode,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption(
    String title,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isDarkMode ? Colors.grey[850]?.withOpacity(0.5) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.grey[900],
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String> contextChips;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.contextChips = const [],
  });
}
