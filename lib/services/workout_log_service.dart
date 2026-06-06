import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Запись о завершённой тренировке: настроение + опциональная заметка.
class WorkoutLogEntry {
  final String workoutTitle;
  final String? mood; // 'tough' | 'good' | 'fire' | null
  final String? note;
  final DateTime date;
  const WorkoutLogEntry({
    required this.workoutTitle,
    this.mood,
    this.note,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'title': workoutTitle,
        'mood': mood,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory WorkoutLogEntry.fromJson(Map<String, dynamic> j) => WorkoutLogEntry(
        workoutTitle: j['title'] as String? ?? '',
        mood: j['mood'] as String?,
        note: j['note'] as String?,
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Запись лога к упражнению (используется на этапе 3): вес/повторы + заметка.
class ExerciseLogEntry {
  final String exerciseName;
  final String? weight; // строкой: бывает «12 кг», «BW» и т.п.
  final int? reps;
  final String? note;
  final DateTime date;
  const ExerciseLogEntry({
    required this.exerciseName,
    this.weight,
    this.reps,
    this.note,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'name': exerciseName,
        'weight': weight,
        'reps': reps,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory ExerciseLogEntry.fromJson(Map<String, dynamic> j) => ExerciseLogEntry(
        exerciseName: j['name'] as String? ?? '',
        weight: j['weight'] as String?,
        reps: (j['reps'] as num?)?.toInt(),
        note: j['note'] as String?,
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Локальное хранилище логов и заметок (заглушка на shared_preferences).
/// Образец интерфейса как у AuthService: при появлении бэкенда меняются
/// ТОЛЬКО тела методов, сигнатуры и экраны не трогаются.
class WorkoutLogService {
  static const _kWorkoutLog = 'wlog_workout_entries'; // JSON-массив строк
  static String _exKey(String name) =>
      'wlog_ex_${name.toLowerCase().trim()}';

  // ───── Уровень тренировки (этап 2) ─────

  static Future<void> saveWorkoutEntry({
    required String workoutTitle,
    String? mood,
    String? note,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kWorkoutLog) ?? <String>[];
    final entry = WorkoutLogEntry(
      workoutTitle: workoutTitle,
      mood: mood,
      note: (note != null && note.isEmpty) ? null : note,
      date: DateTime.now(),
    );
    list.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_kWorkoutLog, list);
  }

  /// Свежие записи сверху.
  static Future<List<WorkoutLogEntry>> workoutHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kWorkoutLog) ?? <String>[];
    return list
        .map((s) => WorkoutLogEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
        .reversed
        .toList();
  }

  // ───── Уровень упражнения (этап 3 — интерфейс готов заранее) ─────

  static Future<void> saveExerciseLog({
    required String exerciseName,
    String? weight,
    int? reps,
    String? note,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _exKey(exerciseName);
    final list = prefs.getStringList(key) ?? <String>[];
    final entry = ExerciseLogEntry(
      exerciseName: exerciseName,
      weight: weight,
      reps: reps,
      note: (note != null && note.isEmpty) ? null : note,
      date: DateTime.now(),
    );
    list.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(key, list);
  }

  /// Свежие записи сверху.
  static Future<List<ExerciseLogEntry>> exerciseHistory(String exerciseName) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_exKey(exerciseName)) ?? <String>[];
    return list
        .map((s) => ExerciseLogEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
        .reversed
        .toList();
  }

  /// «Прошлый раз …» — последняя запись по упражнению (для подсказки в плеере).
  static Future<ExerciseLogEntry?> lastExerciseLog(String exerciseName) async {
    final h = await exerciseHistory(exerciseName);
    return h.isEmpty ? null : h.first;
  }
}
