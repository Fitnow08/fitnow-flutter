import 'package:fitnow/core/state/onboarding_provider.dart';
import 'package:fitnow/presentation/auth/pages/forgot_password.dart';
import 'package:fitnow/presentation/auth/pages/login.dart';
import 'package:fitnow/presentation/auth/pages/register.dart';
import 'package:fitnow/presentation/intro/pages/get_started.dart';
import 'package:fitnow/presentation/start/pages/hello.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static GoRouter router(WidgetRef ref) {
    final seenHello = ref.read(onboardingProvider);
    return GoRouter(
      initialLocation: seenHello ? '/' : '/hello',
      routes: [
        GoRoute(path: '/hello', builder: (context, state) => const HelloPage()),
        GoRoute(path: '/', builder: (context, state) => const GetStartedPage()),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),
      ],
    );
  }
}
