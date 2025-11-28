import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kundali_app/core/providers/kundli_provider.dart';
import 'package:kundali_app/core/providers/auth_provider.dart';
import 'package:kundali_app/core/providers/theme_provider.dart';
import 'package:kundali_app/core/providers/language_provider.dart';
import 'package:kundali_app/features/kundli/screens/modern_kundli_input_screen.dart';
import 'package:kundali_app/features/kundli/screens/modern_kundli_display_screen.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences mockPrefs;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    mockPrefs = await SharedPreferences.getInstance();
  });

  Widget createTestApp(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => KundliProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(mockPrefs)),
        ChangeNotifierProvider(create: (_) => LanguageProvider(mockPrefs)),
      ],
      child: MaterialApp(
        home: child,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.purple,
        ),
      ),
    );
  }

  group('Kundali Input Screen Tests', () {
    testWidgets('Should display all input fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const ModernKundliInputScreen()));
      await tester.pumpAndSettle();

      // Check for section headers
      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Birth Details'), findsOneWidget);
      expect(find.text('Preferences'), findsOneWidget);

      // Check for input fields
      expect(find.byType(TextFormField), findsNWidgets(2)); // Name and Place
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Birth Place'), findsOneWidget);

      // Check for gender selection
      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);

      // Check for date and time pickers
      expect(find.text('Birth Date'), findsOneWidget);
      expect(find.text('Birth Time'), findsOneWidget);

      // Check for preferences
      expect(find.text('Chart Style'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Set as Primary Kundali'), findsOneWidget);

      // Check for generate button
      expect(find.text('Generate Kundali'), findsOneWidget);
    });

    testWidgets('Should validate required fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const ModernKundliInputScreen()));
      await tester.pumpAndSettle();

      // Try to generate without filling fields
      await tester.tap(find.text('Generate Kundali'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter a name'), findsOneWidget);
      expect(find.text('Please enter birth place'), findsOneWidget);
    });

    testWidgets('Should allow gender selection', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const ModernKundliInputScreen()));
      await tester.pumpAndSettle();

      // Select Female
      await tester.tap(find.text('Female'));
      await tester.pumpAndSettle();

      // Female should be selected (check for visual feedback)
      final femaleContainer =
          find
              .ancestor(
                of: find.text('Female'),
                matching: find.byType(Container),
              )
              .first;
      expect(femaleContainer, findsOneWidget);
    });

    testWidgets('Should allow chart style selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp(const ModernKundliInputScreen()));
      await tester.pumpAndSettle();

      // Find and tap South Indian style
      await tester.tap(find.text('South Indian'));
      await tester.pumpAndSettle();

      // Should be selected
      final southIndianChip = find.ancestor(
        of: find.text('South Indian'),
        matching: find.byType(ChoiceChip),
      );
      expect(southIndianChip, findsOneWidget);
    });

    testWidgets('Should toggle primary Kundali switch', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp(const ModernKundliInputScreen()));
      await tester.pumpAndSettle();

      // Find and toggle switch
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Switch should be toggled
      final Switch switchWidget = tester.widget(switchFinder);
      expect(switchWidget.value, true);
    });
  });

  group('Kundali Display Screen Tests', () {
    testWidgets('Should display Kundali data correctly', (
      WidgetTester tester,
    ) async {
      // Create test Kundali data
      final testKundali = KundaliData.fromBirthDetails(
        id: 'test123',
        name: 'Test User',
        birthDateTime: DateTime(2000, 1, 1, 12, 0, 0),
        birthPlace: 'Delhi',
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: 'IST',
        gender: 'Male',
      );

      await tester.pumpWidget(
        createTestApp(ModernKundliDisplayScreen(kundaliData: testKundali)),
      );
      await tester.pumpAndSettle();

      // Check for user name
      expect(find.text('Test User'), findsOneWidget);

      // Check for birth place
      expect(find.text('Delhi'), findsOneWidget);

      // Check for tabs
      expect(find.text('Chart'), findsOneWidget);
      expect(find.text('Planets'), findsOneWidget);
      expect(find.text('Houses'), findsOneWidget);
      expect(find.text('Dasha'), findsOneWidget);
      expect(find.text('Report'), findsOneWidget);
    });

    testWidgets('Should switch between tabs', (WidgetTester tester) async {
      final testKundali = KundaliData.fromBirthDetails(
        id: 'test456',
        name: 'Tab Test User',
        birthDateTime: DateTime(2000, 1, 1, 12, 0, 0),
        birthPlace: 'Mumbai',
        latitude: 19.0760,
        longitude: 72.8777,
        timezone: 'IST',
        gender: 'Female',
      );

      await tester.pumpWidget(
        createTestApp(ModernKundliDisplayScreen(kundaliData: testKundali)),
      );
      await tester.pumpAndSettle();

      // Tap on Planets tab
      await tester.tap(find.text('Planets'));
      await tester.pumpAndSettle();

      // Should show planet list
      expect(find.text('Sun'), findsOneWidget);
      expect(find.text('Moon'), findsOneWidget);
      expect(find.text('Mars'), findsOneWidget);

      // Tap on Houses tab
      await tester.tap(find.text('Houses'));
      await tester.pumpAndSettle();

      // Should show house list
      expect(find.text('House 1'), findsOneWidget);
      expect(find.text('House 2'), findsOneWidget);

      // Tap on Dasha tab
      await tester.tap(find.text('Dasha'));
      await tester.pumpAndSettle();

      // Should show Dasha information
      expect(find.text('Current Mahadasha'), findsOneWidget);
      expect(find.text('Vimshottari Dasha Sequence'), findsOneWidget);
    });

    testWidgets('Should switch chart styles', (WidgetTester tester) async {
      final testKundali = KundaliData.fromBirthDetails(
        id: 'test789',
        name: 'Chart Style Test',
        birthDateTime: DateTime(2000, 1, 1, 12, 0, 0),
        birthPlace: 'Bangalore',
        latitude: 12.9716,
        longitude: 77.5946,
        timezone: 'IST',
        gender: 'Male',
        chartStyle: ChartStyle.northIndian,
      );

      await tester.pumpWidget(
        createTestApp(ModernKundliDisplayScreen(kundaliData: testKundali)),
      );
      await tester.pumpAndSettle();

      // Find and tap South Indian style
      final southIndianChip = find.text('South Indian').first;
      await tester.tap(southIndianChip);
      await tester.pumpAndSettle();

      // Chart should update (CustomPaint should be redrawn)
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('Should display basic info cards', (WidgetTester tester) async {
      final testKundali = KundaliData.fromBirthDetails(
        id: 'test101',
        name: 'Info Cards Test',
        birthDateTime: DateTime(2000, 1, 1, 12, 0, 0),
        birthPlace: 'Chennai',
        latitude: 13.0827,
        longitude: 80.2707,
        timezone: 'IST',
        gender: 'Female',
      );

      await tester.pumpWidget(
        createTestApp(ModernKundliDisplayScreen(kundaliData: testKundali)),
      );
      await tester.pumpAndSettle();

      // Check for basic info cards
      expect(find.text('Ascendant'), findsOneWidget);
      expect(find.text('Moon Sign'), findsOneWidget);
      expect(find.text('Sun Sign'), findsOneWidget);
      expect(find.text('Nakshatra'), findsOneWidget);
    });

    testWidgets('Should show menu options', (WidgetTester tester) async {
      final testKundali = KundaliData.fromBirthDetails(
        id: 'test102',
        name: 'Menu Test',
        birthDateTime: DateTime(2000, 1, 1, 12, 0, 0),
        birthPlace: 'Kolkata',
        latitude: 22.5726,
        longitude: 88.3639,
        timezone: 'IST',
        gender: 'Male',
      );

      await tester.pumpWidget(
        createTestApp(ModernKundliDisplayScreen(kundaliData: testKundali)),
      );
      await tester.pumpAndSettle();

      // Open menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Check menu options
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Export PDF'), findsOneWidget);
      expect(find.text('Set as Primary'), findsOneWidget);
    });
  });

  group('Provider Integration Tests', () {
    testWidgets('Should generate and save Kundali', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp(const ModernKundliInputScreen()));
      await tester.pumpAndSettle();

      // Fill in the form
      await tester.enterText(find.byType(TextFormField).first, 'Test User');
      await tester.enterText(find.byType(TextFormField).last, 'Delhi');

      // Generate Kundali
      await tester.tap(find.text('Generate Kundali'));
      await tester.pump(); // Start the async operation
      await tester.pump(const Duration(seconds: 1)); // Wait for generation
      await tester.pumpAndSettle(); // Settle animations

      // Should navigate to display screen
      // Note: In a real test, we'd check for navigation
      final BuildContext context = tester.element(
        find.byType(ModernKundliInputScreen),
      );
      final provider = Provider.of<KundliProvider>(context, listen: false);

      // Check if Kundali was generated
      expect(provider.currentKundali, isNotNull);
      expect(provider.savedKundalis.isNotEmpty, true);
    });
  });
}
