import 'package:flutter/foundation.dart';

class AppProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _error = '';

  bool get isLoading => _isLoading;
  String get error => _error;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String message) {
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}


