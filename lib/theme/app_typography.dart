import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_tokens.dart';

/// Текстовые стили FitNow на Manrope.
/// Размеры/веса/letter-spacing сняты с JSX 1:1.
class AppText {
  AppText._();

  static TextStyle _m({
    required double size,
    required FontWeight weight,
    Color color = AppColors.text,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  // Заголовки экранов
  static TextStyle get screenTitle =>
      _m(size: 28, weight: FontWeight.w800, letterSpacing: -0.6);
  static TextStyle get bigTitle =>
      _m(size: 26, weight: FontWeight.w800, letterSpacing: -0.5, height: 1.1);

  // Метрики (крупные числа)
  static TextStyle get metricXl =>
      _m(size: 32, weight: FontWeight.w800, letterSpacing: -0.8, height: 1.0);
  static TextStyle get metricLg =>
      _m(size: 22, weight: FontWeight.w800, letterSpacing: -0.4);

  // Секции
  static TextStyle get sectionTitle =>
      _m(size: 18, weight: FontWeight.w800, letterSpacing: -0.3);

  // Карточки / контент
  static TextStyle get cardTitle =>
      _m(size: 16, weight: FontWeight.w700, letterSpacing: -0.3);
  static TextStyle get body =>
      _m(size: 14, weight: FontWeight.w600, letterSpacing: -0.2);

  // Подписи / мета
  static TextStyle get meta =>
      _m(size: 12, weight: FontWeight.w500, color: AppColors.eyebrow);
  static TextStyle get metaSmall =>
      _m(size: 11, weight: FontWeight.w500, color: AppColors.eyebrow);

  // Eyebrow (мелкий заглавный)
  static TextStyle get eyebrow => _m(
        size: 11,
        weight: FontWeight.w700,
        color: AppColors.eyebrow,
        letterSpacing: 1.0,
      );

  // Лейблы кнопок/чипов
  static TextStyle get label =>
      _m(size: 13, weight: FontWeight.w600);
  static TextStyle get badge =>
      _m(size: 10.5, weight: FontWeight.w800, letterSpacing: 0.4);
}

ThemeData buildFitNowTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: GoogleFonts.manropeTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.text, displayColor: AppColors.text),
    colorScheme: base.colorScheme.copyWith(
      surface: AppColors.bg,
      primary: AppColors.lime,
      secondary: AppColors.gold,
    ),
  );
}
