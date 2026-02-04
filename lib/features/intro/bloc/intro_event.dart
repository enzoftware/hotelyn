part of 'intro_bloc.dart';

sealed class IntroEvent extends Equatable {
  const IntroEvent();

  @override
  List<Object> get props => [];
}

class IntroPageChanged extends IntroEvent {
  const IntroPageChanged({
    required this.position,
    this.isLastItem = false,
  });

  final int position;
  final bool isLastItem;

  @override
  List<Object> get props => [position, isLastItem];
}

class IntroGoToWelcome extends IntroEvent {
  const IntroGoToWelcome();
}
