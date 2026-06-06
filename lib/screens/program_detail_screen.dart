import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import '../widgets/common.dart';
import '../widgets/detail_common.dart';
import 'player_screen.dart';
import 'workout_detail_screen.dart';

typedef ScheduleItem = ({int week, int day, String title, int minutes, String status});

typedef ProgramData = ({
  String title,
  double rating,
  bool isActive,
  int weeks,
  int workouts,
  String level,
  int currentDay,
  int totalDays,
  int progress,
  String description,
  List<ScheduleItem> schedule,
});

class ProgramDetailScreen extends StatelessWidget {
  final ProgramData program;
  const ProgramDetailScreen({super.key, required this.program});

  static const ProgramData sample = (
    title: 'Сила и рельеф',
    rating: 4.8,
    isActive: true,
    weeks: 6,
    workouts: 24,
    level: 'Сложно',
    currentDay: 12,
    totalDays: 30,
    progress: 40,
    description:
        'Прогрессивный план на силу и плотность мышц. Каждая неделя усиливает нагрузку: больше подходов, тяжелее веса, короче паузы. Подходит для среднего уровня и выше.',
    schedule: [
      (week: 1, day: 1, title: 'Ноги · вводная', minutes: 32, status: 'done'),
      (week: 1, day: 3, title: 'Верх · толкающие', minutes: 28, status: 'done'),
      (week: 1, day: 5, title: 'Верх · тянущие', minutes: 30, status: 'done'),
      (week: 2, day: 8, title: 'Ноги · мощность', minutes: 35, status: 'current'),
      (week: 2, day: 10, title: 'Кор и стабильность', minutes: 22, status: 'locked'),
      (week: 2, day: 12, title: 'Верх · объём', minutes: 34, status: 'locked'),
      (week: 3, day: 15, title: 'Ноги · сила', minutes: 38, status: 'locked'),
      (week: 3, day: 17, title: 'Активное восстановление', minutes: 25, status: 'locked'),
    ],
  );

  // ── Шаблоны упражнений по категориям дня ──────────────────────────────
  // Уровни строго из проверенного набора: Сильно / Средне / Легко.
  static const List<Exercise> _legsEx = [
    (name: 'Приседания со штангой', meta: '4 × 12', level: 'Сильно'),
    (name: 'Выпады с гантелями', meta: '3 × 10 на ногу', level: 'Средне'),
    (name: 'Румынская тяга', meta: '4 × 10', level: 'Сильно'),
    (name: 'Ягодичный мост', meta: '3 × 15', level: 'Средне'),
    (name: 'Подъёмы на носки', meta: '4 × 20', level: 'Легко'),
    (name: 'Планка с подъёмом ноги', meta: '3 × 40 сек', level: 'Средне'),
  ];
  static const List<Exercise> _upperEx = [
    (name: 'Жим гантелей лёжа', meta: '4 × 12', level: 'Сильно'),
    (name: 'Тяга гантели в наклоне', meta: '3 × 12 на руку', level: 'Средне'),
    (name: 'Жим над головой', meta: '4 × 10', level: 'Сильно'),
    (name: 'Подтягивания', meta: '3 × max', level: 'Сильно'),
    (name: 'Разведения гантелей', meta: '3 × 15', level: 'Легко'),
    (name: 'Отжимания', meta: '3 × 15', level: 'Средне'),
  ];
  static const List<Exercise> _coreEx = [
    (name: 'Планка', meta: '3 × 60 сек', level: 'Средне'),
    (name: 'Скручивания', meta: '3 × 20', level: 'Легко'),
    (name: 'Боковая планка', meta: '3 × 40 сек на бок', level: 'Средне'),
    (name: 'Велосипед', meta: '3 × 30', level: 'Средне'),
    (name: 'Подъём ног в висе', meta: '3 × 12', level: 'Сильно'),
    (name: 'Гиперэкстензия', meta: '3 × 15', level: 'Легко'),
  ];
  static const List<Exercise> _recoveryEx = [
    (name: 'Суставная разминка', meta: '5 мин', level: 'Легко'),
    (name: 'Кошка-корова', meta: '3 × 10', level: 'Легко'),
    (name: 'Растяжка бёдер', meta: '3 × 30 сек', level: 'Легко'),
    (name: 'Наклоны к ногам', meta: '3 × 30 сек', level: 'Легко'),
    (name: 'Дыхательная практика', meta: '4 мин', level: 'Легко'),
    (name: 'Заминка-растяжка', meta: '5 мин', level: 'Легко'),
  ];

  /// Собирает WorkoutData для дня расписания: заголовок и минуты берутся
  /// из самого ScheduleItem (чтобы шапка деталей совпадала с нажатой строкой),
  /// а упражнения/теги/ккал — по категории дня. Типы не меняем.
  /// Публичный статический — единый источник правды и для деталей, и для Главной.
  static WorkoutData workoutFor(ScheduleItem it, {double rating = 4.8}) {
    final t = it.title.toLowerCase();
    late final String level;
    late final List<String> tags;
    late final int kcal;
    late final List<Exercise> list;
    late final String descr;

    if (t.startsWith('ноги')) {
      level = 'Сильно';
      tags = const ['Без прыжков', 'Гантели'];
      kcal = 320;
      list = _legsEx;
      descr = 'Силовая проработка ног: квадрицепсы, ягодицы и бицепс бедра. '
          'Базовые движения с прогрессией веса и короткими паузами между подходами.';
    } else if (t.startsWith('верх')) {
      level = 'Сильно';
      tags = const ['Гантели', 'Турник'];
      kcal = 280;
      list = _upperEx;
      descr = 'Тренировка верха тела: грудь, спина, плечи и руки. Сочетание '
          'жимовых и тяговых движений для сбалансированного развития.';
    } else if (t.startsWith('кор')) {
      level = 'Средне';
      tags = const ['Без инвентаря', 'Коврик'];
      kcal = 180;
      list = _coreEx;
      descr = 'Работа над кором и стабильностью: глубокие мышцы живота, '
          'поясница и баланс. Контролируемый темп, акцент на технику.';
    } else {
      level = 'Легко';
      tags = const ['Без инвентаря', 'Растяжка'];
      kcal = 120;
      list = _recoveryEx;
      descr = 'Лёгкая восстановительная сессия: мобилизация суставов, растяжка '
          'и дыхание. Снижает крепатуру и готовит тело к следующей нагрузке.';
    }

    return (
      title: it.title,
      rating: rating,
      level: level,
      tags: tags,
      exercises: list.length,
      kcal: kcal,
      minutes: it.minutes,
      description: descr,
      exerciseList: list,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 130),
            children: [
              DetailCover(
                icon: AppIcons.dumbbell,
                floatingChip: const DetailFloatingChip(icon: AppIcons.grid, label: 'Программа'),
              ),
              // Заголовок + бейдж + рейтинг
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (program.isActive)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: PillBadge(text: 'Активна', bg: AppColors.gold, fg: AppColors.bg),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(program.title, style: AppText.metricLg.copyWith(fontSize: 28, letterSpacing: -0.6, height: 1.1)),
                        ),
                        const SizedBox(width: 14),
                        RatingPill(rating: program.rating),
                      ],
                    ),
                  ],
                ),
              ),
              // Метрики
              MetricsRow(items: [
                (value: '${program.weeks}', label: 'недель', color: null),
                (value: '${program.workouts}', label: 'тренировок', color: null),
                (value: program.level, label: 'уровень', color: levelColor(program.level)),
              ]),
              // Прогресс (если активна)
              if (program.isActive)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
                  child: SurfaceCard(
                    radius: AppRadius.xl,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: Border.all(color: AppColors.goldTint(0.2)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ТВОЙ ПРОГРЕСС', style: AppText.eyebrow.copyWith(color: AppColors.gold, letterSpacing: 1.2)),
                                const SizedBox(height: 4),
                                Text('День ${program.currentDay} из ${program.totalDays}', style: AppText.cardTitle),
                              ],
                            ),
                            Text('${program.progress}%', style: AppText.metricLg.copyWith(color: AppColors.gold)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ProgressLine(value: program.progress / 100, fill: AppColors.gold, height: 6),
                      ],
                    ),
                  ),
                ),
              // Описание
              DetailDescription(text: program.description),
              // Расписание
              DetailSectionHeader(title: 'Расписание', action: '${program.schedule.length}'),
              _scheduleList(context),
            ],
          ),
          DetailHeaderOverlay(onBack: () => Navigator.of(context).maybePop()),
          DetailStickyCta(
            label: program.isActive ? 'Продолжить' : 'Начать программу',
            onTap: () async {
              // Тренировка текущего дня программы (или первая, если current нет).
              final current = program.schedule.firstWhere(
                (it) => it.status == 'current',
                orElse: () => program.schedule.first,
              );
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => PlayerScreen(
                    workout: buildPlayerWorkout(workoutFor(current, rating: program.rating)),
                  ),
                ),
              );
              if (result == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Тренировка дня завершена 💪'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _scheduleList(BuildContext context) {
    final widgets = <Widget>[];
    int? lastWeek;
    for (final it in program.schedule) {
      if (it.week != lastWeek) {
        widgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
          child: Text('НЕДЕЛЯ ${it.week}', style: AppText.eyebrow.copyWith(letterSpacing: 1.2)),
        ));
        lastWeek = it.week;
      }
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _scheduleRow(context, it),
      ));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: widgets),
    );
  }

  Widget _scheduleRow(BuildContext context, ScheduleItem it) {
    final isDone = it.status == 'done';
    final isCurrent = it.status == 'current';
    final isLocked = it.status == 'locked';

    Widget statusDot() {
      Color bg;
      if (isDone) {
        bg = AppColors.gold;
      } else if (isCurrent) {
        bg = AppColors.goldTint(0.13);
      } else {
        bg = AppColors.whiteAlpha(0.06);
      }
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: isCurrent ? Border.all(color: AppColors.gold, width: 1.5) : null,
        ),
        child: isDone
            ? const Icon(Icons.check, color: AppColors.bg, size: 16)
            : isCurrent
                ? const Icon(AppIcons.play, color: AppColors.gold, size: 13)
                : Icon(AppIcons.lock, color: AppColors.whiteAlpha(0.55), size: 14),
      );
    }

    final row = Opacity(
      opacity: isLocked ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrent ? AppColors.goldTint(0.06) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isCurrent ? AppColors.goldTint(0.33) : AppColors.border),
        ),
        child: Row(
          children: [
            statusDot(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('День ${it.day} · ${it.title}',
                      style: AppText.body.copyWith(fontSize: 14, color: isCurrent ? AppColors.gold : AppColors.text)),
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(AppIcons.clock, color: AppColors.eyebrow, size: 11),
                    const SizedBox(width: 6),
                    Text('${it.minutes} мин', style: AppText.metaSmall.copyWith(fontSize: 12)),
                    if (isDone) ...[
                      const SizedBox(width: 6),
                      Text('· Выполнено', style: AppText.metaSmall.copyWith(fontSize: 12, color: AppColors.mutedGreen, fontWeight: FontWeight.w700)),
                    ],
                    if (isCurrent) ...[
                      const SizedBox(width: 6),
                      Text('· Сегодня', style: AppText.metaSmall.copyWith(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w700)),
                    ],
                  ]),
                ],
              ),
            ),
            if (!isLocked) Icon(AppIcons.chevronRight, color: AppColors.dim2, size: 16),
          ],
        ),
      ),
    );

    // Locked-дни не открываются — совпадает с визуалом (приглушены, замок,
    // нет чевронки). Чтобы в портфолио ревьюер мог открыть любой день,
    // удали эту строку (тогда locked тоже станут кликабельными).
    if (isLocked) return row;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WorkoutDetailScreen(workout: workoutFor(it, rating: program.rating)),
        ),
      ),
      child: row,
    );
  }
}
