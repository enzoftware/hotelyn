import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotelyn/core/domain/repository/onboarding_repository.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc({required OnBoardingRepository onBoardingRepository})
      : _onBoardingRepository = onBoardingRepository,
        super(SplashInitial()) {
    on<SplashStarted>(_onStartSplash);
  }

  final OnBoardingRepository _onBoardingRepository;

  FutureOr<void> _onStartSplash(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    final result = await _onBoardingRepository.isOnBoardingPassed();
    final navigateTo = result ? SplashToHome() : SplashToOnBoarding();
    emit(navigateTo);
  }
}
