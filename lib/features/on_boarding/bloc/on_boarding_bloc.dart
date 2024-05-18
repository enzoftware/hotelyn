import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'on_boarding_event.dart';
part 'on_boarding_state.dart';

class OnBoardingBloc extends Bloc<OnBoardingEvent, OnBoardingState> {
  OnBoardingBloc() : super(OnboardingInitial()) {
    on<OnBoardingEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
