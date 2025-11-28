import 'package:flutter/foundation.dart';
import '../../shared/models/panchang_model.dart';

class PanchangProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  Panchang? _currentPanchang;
  Map<DateTime, List<String>> _festivals = {};
  bool _isLoading = false;
  String _error = '';
  String _location = 'Mumbai, India';

  DateTime get selectedDate => _selectedDate;
  Panchang? get currentPanchang => _currentPanchang;
  Map<DateTime, List<String>> get festivals => _festivals;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get location => _location;

  Future<void> fetchPanchang(DateTime date) async {
    _isLoading = true;
    _error = '';
    _selectedDate = date;
    // Use Future.microtask to avoid calling notifyListeners during build
    await Future.microtask(() => notifyListeners());

    try {
      // TODO: Implement actual Panchang calculation
      await Future.delayed(const Duration(seconds: 1));

      // Mock Panchang data
      _currentPanchang = Panchang(
        date: date,
        tithi: 'Shukla Paksha Tritiya',
        nakshatra: 'Rohini',
        yoga: 'Siddhi',
        karana: 'Bava',
        vara: _getWeekday(date),
        sunrise: '06:15 AM',
        sunset: '07:00 PM',
        moonrise: '09:30 PM',
        moonset: '08:45 AM',
        rahuKaal: '12:00 PM - 01:30 PM',
        gulikai: '03:00 PM - 04:30 PM',
        yamaganda: '07:30 AM - 09:00 AM',
        abhijitMuhurat: '11:45 AM - 12:30 PM',
        festivals: _getFestivalsForDate(date),
        auspiciousTimings: [
          'Morning: 06:15 AM - 07:45 AM',
          'Afternoon: 11:45 AM - 12:30 PM',
        ],
        inauspiciousTimings: [
          'Rahu Kaal: 12:00 PM - 01:30 PM',
          'Gulikai: 03:00 PM - 04:30 PM',
        ],
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getWeekday(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[date.weekday - 1];
  }

  List<String> _getFestivalsForDate(DateTime date) {
    // Mock festival data
    if (date.day == 15 && date.month == 8) {
      return ['Independence Day'];
    } else if (date.day == 2 && date.month == 10) {
      return ['Gandhi Jayanti'];
    }
    return _festivals[date] ?? [];
  }

  Future<void> loadFestivals(int year) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Load festivals from database or API
      await Future.delayed(const Duration(seconds: 1));

      // Mock festival data
      _festivals = {
        DateTime(year, 1, 26): ['Republic Day'],
        DateTime(year, 3, 8): ['Holi'],
        DateTime(year, 8, 15): ['Independence Day'],
        DateTime(year, 10, 2): ['Gandhi Jayanti'],
        DateTime(year, 10, 24): ['Diwali'],
      };
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    fetchPanchang(date);
  }

  void setLocation(String location, double latitude, double longitude) {
    _location = location;
    // Recalculate panchang for new location
    fetchPanchang(_selectedDate);
  }

  bool hasFestival(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return _festivals.containsKey(dateKey) && _festivals[dateKey]!.isNotEmpty;
  }
}
