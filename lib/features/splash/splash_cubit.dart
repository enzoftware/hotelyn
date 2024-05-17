import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/core/data/preferences/repository/preference_repository.dart';
import 'package:hotelyn/features/splash/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({required PreferenceRepository preferenceRepository})
      : _preferenceRepository = preferenceRepository,
        super(SplashInitial()) {
    _load();
  }

  final PreferenceRepository _preferenceRepository;

  Future<void> _load() async {
    // Validate if we're on a testing envinronment
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      await Future.delayed(const Duration(seconds: 1));
    }
    final result = await _preferenceRepository.isOnBoardingPassed();
    final navigateTo = result ? SplashToHome() : SplashToOnBoarding();
    emit(navigateTo);
  }
}
