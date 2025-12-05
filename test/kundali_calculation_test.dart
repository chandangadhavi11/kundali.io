// Test file for Kundali calculations
// Run with: flutter test test/kundali_calculation_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:kundali_v2/core/services/kundali_calculation_service.dart';
import 'package:kundali_v2/core/services/sweph_service.dart';

void main() {
  setUpAll(() async {
    // Initialize Swiss Ephemeris (required for calculations)
    TestWidgetsFlutterBinding.ensureInitialized();
    await SwephService.initialize();
  });

  group('Kundali Calculation Tests', () {
    test('Jupiter position on Dec 5, 2025 should be in Gemini', () {
      // Test the specific case the user is verifying
      final result = KundaliCalculationService.testCalculation(
        year: 2025,
        month: 12,
        day: 5,
        hour: 13,
        minute: 5,
        second: 44,
        latitude: 28.6139,  // Delhi
        longitude: 77.2090,
        timezone: 'IST',
      );
      
      expect(result['success'], true);
      
      final jupiter = result['planets']['Jupiter'];
      expect(jupiter, isNotNull);
      expect(jupiter['sign'], 'Gemini', reason: 'Jupiter should be in Gemini for Dec 5, 2025');
      
      // Jupiter should be around 29° Gemini
      final degree = jupiter['degree'] as double;
      expect(degree, greaterThan(28.0), reason: 'Jupiter degree should be ~29°');
      expect(degree, lessThan(30.0), reason: 'Jupiter degree should be ~29°');
      
      print('\n✅ Jupiter position verified: ${jupiter['sign']} ${degree.toStringAsFixed(2)}°');
    });

    test('Quick test with default values', () {
      final result = KundaliCalculationService.quickTest();
      
      expect(result['success'], true);
      
      print('\n📊 Quick test results:');
      print('   Ascendant: ${result['ascendant']['sign']} ${(result['ascendant']['degree'] as double).toStringAsFixed(2)}°');
      
      final planets = result['planets'] as Map<String, Map<String, dynamic>>;
      for (var entry in planets.entries) {
        final planet = entry.key;
        final data = entry.value;
        print('   $planet: ${data['sign']} ${(data['degree'] as double).toStringAsFixed(2)}°');
      }
    });

    test('Test various dates for Jupiter position', () {
      // Test dates around Jupiter sign changes
      final testCases = [
        {'year': 2025, 'month': 6, 'day': 1, 'expectedSign': 'Gemini'},   // Mid 2025
        {'year': 2025, 'month': 12, 'day': 5, 'expectedSign': 'Gemini'},  // Dec 2025
        {'year': 2024, 'month': 5, 'day': 1, 'expectedSign': 'Taurus'},   // May 2024
      ];

      for (var testCase in testCases) {
        final result = KundaliCalculationService.testCalculation(
          year: testCase['year'] as int,
          month: testCase['month'] as int,
          day: testCase['day'] as int,
          hour: 12,
          minute: 0,
          latitude: 28.6139,
          longitude: 77.2090,
          timezone: 'IST',
        );
        
        final jupiter = result['planets']['Jupiter'];
        print('\n${testCase['year']}-${testCase['month']}-${testCase['day']}: Jupiter in ${jupiter['sign']} ${(jupiter['degree'] as double).toStringAsFixed(2)}°');
        expect(jupiter['sign'], testCase['expectedSign'], 
          reason: 'Jupiter should be in ${testCase['expectedSign']} on ${testCase['year']}-${testCase['month']}-${testCase['day']}');
      }
    });
  });
}

