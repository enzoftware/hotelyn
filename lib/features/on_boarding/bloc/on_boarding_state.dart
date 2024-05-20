part of 'on_boarding_bloc.dart';

sealed class OnBoardingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OnBoardingIntro extends OnBoardingState {
  OnBoardingIntro({
    this.isLastItem = false,
    this.currentPosition = 0,
  });

  final int currentPosition;
  final bool isLastItem;

  @override
  List<Object> get props => [currentPosition, isLastItem];
}

class OnBoardingWelcome extends OnBoardingState {}
