import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'on_boarding_event.dart';
part 'on_boarding_state.dart';

class OnBoardingBloc extends Bloc<OnBoardingEvent, OnBoardingState> {
  OnBoardingBloc() : super(OnBoardingIntro()) {
    on<OnBoardingPageChanged>(_onPageChanged);
    on<OnBoardingGoToWelcome>(_onGoToWelcome);
  }

  FutureOr<void> _onGoToWelcome(
    OnBoardingGoToWelcome event,
    Emitter<OnBoardingState> emit,
  ) {
    emit(OnBoardingWelcome());
  }

  FutureOr<void> _onPageChanged(
    OnBoardingPageChanged event,
    Emitter<OnBoardingState> emit,
  ) {
    emit(
      OnBoardingIntro(
        currentPosition: event.position,
        isLastItem: event.isLastItem,
      ),
    );
  }
}
