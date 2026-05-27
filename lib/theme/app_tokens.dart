import 'package:flutter/material.dart';

/// FitNow design tokens — перенесено 1:1 из window.V2_TOKENS (UI kit).
///
/// Дисциплина акцента (как в исходной ДС):
///   • LIME (#B0EC3D)  — ТОЛЬКО главные CTA («Начать», «Начать тренировку»)
///                       и активная вкладка таб-бара. Больше нигде.
///   • GOLD (#FFC93C)  — streak, личные рекорды (PR), Premium, прогресс-бары,
///                       тренды, активные «сегодня» бары в графике.
///   • MUTED_GREEN     — позитивные дельты (+18%, +4 кг).
///   • Остальное       — нейтральная графитовая палитра.
class AppColors {
  AppColors._();

  // Структурные
  static const bg = Color(0xFF0E0E10);
  static const surface = Color(0xFF1A1A1D);
  static const surface2 = Color(0xFF252528);
  static const border = Color(0x12FFFFFF); // rgba(255,255,255,0.07)

  // Текст
  static const text = Color(0xFFFFFFFF);
  static const eyebrow = Color(0xFFA8A8AD);
  static const dim = Color(0xB3FFFFFF); // rgba(255,255,255,0.70)
  static const dim2 = Color(0x8CFFFFFF); // rgba(255,255,255,0.55)

  // Акценты
  static const lime = Color(0xFFB0EC3D); // главный CTA + активный таб
  static const gold = Color(0xFFFFC93C); // streak / PR / premium / progress
  static const mutedGreen = Color(0xFF4ADE80);
  static const softGreen = Color(0xFF5FB875);

  // Уровни сложности
  static const levelEasy = Color(0xFF5FB875);
  static const levelMed = Color(0xFFD9A058);
  static const levelHard = Color(0xFFE07A7A);

  // Прочее
  static const chartGray = Color(0xFF4A4A4E);
  static const notify = Color(0xFFFF4D4D);
  static const danger = Color(0xFFFF6B6B);

  // Тинты, которые в JSX задавались инлайном
  static Color whiteAlpha(double a) => Colors.white.withValues(alpha: a);
  static Color goldTint(double a) => gold.withValues(alpha: a);
  static Color greenTint(double a) => mutedGreen.withValues(alpha: a);
}

/// Радиусы — собрано из значений borderRadius по всем экранам.
class AppRadius {
  AppRadius._();
  static const xs = 6.0; // мелкие бейджи
  static const sm = 8.0; // чипы-теги, бары
  static const md = 12.0; // кнопки, segmented, фильтры
  static const lg = 16.0; // workout rows, мелкие карточки
  static const xl = 18.0; // PR/goal карточки
  static const xxl = 20.0; // stats, settings блоки
  static const xxxl = 24.0; // крупные карточки (weekly)
  static const pill = 999.0; // streak, level chip
}

/// Отступы — 4-кратная шкала.
class AppSpacing {
  AppSpacing._();
  static const x2 = 2.0;
  static const x4 = 4.0;
  static const x6 = 6.0;
  static const x8 = 8.0;
  static const x10 = 10.0;
  static const x12 = 12.0;
  static const x14 = 14.0;
  static const x16 = 16.0;
  static const x18 = 18.0;
  static const x20 = 20.0;
  static const x22 = 22.0;
  static const x24 = 24.0;
  static const x28 = 28.0;

  /// Горизонтальный отступ контента экранов (в JSX был 16–20).
  static const screenH = 20.0;
}
