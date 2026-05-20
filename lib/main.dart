import 'package:firebase_core/firebase_core.dart';
import 'package:fitnow/core/configs/routers/routers.dart';
import 'package:fitnow/core/configs/services/notification.dart';
import 'package:fitnow/core/configs/services/onboarding.dart';
import 'package:fitnow/core/configs/theme/app_theme.dart';
import 'package:fitnow/firebase_options.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: '.env');
  final notificationService = NotificationService();
  await notificationService.initialize();
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      onboardingServiceProvider.overrideWithValue(OnboardingService(prefs)),
    ],
  );
  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Fitnow',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router(ref),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
    );
  }
}
