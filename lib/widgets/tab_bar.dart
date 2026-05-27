import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';

class FitNowTabBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onChange;
  const FitNowTabBar({super.key, required this.activeIndex, required this.onChange});

  static const _tabs = [
    (label: 'Главная', icon: AppIcons.home),
    (label: 'Прогресс', icon: AppIcons.chart),
    (label: 'Программы', icon: AppIcons.grid),
    (label: 'Профиль', icon: AppIcons.user),
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 18,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xD9141414), // rgba(20,20,20,0.85)
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.whiteAlpha(0.08)),
              boxShadow: const [
                BoxShadow(color: Color(0x59000000), blurRadius: 20, offset: Offset(0, -2)),
                BoxShadow(color: Color(0x4D000000), blurRadius: 40, offset: Offset(0, 20)),
              ],
            ),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final active = i == activeIndex;
                final color = active ? AppColors.lime : AppColors.dim2;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChange(i),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (active)
                          Positioned(
                            top: 6,
                            child: Container(
                              width: 28,
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.lime,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_tabs[i].icon, color: color, size: 22),
                            const SizedBox(height: 3),
                            Text(_tabs[i].label,
                                style: AppText.metaSmall.copyWith(
                                    fontSize: 10.5, fontWeight: FontWeight.w600, color: color)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
