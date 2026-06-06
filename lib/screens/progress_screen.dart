import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import '../widgets/common.dart';
import '../services/workout_log_service.dart';

class ProgressScreen extends StatefulWidget {
  final String name;
  const ProgressScreen({super.key, this.name = ''});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<List<WorkoutLogEntry>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = WorkoutLogService.workoutHistory();
  }

  Future<void> _reloadHistory() async {
    final f = WorkoutLogService.workoutHistory();
    setState(() => _historyFuture = f);
    await f;
  }

  static const _week = [
    (d: 'Пн', m: 28, today: false),
    (d: 'Вт', m: 52, today: false),
    (d: 'Ср', m: 0, today: false),
    (d: 'Чт', m: 46, today: false),
    (d: 'Пт', m: 64, today: false),
    (d: 'Сб', m: 38, today: false),
    (d: 'Вс', m: 18, today: true),
  ];

  static const _prs = [
    (label: 'Макс. жим', value: '62', unit: 'кг', delta: '+4 кг', isPr: false, icon: AppIcons.dumbbell),
    (label: 'Дольше план', value: '2:18', unit: 'мин', delta: 'PR', isPr: true, icon: AppIcons.yoga),
    (label: 'Длинная пробежка', value: '8.4', unit: 'км', delta: '+1.2', isPr: false, icon: AppIcons.run),
    (label: 'Лучший темп', value: '5:42', unit: '/км', delta: '−12с', isPr: false, icon: AppIcons.bolt),
  ];

  static const _badges = [
    (name: '30 дней', sub: 'подряд', unlocked: true, icon: AppIcons.flame),
    (name: 'Ранняя пташка', sub: '5 утренних', unlocked: true, icon: AppIcons.sunrise),
    (name: 'Железная воля', sub: 'PR × 10', unlocked: true, icon: AppIcons.trophy),
    (name: 'Марафонец', sub: '42 км', unlocked: false, icon: AppIcons.medal),
    (name: 'Сотня', sub: '100 трен.', unlocked: false, icon: AppIcons.target),
    (name: 'Йога-мастер', sub: '50 сессий', unlocked: false, icon: AppIcons.yoga),
  ];

  @override
  Widget build(BuildContext context) {
    const maxM = 70.0;
    final totalMin = _week.fold<int>(0, (s, w) => s + w.m);

    return RefreshIndicator(
      onRefresh: _reloadHistory,
      color: AppColors.gold,
      backgroundColor: AppColors.surface,
      child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 56, bottom: 110),
      children: [
        _header(),
        const SizedBox(height: 20),
        _weeklyCard(totalMin, maxM),
        const SizedBox(height: 20),
        _comparison(),
        const SizedBox(height: 24),
        _diarySection(),
        const SizedBox(height: 28),
        _prSection(),
        const SizedBox(height: 28),
        _badgesSection(),
      ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Прогресс',
                    style: AppText.meta.copyWith(fontWeight: FontWeight.w500, letterSpacing: 0.2)),
                const SizedBox(height: 4),
                Text(widget.name.isEmpty ? 'Ты в огне!' : 'Ты в огне, ${widget.name}', style: AppText.bigTitle),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(AppIcons.flame, color: AppColors.gold, size: 14),
              const SizedBox(width: 6),
              Text('12 дней',
                  style: AppText.label.copyWith(fontWeight: FontWeight.w700)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _weeklyCard(int totalMin, double maxM) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SurfaceCard(
        radius: AppRadius.xxxl,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ЭТА НЕДЕЛЯ', style: AppText.eyebrow.copyWith(color: AppColors.text, letterSpacing: 1.2)),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(text: '$totalMin ', style: AppText.metricXl),
                          TextSpan(text: 'мин',
                              style: AppText.metricXl.copyWith(
                                  fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.eyebrow)),
                        ]),
                      ),
                      const SizedBox(height: 4),
                      Text('2 480 ккал · 5 тренировок', style: AppText.meta),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: AppColors.greenTint(0.13), borderRadius: BorderRadius.circular(AppRadius.sm)),
                  child: Text('↑ +18%',
                      style: AppText.metaSmall.copyWith(
                          color: AppColors.mutedGreen, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 124,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _week.map((w) {
                  final h = w.m == 0 ? 4.0 : (w.m / maxM * 92).clamp(12.0, 92.0);
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: h,
                          decoration: BoxDecoration(
                            color: w.today ? AppColors.gold : AppColors.chartGray,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(w.d,
                            style: AppText.metaSmall.copyWith(
                                color: w.today ? AppColors.gold : AppColors.eyebrow,
                                fontWeight: w.today ? FontWeight.w700 : FontWeight.w600)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _comparison() {
    Widget cell(String label, String value, Color valueColor, String sub) => Expanded(
          child: SurfaceCard(
            radius: AppRadius.lg,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.metaSmall.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: AppText.metricLg.copyWith(fontSize: 20, color: valueColor, letterSpacing: -0.3)),
                const SizedBox(height: 2),
                Text(sub, style: AppText.metaSmall),
              ],
            ),
          ),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        cell('Активность', '+18%', AppColors.mutedGreen, 'к прошлой неделе'),
        const SizedBox(width: 10),
        cell('Отдых', '−2 мин', AppColors.text, 'среднее'),
      ]),
    );
  }

  Widget _prSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Личные рекорды', style: AppText.sectionTitle),
              Text('Все', style: AppText.label.copyWith(color: AppColors.text)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              for (int i = 0; i < _prs.length; i += 2)
                Padding(
                  padding: EdgeInsets.only(bottom: i + 2 < _prs.length ? 10 : 0),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _prCard(_prs[i])),
                        const SizedBox(width: 10),
                        if (i + 1 < _prs.length)
                          Expanded(child: _prCard(_prs[i + 1]))
                        else
                          const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _prCard(({String label, String value, String unit, String delta, bool isPr, IconData icon}) p) {
    final tintBg = p.isPr ? AppColors.gold : AppColors.greenTint(0.13);
    final tintFg = p.isPr ? AppColors.bg : AppColors.mutedGreen;
    return SurfaceCard(
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: AppColors.whiteAlpha(0.06), borderRadius: BorderRadius.circular(10)),
            child: Icon(p.icon, color: AppColors.text, size: 18),
          ),
          const SizedBox(height: 10),
          Text(p.label, style: AppText.metaSmall.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(p.value, style: AppText.metricLg.copyWith(letterSpacing: -0.5)),
              const SizedBox(width: 4),
              Text(p.unit, style: AppText.meta.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: PillBadge(text: p.delta, bg: tintBg, fg: tintFg),
          ),
        ],
      ),
    );
  }

  Widget _badgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Достижения', style: AppText.sectionTitle),
              Text('3 из 24', style: AppText.label.copyWith(color: AppColors.eyebrow)),
            ],
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _badges.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final b = _badges[i];
              return Opacity(
                opacity: b.unlocked ? 1 : 0.55,
                child: Container(
                  width: 110,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: b.unlocked ? AppColors.surface : AppColors.whiteAlpha(0.03),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                        color: b.unlocked ? AppColors.goldTint(0.2) : AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: b.unlocked ? AppColors.goldTint(0.12) : AppColors.whiteAlpha(0.05),
                        ),
                        child: Icon(b.icon,
                            color: b.unlocked ? AppColors.gold : AppColors.whiteAlpha(0.5), size: 26),
                      ),
                      const SizedBox(height: 10),
                      Text(b.name,
                          textAlign: TextAlign.center,
                          style: AppText.metaSmall.copyWith(
                              fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text)),
                      const SizedBox(height: 2),
                      Text(b.sub, textAlign: TextAlign.center, style: AppText.metaSmall.copyWith(fontSize: 10.5)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  // ───── Этап 4: дневник тренировок (настроение + заметка) ─────

  Widget _diarySection() {
    return FutureBuilder<List<WorkoutLogEntry>>(
      future: _historyFuture,
      builder: (context, snap) {
        final entries = snap.data ?? const <WorkoutLogEntry>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Недавние тренировки', style: AppText.sectionTitle),
                  if (entries.isNotEmpty)
                    Text('${entries.length}', style: AppText.label.copyWith(color: AppColors.eyebrow)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: entries.isEmpty
                  ? _diaryEmpty()
                  : Column(
                      children: [
                        for (final e in entries.take(5))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _diaryCard(e),
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _diaryEmpty() {
    return SurfaceCard(
      radius: AppRadius.xl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.whiteAlpha(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_note_rounded, color: AppColors.dim2, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Здесь появятся твои тренировки — с настроением и заметкой после завершения.',
                style: AppText.metaSmall.copyWith(color: AppColors.eyebrow, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _diaryCard(WorkoutLogEntry e) {
    final glyph = _moodGlyph(e.mood);
    final hasNote = e.note != null && e.note!.isNotEmpty;
    return SurfaceCard(
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.whiteAlpha(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: glyph != null
                ? Text(glyph, style: const TextStyle(fontSize: 22))
                : const Icon(AppIcons.dumbbell, color: AppColors.dim2, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(e.workoutTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body.copyWith(fontSize: 14.5)),
                    ),
                    const SizedBox(width: 8),
                    Text(_relDate(e.date), style: AppText.metaSmall.copyWith(fontSize: 12)),
                  ],
                ),
                if (hasNote) ...[
                  const SizedBox(height: 6),
                  Text('«${e.note!}»',
                      style: AppText.metaSmall.copyWith(fontSize: 13, color: AppColors.dim, height: 1.35)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _moodGlyph(String? mood) {
    switch (mood) {
      case 'tough':
        return '😮‍💨';
      case 'good':
        return '🙂';
      case 'fire':
        return '🔥';
      default:
        return null;
    }
  }

  String _relDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = today.difference(that).inDays;
    if (diff <= 0) return 'сегодня';
    if (diff == 1) return 'вчера';
    if (diff < 7) return '$diff дн назад';
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
  }

}
