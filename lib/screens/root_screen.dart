import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_tokens.dart';
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

  // Имя для приветствий/профиля. Грузится из prefs/email (см. AuthService).
  String _name = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final n = await AuthService.displayName();
    if (!mounted) return;
    setState(() => _name = n);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      // НЕ используем bottomNavigationBar — FitNowTabBar возвращает
      // Positioned и должен жить в Stack, плавая поверх контента.
      body: Stack(
        children: [
          // IndexedStack сохраняет состояние каждой вкладки.
          // Порядок ОБЯЗАН совпадать с порядком _tabs внутри FitNowTabBar:
          // 0 — Главная, 1 — Прогресс, 2 — Программы, 3 — Профиль.
          IndexedStack(
            index: _index,
            children: [
              // Режим Главной пока константа active. Когда появится реальное
              // состояние плана (бэкенд / репозиторий) — подставить сюда:
              // loading во время загрузки → empty если плана нет → active.
              HomeScreen(
                mode: HomeMode.active,
                name: _name,
                onSwitchTab: (i) => setState(() => _index = i),
              ),
              ProgressScreen(name: _name),
              const ProgramsScreen(),
              ProfileScreen(name: _name),
            ],
          ),

          // Таб-бар поверх контента.
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
