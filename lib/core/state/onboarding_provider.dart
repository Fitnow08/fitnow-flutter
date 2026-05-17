import 'package:fitnow/core/configs/services/onboarding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingProvider = NotifierProvider<OnboardingNotifier, bool>(
  OnboardingNotifier.new,
);

class OnboardingNotifier extends Notifier<bool> {
  late OnboardingService _service;

  @override
  bool build() {
    _service = ref.watch(onboardingServiceProvider);
    return _service.hasSeenHello;
  }

  Future<void> setSeen(bool value) async {
    await _service.setHelloSeen(value);
    state = value;
  }
}
