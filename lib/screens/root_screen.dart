import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../widgets/tab_bar.dart';
import 'home_screen.dart';
import 'progress_screen.dart';
import 'programs_screen.dart';
import 'profile_screen.dart';

/// Корневая навигационная обёртка приложения.
///
/// Держит четыре вкладки в IndexedStack (стейт каждой сохраняется при
/// переключении) и стеклянный FitNowTabBar поверх. Сам TabBar рендерится
/// через Positioned, поэтому всё лежит в Stack, а не в bottomNavigationBar.
///
/// Сюда переходим из main.dart → _Bootstrap после успешной авторизации
/// и пройденного онбординга.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late int _index = widget.initialIndex;

  // Режим Главной — меняется демо-переключателем (см. ниже).
  // В проде поле и переключатель удалить, в HomeScreen передать
  // настоящий режим из бэкенда / shared_preferences.
  HomeMode _homeMode = HomeMode.active;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      // НЕ используем bottomNavigationBar — FitNowTabBar возвращает
      // Positioned и должен жить в Stack, плавая поверх контента.
      body: Stack(
        children: [
          // IndexedStack сохраняет состояние каждой вкладки — например,
          // позицию скролла на Прогрессе при переключении на Профиль
          // и обратно. Это правильное поведение для таб-бара.
          //
          // Порядок ОБЯЗАН совпадать с порядком _tabs внутри FitNowTabBar:
          // 0 — Главная, 1 — Прогресс, 2 — Программы, 3 — Профиль.
          IndexedStack(
            index: _index,
            children: [
              HomeScreen(mode: _homeMode),
              const ProgressScreen(),
              const ProgramsScreen(),
              const ProfileScreen(),
            ],
          ),

          // ╔═══════════════════════════════════════════════════════════
          // ║  ДЕМО-ПЕРЕКЛЮЧАТЕЛЬ РЕЖИМОВ ГЛАВНОЙ — УБРАТЬ В ПРОДЕ
          // ║
          // ║  В проде нужно:
          // ║    1) Удалить поле _homeMode и этот блок
          // ║    2) В HomeScreen(...) выше передать настоящий режим
          // ║       (например, из репозитория, который читает прогресс
          // ║        пользователя с бэкенда)
          // ║
          // ║  Виден только когда открыта вкладка Главная — иначе был
          // ║  бы мусором поверх Прогресса/Программ/Профиля.
          // ╚═══════════════════════════════════════════════════════════
          if (_index == 0)
            Positioned(
              right: 16,
              // Над таб-баром: его высота 72 + bottom-отступ 18 = 90,
              // плюс воздух — итого 100.
              bottom: 100,
              child: _HomeModeSwitcher(
                mode: _homeMode,
                onChange: (m) => setState(() => _homeMode = m),
              ),
            ),

          // Таб-бар поверх всего, иначе свитчер выше его перекроет.
          FitNowTabBar(
            activeIndex: _index,
            onChange: (i) {
              if (i == _index) return;
              setState(() => _index = i);
            },
          ),
        ],
      ),
    );
  }
}

/// Компактный вертикальный свитчер из трёх пилюль: active / empty / loading.
/// Только для отладки — в проде удалить вместе с использованием в RootScreen.
class _HomeModeSwitcher extends StatelessWidget {
  const _HomeModeSwitcher({required this.mode, required this.onChange});

  final HomeMode mode;
  final ValueChanged<HomeMode> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        // Полупрозрачный фон — чтобы контент Главной немного просвечивал
        // и было очевидно, что это служебный оверлей, а не часть UI.
        color: const Color(0xCC1A1A1D),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      // IntrinsicWidth даёт Column ширину самого широкого ребёнка
      // ('loading'). Без него stretch в неограниченном по ширине Positioned
      // требует бесконечной ширины → краш рендеринга.
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: HomeMode.values.map((m) {
            final active = m == mode;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChange(m),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 1),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? AppColors.surface2 : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                alignment: Alignment.center,
                child: Text(
                  _label(m),
                  style: AppText.metaSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: active ? AppColors.text : AppColors.eyebrow,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _label(HomeMode m) {
    switch (m) {
      case HomeMode.active:
        return 'active';
      case HomeMode.empty:
        return 'empty';
      case HomeMode.loading:
        return 'loading';
    }
  }
}
