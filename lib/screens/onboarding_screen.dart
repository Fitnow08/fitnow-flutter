import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_tokens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';

/// Ключи для shared_preferences
class OnboardingPrefs {
  static const done = 'onboarding_done';
  static const goal = 'user_goal';
  static const name = 'user_name';
}

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  final _nameCtrl = TextEditingController();
  int _page = 0;
  String? _selectedGoal;

  @override
  void dispose() {
    _controller.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page >= 4) {
      _finish();
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    }
  }

  void _skip() {
    _controller.animateToPage(4, duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingPrefs.done, true);
    if (_selectedGoal != null) {
      await prefs.setString(OnboardingPrefs.goal, _selectedGoal!);
    }
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) {
      await prefs.setString(OnboardingPrefs.name, name);
    }
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Мягкое свечение в углу (как glow в JSX)
          Positioned(
            top: -40,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.lime.withValues(alpha: 0.09), Colors.transparent],
                  stops: const [0.0, 0.65],
                ),
              ),
            ),
          ),
          PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            children: [
              _ChromeWrap(slide: 1, total: 5, onSkip: _skip, showSkip: true, child: _welcome()),
              _ChromeWrap(slide: 2, total: 5, onSkip: _skip, showSkip: true, child: _ai()),
              _ChromeWrap(slide: 3, total: 5, onSkip: _skip, showSkip: true, child: _programs()),
              _ChromeWrap(slide: 4, total: 5, onSkip: _skip, showSkip: true, child: _progress()),
              _ChromeWrap(slide: 5, total: 5, onSkip: _skip, showSkip: false, child: _goal()),
            ],
          ),
        ],
      ),
    );
  }

  // ───── Общие элементы ─────
  Widget _dots(int active) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final on = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 6,
          width: on ? 22 : 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: on ? AppColors.text : AppColors.whiteAlpha(0.18),
          ),
        );
      }),
    );
  }

  Widget _primaryCta(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
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
    );
  }

  Widget _eyebrow(String text) {
    return Text(text.toUpperCase(),
        style: AppText.metaSmall.copyWith(fontSize: 11, color: AppColors.lime, fontWeight: FontWeight.w700, letterSpacing: 1.6));
  }

  Widget _slideTitle(String text) {
    return Text(text, textAlign: TextAlign.center, style: AppText.metricLg.copyWith(fontSize: 30, height: 1.05, letterSpacing: -0.7));
  }

  Widget _slideDesc(String text) {
    return Text(text, textAlign: TextAlign.center, style: AppText.body.copyWith(fontSize: 15, color: AppColors.dim, fontWeight: FontWeight.w500, height: 1.5));
  }

  // ───── Слайд 1: Welcome ─────
  Widget _welcome() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _ring(240, 0.08),
                      _ring(184, 0.06),
                      Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [AppColors.lime.withValues(alpha: 0.2), Colors.transparent], stops: const [0.0, 0.7]),
                        ),
                      ),
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: AppColors.lime,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [BoxShadow(color: AppColors.lime.withValues(alpha: 0.33), blurRadius: 60, offset: const Offset(0, 20))],
                        ),
                        child: const Icon(AppIcons.bolt, color: AppColors.bg, size: 38),
                      ),
                      Positioned(top: 0, child: Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.gold))),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                RichText(
                  text: TextSpan(
                    style: AppText.metricXl.copyWith(fontSize: 44, letterSpacing: -1.4),
                    children: [
                      const TextSpan(text: 'Fit'),
                      TextSpan(text: 'Now', style: TextStyle(color: AppColors.lime)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: 280,
                  child: Text('Твой ИИ-тренер в кармане — каждый день, под твой темп.',
                      textAlign: TextAlign.center, style: AppText.body.copyWith(fontSize: 16, color: AppColors.dim, fontWeight: FontWeight.w500, height: 1.45)),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _primaryCta('Начать', _next),
              const SizedBox(height: 14),
              RichText(
                text: TextSpan(
                  style: AppText.metaSmall.copyWith(fontSize: 12, color: AppColors.eyebrow, fontWeight: FontWeight.w500),
                  children: [
                    const TextSpan(text: 'Уже есть аккаунт? '),
                    TextSpan(text: 'Войти', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ring(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.whiteAlpha(opacity)),
      ),
    );
  }

  // ───── Слайд 2: AI ─────
  Widget _ai() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _limeRing(180, 0.1),
                      _limeRing(130, 0.2),
                      _limeRing(80, 0.4),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface2,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.lime)),
                            const SizedBox(width: 5),
                            Text('AI', style: AppText.body.copyWith(fontSize: 14, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _eyebrow('Шаг 1 из 4'),
                const SizedBox(height: 12),
                _slideTitle('ИИ-тренер\nв реальном времени'),
                const SizedBox(height: 14),
                SizedBox(width: 300, child: _slideDesc('Подсказывает технику, считает повторы и подстраивает темп тренировки под тебя.')),
              ],
            ),
          ),
        ),
        _slideNav(1),
      ],
    );
  }

  Widget _limeRing(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.lime.withValues(alpha: opacity), width: 1.5),
      ),
    );
  }

  // ───── Слайд 3: Программы ─────
  Widget _programs() {
    final cats = [
      ('Сила', AppIcons.dumbbell, AppColors.levelHard),
      ('Кардио', AppIcons.run, AppColors.levelMed),
      ('Йога', AppIcons.yoga, AppColors.levelEasy),
      ('HIIT', AppIcons.bolt, AppColors.gold),
    ];
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 280,
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: cats.map((c) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(color: AppColors.whiteAlpha(0.06), borderRadius: BorderRadius.circular(14)),
                              child: Icon(c.$2, color: c.$3, size: 24),
                            ),
                            const SizedBox(height: 10),
                            Text(c.$1, style: AppText.body.copyWith(fontSize: 14, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 36),
                _eyebrow('Шаг 2 из 4'),
                const SizedBox(height: 12),
                _slideTitle('Программы\nпод тебя'),
                const SizedBox(height: 14),
                SizedBox(width: 300, child: _slideDesc('Сила, кардио, йога или HIIT — подберём план под твой уровень и цель.')),
              ],
            ),
          ),
        ),
        _slideNav(2),
      ],
    );
  }

  // ───── Слайд 4: Прогресс ─────
  Widget _progress() {
    const week = [22, 38, 0, 46, 64, 28, 18];
    const maxM = 64;
    const todayIdx = 4;
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 280,
                  height: 200,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: 10,
                        left: 0,
                        right: 0,
                        child: Transform.rotate(
                          angle: -0.05,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                              boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 50, offset: Offset(0, 20))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ЭТА НЕДЕЛЯ', style: AppText.eyebrow.copyWith(fontSize: 10.5, letterSpacing: 1.2)),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text('216', style: AppText.metricLg.copyWith(letterSpacing: -0.5)),
                                    const SizedBox(width: 4),
                                    Text('мин', style: AppText.metaSmall.copyWith(fontWeight: FontWeight.w600)),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: AppColors.greenTint(0.13), borderRadius: BorderRadius.circular(5)),
                                      child: Text('↑ +18%', style: AppText.metaSmall.copyWith(fontSize: 10, color: AppColors.mutedGreen, fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 40,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: List.generate(week.length, (i) {
                                      final h = week[i] == 0 ? 3.0 : (week[i] / maxM * 34).clamp(6.0, 34.0);
                                      return Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 2),
                                          height: h,
                                          decoration: BoxDecoration(
                                            color: i == todayIdx ? AppColors.gold : AppColors.chartGray,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -4,
                        child: Transform.rotate(
                          angle: 0.14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surface2,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.goldTint(0.25)),
                              boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 30, offset: Offset(0, 10))],
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(AppIcons.flame, color: AppColors.gold, size: 14),
                              const SizedBox(width: 6),
                              Text('12 дней', style: AppText.metaSmall.copyWith(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.text)),
                            ]),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -10,
                        left: 6,
                        child: Transform.rotate(
                          angle: -0.1,
                          child: Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surface2,
                              border: Border.all(color: AppColors.goldTint(0.33), width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(AppIcons.trophy, color: AppColors.gold, size: 26),
                                const SizedBox(height: 2),
                                Text('PR×10', style: AppText.metaSmall.copyWith(fontSize: 9, color: AppColors.gold, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _eyebrow('Шаг 3 из 4'),
                const SizedBox(height: 12),
                _slideTitle('Прогресс,\nкоторый видно'),
                const SizedBox(height: 14),
                SizedBox(width: 300, child: _slideDesc('Графики, рекорды и стрики — наглядное доказательство твоей работы.')),
              ],
            ),
          ),
        ),
        _slideNav(3),
      ],
    );
  }

  // ───── Слайд 5: Выбор цели ─────
  Widget _goal() {
    final goals = [
      ('strength', 'Набрать силу', 'Мышцы и рельеф', AppIcons.dumbbell),
      ('lose', 'Сбросить вес', 'Жиросжигание + кардио', AppIcons.bolt),
      ('endurance', 'Выносливость', 'Бег, HIIT, кардио', AppIcons.run),
      ('maintain', 'Поддерживать форму', 'Регулярная активность', AppIcons.yoga),
    ];
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _eyebrow('Шаг 4 из 4'),
                const SizedBox(height: 10),
                Text('Какая твоя цель?', style: AppText.metricLg.copyWith(fontSize: 28, letterSpacing: -0.6, height: 1.05)),
                const SizedBox(height: 8),
                Text('Выбери одно — план подстроится под него.', style: AppText.body.copyWith(fontSize: 14, color: AppColors.dim, fontWeight: FontWeight.w500)),
                const SizedBox(height: 18),
                _nameField(),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.separated(
                    itemCount: goals.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final g = goals[i];
                      final active = _selectedGoal == g.$1;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedGoal = g.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: active ? AppColors.lime.withValues(alpha: 0.07) : AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: active ? AppColors.lime : AppColors.border, width: active ? 1.5 : 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: active ? AppColors.lime.withValues(alpha: 0.1) : AppColors.whiteAlpha(0.05),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Icon(g.$4, color: active ? AppColors.lime : AppColors.text, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(g.$2, style: AppText.body.copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 2),
                                    Text(g.$3, style: AppText.metaSmall.copyWith(fontSize: 12)),
                                  ],
                                ),
                              ),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: active ? AppColors.bg : Colors.transparent,
                                  border: Border.all(color: active ? AppColors.lime : AppColors.whiteAlpha(0.25), width: active ? 7 : 1.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              _dots(4),
              const SizedBox(height: 22),
              _primaryCta('Поехали', _finish),
            ],
          ),
        ),
      ],
    );
  }

  Widget _nameField() {
    return TextField(
      controller: _nameCtrl,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      cursorColor: AppColors.lime,
      style: AppText.body.copyWith(fontSize: 15, color: AppColors.text, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: 'Как тебя зовут?',
        hintStyle: AppText.body.copyWith(fontSize: 15, color: AppColors.dim2, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.lime),
        ),
      ),
    );
  }

  Widget _slideNav(int activeDot) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _dots(activeDot),
          const SizedBox(height: 22),
          _primaryCta(_page >= 4 ? 'Поехали' : 'Далее', _next),
        ],
      ),
    );
  }
}

/// Обёртка с верхним баром (счётчик + Пропустить) и paddings.
class _ChromeWrap extends StatelessWidget {
  final int slide;
  final int total;
  final VoidCallback onSkip;
  final bool showSkip;
  final Widget child;
  const _ChromeWrap({
    required this.slide,
    required this.total,
    required this.onSkip,
    required this.showSkip,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 56, bottom: 28),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$slide / $total',
                    style: AppText.meta.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                if (showSkip)
                  GestureDetector(
                    onTap: onSkip,
                    child: Text('Пропустить', style: AppText.label.copyWith(color: AppColors.eyebrow)),
                  )
                else
                  const SizedBox(width: 60),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
