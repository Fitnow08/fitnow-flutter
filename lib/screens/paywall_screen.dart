import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';

/// План подписки
typedef _Plan = ({String id, String title, String price, String per, String? note, String? badge});

/// Экран Premium / пейвол. Открывается из Профиля и с карточки плана на Главной.
/// Реальной оплаты пока нет — кнопка показывает заглушку (биллинг подключим позже).
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  String _plan = 'year';

  static const List<_Plan> _plans = [
    (id: 'year', title: 'Год', price: '2 990 ₽', per: '/год', note: '≈ 249 ₽/мес', badge: '−38%'),
    (id: 'month', title: 'Месяц', price: '399 ₽', per: '/мес', note: null, badge: null),
  ];

  static const List<String> _features = [
    'Все программы и тренировки',
    'Персональный AI-тренер',
    'Расширенная аналитика прогресса',
    'Планы, адаптирующиеся под тебя',
    'Без рекламы',
  ];

  _Plan get _selected => _plans.firstWhere((p) => p.id == _plan);

  void _subscribe() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Оплата скоро будет доступна'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Закрыть
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: 8, top: 4),
                  child: const Icon(Icons.close_rounded, color: AppColors.dim, size: 24),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                children: [
                  _hero(),
                  const SizedBox(height: 28),
                  ..._features.map(_featureRow),
                  const SizedBox(height: 24),
                  for (final p in _plans) ...[
                    _planCard(p),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            // Sticky CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _subscribe,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.25), blurRadius: 28, offset: const Offset(0, 12))],
                      ),
                      child: Text('Оформить — ${_selected.price}${_selected.per}',
                          style: AppText.cardTitle.copyWith(color: AppColors.bg, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Автопродление. Отмена в любой момент.',
                      style: AppText.metaSmall.copyWith(fontSize: 11, color: AppColors.eyebrow)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.goldTint(0.14),
            border: Border.all(color: AppColors.goldTint(0.4), width: 1.5),
          ),
          child: const Icon(AppIcons.star, color: AppColors.gold, size: 38),
        ),
        const SizedBox(height: 18),
        Text('FitNow Premium', style: AppText.metricLg.copyWith(fontSize: 26, letterSpacing: -0.5)),
        const SizedBox(height: 8),
        Text('Тренируйся без ограничений и быстрее достигай цели',
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(fontSize: 14.5, color: AppColors.dim, height: 1.45)),
      ],
    );
  }

  Widget _featureRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.goldTint(0.14)),
            child: const Icon(Icons.check_rounded, color: AppColors.gold, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppText.body.copyWith(fontSize: 14.5))),
        ],
      ),
    );
  }

  Widget _planCard(_Plan p) {
    final active = p.id == _plan;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _plan = p.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: active ? AppColors.goldTint(0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: active ? AppColors.gold : AppColors.border, width: active ? 1.5 : 1),
        ),
        child: Row(
          children: [
            // Радио
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? AppColors.bg : Colors.transparent,
                border: Border.all(color: active ? AppColors.gold : AppColors.whiteAlpha(0.25), width: active ? 7 : 1.5),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(p.title, style: AppText.body.copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
                    if (p.badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(6)),
                        child: Text(p.badge!, style: AppText.metaSmall.copyWith(fontSize: 10.5, color: AppColors.bg, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ]),
                  if (p.note != null) ...[
                    const SizedBox(height: 2),
                    Text(p.note!, style: AppText.metaSmall.copyWith(fontSize: 12)),
                  ],
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(p.price, style: AppText.body.copyWith(fontSize: 16, fontWeight: FontWeight.w800)),
                Text(p.per, style: AppText.metaSmall.copyWith(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
