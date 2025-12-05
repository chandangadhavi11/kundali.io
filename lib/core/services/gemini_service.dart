import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../shared/models/kundali_data_model.dart';

/// Service for interacting with Google Gemini AI for astrology-focused responses
class GeminiService {
  static GeminiService? _instance;
  GenerativeModel? _model;
  ChatSession? _chatSession;
  
  // API Key - In production, this should be fetched from secure storage or environment
  // For now, we'll allow setting it dynamically
  String? _apiKey;
  
  GeminiService._();
  
  static GeminiService get instance {
    _instance ??= GeminiService._();
    return _instance!;
  }
  
  /// Initialize the Gemini service with an API key
  Future<bool> initialize(String apiKey) async {
    try {
      _apiKey = apiKey;
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
        ],
      );
      return true;
    } catch (e) {
      debugPrint('Error initializing Gemini: $e');
      return false;
    }
  }
  
  /// Check if the service is initialized
  bool get isInitialized => _model != null && _apiKey != null;
  
  /// Get the system prompt for astrology context
  String _getAstrologySystemPrompt(KundaliData? kundali) {
    final basePrompt = '''
You are an expert Vedic Astrologer AI assistant with deep knowledge of:
- Vedic Astrology (Jyotish Shastra)
- Birth chart (Kundli/Kundali) interpretation
- Planetary positions and their effects
- Nakshatras (lunar mansions) and their significance
- Dasha systems (Vimshottari Dasha)
- Gochar (planetary transits)
- Muhurta (auspicious timing)
- Compatibility matching (Kundali Milan)
- Remedies and suggestions based on planetary positions

Guidelines for your responses:
1. Be respectful, empathetic, and culturally sensitive
2. Provide insights based on Vedic astrology principles
3. When discussing predictions, use phrases like "the planetary positions suggest" rather than absolute statements
4. Offer practical advice and remedies when appropriate
5. If asked about health, always recommend consulting a medical professional alongside astrological insights
6. Be positive and encouraging, even when discussing challenging planetary periods
7. Explain astrological concepts in simple terms when needed
8. Reference specific planets, houses, and aspects when relevant to the question
''';

    if (kundali != null) {
      final userContext = '''

USER'S BIRTH CHART INFORMATION:
- Name: ${kundali.name}
- Birth Date & Time: ${kundali.birthDateTime}
- Birth Place: ${kundali.birthPlace}
- Ascendant (Lagna): ${kundali.ascendant.sign} at ${kundali.ascendant.signDegree.toStringAsFixed(2)}°
- Moon Sign (Rashi): ${kundali.moonSign}
- Sun Sign: ${kundali.sunSign}
- Birth Nakshatra: ${kundali.birthNakshatra}
- Current Mahadasha: ${kundali.dashaInfo.currentMahadasha}
- Dasha Remaining: ${kundali.dashaInfo.remainingYears.toStringAsFixed(1)} years

PLANETARY POSITIONS:
${_formatPlanetaryPositions(kundali)}

Use this birth chart information to provide personalized insights. Reference specific planetary positions when relevant to the user's questions.
''';
      return '$basePrompt$userContext';
    }
    
    return '''$basePrompt

Note: The user hasn't provided their birth chart yet. Encourage them to create their Kundali for personalized insights, but still provide general astrological guidance based on their questions.
''';
  }
  
  /// Format planetary positions for the system prompt
  String _formatPlanetaryPositions(KundaliData kundali) {
    final buffer = StringBuffer();
    kundali.planetPositions.forEach((planet, position) {
      buffer.writeln('- $planet: ${position.sign} (House ${position.house}) at ${position.longitude.toStringAsFixed(2)}° - Nakshatra: ${position.nakshatra}');
    });
    return buffer.toString();
  }
  
  /// Start a new chat session with optional Kundali context
  void startNewSession(KundaliData? kundali) {
    if (_model == null) {
      debugPrint('Gemini model not initialized');
      return;
    }
    
    final systemPrompt = _getAstrologySystemPrompt(kundali);
    
    _chatSession = _model!.startChat(
      history: [
        Content.text(systemPrompt),
        Content.model([TextPart('Namaste! I am your AI Astrologer, here to guide you through the cosmic wisdom of Vedic astrology. ${kundali != null ? "I can see your birth chart and will provide personalized insights based on your planetary positions." : "Create your Kundali for personalized predictions, or ask me any astrological question."} How may I assist you today?')]),
      ],
    );
  }
  
  /// Send a message and get a response
  Future<String> sendMessage(String message, {KundaliData? kundali}) async {
    if (_model == null) {
      throw Exception('Gemini service not initialized. Please set your API key.');
    }
    
    // Start a new session if needed
    if (_chatSession == null) {
      startNewSession(kundali);
    }
    
    try {
      final response = await _chatSession!.sendMessage(Content.text(message));
      final responseText = response.text;
      
      if (responseText == null || responseText.isEmpty) {
        return 'I apologize, but I couldn\'t generate a response. Please try rephrasing your question.';
      }
      
      return responseText;
    } catch (e) {
      debugPrint('Error sending message to Gemini: $e');
      
      if (e.toString().contains('API key')) {
        throw Exception('Invalid API key. Please check your Gemini API key in settings.');
      }
      
      if (e.toString().contains('quota') || e.toString().contains('rate')) {
        throw Exception('API quota exceeded. Please try again later.');
      }
      
      throw Exception('Failed to get response: ${e.toString()}');
    }
  }
  
  /// Send a message with streaming response
  Stream<String> sendMessageStream(String message, {KundaliData? kundali}) async* {
    if (_model == null) {
      throw Exception('Gemini service not initialized. Please set your API key.');
    }
    
    // Start a new session if needed
    if (_chatSession == null) {
      startNewSession(kundali);
    }
    
    try {
      final responses = _chatSession!.sendMessageStream(Content.text(message));
      
      await for (final response in responses) {
        final text = response.text;
        if (text != null && text.isNotEmpty) {
          yield text;
        }
      }
    } catch (e) {
      debugPrint('Error in streaming response: $e');
      throw Exception('Failed to get response: ${e.toString()}');
    }
  }
  
  /// Generate a transit analysis for the current day
  Future<String> generateTransitAnalysis(KundaliData kundali) async {
    final prompt = '''
Based on my birth chart, please provide a detailed analysis of today's planetary transits and how they affect me. Include:
1. Key transits affecting my chart today
2. Areas of life that may be impacted (career, relationships, health, etc.)
3. Favorable and challenging periods during the day
4. Any specific advice or remedies for today

Please make it practical and actionable.
''';
    
    return await sendMessage(prompt, kundali: kundali);
  }
  
  /// Generate compatibility analysis
  Future<String> generateCompatibilityIntro() async {
    return await sendMessage(
      'I want to check compatibility with a potential partner. What information do you need from me to perform a Kundali Milan (compatibility matching)?',
    );
  }
  
  /// Clear the current chat session
  void clearSession() {
    _chatSession = null;
  }
  
  /// Update the API key
  Future<bool> updateApiKey(String newApiKey) async {
    clearSession();
    return await initialize(newApiKey);
  }
  
  /// Dispose resources
  void dispose() {
    _chatSession = null;
    _model = null;
    _apiKey = null;
  }
}

