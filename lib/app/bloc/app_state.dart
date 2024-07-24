part of 'app_bloc.dart';

sealed class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

final class LoadingAuthStatus extends AppState {}

final class AppStateAuthenticated extends AppState {
  const AppStateAuthenticated({required this.user});

  final User user;

  @override
  List<Object> get props => [user];
}

final class AppStateUnauthenticated extends AppState {}
