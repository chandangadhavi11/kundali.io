import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatHistoryView extends StatefulWidget {
  const ChatHistoryView({super.key});

  @override
  State<ChatHistoryView> createState() => _ChatHistoryViewState();
}

class _ChatHistoryViewState extends State<ChatHistoryView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _itemAnimations;

  final List<Map<String, dynamic>> _chatHistory = [
    {
      'type': 'ai',
      'title': 'Career Guidance',
      'lastMessage': 'Based on your chart, the next 3 months...',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'unread': false,
    },
    {
      'type': 'astrologer',
      'name': 'Dr. Rajesh Sharma',
      'title': 'Marriage Consultation',
      'lastMessage': 'The planetary positions suggest...',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'unread': true,
    },
    {
      'type': 'ai',
      'title': 'Health Analysis',
      'lastMessage': 'Your moon sign indicates...',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'unread': false,
    },
    {
      'type': 'astrologer',
      'name': 'Priya Mehta',
      'title': 'Tarot Reading',
      'lastMessage': 'The cards reveal interesting insights...',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      'unread': false,
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _itemAnimations = List.generate(
      10,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return _chatHistory.isEmpty
        ? _buildEmptyState(isDarkMode)
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _chatHistory.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _itemAnimations[index % 10],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    20 * (1 - _itemAnimations[index % 10].value),
                  ),
                  child: Opacity(
                    opacity: _itemAnimations[index % 10].value,
                    child: _buildHistoryItem(_chatHistory[index], isDarkMode),
                  ),
                );
              },
            );
          },
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
              color: const Color(0xFF00B894).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 40,
              color: Color(0xFF00B894),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No chat history',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your conversations will appear here',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> chat, bool isDarkMode) {
    final isAI = chat['type'] == 'ai';

    return Dismissible(
      key: Key(chat['title']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.red, size: 24),
      ),
      onDismissed: (direction) {
        setState(() {
          _chatHistory.remove(chat);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chat deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  _chatHistory.add(chat);
                });
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          // Open chat
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isDarkMode ? Colors.grey[900]?.withOpacity(0.7) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  chat['unread'] == true
                      ? const Color(0xFF00B894).withOpacity(0.3)
                      : (isDarkMode
                          ? Colors.grey[800]!.withOpacity(0.5)
                          : Colors.grey[200]!),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        isAI
                            ? [const Color(0xFF6C5CE7), const Color(0xFF8B7EFF)]
                            : [
                              const Color(0xFF00B894),
                              const Color(0xFF00CEC9),
                            ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAI ? Icons.auto_awesome_rounded : Icons.person_rounded,
                  color: Colors.white,
                  size: 24,
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
                            isAI ? 'AI Assistant' : chat['name'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDarkMode ? Colors.white : Colors.grey[900],
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(chat['timestamp']),
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                isDarkMode
                                    ? Colors.grey[500]
                                    : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      chat['title'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            chat['unread'] == true
                                ? FontWeight.w600
                                : FontWeight.w500,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chat['lastMessage'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // Unread indicator
              if (chat['unread'] == true)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00B894),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${time.day}/${time.month}/${time.year}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}


