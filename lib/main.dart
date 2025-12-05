import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/providers/app_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/kundli_provider.dart';
import 'core/providers/panchang_provider.dart';
import 'core/providers/horoscope_provider.dart';
import 'core/providers/chat_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/compatibility_provider.dart';
import 'core/services/sweph_service.dart';
import 'core/services/chat_storage_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize Swiss Ephemeris for astronomical calculations
  await SwephService.initialize();

  // Initialize Chat Storage Service for AI chat persistence
  await ChatStorageService.instance.initialize();

  // Initialize Firebase (commented out for now as it needs configuration)
  // await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => KundliProvider()),
        ChangeNotifierProvider(create: (_) => PanchangProvider()),
        ChangeNotifierProvider(create: (_) => HoroscopeProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => CompatibilityProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
      ],
      child: const KundaliApp(),
    ),
  );
}

class KundaliApp extends StatelessWidget {
  const KundaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp.router(
          title: 'Kundali',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          locale: languageProvider.currentLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', ''), Locale('hi', '')],
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
