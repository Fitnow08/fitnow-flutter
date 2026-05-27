import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import '../widgets/common.dart';

enum HomeMode { active, empty, loading }

class HomeScreen extends StatelessWidget {
  final String name;
  final HomeMode mode;
  const HomeScreen({super.key, this.name = 'Мария', this.mode = HomeMode.active});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 56, bottom: 110),
      children: [
        _header(),
        const SizedBox(height: 4),
        _todayLabel(),
        const SizedBox(height: 12),
        _heroCard(),
        const SizedBox(height: 16),
        if (mode == HomeMode.active) ...[
          _planCta(),
          const SizedBox(height: 16),
          _weeklyStats(),
        ] else if (mode == HomeMode.empty) ...[
          _emptyStats(),
        ] else ...[
          _loadingStats(),
        ],
      ],
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          // Аватар-заглушка
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface2,
              border: Border.all(color: AppColors.whiteAlpha(0.15)),
            ),
            child: Icon(AppIcons.user, color: AppColors.dim2, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('четверг, 24 апр', style: AppText.metaSmall),
                Text('Привет, $name', style: AppText.cardTitle),
              ],
            ),
          ),
          // Streak бейдж
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(AppIcons.flame, color: AppColors.gold, size: 13),
              const SizedBox(width: 5),
              Text('12 дней', style: AppText.metaSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.text)),
            ]),
          ),
          const SizedBox(width: 10),
          Icon(AppIcons.bell, color: AppColors.dim2, size: 22),
        ],
      ),
    );
  }

  Widget _todayLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('ТРЕНИРОВКА СЕГОДНЯ', style: AppText.eyebrow.copyWith(color: AppColors.text, letterSpacing: 1.2)),
          Text('День 12 / 30', style: AppText.metaSmall),
        ],
      ),
    );
  }

  Widget _heroCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xxxl),
        child: Stack(
          children: [
            const PhotoPlaceholder(height: 320, darkScrim: true),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Live AI бейдж + bookmark
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xA6000000),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.mutedGreen)),
                            const SizedBox(width: 6),
                            Text('Live AI-тренер', style: AppText.metaSmall.copyWith(color: AppColors.text, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                        const Spacer(),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: const Color(0xA6000000), borderRadius: BorderRadius.circular(AppRadius.pill)),
                          child: Icon(AppIcons.bookmark, color: AppColors.text, size: 16),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Чипы
                    Row(
                      children: [
                        _heroChip('Средний'),
                        const SizedBox(width: 6),
                        _heroChip('Без прыжков'),
                        const SizedBox(width: 6),
                        _heroChip('Гантели'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('Сила всего тела', style: AppText.screenTitle),
                    const SizedBox(height: 4),
                    Text('6 упражнений · 42 мин · 320 ккал', style: AppText.meta.copyWith(color: AppColors.dim)),
                    const SizedBox(height: 12),
                    // Тренер
                    Row(children: [
                      Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surface2)),
                      const SizedBox(width: 8),
                      Text('Тренер Аня Ромашова', style: AppText.metaSmall.copyWith(color: AppColors.dim)),
                    ]),
                    const SizedBox(height: 14),
                    // CTA — lime (главное действие!)
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(color: AppColors.lime, borderRadius: BorderRadius.circular(AppRadius.pill)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('Начать', style: AppText.label.copyWith(color: AppColors.bg, fontWeight: FontWeight.w800)),
                          const SizedBox(width: 6),
                          const Icon(AppIcons.arrowRight, color: AppColors.bg, size: 16),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x66000000),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(label, style: AppText.metaSmall.copyWith(color: AppColors.text, fontWeight: FontWeight.w600)),
    );
  }

  Widget _planCta() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SurfaceCard(
        radius: AppRadius.xxl,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: AppColors.whiteAlpha(0.06), borderRadius: BorderRadius.circular(10)),
              child: Icon(AppIcons.plus, color: AppColors.text, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Получить персональный план', style: AppText.body),
                  const SizedBox(height: 2),
                  Text('30 дней · адаптируется под прогресс', style: AppText.metaSmall),
                ],
              ),
            ),
            Icon(AppIcons.chevronRight, color: AppColors.dim2, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _weeklyStats() {
    const week = [
      ('Пн', 0.55, false),
      ('Вт', 0.75, false),
      ('Ср', 0.0, false),
      ('Чт', 1.0, true),
      ('Пт', 0.0, false),
      ('Сб', 0.0, false),
      ('Вс', 0.0, false),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SurfaceCard(
        radius: AppRadius.xxl,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Твой прогресс на этой неделе', style: AppText.body),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.goldTint(0.15), borderRadius: BorderRadius.circular(AppRadius.xs)),
                  child: Text('↑ +18%', style: AppText.metaSmall.copyWith(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 10.5)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _statMetric('4', 'тренировки'),
                _statMetric('146', 'минут'),
                _statMetric('1.2к', 'ккал'),
              ],
            ),
            const SizedBox(height: 16),
            // График с линией цели
            SizedBox(
              height: 78,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: week.map((w) {
                  final h = w.$2 == 0 ? 6.0 : (w.$2 * 48).clamp(10.0, 48.0);
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: h,
                          decoration: BoxDecoration(
                            color: w.$3 ? AppColors.gold : AppColors.chartGray,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(w.$1, style: AppText.metaSmall.copyWith(fontSize: 10, color: w.$3 ? AppColors.gold : AppColors.eyebrow)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statMetric(String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppText.metricLg),
          const SizedBox(height: 2),
          Text(label, style: AppText.metaSmall),
        ],
      ),
    );
  }

  // EMPTY STATE
  Widget _emptyStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SurfaceCard(
        radius: AppRadius.xxl,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: AppColors.whiteAlpha(0.06), borderRadius: BorderRadius.circular(AppRadius.lg)),
              child: Icon(AppIcons.chart, color: AppColors.dim2, size: 26),
            ),
            const SizedBox(height: 16),
            Text('Здесь появится твоя статистика', style: AppText.cardTitle),
            const SizedBox(height: 6),
            Text('Тренировки, минуты и ккал за неделю', style: AppText.meta, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.lime, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Text('Начать первую тренировку', style: AppText.label.copyWith(color: AppColors.bg, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // LOADING SKELETON
  Widget _loadingStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SurfaceCard(
        radius: AppRadius.xxl,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _skel(width: 180, height: 14),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _skel(height: 32)),
              const SizedBox(width: 12),
              Expanded(child: _skel(height: 32)),
              const SizedBox(width: 12),
              Expanded(child: _skel(height: 32)),
            ]),
            const SizedBox(height: 18),
            _skel(height: 64),
          ],
        ),
      ),
    );
  }

  Widget _skel({double? width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.whiteAlpha(0.05),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }
}