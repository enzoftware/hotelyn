import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'intro_event.dart';
part 'intro_state.dart';

class IntroBloc extends Bloc<IntroEvent, IntroState> {
  IntroBloc() : super(IntroCarousel()) {
    on<IntroPageChanged>(_onPageChanged);
    on<IntroGoToWelcome>(_onGoToWelcome);
  }

  FutureOr<void> _onGoToWelcome(
    IntroGoToWelcome event,
    Emitter<IntroState> emit,
  ) {
    emit(IntroWelcome());
  }

  FutureOr<void> _onPageChanged(
    IntroPageChanged event,
    Emitter<IntroState> emit,
  ) {
    emit(
      IntroCarousel(
        currentPosition: event.position,
        isLastItem: event.isLastItem,
      ),
    );
  }
}
