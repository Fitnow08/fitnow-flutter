import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Маппинг иконок FitNow → Lucide (пакет lucide_icons_flutter, совместим с
/// Flutter 3.44+, где IconData стал final).
///
/// Исходные SVG в kit были stroke-based weight 1.7 — это ровно стиль Lucide,
/// поэтому визуально совпадает. Где точного эквивалента нет — подобран
/// ближайший по смыслу/форме.
class AppIcons {
  AppIcons._();

  // Навигация (таб-бар)
  static const home = LucideIcons.house;
  static const chart = LucideIcons.chartColumn;
  static const grid = LucideIcons.layoutGrid;
  static const user = LucideIcons.user;

  // Действия / UI
  static const search = LucideIcons.search;
  static const bell = LucideIcons.bell;
  static const arrowRight = LucideIcons.arrowRight;
  static const arrowUpRight = LucideIcons.arrowUpRight;
  static const chevronRight = LucideIcons.chevronRight;
  static const chevronLeft = LucideIcons.chevronLeft;
  static const play = LucideIcons.play;
  static const settings = LucideIcons.settings;
  static const share = LucideIcons.share;
  static const camera = LucideIcons.camera;
  static const lock = LucideIcons.lock;
  static const filter = LucideIcons.slidersHorizontal;
  static const bookmark = LucideIcons.bookmark;
  static const plus = LucideIcons.plus;

  // Тематические (фитнес/достижения)
  static const flame = LucideIcons.flame;
  static const dumbbell = LucideIcons.dumbbell;
  static const yoga = LucideIcons.personStanding; // ближайшее к «йога»
  static const run = LucideIcons.footprints; // бег
  static const bolt = LucideIcons.zap;
  static const sunrise = LucideIcons.sunrise;
  static const trophy = LucideIcons.trophy;
  static const medal = LucideIcons.medal;
  static const target = LucideIcons.target;
  static const clock = LucideIcons.clock;
  static const watch = LucideIcons.watch;
  static const star = LucideIcons.star;
  static const globe = LucideIcons.globe;
  static const moon = LucideIcons.moon;
  static const heart = LucideIcons.heart;
}
