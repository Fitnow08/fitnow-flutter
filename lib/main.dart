import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/auth_service.dart';
import 'theme/app_tokens.dart';
import 'theme/app_typography.dart'; // нужен для buildFitNowTheme()
import 'widgets/app_restart.dart';

// Экраны:
import 'screens/sign_in_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/root_screen.dart';

void main() {
  runApp(const AppRestart(child: FitNowApp()));
}

class FitNowApp extends StatelessWidget {
  const FitNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitNow',
      debugShowCheckedModeBanner: false,
      theme: buildFitNowTheme(),
      home: const _Bootstrap(),
    );
  }
}

/// Решает, какой экран показать первым.
///
/// Логика:
///   1) Не авторизован                    → SignInScreen
///   2) Авторизован, онбординг не пройден → OnboardingScreen
///   3) Авторизован + онбординг пройден   → RootScreen (4 вкладки)
///
/// После входа/регистрации auth-экраны вызывают AppRestart.restart(),
/// который пересоздаёт всё дерево от корня — _Bootstrap заново читает
/// флаги и показывает нужный экран. Онбординг делает то же через onFinish.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  // null = ещё определяем (показываем сплэш).
  _StartupState? _state;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    debugPrint('[BOOTSTRAP] _resolve() start');
    final authed = await AuthService.isAuthenticated();
    debugPrint('[BOOTSTRAP] authed=$authed mounted=$mounted');
    if (!mounted) return;

    if (!authed) {
      setState(() => _state = _StartupState.signIn);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    debugPrint('[BOOTSTRAP] onboardingDone=$onboardingDone -> '
        '${onboardingDone ? "home" : "onboarding"}');
    if (!mounted) return;

    setState(() {
      _state = onboardingDone ? _StartupState.home : _StartupState.onboarding;
    });
  }

  /// Вызывается из auth-экранов и онбординга — пересоздаёт дерево от
  /// корня (AppRestart) или показывает нужный экран по флагам.

  @override
  Widget build(BuildContext context) {
    final state = _state;

    if (state == null) {
      // Тихий чёрный сплэш, пока читаем флаги (это миллисекунды).
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: SizedBox.shrink(),
      );
    }

    switch (state) {
      case _StartupState.signIn:
        return const SignInScreen();
      case _StartupState.onboarding:
        return OnboardingScreen(
          onFinish: () => AppRestart.restart(context),
        );
      case _StartupState.home:
        return const RootScreen();
    }
  }
}

enum _StartupState { signIn, onboarding, home }
