import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/features/splash/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial()) {
    _load();
  }

  Future<void> _load() async {
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      await Future.delayed(const Duration(seconds: 1));
    }
    // Validate if on boaarding was already passed by the user, default false
    emit(SplashToOnBoarding());
  }
}
