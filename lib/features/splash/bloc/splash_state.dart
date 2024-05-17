part of 'splash_bloc.dart';

sealed class SplashState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {}

class SplashToOnBoarding extends SplashState {}

class SplashToHome extends SplashState {}
