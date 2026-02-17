import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotelyn/core/domain/repository/repository.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc({
    required IntroRepository introRepository,
    required AuthRepository authRepository,
  })  : _introRepository = introRepository,
        _authRepository = authRepository,
        super(SplashInitial()) {
    on<SplashStarted>(_onStartSplash);
  }

  final IntroRepository _introRepository;
  final AuthRepository _authRepository;

  FutureOr<void> _onStartSplash(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    final introPassed = await _introRepository.isIntroPassed();

    if (!introPassed) {
      emit(SplashToIntro());
      return;
    }

    // Check if user is authenticated
    if (_authRepository.isAuthenticated) {
      // Initialize Clarity with the stored user ID for returning users
      _authRepository.initializeClarityUser();
      emit(SplashToHome());
    } else {
      emit(SplashToLogin());
    }
  }
}
