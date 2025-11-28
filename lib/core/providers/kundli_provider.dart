import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../shared/models/kundali_data_model.dart';
import '../../shared/models/kundli_model.dart';
import '../../shared/models/planet_position.dart' as legacy;

class KundliProvider extends ChangeNotifier {
  // Current Kundali being viewed/generated
  KundaliData? _currentKundali;

  // List of saved Kundalis
  List<KundaliData> _savedKundalis = [];

  // Primary Kundali (user's own)
  KundaliData? _primaryKundali;

  // UI State
  bool _isLoading = false;
  String _error = '';
  bool _isGenerating = false;

  // Preferences
  ChartStyle _defaultChartStyle = ChartStyle.northIndian;
  String _defaultLanguage = 'English';

  // Storage key
  static const String _storageKey = 'saved_kundalis';
  static const String _prefsKey = 'kundali_preferences';

  // Getters
  KundaliData? get currentKundali => _currentKundali;
  List<KundaliData> get savedKundalis => _savedKundalis;
  KundaliData? get primaryKundali => _primaryKundali;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isGenerating => _isGenerating;
  ChartStyle get defaultChartStyle => _defaultChartStyle;
  String get defaultLanguage => _defaultLanguage;

  // Legacy getters for compatibility
  Kundli? get currentKundli =>
      _currentKundali != null ? _convertToLegacyKundli(_currentKundali!) : null;
  List<Kundli> get savedKundlis =>
      _savedKundalis.map(_convertToLegacyKundli).toList();
  String get chartStyle => _defaultChartStyle.displayName;

  KundliProvider() {
    _loadSavedKundalis();
    _loadPreferences();
  }

  /// Generate a new Kundali
  Future<void> generateKundali({
    required String name,
    required DateTime birthDateTime,
    required String birthPlace,
    required double latitude,
    required double longitude,
    required String timezone,
    required String gender,
    bool isPrimary = false,
    ChartStyle? chartStyle,
    String? language,
  }) async {
    _isGenerating = true;
    _error = '';
    notifyListeners();

    try {
      // Generate unique ID
      String id = DateTime.now().millisecondsSinceEpoch.toString();

      // Create Kundali with calculations
      final kundali = KundaliData.fromBirthDetails(
        id: id,
        name: name,
        birthDateTime: birthDateTime,
        birthPlace: birthPlace,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
        gender: gender,
        chartStyle: chartStyle ?? _defaultChartStyle,
        language: language ?? _defaultLanguage,
        isPrimary: isPrimary,
      );

      // Set as current
      _currentKundali = kundali;

      // Add to saved list
      _savedKundalis.add(kundali);

      // Set as primary if specified
      if (isPrimary) {
        // Remove primary flag from others
        for (var k in _savedKundalis) {
          if (k.id != kundali.id && k.isPrimary) {
            int index = _savedKundalis.indexOf(k);
            _savedKundalis[index] = k.copyWith(isPrimary: false);
          }
        }
        _primaryKundali = kundali;
      }

      // Save to storage
      await _saveToStorage();
    } catch (e) {
      _error = 'Failed to generate Kundali: ${e.toString()}';
      debugPrint('Error generating Kundali: $e');
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  /// Legacy method for compatibility
  Future<void> generateKundli({
    required String name,
    required DateTime birthDate,
    required DateTime birthTime,
    required String birthPlace,
    required double latitude,
    required double longitude,
    required String gender,
  }) async {
    // Combine date and time
    final birthDateTime = DateTime(
      birthDate.year,
      birthDate.month,
      birthDate.day,
      birthTime.hour,
      birthTime.minute,
    );

    await generateKundali(
      name: name,
      birthDateTime: birthDateTime,
      birthPlace: birthPlace,
      latitude: latitude,
      longitude: longitude,
      timezone: 'IST', // Default timezone
      gender: gender,
    );
  }

  /// Set a Kundali as current for viewing
  void setCurrentKundali(KundaliData kundali) {
    _currentKundali = kundali;
    notifyListeners();
  }

  /// Legacy method
  void selectKundli(Kundli kundli) {
    final kundali = _savedKundalis.firstWhere(
      (k) => k.id == kundli.id,
      orElse: () => _savedKundalis.first,
    );
    setCurrentKundali(kundali);
  }

  /// Set a Kundali as primary
  Future<void> setPrimaryKundali(String kundaliId) async {
    try {
      // Find the Kundali (just to verify it exists)
      _savedKundalis.firstWhere((k) => k.id == kundaliId);

      // Update all Kundalis
      for (int i = 0; i < _savedKundalis.length; i++) {
        if (_savedKundalis[i].id == kundaliId) {
          _savedKundalis[i] = _savedKundalis[i].copyWith(isPrimary: true);
          _primaryKundali = _savedKundalis[i];
        } else if (_savedKundalis[i].isPrimary) {
          _savedKundalis[i] = _savedKundalis[i].copyWith(isPrimary: false);
        }
      }

      await _saveToStorage();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to set primary Kundali';
      notifyListeners();
    }
  }

  /// Update Kundali preferences
  Future<void> updateKundaliPreferences(
    String kundaliId, {
    ChartStyle? chartStyle,
    String? language,
  }) async {
    try {
      int index = _savedKundalis.indexWhere((k) => k.id == kundaliId);
      if (index != -1) {
        _savedKundalis[index] = _savedKundalis[index].copyWith(
          chartStyle: chartStyle,
          language: language,
        );

        if (_currentKundali?.id == kundaliId) {
          _currentKundali = _savedKundalis[index];
        }

        await _saveToStorage();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update preferences';
      notifyListeners();
    }
  }

  /// Delete a Kundali
  Future<void> deleteKundali(String kundaliId) async {
    try {
      _savedKundalis.removeWhere((k) => k.id == kundaliId);

      if (_currentKundali?.id == kundaliId) {
        _currentKundali = null;
      }

      if (_primaryKundali?.id == kundaliId) {
        _primaryKundali = null;
        // Set the first Kundali as primary if exists
        if (_savedKundalis.isNotEmpty) {
          _savedKundalis[0] = _savedKundalis[0].copyWith(isPrimary: true);
          _primaryKundali = _savedKundalis[0];
        }
      }

      await _saveToStorage();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete Kundali';
      notifyListeners();
    }
  }

  /// Legacy method
  Future<void> deleteKundli(String id) async {
    await deleteKundali(id);
  }

  /// Update default preferences
  Future<void> updateDefaultPreferences({
    ChartStyle? chartStyle,
    String? language,
  }) async {
    if (chartStyle != null) {
      _defaultChartStyle = chartStyle;
    }
    if (language != null) {
      _defaultLanguage = language;
    }

    await _savePreferences();
    notifyListeners();
  }

  /// Legacy method
  void setChartStyle(String style) {
    ChartStyle newStyle = ChartStyle.northIndian;
    if (style.contains('South')) {
      newStyle = ChartStyle.southIndian;
    } else if (style.contains('Western')) {
      newStyle = ChartStyle.western;
    }
    updateDefaultPreferences(chartStyle: newStyle);
  }

  /// Load saved Kundalis from storage
  Future<void> _loadSavedKundalis() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);

      if (data != null) {
        final List<dynamic> jsonList = json.decode(data);
        _savedKundalis =
            jsonList.map((json) {
              // Recreate KundaliData from stored JSON
              return KundaliData.fromBirthDetails(
                id: json['id'],
                name: json['name'],
                birthDateTime: DateTime.parse(json['birthDateTime']),
                birthPlace: json['birthPlace'],
                latitude: json['latitude'],
                longitude: json['longitude'],
                timezone: json['timezone'],
                gender: json['gender'],
                chartStyle: _parseChartStyle(json['chartStyle']),
                language: json['language'],
                isPrimary: json['isPrimary'] ?? false,
              );
            }).toList();

        // Find primary Kundali
        if (_savedKundalis.isNotEmpty) {
          _primaryKundali = _savedKundalis.firstWhere(
            (k) => k.isPrimary,
            orElse: () => _savedKundalis.first,
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading saved Kundalis: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Legacy method
  Future<void> loadSavedKundlis() async {
    await _loadSavedKundalis();
  }

  /// Save Kundalis to storage
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _savedKundalis.map((k) => k.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving Kundalis: $e');
    }
  }

  /// Load preferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_prefsKey);

      if (data != null) {
        final Map<String, dynamic> prefsData = json.decode(data);
        _defaultChartStyle = _parseChartStyle(prefsData['chartStyle']);
        _defaultLanguage = prefsData['language'] ?? 'English';
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  /// Save preferences
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsData = {
        'chartStyle': _defaultChartStyle.toString(),
        'language': _defaultLanguage,
      };
      await prefs.setString(_prefsKey, json.encode(prefsData));
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }
  }

  /// Parse chart style from string
  ChartStyle _parseChartStyle(String? style) {
    switch (style) {
      case 'ChartStyle.northIndian':
        return ChartStyle.northIndian;
      case 'ChartStyle.southIndian':
        return ChartStyle.southIndian;
      case 'ChartStyle.western':
        return ChartStyle.western;
      default:
        return ChartStyle.northIndian;
    }
  }

  /// Convert KundaliData to legacy Kundli model
  Kundli _convertToLegacyKundli(KundaliData data) {
    return Kundli(
      id: data.id,
      name: data.name,
      birthDate: data.birthDateTime,
      birthTime: data.birthDateTime,
      birthPlace: data.birthPlace,
      latitude: data.latitude,
      longitude: data.longitude,
      gender: data.gender,
      ascendant: data.ascendant.sign,
      moonSign: data.moonSign,
      sunSign: data.sunSign,
      nakshatra: data.birthNakshatra,
      planetPositions:
          data.planetPositions.values
              .map(
                (p) => legacy.PlanetPosition(
                  planet: p.planet,
                  sign: p.sign,
                  degree: p.longitude,
                  house: p.house,
                  nakshatra: p.nakshatra,
                  isRetrograde: false,
                ),
              )
              .toList(),
      houses: data.houses.map((h) => h.sign).toList(),
      dashas: {
        'currentMahadasha': data.dashaInfo.currentMahadasha,
        'remainingYears': data.dashaInfo.remainingYears,
        'startDate': data.dashaInfo.startDate,
        'endDate': data.dashaInfo.endDate,
      },
    );
  }

  /// Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  /// Clear all data
  Future<void> clearAllData() async {
    _currentKundali = null;
    _savedKundalis.clear();
    _primaryKundali = null;
    _error = '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);

    notifyListeners();
  }
}
