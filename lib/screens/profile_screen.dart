import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../theme/app_tokens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import '../widgets/app_restart.dart';
import '../widgets/common.dart';
import 'paywall_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  const ProfileScreen({super.key, this.name = ''});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _mode = 'overview';

  /// Выбранная цель (strength/lose/endurance/maintain). null — ещё не
  /// загружена из shared_preferences или не выбиралась в онбординге.
  String? _userGoal;

  @override
  void initState() {
    super.initState();
    _loadGoal();
  }

  Future<void> _loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _userGoal = prefs.getString('user_goal'));
  }

  /// Сохраняет новую цель и обновляет подсветку. Та же запись в
  /// shared_preferences, что и в онбординге (ключ 'user_goal').
  Future<void> _selectGoal(String id) async {
    if (_userGoal == id) return;
    setState(() => _userGoal = id);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_goal', id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Цель обновлена: ${_goalWord(id)}'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Короткое слово цели для подзаголовка профиля.
  String _goalWord(String? id) {
    switch (id) {
      case 'strength':
        return 'сила';
      case 'lose':
        return 'похудение';
      case 'endurance':
        return 'выносливость';
      case 'maintain':
        return 'форма';
      default:
        return 'не выбрана';
    }
  }

  void _openPaywall() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              _modeBtn('overview', 'Обзор'),
              const SizedBox(width: 4),
              _modeBtn('settings', 'Настройки'),
            ]),
          ),
        ),
        Expanded(
          child: _mode == 'overview' ? _overview() : _settings(),
        ),
      ],
    );
  }

  Widget _modeBtn(String id, String label) {
    final active = _mode == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = id),
        child: Container(
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.text : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(label, style: AppText.label.copyWith(color: active ? AppColors.bg : AppColors.text, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  // ───────────── ВЫХОД ─────────────

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            side: BorderSide(color: AppColors.border),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 36),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Выйти из аккаунта?', style: AppText.cardTitle, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Тебе нужно будет снова ввести email и пароль, чтобы вернуться.',
                  style: AppText.metaSmall.copyWith(fontSize: 13, color: AppColors.dim, height: 1.45),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(false),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.whiteAlpha(0.18)),
                          ),
                          child: Text('Отмена', style: AppText.label.copyWith(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(true),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            color: AppColors.danger.withValues(alpha: 0.14),
                            border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                          ),
                          child: Text('Выйти', style: AppText.label.copyWith(fontWeight: FontWeight.w700, color: AppColors.danger)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true) return;
    if (!mounted) return;
    await AuthService.signOut();
    if (!mounted) return;
    AppRestart.restart(context);
  }

  // ───── БЛОК ВЫБОРА ЦЕЛИ (из онбординга) ─────

  /// Карточка одной цели. Активная — lime-рамка (это ВЫБОР пользователя,
  /// поэтому lime, а не gold, который зарезервирован за прогрессом/PR).
  Widget _goalCard(String id, String label, IconData icon) {
    final active = _userGoal == id;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _selectGoal(id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: active ? AppColors.lime.withValues(alpha: 0.07) : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: active ? AppColors.lime : AppColors.border,
              width: active ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: active ? AppColors.lime : AppColors.text, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label, style: AppText.body.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text('Моя цель', style: AppText.sectionTitle),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(children: [
                _goalCard('strength', 'Сила', AppIcons.dumbbell),
                const SizedBox(width: 10),
                _goalCard('lose', 'Похудение', AppIcons.bolt),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                _goalCard('endurance', 'Выносливость', AppIcons.run),
                const SizedBox(width: 10),
                _goalCard('maintain', 'Форма', AppIcons.yoga),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  // ───── ОБЗОР ─────
  Widget _overview() {
    const stats = [('87', 'тренировок', 'всего'), ('42.3к', 'ккал', 'сожжено'), ('128', 'дней', 'в приложении')];
    const goals = [
      ('Сила всего тела', 40, 'День 12 из 30', AppIcons.dumbbell),
      ('30 дней подряд', 66, '12 из 30 дней', AppIcons.flame),
      ('−4 кг к лету', 25, '−1 из 4 кг', AppIcons.target),
    ];
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 110),
      children: [
        Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface2,
                    border: Border.all(color: AppColors.whiteAlpha(0.25), width: 3),
                  ),
                  child: Icon(AppIcons.user, color: AppColors.dim2, size: 44),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface2,
                      border: Border.all(color: AppColors.bg, width: 3),
                    ),
                    child: Icon(AppIcons.camera, color: AppColors.text, size: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(widget.name.isEmpty ? 'Профиль' : widget.name, style: AppText.metricLg.copyWith(fontSize: 24)),
            const SizedBox(height: 4),
            Text('Начинающая · Цель: ${_goalWord(_userGoal)}', style: AppText.meta),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.goldTint(0.1),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.goldTint(0.33)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(AppIcons.bolt, color: AppColors.gold, size: 12),
                const SizedBox(width: 6),
                Text('Уровень 8', style: AppText.metaSmall.copyWith(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w800)),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            radius: AppRadius.xxl,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  for (int i = 0; i < stats.length; i++) ...[
                    if (i > 0) Container(width: 1, color: AppColors.whiteAlpha(0.06)),
                    Expanded(
                      child: Column(
                        children: [
                          Text(stats[i].$1, style: AppText.metricLg),
                          const SizedBox(height: 4),
                          Text(stats[i].$2.toUpperCase(), style: AppText.metaSmall.copyWith(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                          const SizedBox(height: 2),
                          Text(stats[i].$3, style: AppText.metaSmall.copyWith(fontSize: 10.5)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 26),
        _goalSelector(),
        const SizedBox(height: 26),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Цели', style: AppText.sectionTitle),
              Text('+ Новая', style: AppText.label.copyWith(color: AppColors.text)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: goals.map((g) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SurfaceCard(
                  radius: AppRadius.xl,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: AppColors.whiteAlpha(0.06), borderRadius: BorderRadius.circular(AppRadius.md)),
                          child: Icon(g.$4, color: AppColors.text, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.$1, style: AppText.body),
                              const SizedBox(height: 1),
                              Text(g.$3, style: AppText.metaSmall.copyWith(fontSize: 11.5)),
                            ],
                          ),
                        ),
                        Text('${g.$2}%', style: AppText.body.copyWith(fontWeight: FontWeight.w800, color: AppColors.gold)),
                      ]),
                      const SizedBox(height: 10),
                      ProgressLine(value: g.$2 / 100, fill: AppColors.gold, height: 5),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            radius: AppRadius.xxl,
            child: Row(children: [
              SizedBox(
                width: 96,
                height: 36,
                child: Stack(
                  children: [
                    for (int i = 0; i < 3; i++)
                      Positioned(
                        left: i * 24.0,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface2,
                            border: Border.all(color: AppColors.surface, width: 2.5),
                          ),
                          child: Icon(AppIcons.user, color: AppColors.dim2, size: 16),
                        ),
                      ),
                    Positioned(
                      left: 60,
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.whiteAlpha(0.08),
                          border: Border.all(color: AppColors.surface, width: 2.5),
                        ),
                        child: Text('+9', style: AppText.metaSmall.copyWith(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.text)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Друзья', style: AppText.body),
                    const SizedBox(height: 2),
                    Text('12 в приложении · 3 онлайн', style: AppText.metaSmall.copyWith(fontSize: 11.5)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.whiteAlpha(0.18)),
                ),
                child: Text('Пригласить', style: AppText.metaSmall.copyWith(fontSize: 12, color: AppColors.text, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(AppIcons.share, color: AppColors.text, size: 16),
              const SizedBox(width: 8),
              Text('Поделиться прогрессом', style: AppText.label),
            ]),
          ),
        ),
      ],
    );
  }

  // ───── НАСТРОЙКИ ─────
  Widget _settings() {
    final items = [
      ('Мои цели', AppIcons.target, _goalWord(_userGoal), false),
      ('Уведомления', AppIcons.bell, 'Вкл.', false),
      ('Напоминания', AppIcons.clock, '8:00, 19:00', false),
      ('Устройства', AppIcons.watch, 'Apple Watch', false),
      ('FitNow Premium', AppIcons.star, 'Активна', true),
      ('Язык', AppIcons.globe, 'Русский', false),
      ('Тема', AppIcons.moon, 'Тёмная', false),
    ];
    return ListView(
      padding: const EdgeInsets.only(top: 18, bottom: 110),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface2,
                border: Border.all(color: AppColors.whiteAlpha(0.25), width: 2),
              ),
              child: Icon(AppIcons.user, color: AppColors.dim2, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name.isEmpty ? 'Профиль' : widget.name, style: AppText.cardTitle),
                  const SizedBox(height: 2),
                  Text('Уровень 8 · Premium активна', style: AppText.metaSmall),
                ],
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.goldTint(0.15), AppColors.surface],
                stops: const [0.0, 0.7],
              ),
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              border: Border.all(color: AppColors.goldTint(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(AppRadius.md)),
                    child: const Icon(AppIcons.star, color: AppColors.bg, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FitNow Premium', style: AppText.cardTitle),
                        const SizedBox(height: 3),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.softGreen)),
                          const SizedBox(width: 5),
                          Text('Активна · до 24 мая', style: AppText.metaSmall.copyWith(fontSize: 12, color: AppColors.softGreen, fontWeight: FontWeight.w700)),
                        ]),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Text('Все программы, персональный AI-тренер, без рекламы',
                    style: AppText.metaSmall.copyWith(fontSize: 12.5, color: AppColors.dim, height: 1.45)),
                const SizedBox(height: 14),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _openPaywall,
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.whiteAlpha(0.18)),
                    ),
                    child: Text('Управлять подпиской', style: AppText.label.copyWith(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 20, 10),
          child: Text('НАСТРОЙКИ', style: AppText.eyebrow),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            radius: AppRadius.xxl,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: items[i].$4 ? _openPaywall : null,
                    child: Container(
                    decoration: BoxDecoration(
                      border: i < items.length - 1
                          ? Border(bottom: BorderSide(color: AppColors.whiteAlpha(0.04)))
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: items[i].$4 ? AppColors.goldTint(0.12) : AppColors.whiteAlpha(0.05),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(items[i].$2, color: items[i].$4 ? AppColors.gold : AppColors.text, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(items[i].$1, style: AppText.body.copyWith(fontSize: 14.5))),
                      Text(items[i].$3, style: AppText.metaSmall.copyWith(fontSize: 12, color: items[i].$4 ? AppColors.softGreen : AppColors.eyebrow, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      Icon(AppIcons.chevronRight, color: AppColors.whiteAlpha(0.3), size: 14),
                    ]),
                  ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Помощь', style: AppText.label.copyWith(color: AppColors.eyebrow)),
                  const SizedBox(width: 22),
                  Text('О приложении', style: AppText.label.copyWith(color: AppColors.eyebrow)),
                  const SizedBox(width: 22),
                  GestureDetector(
                    onTap: _confirmSignOut,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: Text('Выход', style: AppText.label.copyWith(color: AppColors.danger)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text('FitNow v2.4.1', style: AppText.metaSmall.copyWith(fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
