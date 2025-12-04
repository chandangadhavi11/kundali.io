import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/profile_setup_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/navigation/main_navigation_screen.dart';
import '../../features/kundli/screens/kundli_input_screen.dart';
import '../../features/kundli/screens/kundli_display_screen.dart';
import '../../features/panchang/screens/panchang_screen.dart';
import '../../features/horoscope/screens/horoscope_screen.dart';
import '../../features/chat/screens/ai_chat_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/compatibility/screens/compatibility_screen.dart';
import '../../features/subscription/screens/subscription_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profileSetup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainNavigationScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/horoscope',
            name: 'horoscope',
            builder: (context, state) => const HoroscopeScreen(),
          ),
          GoRoute(
            path: '/panchang',
            name: 'panchang',
            builder: (context, state) => const PanchangScreen(),
          ),
          GoRoute(
            path: '/chat',
            name: 'chat',
            builder: (context, state) => const AiChatScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/kundli/input',
        name: 'kundliInput',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const KundliInputScreen(),
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 150),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fast, smooth slide-up transition
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        ),
      ),
      GoRoute(
        path: '/kundli/display',
        name: 'kundliDisplay',
        builder: (context, state) => const KundliDisplayScreen(),
      ),
      GoRoute(
        path: '/compatibility',
        name: 'compatibility',
        builder: (context, state) => const CompatibilityScreen(),
      ),
      GoRoute(
        path: '/subscription',
        name: 'subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Page not found',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  state.error?.toString() ?? 'Unknown error',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
  );
}
