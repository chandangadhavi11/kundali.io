import 'package:flutter_test/flutter_test.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';

void main() {
  group('Kundali Calculation Tests', () {
    test('Should calculate Julian Day correctly', () {
      // Test for January 1, 2000 at noon
      final dateTime = DateTime(2000, 1, 1, 12, 0, 0);
      final jd = KundaliCalculationService.calculateJulianDay(dateTime);

      // Expected JD for Jan 1, 2000 at noon is approximately 2451545.0
      expect(jd, closeTo(2451545.0, 0.1));
    });

    test('Should calculate Ayanamsha correctly', () {
      final dateTime = DateTime(2024, 1, 1);
      final ayanamsha = KundaliCalculationService.calculateAyanamsha(dateTime);

      // Expected ayanamsha for 2024 is approximately 24.1567 degrees
      expect(ayanamsha, closeTo(24.1567, 0.01));
    });

    test('Should calculate planetary positions', () {
      final dateTime = DateTime(2024, 1, 1, 12, 0, 0);
      final latitude = 28.6139; // Delhi
      final longitude = 77.2090;

      final positions = KundaliCalculationService.calculatePlanetaryPositions(
        dateTime,
        latitude,
        longitude,
      );

      // Should have all 9 planets
      expect(positions.length, 9);
      expect(positions.containsKey('Sun'), true);
      expect(positions.containsKey('Moon'), true);
      expect(positions.containsKey('Mars'), true);
      expect(positions.containsKey('Mercury'), true);
      expect(positions.containsKey('Jupiter'), true);
      expect(positions.containsKey('Venus'), true);
      expect(positions.containsKey('Saturn'), true);
      expect(positions.containsKey('Rahu'), true);
      expect(positions.containsKey('Ketu'), true);

      // Each planet should have valid data
      for (var planet in positions.values) {
        expect(planet.longitude, greaterThanOrEqualTo(0));
        expect(planet.longitude, lessThan(360));
        expect(planet.sign, isNotEmpty);
        expect(planet.nakshatra, isNotEmpty);
      }
    });

    test('Should calculate ascendant', () {
      final dateTime = DateTime(2024, 1, 1, 6, 0, 0);
      final latitude = 28.6139;
      final longitude = 77.2090;

      final ascendant = KundaliCalculationService.calculateAscendant(
        dateTime,
        latitude,
        longitude,
      );

      expect(ascendant.longitude, greaterThanOrEqualTo(0));
      expect(ascendant.longitude, lessThan(360));
      expect(ascendant.sign, isNotEmpty);
      expect(ascendant.nakshatra, isNotEmpty);
    });

    test('Should calculate houses correctly', () {
      final ascendantLongitude = 45.0; // Example ascendant at 45 degrees
      final houses = KundaliCalculationService.calculateHouses(
        ascendantLongitude,
      );

      expect(houses.length, 12);

      for (int i = 0; i < houses.length; i++) {
        expect(houses[i].number, i + 1);
        expect(houses[i].sign, isNotEmpty);
        expect(houses[i].cuspDegree, greaterThanOrEqualTo(0));
        expect(houses[i].cuspDegree, lessThan(360));
      }
    });

    test('Should calculate Vimshottari Dasha', () {
      final birthDateTime = DateTime(2000, 1, 1, 12, 0, 0);
      final moonLongitude = 45.0; // Example moon position

      final dashaInfo = KundaliCalculationService.calculateVimshottariDasha(
        birthDateTime,
        moonLongitude,
      );

      expect(dashaInfo.currentMahadasha, isNotEmpty);
      expect(dashaInfo.remainingYears, greaterThan(0));
      expect(dashaInfo.sequence.length, 9); // 9 planetary periods
    });

    test('Should create KundaliData from birth details', () {
      final kundali = KundaliData.fromBirthDetails(
        id: 'test123',
        name: 'Test User',
        birthDateTime: DateTime(2000, 1, 1, 12, 0, 0),
        birthPlace: 'Delhi',
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: 'IST',
        gender: 'Male',
      );

      expect(kundali.id, 'test123');
      expect(kundali.name, 'Test User');
      expect(kundali.birthPlace, 'Delhi');
      expect(kundali.ascendant, isNotNull);
      expect(kundali.planetPositions.length, 9);
      expect(kundali.houses.length, 12);
      expect(kundali.dashaInfo, isNotNull);
      expect(kundali.moonSign, isNotEmpty);
      expect(kundali.sunSign, isNotEmpty);
      expect(kundali.birthNakshatra, isNotEmpty);
    });

    test('Should detect Yogas correctly', () {
      final kundali = KundaliData.fromBirthDetails(
        id: 'test456',
        name: 'Yoga Test',
        birthDateTime: DateTime(2000, 1, 1, 12, 0, 0),
        birthPlace: 'Mumbai',
        latitude: 19.0760,
        longitude: 72.8777,
        timezone: 'IST',
        gender: 'Female',
      );

      // Yogas list should be populated (may be empty depending on planetary positions)
      expect(kundali.yogas, isNotNull);
      expect(kundali.yogas, isA<List<String>>());
    });

    test('Should detect Doshas correctly', () {
      final kundali = KundaliData.fromBirthDetails(
        id: 'test789',
        name: 'Dosha Test',
        birthDateTime: DateTime(1990, 5, 15, 8, 30, 0),
        birthPlace: 'Bangalore',
        latitude: 12.9716,
        longitude: 77.5946,
        timezone: 'IST',
        gender: 'Male',
      );

      // Doshas list should be populated (may be empty depending on planetary positions)
      expect(kundali.doshas, isNotNull);
      expect(kundali.doshas, isA<List<String>>());
    });

    test('Should calculate Navamsa chart', () {
      final dateTime = DateTime(2024, 1, 1, 12, 0, 0);
      final latitude = 28.6139;
      final longitude = 77.2090;

      final birthChart = KundaliCalculationService.calculatePlanetaryPositions(
        dateTime,
        latitude,
        longitude,
      );

      final navamsaChart = KundaliCalculationService.calculateNavamsaChart(
        birthChart,
      );

      expect(navamsaChart.length, birthChart.length);

      for (var planet in navamsaChart.keys) {
        expect(birthChart.containsKey(planet), true);
        expect(navamsaChart[planet]!.longitude, greaterThanOrEqualTo(0));
        expect(navamsaChart[planet]!.longitude, lessThan(360));
      }
    });
  });

  group('Chart Style Tests', () {
    test('Should have correct display names', () {
      expect(ChartStyle.northIndian.displayName, 'North Indian');
      expect(ChartStyle.southIndian.displayName, 'South Indian');
      expect(ChartStyle.western.displayName, 'Western');
    });
  });

  group('KundaliData Model Tests', () {
    test('Should convert to JSON correctly', () {
      final kundali = KundaliData.fromBirthDetails(
        id: 'json_test',
        name: 'JSON Test User',
        birthDateTime: DateTime(2000, 1, 1, 12, 0, 0),
        birthPlace: 'Chennai',
        latitude: 13.0827,
        longitude: 80.2707,
        timezone: 'IST',
        gender: 'Female',
      );

      final json = kundali.toJson();

      expect(json['id'], 'json_test');
      expect(json['name'], 'JSON Test User');
      expect(json['birthPlace'], 'Chennai');
      expect(json['latitude'], 13.0827);
      expect(json['longitude'], 80.2707);
      expect(json['timezone'], 'IST');
      expect(json['gender'], 'Female');
      expect(json['ascendant'], isNotNull);
      expect(json['planetPositions'], isNotNull);
      expect(json['dashaInfo'], isNotNull);
    });

    test('Should copy with new values', () {
      final original = KundaliData.fromBirthDetails(
        id: 'copy_test',
        name: 'Original User',
        birthDateTime: DateTime(2000, 1, 1, 12, 0, 0),
        birthPlace: 'Kolkata',
        latitude: 22.5726,
        longitude: 88.3639,
        timezone: 'IST',
        gender: 'Male',
        chartStyle: ChartStyle.northIndian,
        language: 'English',
        isPrimary: false,
      );

      final copied = original.copyWith(
        chartStyle: ChartStyle.southIndian,
        language: 'Hindi',
        isPrimary: true,
      );

      expect(copied.id, original.id);
      expect(copied.name, original.name);
      expect(copied.chartStyle, ChartStyle.southIndian);
      expect(copied.language, 'Hindi');
      expect(copied.isPrimary, true);
      expect(copied.updatedAt, isNotNull);
    });
  });
}


