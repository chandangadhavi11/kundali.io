import 'package:hive/hive.dart';
import 'chat_message.dart';

part 'chat_conversation.g.dart';

/// Represents a chat conversation session with the AI Astrologer
@HiveType(typeId: 10)
class ChatConversation extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  final List<ChatMessageHive> messages;
  
  @HiveField(3)
  final DateTime createdAt;
  
  @HiveField(4)
  DateTime updatedAt;
  
  @HiveField(5)
  String? kundaliId; // Associated Kundali for context
  
  @HiveField(6)
  bool isPinned;
  
  @HiveField(7)
  ConversationType type;
  
  ChatConversation({
    required this.id,
    required this.title,
    List<ChatMessageHive>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.kundaliId,
    this.isPinned = false,
    this.type = ConversationType.general,
  }) : messages = messages ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();
  
  /// Add a message to the conversation
  void addMessage(ChatMessageHive message) {
    messages.add(message);
    updatedAt = DateTime.now();
    
    // Auto-generate title from first user message if title is default
    if (title == 'New Conversation' && message.isUser && messages.length <= 2) {
      title = _generateTitle(message.text);
    }
  }
  
  /// Generate a title from the message text
  String _generateTitle(String text) {
    // Take first 30 characters or until end of first sentence
    final cleanText = text.trim();
    if (cleanText.length <= 35) return cleanText;
    
    // Find a good breaking point
    final punctuationIndex = cleanText.indexOf(RegExp(r'[.?!]'));
    if (punctuationIndex > 0 && punctuationIndex <= 35) {
      return cleanText.substring(0, punctuationIndex + 1);
    }
    
    // Find last space before 35 chars
    final lastSpace = cleanText.lastIndexOf(' ', 35);
    if (lastSpace > 20) {
      return '${cleanText.substring(0, lastSpace)}...';
    }
    
    return '${cleanText.substring(0, 32)}...';
  }
  
  /// Get the last message preview
  String get lastMessagePreview {
    if (messages.isEmpty) return 'No messages yet';
    final lastMsg = messages.last;
    final text = lastMsg.text;
    return text.length > 50 ? '${text.substring(0, 47)}...' : text;
  }
  
  /// Get message count
  int get messageCount => messages.length;
  
  /// Convert to JSON for export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'kundaliId': kundaliId,
      'isPinned': isPinned,
      'type': type.name,
    };
  }
  
  /// Create from JSON
  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      title: json['title'],
      messages: (json['messages'] as List?)
          ?.map((m) => ChatMessageHive.fromMap(m))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      kundaliId: json['kundaliId'],
      isPinned: json['isPinned'] ?? false,
      type: ConversationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ConversationType.general,
      ),
    );
  }
  
  /// Create a copy with modifications
  ChatConversation copyWith({
    String? id,
    String? title,
    List<ChatMessageHive>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? kundaliId,
    bool? isPinned,
    ConversationType? type,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? List.from(this.messages),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      kundaliId: kundaliId ?? this.kundaliId,
      isPinned: isPinned ?? this.isPinned,
      type: type ?? this.type,
    );
  }
}

/// Types of conversations
@HiveType(typeId: 11)
enum ConversationType {
  @HiveField(0)
  general,
  
  @HiveField(1)
  kundaliAnalysis,
  
  @HiveField(2)
  transitAnalysis,
  
  @HiveField(3)
  compatibility,
  
  @HiveField(4)
  prediction,
  
  @HiveField(5)
  remedy,
}

/// Extended ChatMessage for Hive storage
@HiveType(typeId: 12)
class ChatMessageHive extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String text;
  
  @HiveField(2)
  final bool isUser;
  
  @HiveField(3)
  final DateTime timestamp;
  
  @HiveField(4)
  final String? attachmentUrl;
  
  @HiveField(5)
  final String? attachmentType;
  
  @HiveField(6)
  final MessageStatus status;
  
  ChatMessageHive({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.attachmentUrl,
    this.attachmentType,
    this.status = MessageStatus.sent,
  });
  
  /// Convert to the simple ChatMessage model
  ChatMessage toChatMessage() {
    return ChatMessage(
      id: id,
      text: text,
      isUser: isUser,
      timestamp: timestamp,
      attachmentUrl: attachmentUrl,
      attachmentType: attachmentType,
    );
  }
  
  /// Create from simple ChatMessage
  factory ChatMessageHive.fromChatMessage(ChatMessage msg, {MessageStatus status = MessageStatus.sent}) {
    return ChatMessageHive(
      id: msg.id,
      text: msg.text,
      isUser: msg.isUser,
      timestamp: msg.timestamp,
      attachmentUrl: msg.attachmentUrl,
      attachmentType: msg.attachmentType,
      status: status,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
      'status': status.name,
    };
  }
  
  factory ChatMessageHive.fromMap(Map<String, dynamic> map) {
    return ChatMessageHive(
      id: map['id'],
      text: map['text'],
      isUser: map['isUser'],
      timestamp: DateTime.parse(map['timestamp']),
      attachmentUrl: map['attachmentUrl'],
      attachmentType: map['attachmentType'],
      status: MessageStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => MessageStatus.sent,
      ),
    );
  }
}

/// Message delivery status
@HiveType(typeId: 13)
enum MessageStatus {
  @HiveField(0)
  sending,
  
  @HiveField(1)
  sent,
  
  @HiveField(2)
  delivered,
  
  @HiveField(3)
  error,
}

