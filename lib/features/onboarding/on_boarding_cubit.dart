import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/features/onboarding/data/on_boarding_data.dart';
import 'package:hotelyn/features/onboarding/on_boarding_state.dart';

class OnBoardingCubit extends Cubit<OnBoardingState> {
  OnBoardingCubit()
      : super(
          OnBoardingState(
            currentPosition: 0,
            primaryButtonMessage: 'Continue',
            data: onBoardingData,
          ),
        );

  void updateCurrentPosition(int position) {
    // Change primaryButtonMessage value when the current position
    // matches the last position
    if (position == onBoardingData.length - 1) {
      emit(
        state.copyWith(
          currentPosition: position,
          primaryButtonMessage: 'Get Started',
        ),
      );
    } else {
      emit(
        state.copyWith(
          currentPosition: position,
          primaryButtonMessage: 'Continue',
        ),
      );
    }
  }
}
