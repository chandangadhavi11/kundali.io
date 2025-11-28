import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/user_model.dart';
import '../constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String _error = '';

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.userTokenKey);

      if (token != null) {
        // TODO: Validate token and fetch user data
        await _loadUserFromLocal();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(AppConstants.userProfileKey);

    if (userData != null) {
      _currentUser = User.fromJson(userData);
      _isAuthenticated = true;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock user data
      _currentUser = User(
        id: '1',
        name: 'John Doe',
        email: email,
        phoneNumber: '',
        birthDate: DateTime.now(),
        birthTime: DateTime.now(),
        birthPlace: 'Mumbai, India',
        gender: 'Male',
        zodiacSign: 'Aries',
        moonSign: 'Taurus',
        ascendant: 'Gemini',
      );

      _isAuthenticated = true;

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userTokenKey, 'mock_token');
      await prefs.setString(
        AppConstants.userProfileKey,
        _currentUser!.toJson(),
      );

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock user creation
      _currentUser = User(
        id: '1',
        name: name,
        email: email,
        phoneNumber: '',
        birthDate: DateTime.now(),
        birthTime: DateTime.now(),
        birthPlace: '',
        gender: '',
        zodiacSign: '',
        moonSign: '',
        ascendant: '',
      );

      _isAuthenticated = true;

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userTokenKey, 'mock_token');
      await prefs.setString(
        AppConstants.userProfileKey,
        _currentUser!.toJson(),
      );

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // TODO: Implement Google Sign In
      await Future.delayed(const Duration(seconds: 2));

      _currentUser = User(
        id: '1',
        name: 'Google User',
        email: 'user@gmail.com',
        phoneNumber: '',
        birthDate: DateTime.now(),
        birthTime: DateTime.now(),
        birthPlace: '',
        gender: '',
        zodiacSign: '',
        moonSign: '',
        ascendant: '',
      );

      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userTokenKey, 'google_token');
      await prefs.setString(
        AppConstants.userProfileKey,
        _currentUser!.toJson(),
      );

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(User updatedUser) async {
    _currentUser = updatedUser;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userProfileKey, updatedUser.toJson());

    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userTokenKey);
      await prefs.remove(AppConstants.userProfileKey);

      _currentUser = null;
      _isAuthenticated = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}


