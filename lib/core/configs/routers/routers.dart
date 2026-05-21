import 'package:fitnow/common/widgets/nav_bar/scaffold_with_nav_bar.dart';
import 'package:fitnow/core/state/onboarding_provider.dart';
import 'package:fitnow/presentation/auth/pages/forgot_password.dart';
import 'package:fitnow/presentation/auth/pages/login.dart';
import 'package:fitnow/presentation/auth/pages/register.dart';
import 'package:fitnow/presentation/home/pages/home.dart';
import 'package:fitnow/presentation/profile/pages/profile.dart';
import 'package:fitnow/presentation/program/pages/program.dart';
import 'package:fitnow/presentation/progress/pages/progrss.dart';
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

        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return ScaffoldWithNavBar(navigationShell: navigationShell);
          },

          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const HomePage(),
                ),
              ],
            ),

            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfilePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/progress',
                  builder: (context, state) => const ProgressPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/program',
                  builder: (context, state) => const ProgramPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
