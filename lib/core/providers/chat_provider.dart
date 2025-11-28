import 'package:flutter/foundation.dart';
import '../../shared/models/chat_message.dart';
import '../constants/app_constants.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _error = '';
  int _freeQuestionsRemaining = AppConstants.freeAiQuestionsPerDay;
  bool _isPremium = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get freeQuestionsRemaining => _freeQuestionsRemaining;
  bool get isPremium => _isPremium;
  bool get canAskQuestion => _isPremium || _freeQuestionsRemaining > 0;

  ChatProvider() {
    _initializeChat();
  }

  void _initializeChat() {
    _messages.add(
      ChatMessage(
        id: '0',
        text:
            'Namaste! I am your AI Astrologer. Ask me anything about your horoscope, birth chart, or life predictions. How can I guide you today?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> sendMessage(
    String text, {
    String? userId,
    Map<String, dynamic>? userBirthData,
  }) async {
    if (!canAskQuestion) {
      _error =
          'You have reached your daily limit of free questions. Upgrade to Premium for unlimited access.';
      notifyListeners();
      return;
    }

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // TODO: Implement actual AI API call
      await Future.delayed(const Duration(seconds: 2));

      // Generate mock AI response
      String response = _generateMockResponse(text, userBirthData);

      final aiMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMessage);

      // Decrement free questions if not premium
      if (!_isPremium) {
        _freeQuestionsRemaining--;
      }
    } catch (e) {
      _error = 'Failed to get response. Please try again.';

      // Add error message to chat
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              'I apologize, but I encountered an error. Please try asking your question again.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _generateMockResponse(
    String question,
    Map<String, dynamic>? userBirthData,
  ) {
    final lowerQuestion = question.toLowerCase();

    if (lowerQuestion.contains('career')) {
      return 'Based on your planetary positions, your career prospects look promising. The current Jupiter transit through your 10th house indicates professional growth and recognition. Focus on networking and skill development during this period. Your hard work will bear fruit in the coming months.';
    } else if (lowerQuestion.contains('love') ||
        lowerQuestion.contains('marriage')) {
      return 'Venus, the planet of love, is favorably positioned in your chart. For singles, the next 3 months bring excellent opportunities to meet someone special. For those in relationships, this is a time to deepen your bond. Communication and understanding will be key to harmony.';
    } else if (lowerQuestion.contains('health')) {
      return 'Your health sector shows mixed influences. While your overall vitality is good, pay attention to stress management. Regular exercise, meditation, and a balanced diet will help maintain optimal health. Avoid overexertion during the afternoon hours.';
    } else if (lowerQuestion.contains('money') ||
        lowerQuestion.contains('finance')) {
      return 'Financial prospects are improving with Jupiter\'s beneficial aspect on your 2nd house of wealth. This is a good time for investments, especially in long-term assets. However, avoid impulsive purchases and maintain a budget for better financial stability.';
    } else if (lowerQuestion.contains('lucky')) {
      return 'Your lucky number today is 7, and your lucky color is blue. The most auspicious time for important decisions is between 11 AM and 1 PM. Wearing blue or keeping a blue accessory can enhance positive energies around you.';
    } else {
      return 'Based on your birth chart and current planetary transits, I see a period of transformation ahead. The cosmic energies are aligning to bring new opportunities in various aspects of your life. Stay positive and trust your intuition as you navigate through this phase. Remember, the stars guide but don\'t compel - your actions shape your destiny.';
    }
  }

  void clearChat() {
    _messages.clear();
    _initializeChat();
    notifyListeners();
  }

  void setPremiumStatus(bool isPremium) {
    _isPremium = isPremium;
    if (isPremium) {
      _freeQuestionsRemaining = -1; // Unlimited
    }
    notifyListeners();
  }

  void resetDailyQuestions() {
    if (!_isPremium) {
      _freeQuestionsRemaining = AppConstants.freeAiQuestionsPerDay;
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
