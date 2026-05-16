import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final onboardingServiceProvider = Provider<OnboardingService>(
  (ref) => throw UnimplementedError('Override in main() with a resolved instance'),
);

class OnboardingService {
  OnboardingService(this._prefs);

  final SharedPreferences _prefs;

  static const _seenHelloKey = 'seen_hello';

  bool get hasSeenHello => _prefs.getBool(_seenHelloKey) ?? false;

  Future<void> markHelloSeen() => _prefs.setBool(_seenHelloKey, true);

  Future<void> reset() => _prefs.remove(_seenHelloKey);
}
