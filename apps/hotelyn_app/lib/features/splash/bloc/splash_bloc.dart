import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotelyn/core/domain/repository/repository.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc({
    required this.introRepository,
    required this.authRepository,
  }) : super(SplashInitial()) {
    on<SplashStarted>(_onStartSplash);
  }

  final IntroRepository introRepository;
  final AuthRepository authRepository;

  FutureOr<void> _onStartSplash(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    final introPassed = await introRepository.isIntroPassed();

    if (!introPassed) {
      emit(SplashToIntro());
      return;
    }

    // Check if user is authenticated
    if (authRepository.isAuthenticated) {
      // Initialize Clarity with the stored user ID for returning users
      authRepository.initializeClarityUser();
      emit(SplashToHome());
    } else {
      emit(SplashToLogin());
    }
  }
}
