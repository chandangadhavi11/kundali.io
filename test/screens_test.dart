import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kundali_app/core/providers/auth_provider.dart';
import 'package:kundali_app/core/providers/theme_provider.dart';
import 'package:kundali_app/core/providers/language_provider.dart';
import 'package:kundali_app/core/providers/horoscope_provider.dart';
import 'package:kundali_app/core/providers/panchang_provider.dart';
import 'package:kundali_app/core/providers/chat_provider.dart';
import 'package:kundali_app/core/providers/kundli_provider.dart';

// Import all screens
import 'package:kundali_app/features/home/screens/home_screen.dart';
import 'package:kundali_app/features/home/screens/main_navigation_screen.dart';
import 'package:kundali_app/features/horoscope/screens/horoscope_screen.dart';
import 'package:kundali_app/features/panchang/screens/panchang_screen.dart';
import 'package:kundali_app/features/chat/screens/ai_chat_screen.dart';
import 'package:kundali_app/features/profile/screens/profile_screen.dart';
import 'package:kundali_app/features/profile/screens/my_kundlis_screen.dart';
import 'package:kundali_app/features/profile/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences mockPrefs;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    mockPrefs = await SharedPreferences.getInstance();
  });

  // Helper to wrap widget with providers
  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(mockPrefs)),
        ChangeNotifierProvider(create: (_) => LanguageProvider(mockPrefs)),
        ChangeNotifierProvider(create: (_) => HoroscopeProvider()),
        ChangeNotifierProvider(create: (_) => PanchangProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => KundliProvider()),
      ],
      child: MaterialApp(home: child),
    );
  }

  group('Screen Runtime Tests', () {
    testWidgets('HomeScreen should build without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const HomeScreen()));
      // Allow initial build
      await tester.pump();
      // Allow post frame callbacks to run
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('MainNavigationScreen should build without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(MainNavigationScreen(child: Container())),
      );
      await tester.pump();
      expect(find.byType(MainNavigationScreen), findsOneWidget);
    });

    testWidgets('HoroscopeScreen should build without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const HoroscopeScreen()));
      await tester.pump();
      // Allow animations to start
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(HoroscopeScreen), findsOneWidget);
    });

    testWidgets('PanchangScreen should build without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const PanchangScreen()));
      await tester.pump();
      // Allow animations to start
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(PanchangScreen), findsOneWidget);
    });

    testWidgets('AiChatScreen should build without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const AiChatScreen()));
      await tester.pump();
      // Allow animations to start
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(AiChatScreen), findsOneWidget);
    });

    testWidgets('ProfileScreen should build without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const ProfileScreen()));
      await tester.pump();
      // Allow animations to start
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('MyKundlisScreen should build without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const MyKundlisScreen()));
      await tester.pump();
      // Allow animations to start
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(MyKundlisScreen), findsOneWidget);
    });

    testWidgets('SettingsScreen should build without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pump();
      // Allow animations to start
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });
}
