import 'package:fitnow/core/configs/services/onboarding.dart';
import 'package:fitnow/core/configs/theme/app_theme.dart';
import 'package:fitnow/core/state/onboarding_provider.dart';
import 'package:fitnow/presentation/intro/pages/get_started.dart';
import 'package:fitnow/presentation/start/pages/hello.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        onboardingServiceProvider.overrideWithValue(OnboardingService(prefs)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seenHello = ref.watch(onboardingProvider);

    return MaterialApp(
      title: 'Fitnow',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: seenHello ? const GetStartedPage() : const HelloPage(),
    );
  }
}
