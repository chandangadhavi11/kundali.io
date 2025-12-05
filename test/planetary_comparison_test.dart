// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';

/// Test to compare planetary positions with other app
/// 
/// Run with: flutter test test/planetary_comparison_test.dart
void main() {
  test('Compare planetary positions with other app', () {
    print('\n' + '=' * 70);
    print('PLANETARY POSITION COMPARISON TEST');
    print('Date: Dec 5, 2025, 13:38:40 IST');
    print('Location: Delhi (28.6139°N, 77.209°E)');
    print('=' * 70);
    
    // Run the comparison
    KundaliCalculationService.compareWithOtherApp();
    
    // Also run the detailed test
    final result = KundaliCalculationService.testCalculation(
      year: 2025,
      month: 12,
      day: 5,
      hour: 13,
      minute: 38,
      second: 40,
      latitude: 28.6139,
      longitude: 77.2090,
      timezone: 'IST',
    );
    
    // Check specific planets
    final planets = result['planets'] as Map<String, Map<String, dynamic>>?;
    
    if (planets != null) {
      print('\n' + '=' * 70);
      print('KEY PLANETS TO VERIFY:');
      print('=' * 70);
      
      // Jupiter check
      final jupiter = planets['Jupiter'];
      if (jupiter != null) {
        print('');
        print('JUPITER:');
        print('  Our app: ${jupiter['sign']} ${(jupiter['degree'] as double).toStringAsFixed(2)}°');
        print('  Other app: Gemini 29.95°');
        print('  Expected longitude: 89.95°');
        print('  Our longitude: ${(jupiter['longitude'] as double).toStringAsFixed(2)}°');
        final jupiterDiff = (jupiter['longitude'] as double) - 89.95;
        print('  Difference: ${jupiterDiff >= 0 ? '+' : ''}${jupiterDiff.toStringAsFixed(2)}°');
        
        if (jupiter['sign'] == 'Gemini') {
          print('  ✅ Jupiter sign MATCHES');
        } else {
          print('  ❌ Jupiter sign MISMATCH (expected Gemini, got ${jupiter['sign']})');
        }
      }
      
      // Saturn check
      final saturn = planets['Saturn'];
      if (saturn != null) {
        print('');
        print('SATURN:');
        print('  Our app: ${saturn['sign']} ${(saturn['degree'] as double).toStringAsFixed(2)}°');
        print('  Other app: Pisces 0.97°');
        print('  Expected longitude: 330.97°');
        print('  Our longitude: ${(saturn['longitude'] as double).toStringAsFixed(2)}°');
        final saturnDiff = (saturn['longitude'] as double) - 330.97;
        print('  Difference: ${saturnDiff >= 0 ? '+' : ''}${saturnDiff.toStringAsFixed(2)}°');
        
        if (saturn['sign'] == 'Pisces') {
          print('  ✅ Saturn sign MATCHES');
        } else {
          print('  ❌ Saturn sign MISMATCH (expected Pisces, got ${saturn['sign']})');
        }
      }
      
      print('\n' + '=' * 70);
      print('RECOMMENDATION:');
      print('=' * 70);
      
      // Calculate average needed correction
      if (jupiter != null && saturn != null) {
        final jupiterDiff = (jupiter['longitude'] as double) - 89.95;
        final saturnDiff = (saturn['longitude'] as double) - 330.97;
        final avgDiff = (jupiterDiff + saturnDiff) / 2;
        
        print('');
        print('To match the other app, set ayanamsaCorrection to: ${(-avgDiff).toStringAsFixed(2)}°');
        print('This is the average correction needed based on Jupiter and Saturn.');
        print('');
        print('However, note that different apps use different ayanamsa variants.');
        print('Perfect matching may not be possible for ALL planets at once.');
      }
    }
    
    print('\n' + '=' * 70 + '\n');
    
    expect(result['success'], true);
  });
}

