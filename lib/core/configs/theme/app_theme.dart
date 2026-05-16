import 'package:fitnow/core/configs/theme/app_colors.dart';

import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.dartBG,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
  );
  static final darkTheme = ThemeData(
    primaryColor: AppColors.white,
    scaffoldBackgroundColor: AppColors.dartBG,
    brightness: Brightness.dark,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.fullDark,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 17,
          color: AppColors.fullDark,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),
  );
}
