part of 'intro_bloc.dart';

sealed class IntroState extends Equatable {
  @override
  List<Object?> get props => [];
}

class IntroCarousel extends IntroState {
  IntroCarousel({
    this.isLastItem = false,
    this.currentPosition = 0,
  });

  final int currentPosition;
  final bool isLastItem;

  @override
  List<Object> get props => [currentPosition, isLastItem];
}

class IntroWelcome extends IntroState {}
