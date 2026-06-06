import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import '../widgets/progress_ring.dart';
import '../services/workout_log_service.dart';

/// Тип упражнения: на повторы или на время
enum ExerciseKind { reps, time }

/// Упражнение в плеере (плеер хранит свой формат, не зависит от деталей)
class PlayerExercise {
  final String name;
  final int sets;
  final ExerciseKind kind;
  final int amount; // повторов или секунд
  final String? unit; // 'на ногу' / 'сек' / null
  const PlayerExercise({
    required this.name,
    required this.sets,
    required this.kind,
    required this.amount,
    this.unit,
  });
}

/// Данные тренировки для плеера
class PlayerWorkout {
  final String title;
  final int minutes;
  final int kcal;
  final List<PlayerExercise> exercises;
  const PlayerWorkout({required this.title, required this.minutes, required this.kcal, required this.exercises});

  /// Образец — «Ноги в огне», как в JSX
  static const sample = PlayerWorkout(
    title: 'Ноги в огне',
    minutes: 28,
    kcal: 320,
    exercises: [
      PlayerExercise(name: 'Приседания со штангой', sets: 4, kind: ExerciseKind.reps, amount: 12),
      PlayerExercise(name: 'Выпады с гантелями', sets: 3, kind: ExerciseKind.reps, amount: 10, unit: 'на ногу'),
      PlayerExercise(name: 'Румынская тяга', sets: 4, kind: ExerciseKind.reps, amount: 10),
      PlayerExercise(name: 'Ягодичный мост', sets: 3, kind: ExerciseKind.reps, amount: 15),
      PlayerExercise(name: 'Подъёмы на носки', sets: 4, kind: ExerciseKind.reps, amount: 20),
      PlayerExercise(name: 'Планка с подъёмом ноги', sets: 3, kind: ExerciseKind.time, amount: 40, unit: 'сек'),
    ],
  );
}

enum _Phase { countdown, active, rest, paused, finished }

class PlayerScreen extends StatefulWidget {
  final PlayerWorkout workout;
  const PlayerScreen({super.key, required this.workout});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  _Phase _phase = _Phase.countdown;
  int _exIdx = 0;
  int _setIdx = 1;
  int _count = 3;
  int _timeLeft = 0;
  int _restLeft = 45;
  static const _restTotal = 45;

  Timer? _timer;

  // Этап 3: заметка к упражнению (инлайн-редактор, без модалок)
  final TextEditingController _exNoteCtrl = TextEditingController();
  bool _noteOpen = false;
  int _logTick = 0;
  Future<ExerciseLogEntry?>? _lastLogFuture;
  String? _lastLogKey;

  PlayerWorkout get _w => widget.workout;
  PlayerExercise get _ex => _w.exercises[_exIdx];
  int get _total => _w.exercises.length;

  @override
  void initState() {
    super.initState();
    _timeLeft = _w.exercises[0].kind == ExerciseKind.time ? _w.exercises[0].amount : 0;
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _exNoteCtrl.dispose();
    super.dispose();
  }

  // ───── Таймеры ─────

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 900), (t) {
      if (!mounted) return;
      setState(() {
        if (_count <= 1) {
          t.cancel();
          _count = 0;
          _phase = _Phase.active;
          _startActiveTimer();
        } else {
          _count--;
        }
      });
    });
  }

  void _startActiveTimer() {
    _timer?.cancel();
    if (_ex.kind != ExerciseKind.time) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft <= 1) {
          t.cancel();
          _timeLeft = 0;
          _advanceSet();
        } else {
          _timeLeft--;
        }
      });
    });
  }

  void _startRestTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_restLeft <= 1) {
          t.cancel();
          _restLeft = 0;
          _startNextSet();
        } else {
          _restLeft--;
        }
      });
    });
  }

  // ───── Логика переходов ─────

  void _advanceSet() {
    if (_setIdx < _ex.sets) {
      // Ещё есть подходы — идём на отдых
      _restLeft = _restTotal;
      setState(() => _phase = _Phase.rest);
      _startRestTimer();
    } else {
      // Подходы кончились — следующее упражнение или финал
      if (_exIdx + 1 >= _w.exercises.length) {
        _timer?.cancel();
        setState(() => _phase = _Phase.finished);
      } else {
        _exIdx++;
        _setIdx = 1;
        _restLeft = _restTotal;
        _timeLeft = _ex.kind == ExerciseKind.time ? _ex.amount : 0;
        setState(() => _phase = _Phase.rest);
        _startRestTimer();
      }
    }
  }

  void _startNextSet() {
    if (_setIdx < _ex.sets) {
      _setIdx++;
    }
    _timeLeft = _ex.kind == ExerciseKind.time ? _ex.amount : 0;
    setState(() => _phase = _Phase.active);
    _startActiveTimer();
  }

  void _onPrimary() {
    if (_ex.kind == ExerciseKind.time) {
      // На time-упражнении главная кнопка — пауза
      _timer?.cancel();
      setState(() => _phase = _Phase.paused);
    } else {
      _advanceSet();
    }
  }

  void _onPrev() {
    if (_exIdx > 0) {
      _timer?.cancel();
      setState(() {
        _exIdx--;
        _setIdx = 1;
        _timeLeft = _ex.kind == ExerciseKind.time ? _ex.amount : 0;
      });
      if (_phase == _Phase.active) _startActiveTimer();
    }
  }

  void _onNext() {
    _timer?.cancel();
    if (_exIdx + 1 < _w.exercises.length) {
      setState(() {
        _exIdx++;
        _setIdx = 1;
        _timeLeft = _ex.kind == ExerciseKind.time ? _ex.amount : 0;
      });
      if (_phase == _Phase.active) _startActiveTimer();
    } else {
      setState(() => _phase = _Phase.finished);
    }
  }

  Future<void> _confirmExit() async {
    _timer?.cancel();
    setState(() => _phase = _Phase.paused);
  }

  void _resume() {
    setState(() => _phase = _Phase.active);
    _startActiveTimer();
  }

  void _exitWorkout() {
    Navigator.of(context).pop();
  }

  // ───── Этап 3: заметка к упражнению ─────

  // Стабильный future для подсказки «прошлый раз»: пересоздаётся только при
  // смене упражнения или после сохранения (_logTick), иначе FutureBuilder
  // не дёргал бы запрос на каждый тик таймера.
  Future<ExerciseLogEntry?> _lastLogForCurrent() {
    final k = '${_ex.name}_$_logTick';
    if (_lastLogKey != k) {
      _lastLogKey = k;
      _lastLogFuture = WorkoutLogService.lastExerciseLog(_ex.name);
    }
    return _lastLogFuture!;
  }

  void _openExNote() {
    _timer?.cancel();
    _exNoteCtrl.clear();
    setState(() => _noteOpen = true);
  }

  void _closeExNote() {
    setState(() => _noteOpen = false);
    _startActiveTimer(); // no-op для reps, возобновляет отсчёт для time
  }

  Future<void> _saveExNote() async {
    final t = _exNoteCtrl.text.trim();
    if (t.isNotEmpty) {
      await WorkoutLogService.saveExerciseLog(exerciseName: _ex.name, note: t);
    }
    if (!mounted) return;
    setState(() {
      _noteOpen = false;
      _logTick++;
    });
    _startActiveTimer();
  }

  Widget _lastNoteHint() {
    return FutureBuilder<ExerciseLogEntry?>(
      future: _lastLogForCurrent(),
      builder: (context, snap) {
        final last = snap.data;
        if (last == null || last.note == null || last.note!.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.history_rounded, color: AppColors.eyebrow, size: 13),
                const SizedBox(width: 7),
                Flexible(
                  child: Text('Прошлый раз: «${last.note}»',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.metaSmall.copyWith(fontSize: 12, color: AppColors.dim)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Инлайн-редактор заметки (вместо active-вида), без модального роута.
  Widget _noteEditor() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _closeExNote,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.close, color: AppColors.text, size: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Заметка к упражнению', style: AppText.cardTitle),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_ex.name.toUpperCase(), style: AppText.eyebrow.copyWith(letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    FutureBuilder<ExerciseLogEntry?>(
                      future: _lastLogForCurrent(),
                      builder: (context, snap) {
                        final last = snap.data;
                        if (last == null || last.note == null || last.note!.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.history_rounded, color: AppColors.eyebrow, size: 14),
                                    const SizedBox(width: 7),
                                    Text('ПРОШЛЫЙ РАЗ', style: AppText.eyebrow.copyWith(fontSize: 10.5, letterSpacing: 1.2)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(last.note!, style: AppText.body.copyWith(fontSize: 14, color: AppColors.text)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    TextField(
                      controller: _exNoteCtrl,
                      autofocus: true,
                      minLines: 3,
                      maxLines: 6,
                      maxLength: 200,
                      cursorColor: AppColors.lime,
                      style: AppText.body.copyWith(color: AppColors.text, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Например: гантели 12 кг тяжело, взять 10',
                        hintStyle: AppText.body.copyWith(color: AppColors.dim2, fontSize: 14),
                        filled: true,
                        fillColor: AppColors.surface,
                        counterStyle: AppText.metaSmall.copyWith(color: AppColors.eyebrow),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide(color: AppColors.gold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _saveExNote,
              child: Container(
                width: double.infinity,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [BoxShadow(color: AppColors.lime.withValues(alpha: 0.25), blurRadius: 32, offset: const Offset(0, 12))],
                ),
                child: Text('Сохранить заметку',
                    style: AppText.cardTitle.copyWith(color: AppColors.bg, fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───── Сборка экрана ─────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _phase == _Phase.finished,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _phase != _Phase.paused && _phase != _Phase.finished) {
          _confirmExit();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: _buildPhase(),
      ),
    );
  }

  Widget _buildPhase() {
    switch (_phase) {
      case _Phase.countdown:
        return _countdown();
      case _Phase.active:
        return _active();
      case _Phase.rest:
        return _rest();
      case _Phase.paused:
        return _paused();
      case _Phase.finished:
        return _finished();
    }
  }

  // ───── State 1: Countdown ─────
  Widget _countdown() {
    final first = _w.exercises[0];
    return Stack(
      children: [
        // Lime glow
        Center(
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.lime.withValues(alpha: 0.13), Colors.transparent],
                stops: const [0.0, 0.6],
              ),
            ),
          ),
        ),
        Column(
          children: [
            // Skip top-right
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    _timer?.cancel();
                    setState(() {
                      _count = 0;
                      _phase = _Phase.active;
                    });
                    _startActiveTimer();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('Пропустить', style: AppText.label.copyWith(color: AppColors.eyebrow)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ГОТОВЬСЯ',
                      style: AppText.eyebrow.copyWith(color: AppColors.lime, letterSpacing: 1.8)),
                  const SizedBox(height: 16),
                  Text(
                    '$_count',
                    style: AppText.metricXl.copyWith(
                      fontSize: 180,
                      height: 1.0,
                      letterSpacing: -8,
                      shadows: [Shadow(color: AppColors.lime.withValues(alpha: 0.25), blurRadius: 60)],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 64),
              child: Column(
                children: [
                  Text('ПЕРВОЕ УПРАЖНЕНИЕ', style: AppText.eyebrow.copyWith(letterSpacing: 1.4)),
                  const SizedBox(height: 8),
                  Text(first.name, textAlign: TextAlign.center, style: AppText.metricLg.copyWith(fontSize: 22, letterSpacing: -0.4)),
                  const SizedBox(height: 4),
                  Text(_exerciseMeta(first), style: AppText.body.copyWith(fontSize: 14, color: AppColors.eyebrow, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ───── State 2: Active ─────
  Widget _active() {
    if (_noteOpen) return _noteEditor();
    final isTime = _ex.kind == ExerciseKind.time;
    return Column(
      children: [
        // Top: progress segments + exit
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
          child: Row(
            children: [
              Expanded(child: _progressSegments(_total, _exIdx)),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _openExNote,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.edit_note_rounded, color: AppColors.text, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _confirmExit,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.close, color: AppColors.text, size: 16),
                ),
              ),
            ],
          ),
        ),
        // Counter
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Упражнение ${_exIdx + 1} из $_total',
                  style: AppText.metaSmall.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('${((_exIdx / _total) * 100).round()}%',
                  style: AppText.metaSmall.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        // Video placeholder
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2A2A30), Color(0xFF17171A)],
                ),
              ),
              child: Stack(
                children: [
                  // «Техника» бейдж
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0x8C000000),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.lime,
                            boxShadow: [BoxShadow(color: AppColors.lime, blurRadius: 8)],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text('Техника',
                            style: AppText.metaSmall.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text)),
                      ]),
                    ),
                  ),
                  // Play в центре
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.whiteAlpha(0.18),
                        border: Border.all(color: AppColors.whiteAlpha(0.4), width: 1.5),
                      ),
                      child: const Icon(AppIcons.play, color: AppColors.text, size: 22),
                    ),
                  ),
                  // Иконка-заглушка типа упражнения
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Icon(AppIcons.dumbbell, color: AppColors.whiteAlpha(0.14), size: 32),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Title + set
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            children: [
              Text(_ex.name, textAlign: TextAlign.center, style: AppText.metricLg.copyWith(fontSize: 22, letterSpacing: -0.4)),
              const SizedBox(height: 4),
              Text('Подход $_setIdx из ${_ex.sets}',
                  style: AppText.metaSmall.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
              _lastNoteHint(),
            ],
          ),
        ),
        // Reps or Timer
        Expanded(
          child: Center(
            child: isTime
                ? ProgressRing(
                    value: _timeLeft / _ex.amount,
                    size: 200,
                    stroke: 8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$_timeLeft',
                            style: AppText.metricXl.copyWith(fontSize: 56, color: AppColors.gold, letterSpacing: -2, height: 1.0)),
                        const SizedBox(height: 4),
                        Text('СЕКУНД', style: AppText.eyebrow.copyWith(letterSpacing: 1.4)),
                      ],
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('ПОВТОРОВ', style: AppText.eyebrow.copyWith(letterSpacing: 1.4)),
                      const SizedBox(height: 8),
                      Text('${_ex.amount}',
                          style: AppText.metricXl.copyWith(fontSize: 120, letterSpacing: -6, height: 1.0)),
                      if (_ex.unit != null) ...[
                        const SizedBox(height: 6),
                        Text(_ex.unit!, style: AppText.body.copyWith(fontSize: 14, color: AppColors.eyebrow, fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
          ),
        ),
        // Bottom controls
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _circleIconBtn(Icons.keyboard_double_arrow_left_rounded, _onPrev),
              const SizedBox(width: 18),
              _primaryAction(isTime
                  ? const Icon(Icons.pause, color: AppColors.bg, size: 28)
                  : Text('Готово', style: AppText.cardTitle.copyWith(color: AppColors.bg, fontSize: 15, fontWeight: FontWeight.w800))),
              const SizedBox(width: 18),
              _circleIconBtn(Icons.keyboard_double_arrow_right_rounded, _onNext),
            ],
          ),
        ),
      ],
    );
  }

  // ───── State 3: Rest ─────
  Widget _rest() {
    // Следующее упражнение для preview: если текущие подходы не кончились — то же,
    // иначе — следующее
    final nextIdx = _setIdx < _ex.sets ? _exIdx : (_exIdx + 1 < _w.exercises.length ? _exIdx + 1 : _exIdx);
    final next = _w.exercises[nextIdx];
    final m = _restLeft ~/ 60;
    final s = _restLeft % 60;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 36),
      child: Column(
        children: [
          // Header
          Column(
            children: [
              Text('ОТДЫХ', style: AppText.eyebrow.copyWith(color: AppColors.gold, letterSpacing: 1.8)),
              const SizedBox(height: 6),
              Text('Восстановись', style: AppText.metricLg.copyWith(fontSize: 26, letterSpacing: -0.5)),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProgressRing(
                  value: _restLeft / _restTotal,
                  size: 240,
                  stroke: 10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$m:${s.toString().padLeft(2, '0')}',
                          style: AppText.metricXl.copyWith(fontSize: 64, color: AppColors.gold, letterSpacing: -2, height: 1.0)),
                      const SizedBox(height: 6),
                      Text('ОСТАЛОСЬ', style: AppText.eyebrow.copyWith(letterSpacing: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _restAdjustBtn('−15с', () => setState(() => _restLeft = (_restLeft - 15).clamp(0, 999))),
                    const SizedBox(width: 12),
                    _restAdjustBtn('+15с', () => setState(() => _restLeft += 15)),
                  ],
                ),
              ],
            ),
          ),
          // Next exercise preview
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(AppIcons.dumbbell, color: AppColors.dim2, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ДАЛЕЕ', style: AppText.eyebrow.copyWith(fontSize: 10.5, letterSpacing: 1.2)),
                      const SizedBox(height: 3),
                      Text(next.name, style: AppText.body.copyWith(fontSize: 14, letterSpacing: -0.2)),
                      const SizedBox(height: 2),
                      Text(_exerciseMeta(next), style: AppText.metaSmall.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Skip rest CTA
          GestureDetector(
            onTap: _startNextSet,
            child: Container(
              width: double.infinity,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.lime,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [BoxShadow(color: AppColors.lime.withValues(alpha: 0.25), blurRadius: 32, offset: const Offset(0, 12))],
              ),
              child: Text('Пропустить отдых',
                  style: AppText.cardTitle.copyWith(color: AppColors.bg, fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  // ───── State 4: Paused (overlay-like) ─────
  Widget _paused() {
    return Container(
      color: const Color(0xE00E0E10),
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 60, offset: Offset(0, 30))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface2,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.pause, color: AppColors.text, size: 28),
            ),
            const SizedBox(height: 20),
            Text('Пауза', style: AppText.metricLg.copyWith(fontSize: 26, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            Text('${_ex.name} · подход $_setIdx из ${_ex.sets}',
                textAlign: TextAlign.center,
                style: AppText.metaSmall.copyWith(fontSize: 13, height: 1.45)),
            const SizedBox(height: 22),
            // Progress preview
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.whiteAlpha(0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(child: _progressSegments(_total, _exIdx)),
                  const SizedBox(width: 10),
                  Text('${_exIdx + 1}/$_total',
                      style: AppText.metaSmall.copyWith(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            // Resume
            _pillCta('Продолжить', _resume, primary: true),
            const SizedBox(height: 10),
            _pillCta('Выйти из тренировки', _exitWorkout, primary: false),
          ],
        ),
      ),
    );
  }

  // ───── State 5: Finished ─────
  Widget _finished() {
    return _FinishedView(workout: _w, onDone: () => Navigator.of(context).pop(true));
  }

  // ───── Хелперы ─────

  String _exerciseMeta(PlayerExercise ex) {
    final unit = ex.unit ?? (ex.kind == ExerciseKind.time ? 'сек' : '');
    return '${ex.sets} × ${ex.amount}${unit.isNotEmpty ? ' $unit' : ''}';
  }

  Widget _progressSegments(int total, int current) {
    return Row(
      children: List.generate(total, (i) {
        Color color;
        double opacity;
        if (i < current) {
          color = AppColors.gold;
          opacity = 0.65;
        } else if (i == current) {
          color = AppColors.gold;
          opacity = 1.0;
        } else {
          color = AppColors.whiteAlpha(0.1);
          opacity = 1.0;
        }
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
            child: Opacity(
              opacity: opacity,
              child: Container(
                height: 4,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _circleIconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface2,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.text, size: 22),
      ),
    );
  }

  Widget _primaryAction(Widget child) {
    return GestureDetector(
      onTap: _onPrimary,
      child: Container(
        width: 86,
        height: 86,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.lime,
          boxShadow: [BoxShadow(color: AppColors.lime.withValues(alpha: 0.33), blurRadius: 32, offset: const Offset(0, 12))],
        ),
        child: child,
      ),
    );
  }

  Widget _restAdjustBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(label, style: AppText.label.copyWith(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _pillCta(String label, VoidCallback onTap, {required bool primary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primary ? AppColors.lime : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: primary ? null : Border.all(color: AppColors.whiteAlpha(0.18)),
          boxShadow: primary
              ? [BoxShadow(color: AppColors.lime.withValues(alpha: 0.25), blurRadius: 32, offset: const Offset(0, 12))]
              : null,
        ),
        child: Text(label,
            style: AppText.cardTitle.copyWith(
                color: primary ? AppColors.bg : AppColors.text, fontSize: 16, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

// ───── Финал — отдельный StatefulWidget из-за выбора настроения ─────
class _FinishedView extends StatefulWidget {
  final PlayerWorkout workout;
  final VoidCallback onDone;
  const _FinishedView({required this.workout, required this.onDone});

  @override
  State<_FinishedView> createState() => _FinishedViewState();
}

class _FinishedViewState extends State<_FinishedView> {
  String? _mood;
  final TextEditingController _noteCtrl = TextEditingController();
  bool _noteOpen = false;
  bool _saving = false;

  static const _moods = [
    (id: 'tough', label: 'Тяжело', glyph: '😮‍💨'),
    (id: 'good', label: 'Хорошо', glyph: '🙂'),
    (id: 'fire', label: 'Огонь', glyph: '🔥'),
  ];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_saving) return;
    _saving = true;
    final note = _noteCtrl.text.trim();
    await WorkoutLogService.saveWorkoutEntry(
      workoutTitle: widget.workout.title,
      mood: _mood,
      note: note.isEmpty ? null : note,
    );
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.workout;
    return Stack(
      children: [
        Positioned(
          top: 80,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.gold.withValues(alpha: 0.15), Colors.transparent],
                  stops: const [0.0, 0.65],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 36),
          child: Column(
            children: [
              // Контент скроллится — при клавиатуре просто прокрутка,
              // никаких модалок и внешнего IntrinsicHeight.
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold,
                          boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.33), blurRadius: 60, offset: const Offset(0, 20))],
                        ),
                        child: const Icon(Icons.check_rounded, color: AppColors.bg, size: 58),
                      ),
                      const SizedBox(height: 26),
                      Text('ГОТОВО', style: AppText.eyebrow.copyWith(color: AppColors.mutedGreen, letterSpacing: 1.8)),
                      const SizedBox(height: 8),
                      Text('Тренировка завершена!',
                          textAlign: TextAlign.center,
                          style: AppText.metricLg.copyWith(fontSize: 28, letterSpacing: -0.6)),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 280,
                        child: Text('${w.title} · ты в форме сегодня.',
                            textAlign: TextAlign.center,
                            style: AppText.body.copyWith(fontSize: 14, color: AppColors.dim, fontWeight: FontWeight.w500, height: 1.45)),
                      ),
                      const SizedBox(height: 28),
                      // Stats
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              _stat('${w.minutes}', 'минут'),
                              Container(width: 1, color: AppColors.whiteAlpha(0.06)),
                              _stat('${w.kcal}', 'ккал'),
                              Container(width: 1, color: AppColors.whiteAlpha(0.06)),
                              _stat('${w.exercises.length}', 'упражнений'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      // Mood picker
                      Text('Как ощущения?',
                          style: AppText.label.copyWith(color: AppColors.eyebrow, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
                      const SizedBox(height: 10),
                      Row(
                        children: _moods.map((m) {
                          final active = _mood == m.id;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: m.id != 'fire' ? 8 : 0),
                              child: GestureDetector(
                                onTap: () => setState(() => _mood = m.id),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: active ? AppColors.goldTint(0.1) : AppColors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: active ? AppColors.gold : AppColors.border, width: active ? 1.5 : 1),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(m.glyph, style: const TextStyle(fontSize: 22)),
                                      const SizedBox(height: 4),
                                      Text(m.label,
                                          style: AppText.metaSmall.copyWith(
                                              fontSize: 11, fontWeight: FontWeight.w700, color: active ? AppColors.gold : AppColors.eyebrow)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      _noteSection(),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _finish,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.lime,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [BoxShadow(color: AppColors.lime.withValues(alpha: 0.25), blurRadius: 32, offset: const Offset(0, 12))],
                  ),
                  child: Text('Готово',
                      style: AppText.cardTitle.copyWith(color: AppColors.bg, fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Заметка инлайн (без модалок): строка-кнопка раскрывается в поле ввода.
  Widget _noteSection() {
    if (!_noteOpen) {
      return GestureDetector(
        onTap: () => setState(() => _noteOpen = true),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.plus, color: AppColors.eyebrow, size: 16),
              const SizedBox(width: 8),
              Text('Добавить заметку',
                  style: AppText.body.copyWith(fontSize: 14, color: AppColors.eyebrow)),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ЗАМЕТКА О ТРЕНИРОВКЕ', style: AppText.eyebrow.copyWith(letterSpacing: 1.2)),
        const SizedBox(height: 8),
        TextField(
          controller: _noteCtrl,
          autofocus: true,
          minLines: 1,
          maxLines: 3,
          maxLength: 200,
          textInputAction: TextInputAction.done,
          cursorColor: AppColors.lime,
          style: AppText.body.copyWith(color: AppColors.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Например: не доспал, тяжело зашло',
            hintStyle: AppText.body.copyWith(color: AppColors.dim2, fontSize: 14),
            filled: true,
            fillColor: AppColors.surface,
            counterStyle: AppText.metaSmall.copyWith(color: AppColors.eyebrow),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: AppColors.gold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppText.metricLg.copyWith(fontSize: 22, letterSpacing: -0.4)),
          const SizedBox(height: 4),
          Text(label.toUpperCase(),
              style: AppText.metaSmall.copyWith(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
