import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import 'common.dart';

/// Цвет уровня сложности
Color levelColor(String lvl) {
  switch (lvl) {
    case 'Легко':
      return AppColors.levelEasy;
    case 'Средне':
      return AppColors.levelMed;
    case 'Сильно':
    case 'Сложно':
      return AppColors.levelHard;
    default:
      return AppColors.eyebrow;
  }
}

/// Обложка-заглушка сверху экрана деталей (вместо фото)
class DetailCover extends StatelessWidget {
  final IconData icon;
  final Widget? floatingChip;
  final double height;
  const DetailCover({super.key, this.icon = Icons.fitness_center, this.floatingChip, this.height = 340});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Градиентная заглушка вместо фото
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2A2A30), Color(0xFF17171A)],
              ),
            ),
            child: Center(child: Icon(icon, color: AppColors.whiteAlpha(0.14), size: 56)),
          ),
          // Скрим снизу (чтобы текст под обложкой читался) — как в JSX
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x73000000), Colors.transparent, Color(0xF20E0E10)],
                stops: [0.0, 0.35, 1.0],
              ),
            ),
          ),
          if (floatingChip != null)
            Positioned(left: 20, bottom: 18, child: floatingChip!),
        ],
      ),
    );
  }
}

/// Плавающий чип на обложке (длительность / тип)
class DetailFloatingChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const DetailFloatingChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0x8C000000),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.whiteAlpha(0.12)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: AppColors.text, size: 13),
            const SizedBox(width: 6),
            Text(label, style: AppText.metaSmall.copyWith(fontSize: 12.5, color: AppColors.text, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

/// Шапка поверх обложки: кнопки назад и поделиться
class DetailHeaderOverlay extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback? onShare;
  const DetailHeaderOverlay({super.key, required this.onBack, this.onShare});

  Widget _btn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x8C000000),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.whiteAlpha(0.12)),
            ),
            child: Icon(icon, color: AppColors.text, size: 18),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 56,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _btn(AppIcons.chevronLeft, onBack),
          _btn(AppIcons.share, onShare ?? () {}),
        ],
      ),
    );
  }
}

/// Sticky-кнопка внизу с градиентной подложкой
class DetailStickyCta extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const DetailStickyCta({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x000E0E10), Color(0xEB0E0E10), Color(0xFF0E0E10)],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.lime,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [BoxShadow(color: AppColors.lime.withValues(alpha: 0.25), blurRadius: 32, offset: const Offset(0, 12))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: AppText.cardTitle.copyWith(color: AppColors.bg, fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                const Icon(AppIcons.arrowRight, color: AppColors.bg, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Рейтинг-пилюля (звезда + число), gold
class RatingPill extends StatelessWidget {
  final double rating;
  const RatingPill({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.goldTint(0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.goldTint(0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(AppIcons.star, color: AppColors.gold, size: 11),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1), style: AppText.metaSmall.copyWith(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

/// Чип уровня сложности (цветной)
class LevelChip extends StatelessWidget {
  final String level;
  const LevelChip({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final c = levelColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(8)),
      child: Text(level, style: AppText.metaSmall.copyWith(fontSize: 11, color: c, fontWeight: FontWeight.w700)),
    );
  }
}

/// Нейтральный чип (тег)
class NeutralChip extends StatelessWidget {
  final String label;
  const NeutralChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: AppText.metaSmall.copyWith(fontSize: 11, color: AppColors.text, fontWeight: FontWeight.w600)),
    );
  }
}

/// Ряд из 3 метрик в карточке
class MetricsRow extends StatelessWidget {
  final List<({String value, String label, Color? color})> items;
  const MetricsRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: SurfaceCard(
        radius: AppRadius.xxl,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0) Container(width: 1, color: AppColors.whiteAlpha(0.06)),
                Expanded(
                  child: Column(
                    children: [
                      Text(items[i].value, style: AppText.metricLg.copyWith(color: items[i].color ?? AppColors.text, height: 1.0)),
                      const SizedBox(height: 4),
                      Text(items[i].label.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: AppText.metaSmall.copyWith(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Заголовок секции с опциональным действием справа
class DetailSectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  const DetailSectionHeader({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppText.sectionTitle),
          if (action != null) Text(action!, style: AppText.label.copyWith(color: AppColors.text)),
        ],
      ),
    );
  }
}

/// Блок описания
class DetailDescription extends StatelessWidget {
  final String text;
  const DetailDescription({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
      child: Text(text, style: AppText.body.copyWith(fontSize: 14, color: AppColors.dim, fontWeight: FontWeight.w500, height: 1.5)),
    );
  }
}
