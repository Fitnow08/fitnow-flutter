# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Отвечай всегда кратко и по делу. Отвечай как сеньер разработчик с большим опытом
## Project status

This is an early-stage Flutter project generated from the default `flutter create` template. As of now:

- `lib/main.dart` still contains the default counter-app scaffold (with two known broken lines using bare `.fromSeed(...)` and `.center` — likely from an editor stripping class prefixes; verify before assuming code compiles).
- `lib/app.dart` exists but is empty — placeholder for the top-level `App` widget once `main.dart` is split.
- `lib/features/` exists but is empty — intended for feature-first folder structure (e.g. `lib/features/<feature_name>/`).
- Only one test (`test/widget_test.dart`) — the default counter smoke test, tied to `MyApp` in `main.dart`. Any rename/move of `MyApp` will break it.

Dart SDK constraint: `^3.11.5`. Lints: `flutter_lints: ^6.0.0` via `analysis_options.yaml`.

## Commands

All commands run from the project root (`E:\projects\fullstack\fitnow\fitnow_flutter`).

| Task | Command |
|------|---------|
| Install/refresh deps | `flutter pub get` |
| Run on Android emulator | `flutter run -d emulator-5554` (or `flutter run -d emulator` — substring match works) |
| List available devices | `flutter devices` |
| Static analysis (lint) | `flutter analyze` |
| Format | `dart format .` |
| Run all tests | `flutter test` |
| Run a single test file | `flutter test test/widget_test.dart` |
| Run a single test by name | `flutter test --plain-name "Counter increments smoke test"` |
| Clean build artifacts | `flutter clean` |
| Build release APK | `flutter build apk` |

### Hot reload / restart

While `flutter run` is attached, type into the same terminal:
- `r` — hot reload (preserves state)
- `R` — hot restart (resets state)
- `q` — quit

### Dev environment

The user works from Zed (terminal-based Flutter CLI) and uses Android Studio only to launch the Android emulator. Don't suggest IDE-specific Run buttons — give terminal commands.

## Platforms

The project has scaffolding for `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`. No platform-specific code has been written yet beyond the generated runners, so `flutter run` works on any of them, but primary target right now is Android (emulator-5554).
