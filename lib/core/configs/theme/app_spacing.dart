import 'package:fitnow/core/configs/theme/app_colors.dart';
import 'package:flutter/material.dart';

abstract class AppSpacing {
  static const screen = EdgeInsets.symmetric(horizontal: 16);
  static const inputMargin = EdgeInsets.only(top: 32);

  static const inputGap = 12.0;
  static const marginLoginBTN = 24.0;
  static const marginForgotPassword = 12.0;
}

abstract class AppBorderRadius {
  static const borderRadiusInput = 16.0;
}

abstract class AppFontSize {
  static const inputText = 17.0;
  static const TextStyle helloTexth1 = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static const TextStyle helloText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );
  static const TextStyle loginTexth1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static const TextStyle loginText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );
  static const TextStyle forgotPasswordText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: AppColors.white,
  );
}
