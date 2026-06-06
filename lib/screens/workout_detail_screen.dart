import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import '../widgets/common.dart';
import '../widgets/detail_common.dart';
import 'player_screen.dart';

/// Данные одного упражнения
typedef Exercise = ({String name, String meta, String level});

/// Данные тренировки для экрана деталей
typedef WorkoutData = ({
  String title,
  double rating,
  String level,
  List<String> tags,
  int exercises,
  int kcal,
  int minutes,
  String description,
  List<Exercise> exerciseList,
});

class WorkoutDetailScreen extends StatelessWidget {
  final WorkoutData workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  /// Дефолтные данные («Ноги в огне») — как в JSX
  static const WorkoutData sample = (
    title: 'Ноги в огне',
    rating: 4.8,
    level: 'Сильно',
    tags: ['Без прыжков', 'Гантели'],
    exercises: 6,
    kcal: 320,
    minutes: 28,
    description:
        'Высокоинтенсивная проработка квадрицепсов, ягодиц и икроножных. Подойдёт для среднего и продвинутого уровня. Каждое упражнение — 3 подхода с короткими паузами.',
    exerciseList: [
      (name: 'Приседания со штангой', meta: '4 × 12', level: 'Сильно'),
      (name: 'Выпады с гантелями', meta: '3 × 10 на ногу', level: 'Средне'),
      (name: 'Румынская тяга', meta: '4 × 10', level: 'Сильно'),
      (name: 'Ягодичный мост', meta: '3 × 15', level: 'Средне'),
      (name: 'Подъёмы на носки', meta: '4 × 20', level: 'Легко'),
      (name: 'Планка с подъёмом ноги', meta: '3 × 40 сек', level: 'Средне'),
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
                floatingChip: DetailFloatingChip(
                  icon: AppIcons.clock,
                  label: '${workout.minutes} мин',
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ТРЕНИРОВКА', style: AppText.eyebrow.copyWith(letterSpacing: 1.4)),
                          const SizedBox(height: 6),
                          Text(workout.title, style: AppText.metricLg.copyWith(fontSize: 28, letterSpacing: -0.6, height: 1.1)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    RatingPill(rating: workout.rating),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    LevelChip(level: workout.level),
                    ...workout.tags.map((t) => NeutralChip(label: t)),
                  ],
                ),
              ),
              MetricsRow(items: [
                (value: '${workout.exercises}', label: 'упражнений', color: null),
                (value: '${workout.kcal}', label: 'ккал', color: null),
                (value: '${workout.minutes}', label: 'минут', color: null),
              ]),
              DetailDescription(text: workout.description),
              DetailSectionHeader(title: 'Упражнения', action: '${workout.exerciseList.length}'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: List.generate(workout.exerciseList.length, (i) {
                    final ex = workout.exerciseList[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SurfaceCard(
                        radius: AppRadius.lg,
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                PhotoPlaceholder(
                                  width: 64,
                                  height: 64,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  icon: AppIcons.dumbbell,
                                ),
                                Positioned(
                                  left: 6,
                                  bottom: 6,
                                  child: Text(
                                    (i + 1).toString().padLeft(2, '0'),
                                    style: AppText.metaSmall.copyWith(fontSize: 11, color: AppColors.text, fontWeight: FontWeight.w800),
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
                                  Text(ex.name, style: AppText.body.copyWith(fontSize: 14.5)),
                                  const SizedBox(height: 6),
                                  Row(children: [
                                    Text(ex.meta, style: AppText.metaSmall.copyWith(fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 8),
                                    Container(width: 3, height: 3, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.whiteAlpha(0.2))),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: levelColor(ex.level).withValues(alpha: 0.13),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(ex.level, style: AppText.metaSmall.copyWith(fontSize: 10.5, color: levelColor(ex.level), fontWeight: FontWeight.w700)),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                            Icon(AppIcons.chevronRight, color: AppColors.dim2, size: 16),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          DetailHeaderOverlay(onBack: () => Navigator.of(context).maybePop()),
          DetailStickyCta(
            label: 'Начать',
            onTap: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => PlayerScreen(workout: buildPlayerWorkout(workout)),
                ),
              );
              if (result == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Тренировка завершена 💪'),
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
}


/// Преобразует WorkoutData (детали/программа) в PlayerWorkout для плеера.
/// Парсит meta упражнения («4 × 12», «3 × 40 сек», «5 мин», «3 × max», …)
/// в подходы / тип (reps|time) / количество.
PlayerWorkout buildPlayerWorkout(WorkoutData w) {
  final list = w.exerciseList.map(_playerExerciseFromMeta).toList();
  return PlayerWorkout(
    title: w.title,
    minutes: w.minutes,
    kcal: w.kcal,
    exercises: list.isEmpty
        ? const [PlayerExercise(name: 'Упражнение', sets: 1, kind: ExerciseKind.reps, amount: 10)]
        : list,
  );
}

PlayerExercise _playerExerciseFromMeta(Exercise e) {
  final meta = e.meta;
  final lower = meta.toLowerCase();
  final isTime = lower.contains('сек') || lower.contains('мин');
  final isMin = lower.contains('мин');

  final nums = RegExp(r'\d+').allMatches(meta).map((m) => int.parse(m.group(0)!)).toList();

  int sets;
  int amount;
  if (meta.contains('×')) {
    sets = nums.isNotEmpty ? nums[0] : 1;
    amount = nums.length > 1 ? nums[1] : 12; // «3 × max» — нет второго числа
  } else {
    sets = 1;
    amount = nums.isNotEmpty ? nums[0] : 1;
  }
  if (isMin) amount *= 60; // минуты → секунды

  String? unit;
  if (isTime) {
    unit = 'сек';
  } else {
    for (final phrase in const ['на ногу', 'на руку', 'на бок']) {
      if (lower.contains(phrase)) {
        unit = phrase;
        break;
      }
    }
  }

  if (isTime && amount <= 0) amount = 30; // защита от деления на ноль в кольце

  return PlayerExercise(
    name: e.name,
    sets: sets < 1 ? 1 : sets,
    kind: isTime ? ExerciseKind.time : ExerciseKind.reps,
    amount: amount < 0 ? 0 : amount,
    unit: unit,
  );
}
