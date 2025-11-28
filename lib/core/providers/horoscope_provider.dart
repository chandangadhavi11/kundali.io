import 'package:flutter/foundation.dart';
import '../../shared/models/horoscope_model.dart';

class HoroscopeProvider extends ChangeNotifier {
  final Map<String, Horoscope> _dailyHoroscopes = {};
  final Map<String, Horoscope> _weeklyHoroscopes = {};
  final Map<String, Horoscope> _monthlyHoroscopes = {};
  Horoscope? _personalizedHoroscope;
  String _selectedSign = 'Aries';
  String _selectedPeriod = 'Daily';
  bool _isLoading = false;
  String _error = '';

  Map<String, Horoscope> get dailyHoroscopes => _dailyHoroscopes;
  Map<String, Horoscope> get weeklyHoroscopes => _weeklyHoroscopes;
  Map<String, Horoscope> get monthlyHoroscopes => _monthlyHoroscopes;
  Horoscope? get personalizedHoroscope => _personalizedHoroscope;
  String get selectedSign => _selectedSign;
  String get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;
  String get error => _error;

  Horoscope? get currentHoroscope {
    switch (_selectedPeriod) {
      case 'Daily':
        return _dailyHoroscopes[_selectedSign];
      case 'Weekly':
        return _weeklyHoroscopes[_selectedSign];
      case 'Monthly':
        return _monthlyHoroscopes[_selectedSign];
      default:
        return _dailyHoroscopes[_selectedSign];
    }
  }

  Future<void> fetchDailyHoroscopes() async {
    _isLoading = true;
    _error = '';
    // Use Future.microtask to avoid calling notifyListeners during build
    await Future.microtask(() => notifyListeners());

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock horoscope data
      final signs = [
        'Aries',
        'Taurus',
        'Gemini',
        'Cancer',
        'Leo',
        'Virgo',
        'Libra',
        'Scorpio',
        'Sagittarius',
        'Capricorn',
        'Aquarius',
        'Pisces',
      ];

      for (final sign in signs) {
        _dailyHoroscopes[sign] = Horoscope(
          sign: sign,
          date: DateTime.now(),
          period: 'Daily',
          general:
              'Today brings new opportunities for growth and self-discovery. Stay open to unexpected changes.',
          love:
              'Romance is in the air. Singles may meet someone special, while couples strengthen their bond.',
          career:
              'Professional success is within reach. Focus on your goals and maintain a positive attitude.',
          health:
              'Pay attention to your well-being. Regular exercise and a balanced diet will boost your energy.',
          finance:
              'Financial prospects look promising. Consider long-term investments for future security.',
          luckyNumber: (signs.indexOf(sign) + 1) * 3,
          luckyColor: _getLuckyColor(sign),
          mood: 'Optimistic',
          compatibility: _getCompatibleSign(sign),
          rating: 3 + (signs.indexOf(sign) % 3), // Rating between 3-5
          luckyTime:
              '${9 + (signs.indexOf(sign) % 3)}:00 AM - ${10 + (signs.indexOf(sign) % 3)}:00 AM',
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPersonalizedHoroscope(String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // TODO: Implement actual personalized horoscope based on user's birth chart
      await Future.delayed(const Duration(seconds: 1));

      _personalizedHoroscope = Horoscope(
        sign: 'Personalized',
        date: DateTime.now(),
        period: 'Daily',
        general:
            'Based on your birth chart, today\'s planetary positions favor new beginnings.',
        love: 'Venus in your 7th house brings harmony to relationships.',
        career: 'Mars transiting your 10th house energizes career matters.',
        health: 'Moon in your 6th house suggests focusing on health routines.',
        finance:
            'Jupiter\'s aspect on your 2nd house indicates financial growth.',
        luckyNumber: 7,
        luckyColor: 'Blue',
        mood: 'Energetic',
        compatibility: 'Taurus',
        rating: 5, // Personalized horoscopes get high rating
        luckyTime: '11:00 AM - 12:00 PM',
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getLuckyColor(String sign) {
    final colors = {
      'Aries': 'Red',
      'Taurus': 'Green',
      'Gemini': 'Yellow',
      'Cancer': 'Silver',
      'Leo': 'Gold',
      'Virgo': 'Brown',
      'Libra': 'Pink',
      'Scorpio': 'Maroon',
      'Sagittarius': 'Purple',
      'Capricorn': 'Black',
      'Aquarius': 'Blue',
      'Pisces': 'Sea Green',
    };
    return colors[sign] ?? 'White';
  }

  String _getCompatibleSign(String sign) {
    final compatibility = {
      'Aries': 'Leo',
      'Taurus': 'Virgo',
      'Gemini': 'Libra',
      'Cancer': 'Scorpio',
      'Leo': 'Sagittarius',
      'Virgo': 'Capricorn',
      'Libra': 'Aquarius',
      'Scorpio': 'Pisces',
      'Sagittarius': 'Aries',
      'Capricorn': 'Taurus',
      'Aquarius': 'Gemini',
      'Pisces': 'Cancer',
    };
    return compatibility[sign] ?? 'Aries';
  }

  void selectSign(String sign) {
    _selectedSign = sign;
    notifyListeners();
  }

  void selectPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }
}
