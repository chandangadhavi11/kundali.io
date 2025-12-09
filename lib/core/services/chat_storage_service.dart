import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/chat_conversation.dart';
import '../../shared/models/chat_message.dart';

/// Service for persisting chat conversations locally using Hive
class ChatStorageService {
  static ChatStorageService? _instance;
  static const String _boxName = 'chat_conversations';
  static const String _settingsKey = 'chat_settings';
  static const String _apiKeyKey = 'gemini_api_key';
  
  Box<ChatConversation>? _conversationsBox;
  bool _isInitialized = false;
  
  ChatStorageService._();
  
  static ChatStorageService get instance {
    _instance ??= ChatStorageService._();
    return _instance!;
  }
  
  /// Initialize the storage service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Register Hive adapters if not already registered
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(ChatConversationAdapter());
      }
      if (!Hive.isAdapterRegistered(11)) {
        Hive.registerAdapter(ConversationTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(ChatMessageHiveAdapter());
      }
      if (!Hive.isAdapterRegistered(13)) {
        Hive.registerAdapter(MessageStatusAdapter());
      }
      
      // Open the conversations box
      _conversationsBox = await Hive.openBox<ChatConversation>(_boxName);
      _isInitialized = true;
      
      debugPrint('ChatStorageService initialized with ${_conversationsBox!.length} conversations');
    } catch (e) {
      debugPrint('Error initializing ChatStorageService: $e');
      rethrow;
    }
  }
  
  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
  
  /// Get all conversations sorted by updatedAt (most recent first)
  List<ChatConversation> getAllConversations() {
    if (_conversationsBox == null) return [];
    
    final conversations = _conversationsBox!.values.toList();
    
    // Sort by pinned first, then by updatedAt
    conversations.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    
    return conversations;
  }
  
  /// Get conversations by type
  List<ChatConversation> getConversationsByType(ConversationType type) {
    return getAllConversations().where((c) => c.type == type).toList();
  }
  
  /// Get a specific conversation by ID
  ChatConversation? getConversation(String id) {
    if (_conversationsBox == null) return null;
    return _conversationsBox!.get(id);
  }
  
  /// Create a new conversation
  Future<ChatConversation> createConversation({
    String title = 'New Conversation',
    String? kundaliId,
    ConversationType type = ConversationType.general,
  }) async {
    final conversation = ChatConversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      kundaliId: kundaliId,
      type: type,
    );
    
    await _conversationsBox?.put(conversation.id, conversation);
    return conversation;
  }
  
  /// Save/update a conversation
  Future<void> saveConversation(ChatConversation conversation) async {
    await _conversationsBox?.put(conversation.id, conversation);
  }
  
  /// Add a message to a conversation
  Future<void> addMessageToConversation(
    String conversationId,
    ChatMessage message, {
    MessageStatus status = MessageStatus.sent,
  }) async {
    final conversation = getConversation(conversationId);
    if (conversation == null) return;
    
    final hiveMessage = ChatMessageHive.fromChatMessage(message, status: status);
    conversation.addMessage(hiveMessage);
    await saveConversation(conversation);
  }
  
  /// Update conversation title
  Future<void> updateConversationTitle(String conversationId, String newTitle) async {
    final conversation = getConversation(conversationId);
    if (conversation == null) return;
    
    conversation.title = newTitle;
    conversation.updatedAt = DateTime.now();
    await saveConversation(conversation);
  }
  
  /// Toggle pin status
  Future<void> togglePinConversation(String conversationId) async {
    final conversation = getConversation(conversationId);
    if (conversation == null) return;
    
    conversation.isPinned = !conversation.isPinned;
    conversation.updatedAt = DateTime.now();
    await saveConversation(conversation);
  }
  
  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    await _conversationsBox?.delete(conversationId);
  }
  
  /// Delete all conversations
  Future<void> deleteAllConversations() async {
    await _conversationsBox?.clear();
  }
  
  /// Search conversations by title or message content
  List<ChatConversation> searchConversations(String query) {
    if (query.isEmpty) return getAllConversations();
    
    final lowerQuery = query.toLowerCase();
    return getAllConversations().where((conversation) {
      // Search in title
      if (conversation.title.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      
      // Search in messages
      for (final message in conversation.messages) {
        if (message.text.toLowerCase().contains(lowerQuery)) {
          return true;
        }
      }
      
      return false;
    }).toList();
  }
  
  /// Get conversation statistics
  Map<String, dynamic> getStatistics() {
    final conversations = getAllConversations();
    int totalMessages = 0;
    int userMessages = 0;
    int aiMessages = 0;
    
    for (final conversation in conversations) {
      totalMessages += conversation.messages.length;
      for (final msg in conversation.messages) {
        if (msg.isUser) {
          userMessages++;
        } else {
          aiMessages++;
        }
      }
    }
    
    return {
      'totalConversations': conversations.length,
      'totalMessages': totalMessages,
      'userMessages': userMessages,
      'aiMessages': aiMessages,
      'pinnedConversations': conversations.where((c) => c.isPinned).length,
    };
  }
  
  // ============ Settings & API Key Management ============
  
  /// Save Gemini API key securely
  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    // In production, use flutter_secure_storage instead
    await prefs.setString(_apiKeyKey, apiKey);
  }
  
  /// Get saved API key
  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }
  
  /// Delete API key
  Future<void> deleteApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyKey);
  }
  
  /// Check if API key is saved
  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }
  
  // ============ Chat Settings ============
  
  /// Save chat settings
  Future<void> saveChatSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert to string values for storage
    for (final entry in settings.entries) {
      final key = '${_settingsKey}_${entry.key}';
      if (entry.value is bool) {
        await prefs.setBool(key, entry.value);
      } else if (entry.value is int) {
        await prefs.setInt(key, entry.value);
      } else if (entry.value is String) {
        await prefs.setString(key, entry.value);
      }
    }
  }
  
  /// Get chat settings
  Future<Map<String, dynamic>> getChatSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'streamingEnabled': prefs.getBool('${_settingsKey}_streamingEnabled') ?? true,
      'soundEnabled': prefs.getBool('${_settingsKey}_soundEnabled') ?? true,
      'hapticEnabled': prefs.getBool('${_settingsKey}_hapticEnabled') ?? true,
      'autoSaveEnabled': prefs.getBool('${_settingsKey}_autoSaveEnabled') ?? true,
    };
  }
  
  /// Export all conversations as JSON
  Future<String> exportConversations() async {
    final conversations = getAllConversations();
    final exportData = {
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0',
      'conversations': conversations.map((c) => c.toJson()).toList(),
    };
    
    // Convert to JSON string
    return exportData.toString();
  }
  
  /// Close the storage
  Future<void> close() async {
    await _conversationsBox?.close();
    _isInitialized = false;
  }
  
  /// Dispose of the service
  void dispose() {
    close();
    _instance = null;
  }
}



