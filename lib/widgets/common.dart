import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';

/// Заглушка фото вместо Unsplash. Градиентный блок + иконка по центру.
/// Когда появятся реальные ассеты — заменить на Image.asset/Image.network.
class PhotoPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final IconData icon;
  final bool darkScrim; // нижний градиент-скрим как в kit

  const PhotoPlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    this.icon = Icons.fitness_center,
    this.darkScrim = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A2A30), Color(0xFF17171A)],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Icon(icon, color: AppColors.whiteAlpha(0.18), size: 34),
            ),
            if (darkScrim)
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xC7000000)],
                    stops: [0.5, 1.0],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Прямоугольный бейдж (Активна / TOP 10 / NEW / PR).
class PillBadge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const PillBadge({super.key, required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.xs)),
      child: Text(text.toUpperCase(),
          style: AppText.badge.copyWith(color: fg, letterSpacing: 0.5)),
    );
  }
}

/// Чип-фильтр (Все / Сила / Кардио…). active = белый фон.
class FilterChipBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const FilterChipBtn({super.key, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? AppColors.text : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: active ? null : Border.all(color: AppColors.border),
        ),
        child: Text(label,
            style: AppText.label.copyWith(color: active ? AppColors.bg : AppColors.text)),
      ),
    );
  }
}

/// Прогресс-бар (тонкая полоса с заливкой). Цвет заливки задаётся (gold/white).
class ProgressLine extends StatelessWidget {
  final double value; // 0..1
  final Color fill;
  final double height;
  const ProgressLine({super.key, required this.value, this.fill = AppColors.gold, this.height = 5});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: AppColors.whiteAlpha(0.06),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0, 1),
          child: Container(color: fill),
        ),
      ),
    );
  }
}

/// Карточка-поверхность (фон surface + бордер + радиус). База почти всего.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Border? border;
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.x16),
    this.radius = AppRadius.xxl,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: border ?? Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
