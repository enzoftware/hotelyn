part of 'on_boarding_bloc.dart';

sealed class OnBoardingEvent extends Equatable {
  const OnBoardingEvent();

  @override
  List<Object> get props => [];
}

class OnBoardingPageChanged extends OnBoardingEvent {
  const OnBoardingPageChanged({
    required this.position,
    this.isLastItem = false,
  });

  final int position;
  final bool isLastItem;

  @override
  List<Object> get props => [position, isLastItem];
}

class OnBoardingGoToWelcome extends OnBoardingEvent {
  const OnBoardingGoToWelcome();
}
