import 'package:flutter/foundation.dart';
import '../../shared/models/chat_message.dart';
import '../../shared/models/chat_conversation.dart';
import '../../shared/models/kundali_data_model.dart';
import '../constants/app_constants.dart';
import '../services/gemini_service.dart';
import '../services/chat_storage_service.dart';

/// Provider for managing AI Astrologer chat functionality
class ChatProvider extends ChangeNotifier {
  // Services
  final GeminiService _geminiService = GeminiService.instance;
  final ChatStorageService _storageService = ChatStorageService.instance;
  
  // Current conversation state
  final List<ChatMessage> _messages = [];
  ChatConversation? _currentConversation;
  List<ChatConversation> _allConversations = [];
  
  // UI State
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isAiTyping = false;
  String _error = '';
  String _streamingResponse = '';
  
  // Premium and limits
  int _freeQuestionsRemaining = AppConstants.freeAiQuestionsPerDay;
  bool _isPremium = false;
  DateTime? _lastQuestionDate;
  
  // Kundali context
  KundaliData? _activeKundali;

  // Getters
  List<ChatMessage> get messages => _messages;
  ChatConversation? get currentConversation => _currentConversation;
  List<ChatConversation> get allConversations => _allConversations;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isAiTyping => _isAiTyping;
  String get error => _error;
  String get streamingResponse => _streamingResponse;
  int get freeQuestionsRemaining => _freeQuestionsRemaining;
  bool get isPremium => _isPremium;
  bool get canAskQuestion => _isPremium || _freeQuestionsRemaining > 0;
  bool get hasApiKey => _geminiService.isInitialized;
  KundaliData? get activeKundali => _activeKundali;

  ChatProvider() {
    _initialize();
  }

  /// Initialize the chat provider
  Future<void> _initialize() async {
    try {
      // Initialize storage service
      await _storageService.initialize();
      
      // Try to load saved API key and initialize Gemini
      final apiKey = await _storageService.getApiKey();
      if (apiKey != null && apiKey.isNotEmpty) {
        await _geminiService.initialize(apiKey);
      }
      
      // Load all conversations
      _allConversations = _storageService.getAllConversations();
      
      // Check and reset daily question limit
      await _checkDailyReset();
      
      // Initialize with welcome message
      _initializeChat();
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing ChatProvider: $e');
      _error = 'Failed to initialize chat service';
      _isInitialized = true; // Still mark as initialized to show UI
      notifyListeners();
    }
  }

  /// Initialize chat with welcome message
  void _initializeChat() {
    _messages.clear();
    _messages.add(
      ChatMessage(
        id: '0',
        text: 'Namaste! I am your AI Astrologer. Ask me anything about your horoscope, birth chart, or life predictions. How can I guide you today?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Check and reset daily question limit
  Future<void> _checkDailyReset() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastQuestionDate == null || _lastQuestionDate!.isBefore(today)) {
      _freeQuestionsRemaining = AppConstants.freeAiQuestionsPerDay;
      _lastQuestionDate = today;
    }
  }

  /// Set the API key for Gemini
  Future<bool> setApiKey(String apiKey) async {
    try {
      final success = await _geminiService.initialize(apiKey);
      if (success) {
        await _storageService.saveApiKey(apiKey);
        _error = '';
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Invalid API key';
      notifyListeners();
      return false;
    }
  }

  /// Set the active Kundali for personalized responses
  void setActiveKundali(KundaliData? kundali) {
    _activeKundali = kundali;
    // Restart session with new context
    _geminiService.clearSession();
    if (kundali != null) {
      _geminiService.startNewSession(kundali);
    }
    notifyListeners();
  }

  /// Start a new conversation
  Future<void> startNewConversation({
    String title = 'New Conversation',
    ConversationType type = ConversationType.general,
  }) async {
    // Save current conversation if it has messages
    if (_currentConversation != null && _messages.length > 1) {
      await _saveCurrentConversation();
    }
    
    // Create new conversation
    _currentConversation = await _storageService.createConversation(
      title: title,
      kundaliId: _activeKundali?.id,
      type: type,
    );
    
    // Reset messages
    _initializeChat();
    
    // Reset Gemini session
    _geminiService.clearSession();
    if (_activeKundali != null) {
      _geminiService.startNewSession(_activeKundali);
    }
    
    // Refresh conversations list
    _allConversations = _storageService.getAllConversations();
    
    notifyListeners();
  }

  /// Load an existing conversation
  Future<void> loadConversation(String conversationId) async {
    final conversation = _storageService.getConversation(conversationId);
    if (conversation == null) return;
    
    // Save current conversation first
    if (_currentConversation != null && 
        _currentConversation!.id != conversationId &&
        _messages.length > 1) {
      await _saveCurrentConversation();
    }
    
    _currentConversation = conversation;
    
    // Load messages
    _messages.clear();
    for (final msg in conversation.messages) {
      _messages.add(msg.toChatMessage());
    }
    
    // If no messages, add welcome
    if (_messages.isEmpty) {
      _initializeChat();
    }
    
    // Reset Gemini session with context
    _geminiService.clearSession();
    
    notifyListeners();
  }

  /// Save current conversation to storage
  Future<void> _saveCurrentConversation() async {
    if (_currentConversation == null) return;
    
    // Update messages in conversation
    _currentConversation!.messages.clear();
    for (final msg in _messages) {
      _currentConversation!.messages.add(
        ChatMessageHive.fromChatMessage(msg),
      );
    }
    
    await _storageService.saveConversation(_currentConversation!);
    _allConversations = _storageService.getAllConversations();
  }

  /// Send a message to the AI
  Future<void> sendMessage(
    String text, {
    String? userId,
    Map<String, dynamic>? userBirthData,
  }) async {
    if (text.trim().isEmpty) return;
    
    if (!canAskQuestion) {
      _error = 'You have reached your daily limit of free questions. Upgrade to Premium for unlimited access.';
      notifyListeners();
      return;
    }

    // Create new conversation if needed
    _currentConversation ??= await _storageService.createConversation(
      kundaliId: _activeKundali?.id,
    );

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    
    _isLoading = true;
    _isAiTyping = true;
    _error = '';
    _streamingResponse = '';
    notifyListeners();

    try {
      // Check if Gemini is initialized
      if (!_geminiService.isInitialized) {
        // Fall back to mock response if no API key
        await _generateMockResponse(text, userBirthData);
      } else {
        // Use Gemini for real AI response
        await _generateGeminiResponse(text);
      }

      // Decrement free questions if not premium
      if (!_isPremium) {
        _freeQuestionsRemaining--;
        _lastQuestionDate = DateTime.now();
      }
      
      // Save conversation
      await _saveCurrentConversation();
      
    } catch (e) {
      debugPrint('Error getting AI response: $e');
      _error = e.toString().replaceAll('Exception: ', '');

      // Add error message to chat
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: 'I apologize, but I encountered an error. Please try asking your question again.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isLoading = false;
      _isAiTyping = false;
      notifyListeners();
    }
  }

  /// Generate response using Gemini AI
  Future<void> _generateGeminiResponse(String text) async {
    try {
      final response = await _geminiService.sendMessage(
        text,
        kundali: _activeKundali,
      );
      
      final aiMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMessage);
    } catch (e) {
      rethrow;
    }
  }

  /// Generate mock response (fallback when no API key)
  Future<void> _generateMockResponse(
    String question,
    Map<String, dynamic>? userBirthData,
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    
    String response = _generateMockResponseText(question, userBirthData);

    final aiMessage = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(aiMessage);
  }

  String _generateMockResponseText(
    String question,
    Map<String, dynamic>? userBirthData,
  ) {
    final lowerQuestion = question.toLowerCase();

    if (lowerQuestion.contains('career')) {
      return 'Based on your planetary positions, your career prospects look promising. The current Jupiter transit through your 10th house indicates professional growth and recognition. Focus on networking and skill development during this period. Your hard work will bear fruit in the coming months.\n\n💡 **Tip:** To get personalized predictions, please add your Gemini API key in settings.';
    } else if (lowerQuestion.contains('love') ||
        lowerQuestion.contains('marriage')) {
      return 'Venus, the planet of love, is favorably positioned in your chart. For singles, the next 3 months bring excellent opportunities to meet someone special. For those in relationships, this is a time to deepen your bond. Communication and understanding will be key to harmony.\n\n💡 **Tip:** To get personalized predictions, please add your Gemini API key in settings.';
    } else if (lowerQuestion.contains('health')) {
      return 'Your health sector shows mixed influences. While your overall vitality is good, pay attention to stress management. Regular exercise, meditation, and a balanced diet will help maintain optimal health. Avoid overexertion during the afternoon hours.\n\n⚠️ Always consult a medical professional for health concerns.\n\n💡 **Tip:** To get personalized predictions, please add your Gemini API key in settings.';
    } else if (lowerQuestion.contains('money') ||
        lowerQuestion.contains('finance')) {
      return 'Financial prospects are improving with Jupiter\'s beneficial aspect on your 2nd house of wealth. This is a good time for investments, especially in long-term assets. However, avoid impulsive purchases and maintain a budget for better financial stability.\n\n💡 **Tip:** To get personalized predictions, please add your Gemini API key in settings.';
    } else if (lowerQuestion.contains('lucky')) {
      return 'Your lucky number today is 7, and your lucky color is blue. The most auspicious time for important decisions is between 11 AM and 1 PM. Wearing blue or keeping a blue accessory can enhance positive energies around you.\n\n💡 **Tip:** To get personalized predictions, please add your Gemini API key in settings.';
    } else if (lowerQuestion.contains('transit') || lowerQuestion.contains('today')) {
      return 'Today\'s planetary transits indicate a favorable day for communication and social interactions. Mercury\'s positive aspect enhances your ability to express yourself clearly. The Moon\'s position supports emotional balance. This is a good day for important conversations and meetings.\n\n💡 **Tip:** To get personalized predictions, please add your Gemini API key in settings.';
    } else {
      return 'Based on your birth chart and current planetary transits, I see a period of transformation ahead. The cosmic energies are aligning to bring new opportunities in various aspects of your life. Stay positive and trust your intuition as you navigate through this phase. Remember, the stars guide but don\'t compel - your actions shape your destiny.\n\n💡 **Tip:** To get personalized predictions, please add your Gemini API key in settings.';
    }
  }

  /// Handle quick action: My Kundli
  Future<String?> handleMyKundliAction() async {
    if (_activeKundali == null) {
      return 'no_kundali'; // Signal to navigate to kundli creation
    }
    
    // Generate a summary of the user's kundali
    final prompt = '''
Please provide a brief overview of my birth chart, including:
1. Key personality traits based on my Ascendant and Moon sign
2. Current planetary period (Mahadasha) and its effects
3. One key strength and one area to focus on
Keep it concise but insightful.
''';
    
    await sendMessage(prompt);
    return null;
  }

  /// Handle quick action: Today's Transit
  Future<void> handleTodaysTransitAction() async {
    String prompt;
    
    if (_activeKundali != null) {
      prompt = '''
Analyze today's planetary transits specifically for my birth chart. Include:
1. Key transits affecting my chart today
2. Which areas of life (houses) are most activated
3. Favorable and challenging periods during today
4. One practical recommendation for today
''';
    } else {
      prompt = '''
What are the important planetary transits today and how do they generally affect people? Include:
1. Current major planetary positions
2. General effects of today's Moon position
3. Any notable aspects between planets today
4. General recommendations for today
''';
    }
    
    await sendMessage(prompt);
  }

  /// Handle quick action: Partner Match
  Future<String?> handlePartnerMatchAction() async {
    if (_activeKundali == null) {
      return 'no_kundali'; // Signal to navigate to kundli creation
    }
    
    // Navigate to compatibility screen or start compatibility chat
    final prompt = '''
I'm interested in understanding compatibility matching (Kundali Milan). Based on my chart:
1. What should I look for in a partner's chart for good compatibility?
2. Which planetary positions in a partner's chart would complement mine?
3. What are the key Guna factors for me to consider?
''';
    
    await sendMessage(prompt);
    return 'compatibility'; // Signal to potentially navigate to compatibility screen
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    await _storageService.deleteConversation(conversationId);
    
    // If deleting current conversation, start new one
    if (_currentConversation?.id == conversationId) {
      _currentConversation = null;
      _initializeChat();
    }
    
    _allConversations = _storageService.getAllConversations();
    notifyListeners();
  }

  /// Toggle pin status of a conversation
  Future<void> togglePinConversation(String conversationId) async {
    await _storageService.togglePinConversation(conversationId);
    _allConversations = _storageService.getAllConversations();
    notifyListeners();
  }

  /// Search conversations
  List<ChatConversation> searchConversations(String query) {
    return _storageService.searchConversations(query);
  }

  /// Clear current chat
  void clearChat() {
    _messages.clear();
    _currentConversation = null;
    _geminiService.clearSession();
    _initializeChat();
    notifyListeners();
  }

  /// Set premium status
  void setPremiumStatus(bool isPremium) {
    _isPremium = isPremium;
    if (isPremium) {
      _freeQuestionsRemaining = -1; // Unlimited
    }
    notifyListeners();
  }

  /// Reset daily questions
  void resetDailyQuestions() {
    if (!_isPremium) {
      _freeQuestionsRemaining = AppConstants.freeAiQuestionsPerDay;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  /// Refresh conversations list
  void refreshConversations() {
    _allConversations = _storageService.getAllConversations();
    notifyListeners();
  }

  @override
  void dispose() {
    _saveCurrentConversation();
    super.dispose();
  }
}
