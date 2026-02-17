part of 'splash_bloc.dart';

sealed class SplashState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {}

class SplashToIntro extends SplashState {}

class SplashToLogin extends SplashState {}

class SplashToHome extends SplashState {}
