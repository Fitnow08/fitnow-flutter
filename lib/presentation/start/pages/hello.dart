import 'package:fitnow/core/configs/assets/app_images.dart';
import 'package:fitnow/core/configs/theme/app_colors.dart';
import 'package:fitnow/core/configs/theme/app_spacing.dart';
import 'package:fitnow/presentation/intro/pages/get_started.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HelloPage extends StatelessWidget {
  const HelloPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                    Builder(
                      builder: (context) => ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GetStartedPage(),
                          ),
                        ),
                        child: const Text("Продолжить"),
                      ),
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
