import 'package:go_router/go_router.dart';

import '../state/app_state.dart';
import '../../features/authentication/screens/splash_screen.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/onboarding/screens/onboarding_step1_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/iv/screens/iv_chat_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: appState,
  redirect: (context, state) {
    final p = state.uri.path;

    if (p == '/splash') {
      return null;
    }

    if (!appState.signedIn && p != '/login') {
      return '/login';
    }

    if (appState.signedIn && p == '/login') {
      return appState.onboardingComplete
          ? '/dashboard'
          : '/onboarding/step-1';
    }

    if (appState.signedIn &&
        !appState.onboardingComplete &&
        p != '/onboarding/step-1') {
      return '/onboarding/step-1';
    }

    if (appState.signedIn &&
        appState.onboardingComplete &&
        p == '/onboarding/step-1') {
      return '/dashboard';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/onboarding/step-1',
      builder: (_, __) => const OnboardingWizard(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (_, __) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/iv',
      builder: (_, __) => const IvChatScreen(),
    ),
  ],
);
