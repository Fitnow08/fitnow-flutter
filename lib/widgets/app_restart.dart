import 'package:flutter/material.dart';

/// Корневая обёртка, позволяющая перезапустить всё дерево виджетов изнутри.
///
/// Зачем нужно: наш стартовый _Bootstrap читает флаги из shared_preferences
/// один раз при создании и кэширует результат в FutureBuilder. Когда мы
/// делаем signOut() где-то глубоко в Профиле, _Bootstrap не узнает об
/// изменении флагов автоматически — он не пересоздаётся.
///
/// AppRestart решает это просто: меняет Key корневого поддерева, и Flutter
/// заново создаёт всё. _Bootstrap инициализируется как при первом запуске,
/// перечитывает флаги, видит !isAuthenticated и показывает SignInScreen.
///
/// Использование:
///   1) В main(): runApp(const AppRestart(child: FitNowApp()));
///   2) В нужном месте: AppRestart.restart(context);
///
/// Также пригодится для смены темы/языка в будущем — любая глобальная
/// перенастройка, требующая «холодного старта» UI.
class AppRestart extends StatefulWidget {
  const AppRestart({super.key, required this.child});

  final Widget child;

  /// Перезапустить дерево из любого места по контексту.
  static void restart(BuildContext context) {
    final state = context.findAncestorStateOfType<_AppRestartState>();
    assert(state != null,
        'AppRestart.restart вызвана, но AppRestart не найден в дереве предков. '
        'Оберни корневое приложение: runApp(const AppRestart(child: FitNowApp())).');
    state?._restart();
  }

  @override
  State<AppRestart> createState() => _AppRestartState();
}

class _AppRestartState extends State<AppRestart> {
  Key _key = UniqueKey();

  void _restart() {
    setState(() => _key = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    // KeyedSubtree с новым Key заставит Flutter уничтожить и пересоздать
    // всё поддерево, включая стейты всех StatefulWidget вниз.
    return KeyedSubtree(key: _key, child: widget.child);
  }
}
