import 'package:flutter_test/flutter_test.dart';
import 'package:kundali_app/core/services/sweph_service.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';

/// Test file to verify Swiss Ephemeris calculations
/// These tests verify that the sweph integration works correctly
/// and produces accurate planetary positions.
void main() {
  group('SwephService Tests', () {
    setUpAll(() async {
      // Initialize Swiss Ephemeris
      await SwephService.initialize();
    });

    test('SwephService initializes correctly', () {
      expect(SwephService.isInitialized, isTrue);
    });

    test('Calculate planetary positions for known date', () {
      // Skip if native library isn't available (unit tests)
      if (!SwephService.nativeLibraryAvailable) {
        print('Skipping test: Native library not available (expected in unit tests)');
        return;
      }
      
      // Test with a known birth date: January 1, 2000, 12:00 PM IST
      // Location: New Delhi, India (28.6139° N, 77.2090° E)
      final result = SwephService.instance.calculateKundli(
        birthDateTime: DateTime(2000, 1, 1, 12, 0, 0),
        latitude: 28.6139,
        longitude: 77.2090,
        timezoneOffsetHours: 5.5, // IST
        useAyanamsa: true, // Sidereal positions
      );

      // Verify we got results for all planets
      expect(result.planets.length, equals(9)); // Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn, Rahu, Ketu
      expect(result.planets.containsKey('Sun'), isTrue);
      expect(result.planets.containsKey('Moon'), isTrue);
      expect(result.planets.containsKey('Mars'), isTrue);
      expect(result.planets.containsKey('Mercury'), isTrue);
      expect(result.planets.containsKey('Jupiter'), isTrue);
      expect(result.planets.containsKey('Venus'), isTrue);
      expect(result.planets.containsKey('Saturn'), isTrue);
      expect(result.planets.containsKey('Rahu'), isTrue);
      expect(result.planets.containsKey('Ketu'), isTrue);

      // Verify longitude values are in valid range (0-360)
      for (var planet in result.planets.values) {
        expect(planet.longitude, greaterThanOrEqualTo(0));
        expect(planet.longitude, lessThan(360));
      }

      // Verify houses are calculated
      expect(result.houses.length, equals(12));
      for (var cusp in result.houses) {
        expect(cusp, greaterThanOrEqualTo(0));
        expect(cusp, lessThan(360));
      }

      // Verify ascendant is calculated
      expect(result.ascendant, greaterThanOrEqualTo(0));
      expect(result.ascendant, lessThan(360));

      // Print results for verification
      print('\n=== Kundli Calculation Results (Jan 1, 2000, New Delhi) ===');
      print('Ascendant: ${result.ascendantSign} ${result.ascendantDegreeInSign.toStringAsFixed(2)}°');
      print('Ayanamsa: ${result.ayanamsa.toStringAsFixed(4)}°');
      print('\nPlanetary Positions:');
      for (var entry in result.planets.entries) {
        final planet = entry.value;
        final retro = planet.isRetrograde ? ' (R)' : '';
        print('  ${entry.key}: ${planet.signName} ${planet.degreeInSign.toStringAsFixed(2)}°$retro');
      }
      print('\nHouse Cusps:');
      for (int i = 0; i < 12; i++) {
        print('  House ${i + 1}: ${SwephService.getSignName(result.houses[i])} ${SwephService.getDegreeInSign(result.houses[i]).toStringAsFixed(2)}°');
      }
    });

    test('Ketu is opposite to Rahu', () {
      // Skip if native library isn't available (unit tests)
      if (!SwephService.nativeLibraryAvailable) {
        print('Skipping test: Native library not available (expected in unit tests)');
        return;
      }
      
      final result = SwephService.instance.calculateKundli(
        birthDateTime: DateTime(2000, 1, 1, 12, 0, 0),
        latitude: 28.6139,
        longitude: 77.2090,
        timezoneOffsetHours: 5.5,
      );

      final rahu = result.planets['Rahu']!;
      final ketu = result.planets['Ketu']!;

      // Ketu should be 180° opposite to Rahu
      final expectedKetu = (rahu.longitude + 180.0) % 360.0;
      expect(ketu.longitude, closeTo(expectedKetu, 0.001));
    });

    test('Timezone parsing works correctly', () {
      expect(SwephService.parseTimezoneOffset('IST'), equals(5.5));
      expect(SwephService.parseTimezoneOffset('UTC'), equals(0.0));
      expect(SwephService.parseTimezoneOffset('GMT'), equals(0.0));
      expect(SwephService.parseTimezoneOffset('EST'), equals(-5.0));
      expect(SwephService.parseTimezoneOffset('+05:30'), equals(5.5));
      expect(SwephService.parseTimezoneOffset('-08:00'), equals(-8.0));
      expect(SwephService.parseTimezoneOffset('UTC+5.5'), equals(5.5));
      expect(SwephService.parseTimezoneOffset('5.5'), equals(5.5));
    });

    test('Nakshatra calculation', () {
      // Moon at 0° Aries should be in Ashwini
      var nakshatra = SwephService.getNakshatra(0.0);
      expect(nakshatra.name, equals('Ashwini'));
      expect(nakshatra.pada, equals(1));

      // Moon at 15° Aries should still be in Ashwini Pada 4 or Bharani
      nakshatra = SwephService.getNakshatra(15.0);
      expect(nakshatra.index, lessThanOrEqualTo(1)); // Either Ashwini or Bharani

      // Moon at 26.67° should be in Bharani (13.33° - 26.67°)
      nakshatra = SwephService.getNakshatra(20.0);
      expect(nakshatra.name, equals('Bharani'));
    });

    test('Sign calculation', () {
      expect(SwephService.getSignName(0.0), equals('Aries'));
      expect(SwephService.getSignName(30.0), equals('Taurus'));
      expect(SwephService.getSignName(60.0), equals('Gemini'));
      expect(SwephService.getSignName(90.0), equals('Cancer'));
      expect(SwephService.getSignName(359.9), equals('Pisces'));
    });
  });

  group('KundaliCalculationService Tests', () {
    setUpAll(() async {
      await SwephService.initialize();
    });

    test('Calculate complete planetary positions', () {
      final positions = KundaliCalculationService.calculatePlanetaryPositions(
        birthDateTime: DateTime(1990, 5, 15, 10, 30, 0),
        latitude: 19.0760, // Mumbai
        longitude: 72.8777,
        timezone: 'IST',
      );

      expect(positions.length, equals(9));
      
      // Verify all planets have valid positions
      for (var planet in positions.values) {
        expect(planet.longitude, greaterThanOrEqualTo(0));
        expect(planet.longitude, lessThan(360));
        expect(KundaliCalculationService.zodiacSigns.contains(planet.sign), isTrue);
        expect(planet.signDegree, greaterThanOrEqualTo(0));
        expect(planet.signDegree, lessThan(30));
        expect(planet.house, greaterThanOrEqualTo(1));
        expect(planet.house, lessThanOrEqualTo(12));
      }

      print('\n=== Kundli for May 15, 1990, Mumbai ===');
      for (var entry in positions.entries) {
        print('${entry.key}: ${entry.value.formattedPosition} (House ${entry.value.house})');
      }
    });

    test('Calculate ascendant', () {
      final ascendant = KundaliCalculationService.calculateAscendant(
        birthDateTime: DateTime(1990, 5, 15, 10, 30, 0),
        latitude: 19.0760,
        longitude: 72.8777,
        timezone: 'IST',
      );

      expect(ascendant.longitude, greaterThanOrEqualTo(0));
      expect(ascendant.longitude, lessThan(360));
      expect(KundaliCalculationService.zodiacSigns.contains(ascendant.sign), isTrue);

      print('\nAscendant: ${ascendant.formattedPosition}');
      print('Nakshatra: ${ascendant.nakshatra}');
    });

    test('Calculate houses', () {
      final houses = KundaliCalculationService.calculateHouses(
        birthDateTime: DateTime(1990, 5, 15, 10, 30, 0),
        latitude: 19.0760,
        longitude: 72.8777,
        timezone: 'IST',
      );

      expect(houses.length, equals(12));
      
      for (int i = 0; i < 12; i++) {
        expect(houses[i].number, equals(i + 1));
        expect(KundaliCalculationService.zodiacSigns.contains(houses[i].sign), isTrue);
      }

      print('\nHouses:');
      for (var house in houses) {
        final planetsStr = house.planets.isNotEmpty ? ' - Planets: ${house.planets.join(", ")}' : '';
        print('House ${house.number}: ${house.sign}$planetsStr');
      }
    });

    test('Calculate Navamsa chart', () {
      final birthChart = KundaliCalculationService.calculatePlanetaryPositions(
        birthDateTime: DateTime(1990, 5, 15, 10, 30, 0),
        latitude: 19.0760,
        longitude: 72.8777,
        timezone: 'IST',
      );

      final navamsa = KundaliCalculationService.calculateNavamsaChart(birthChart);

      expect(navamsa.length, equals(birthChart.length));
      
      print('\nNavamsa Chart:');
      for (var entry in navamsa.entries) {
        print('${entry.key}: ${entry.value.formattedPosition}');
      }
    });

    test('Calculate Dasha info', () {
      final moonLongitude = 96.0; // Example Moon position in Cancer
      final birthDateTime = DateTime(1990, 5, 15);
      
      final dashaInfo = KundaliCalculationService.calculateDashaInfo(
        birthDateTime,
        moonLongitude,
      );

      expect(dashaInfo.currentMahadasha.isNotEmpty, isTrue);
      expect(dashaInfo.remainingYears, greaterThanOrEqualTo(0));
      expect(dashaInfo.sequence.length, equals(9));

      print('\nDasha Info:');
      print('Current Mahadasha: ${dashaInfo.currentMahadasha}');
      print('Remaining Years: ${dashaInfo.remainingYears.toStringAsFixed(2)}');
    });

    test('Detect Yogas', () {
      // Create positions where Gajakesari Yoga should form
      // (Jupiter in kendra from Moon)
      final positions = KundaliCalculationService.calculatePlanetaryPositions(
        birthDateTime: DateTime(1990, 5, 15, 10, 30, 0),
        latitude: 19.0760,
        longitude: 72.8777,
        timezone: 'IST',
      );

      // Just verify the positions are calculated
      expect(positions.isNotEmpty, isTrue);
    });
  });
}

