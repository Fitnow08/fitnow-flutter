import 'package:fitnow/core/configs/assets/app_images.dart';
import 'package:fitnow/core/configs/theme/app_colors.dart';
import 'package:fitnow/core/configs/theme/app_spacing.dart';
import 'package:fitnow/core/state/onboarding_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HelloPage extends ConsumerWidget {
  const HelloPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screen,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Добро пожаловать", style: AppFontSize.helloText),
                  Text.rich(
                    TextSpan(
                      style: AppFontSize.helloTexth1,
                      children: [
                        TextSpan(
                          text: 'Fit',
                          style: TextStyle(color: AppColors.green),
                        ),
                        const TextSpan(text: 'Now приложение'),
                      ],
                    ),
                  ),
                ],
              ),
              Center(child: Image.asset(AppImages.logo)),
              Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 36),
                      child: Text.rich(
                        TextSpan(
                          style: AppFontSize.helloText,
                          children: [
                            TextSpan(
                              text: 'Discover',
                              style: TextStyle(color: AppColors.green),
                            ),
                            const TextSpan(text: ' workout with our app'),
                          ],
                        ),
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(onboardingProvider.notifier)
                            .setSeen(true);
                        if (!context.mounted) return;
                        context.go('/login');
                      },
                      child: const Text('Продолжить'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
