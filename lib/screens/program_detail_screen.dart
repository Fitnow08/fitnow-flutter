import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import '../widgets/common.dart';
import '../widgets/detail_common.dart';
import 'player_screen.dart';

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
              _scheduleList(),
            ],
          ),
          DetailHeaderOverlay(onBack: () => Navigator.of(context).maybePop()),
          DetailStickyCta(
            label: program.isActive ? 'Продолжить' : 'Начать программу',
            onTap: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => const PlayerScreen(workout: PlayerWorkout.sample),
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

  Widget _scheduleList() {
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
        child: _scheduleRow(it),
      ));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: widgets),
    );
  }

  Widget _scheduleRow(ScheduleItem it) {
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

    return Opacity(
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
  }
}
