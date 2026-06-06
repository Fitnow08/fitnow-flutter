import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import '../widgets/common.dart';

/// Одно уведомление
typedef _Notif = ({
  IconData icon,
  Color tint,
  String title,
  String body,
  String time,
  bool unread,
});

/// Экран уведомлений. Открывается по тапу на колокол в шапке Главной.
/// Пока на статичных данных — когда появится бэкенд, список придёт оттуда.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static final List<_Notif> _today = [
    (
      icon: AppIcons.flame,
      tint: AppColors.gold,
      title: 'Стрик 12 дней!',
      body: 'Ты тренируешься почти две недели подряд. Так держать.',
      time: '09:00',
      unread: true,
    ),
    (
      icon: AppIcons.bolt,
      tint: AppColors.lime,
      title: 'Пора на тренировку',
      body: 'Сегодня по плану «Ноги · мощность» — 35 минут.',
      time: '08:00',
      unread: true,
    ),
  ];

  static final List<_Notif> _earlier = [
    (
      icon: AppIcons.trophy,
      tint: AppColors.gold,
      title: 'Новый рекорд',
      body: 'Жим лёжа — 62 кг. Это твой максимум.',
      time: 'Вчера',
      unread: false,
    ),
    (
      icon: AppIcons.grid,
      tint: AppColors.lime,
      title: 'Программа обновилась',
      body: '«Сила и рельеф» адаптировалась под твой прогресс.',
      time: 'Вчера',
      unread: false,
    ),
    (
      icon: AppIcons.medal,
      tint: AppColors.gold,
      title: '50 тренировок',
      body: 'Поздравляем с юбилейной тренировкой в FitNow!',
      time: '2 дня назад',
      unread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Топ-бар: назад + заголовок
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text, size: 18),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('Уведомления', style: AppText.cardTitle),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                children: [
                  _group('Сегодня', _today),
                  const SizedBox(height: 24),
                  _group('Ранее', _earlier),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _group(String label, List<_Notif> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(label.toUpperCase(), style: AppText.eyebrow),
        ),
        ...items.map(_card),
      ],
    );
  }

  Widget _card(_Notif n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SurfaceCard(
        radius: AppRadius.xl,
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: n.tint.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(n.icon, color: n.tint, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(n.title, style: AppText.body.copyWith(fontWeight: FontWeight.w700))),
                      if (n.unread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.lime),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(n.body, style: AppText.metaSmall.copyWith(fontSize: 12.5, color: AppColors.dim, height: 1.4)),
                  const SizedBox(height: 6),
                  Text(n.time, style: AppText.metaSmall.copyWith(fontSize: 11, color: AppColors.eyebrow)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
