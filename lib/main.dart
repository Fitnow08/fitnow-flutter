import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_tokens.dart';
import 'theme/app_typography.dart';
import 'widgets/tab_bar.dart';
import 'screens/home_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/programs_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/onboarding_screen.dart';

void main() => runApp(const FitNowApp());

class FitNowApp extends StatefulWidget {
  const FitNowApp({super.key});
  @override
  State<FitNowApp> createState() => _FitNowAppState();
}

class _FitNowAppState extends State<FitNowApp> {
  bool _loading = true;
  bool _onboarded = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _onboarded = prefs.getBool(OnboardingPrefs.done) ?? false;
      _loading = false;
    });
  }

  void _finishOnboarding() => setState(() => _onboarded = true);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitNow',
      debugShowCheckedModeBanner: false,
      theme: buildFitNowTheme(),
      home: _loading
          ? const Scaffold(backgroundColor: AppColors.bg, body: SizedBox.shrink())
          : (_onboarded
              ? const RootShell()
              : OnboardingScreen(onFinish: _finishOnboarding)),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  HomeMode _homeMode = HomeMode.active;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(mode: _homeMode),
      const ProgressScreen(),
      const ProgramsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned.fill(child: IndexedStack(index: _index, children: screens)),
          if (_index == 0) _homeModeSwitcher(),
          FitNowTabBar(
            activeIndex: _index,
            onChange: (i) => setState(() => _index = i),
          ),
        ],
      ),
    );
  }

  Widget _homeModeSwitcher() {
    Widget chip(HomeMode m, String label) {
      final active = _homeMode == m;
      return GestureDetector(
        onTap: () => setState(() => _homeMode = m),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.lime : AppColors.surface2,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(label,
              style: AppText.metaSmall.copyWith(
                  fontSize: 11,
                  color: active ? AppColors.bg : AppColors.text,
                  fontWeight: FontWeight.w700)),
        ),
      );
    }

    return Positioned(
      right: 12,
      bottom: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          chip(HomeMode.active, 'active'),
          const SizedBox(height: 6),
          chip(HomeMode.empty, 'empty'),
          const SizedBox(height: 6),
          chip(HomeMode.loading, 'loading'),
        ],
      ),
    );
  }
}
