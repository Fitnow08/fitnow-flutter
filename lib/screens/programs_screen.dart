import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import '../widgets/common.dart';
import 'program_detail_screen.dart';
import 'workout_detail_screen.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});
  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  String _seg = 'programs';
  String _cat = 'Все';

  static const _programs = [
    (title: 'Сила и рельеф', weeks: 6, sessions: 24, level: 'Сильно', rating: 4.8, badge: 'Активна', progress: 40, cat: 'Силовые'),
    (title: 'HIIT Shred', weeks: 4, sessions: 20, level: 'Средне', rating: 4.9, badge: 'TOP 10', progress: -1, cat: 'HIIT'),
    (title: 'Утренняя йога', weeks: 2, sessions: 14, level: 'Легко', rating: 4.7, badge: 'NEW', progress: -1, cat: 'Йога'),
    (title: 'Мобильность', weeks: 3, sessions: 21, level: 'Легко', rating: 4.8, badge: '', progress: -1, cat: 'Растяжка'),
    (title: 'Беговая база', weeks: 8, sessions: 32, level: 'Средне', rating: 4.6, badge: 'Для вас', progress: -1, cat: 'Кардио'),
    (title: 'Кор-челлендж', weeks: 4, sessions: 28, level: 'Средне', rating: 4.9, badge: 'Популярно', progress: -1, cat: 'Силовые'),
  ];

  static const _workouts = [
    (title: 'Ноги в огне', mins: 28, type: 'Силовая', equip: 'Гантели', cat: 'Силовая'),
    (title: 'Бокс-кардио', mins: 35, type: 'Кардио', equip: 'Без', cat: 'Кардио'),
    (title: 'HIIT 20 мин', mins: 20, type: 'Кардио', equip: 'Без', cat: 'Кардио'),
    (title: 'Утренняя йога', mins: 15, type: 'Йога', equip: 'Коврик', cat: 'Йога'),
    (title: 'Кор и стабильность', mins: 22, type: 'Кор', equip: 'Без', cat: 'Кор'),
  ];

  List<String> get _cats => _seg == 'programs'
      ? ['Все', 'Силовые', 'Кардио', 'Йога', 'HIIT', 'Растяжка']
      : ['Все', 'Силовая', 'Кардио', 'Йога', 'Кор'];

  Color _levelColor(String lvl) {
    if (lvl == 'Легко') return AppColors.levelEasy;
    if (lvl == 'Средне') return AppColors.levelMed;
    if (lvl == 'Сильно') return AppColors.levelHard;
    return AppColors.eyebrow;
  }

  ({Color bg, Color fg}) _badgeColor(String b) {
    if (b == 'NEW') return (bg: AppColors.text, fg: AppColors.bg);
    return (bg: AppColors.gold, fg: AppColors.bg);
  }

  @override
  Widget build(BuildContext context) {
    final filteredPrograms = _cat == 'Все' ? _programs : _programs.where((p) => p.cat == _cat).toList();
    final filteredWorkouts = _cat == 'Все' ? _workouts : _workouts.where((w) => w.cat == _cat).toList();

    return ListView(
      padding: const EdgeInsets.only(top: 56, bottom: 110),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FitNow', style: AppText.meta),
              const SizedBox(height: 2),
              Text('Программы и тренировки', style: AppText.screenTitle),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _search(),
        const SizedBox(height: 16),
        _segmented(),
        const SizedBox(height: 16),
        if (_seg == 'programs') _activeProgram(),
        if (_seg == 'programs') const SizedBox(height: 24),
        _filters(),
        const SizedBox(height: 18),
        if (_seg == 'programs')
          _programsGrid(filteredPrograms)
        else
          _workoutsList(filteredWorkouts),
      ],
    );
  }

  Widget _search() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(AppIcons.search, color: AppColors.eyebrow, size: 18),
            const SizedBox(width: 10),
            Text(_seg == 'programs' ? 'Поиск программ' : 'Поиск тренировок',
                style: AppText.body.copyWith(color: AppColors.eyebrow, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _segmented() {
    Widget btn(String id, String label) {
      final active = _seg == id;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() {
            _seg = id;
            _cat = 'Все';
          }),
          child: Container(
            height: 36,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [btn('programs', 'Программы'), const SizedBox(width: 4), btn('workouts', 'Тренировки')]),
      ),
    );
  }

  Widget _activeProgram() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('МОИ АКТИВНЫЕ', style: AppText.eyebrow.copyWith(color: AppColors.text, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  const PhotoPlaceholder(width: 112, darkScrim: true),
                  Expanded(
                    child: Container(
                      color: AppColors.surface,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PillBadge(text: 'Активна', bg: AppColors.gold, fg: AppColors.bg),
                          const SizedBox(height: 8),
                          Text('Сила всего тела', style: AppText.cardTitle),
                          const SizedBox(height: 3),
                          Text('День 12 из 30 · 40%', style: AppText.metaSmall),
                          const SizedBox(height: 12),
                          const ProgressLine(value: 0.4, fill: AppColors.text, height: 6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _cats.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => FilterChipBtn(
                  label: _cats[i],
                  active: _cat == _cats[i],
                  onTap: () => setState(() => _cat = _cats[i]),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(AppIcons.filter, color: AppColors.text, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _programsGrid(List<({String badge, String cat, String level, int progress, double rating, int sessions, String title, int weeks})> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i += 2)
            Padding(
              padding: EdgeInsets.only(bottom: i + 2 < items.length ? 12 : 0),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _programCard(items[i])),
                    const SizedBox(width: 12),
                    if (i + 1 < items.length)
                      Expanded(child: _programCard(items[i + 1]))
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _programCard(({String badge, String cat, String level, int progress, double rating, int sessions, String title, int weeks}) p) {
    final lc = _levelColor(p.level);
    return GestureDetector(
      onTap: () {
        // Открываем детали программы. Пока используем образец данных,
        // но подставляем title/rating/уровень из карточки.
        final data = (
          title: p.title,
          rating: p.rating,
          isActive: p.progress >= 0,
          weeks: p.weeks,
          workouts: p.sessions,
          level: p.level,
          currentDay: ProgramDetailScreen.sample.currentDay,
          totalDays: ProgramDetailScreen.sample.totalDays,
          progress: p.progress >= 0 ? p.progress : 0,
          description: ProgramDetailScreen.sample.description,
          schedule: ProgramDetailScreen.sample.schedule,
        );
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ProgramDetailScreen(program: data),
        ));
      },
      child: ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                const PhotoPlaceholder(height: 130, darkScrim: true),
                if (p.badge.isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: PillBadge(text: p.badge, bg: _badgeColor(p.badge).bg, fg: _badgeColor(p.badge).fg),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xA60A0A0A), borderRadius: BorderRadius.circular(AppRadius.pill)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(AppIcons.star, color: AppColors.gold, size: 10),
                      const SizedBox(width: 3),
                      Text(p.rating.toStringAsFixed(1), style: AppText.metaSmall.copyWith(fontSize: 11, color: AppColors.text, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(p.title, style: AppText.body.copyWith(height: 1.2)),
                  const SizedBox(height: 5),
                  Text('${p.weeks} нед · ${p.sessions} тренировок', style: AppText.metaSmall),
                  const SizedBox(height: 8),
                  if (p.progress >= 0)
                    Row(children: [
                      Expanded(child: ProgressLine(value: p.progress / 100, fill: AppColors.gold, height: 4)),
                      const SizedBox(width: 6),
                      Text('${p.progress}%', style: AppText.metaSmall.copyWith(fontSize: 10.5, color: AppColors.gold, fontWeight: FontWeight.w700)),
                    ])
                  else
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: lc.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(5)),
                        child: Text(p.level, style: AppText.metaSmall.copyWith(fontSize: 10, color: lc, fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _workoutsList(List<({String cat, String equip, int mins, String title, String type})> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: items.map((w) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () {
                final data = (
                  title: w.title,
                  rating: WorkoutDetailScreen.sample.rating,
                  level: WorkoutDetailScreen.sample.level,
                  tags: [w.equip],
                  exercises: WorkoutDetailScreen.sample.exercises,
                  kcal: WorkoutDetailScreen.sample.kcal,
                  minutes: w.mins,
                  description: WorkoutDetailScreen.sample.description,
                  exerciseList: WorkoutDetailScreen.sample.exerciseList,
                );
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => WorkoutDetailScreen(workout: data),
                ));
              },
              child: SurfaceCard(
              radius: AppRadius.lg,
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Stack(
                    children: [
                      PhotoPlaceholder(
                        width: 72,
                        height: 72,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        icon: AppIcons.play,
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.whiteAlpha(0.25),
                              border: Border.all(color: AppColors.whiteAlpha(0.6), width: 1.5),
                            ),
                            child: const Icon(AppIcons.play, color: AppColors.text, size: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.whiteAlpha(0.08), borderRadius: BorderRadius.circular(5)),
                            child: Text(w.type.toUpperCase(), style: AppText.metaSmall.copyWith(fontSize: 10, letterSpacing: 0.3, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(w.title, style: AppText.body),
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(AppIcons.clock, color: AppColors.text, size: 12),
                          const SizedBox(width: 4),
                          Text('${w.mins} мин', style: AppText.metaSmall),
                          const SizedBox(width: 10),
                          Text('·', style: AppText.metaSmall),
                          const SizedBox(width: 10),
                          Text(w.equip, style: AppText.metaSmall),
                        ]),
                      ],
                    ),
                  ),
                  Icon(AppIcons.chevronRight, color: AppColors.dim2, size: 16),
                ],
              ),
            ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
