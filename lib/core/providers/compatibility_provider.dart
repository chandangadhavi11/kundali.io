import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/kundali_data_model.dart';
import '../../shared/models/compatibility_result.dart';
import '../services/compatibility_service.dart';

/// Provider for managing compatibility/matchmaking state
class CompatibilityProvider extends ChangeNotifier {
  // Selected profiles for comparison
  KundaliData? _person1;
  KundaliData? _person2;

  // Current result
  CompatibilityResult? _currentResult;

  // Match history
  List<MatchHistoryItem> _matchHistory = [];

  // UI State
  bool _isCalculating = false;
  String _error = '';

  // Storage key
  static const String _historyKey = 'match_history';

  // Getters
  KundaliData? get person1 => _person1;
  KundaliData? get person2 => _person2;
  CompatibilityResult? get currentResult => _currentResult;
  List<MatchHistoryItem> get matchHistory => _matchHistory;
  bool get isCalculating => _isCalculating;
  String get error => _error;
  bool get canCalculate => _person1 != null && _person2 != null;
  bool get hasResult => _currentResult != null;

  CompatibilityProvider() {
    _loadHistory();
  }

  /// Set person 1 for comparison
  void setPerson1(KundaliData? person) {
    _person1 = person;
    _currentResult = null; // Clear previous result
    _error = '';
    notifyListeners();
  }

  /// Set person 2 for comparison
  void setPerson2(KundaliData? person) {
    _person2 = person;
    _currentResult = null; // Clear previous result
    _error = '';
    notifyListeners();
  }

  /// Swap person 1 and person 2
  void swapPersons() {
    final temp = _person1;
    _person1 = _person2;
    _person2 = temp;
    _currentResult = null;
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    _person1 = null;
    _person2 = null;
    _currentResult = null;
    _error = '';
    notifyListeners();
  }

  /// Calculate compatibility
  Future<void> calculateMatch() async {
    if (_person1 == null || _person2 == null) {
      _error = 'Please select both profiles';
      notifyListeners();
      return;
    }

    _isCalculating = true;
    _error = '';
    notifyListeners();

    try {
      // Small delay for animation effect
      await Future.delayed(const Duration(milliseconds: 500));

      // Calculate compatibility
      _currentResult = CompatibilityService.calculateAshtakootScore(
        _person1!,
        _person2!,
      );

      // Save to history
      await _saveToHistory(_currentResult!);
    } catch (e) {
      _error = 'Failed to calculate compatibility: ${e.toString()}';
      debugPrint('Error calculating compatibility: $e');
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  /// Save result to history
  Future<void> _saveToHistory(CompatibilityResult result) async {
    final historyItem = MatchHistoryItem.fromResult(result);
    
    // Remove if already exists (same two people)
    _matchHistory.removeWhere((item) =>
        (item.person1Name == historyItem.person1Name &&
            item.person2Name == historyItem.person2Name) ||
        (item.person1Name == historyItem.person2Name &&
            item.person2Name == historyItem.person1Name));

    // Add to beginning
    _matchHistory.insert(0, historyItem);

    // Keep only last 20 matches
    if (_matchHistory.length > 20) {
      _matchHistory = _matchHistory.take(20).toList();
    }

    await _saveHistory();
  }

  /// Load history from storage
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_historyKey);

      if (data != null) {
        final List<dynamic> jsonList = json.decode(data);
        _matchHistory = jsonList
            .map((json) => MatchHistoryItem.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading match history: $e');
    }
  }

  /// Save history to storage
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _matchHistory.map((item) => item.toJson()).toList();
      await prefs.setString(_historyKey, json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving match history: $e');
    }
  }

  /// Delete a history item
  Future<void> deleteHistoryItem(String id) async {
    _matchHistory.removeWhere((item) => item.id == id);
    await _saveHistory();
    notifyListeners();
  }

  /// Clear all history
  Future<void> clearHistory() async {
    _matchHistory.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    notifyListeners();
  }

  /// Clear current result
  void clearResult() {
    _currentResult = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  /// Get kuta display name
  static String getKutaDisplayName(String kutaKey) {
    const names = {
      'varna': 'Varna',
      'vashya': 'Vashya',
      'tara': 'Tara',
      'yoni': 'Yoni',
      'grahaMaitri': 'Graha Maitri',
      'gana': 'Gana',
      'bhakoot': 'Bhakoot',
      'nadi': 'Nadi',
    };
    return names[kutaKey] ?? kutaKey;
  }

  /// Get kuta icon
  static IconData getKutaIcon(String kutaKey) {
    const icons = {
      'varna': Icons.account_balance_rounded,
      'vashya': Icons.psychology_rounded,
      'tara': Icons.star_rounded,
      'yoni': Icons.pets_rounded,
      'grahaMaitri': Icons.handshake_rounded,
      'gana': Icons.mood_rounded,
      'bhakoot': Icons.account_balance_wallet_rounded,
      'nadi': Icons.favorite_rounded,
    };
    return icons[kutaKey] ?? Icons.help_outline_rounded;
  }

  /// Get kuta color
  static Color getKutaColor(String kutaKey) {
    const colors = {
      'varna': Color(0xFFFBBF24), // Amber
      'vashya': Color(0xFF60A5FA), // Blue
      'tara': Color(0xFFA78BFA), // Purple
      'yoni': Color(0xFFF472B6), // Pink
      'grahaMaitri': Color(0xFF34D399), // Green
      'gana': Color(0xFFFCA5A5), // Red light
      'bhakoot': Color(0xFF67E8F9), // Cyan
      'nadi': Color(0xFFE879F9), // Fuchsia
    };
    return colors[kutaKey] ?? const Color(0xFF9CA3AF);
  }
}

