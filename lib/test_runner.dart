import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/horoscope_provider.dart';
import 'core/providers/panchang_provider.dart';
import 'core/providers/chat_provider.dart';
import 'core/providers/kundli_provider.dart';
import 'core/providers/app_provider.dart';

// Import screens to test
import 'features/home/screens/home/home_screen.dart';
import 'features/horoscope/screens/horoscope/horoscope_screen.dart';
import 'features/panchang/screens/panchang/panchang_screen.dart';
import 'features/chat/screens/ai_chat/ai_chat_screen.dart';
import 'features/profile/screens/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(TestRunnerApp(prefs: prefs));
}

class TestRunnerApp extends StatelessWidget {
  final SharedPreferences prefs;

  const TestRunnerApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => LanguageProvider(prefs)),
        ChangeNotifierProvider(create: (_) => HoroscopeProvider()),
        ChangeNotifierProvider(create: (_) => PanchangProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => KundliProvider()),
      ],
      child: MaterialApp(
        title: 'UI Test Runner',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5CE7)),
          useMaterial3: true,
        ),
        home: const TestNavigator(),
      ),
    );
  }
}

class TestNavigator extends StatelessWidget {
  const TestNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Test Runner'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTestButton(
            context,
            'Test Home Screen',
            const HomeScreen(),
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildTestButton(
            context,
            'Test Horoscope Screen',
            const HoroscopeScreen(),
            Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildTestButton(
            context,
            'Test Panchang Screen',
            const PanchangScreen(),
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildTestButton(
            context,
            'Test Chat Screen',
            const AiChatScreen(),
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildTestButton(
            context,
            'Test Profile Screen',
            const ProfileScreen(),
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(
    BuildContext context,
    String title,
    Widget screen,
    Color color,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}


